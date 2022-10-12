local addonName, _ = ...

--[ Config Begin ]=============================================================

--[[ 
	You _have_ to change the font path to the path of your desired font in your
	WoW setup (unless you happen to have the example font at exactly the same
	path on your machine). 
	The game client (Retail) can only access fonts inside `/World of
	Warcraft/_retail_/` which acts as root folder for the path. So, for example,
	`Fonts/MORPHEUS.ttf` would also be a valid path, but _not_ anything outside
	like `/System/Library/Fonts/Courier New.ttf`.
]]

-- Path to the font file
local font = [[Interface/AddOns/SharedMedia_MyMedia/font/PT/PT_Mono/PTM55F.ttf]]

-- Size in points
local size = 12

-- Either an empty string for no flags, or any comma-delimited combination of 'OUTLINE', 'THICKOUTLINE' and 'MONOCHROME'
local flags = '' 

-- https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont

--[ Config End ]================================================================


-- The 'addon names' in the comments _must_ be in OptionalDeps in the toc
local targets = { 
	M6EditBox, -- 'M6'; edit box, title and group we leave alone
	ABE_MacroInput, -- 'OPie'; the edit box for custom macro buttons
	MacroFrameText, -- 'Blizzard_MacroUI'; also affects 'ImprovedMacroFrame' (toc!)
	WowLuaFrameOutput, -- 'WowLua'; output box
	-- MacroManager does not work bc the frame is not visible. It _is_ visible though if run in-game, from WoWLua or macro. TODO: find out why.
-- 	MacroManagerMultiLineEditBox1Edit, -- 'MacroManager'; new addon 2022-10
}

-- 'pairs' is crucial here. 'ipairs' exits at a gap in the list (bc of a not loaded addon).
for _, t in pairs(targets) do
	t:SetFont(font, size, flags)
end

-- For the WoWLua edit box we take the font size as actually set in the WowLua GUI
-- This is not a frame, so we want to make sure it exists
if WowLuaMonoFont then 
	WowLuaMonoFont:SetFont(font, WowLua_DB.fontSize, flags)
end

-- local f = CreateFrame('Frame')
-- f:RegisterEvent('PLAYER_LOGIN')
-- f:SetScript('OnEvent', function()
-- 	for _, t in pairs(targets) do
-- 		t:SetFont(font, size, flags)
-- 	end
-- 	if WowLuaMonoFont then
-- 		WowLuaMonoFont:SetFont(font, WowLua_DB.fontSize, flags)
-- 	end
-- MacroManagerMultiLineEditBox1Edit:SetFont(font, size, flags)
-- end)

--[[ Notes for the User ========================================================

	You can add additional addons by adding their edit box frame to the
	`targets` list. To find the correct frame name, you can use `/fstack` in the
	game UI. This will not work for every addon though.

============================================================================]]--



--[[ License ===================================================================

	Copyright © 2022 Thomas Floeren

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
