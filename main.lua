-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright (c) 2022-2025 Thomas Floeren

local MYNAME, _ = ...
local user_is_author = false

local WTC = WrapTextInColorCode

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
-- We opt to not raise an error if a font cannot be set, and just print a one-time warning.
-- The user will notice that the font is not set when they open the relevant addon.
local function warnprint(msg)
	print(format('%s %s %s', MSG_PREFIX, CLR.WARN('WARNING:'), msg))
end

local function efiprint(msg) print(format('%s %s', MSG_PREFIX, msg)) end

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
	font = 'Interface/AddOns/EditBox-Font-Improver/font/pt-mono_regular.ttf',
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

local dfonts = {
	'pt-mono_regular',
	'FiraMono-Regular',
	'FiraMono-Medium',
	'Hack-Regular',
	'IBMPlexMono-Light',
	'IBMPlexMono-Regular',
	'IBMPlexMono-Text',
	'IBMPlexMono-Medium',
	'IBMPlexMono-SemiBold',
}

local base_path, extension = 'Interface/AddOns/EditBox-Font-Improver/font/', '.ttf'

for i, v in ipairs(dfonts) do
	dfonts[i] = base_path .. v .. extension
end

-- not yet implemented, TODO
local ufonts = db.userfonts

local efi_font = db.font

