local me, a = ...

local db = {}
local FLAGS = "" -- For our purpose, we do not want any outlining. Nope.



local debug = false

local function debugprint(...)
	if debug then
		local a, b = strsplit(".", GetTimePreciseSec())
		print(format("[%s.%s] %sEBFI >>> Debug >>>\124r", a:sub(-3), b:sub(1, 3), "\124cffEE82EE"), ...)
	end
end

local COLOR_EBFI = "|cFFD783FF"
local COLOR_WARN = "|cnWARNING_FONT_COLOR:"
local MSG_PRE = COLOR_EBFI .. "EBFI|r:"
local MSG_PREFIX = COLOR_EBFI .. "EditBox Font Improver|r:"

local function warnprint(...)
	print(format("%s %sWARNING:", MSG_PREFIX, COLOR_WARN), ...)
end

--[[===========================================================================
	Defaults for the DB
===========================================================================]]--

local default_fontpath = [[Interface/AddOns/EditBox-Font-Improver/fonts/pt-mono_regular.ttf]]
local default_size = 12

local defaults = {
	macroeditors = { enable = true, size = default_size },
	wowlua = { enable = true, size = default_size },
	scriptlibrary = { enable = true, size = default_size },
	bugsack = { enable = true, size = default_size },
}

local function make_subtables(src, dst)
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = dst[k] or {}
			make_subtables(src[k], dst[k])
		end
	end
end


local readme_for_SV = [[
Hi there! Probably you have opened this SavedVariables file to directly edit the font path. Good idea! This help text is
for you: ——— The default path ['font'] points to the PT Mono font, inside the 'fonts' folder of the addon itself. ———
The addon can load any font that is located in the World of 'Warcraft/_retail_/Interface/AddOns' directory, where
'Interface' serves as root folder for the path. ——— So, for example, to use a font that you already have installed for
SharedMedia: 'Interface/AddOns/SharedMedia_MyMedia/font/MyFont.ttf'. But you can also just toss the font into the AddOns
folder and set the path like 'Interface/AddOns/MyFont.ttf'.
]]

readme_for_SV = readme_for_SV:gsub("\n", " ")

local size = default_size


--[[===========================================================================
	Create Font Object
===========================================================================]]--

local function create_fontobj()
	local ebfi_font = CreateFont "ebfi_font"
	ebfi_font:SetFont(db.font, size, FLAGS)
end

local function test_font()
	if ebfi_font:GetFont() ~= db.font then
		warnprint "Font path is not valid! You have to set a valid font path in the addon's SavedVariables file. Check out the addon's readme/description for more information."
	end
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
	debugprint "`setup_misc` run."
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
	if not WowLuaMonoFontSpaced then return end
	WowLuaMonoFont:SetFont(font, WowLua_DB.fontSize, FLAGS)
	WowLuaMonoFontSpaced:SetFont(font, WowLua_DB.fontSize, FLAGS)
	WowLua:UpdateFontSize(WowLua_DB.fontSize)

-- Disabled for the moment, since this messes up the cursor position
-- 	local spacing = tonumber(spacing_wowlua)
-- 	if spacing then
-- 		WowLuaMonoFontSpaced:SetSpacing(spacing)
-- 	end
end


--[[===========================================================================
	BugSack
===========================================================================]]--

local function setup_bugsack()
	if BugSackScrollText then
		BugSackScrollText:SetFontObject(ebfi_font)
	else
		warnprint "BugSack target frame not found."
	end
end

-- The main frame is not created before first open, so we have to hook.
local function hook_bugsack()
	if not BugSack then return end
	local done = false
	hooksecurefunc(BugSack, "OpenSack", function()
		if not done then
			setup_bugsack()
			done = true
			debugprint "BugSack hook called."
		end
	end)
end


--[[===========================================================================
	ScriptLibrary
===========================================================================]]--

local function setup_scriptlibrary()
	if RuntimeEditorMainWindowCodeEditorCodeEditorEditBox then
		RuntimeEditorMainWindowCodeEditorCodeEditorEditBox:SetFont(db.font, size, FLAGS)
	else
		warnprint "ScriptLibrary target frame not found."
	end
end

-- The main frame is not created before first open, so we have to hook.
local function hook_scriptlibrary()
	if not SlashCmdList.SCRIPTLIBRARY then return end
	local done = false
	hooksecurefunc(SlashCmdList, "SCRIPTLIBRARY", function()
		if not done then
			setup_scriptlibrary()
			done = true
			debugprint "ScriptLibrary hook called."
		end
	end)
end

-- NOTE:
-- I haven't found a way to grab the font size that is set in ScriptLibrary.
-- ScriptLibrary wipes its global DB after load, and practically all functions and variables are private.

--[[===========================================================================
	Run the Stuff
===========================================================================]]--

local ef = CreateFrame "Frame"

local function on_event(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == me then
			self:UnregisterEvent "ADDON_LOADED"
			EBFI_DB = setmetatable(EBFI_DB or {}, { __index = defaults })
			db = EBFI_DB
			make_subtables(defaults, db)
			db["Read Me!"] = readme_for_SV -- Populate SV file for user guidance.
			db.font = db.font or default_fontpath -- Populate SV file with example path.
			create_fontobj()
		end
	elseif event == "VARIABLES_LOADED" then
		if db.wowlua.enable then setup_wowlua() end
		if db.bugsack.enable then hook_bugsack() end
		if db.scriptlibrary.enable then hook_scriptlibrary() end
		if db.macroeditors.enable then setup_misc() end
	elseif event == "PLAYER_LOGIN" then
		C_Timer.After(20, test_font)
	end
end

ef:RegisterEvent "ADDON_LOADED"
ef:RegisterEvent "PLAYER_LOGIN"
ef:RegisterEvent "VARIABLES_LOADED"
ef:SetScript("OnEvent", on_event)

-- SLASH_EDITBOXFONTIMPROVER1 = "/editboxfontimprover"
-- SLASH_EDITBOXFONTIMPROVER2 = "/ebfi"
-- SlashCmdList["EDITBOXFONTIMPROVER"] = function(msg)
-- 	if msg == "runsl" then
-- 		setup_scriptlibrary()
-- 	elseif msg == "runcmd" then
-- 	end
-- end


--[[ License ===================================================================

	Copyright © 2022-2025 Thomas Floeren

	This file is part of EditBox Font Improver.

	EditBox Font Improver is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	EditBox Font Improver is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
	or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.

	You should have received a copy of the GNU General Public License along with
	EditBox Font Improver. If not, see <https://www.gnu.org/licenses/>.

============================================================================]]--
