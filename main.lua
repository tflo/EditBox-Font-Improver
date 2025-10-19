-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright (c) 2022-2025 Thomas Floeren

local MYNAME, _ = ...

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local FLAGS = "" -- For our purpose, we do not want any outlining.
local debug = true

local function debugprint(...)
	if debug then
		local a, b = strsplit(".", GetTimePreciseSec())
		print(format("[%s.%s] %sEBFI >>> Debug >>>\124r", a:sub(-3), b:sub(1, 3), "\124cffEE82EE"), ...)
	end
end

local CLR_EBFI = "ffD783FF"
local CLR_WARN = WARNING_FONT_COLOR
local MSG_PREFIX = WrapTextInColorCode("EditBox Font Improver:", CLR_EBFI)

-- We opt to not raise an error if a font cannot be set, and just print a one-time warning.
-- The user will notice that the font is not set when they open the relevant addon.
local function warnprint(msg)
	print(format("%s %s %s", MSG_PREFIX, CLR_WARN:WrapTextInColorCode("WARNING:"), msg))
end

--[[===========================================================================
	Defaults
===========================================================================]]--

local defaults = {
	font = [[Interface/AddOns/EditBox-Font-Improver/font/pt-mono_regular.ttf]],
	default_fontsize = 12,
	-- Individual sizes are not yet enabled.
	macroeditors = {
		enable = true,
		fontsize = nil,
	},
	wowlua = {
		enable = true,
		fontsize = nil,
	},
	scriptlibrary = {
		enable = true,
		fontsize = nil,
	},
	bugsack = {
		enable = true,
		fontsize = nil,
	},
	["Read Me!"] = "Hi there! Probably you have opened this SavedVariables file to directly edit the font path. Good idea! This help text is for you: ——— The default path ['font'] points to the PT Mono font, inside the 'fonts' folder of the addon itself. ——— The addon can load any font that is located in the World of 'Warcraft/_retail_/Interface/AddOns' directory, where 'Interface' serves as root folder for the path. ——— So, for example, to use a font that you already have installed for SharedMedia: 'Interface/AddOns/SharedMedia_MyMedia/font/MyFont.ttf'. But you can also just toss the font into the AddOns folder and set the path like 'Interface/AddOns/MyFont.ttf'."
}

local function merge_defaults(src, dst)
	for k, v in pairs(src) do
		local src_type = type(v)
		if src_type == 'table' then
			if type(dst[k]) ~= 'table' then
				dst[k] = {}
			end
			merge_defaults(v, dst[k])
		elseif type(dst[k]) ~= src_type then
			dst[k] = v
		end
	end
end

_G.EBFI_DB = _G.EBFI_DB or {}
merge_defaults(defaults, _G.EBFI_DB)
local db = _G.EBFI_DB


--[[===========================================================================
	Create Font Object
===========================================================================]]--

local function create_fontobj()
	local ebfi_font = CreateFont "ebfi_font"
	ebfi_font:SetFont(db.font, db.default_fontsize, FLAGS)
end

create_fontobj()

local function validate_fontpath()
	if ebfi_font:GetFont() == db.font then return true end
	warnprint(
		RED_FONT_COLOR:WrapTextInColorCode("Font path is not valid!")
			.. " Make sure there is a valid font path set in the addon's SavedVariables file. Check out the addon's readme/description for more information."
	)
end


--[[===========================================================================
	Straightforward Frames (macro editors)
===========================================================================]]--

-- Easy stuff, where we can simply apply our font object.
-- The frames are created at load time, so no issues, if the addons are
-- OptionalDeps. A missing addon doesn't pose a problem, as it just creates a
-- nil value in the table, which is ignored when we iterate.
local function setup_misc()
	local targets = {
		MacroFrameText, -- Blizzard_MacroUI; also affects ImprovedMacroFrame.
-- 		M6EditBox, -- M6; it seems this frame was renamed; see next entry.
		ABE_MacroInputEB, -- M6 and OPie; macro edit box.
	}
	-- We can't use `ipairs' here because a missing addon (nil) would stop iteration.
	for _, t in pairs(targets) do
		t:SetFontObject(ebfi_font)
	end
	debugprint "Setup for misc macro editors run."
end

-- NOTE for the user:
-- You can add more addons by adding their edit box frame to the `targets` list.
-- To find the correct frame, use `/fstack` in the game UI. This will only work
-- if the frame is created at addon load time, and not for every addon though.

-- Check out this:
-- https://github.com/Stanzilla/WoWUIBugs/issues/581

