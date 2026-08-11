# Existing Script Migration Map

This map fixes the initial disposition of every `.as` file that exists under `Script/Examples/**` or directly under `Script/Tests/` at the 2026-08-11 planning baseline. It is a migration contract, not evidence that the move has been implemented.

The current inventory is 37 project scripts: 27 examples, 9 direct test files, and the cooked `Script/Game/Example_Actor.as` fixture. The cooked fixture is listed separately because it is not part of either migration set.

The new BlueprintLibraries and Bindings tracks do not change these dispositions. They may reuse an existing example's idea only through a distinct workflow and cross-link; current example bodies still migrate to their dominant domain owner below.

## Disposition Meanings

| Disposition | Required implementation behavior |
|---|---|
| `Migrate` | Move and rewrite the useful scenario into the named theme target; update live references in the same task. |
| `Split` | Divide a mixed or overly broad source across the named focused targets; retire the old path after all live references move. |
| `RetireAsRedundant` | Preserve any unique guidance in the new corpus/catalogue, prove no live consumer remains, then remove the old file. |
| `KeepSpecialPurpose` | Keep the file at its current path because it serves a bounded infrastructure or framework-reference role; do not catalogue it as normal corpus unless explicitly stated. |
| `OutOfScope` | Leave the optional/integration fixture unchanged and exclude it from core completion. |

## Current `Script/Examples/**` Files

