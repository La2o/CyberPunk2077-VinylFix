module VinylFix

// Record platters spin through a RotateOnAxis track in the record player's
// transform animator, or through a worldRotatingMeshNode when a record is
// placed straight into a world sector. Both are patched before they start:
// the direction is reversed and the looping spin is retimed to TargetRPM.
public class VinylFixService extends ScriptableService {
  private cb func OnLoad() {
    let callbacks = GameInstance.GetCallbackSystem();

    let handler = callbacks.RegisterCallback(n"Entity/Assemble", this, n"OnRecordPlayerAssemble");
    for template in VinylFixTargets.RecordPlayerTemplates() {
      handler.AddTarget(EntityTarget.Template(template));
    }

    if VinylFixConfig.PatchWorldNodes() {
      callbacks.RegisterCallback(n"Resource/PostLoad", this, n"OnSectorLoaded")
        .AddTarget(ResourceTarget.Type(n"worldStreamingSector"));
    }
  }

  private cb func OnRecordPlayerAssemble(event: ref<EntityLifecycleEvent>) {
    let entity = event.GetEntity();
    if !IsDefined(entity) {
      return;
    }

    let patched = 0;
    let components = "";
    for component in entity.GetComponents() {
      let animator = component as gameTransformAnimatorComponent;
      if IsDefined(animator) {
        patched += this.PatchAnimator(animator);
      }
      components = components + s" \(NameToString(component.GetClassName()))";
    }

    if VinylFixConfig.DebugLog() {
      if patched > 0 {
        VinylFixService.Log(s"Patched \(patched) spin track(s) on \(NameToString(entity.GetClassName()))");
      } else {
        VinylFixService.Log(s"No spin track found on \(NameToString(entity.GetClassName())), components:\(components)");
      }
    }
  }

  private func PatchAnimator(animator: ref<gameTransformAnimatorComponent>) -> Int32 {
    let patched = 0;
    let animations = animator.animations;
    let i = 0;
    while i < ArraySize(animations) {
      let definition = animations[i];
      let itemCount = ArraySize(definition.timeline.items);
      let j = 0;
      while j < itemCount {
        let duration = definition.timeline.items[j].duration;
        let spin = definition.timeline.items[j].impl as gameTransformAnimation_RotateOnAxis;
        if IsDefined(spin) {
          if VinylFixConfig.FixDirection() {
            spin.reverseDirection = !spin.reverseDirection;
          }

          // Only retime a looping timeline that holds nothing but the spin,
          // since timeScale applies to the whole timeline.
          if VinylFixConfig.FixSpeed() && definition.looping && itemCount == 1
            && spin.numberOfFullRotations > 0.0 && duration > 0.0 {
            definition.timeScale = VinylFixConfig.TargetRPM() * duration / (spin.numberOfFullRotations * 60.0);
            VinylFixService.MakeLinear(spin);
          }

          if VinylFixConfig.DebugLog() {
            VinylFixService.Log(s"Spin track '\(NameToString(definition.name))': axis \(EnumInt(spin.axis)), \(spin.numberOfFullRotations) turn(s) per \(duration)s, reverse=\(spin.reverseDirection), timeScale=\(definition.timeScale)");
          }

          patched += 1;
        }
        j += 1;
      }
      animations[i] = definition;
      i += 1;
    }
    animator.animations = animations;
    return patched;
  }

  // An eased spin speeds up and slows down on every loop; a record should not.
  private static func MakeLinear(spin: ref<gameTransformAnimation_RotateOnAxis>) {
    let movement = spin.movement as gameTransformAnimation_Movement_PredefinedFunction;
    if IsDefined(movement) {
      let easing = movement.function;
      easing.transitionType = ETransitionType.EET_Linear;
      movement.function = easing;
    }
  }

  private cb func OnSectorLoaded(event: ref<ResourceEvent>) {
    let sector = event.GetResource() as worldStreamingSector;
    if !IsDefined(sector) {
      return;
    }

    let fullRotationTime = 60.0 / VinylFixConfig.TargetRPM();
    for node in sector.GetNodes() {
      let rotating = node as worldRotatingMeshNode;
      if IsDefined(rotating) && VinylFixTargets.IsRecordMesh(ResourceAsyncRef.GetPath(rotating.mesh)) {
        // A node already at the target speed has been patched before.
        if VinylFixConfig.FixSpeed() && AbsF(rotating.fullRotationTime - fullRotationTime) < 0.001 {
          continue;
        }

        if VinylFixConfig.FixDirection() {
          rotating.reverseDirection = !rotating.reverseDirection;
        }
        if VinylFixConfig.FixSpeed() {
          rotating.fullRotationTime = fullRotationTime;
        }

        if VinylFixConfig.DebugLog() {
          VinylFixService.Log(s"Patched rotating record node: axis \(EnumInt(rotating.rotationAxis)), reverse=\(rotating.reverseDirection), fullRotationTime=\(rotating.fullRotationTime)s");
        }
      }
    }
  }

  private static func Log(text: String) {
    ModLog(n"VinylFix", text);
  }
}
