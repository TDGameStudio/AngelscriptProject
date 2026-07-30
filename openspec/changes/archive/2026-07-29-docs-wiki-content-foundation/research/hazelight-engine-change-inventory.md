# Hazelight Engine Change Inventory

Captured: 2026-07-25

## What the existing report proves

`Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt` is a Beyond Compare folder report generated on 2026-03-12. It compares `Engine\Source` beneath a Hazelight engine checkout and a release-engine checkout and visibly marks thirteen engine-source leaf files as changed.

It proves that those paths differed in that local comparison. It does **not** prove:

- which Git revisions were compared;
- that the list is exhaustive;
- which individual lines were AngelScript changes rather than UE-version drift;
- that the current `angelscript-master` branch has the same patch set;
- that a local plugin replacement is behaviorally equivalent.

The future Wiki should retain the report as historical path evidence and derive semantic claims from pinned source.

## Thirteen visible engine-source leaf files

The “current Hazelight evidence” column below was rechecked against private source commit `f459e6322f63deef8d345f1c1624734cc22747e3`. “Local direction” describes what a later comparison page must trace; it is not a completed parity verdict.

| Reported engine file | Current Hazelight evidence | Comparison family | Local direction | Confidence |
|---|---|---|---|---|
| `Runtime/CoreUObject/Public/Serialization/ArchiveReplaceObjectRef.h` | Replacement checks recognize `bIsScriptClass` and null incompatible replacement instances. | Reload/reference replacement | Trace plugin ClassReloadHelper/reinstancing behavior and incompatible-property tests; do not infer equivalence from the absence of an engine patch. | supported |
| `Runtime/CoreUObject/Public/UObject/Class.h` | Adds runtime container-size behavior, script-struct/ops hooks, runtime UFunction calls, script UClass fields, function-map access, and script object lifecycle hooks. | Class/struct generation, dispatch, GC/reload | Compare `UASClass`, `UASStruct`, `UASFunction`, ClassGenerator, reference schema, native thunk, and stock-engine APIs. | verified |
| `Runtime/CoreUObject/Public/UObject/CoreNative.h` | Defines type-erased method/function pointer machinery used by generated UHT records. | Generated function binding | Compare the local UHTTool shards, FunctionCallers, NativeRuntimeLinked and NativeModuleFunctionAddress bridges. | verified |
| `Runtime/CoreUObject/Public/UObject/EnumProperty.h` | Makes enum internals available where Hazelight binding/generation needs them. | Type/property binding | Identify the current local enum-property API path and tests; do not require engine exposure unless evidence shows a gap. | supported |
| `Runtime/CoreUObject/Public/UObject/ObjectMacros.h` | Defines `EAngelscriptPropertyFlags`: C++ const/ref, enum-as-byte, runtime-generated, world-context, and const-template-arg. | UHT/property semantics | Compare local `IsAngelscriptGenerated`, `IsAngelscriptWorldContextProperty`, metadata, signature policy, and container propagation. | verified |
| `Runtime/CoreUObject/Public/UObject/Script.h` | Adds `FUNC_RuntimeGenerated`. | Script UFunction dispatch | Compare Hazelight ScriptCore dispatch with local `FUNC_Native` plus UASFunction thunk/dispatch. | verified |
| `Runtime/CoreUObject/Public/UObject/UnrealType.h` | Stores `AngelscriptPropertyFlags`, exposes a native-definition export flag, and uses runtime container size in property bounds. | Property layout/UHT/class storage | Trace local plugin-owned query/state mechanisms and stock FProperty layout constraints. | verified |
| `Runtime/CoreUObject/Public/UObject/UObjectGlobals.h` | Carries AngelScript property flags through code-generated property parameter layouts and stores generated function pointers. | UHT payload/ABI | Compare local generated payload structs, layout-version file, Runtime bridge, and tests. | verified |
| `Runtime/Engine/Classes/Engine/Blueprint.h` | Adds cached runtime-class dependencies. | Hot reload/Blueprint impact | Compare local ClassReloadHelper and BlueprintImpact ownership, invalidation, and descendant tests. | supported |
| `Runtime/Engine/Classes/Engine/CollisionProfile.h` | Exposes collision profiles to Hazelight code. | Manual binding/API exposure | Compare `Bind_CollisionProfile.cpp` behavior and public stock APIs before classifying. | provisional |
| `Runtime/Engine/Classes/GameFramework/Actor.h` | Adds a `ScriptName` for construction script, exposes reset-attachment behavior, and exposes a post-initialize delegate for script/component integration. | Actor/default component/hot reload | Compare local Actor binds, ASClass construction/finalization, default-component attachment, and reload tests. | verified |
| `Runtime/Engine/Classes/Kismet/KismetMathLibrary.h` | Marks the class `NotInAngelscript` and assigns `ScriptName = "MathLibrary"`, allowing a curated math surface instead of blind reflection. | Binding policy/naming | Compare local `Bind_FMath.cpp` and function-library/mixin policy. | verified |
| `Runtime/Engine/Classes/Kismet/KismetSystemLibrary.h` | Changes `K2_SetTimer`'s function-name argument from `FString` to `FName` and gives it the script name `SetTimer`. | API-shape divergence | Document the user-visible timer signature and local bind/mixin shape; treat it as divergence, not an automatic engine patch candidate. | verified |