| Current file | Disposition | Planned corpus target(s) | Migration intent and reference handling |
|---|---|---|---|
| `Script/Examples/Core/Example_AccessSpecifiers.as` | `Split` | `Script/Language/ClassDesign.as`; `Script/Reflection/SpecifierReference.as` | Separate script access control from reflected property/function exposure. Update `Documents/Knowledges/ZH/Syntax_AccessSpecifiers.md` references after the replacement files exist. |
| `Script/Examples/Core/Example_Array.as` | `Split` | `Script/Containers/InventoryArray.as`; `Script/Containers/ArrayIteration.as`; `Script/Containers/ArrayMutation.as` | Replace the general API sampler with inventory workflows and focused iteration/mutation examples. Update Standalone and TArray guide paths. |
| `Script/Examples/Core/Example_BehaviorTreeNodes.as` | `KeepSpecialPurpose` | Current path | AI/BehaviorTree is not an approved v1 root theme and requires AI module/asset context. Keep it as an uncatalogued legacy special-purpose sample until an AI-focused OpenSpec owns it. |
| `Script/Examples/Core/Example_CharacterInput.as` | `Migrate` | `Script/Input/LegacyInputBinding.as` | Preserve character/controller input setup while stating World, controller, and input-device prerequisites. |
| `Script/Examples/Core/Example_ConstructionScript.as` | `Migrate` | `Script/Actor/ConstructionAndDefaults.as` | Turn construction/default-component code into one observable component-hierarchy workflow. |
| `Script/Examples/Core/Example_Delegates.as` | `Split` | `Script/Delegates/SingleCastDelegates.as`; `Script/Delegates/MulticastEvents.as`; `Script/Delegates/ReflectedDelegateReceivers.as` | Separate bind/execute/unbind, multicast payload, and reflected receiver contracts. Update the delegate knowledge-guide links. |
| `Script/Examples/Core/Example_Enum.as` | `Migrate` | `Script/Language/EnumWorkflows.as` | Replace enumerator listing with selection, switch, conversion, and reflected-enum behavior. |
| `Script/Examples/Core/Example_FormatString.as` | `Split` | `Script/Language/StringInterpolation.as`; `Script/Text/TextFormatting.as` | Separate language interpolation syntax from FText/number-formatting behavior and culture limits. |
| `Script/Examples/Core/Example_Functions.as` | `Split` | `Script/Language/FunctionContracts.as`; `Script/Reflection/GlobalFunctions.as` | Separate ordinary functions/arguments/returns from reflected global UFUNCTION publication. |
| `Script/Examples/Core/Example_FunctionSpecifiers.as` | `Migrate` | `Script/Reflection/BlueprintFunctionSurface.as` | Demonstrate callable, pure, event, and override effects through observable reflected behavior. |
| `Script/Examples/Core/Example_Map.as` | `Split` | `Script/Containers/LookupMap.as`; `Script/Containers/MapIteration.as`; `Script/Containers/StructuredMapValues.as` | Replace the broad sampler with lookup, mutation/iteration, and structured-value workflows. Update the active TMap knowledge-guide link. |
| `Script/Examples/Core/Example_Math.as` | `Split` | `Script/Math/ScalarMath.as`; `Script/Math/VectorOperations.as`; `Script/Math/RotationWorkflows.as`; `Script/Math/TransformWorkflows.as` | Preserve only verified operations, split by value family, and add Bind-derived AS API tables. |
| `Script/Examples/Core/Example_MixinMethods.as` | `Migrate` | `Script/Language/MixinFunctions.as` | Keep a receiver-oriented use case with exact supported syntax and update both active mixin guides. |
| `Script/Examples/Core/Example_MovingObject.as` | `Split` | `Script/Actor/ActorLifecycle.as`; `Script/Actor/ActorTransforms.as` | Separate lifecycle callbacks from transform movement and give both observable state. |
| `Script/Examples/Core/Example_Overlaps.as` | `Split` | `Script/Actor/ActorOverlapWorkflow.as`; `Script/Component/PrimitiveComponentCollision.as` | Separate actor-level reaction from primitive-component configuration and delegate payload. |
| `Script/Examples/Core/Example_PropertySpecifiers.as` | `Migrate` | `Script/Reflection/SpecifierReference.as` | Consolidate property metadata with access/function specifiers and demonstrate actual reflection/Blueprint effects. |
| `Script/Examples/Core/Example_Struct.as` | `Split` | `Script/Language/StructValues.as`; `Script/Reflection/ReflectedStruct.as` | Separate pure value semantics from USTRUCT/UPROPERTY reflection and copy behavior. |
| `Script/Examples/Core/Example_Timers.as` | `Split` | `Script/Timers/TimerScheduling.as`; `Script/Timers/TimerPauseResume.as`; `Script/Timers/TimerCleanup.as`; `Script/Timers/TimerOwnerLifetime.as` | Split scheduling, pause/resume, invalidation, and owner-lifetime behavior; use deterministic time in tests. |
| `Script/Examples/Core/Example_Widget_UMG.as` | `Split` | `Script/UI/UserWidgetLifecycle.as`; `Script/UI/BoundWidgetFields.as` | Separate asset-free lifecycle/property behavior from the Widget Blueprint `BindWidget` prerequisite. |
| `Script/Examples/EnhancedInput/Example_EI_Component.as` | `Migrate` | `Script/Input/EnhancedInputActions.as` | Consolidate action value, trigger event, binding, and callback behavior around a coherent pawn workflow. |
| `Script/Examples/EnhancedInput/Example_EI_InterfaceCall.as` | `Migrate` | `Script/Input/InputMappingContexts.as` | Remove implementation-phase commentary and teach the supported subsystem-interface mapping-context workflow and its LocalPlayer requirement. |
| `Script/Examples/EnhancedInput/Example_EI_PlayerController.as` | `Split` | `Script/Input/EnhancedInputActions.as`; `Script/Input/InputMappingContexts.as` | Merge duplicate action-binding material and retain controller-owned mapping setup only where it adds a distinct workflow. |
| `Script/Examples/Extended/Example_BlueprintSubclass.as` | `Migrate` | `Script/Inheritance/BlueprintSubclassing.as` | Preserve the script-parent/Blueprint-child workflow with explicit asset/editor prerequisites and asserted dispatch evidence. |
| `Script/Examples/Extended/Example_ConsoleWorkflow.as` | `Split` | `Script/Language/NamespacesAndGlobals.as`; `Script/Diagnostics/Logging.as` | The current file does not demonstrate console commands or CVars. Rehome its const-global/state pattern and logging separately instead of preserving a misleading title. |
| `Script/Examples/Extended/Example_InterfaceDispatch.as` | `Split` | `Script/Inheritance/VirtualDispatch.as`; `Script/Interface/InterfaceDispatch.as` | The current code is class inheritance, not an AS interface. Preserve the health-dispatch idea under real virtual dispatch and build the interface target from actual interface evidence. |
| `Script/Examples/Extended/Example_NetworkReplication.as` | `Split` | `Script/Networking/ReplicatedState.as`; `Script/Networking/RepNotifyState.as`; `Script/Networking/ServerRpc.as`; `Script/Networking/ClientRpc.as`; `Script/Networking/MulticastRpc.as`; `Script/Networking/ValidatedServerRpc.as`; `Script/Networking/AuthorityAndRoles.as` | Split declaration families and distinguish compile evidence from real network delivery. Update live planning/guide references only after replacement targets exist. |
| `Script/Examples/Extended/Example_SubsystemLifecycle.as` | `Split` | `Script/Subsystems/EngineSubsystems.as`; `Script/Subsystems/GameInstanceSubsystems.as`; `Script/Subsystems/WorldSubsystems.as`; `Script/Subsystems/LocalPlayerSubsystems.as` | Separate lifetime/context rules, keep exact AS-facing lifecycle names, and update the runtime-lifecycle guide reference. |

