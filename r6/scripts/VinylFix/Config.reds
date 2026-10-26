module VinylFix

// Edit these values to tune the mod, then restart the game.
public abstract class VinylFixConfig {
  // Real turntables spin at 33 1/3 RPM (LPs) or 45 RPM (singles).
  public static func TargetRPM() -> Float = 33.333333

  // Reverse the spin of record platters so they turn the right way.
  public static func FixDirection() -> Bool = true

  // Retime the looping spin animation to TargetRPM.
  public static func FixSpeed() -> Bool = true

  // Also patch record meshes placed directly in the world as rotating
  // mesh nodes (not part of a record player device). Off by default:
  // experimental and untested in game, and it makes Codeware inspect every
  // resource the game loads.
  public static func PatchWorldNodes() -> Bool = false

  // Write what the mod patched to the log. Useful while testing.
  public static func DebugLog() -> Bool = true
}
