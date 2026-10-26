module VinylFix

// Record platters spin through a RotateOnAxis track in the record player's
// transform animator, or through a worldRotatingMeshNode when a record is
// placed straight into a world sector. Both are patched before they start:
// the direction is reversed and the looping spin is retimed to TargetRPM.
// Animators are patched by the VinylFix RED4ext plugin (see Native.reds),
// because reading their animations from script crashes the game.
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
        patched += VinylFix_PatchAnimator(animator, VinylFixConfig.FixDirection(), VinylFixConfig.FixSpeed(), VinylFixConfig.TargetRPM());
      }
      if VinylFixConfig.DebugLog() {
        components = components + s" \(NameToString(component.GetClassName()))";
      }
    }

    if VinylFixConfig.DebugLog() {
      if patched > 0 {
        VinylFixService.Log(s"Patched \(patched) spin track(s) on \(NameToString(entity.GetClassName()))");
      } else {
        VinylFixService.Log(s"No spin track found on \(NameToString(entity.GetClassName())), components:\(components)");
      }
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
      // PostLoad fires once per sector load, and every load deserializes
      // fresh nodes, so each node is seen exactly once.
      if IsDefined(rotating) && VinylFixTargets.IsRecordMesh(ResourceAsyncRef.GetPath(rotating.mesh)) {
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