## Current Direct `Script/Tests/*.as` Files

These files are not assumed to be runnable `UAngelscriptTestSuite` tests merely because they live under `Script/Tests`. The implementation must first determine whether each path is a framework suite, a source fixture, or optional-plugin input.

| Current file | Disposition | Replacement or stable role | Consumer and removal rule |
|---|---|---|---|
| `Script/Tests/Test_ActorLifecycle.as` | `RetireAsRedundant` | `Script/Tests/Actor/Test_ActorLifecycle.as` | Current arbitrary `FPhase2ActorLifecycleProbe::Step()` provides no lifecycle coverage. Delete after the themed suite is discovered and no path consumer exists. |
| `Script/Tests/Test_Enums.as` | `RetireAsRedundant` | `Script/Tests/Language/Test_EnumWorkflows.as` | Replace constant-return source with enum behavior assertions; verify no active path consumer before removal. |
| `Script/Tests/Test_ExampleActorFixture.as` | `Migrate` | A meaningful file-backed source selected from the first implemented theme, with the exact new path recorded in the hot-reload test | `AngelscriptNativeScriptHotReloadTests.cpp` currently loads this exact path in `Phase2C`. Change that consumer first, preserve full/soft-reload coverage, then remove the placeholder. |
| `Script/Tests/Test_GameplayTags.as` | `OutOfScope` | Current path | Optional GameplayTags legacy input is excluded from core completion. Leave it unchanged; a GameplayTags-specific change may relocate or replace it. |
| `Script/Tests/Test_Handles.as` | `RetireAsRedundant` | `Script/Tests/Language/Test_TypeAndHandleSemantics.as`; `Script/Tests/Objects/Test_StrongObjectReferences.as` | Replace the constant with value/handle and UObject identity behavior; remove only after source scans show no active consumer. |
| `Script/Tests/Test_Inheritance.as` | `RetireAsRedundant` | `Script/Tests/Inheritance/Test_ClassInheritance.as`; `Script/Tests/Inheritance/Test_VirtualDispatch.as` | Replace arithmetic masquerading as inheritance with base/derived state and dispatch assertions. |
| `Script/Tests/Test_MathNamespace.as` | `RetireAsRedundant` | `Script/Tests/Math/Test_ScalarMath.as` | Replace `FPhase2MathFixture` with actual `Math::` behavior and boundary assertions. |
| `Script/Tests/Test_ReflectedScriptSuites.as` | `KeepSpecialPurpose` | Current path | Retain as the one-stop reflected test-framework authoring reference. Theme tests may reuse its conventions but must not turn it into a miscellaneous behavior suite. |
| `Script/Tests/Test_SystemUtils.as` | `RetireAsRedundant` | `Script/Tests/Diagnostics/Test_PlatformQueries.as` and/or the audited stable system-utility owner | Replace `FPhase2SystemUtilsFixture::Read()` only after the bind audit identifies the real supported user capability; do not invent a generic utility test to preserve the name. |

## Cooked Fixture

| Current file | Disposition | Contract |
|---|---|---|
| `Script/Game/Example_Actor.as` | `KeepSpecialPurpose` | Keep the path and script parent stable because cooked content depends on it. It is not part of the 27-example migration and is not a disposable corpus sample. |

## Migration Completion Checks

- All 27 example rows and all 9 direct test rows have been applied or explicitly retained with the disposition above.
- No old path is removed before `rg` confirms all active code, tool, Standalone, and non-legacy guide consumers have moved.
- Historical files under `Documents/Plans/**` and archived OpenSpec records are not rewritten solely to update old paths.
- `Script/README.md` catalogues only approved corpus targets; special-purpose and out-of-scope fixtures are documented separately from the normal corpus table.
- Git history preserves moves where practical, but semantic rewrites are reviewed against the target matrix rather than judged by rename detection.
