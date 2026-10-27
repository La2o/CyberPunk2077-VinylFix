# Contributing

## Reporting a problem

Open an issue on [GitHub](https://github.com/La2o/CyberPunk2077-VinylFix/issues) or post in the comments on [Nexus Mods](https://www.nexusmods.com/cyberpunk2077/mods/36113). Include:

- Your game version, and the RED4ext, redscript and Codeware versions.
- Where the record player is (apartment, quest or district).
- The newest `red4ext/logs/vinylfix-*.log`.
- For a crash, the crash report folder that the game writes.

### A record player that isn't fixed

If the log for a record player only says `No looping spin track on animator, left unchanged`, that record player animates its platter some other way. Say where it is, and if you can, the `.ent` template it uses (for example from WolvenKit or the Cyber Engine Tweaks overlay). Support can then be added to `Targets.reds` or the plugin.

### A record player that isn't in the log at all

Its template isn't in `VinylFixTargets.RecordPlayerTemplates()` in `r6/scripts/VinylFix/Targets.reds`. Add the template path there and test it, or report it with its location.

## Changing the code

The mod has two parts:

- `r6/scripts/VinylFix/` holds the redscript. It registers the Codeware callbacks and calls the plugin for each record player.
- `src/Main.cpp` holds the RED4ext plugin. It edits the animator data in place.

Keep reads and writes of `gameTransformAnimatorComponent.animations` in the plugin. Reading that array from redscript copies its track items, and destroying the copies corrupts the originals, which crashes the game.

To build the plugin, see [Building the plugin](README.md#building-the-plugin). Scripts need no build step: copy them into `r6/scripts/VinylFix/`, and redscript compiles them when the game starts.

Before you open a pull request:

1. Test in game: load a save near a record player and check that the platter spins clockwise and the tonearm still swings onto the record.
2. Check `vinylfix-*.log` for the expected `Spin track 'play_record'` line.
3. Check that a fast travel and a save load near the record player don't crash.
4. Add a line under a new version heading in [CHANGELOG.md](CHANGELOG.md).

## Releasing

1. Bump the version in `Query()` in `src/Main.cpp` and add the changelog entry.
2. Run `build.bat`.
3. Zip `r6/scripts/VinylFix/*.reds` and `red4ext/plugins/VinylFix/VinylFix.dll` with those folder paths, plus [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
4. Tag the commit `vX.Y.Z`, create the GitHub release with the zip, and upload the same zip to Nexus Mods.
