# Changelog

## 1.0.0 (2026-10-26)

First release.

- Record players spin clockwise instead of counter-clockwise.
- Record players spin at 33⅓ RPM (one turn every 1.8 s) instead of 60 RPM. The speed is set by `TargetRPM` in `Config.reds`.
- Covers the record players in the Japantown, The Glen and Corpo Plaza apartments, in H10 (Kerry's gift), in the epilogue and in Dogtown, plus the generic record player device.
- The tonearm swing is left unchanged.
- The animator is edited by a small RED4ext plugin (`VinylFix.dll`). Editing it from redscript alone crashed the game when a record player loaded.
- Optional `PatchWorldNodes` setting for record meshes placed directly in world sectors. It's off by default and untested in game.

Tested on game 2.5 with RED4ext 1.31.0, redscript 0.5.32 and Codeware 1.21.1.
