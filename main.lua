local addonName, a = ...


--[[===========================================================================
	User Config
===========================================================================]]--

--[[
YOU HAVE TO CHANGE THE FONT PATH TO THE PATH OF *YOUR* DESIRED FONT.
The game client (Retail) can only access fonts inside `../World of Warcraft/_retail_/`
which also acts as root folder for any path. So, for example, `Fonts/MORPHEUS.ttf`
would be a valid path, also e.g. `Interface/AddOns/SharedMedia_MyMedia/font/MyFont.ttf`
for a font you've installed for SharedMedia. But any font path outside WoW like e.g.
`/System/Library/Fonts/Courier New.ttf` will not work!
]]

-- MANDATORY: FONT PATH: Replace the example path with the path to your desired font file:
local font = [[Interface/AddOns/SharedMedia_MyMedia/font/PT/PT_Mono/PTM55F.ttf]]

-- Size in points: Set the desired font size here.
local size = 12

-- WoWLua alraedy uses a nice monospaced font out of the box (Vera Mono).
-- So, if you prefer the original font in WoWLua, just set the following variable to `false`:
local include_wowlua = true

-- EXTRA: Interline spacing for the WoWLua edit box:
-- WoWLua uses a line spacing of 0 (zero), which too tight for an editor that
-- displays many lines. This setting increases the line spacing. Recommended: At
-- least 1, better something in the range of 2 to 4. To use WoWLua's default
-- spacing, set the value to `nil` (without any quotes) or remove/comment the
-- line.
-- Note: This setting is independent of the above `include_wowlua`.
local spacing_wowlua = 3

-- [ End of User Config ] -----------------------------------------------------


-- TIP: After setting your font path and the other config values, copy the
-- Config section to a safe place. That way you can quickly reapply your values
-- when the addon is updated. (But do not blindly paste the entire saved config,
-- as variable names may have changed, or configs may have been added/removed in
-- the new version!)

-- If this addon reaches a higher download number, I will consider adding a
-- database (SavedVariables) and a way to configure it in-game. But not for now,
-- as it seems to be used only by me and a handful of others ;)


--[[===========================================================================
	Create Font Object
===========================================================================]]--

-- Currently we do not need the global font object.
local ebfi_font = CreateFont('ebfi_font_global')

-- For our purpose, we do not want any outlining.
local flags = ''

ebfi_font:SetFont(font, size, flags)


--[[===========================================================================
	Straightforward Frames
===========================================================================]]--

-- Easy stuff, where we can simply apply our font object.
-- The frames are created at load time, so no issues, if the addons are
-- OptionalDeps. A missing addon doesn't pose a problem, as it just creates a
-- nil value in the table, which is ignored when we iterate.
local function setup_misc()
	-- The addon names as noted in the comments must be declared OptionalDeps in the toc.
	local targets = {
		M6EditBox, -- 'M6'; edit box, title and group we leave alone.
		ABE_MacroInput, -- 'OPie'; the edit box for custom macro buttons.
		MacroFrameText, -- 'Blizzard_MacroUI'; also affects 'ImprovedMacroFrame'.
	}
	-- We can't use `ipairs' here because a missing addon (nil) would stop iteration.
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

-- We directly manipulate WoWLua's font object, otherwise we get reset when the
-- user changes font size in WoWLua.
-- We use the font size as actually set in the WowLua GUI.
-- Required OptionalDeps in toc: 'WowLua'
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
	BugSack (experimental)
===========================================================================]]--

-- The main frame is not created before first open, so we have to hook.
-- Required OptionalDeps in toc: 'BugSack'
local function setup_bugsack()
	if not BugSack then return end
	local font_set = false
	hooksecurefunc(BugSack, 'OpenSack', function()
		if not font_set then -- No need to run it more than once
			BugSackScrollText:SetFontObject(ebfi_font)
			font_set = true
		end
	end)
end


--[[===========================================================================
	Run the Stuff
===========================================================================]]--

setup_misc()
setup_wowlua()
setup_bugsack()

-- NOTE: We could also run this in an event script at PLAYER_LOGIN, but the
-- OptionalDeps system seems to work fine so far.



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
