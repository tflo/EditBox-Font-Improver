# EditBox Font Improver

## Summary

The addon lets you set your custom font, font size and style for the edit boxes of: 

- Blizz’s macro frame
- [M6](https://www.curseforge.com/wow/addons/m6x)
- [OPie](https://www.curseforge.com/wow/addons/opie) (the box to write a custom macro for a button)
- [WowLua](https://www.wowinterface.com/downloads/info7366-WowLua.html) (output and edit box)

The main point is that in these macro/script edit boxes we want a clean, monospaced font, and not Friz Quadrata, Arial Narrow, or similar nonsense.

## Usage

### First-time setup

Before using the addon the first time, you have to set the path to your desired font in the `main.lua` file of the addon. 

If you use [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia), then your fonts will usually be in…
- `Interface/AddOns/SharedMedia/fonts/` or  
- `Interface/AddOns/SharedMedia_MyMedia/`

If not, anything inside the client folder should be accessible, for example in `World of Warcraft/_retail_/Fonts/` or `World of Warcraft/_retail_/Interface/MyNewFontFolder/`.  
The path then would be `Fonts/myfont.ttf` or `Interface/MyNewFontFolder/myfont.ttf`.

You can also set font size and font flags in `main.lua`. You have more instructions there. 

### Adding more addons

By default, the addon changes the font only of the addons I am using (see above). If you have another addon with an unsuitable font in the edit box, you can try to add the frame to the list. Find more instructions in `main.lua`.

---

Feel free to post suggestions or issues in the [GitHub Issues](https://github.com/tflo/PetWalker/issues) of the repo!
__Please do not post issues or suggestions in the comments on Curseforge.__

