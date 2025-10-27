-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright (c) 2022-2025 Thomas Floeren

local MYNAME, A = ...
local user_is_author = false

local WTC = WrapTextInColorCode
local tonumber = tonumber
local type = type

local FLAGS = '' -- For our purpose, we do not want any outlining.

local colors = {
	EFI = '1E90FF', -- dodgerblue
-- 	HEAD = 'FFEFD5', -- papayawhip
	HEAD = 'FFE4B5', -- moccasin
	WARN = 'FF4500', -- orangered
	BAD = 'DC143C', -- crimson
	ON = '32CD32', -- limegreen
	OFF = 'C0C0C0', -- silver
-- 	CMD = '6495ED', -- cornflowerblue
	CMD = 'FFA500', -- orange
	KEY = 'FFD700', -- gold
	FONT = '00FA9A', -- mediumspringgreen
	PATH = '90EE90', -- lightgreen
-- 	DEBUG = 'EE82EE', -- violet
	DEBUG = 'FF00FF', -- magenta
}

local CLR = setmetatable({}, {
	__index = function(_, k)
		local color = colors[k]
		assert(color, format('Color %q not defined.', k))
		color = 'FF' .. color
		return function(text) return text and WTC(text, color) or color end
	end,
})

local MSG_PREFIX = CLR.EFI('EditBox Font Improver:')
local FONTPATH_WARNING = CLR.WARN('Font path is not valid!')
	.. ' Make sure that a font file exists at this location, or change the path: \n%s'
local RESET_WARNING = format(
	'Due to an update to the database structure, %s. If you were using EFI version 2 or older, please %s, as there are numerous changes in settings and usage.',
	CLR.WARN("EFI's database has been reset to its default values"),
	CLR.KEY('refer to the ReadMe or the description on CurseForge')
)
local NOTHING_FOUND = CLR.BAD('<NOTHING FOUND>')
local BLOCKSEP = CLR.EFI(strrep('+', 42))

-- We opt to not raise an error if a font cannot be set, and just print a one-time warning.
-- The user will notice that the font is not set when they open the relevant addon.
local function warnprint(msg)
	print(format('%s %s %s', MSG_PREFIX, CLR.WARN('WARNING:'), msg))
end

local function efiprint(msg) print(format('%s %s', MSG_PREFIX, msg)) end

local ITERATORS = {
	['-'] = -1, ['+'] = 1, ['='] = 1, [','] = -1, ['.'] = 1,
}

--[[===========================================================================
	Defaults
===========================================================================]]--

local function merge_defaults(src, dst)
	for k, v in pairs(src) do
		local src_type = type(v)
		if src_type == 'table' then
			if type(dst[k]) ~= 'table' then dst[k] = {} end
			merge_defaults(v, dst[k])
		elseif type(dst[k]) ~= src_type then
			dst[k] = v
		end
	end
end

local db_emptied = nil
local function empty_db()
	if type(_G.EBFI_DB) == 'table' then
		wipe(_G.EBFI_DB)
		db_emptied = true
	else
		-- Should never happen.
		warnprint "Unexpected: Failed to empty EBFI_DB, as it is not a table."
		_G.EBFI_DB = {}
	end
end

-- 1: v3.0.0, Oct 24, 2025: significant; removed/added/renamed keys --> reset all
local DB_VERSION_CURRENT = 1

local defaults = {
	fontfile = 'Interface/AddOns/EditBox-Font-Improver/fonts/pt-mono_regular.ttf',
	fontsize = 12,
	userfonts = nil, -- TODO: user fonts
	macroeditors = {
		enable = true,
		ownsize = nil, -- Always EFI size, since these addons have no own size setting
	},
	wowlua = {
		enable = true,
		ownsize = true,
	},
	scriptlibrary = {
		enable = true,
		ownsize = true,
	},
	bugsack = {
		enable = true,
		ownsize = true,
	},
	debugmode = false,
	db_version = DB_VERSION_CURRENT,
	db_touched = nil,
}

