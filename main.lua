-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright (c) 2022-2025 Thomas Floeren

local MYNAME, _ = ...

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local FLAGS = '' -- For our purpose, we do not want any outlining.

local CLR_EBFI = 'ffD783FF'
local CLR_WARN = WARNING_FONT_COLOR
local MSG_PREFIX = WrapTextInColorCode('EditBox Font Improver:', CLR_EBFI)
local FONTPATH_WARNING = RED_FONT_COLOR:WrapTextInColorCode('Font path is not valid!')
	.. " Make sure there is a valid font path set in the addon's SavedVariables file. Check out the addon's readme/description for more information."

-- We opt to not raise an error if a font cannot be set, and just print a one-time warning.
-- The user will notice that the font is not set when they open the relevant addon.
local function warnprint(msg)
	print(format('%s %s %s', MSG_PREFIX, CLR_WARN:WrapTextInColorCode('WARNING:'), msg))
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

-- 1: Oct 20, 2025: significant; removed/added/renamed keys --> reset all
local DB_VERSION_CURRENT = 1

-- Nilified all individual fontsizes, as no longer planned
local defaults = {
	font = 1,
	fonts = {
		"Interface/AddOns/EditBox-Font-Improver/font/pt-mono_regular.ttf",
		"Interface/AddOns/EditBox-Font-Improver/font/FiraMono-Regular.ttf",
		"Interface/AddOns/EditBox-Font-Improver/font/FiraMono-Medium.ttf",
		"Interface/AddOns/EditBox-Font-Improver/font/FiraCode-Retina.ttf",
		"Interface/AddOns/EditBox-Font-Improver/font/FiraMono-Regular.otf",
		"Interface/AddOns/EditBox-Font-Improver/font/FiraMono-Medium.otf",
	},
	userfonts = {
		"Interface/AddOns/EditBox-Font-Improver/font/pt-mono_regular.ttf",
		"Interface/AddOns/WeakAuras/Media/Fonts/FiraMono-Medium.ttf",
	},
	default_fontsize = 12,
	macroeditors = {
		enable = true,
		ownsize = nil, -- Always EFI default size, since these addons have no own size setting
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
}

_G.EBFI_DB = _G.EBFI_DB or {}

if not _G.EBFI_DB.db_version or _G.EBFI_DB.db_version < DB_VERSION_CURRENT then
	_G.EBFI_DB = {}
end

merge_defaults(defaults, _G.EBFI_DB)
local db = _G.EBFI_DB

--[[===========================================================================
	Setup
===========================================================================]]--

local efi_font = db.fonts[db.font]

local function debugprint(...)
	if db.debugmode then
		local a, b = strsplit('.', GetTimePreciseSec())
		print(
			format('[%s.%s] %sEBFI >>> Debug >>>\124r', a:sub(-3), b:sub(1, 3), '\124cffEE82EE'),
			...
		)
	end
end

local function create_fontobj()
	local efi_fontobject = CreateFont 'efi_fontobject'
	efi_fontobject:SetFont(efi_font, db.default_fontsize, FLAGS)
	if efi_fontobject:GetFont() == efi_font then return true end
	warnprint(FONTPATH_WARNING)
end

local addons = {
	macroeditors = {
		has_sizecfg = false,
		loaded = true,
		setup_done = false,
	},
	wowlua = {
		has_sizecfg = true,
		loaded = false,
		setup_done = false,
	},
	scriptlibrary = {
		has_sizecfg = true,
		loaded = false,
		setup_done = false,
	},
	bugsack = {
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
		local size = db.wowlua.ownsize and WowLua_DB.fontSize or db.default_fontsize
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
				tonumber(currentsize) or db.default_fontsize,
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
			or db.default_fontsize
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
		C_Timer.After(25, function() warnprint(FONTPATH_WARNING) end)
		return
	end
	addons.wowlua.loaded = C_AddOns_IsAddOnLoaded 'WowLua'
	addons.scriptlibrary.loaded = C_AddOns_IsAddOnLoaded 'ScriptLibrary'
	addons.bugsack.loaded = C_AddOns_IsAddOnLoaded 'BugSack'
	initial_setup()
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

local function fontname(path)
	local pattern = db.debugmode and '[^/\\]+$' or '([^/\\]+)%.[tof]+'
	return path:match(pattern) or '<NO MATCH>'
end

SLASH_EditBoxFontImprover1 = '/efi'
SLASH_EditBoxFontImprover2 = '/ebfi'
SLASH_EditBoxFontImprover3 = '/editboxfontimprover'
SlashCmdList.EditBoxFontImprover = function(msg)
	local args = {}
	for arg in msg:gmatch('[^ ]+') do
		tinsert(args, arg)
	end
	if tonumber(args[1]) then
		local size = max(min(tonumber(args[1]), 28), 6)
		db.default_fontsize = size
		efiprint(
			format(
				'Font size now set to %s. This does not affect the addons that are set to use their own font size setting (by default WowLua, Scriptlibrary, and BugSack).',
				db.default_fontsize
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
	elseif args[1] == 'dm' or args[1] == 'debug' then
		db.debugmode = not db.debugmode
		efiprint('Debug mode: ' .. (db.debugmode and 'On' or 'Off'))
	elseif args[1] == 'font' or args[1] == 'f' and tonumber(args[2]) then
		local selection = tonumber(args[2])
		if db.font == selection then
			efiprint('The font you have selected (#' .. selection .. ') is already loaded.')
		elseif not db.fonts[selection] then
			efiprint(
				format(
					'The font you have selected (#%s) does not exist. Your font list contains %s fonts.',
					selection,
					#db.fonts
				)
			)
		else
			efi_font = db.fonts[selection]
			if refresh_setup() then
				db.font = selection
				efiprint(
					format(
						'Your new font is "%s" (#%s of %s).',
						fontname(db.fonts[db.font]),
						db.font,
						#db.fonts
					)
				)
			else
				efiprint(
					format(
						'The path of your selected font (#%s) is not valid!. Your previous font will be used instead.',
						selection
					)
				)
			end
		end
	else
		efiprint 'Supported arguments: Font Size, for example "14" (default is 12). \n"unisize" to force all addons to use EFI\'s font size; "ownsize" to not override the addons\'s own size setting, if it has one (default). \nSelect another font from your list with "f <number>".'
	end
end
