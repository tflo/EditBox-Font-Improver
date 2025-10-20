# EditBox Font Improver

## Summary

The addon lets you set your custom font and font size for the edit boxes of:

- Blizz’s macro UI: Edit box
- [M6](https://www.curseforge.com/wow/addons/m6x): Edit box
- [OPie](https://www.curseforge.com/wow/addons/opie): The edit box to write a macro for a button
- [WowLua](https://www.curseforge.com/wow/addons/wowlua): Output and edit box
- [ScriptLibrary](https://www.curseforge.com/wow/addons/script-library): Edit box
- [BugSack](https://www.curseforge.com/wow/addons/bugsack): Main window text (not an edit box, but it contains code that should be readable)

The main point is that in these macro/code boxes we want a clean, monospaced font, and not Friz Quadrata, Arial Narrow, or similar nonsense. (WoWLua is an exception, as it already uses a monospaced font. EFI allows you to replace it with the one of your choice.)

This not an addon to globally change the WoW UI font! Its scope is to make the coding font of your choice available in macro and script editor addons (and BugSack), without affecting the rest of the UI.

___If you’re having trouble reading this description on CurseForge, you might want to try switching to the [REPO PAGE](https://github.com/tflo/EditBox-Font-Improver?tab=readme-ov-file#editbox-font-improver). You’ll find the exact same text there, but it’s much easier to read and free from CurseForge’s rendering errors.___

## Setup

### Font Selection

By default, the addon comes with a PT Mono font file and the font path is pre-set to that font. (The PT fonts are my preferred font family for the WoW UI.)

**New in version 3:**

You can now save a whole collection of fonts (more precisely: font paths) and switch between them with a simple slash command.

The easiest way to add your own font paths is by editing the SavedVariables file directly. If you open the SavedVariables file, you will see the default font list, consisting of two font paths:

```lua
["fonts"] = {
"Interface/AddOns/EditBox-Font-Improver/font/pt-mono_regular.ttf",
"Interface/AddOns/WeakAuras/Media/Fonts/FiraMono-Medium.ttf",
},
```

The first one is the already mentioned PT Mono font that comes with the addon itself. The second one is the monospaced font in the WeakAuras folder. So if you happen to have WeakAuras installed, you can already switch between these two fonts.

The command for this is `/efi font <number>` or shorter `/efi f <number>`. So, to select the WeakAuras Fira Mono font, you simply enter `/efi f 2`. With `/efi f 1` you select the included default font again.

The point of this font list is not to provide you with an exhaustive font collection out of the box (EFI is not a media addon), but to give you the possibility to add your own favorite fonts and easily switch between them.

You can use any font that is located inside the `World of Warcraft/_retail_/Interface/AddOns` directory. If you already have a bunch of fonts installed (for example in a [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) folder like `Interface/AddOns/SharedMedia_MyMedia`), just add the paths.

Note that `Interface` must be the root folder of *any* font path. 

EFI’s SavedVariables file is at the usual location: 
`World of Warcraft/_retail_/WTF/Account/<number>/SavedVariables/EditBox-Font-Improver.lua`.

To edit and save the SavedVariables file, you have to be logged out (but not necessary to quit the game). Otherwise the game client will overwrite your changes at logout.

In the SavedVariables file itself you will also find a small “Read Me!” text with instructions for the font path.

If you see a `["font"]` key, do *not* edit it, because it holds the index for the currently active font from the `["fonts"]` list.

### Enable/Disable

By default, the addon changes the font of the above listed addons. If you really want to deactivate the font replacement for a specific addon, you have to set the `enable` key of that addon to `false` in the SavedVariables files. (As with the font setup, you have to be logged out while editing/saving the SavedVariables file.)

The `macroeditors` key affects Blizz’s macro UI, M6, and OPie. The other addons (WoWLua, BugSack, ScriptLibrary) have individual keys.

Alternatively you can use these in-game commands (reload the UI afterwards):

```text
/run EBFI_DB.macroeditors.enable = false
/run EBFI_DB.wowlua.enable = false
/run EBFI_DB.scriptlibrary.enable = false
/run EBFI_DB.bugsack.enable = false
```

Use `true` to re-enable.

### Font Size

You can change the font size with a slash command:

`/editboxfontimprover <font size>` or `/efi <font size>`

For example `/efi 14`.

This affects only the addons that are set to use EFI’s default font size, which are the addons that do not have their own font size setting (currently Blizz Macro UI, M6, and OPie). WowLua, ScriptLibrary, and BugSack have their own font size setting, and EFI by default will not override it.

However you can enforce EFI’s font size for these addons with the `/efi unisize` command. Revert back with `/efi ownsize`.

Note that even with `unisize` you can still use the respective addon’s font size setting. The size will just be reset at login, or when you use the slash command to change the size or to switch to another font.

---

Feel free to share your suggestions or report issues on the [GitHub Issues](https://github.com/tflo/EditBox-Font-Improver/issues) page of the repository.  
__Please avoid posting suggestions or issues in the comments on Curseforge.__

---

__Other addons by me:__

- [___PetWalker___](https://www.curseforge.com/wow/addons/petwalker): Never lose your pet again (…or randomly summon a
  new one).
- [___Auto Quest Tracker Mk III___](https://www.curseforge.com/wow/addons/auto-quest-tracker-mk-iii): Continuation of the one and only original. Up to date and tons of new features.
- [___Move 'em All___](https://www.curseforge.com/wow/addons/move-em-all): Mass move items/stacks from your bags to wherever. Works also fine with most bag addons.
- [___Auto Discount Repair___](https://www.curseforge.com/wow/addons/auto-discount-repair): Automatically repair your gear – where it’s cheap.
- [___Auto-Confirm Equip___](https://www.curseforge.com/wow/addons/auto-confirm-equip): Less (or no) confirmation prompts for BoE gear.
- [___Action Bar Button Growth Direction___](https://www.curseforge.com/wow/addons/action-bar-button-growth-direction):
  Fix the button growth direction of multi-row action bars to what is was before Dragonflight (top --> bottom).

__WeakAuras:__

- [___Stats Mini___](https://wago.io/S4023p3Im): A *very* compact but beautiful and feature-loaded stats display: primary/secondary stats, *all* defensive stats (also against target), GCD, speed (rating/base/actual/Skyriding), iLevel (equipped/overall/difference), char level +progress.