if type(_G.EBFI_DB) ~= 'table' then
	_G.EBFI_DB = {}
-- empty_db() triggers a warn print that we don’t want to see during a first installation.
elseif not _G.EBFI_DB.db_version or _G.EBFI_DB.db_version ~= DB_VERSION_CURRENT then
	empty_db()
end

merge_defaults(defaults, _G.EBFI_DB)
local db = _G.EBFI_DB


--[[===========================================================================
	Setup
===========================================================================]]--

local dfonts = A.defaultfonts
local base_path, extension = 'Interface/AddOns/EditBox-Font-Improver/fonts/', '.ttf'

for i, v in ipairs(dfonts) do
	local name = v
	local ext = name:sub(-4) -- with the dot
	dfonts[i] = base_path .. name .. ((ext == '.otf' or ext == '.ttf') and '' or extension)
end

-- not yet implemented, TODO
local ufonts = db.userfonts
-- TODO: for the user font implementation: we should simply prepend the user table to our dfonts
-- This will greatly simplify array handling e.g in our fontlisting etc. functions

local efi_font = db.fontfile

local function debugprint(...)
	if db.debugmode then
		local a, b = strsplit('.', GetTimePreciseSec())
		print(format('[%s.%s] %s', a:sub(-3), b:sub(1, 3), CLR.DEBUG('EFI Debug >')), ...)
	end
end

local function create_fontobj()
	local efi_fontobject = CreateFont 'efi_fontobject'
	efi_fontobject:SetFont(efi_font, db.fontsize, FLAGS)
	if efi_fontobject:GetFont() == efi_font then return true end
	warnprint(FONTPATH_WARNING:format(efi_font))
end

-- Potential candidates to add:
-- PasteNG
-- Chattynator chat EditBox
-- Blizz chat editbox

local addons = {
	macroeditors = {
		name = 'macro editors',
		abbrev = 'me',
		has_sizecfg = false,
		loaded = true,
		setup_done = false,
	},
	wowlua = {
		name = 'WowLua',
		abbrev = 'wl',
		has_sizecfg = true,
		loaded = false,
		setup_done = false,
	},
	scriptlibrary = {
		name = 'ScriptLibrary',
		abbrev = 'sl',
		has_sizecfg = true,
		loaded = false,
		hook_done = false,
		setup_done = false,
	},
	bugsack = {
		name = 'BugSack',
		abbrev = 'bs',
		has_sizecfg = true,
		loaded = false,
		hook_done = false,
		setup_done = false,
	},
}

-- The Size Situation:

-- Blizz Macro:   fix 10
-- M6 and OPie:   fix 12
-- WoWLua:        configurable 5 to 24
-- ScriptLibrary: configurable 8 to 16
-- BugSack:       configurable 10 to 16

-- BugSack's built-in sizes:
-- Small = GameFontHighlightSmall: 10
-- Medium = GameFontHighlight: 12
-- Large = GameFontHighlightMedium: 14
-- X-Large = GameFontHighlightLarge: 16


--[[===========================================================================
	Straightforward Frames (macro editors)
===========================================================================]]--

-- https://www.townlong-yak.com/addons/m6
-- https://www.townlong-yak.com/addons/opie

