# CLAUDE.md

Vinyl Fix is a Cyberpunk 2077 mod that makes record players spin clockwise at 33⅓ RPM. It's redscript (`r6/scripts/VinylFix/`) plus a small RED4ext plugin (`src/Main.cpp`), and needs RED4ext, redscript and Codeware at run time. See [README.md](README.md) for what it covers and how it works, and [CONTRIBUTING.md](CONTRIBUTING.md) for the test and release checklist.

## Rules

- Never read or write `gameTransformAnimatorComponent.animations` from redscript, not even to look. Its track items are `ISerializable` objects stored inline; a script read copies them, destroying the copies corrupts the originals, and the game crashes on load or fast travel. All animator edits go through the native `VinylFix_PatchAnimator`.
- Only patch looping definitions. The tonearm swing (`play_arm`) is a one-shot `RotateOnAxis` too, and flipping it breaks it. The platter spin is `play_record`.
- Keep the plugin free of game addresses (RTTI only), so `RED4EXT_V1_RUNTIME_VERSION_INDEPENDENT` stays true.
- `Native.reds` has no `module` line, because the native function is global. The other scripts are in `module VinylFix`.
- Redscript can't iterate class-typed arrays with `for x in`; use index access.

## Build

`build.bat` finds Visual Studio 2022 with vswhere, configures CMake with Ninja (Release) and copies the DLL to `red4ext/plugins/VinylFix/VinylFix.dll`. The SDK is the `deps/RED4ext.SDK` submodule (`git submodule update --init`). In the SDK, plugin types are under `RED4ext::v1::` and `DynArray` uses `size()`.

`build/`, `dist/` and `red4ext/` are gitignored.

## Checking scripts without starting the game

Compile with the game's script compiler into a scratch cache, so the real cache isn't touched:

```
"<game>/engine/tools/scc.exe" -compile "<game>/r6/scripts" -customCacheDir <scratch dir> -compilePathsFile <file listing <game>/red4ext/plugins/Codeware/Scripts>
```

This needs the mod's scripts copied into `<game>/r6/scripts/VinylFix/` first.

## Local game install

The game is at `D:\SteamLibrary\steamapps\common\Cyberpunk 2077` (version 2.5, with RED4ext 1.31.0, redscript 0.5.32 and Codeware 1.21.1). To install the mod, copy `r6/scripts/VinylFix/` and `red4ext/plugins/VinylFix/VinylFix.dll` there; the DLL can't be replaced while the game runs.

Logs to check after a run:

- `red4ext/logs/vinylfix-*.log`: one `Spin track 'play_record' ...` line per patched record player.
- `r6/logs/redscript_rCURRENT.log`: script compile errors.
- `red4ext/logs/red4ext-*.log`: plugin loading.
- Crash reports (with `Cyberpunk2077.dmp`) are in `%LOCALAPPDATA%\REDEngine\ReportQueue\`, one folder per crash.

## Releases

Released as v1.0.0 on [GitHub](https://github.com/La2o/CyberPunk2077-VinylFix/releases) and [Nexus Mods](https://www.nexusmods.com/cyberpunk2077/mods/36113). Release zips are built into `dist/`. Bump the version in `Query()` in `src/Main.cpp` and add a [CHANGELOG.md](CHANGELOG.md) entry for each release.
