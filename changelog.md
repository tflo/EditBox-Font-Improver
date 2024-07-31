To see all commits, including alpha-version changes, go [here](https://github.com/tflo/EditBox-Font-Improver/commits/master/).

### Releases

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