local function debugprint(...)
	if db.debugmode then
		local a, b = strsplit('.', GetTimePreciseSec())
		print(
			format('[%s.%s] %sEFI >>> Debug >>>\124r', a:sub(-3), b:sub(1, 3), '\124cffEE82EE'),
			...
		)
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
		has_sizecfg = false,
		loaded = true,
		setup_done = false,
	},
	wowlua = {
		name = 'WowLua',
		has_sizecfg = true,
		loaded = false,
		setup_done = false,
	},
	scriptlibrary = {
		name = 'ScriptLibrary',
		has_sizecfg = true,
		loaded = false,
		setup_done = false,
	},
	bugsack = {
		name = 'BugSack',
		has_sizecfg = true,
		loaded = false,
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
-- Small: GameFontHighlightSmall: 10
-- Medium: GameFontHighlight: 12
-- Large: GameFontHighlightMedium: 14
-- X-Large: GameFontHighlightLarge: 16


--[[===========================================================================
	Straightforward Frames (macro editors)
===========================================================================]]--

-- https://www.townlong-yak.com/addons/m6
-- https://www.townlong-yak.com/addons/opie

-- Easy stuff, where we can simply apply our font object.
-- The frames are created at load time, so no issues, if the addons are
-- OptionalDeps. A missing addon doesn't pose a problem, as it just creates a
-- nil value in the table, which is ignored when we iterate.
function addons.macroeditors.setup()
	local editboxes = {
		MacroFrameText, -- Blizzard_MacroUI; also affects ImprovedMacroFrame.
		ABE_MacroInputEB, -- M6 and OPie macro edit box.
	}
	-- Don't use `ipairs' because the entries may be nil (addon not loaded).
	for _, box in pairs(editboxes) do
		box:SetFontObject(efi_fontobject)
	end
	addons.macroeditors.setup_done = true
	debugprint 'Setup for misc macro editors run.'
end

-- NOTE for the user:
-- You can add more addons by adding their edit box frame to the `editboxes` list.
-- To find the correct frame, use `/fstack` in the game UI. This will only work
-- if the frame is created at addon load time, and not for every addon though.

-- Check out this:
-- https://github.com/Stanzilla/WoWUIBugs/issues/581


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
	debugprint 'WowLua setup run.'

	-- Spacing disabled for the moment, since this messes up the cursor position
	-- local spacing = tonumber(spacing_wowlua)
	-- if spacing then
	-- WowLuaMonoFontSpaced:SetSpacing(spacing)
	-- end
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
	else
		warnprint 'BugSack target frame not found. Could not set font.'
	end
	debugprint 'BugSack setup run.'
end

-- The main frame is not created before first open, so we have to hook.
function addons.bugsack.hook()
	if not BugSack.OpenSack then
		warnprint '`BugSack.OpenSack` not found (needed for hook). Could not set font.'
		return
	end
	local done = false
	hooksecurefunc(BugSack, 'OpenSack', function()
		if not done then
			done = true
			addons.bugsack.setup()
		end
	end)
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
	else
		warnprint 'ScriptLibrary target frame not found. Could not set font.'
	end
	debugprint 'ScriptLibrary setup run.'
end

-- The main frame is not created before first open, so we have to hook.
-- Couldn't find any accessible 'open' function, so we use the slash command.
function addons.scriptlibrary.hook()
	if not SlashCmdList.SCRIPTLIBRARY then
		warnprint '`SlashCmdList.SCRIPTLIBRARY` not found (needed for hook). Could not set font.'
		return
	end
	local done = false
	hooksecurefunc(SlashCmdList, 'SCRIPTLIBRARY', function()
		if not done then
			done = true
			addons.scriptlibrary.setup()
		end
	end)
end

-- NOTE:
-- I haven't found a way to grab the font size that is set in ScriptLibrary.
-- ScriptLibrary wipes its global DB after load, and practically all functions and variables are private.


--[[===========================================================================
	Run the Stuff
===========================================================================]]--

local ef = CreateFrame('Frame', MYNAME .. '_eventframe')

local function initial_setup()
	for k, v in pairs(addons) do
		if db[k].enable and v.loaded then (v.hook or v.setup)() end
	end
end

local function PLAYER_LOGIN()
	if not create_fontobj() then
		-- Print the msg once more when login chat spam is over.
		C_Timer.After(20, function() warnprint(FONTPATH_WARNING:format(efi_font)) end)
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

local function refresh_setup()
	if not create_fontobj() then return end
	for k, v in pairs(addons) do
		if db[k].enable and v.setup_done then v.setup() end
	end
	return true
end

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

local function listfonts(array, withpath, sep)
	if type(array) ~= 'table' or #array == 0 then return NOTHING_FOUND end
	sep = sep or ', '
	local t ={}
	local func = withpath and fontpath or fontname
	for _,v in ipairs(array) do
		tinsert(t, func(v)) -- , true, array
	end
	return table.concat(t, sep)
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
				format('%s %s', CLR.HEAD('Current font:'), fontname(db.font)),
				format('%s %s', CLR.HEAD('Current font size:'), CLR.KEY(db.fontsize)),
				format('%s %s', CLR.HEAD('Current font path:'), fontpath(db.font)), -- TODO: user fonts
				format(
					'%s %s; %s %s',
					CLR.HEAD('Num fonts: default:'),
					CLR.HEAD('user [NYI!]:'),
					CLR.KEY(#dfonts),
					CLR.KEY(type(ufonts) == 'table' and #ufonts or 'nil')
				), -- TODO: user fonts
				format('%s %s', CLR.HEAD('Default fonts:'), listfonts(dfonts)),
				format('%s %s', CLR.HEAD('User fonts [NYI!]:'), listfonts(ufonts)), -- TODO: user fonts
				format('%s \n   %s', CLR.HEAD('User font paths [NYI!]:'), listfontpaths(ufonts, '\n   ')), -- TODO: user fonts
				format('%s %s', CLR.HEAD('Enabled for addon/loaded:'), states),
				format('%s %s', CLR.HEAD('Ownsize/Unisize:'), sizepols),
				format('%s %s', CLR.HEAD('Debug mode:'), db.debugmode and 'On' or 'Off'),
				format('%s %s', CLR.HEAD('User is author:'), user_is_author and 'Yes' or 'No'),
			}
		or {
			format('%s %s', CLR.HEAD('Current font:'), fontname(db.font)),
			format('%s %s', CLR.HEAD('Current font size:'), CLR.KEY(db.fontsize)),
			format('%s %s', CLR.HEAD('Num available fonts:'), CLR.KEY(#dfonts)),
			format('%s %s', CLR.HEAD('Available fonts:'), listfonts(dfonts)),
			format('%s %s', CLR.HEAD('Enabled for addon/loaded:'), states),
			format('%s %s', CLR.HEAD('Ownsize/Unisize:'), sizepols),
		}
end

local function shorthelpbody()
	return format(
		'%s %q to set the font size, %q to select a font by index, %q for the complete help with all commands explained.',
		CLR.EFI('Usage examples:'),
		CLR.CMD('/efi\194\16014'),
		CLR.CMD('/efi\194\160f\194\1603'),
		CLR.CMD('/efi\194\160h')
	)
end

local function fullhelpbody()
	return {
		format('%s : Select font by index (1 to %s)', CLR.CMD('/efi f <index>'), CLR.KEY(#dfonts)),
		format('%s : Set fontsize (default: %s)', CLR.CMD('/efi <number>'), CLR.KEY(defaults.fontsize)),
		format('%s : Do not change the font size of addons that have their own size setting (default).', CLR.CMD('/efi ownsize')),
		format('%s : Apply font size to all addons, regardless of their own settings.', CLR.CMD('/efi unisize')),
		format('%s or just %s : Display status and info (index of fonts, current font, settings).', CLR.CMD('/efi s'), CLR.CMD('/efi')),
		format('%s : Display this help text.', CLR.CMD('/efi h')),
	}
end

local BLOCKSEP = CLR.EFI(strrep('+', 42))


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
	-- Multi args: F
	-- Font selection by index
	if (args[1] == 'f' or args[1] == 'font') and tonumber(args[2]) then
		local selection = floor(args[2])
		if db.font == dfonts[selection] then
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
			if refresh_setup() then
				db.font = dfonts[selection]
				efiprint(format('Your new font is %s.', CLR.FONT(fontname(db.font))))
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
		db.font = db.font:gsub('AddOns', 'AddOnsXXX')
		efiprint(format('Font path invalidated to: %s', db.font))
	elseif args[1] == 'f' and args[2] == 'reval' then -- Debug
		db.font = db.font:gsub('AddOnsXXX', 'AddOns')
		efiprint(format('Font path revalidated to: %s', db.font))
	-- Multi args: DB (debug)
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
	-- Single arg
	elseif tonumber(args[1]) then
		local size = max(min(tonumber(args[1]), 28), 6)
		db.fontsize = size
		efiprint(
			format(
				'Font size now set to %s. This does not affect the addons that are set to use their own font size setting (by default WowLua, Scriptlibrary, and BugSack).',
				db.fontsize
			)
		)
		refresh_setup()
	elseif args[1] == 'unisize' then
		for k, v in pairs(addons) do
			if v.has_sizecfg then db[k].ownsize = false end
		end
		efiprint "All addons set to use EFI's default font size."
		refresh_setup()
	elseif args[1] == 'ownsize' then
		for k, v in pairs(addons) do
			if v.has_sizecfg then db[k].ownsize = true end
		end
		efiprint 'All addons with a configurable font size will keep their own size setting.'
		refresh_setup()
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
