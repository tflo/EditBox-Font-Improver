# EditBox Font Improver

***Note on version 2 (2025-02-26):****

- **If you are coming from version 1.x or the 2.0.0-beta versions, please delete your SavedVariables file while being logged out!** (You might get a one-time SV loading error after deleting. This is harmless.)
- **Read the completely rewritten “Setup” section below, since almost everything has changed!**

## Summary

The addon lets you set your custom font and font size for the edit boxes of:

- Blizz’s macro frame: Edit box
- [M6](https://www.curseforge.com/wow/addons/m6x): Edit box
- [OPie](https://www.curseforge.com/wow/addons/opie): The edit box to write a macro for a button
- [WowLua](https://www.curseforge.com/wow/addons/wowlua): Output and edit box
- [ScriptLibrary](https://www.curseforge.com/wow/addons/script-library): Edit box
- [BugSack](https://www.curseforge.com/wow/addons/bugsack): Main window text (not an edit box, but it contains code that should be readable)

The main point is that in these macro/code boxes we want a clean, monospaced font, and not Friz Quadrata, Arial Narrow, or similar nonsense. (WoWLua is an exception, as it already uses an appropriate font. See the comments in `main.lua` for how to exclude WoWLua from the font replacement.)

## Setup

### Font Path

By default, the addon comes with the PT Mono font and the font path is pre-set to that font.

To use a different font, **you have to set the path to your desired font in the SavedVariables file of the addon.** The SavedVariables file is located at  
`World of Warcraft/_retail_/WTF/Account/[number]/SavedVariables/EditBox-Font-Improver.lua`.

To edit and save the SavedVariables file, you have to be logged out (though not necessary to quit the game).

You can set the font path to anything inside the `Interface/AddOns` folder. Examples:

If you use [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia), then your fonts will usually be in…

- `Interface/AddOns/SharedMedia/fonts/` or
- `Interface/AddOns/SharedMedia_MyMedia/` or a similar location

You can also just toss a font file into the AddOns folder and set the path like `Interface/AddOns/MyFont.ttf`.

Note that `Interface` must be the root folder of any path. 

In the SavedVariables file itself you will also find a small “Read Me!” text with instructions for the font path.

### Enable/Disable

By default, the addon changes the font of the above listed addons. To deactivate the font replacement for an addon, you have to set the `enable` key of that addon to `false` in the SavedVariables files. (As with the font setup, you have to be logged out while editing/saving the SavedVariables file.)

The `macroeditors` key affects Blizz’s macro frame, M6, and OPie. The other addons (WoWLua, BugSack, ScriptLibrary) have individual keys.

### Font Size

Change the value (default 12) of the `default_fontsize` key in the SavedVariables file to change the font size for all affected addons. (As with the font setup, you have to be logged out while editing/saving the SavedVariables file.)

In the SavedVariables file you might also see a `fontsize` key for the individual addons. However, individual font sizes are not enabled at this moment (and probably it wouldn’t make much sense).

---

Feel free to post suggestions or issues in the [GitHub Issues](https://github.com/tflo/EditBox-Font-Improver/issues) of the repo!
__Please do not post issues or suggestions in the comments on Curseforge.__

---

__Other addons by me:__

- [___PetWalker___](https://www.curseforge.com/wow/addons/petwalker): Never lose your pet again (…or randomly summon a
  new one).
- [___Auto Quest Tracker Mk III___](https://www.curseforge.com/wow/addons/auto-quest-tracker-mk-iii): Continuation of
  the one and only original. Up to date and new features.
- [___Move 'em All___](https://www.curseforge.com/wow/addons/move-em-all): Mass move items/stacks from your bags to
  wherever. Works also with bag addons.
- [___Auto-Confirm Equip___](https://www.curseforge.com/wow/addons/auto-confirm-equip): Less (or no) confirmation
  prompts for BoE gear.
- [___Action Bar Button Growth Direction___](https://www.curseforge.com/wow/addons/action-bar-button-growth-direction):
  Fix the button growth direction of multi-row action bars to what is was before Dragonflight (top --> bottom).

__WeakAuras:__

- [___Stats Mini___](https://wago.io/S4023p3Im): A *very* compact but beautiful and feature-loaded stats display: primary/secondary stats, *all* defensive stats (also against target), GCD, speed (rating/base/actual/Skyriding), iLevel (equipped/overall/difference), char level +progress.
