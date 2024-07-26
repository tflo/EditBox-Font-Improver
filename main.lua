local addonName, a = ...


--[[===========================================================================
	User Config
===========================================================================]]--

--[[
	You _have_ to change the font path to the path of your desired font in your
	WoW setup (unless you happen to have the example font at exactly the same
	path on your machine).
	The game client (Retail) can only access fonts inside `/World of
	Warcraft/_retail_/` which acts as root folder for the path. So, for example,
	`Fonts/MORPHEUS.ttf` would also be a valid path, but _not_ anything outside
	WoW like `/System/Library/Fonts/Courier New.ttf`.
]]

-- THIS IS THE MAIN THING: Replace the example path with the path to your desired font file!
local font = [[Interface/AddOns/SharedMedia_MyMedia/font/PT/PT_Mono/PTM55F.ttf]]

-- Size in points: Set the desired font size here.
local size = 12

-- Font flags
-- For our purpose, you most likely do not want any outlining. So, leave the empty string here.
-- Otherwise, see https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont
local flags = ''

-- WoWLua alraedy uses a nice monospaced font out of the box (Vera Mono).
-- So, if you prefer the original font in WoWLua, just set the following variable to `false`:
local include_wowlua = true

-- EXTRA: Interline spacing for the WoWLua edit box:
-- WoWLua uses an insanely tight line spacing of 0 (zero). This setting
-- increases the line spacing. Recommended: at least 1, better something between
-- 2 and 5. To use WoWLua's default spacing, set the value to `nil` (without any
-- quotes) or remove/comment the line.
-- Note: This setting is independent of the above `include_wowlua`.
local spacing_wowlua = 3


-- Hint: Before updating the addon, make sure to copy your config, so that you
-- can paste it into the new version!


--[[===========================================================================
	Create Font Object
===========================================================================]]--

-- Currently we do not need the global font object
local ebfi_font = CreateFont('ebfi_font_global')
ebfi_font:SetFont(font, size, flags)

--[[===========================================================================
	Straightforward Frames
===========================================================================]]--

-- Easy stuff, where we can simply set the frame font.
-- The frames are created at load time, so no issues.
local function setup_misc()
	-- The 'addon name strings' as in the comments _must_ be in OptionalDeps in the toc.
	local targets = {
		M6EditBox, -- 'M6'; edit box, title and group we leave alone.
		ABE_MacroInput, -- 'OPie'; the edit box for custom macro buttons.
		MacroFrameText, -- 'Blizzard_MacroUI'; also affects 'ImprovedMacroFrame'.
	}
	-- We need `pairs` here, bc a not loaded addon will cause a gap (nil value) in the list.
	for _, t in pairs(targets) do
		t:SetFontObject(ebfi_font)
	end
end

-- NOTE for the user:
-- You can add more addons by adding their edit box frame to the `targets` list.
-- To find the correct frame, use `/fstack` in the game UI. This will only work
-- if the frame is created at addon load time, and not for every addon though.


--[[===========================================================================
	WoWLua
===========================================================================]]--

-- We have to manipulate the font object, otherwise we get reset when the user changes font size in WoWLua.
-- We use the font size as actually set in the WowLua GUI.
-- Needed OptionalDeps in toc: 'WowLua'
local function setup_wowlua()
	if not WowLuaMonoFontSpaced then return end
	if include_wowlua then
		WowLuaMonoFont:SetFont(font, WowLua_DB.fontSize, flags)
		WowLuaMonoFontSpaced:SetFont(font, WowLua_DB.fontSize, flags)
		WowLua:UpdateFontSize(WowLua_DB.fontSize)
	end

	local spacing = tonumber(spacing_wowlua)
	if spacing then
		WowLuaMonoFontSpaced:SetSpacing(spacing)
	end
end


--[[===========================================================================
	BugSack (experimental!)
===========================================================================]]--

-- The main frame is not created before first open, so we have to hook.
-- Needed OptionalDeps in toc: 'BugSack'
local function setup_bugsack()
	if not BugSack then return end
	local font_set = false
	hooksecurefunc(BugSack, 'OpenSack', function()
		if not font_set then -- No need to run it more than once
			BugSackScrollText:SetFontObject(ebfi_font)
			font_set = true
-- 			print 'EBFI Debug: BugSack hook run!' -- Debug
		end
	end)
end


--[[===========================================================================
	Run the Stuff
===========================================================================]]--

setup_misc()
setup_wowlua()
setup_bugsack()

-- NOTE: We could also run this in an event script at PLAYER_LOGIN, but the OptionalDeps system seems to work fine so far.



--[[ License ===================================================================

	Copyright © 2022-2024 Thomas Floeren

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