## Verified current engine changes outside the visible thirteen

The thirteen-file report is not exhaustive. At current Hazelight commit `f459e6322f63deef8d345f1c1624734cc22747e3`, source markers also verify AngelScript-related changes in at least:

| Current path family | Verified role |
|---|---|
| `Runtime/CoreUObject/Private/UObject/ScriptCore.cpp` | Routes `FUNC_RuntimeGenerated` calls/events and validation through runtime UFunction hooks. |
| `Runtime/CoreUObject/Private/UObject/UObjectGlobals.cpp` | Handles script classes/CDOs/subobjects during initialization. |
| `Runtime/CoreUObject/Private/UObject/Property.cpp` | Initializes and copies `AngelscriptPropertyFlags`. |
| `Runtime/Engine/Private/Actor.cpp` | Resets inherited component attachment for script/Blueprint classes and recognizes runtime-generated properties. |
| `Editor/Kismet/Private/SMyBlueprint.cpp` | Uses runtime-generated property display names and contains an event-visibility adjustment. |
| `Editor/PropertyEditor/Private/PropertyNode.cpp` | Avoids cached addresses for runtime-generated properties and includes edit-inline/runtime-class handling. |
| `Programs/Shared/EpicGames.Core/UnrealEngineTypes.cs` | Defines the C# `EAngelscriptPropertyFlags` representation. |
| `Programs/Shared/EpicGames.UHT/**` | Reconstructs C++ signatures, emits type-erased function pointers, propagates AS-specific property flags through containers, and caches those flags. |

The 2025 change `789cb9e10450` moved AngelScript-only property semantics out of exhausted/shared `CPF_*` bits into a separate `APF_*` field across plugin, editor, CoreUObject, EpicGames.Core, and EpicGames.UHT. The 2026 follow-up `138a7e186082` added UHT input-cache copy/read/write support for that field. This is a cross-layer layout and cache contract, not a one-file binding tweak.

## Latest class/struct-generation delta

The one commit after the previous audit marker is:

| Commit | Change | Local committed observation | Documentation disposition |
|---|---|---|---|
| `f459e6322f63deef8d345f1c1624734cc22747e3` — “Mark UASClasses as Editor Only (#669)” | Editor-only modules propagate `EditorOnly` metadata to class/struct descriptors; generated `UASClass` and `UASStruct` store it and override `IsEditorOnly()`. | Local code has editor-only function/property/component handling and binding filters, but the same type-level fields/overrides were not found at `4e2e23ca16ae9f1786258fb96b09b268259b1aad`. | Add a revisioned `future-candidate` row. Any behavior adoption belongs to a separate OpenSpec with cook/editor-only tests. |

## Engine-patch family catalog

The Hazelight architecture page should group individual paths into stable families:

1. reflected native function pointers and UHT payload;
2. AS-specific property flags and code-generation cache;
3. runtime-generated UFunction dispatch/RPC validation;
4. UClass/UASClass type state and object lifecycle;
5. UScriptStruct/ICppStructOps context and lifetime;
6. CDO/subobject construction;
7. property editor and Blueprint presentation;
8. hot-reload reference replacement and component attachment;
9. selected API exposure, renaming, exclusion, or signature changes.

This family view survives file movement better than a flat patch list. The flat paths remain available as evidence and maintenance entry points.

## Publication rules

- Never present the thirteen-file table as a complete current patch set.
- Never copy private Hazelight source into a public Wiki page or source corpus.
- Prefer a small paraphrased finding plus the private source key; use public Hazelight docs only for public behavior.
- Do not turn an engine patch into a local implementation task from the comparison page.
- Re-run source inspection when Hazelight HEAD, local plugin revision, or Unreal major/minor version changes.
- A performance comparison requires a checked-in benchmark artifact; architectural intuition is not a benchmark.
