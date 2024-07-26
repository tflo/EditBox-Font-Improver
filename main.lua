local addonName, a = ...



--[[===========================================================================
	CONFIG
===========================================================================]]--

--[[
	You _have_ to change the font path to the path of your desired font in your
	WoW setup (unless you happen to have the example font at exactly the same
	path on your machine).
	The game client (Retail) can only access fonts inside `/World of
	Warcraft/_retail_/` which acts as root folder for the path. So, for example,
	`Fonts/MORPHEUS.ttf` would also be a valid path, but _not_ anything outside
	like `/System/Library/Fonts/Courier New.ttf`.
]]

-- THIS IS THE MAIN THING: Replace the example path with the path to your desired font file!
local font = [[Interface/AddOns/SharedMedia_MyMedia/font/PT/PT_Mono/PTM55F.ttf]]

-- Size in points
local size = 12

-- Font flags
-- For our purpose, you most likely do not want any outlining. So, leave the empty string here.
-- Otherwise, see https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont
local flags = ''

-- WoWLua alraedy uses a nice monospaced font out of the box (Vera Mono).
-- So, if you prefer the original font in WoWLua, just set the following variable to `false`:
local include_WoWLua = true

-- EXTRA: Interline spacing for the WoWLua edit box:
-- WoWLua uses an insanely tight line spacing of 0 (zero). This setting increases the line
-- spacing. Recommended: at least 1, better something between 2 and 5.
-- To use WoWLua's default, set it to `nil` (without any quotes) or remove/comment the line.
-- Note: This setting is independent of the above `include_WoWLua`.
local spacing_WoWLua = 3


-- Hint: Before updating the addon, make sure to copy your config, so that you
-- can paste it into the new version!

--[[===========================================================================
	End CONFIG
===========================================================================]]--



-- The 'addon name strings' in the comments _must_ be in OptionalDeps in the toc
local targets = {
	M6EditBox, -- 'M6'; edit box, title and group we leave alone
	ABE_MacroInput, -- 'OPie'; the edit box for custom macro buttons
	MacroFrameText, -- 'Blizzard_MacroUI'; also affects 'ImprovedMacroFrame' (toc!)
-- 	WowLuaFrameOutput, -- 'WowLua'; output box. Actually not needed if we replace the font like we do below.
}

-- We need `pairs` here, bc a not loaded addon will cause a gap (nil value) in the list.
for _, t in pairs(targets) do
	t:SetFont(font, size, flags)
end

-- WOWLUA
-- We take the font size as actually set in the WowLua GUI.
if WowLuaMonoFontSpaced then
	if include_WoWLua then
		WowLuaMonoFont:SetFont(font, WowLua_DB.fontSize, flags)
		WowLuaMonoFontSpaced:SetFont(font, WowLua_DB.fontSize, flags)
		WowLua:UpdateFontSize(WowLua_DB.fontSize)
	end

	local spacing = tonumber(spacing_WoWLua)
	if spacing then
		WowLuaMonoFontSpaced:SetSpacing(spacing)
	end
end

--[[ Notes for the User ========================================================

	You can add more addons by adding their edit box frame to the
	`targets` list. To find the correct frame name, you can use `/fstack` in the
	game UI. This will not work for every addon though.

============================================================================]]--
--[[===========================================================================
	BugSack (experimental!)
===========================================================================]]--

-- The main frame is not created before first open, so we have to hook.
-- Needed OptionalDeps in toc: 'BugSack'
local function setup_bugsack()
	if not BugSack then return end
	local font_set
	hooksecurefunc(BugSack, 'OpenSack', function()
		if not font_set then -- No need to run it more than once
			BugSackScrollText:SetFont(font, size, flags)
			font_set = true
-- 			print 'EBFI Debug: BugSack hook run!' -- Debug
		end
	end)
end




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