-- Easy stuff, where we can simply apply our font object.
-- The frames are created at load time, so no need to hook (Blizzard_MacroUI needs
-- OptionalDeps!). A missing addon doesn't pose a problem, as it just creates a
-- nil value in the array.
function addons.macroeditors.setup()
	local editboxes = {
		MacroFrameText, -- Blizzard_MacroUI; also affects ImprovedMacroFrame.
		ABE_MacroInputEB, -- M6 and OPie macro edit box.
	}
	-- Don't use `ipairs' because the entries may be nil (addon not loaded).
	local count = 0
	for _, box in pairs(editboxes) do
		box:SetFontObject(efi_fontobject)
		debugprint('Set up ' .. box:GetName())
		count = count + 1
	end
	addons.macroeditors.setup_done = true
	debugprint('Setup for misc macro editors finished (' .. count .. ' of ' .. #editboxes .. ').')
end


--[[===========================================================================
	WoWLua
===========================================================================]]--

-- https://www.curseforge.com/wow/addons/wowlua

-- We directly manipulate WoWLua's font object, otherwise we get reset when the
-- user changes font size in WoWLua.
-- We use the font size as actually set in the WowLua GUI.
function addons.wowlua.setup()
	if WowLuaMonoFontSpaced then
		local size = db.wowlua.ownsize and WowLua_DB.fontSize or db.fontsize
		WowLuaMonoFont:SetFont(efi_font, size, FLAGS)
		WowLuaMonoFontSpaced:SetFont(efi_font, size, FLAGS)
		-- Needed to apply the font (not only the size)
		WowLua:UpdateFontSize(size)
		addons.wowlua.setup_done = true
	else
		warnprint "WowLua's `WowLuaMonoFontSpaced` not found. Could not set font."
	end
	debugprint 'WowLua setup finished.'
end


--[[===========================================================================
	BugSack
===========================================================================]]--

-- https://www.curseforge.com/wow/addons/bugsack

function addons.bugsack.setup()
	if BugSackScrollText then
		if db.bugsack.ownsize then
			local currentsize = BugSackScrollText:GetFontObject():GetFontHeight()
			BugSackScrollText:SetFont(
				efi_font,
				tonumber(currentsize) or db.fontsize,
				FLAGS
			)
		else
			BugSackScrollText:SetFontObject(efi_fontobject)
		end
		addons.bugsack.setup_done = true
		debugprint 'BugSack setup finished.'
	elseif not addons.bugsack.hook_done then
		addons.bugsack.hook()
	else
		warnprint 'BugSack target frame not found. Could not set font.'
	end
end

-- The main frame is not created before first open, so we have to hook.
function addons.bugsack.hook()
	if not BugSack.OpenSack then
		warnprint '`BugSack.OpenSack` not found. Could not hook.'
	else
		hooksecurefunc(BugSack, 'OpenSack', function()
			if not addons.bugsack.setup_done then addons.bugsack.setup() end
		end)
		debugprint 'BugSack hooked.'
	end
	addons.bugsack.hook_done = true
end


--[[===========================================================================
	ScriptLibrary
===========================================================================]]--

-- https://www.curseforge.com/wow/addons/script-library

function addons.scriptlibrary.setup()
	if RuntimeEditorMainWindowCodeEditorCodeEditorEditBox then
		local size = db.scriptlibrary.ownsize
				and tonumber(
					(select(2, RuntimeEditorMainWindowCodeEditorCodeEditorEditBox:GetFont()))
				)
			or db.fontsize
		RuntimeEditorMainWindowCodeEditorCodeEditorEditBox:SetFont(efi_font, size, FLAGS)
		addons.scriptlibrary.setup_done = true
		debugprint 'ScriptLibrary setup finished.'
	elseif not addons.scriptlibrary.hook_done then
		addons.scriptlibrary.hook()
	else
		warnprint 'ScriptLibrary target frame not found. Could not set font.'
	end
end

-- The main frame is not created before first open, so we have to hook.
-- Couldn't find any accessible 'open' function, so we use the slash command.
function addons.scriptlibrary.hook()
	if not SlashCmdList.SCRIPTLIBRARY then
		warnprint '`SlashCmdList.SCRIPTLIBRARY` not found. Could not hook.'
		return
	end
	hooksecurefunc(SlashCmdList, 'SCRIPTLIBRARY', function()
		if not addons.scriptlibrary.setup_done then
			addons.scriptlibrary.setup()
		end
	end)
	addons.scriptlibrary.hook_done = true
	debugprint 'ScriptLibrary hooked.'
end

-- I haven't found a way to grab the font size that is set in ScriptLibrary.
-- ScriptLibrary wipes its global DB after load, and practically all functions and variables are private.


--[[===========================================================================
	Run the Stuff
===========================================================================]]--

local ef = CreateFrame('Frame', MYNAME .. '_eventframe')

-- TODO: merge this func with the update_setup func
local function initial_setup()
	for k, v in pairs(addons) do
		if db[k].enable and v.loaded then v.setup() end
	end
end

local function PLAYER_LOGIN()
	if not create_fontobj() then
		-- Print the msg once more when login chat spam is over.
		C_Timer.After(20, function() warnprint(FONTPATH_WARNING:format(efi_font)) end)
		-- NOTE XXX: WoW seems to cache the font file *and also the path* until game
		-- exit; so this test may pass at login even with the file removed, and the
		-- ghost font is also still rendered in-game!
		return
	end
	if db_emptied then C_Timer.After(20, function() warnprint(RESET_WARNING) end) end
	addons.wowlua.loaded = C_AddOns.IsAddOnLoaded 'WowLua'
	addons.scriptlibrary.loaded = C_AddOns.IsAddOnLoaded 'ScriptLibrary'
	addons.bugsack.loaded = C_AddOns.IsAddOnLoaded 'BugSack'
	initial_setup()
	-- Debug
	user_is_author = tf6 and tf6.user_is_tflo
	if user_is_author then db.db_touched = true end

end

local event_handlers = {
	['PLAYER_LOGIN'] = PLAYER_LOGIN,
}

for event in pairs(event_handlers) do
	ef:RegisterEvent(event)
end

ef:SetScript('OnEvent', function(_, event, ...)
	event_handlers[event](...) ---@diagnostic disable-line: redundant-parameter
end)


--[[===========================================================================
	UI
===========================================================================]]--

-- Potential UI improvements, TODO:
-- next: limit he displayed fonts in the overview to the first 15 or so and
-- add a separate 'list all' command
-- 'next font' command, e.g. `n`
-- ambitious: a little font preview frame, which enables the scroll wheel to
-- quickly scan through the installed fonts

local function update_setup()
	if not create_fontobj() then return end
	for k, v in pairs(addons) do
		-- If setup is not yet done then a hook was installed but not yet triggered.
		if db[k].enable and v.setup_done then v.setup() end
	end
	return true
end

local function toggle_target(trg)
	local enable = not db[trg].enable
	db[trg].enable = enable
	efiprint(format('EFI is now %s for %s.%s', enable and CLR.ON('enabled') or CLR.OFF('disabled'), CLR.KEY(addons[trg].name), enable and '' or '\nA ' .. CLR.WARN('UI reload') .. ' is necessary to restore the original font.'))
	if enable and not addons[trg].setup_done then addons[trg].setup() end
end

-- Lookup for the target toggle command
local targetnames = setmetatable({}, {
	__index = function(t, key)
		if addons[key] then return key end
		for k, v in pairs(addons) do
			if v.abbrev == key then return k end
		end
	end,
})

--[[----------------------------------------------------------------------------
	Formatters
----------------------------------------------------------------------------]]--

local function prettyname(name)
	return name:gsub('[_-]+', ' '):gsub('%W%l', strupper):gsub('^pt ', 'PT ')
end

local function idx_from_path(path, array)
	local arrays = array and { array } or type(ufonts) == 'table' and { dfonts, ufonts } or { dfonts }
	if not arrays or type(arrays[1]) ~= 'table' then return CLR.BAD('<invalid array>') end
	for _, array in ipairs(arrays) do
		for i, v in ipairs(array) do
			if v == path then return array == ufonts and 'u' .. i or i end
		end
	end
	return CLR.BAD('<no index>')
end

local function fontname(path, withidx, array)
	withidx = withidx == nil and true or withidx
	local idx = withidx and idx_from_path(path, array)
	local pattern = db.debugmode and '[^/\\]+$' or '([^/\\]+)%.[tof]+'
	local name = tostring(path):match(pattern)
	if not name then return NOTHING_FOUND end
	name = db.debugmode and name or prettyname(name)
	return CLR.FONT(idx and '[' .. idx .. ']\194\160' .. name or name)
end

local function fontpath(path)
	local pattern = '.+[/\\]'
	return CLR.PATH(tostring(path):match(pattern)) or NOTHING_FOUND
end

local function listfonts(array, compact)
	if type(array) ~= 'table' or #array == 0 then return NOTHING_FOUND end
	local fonts = {}
	for i, v in ipairs(array) do
		tinsert(fonts, fontname(v)) -- , true, array
		if compact and i == A.NUM_FONTS_COMPACTLIST then break end
	end
	-- We cannot print 30 lines as one string due to Blizz's broken chat scrolling
	return compact and table.concat(fonts, ', ') or fonts
end

local function listfontpaths(array, sep)
	if type(array) ~= 'table' or #array == 0 then return NOTHING_FOUND end
	sep = sep or ', '
	local seen, result = {}, {}
	for _, v in ipairs(array) do
		local path = fontpath(v)
		if not seen[path] then
			seen[path] = true
			tinsert(result, path)
		end
	end
	table.sort(result)
	return table.concat(result, sep)
end


--[[----------------------------------------------------------------------------
	Large texts
----------------------------------------------------------------------------]]--

local function print_multi(lines)
	for _, v in ipairs(lines) do
		print(v)
	end
end

local function statusbody()
	-- addon efi-enabled / loaded
	local states = {}
	for k, v in pairs(addons) do
		local str = format(
			'%s: %s/%s',
			v.name,
			db[k].enable and CLR.ON('Yes') or CLR.OFF('No'),
			v.loaded and CLR.ON('Yes') or CLR.OFF('No')
		)
		tinsert(states, str)
	end
	table.sort(states)
	states = table.concat(states, '; ')
	-- size policies TODO
	local sizepols = {}
	for k, v in pairs(addons) do
		local str = format(
			'%s: %s',
			v.name,
			db[k].ownsize and CLR.KEY('Own') or CLR.KEY('Uni')
		)
		tinsert(sizepols, str)
	end
	table.sort(sizepols)
	sizepols = table.concat(sizepols, '; ')
	return db.debugmode
			and {
				format('%s %s', CLR.HEAD('Current font:'), fontname(db.fontfile)),
				format('%s %s', CLR.HEAD('Current font size:'), CLR.KEY(db.fontsize)),
				format('%s %s', CLR.HEAD('Current font path:'), fontpath(db.fontfile)), -- TODO: user fonts
				format(
					'%s %s; %s %s',
					CLR.HEAD('Num fonts: default:'),
					CLR.KEY(#dfonts),
					CLR.HEAD('user [NYI!]:'),
					CLR.KEY(type(ufonts) == 'table' and #ufonts or 'nil')
				), -- TODO: user fonts
				format('%s %s', CLR.HEAD('Default fonts:'), listfonts(dfonts, true)),
				format('%s %s', CLR.HEAD('User fonts [NYI!]:'), listfonts(ufonts, true)), -- TODO: user fonts
				format('%s \n   %s', CLR.HEAD('User font paths [NYI!]:'), listfontpaths(ufonts, '\n   ')), -- TODO: user fonts
				format('%s %s', CLR.HEAD('Enabled for addon/loaded:'), states),
				format('%s %s', CLR.HEAD('Ownsize/Unisize:'), sizepols),
				format('%s %s', CLR.HEAD('Debug mode:'), db.debugmode and 'On' or 'Off'),
				format('%s %s', CLR.HEAD('User is author:'), user_is_author and 'Yes' or 'No'),
			}
		or {
			format('%s %s', CLR.HEAD('Current font:'), fontname(db.fontfile)),
			format('%s %s', CLR.HEAD('Current font size:'), CLR.KEY(db.fontsize)),
			format('%s %s. Use %q to list all.', CLR.HEAD('Number of installed fonts:'), CLR.KEY(#dfonts), CLR.CMD('/efi\194\160f')),
			format('%s %s', CLR.HEAD(('Installed fonts ' .. CLR.KEY('[1\226\128\147' .. A.NUM_FONTS_COMPACTLIST .. ']') .. ':')), listfonts(dfonts, true)),
			format('%s %s', CLR.HEAD('Enabled for addon/loaded:'), states),
			format('%s %s', CLR.HEAD('Ownsize/Unisize:'), sizepols),
		}
end

local function shorthelpbody()
	return format(
		'%s %q to set the font size, %q to select a font by index, %q for the complete help with all commands explained.',
		CLR.EFI('Usage examples:'),
		CLR.CMD('/efi\194\160s\194\16014'),
		CLR.CMD('/efi\194\1603'),
		CLR.CMD('/efi\194\160h')
	)
end

local function fullhelpbody()
	return {
		format('%s : Select font by index (%s to %s).', CLR.CMD('/efi <index>'), CLR.KEY('1'), CLR.KEY(#dfonts)),
		format('%s : List all %s available fonts.', CLR.CMD('/efi f'), CLR.KEY(#dfonts)),
		format('%s : Set fontsize (default: %s).', CLR.CMD('/efi s <number>'), CLR.KEY(defaults.fontsize)),
		format('%s : Do not change the font size of addons that have their own size setting (default).', CLR.CMD('/efi ownsize')),
		format('%s : Apply font size to all addons, regardless of their own settings.', CLR.CMD('/efi unisize')),
		format('%s or just %s : Display status and info (index of fonts, current font, settings).', CLR.CMD('/efi s'), CLR.CMD('/efi')),
		format('%s : Display this help text.', CLR.CMD('/efi h')),
	}
end


--[[----------------------------------------------------------------------------
	Slash function
----------------------------------------------------------------------------]]--

SLASH_EditBoxFontImprover1 = '/efi'
SLASH_EditBoxFontImprover2 = '/ebfi'
SLASH_EditBoxFontImprover3 = '/editboxfontimprover'
SlashCmdList.EditBoxFontImprover = function(msg)
	local args = {}
	for arg in msg:gmatch('[^ ]+') do
		tinsert(args, arg)
	end
	-- Multi args: font
	-- Font selection
	if tonumber(args[1]) or ITERATORS[args[1]] then
		local selection = tonumber(args[1]) and floor(args[1]) or idx_from_path(db.fontfile) + ITERATORS[args[1]]
		if db.fontfile == dfonts[selection] then
			efiprint(
				format(
					'The font you have selected (%s) is already loaded.',
					CLR.FONT(fontname(dfonts[selection]))
				)
			)
		elseif not dfonts[selection] then
			efiprint(
				format(
					'The font you have selected (%s) does not exist. The font list contains only %s fonts.',
					CLR.FONT('[' .. selection .. ']'),
					CLR.KEY(#dfonts)
				)
			)
		else
			efi_font = dfonts[selection]
			if update_setup() then
				db.fontfile = dfonts[selection]
				efiprint(format('Your new font: %s', CLR.FONT(fontname(db.fontfile))))
			else
				efiprint(
					format(
						'The path of your selected font (%s) is not valid!. Your previous font will be used instead.',
						CLR.FONT('[' .. selection .. ']')
					)
				)
			end
		end
	elseif args[1] == 'f' and args[2] == 'inval' then -- Debug
		db.fontfile = db.fontfile:gsub('AddOns', 'AddOnsXXX')
		efiprint(format('Font path invalidated to: %s', db.fontfile))
	elseif args[1] == 'f' and args[2] == 'reval' then -- Debug
		db.fontfile = db.fontfile:gsub('AddOnsXXX', 'AddOns')
		efiprint(format('Font path revalidated to: %s', db.fontfile))
	-- Multi args: database (debug)
	elseif args[1] == 'db' and args[2] == 'reset' then -- Debug
		empty_db()
		merge_defaults(defaults, _G.EBFI_DB)
		db = _G.EBFI_DB
		efiprint(
			format(
				'Database reset to defaults: %s',
				db.db_touched and CLR.BAD('Failed to reset the DB!') or 'Yes.'
			)
		)
	elseif args[1] == 'db' and (args[2] == 'empty' or args[2] == 'wipe') then -- Debug
		empty_db()
		efiprint(
			format(
				'Database emptied: %s',
				next(db) == nil and 'Yes. Reload now.' or CLR.BAD('Failed to wipe the DB!')
			)
		)
	elseif args[1] == 'db' and args[2] == 'delete' then -- Debug
		_G.EBFI_DB, db = nil, nil
		efiprint(
			format(
				'Database deleted: %s',
				db == nil and 'Yes. Reload now.' or CLR.BAD('Failed to delete the DB!')
			)
		)
	elseif args[1] == 'db' and (args[2] == 'show' or args[2] == 'dump') then -- Debug
		DevTools_Dump(db)
	-- Multi args: fontsize
	elseif args[1] == 's' and tonumber(args[2]) or ITERATORS[args[2]] then
		db.fontsize = max(min(tonumber(args[2] or db.fontsize + ITERATORS[args[2]]), 28), 6)
		efiprint(
			format(
				'Font size set to %s. This does not affect the addons that are set to use their own font size setting (by default WowLua, Scriptlibrary, and BugSack).',
				CLR.KEY(db.fontsize)
			)
		)
		update_setup()
	-- Single arg
	elseif args[1] == 'unisize' then
		for k, v in pairs(addons) do
			if v.has_sizecfg then db[k].ownsize = false end
		end
		efiprint "All addons set to use EFI's default font size."
		update_setup()
	elseif args[1] == 'ownsize' then
		for k, v in pairs(addons) do
			if v.has_sizecfg then db[k].ownsize = true end
		end
		efiprint 'All addons with a configurable font size will keep their own size setting.'
		update_setup()
	elseif args[1] == 'f' or args[1] == 'fonts' then
		print(BLOCKSEP)
		efiprint(CLR.HEAD('All Installed Fonts:'))
		local fonts = listfonts(dfonts, false)
		for _, v in ipairs(fonts) do
			print(v)
		end
		print(BLOCKSEP)
	-- Addon toggles
	elseif targetnames[args[1]] then
		toggle_target(targetnames[args[1]])
	-- Status and help
	elseif args[1] == nil or args[1] == 's' or args[1] == 'status' or args[1] == 'info' then
		print(BLOCKSEP)
		efiprint(CLR.HEAD('Status & Info:'))
		print_multi(statusbody())
		print(shorthelpbody())
		print(BLOCKSEP)
	elseif args[1] == 'h' or args[1] == 'help' then
		print(BLOCKSEP)
		efiprint(CLR.HEAD('Command Help:'))
		print_multi(fullhelpbody())
		print(BLOCKSEP)
	elseif args[1] == 'dm' or args[1] == 'debug' then
		db.debugmode = not db.debugmode
		efiprint(format('Debug mode: %s', db.debugmode and 'On' or 'Off'))
	else
		print(BLOCKSEP)
		efiprint(
			CLR.BAD(
				format('Your input %q was not a valid input.', CLR.KEY(table.concat(args, '\32')))
			)
		)
		print(shorthelpbody())
		print(BLOCKSEP)
	end
end
