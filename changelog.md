To see all commits, including all alpha changes, [*go here*](https://github.com/tflo/EditBox-Font-Improver/commits/master/).

---

## Releases

#### 3.2.2 (2025-11-03)

- Remove Roboto from the top 1–12 group.
- Add VictorMono-Medium to the top 1–12 group, pos. 11.

#### 3.2.1 (2025-11-03)

- Updated ReadMe for the added PasteNG addon.

#### 3.2.0 (2025-11-03)

- Add Victor Mono font in 3 weights and 2 styles.
    - This is an interesting font for our purpose, as it is pretty narrow while still mono-like.
- Set default font size to 13 (was 12). Does not affect existing setups.
    - I have a hard time to judge what would be a good size for the “average” setup, as I’m running the game GUI at 100% UI Scale on a MacBook with native 3456x2234; for me, 14–16px is a good size, so with 80% UI Scale (which seems to be a more common scale), 13px *could* be the sweet spot.
    -  In any case, you can always adjust it with `/efi s <size>`.

#### 3.1.0 (2025-11-03)

- Add PasteNG as supported addon (editbox). Currently member of the `macroeditors` group.
- Rename `macroeditors` to `misceditors`, `macro editors` to `misc editors` in all UI and internal instances.
- toc: Add 110207 as compatible interface.

#### 3.0.0 (2025-10-27)

- **This is a total rework of the addon.** Main changes:
    - **You can no longer add your own font paths** to the SavedVariables file (may be added back later).
    - EFI now comes with **quite a few preinstalled fonts** you can choose from (currently 74).
    - Please check out the totally rewritten and updated [ReadMe](https://github.com/tflo/EditBox-Font-Improver?tab=readme-ov-file#editbox-font-improver), or the description on CF, for the new font selection commands and other exciting new or changed stuff!
- If you’re coming from v2, the database will be rest.
- Add slash command to set the font size (no reload required). Example `/efi s 14`.
- Add slash command to select a font (no reload required). Example `/efi 3`.
- Respect the addon-set font size (from the addon’s own font size setting) also for ScriptLibrary and BugSack (before, it was only respected for WowLua).
    - This behavior is enabled by default.
    - If you want to enforce efi’s default font size for all addons, use `/efi unisize`. Revert back with `/efi ownsize`.
- Fix `SetFont` bug with WowLua.
- “Rebranded” addon acronym from EBFI to EFI, including the slash command (now `/efi`). The old `/ebfi` will continue to work, along with the full one `/editboxfontimprover`.
- More, and more informative, warning messages if a font could not be set.
- Full rework of the CLI, inluding comprehensive help display with all commands.
- Remove the still not used individual font sizes from the DB. 
    - This was planned to be implemented, but it doesn’t really make much sense. And with WoWLua, ScriptLibrary, and BugSack you can set the font size within the addon itself anyway.
- Standardize addon-is-loaded detection.
- Various code optimizations.

#### 2.0.7 (2025-10-07)

- toc bumped to 110205, no changes.

#### 2.0.6 (2025-09-14)

- Standardized licensing information in the files.
- ReadMe/description: minor changes; added my new addon [Auto Discount Repair](https://www.curseforge.com/wow/addons/auto-discount-repair) to the “Other addons” list.

#### 2.0.5 (2025-08-05)

- toc: Added interface `110200`

#### 2.0.4 (2025-06-18)

- toc: Added `AllowAddOnTableAccess: 1`
- toc: Bumped Interface to `110107`

#### 2.0.3 (2025-04-24)

- fixed missing toc bump.

#### 2.0.2 (2025-04-23)
- toc bump to 110105.
    - Seems to work fine, but not done many tests.
    - But let’s face it, get over yourself and tick that damn “Load out of date AddOns” checkbox. This (i.e not ticking this) is a 100% hypocritical assessment. If an addon author isn’t in the mood to do big revisions, he will just bump that toc number anyway. And you’ll end up with the errors, with or w/o checkbox. That’s what hypocritical means (in this context).
    - Blizz could introduce a real check, that is, checking against some crucial API changes in the last release. This would not cost much (but a bit more than now), but yeah it’s Blizz, only the most cheapest and rotten and fake for us customers.

#### 2.0.1 (2025-02-26)

- Turned the beta into release: See 2.0.0-beta change notes! In short:
    - You set the font path now in the SavedVariables file. (This means it will be preserved across future addon updates.)
    - If coming from an older version (including betas), delete your existing SavedVariables file while logged out!
- The addon comes now with a font included (PT Mono) and pre-set font path.
- In the SavedVariables file, you can now disable the addon for individual applications (macro editors, WoWLua, ScriptLibrary, BugSack).
- Also in the SavedVariables file, you can now set the font size.
- More informative “font path is not valid” message.
- Updated readme/description.
- Added category to toc.
- toc bump to 110100.

#### 2.0.0-beta3 (2024-12-19)

- toc bump to 110007 (WoW Retail 11.0.7).
- No content changes. If I notice that the addon needs an update for 11.0.7, I will release one.
- I currently do not have much time to play, so if you notice weird/unusual behavior with 11.0.7 and don’t see an update from my part, please let me know [here](https://github.com/tflo/EditBox-Font-Improver/issues).

#### 2.0.0-beta2 (2024-10-23)

- If not yet done, read the big change notes from 2.0.0-beta1 (2024-10-17) below!
- Using the enable switches from the DB now.
- Removed some old comments.
- Deactivated debug mode.

#### 2.0.0-beta1 (2024-10-17)

- WiP!
- You have to set your font path now in the SavedVariables file.
    - This is a QoL improvement for you, as your set font path will be persistent through addon updates now.
    - The SavedVariables file is located at: `World of Warcraft/_retail_/WTF/Account/<accountNumber>/SavedVariables/EditBox-Font-Improver.lua`.
    - If it isn’t there, then reload the UI or log out while EBFI is loaded. It will be created then.
    - What you are looking for is the value of the `["font"]` key in the SavedVariables file.
    - The initial value is a sample font path string. Just replace it with your actual font path.
    - Edit the SavedVariables file only while you are logged out! Otherwise the game client will overwrite your changes at logout/reload.
    - Use a simple Plain Text Editor to edit the file. Do not use a Word Processor (e.g. Pages, MS Word)!
    - You find some instructions in the SavedVariables file itself (`["Read Me!"]`)
    - You can no longer set the font path in the main.lua file!
- Added support for the ScriptLibrary addon.
- Using events now to do stuff.

#### 1.2.1 (2024-07-31)

- I had to revert the line spacing setting for the WoWLua editbox, since this messes up the cursor position. Will be re-implemented when/if I find a solution.

#### 1.2.0 (2024-07-27)

- The "experimental" addition of BugSack (see 1.2.0-beta-1 notes) works fine, so this is a permanent feature now.
- Removed font flags (outlining) from the Config section. We don't need that.
- Optimizations.
- Better instructions in main.lua and the readme/description.

#### 1.2.0-beta-1 (2024-07-26)

- Added increased interline spacing (leading) for the WoWLua edit box.
    - WoWLua's default spacing of 0 is so tight that underscores visually melt into uppercase letters on the next line.
    - Check *main.lua* for config.
- Font replacement now covers the BugSack main frame content (experimental!).
    - Yes, this is not a macro/script edit box. But it contains code, so a little more readability is not a bad thing.
- Refactored code.
- Uploaded screenshots to CF.

#### 1.1.0 (2024-07-26)

- Fixed the WoWLua part so that it actually works. (Sorry, I haven't used WoWLua for a while).
- More explanatory comments in the config section in `main.lua`.

#### 1.0.9 (2024-07-24)

- toc updated for TWW 110000.
- Tested in TWW with Blizz Macro Editor, M6 Editor, and OPie.

#### 1.0.8 (2024-05-08)

- toc bump only (100207). Addon update will follow as needed.

#### 1.0.7 (2024-03-19)

- toc bump only. If necessary, the addon will be updated in the next days.

#### 1.0.6 (2024-01-16)

- Just a toc bump for 10.2.5. Compatibility update will follow if needed.

#### 1.0.5 (2023-11-08)

-toc update 100200; no content changes.

#### 1.0.4 (2023-09-07)

- Slightly better instruction comments in main.lua.
- Readme changes.
- toc bump for 100107

#### 1.0.3 (2023-07-12)

- toc updated for 10.1.5.
  - I have not yet had a chance to really test the addon with 10.1.5, but as far as I know there are no relevant API changes. If I find any problems, you'll get a content update soon.

#### 1.0.2 (2023-05-02)

- toc: update for 10.1

#### 1.0.1.2 (2023-03-22)

- toc: update for 10.0.7

#### 1.0.1.1 (2023-01-25)

- toc: update for 10.0.5
- Removed some obsolete comments

#### 1.0.1 (2022-12-31)

- toc: Added CF ID
- Minor changes to readme
- Cleaned up some old commented stuff

#### 1.0.0 (2022-11-18)

- toc: update for 10.0.2

#### 0.9.0

- Initial