--[[===========================================================================
	WoWLua
===========================================================================]]--

-- We directly manipulate WoWLua's font object, otherwise we get reset when the
-- user changes font size in WoWLua.
-- We use the font size as actually set in the WowLua GUI.
local function setup_wowlua()
	if WowLuaMonoFontSpaced then
		WowLuaMonoFont:SetFont(db.font, WowLua_DB.fontSize, FLAGS)
		WowLuaMonoFontSpaced:SetFont(db.font, WowLua_DB.fontSize, FLAGS)
		WowLua:UpdateFontSize(WowLua_DB.fontSize)
	else
		warnprint "WowLua's `WowLuaMonoFontSpaced` not found. Could not set font."
	end
	debugprint "WowLua setup run."

	-- Spacing disabled for the moment, since this messes up the cursor position
	-- local spacing = tonumber(spacing_wowlua)
	-- if spacing then
	-- WowLuaMonoFontSpaced:SetSpacing(spacing)
	-- end
end


--[[===========================================================================
	BugSack
===========================================================================]]--

local function setup_bugsack()
	if BugSackScrollText then
		BugSackScrollText:SetFontObject(ebfi_font)
	else
		warnprint "BugSack target frame not found. Could not set font."
	end
	debugprint "BugSack setup run."
end

-- The main frame is not created before first open, so we have to hook.
local function hook_bugsack()
	if not BugSack.OpenSack then
		warnprint "`BugSack.OpenSack` not found (needed for hook). Could not set font."
		return
	end
	local done = false
	hooksecurefunc(BugSack, "OpenSack", function()
		if not done then
			done = true
			setup_bugsack()
		end
	end)
end


--[[===========================================================================
	ScriptLibrary
===========================================================================]]--

local function setup_scriptlibrary()
	if RuntimeEditorMainWindowCodeEditorCodeEditorEditBox then
		RuntimeEditorMainWindowCodeEditorCodeEditorEditBox:SetFont(
			db.font,
			db.default_fontsize,
			FLAGS
		)
	else
		warnprint "ScriptLibrary target frame not found. Could not set font."
	end
	debugprint "ScriptLibrary setup run."
end

-- The main frame is not created before first open, so we have to hook.
-- Couldn't find any accessible 'open' function, so we use the slash command.
local function hook_scriptlibrary()
	if not SlashCmdList.SCRIPTLIBRARY then
		warnprint "`SlashCmdList.SCRIPTLIBRARY` not found (needed for hook). Could not set font."
		return
	end
	local done = false
	hooksecurefunc(SlashCmdList, "SCRIPTLIBRARY", function()
		if not done then
			done = true
			setup_scriptlibrary()
		end
	end)
end

-- NOTE:
-- I haven't found a way to grab the font size that is set in ScriptLibrary.
-- ScriptLibrary wipes its global DB after load, and practically all functions and variables are private.

--[[===========================================================================
	Run the Stuff
===========================================================================]]--

local ef = CreateFrame("Frame", MYNAME .. "_eventframe")

local function PLAYER_ENTERING_WORLD(is_login, is_reload)
	if is_login or is_reload then
		C_Timer.After(15, validate_fontpath)
		ef:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

local function PLAYER_LOGIN()
	if db.wowlua.enable and C_AddOns_IsAddOnLoaded "WowLua" then setup_wowlua() end
	if db.bugsack.enable and C_AddOns_IsAddOnLoaded "BugSack" then hook_bugsack() end
	if db.scriptlibrary.enable and C_AddOns_IsAddOnLoaded "ScriptLibrary" then
		hook_scriptlibrary()
	end
	if db.macroeditors.enable then setup_misc() end
end

local event_handlers = {
	["PLAYER_ENTERING_WORLD"] = PLAYER_ENTERING_WORLD,
	["PLAYER_LOGIN"] = PLAYER_LOGIN,
-- 	["VARIABLES_LOADED"] = VARIABLES_LOADED,
}

for event in pairs(event_handlers) do
	ef:RegisterEvent(event)
end

ef:SetScript("OnEvent", function(_, event, ...)
	event_handlers[event](...) -- We do not want a nil check here
end)

---

-- SLASH_EDITBOXFONTIMPROVER1 = "/editboxfontimprover"
-- SLASH_EDITBOXFONTIMPROVER2 = "/ebfi"
-- SlashCmdList["EDITBOXFONTIMPROVER"] = function(msg)
-- 	if msg == "runsl" then
-- 		setup_scriptlibrary()
-- 	elseif msg == "runcmd" then
-- 	end
-- end
