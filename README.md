# Vinyl Fix

Makes the record players in V's apartments spin the right way (clockwise, like a real turntable) and at a real record speed (33⅓ RPM by default).

This answers the Nexus forum request [Is anybody else bothered that the record players in the apartments rotate the wrong way?](https://forums.nexusmods.com/topic/13547437-is-anybody-else-bothered-that-the-record-players-in-the-apartments-rotate-the-wrong-way/).

## Requirements

- [RED4ext](https://www.nexusmods.com/cyberpunk2077/mods/2380)
- [redscript](https://www.nexusmods.com/cyberpunk2077/mods/1511)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780)

## Installation

Copy the `r6` and `red4ext` folders into your Cyberpunk 2077 install folder, so you end up with:

```
Cyberpunk 2077/r6/scripts/VinylFix/Config.reds
Cyberpunk 2077/r6/scripts/VinylFix/Native.reds
Cyberpunk 2077/r6/scripts/VinylFix/Targets.reds
Cyberpunk 2077/r6/scripts/VinylFix/VinylFix.reds
Cyberpunk 2077/red4ext/plugins/VinylFix/VinylFix.dll
```

To uninstall, delete `r6/scripts/VinylFix` and `red4ext/plugins/VinylFix`. The mod doesn't change your save, so removing it is safe.

## What it covers

Record player entities:

| Location | Template |
| --- | --- |
| Generic record player device | `base\gameplay\devices\custom\vinyl_record_player.ent` |
| H10 megabuilding (Kerry's gift, *sq028*) | `base\items\quest\sq028__record_player_a.ent`, `base\quest\side_quests\sq028\entities\sq028_record_player.ent` |
| Japantown apartment | `dlc\dlc6_apart\loc_dlc6_apart_wbr_jpn\...\dlc6_apart_wbr_jpn_record_player.ent` |
| Corpo Plaza apartment | `dlc\dlc6_apart\loc_dlc6_apart_cct_dtn\...\dlc6_apart_cct_dtn_record_player.ent` |
| The Glen apartment | `dlc\dlc6_apart\loc_dlc6_apart_hey_gle\...\dlc6_apart_hey_gle_record_player.ent` |
| Epilogue (*q204*) | `base\quest\main_quests\epilogue\q204\entities\q204_record_player.ent` |
| Dogtown (*q305*) | `ep1\items\quest\q305__record_player.ent` |

Optionally (`PatchWorldNodes`, off by default), it also patches the record meshes listed in `Targets.reds` (from `base\environment\decoration\misc\music\vinyl\`) wherever a world sector places one as a `worldRotatingMeshNode`.

## How it works

The mod uses Codeware callbacks and a small RED4ext plugin:

- **`Entity/Assemble`** on the record player templates above. For each `gameTransformAnimatorComponent`, the script calls the plugin's `VinylFix_PatchAnimator`. In every looping animation (the platter spin, `play_record`), the plugin flips the `reverseDirection` of each `gameTransformAnimation_RotateOnAxis` track. One-shot animations, like the tonearm swing (`play_arm`), are left alone. On a timeline that holds only the spin, it also sets the definition's `timeScale` so one full turn takes `60 / TargetRPM` seconds, and makes the movement linear.

  The plugin exists because redscript can't touch this data safely. The animator stores its track items (`ISerializable` objects) inline, so reading `animations` from a script copies them, and destroying those copies breaks the originals. The game then crashes when the record player loads. The plugin edits the component in place instead. It only uses RTTI, not game addresses, so it doesn't depend on the game version.
- **`Resource/PostLoad`** on `worldStreamingSector`, only when `PatchWorldNodes` is on. For `worldRotatingMeshNode`s that use a record mesh, the mod flips `reverseDirection` and sets `fullRotationTime = 60 / TargetRPM`.

All changes are made in memory as entities and sectors load. No game files are replaced, so the mod is compatible with apartment and retexture mods.

## Settings

Edit `r6/scripts/VinylFix/Config.reds`, then restart the game:

| Setting | Default | Meaning |
| --- | --- | --- |
| `TargetRPM` | `33.333333` | Spin speed. Use `45.0` for singles. |
| `FixDirection` | `true` | Reverse the spin direction. |
| `FixSpeed` | `true` | Retime the spin to `TargetRPM`. |
| `PatchWorldNodes` | `false` | Also patch record meshes placed directly in the world. Experimental and untested in game: it makes Codeware inspect every resource the game loads. |
| `DebugLog` | `true` | Log every patched record player. Set it to `false` once you've confirmed the mod works. |

## Testing

1. Install the requirements and the mod, then start the game. If the scripts fail to compile, redscript shows an error popup and writes `r6/logs/redscript_rCURRENT.log`.
2. Load a save and go to an apartment with a record player. Start it if it has a play interaction.
3. Check that the platter spins clockwise when seen from above, at about one turn every 1.8 s.
4. Open the newest `red4ext/logs/vinylfix-*.log`. It has one line per patched spin track, for example `Spin track 'play_record': axis 2, 1.00 turn(s) per 1.00s, looping=1, reverse=1, timeScale=0.5556`. `No looping spin track on animator, left unchanged` is normal for the tonearm's animator. If it's the only line for a record player, that record player spins some other way. Please report it so support can be added.
5. For the script side, `VinylFix` lines also appear in the game log, which you can see in the **Game Log** window of the [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) overlay.

## Building the plugin

The plugin source is in `src/Main.cpp`. It builds against [RED4ext.SDK](https://github.com/wopss/RED4ext.SDK), which is a git submodule.

1. Install the Visual Studio 2022 C++ build tools.
2. Run `git submodule update --init`.
3. Run `build.bat`. It writes `red4ext/plugins/VinylFix/VinylFix.dll`.
