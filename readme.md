# EditBox Font Improver

***Beta Note: This is the description for the 1.x.x release version. For the current 2.x.x-beta or alpha versions (Oct 2024), see the changelog!***

## Summary

The addon lets you set your custom font and font size for the edit boxes of:

- Blizz’s macro frame: Edit box
- [M6](https://www.curseforge.com/wow/addons/m6x): Edit box
- [OPie](https://www.curseforge.com/wow/addons/opie): The edit box to write a macro for a button
- [WowLua](https://www.wowinterface.com/downloads/info7366-WowLua.html): Output and edit box
- [BugSack](https://www.curseforge.com/wow/addons/bugsack): Main window text (not an edit box, but it contains code that should be readable)

The main point is that in these macro/script edit boxes we want a clean, monospaced font, and not Friz Quadrata, Arial Narrow, or similar nonsense. (WoWLua is an exception, as it already uses an appropriate font. See the comments in `main.lua` for how to exclude WoWLua from the font replacement.)

## Usage

### First-time setup

Before using the addon the first time, **you have to set the path to your desired font in the `main.lua` file of the addon.** This and other settings are in the Config section, which is very well commented.

If you use [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia), then your fonts will usually be in…

- `Interface/AddOns/SharedMedia/fonts/` or
- `Interface/AddOns/SharedMedia_MyMedia/`

If not, anything inside the client folder should be accessible, for example in `World of Warcraft/_retail_/Fonts/` or `World of Warcraft/_retail_/Interface/MyNewFontFolder/`.
The path then would be `Fonts/myfont.ttf` or `Interface/MyNewFontFolder/myfont.ttf`.

You can also set the font size and other things in `main.lua`. _You find more instructions there._

**To make it clear (as this is different from most addons): You HAVE TO edit the Config section in the `main.lua` file in order to use the addon. Setting the font path there is not optional!**

### Adding more addons

By default, the addon changes the font only of the addons I am using or was using (see above). If you have another addon with an unsuitable font in the edit box, you can try to add the frame to the list. Find more instructions in `main.lua`.

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
