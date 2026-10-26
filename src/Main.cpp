#include <RED4ext/RED4ext.hpp>
#include <RED4ext/Scripting/Natives/Generated/game/TransformAnimatorComponent.hpp>
#include <RED4ext/Scripting/Natives/Generated/game/TransformAnimation_Movement_PredefinedFunction.hpp>
#include <RED4ext/Scripting/Natives/Generated/game/TransformAnimation_RotateOnAxis.hpp>

// Record player animators keep their animation definitions and track items
// inline. Reading them from redscript copies the track items (ISerializable
// objects), and destroying those copies breaks the originals, which crashes
// the game. This plugin edits the component's data in place instead.

namespace
{
RED4ext::v1::PluginHandle g_handle = nullptr;
const RED4ext::v1::Sdk* g_sdk = nullptr;

template<typename... Args>
void Log(const char* aFormat, Args... aArgs)
{
    if (g_sdk)
    {
        g_sdk->logger->InfoF(g_handle, aFormat, aArgs...);
    }
}

bool IsA(RED4ext::ISerializable* aObject, const char* aClassName)
{
    if (!aObject)
    {
        return false;
    }
    auto* cls = RED4ext::CRTTISystem::Get()->GetClass(aClassName);
    return cls && aObject->GetType()->IsA(cls);
}

// VinylFix_PatchAnimator(animator: ref<gameTransformAnimatorComponent>,
//                        fixDirection: Bool, fixSpeed: Bool, targetRPM: Float) -> Int32
//
// Flips every RotateOnAxis track on a looping animation (the platter spin).
// One-shot animations, like the tonearm swinging onto the record, are left
// alone. On a timeline that holds only the spin, also sets timeScale so one
// turn takes 60 / targetRPM seconds, and makes the movement linear. Returns
// the number of spin tracks patched.
void PatchAnimator(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, int32_t* aOut, int64_t a4)
{
    RED4EXT_UNUSED_PARAMETER(aContext);
    RED4EXT_UNUSED_PARAMETER(a4);

    RED4ext::Handle<RED4ext::IScriptable> handle;
    bool fixDirection = false;
    bool fixSpeed = false;
    float targetRPM = 0.0f;
    RED4ext::GetParameter(aFrame, &handle);
    RED4ext::GetParameter(aFrame, &fixDirection);
    RED4ext::GetParameter(aFrame, &fixSpeed);
    RED4ext::GetParameter(aFrame, &targetRPM);
    aFrame->code++; // skip ParamEnd

    int32_t patched = 0;
    if (handle && IsA(handle.instance, RED4ext::game::TransformAnimatorComponent::NAME))
    {
        auto* animator = reinterpret_cast<RED4ext::game::TransformAnimatorComponent*>(handle.instance);
        for (auto& definition : animator->animations)
        {
            if (!definition.looping)
            {
                continue;
            }

            auto& items = definition.timeline.items;
            for (auto& item : items)
            {
                if (!IsA(item.impl.instance, RED4ext::game::TransformAnimation_RotateOnAxis::NAME))
                {
                    continue;
                }
                auto* spin = reinterpret_cast<RED4ext::game::TransformAnimation_RotateOnAxis*>(item.impl.instance);

                if (fixDirection)
                {
                    spin->reverseDirection = !spin->reverseDirection;
                }

                // timeScale applies to the whole timeline, so only retime one
                // that holds nothing but the spin.
                if (fixSpeed && items.size() == 1 && targetRPM > 0.0f &&
                    spin->numberOfFullRotations > 0.0f && item.duration > 0.0f)
                {
                    definition.timeScale = targetRPM * item.duration / (spin->numberOfFullRotations * 60.0f);

                    // An eased spin speeds up and slows down on every loop.
                    if (IsA(spin->movement.instance,
                            RED4ext::game::TransformAnimation_Movement_PredefinedFunction::NAME))
                    {
                        auto* movement = reinterpret_cast<RED4ext::game::TransformAnimation_Movement_PredefinedFunction*>(
                            spin->movement.instance);
                        movement->function.transitionType = RED4ext::ETransitionType::EET_Linear;
                    }
                }

                Log("Spin track '%s': axis %d, %.2f turn(s) per %.2fs, looping=%d, reverse=%d, timeScale=%.4f",
                    definition.name.ToString(), static_cast<int>(spin->axis), spin->numberOfFullRotations,
                    item.duration, definition.looping, spin->reverseDirection, definition.timeScale);
                ++patched;
            }
        }
    }

    if (patched == 0)
    {
        Log("No looping spin track on animator, left unchanged");
    }

    if (aOut)
    {
        *aOut = patched;
    }
}

void PostRegisterTypes()
{
    auto* rtti = RED4ext::CRTTISystem::Get();
    auto* func = RED4ext::CGlobalFunction::Create("VinylFix_PatchAnimator", "VinylFix_PatchAnimator", &PatchAnimator);
    func->flags = {.isNative = true, .isStatic = true};
    func->AddParam("handle:gameTransformAnimatorComponent", "animator");
    func->AddParam("Bool", "fixDirection");
    func->AddParam("Bool", "fixSpeed");
    func->AddParam("Float", "targetRPM");
    func->SetReturnType("Int32");
    rtti->RegisterFunction(func);
}
} // namespace

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason,
                                        const RED4ext::v1::Sdk* aSdk)
{
    if (aReason == RED4ext::v1::EMainReason::Load)
    {
        g_handle = aHandle;
        g_sdk = aSdk;
        RED4ext::CRTTISystem::Get()->AddPostRegisterCallback(PostRegisterTypes);
    }
    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* aInfo)
{
    aInfo->name = L"VinylFix";
    aInfo->author = L"La2o";
    aInfo->version = RED4EXT_V1_SEMVER(1, 0, 0);
    // Only RTTI is used, no game addresses, so any game version works.
    aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_INDEPENDENT;
    aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_1;
}
