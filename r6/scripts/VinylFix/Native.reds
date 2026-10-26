// Implemented by red4ext/plugins/VinylFix/VinylFix.dll. Edits the animator's
// animations in place: flips every RotateOnAxis spin on a looping animation
// (not one-shot ones like the tonearm) and, on a spin-only timeline, sets
// timeScale so one turn takes 60 / targetRPM seconds.
// Returns the number of spin tracks patched.
public static native func VinylFix_PatchAnimator(animator: ref<gameTransformAnimatorComponent>, fixDirection: Bool, fixSpeed: Bool, targetRPM: Float) -> Int32
