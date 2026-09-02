# High-risk TestSource v2 migration audit

Date: 2026-08-24  
Scope: read-only audit of the eight paths named in `high-risk-audit-brief.md`  
Evidence: current `TestSource/**/*.as`, the corresponding `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp` tests, and the Runtime script-test registry/framework.

## Executive result

The migration must not mechanically rename the current `Observe_*` functions. The audited corpus contains genuine false-positive and shallow-test paths:

- 52 files accept a spawned actor yet treat one or more `DefaultComponent` handles being null as the successful “default” result.
- `Test_InheritanceProcessEventDispatchesToChildOverride.as` claims native `ProcessEvent` coverage but its supplemental entry functions call `Actor.OnPickedUp(...)` directly.
- all 9 scoped GC stories create/release/collect/inspect in one AS callback stack; this does not prove cross-invocation or cross-frame reachability.
- 14 Gameplay timer files directly invoke the timer callback (and 4 World timer stories need explicit TimerManager phases); those direct calls must not be retained as timer execution subcases.
- 10 delegate/event files either call handlers directly or leave broadcast/unbind/destruction entirely implicit in the C++ runner.
- NewObject coverage loses object identity, exact Outer, class, name, and flags by collapsing the result to booleans.
- CDO, Blueprint CDO, spawned parent, spawned Blueprint child, existing pre-reload instance, and fresh post-reload instance are not consistently typed as distinct fixtures.
- the 209 HotReload files already contain useful retained/replaced prose, but the highest-risk 25 files do not yet have a machine-readable retained-object/replaced-surface matrix. The other 184 HotReload files need the same matrix at Medium priority.
- the four framework-discovery fixtures contain names that are part of the registry identity. Those class and method names are fixed names, not legacy names to beautify.

No product or `TestSource` file was changed by this audit.

## Severity and domain counts

Counts are unique files at the stated severity; a file with several issue kinds is counted once at its highest severity. “Audited” is the number of files in the requested path (for EdgeCases, only the 11 GC/NewObject/UObject flag/outer files requested by the brief).

| Domain | Audited | Critical | High | Medium / later contract hardening | Principal risk |
| --- | ---: | ---: | ---: | ---: | --- |
| `Bindings/UObject` | 10 | 0 | 1 | 9 | NewObject result collapsed into one bool |
| `World` | 123 | 2 | 51 | 70 | null DefaultComponents; event/timer phases; Blueprint instance identity |
| `Gameplay` | 262 | 0 | 21 | 241 | direct timer/delegate callbacks and material component null success |
| `Feature/Inheritance` | 51 | 1 | 15 | 35 | direct lifecycle/Blueprint event calls; ProcessEvent label mismatch; CDO ambiguity |
| `Definitions/UClass` | 122 | 0 | 4 | 118 | direct Tick; CDO vs ordinary instance ambiguity |
| `Language/Syntax/EdgeCases` GC/NewObject subset | 11 | 9 | 2 | 0 | GC in one call stack; Outer/flags not carried in typed observations |
| `HotReload` | 209 | 0 | 25 | 184 | retained instance/class/CDO/delegate surface not expressed as contract identity |
| `TestFramework` | 38 | 0 | 4 | 34 | discovery class/method names are externally visible registry keys |

Critical/High does not mean the other source files are migration-ready. It means the files below must be designed before bulk renaming because a mechanical conversion would preserve a false oracle.

## Contract conventions used by this map

The following conventions are part of every Critical/High row below.

1. A `CaseId` is stable data and is never used as a function name. Subcases are lower snake case.
2. Every declaration shown below is the complete AS declaration to put in the v2 function contract. Current `Observe_*`, `SurfaceNNN`, and `_Nominal` names go only into `legacySymbols`; no forwarding alias remains in source.
3. Raw values or handles are returned. Multi-value observations use typed `&out` parameters. Script code must not compare against runner-supplied `Expected*` values.
4. Each callable’s immediately attached English comment records these exact facts: `CaseId/subcase`, role, fixture identity and owner, invocation phase, concrete inputs, raw output/writeback or side effect, boundary behavior, and cleanup owner. For fixed callbacks it also says why the name is fixed.
5. World fixtures use a runner-created isolated test world. “Spawned” means the world has spawned the actor and completed component creation/registration. The runner destroys actors and tears down the world even after assertion failure.
6. UObject vectors spell out `null`, exact identity relation, exact class, exact Outer/owner, name, and relevant flags. Component vectors additionally spell out registration, owner, world, attachment, and destruction state.
7. Timer and delegate callbacks bound by `FName` keep their existing names with a non-empty `requiredNameReason`. Lifecycle overrides (`BeginPlay`, `Tick`, `EndPlay`, etc.) also keep engine-required names. These fixed names are not legacy aliases.

## Critical map

### C1 — native ProcessEvent must remain the dispatcher

File: `TestSource/Feature/Inheritance/Test_InheritanceProcessEventDispatchesToChildOverride.as`  
Final CaseId: `TS-FEAT-0177`  
Subcases: `initial_state`, `native_process_event_777`, `native_process_event_zero`.

Keep the reflected declarations exactly:

```angelscript
UFUNCTION(BlueprintEvent)
void OnPickedUp(int CollectorHash)

UFUNCTION(BlueprintOverride)
void OnPickedUp(int CollectorHash)
```

`OnPickedUp` is fixed because C++ resolves that `UFunction` and calls `ChildActor->ProcessEvent(OnPickedUpFunction, &Params)`. Remove the direct-AS-dispatch entry functions. Add raw snapshot functions only:

```angelscript
void ReadProcessEventDispatchState(
    ATestInhHealthPickup3 Actor,
    int&out ParentCallCount,
    int&out ChildCallCount,
    int&out ChildCollectorHash)
```

Typed vectors:

- `initial_state`: spawned `ATestInhHealthPickup3`; outputs `0, 0, 0`.
- `native_process_event_777`: runner calls native `ProcessEvent` with `int32 CollectorHash=777`; outputs `0, 1, 777`.
- `native_process_event_zero`: fresh actor; native `ProcessEvent` with `0`; outputs `0, 1, 0`.

Function comment facts: the snapshot does not dispatch; the runner owns `UFunction` lookup and the native call; parent must remain uncalled; actor/world cleanup is runner-owned. This is a post-native-dispatch observation, never a direct AS call.

### C2 — GC phases must cross AS invocation boundaries

All nine files below are Critical. Their current `BeginPlay` bodies perform create, release, collection, and weak-reference inspection in one call stack. The final fixture is an actor/harness holding only the explicitly contracted members; the runner invokes each phase separately and performs a final cleanup collection after destroying the fixture.

Common fixed phase declarations (specialized actor type shown per row) are:

```angelscript
UFUNCTION()
void PrepareCandidate()

UFUNCTION()
void ReleaseStrongReference()

UFUNCTION()
void RequestCollection()

UFUNCTION()
bool IsWeakReferenceValid() const
```

`RequestCollection` is present only where the AS binding itself is under test. Otherwise the runner owns GC. It must be called after `ReleaseStrongReference` has returned, and observation occurs in a later call.

| File | CaseId and subcases | Complete specialized declarations | Typed vectors / comment facts | Fixture phase and cleanup owner |
| --- | --- | --- | --- | --- |
| `Test_GCBasicReclaim.as` | `TS-LANG-GC-BASIC-RECLAIM`; `prepared`, `released`, `collected` | `void PrepareCandidate()`; `void ReleaseStrongReference()`; `bool IsWeakReferenceValid() const` | prepared `true`; released-before-GC `true`; after runner GC `false`. Candidate is `UTexture2D`, Outer transient package. | Spawn harness; three separate calls. Runner destroys harness and performs final GC. |
| `Test_GCCollectionMethods.as` | `TS-LANG-GC-COLLECTION-METHODS`; `collect_garbage_now`, `force_garbage_collection_now` | `void PrepareCollectCandidate()`; `void ReleaseCollectCandidate()`; `void RequestCollectGarbageNow()`; `bool IsCollectCandidateValid() const`; equivalent four declarations with `Force` | Both methods use fresh candidates. Valid after release/before request; invalid only in the later snapshot. Comments name the exact API invoked. | Separate invocation for each request; runner guarantees no live local and cleans both weak handles. |
| `Test_GCContainerProtection.as` | `TS-LANG-GC-CONTAINER-PROTECTION`; `array_root`, `map_root`, `released_containers` | `void PrepareContainerCandidates()`; `void ClearStrongContainers()`; `void ReadContainerCandidateValidity(bool&out ArrayValid, bool&out MapValid) const` | after GC with containers: `true,true`; after clear + later GC: `false,false`; array element class/Outer and map key `1` are contract values. | Runner calls prepare, GC, read, clear, GC, read; harness/world teardown. |
| `Test_GCCrossFrameHold.as` | `TS-LANG-GC-CROSS-FRAME-HOLD`; `after_begin_play`, `after_three_world_ticks`, `after_release` | engine-fixed `void BeginPlay()`; engine-fixed `void Tick(float DeltaSeconds)`; `void ReleaseHeldObject()`; `void ReadCrossFrameState(int32&out FrameCount, bool&out StrongValid, bool&out WeakValid) const` | after BeginPlay `0,true,true`; after three runner world ticks and runner GC `3,true,true`; after release + GC `3,false,false`. No direct `Tick` calls. | Real world tick owner; runner destroys actor/world. |
| `Test_GCIsValidCheck.as` | `TS-LANG-GC-ISVALID`; `live`, `released_before_gc`, `after_gc` | `void PrepareCandidate()`; `void ReleaseStrongReference()`; `void ReadCandidateValidity(bool&out WeakValid, bool&out RetrievedIsValid) const` | `true,true`; `true,true`; `false,false`. The second output is raw `IsValid(WeakRef.Get())`, not an OR-comparison wrapper. | Three runner phases; runner GC and teardown. |
| `Test_GCNewObjectOuterAndCollection.as` | `TS-LANG-GC-NEWOBJECT-OUTER`; `created`, `released`, `collected` | `void CreateNamedCandidate(UObject Outer, FName Name, bool bTransient)`; `void ReleaseStrongReference()`; `void ReadCandidateIdentity(UObject&out Strong, UObject&out Outer, UClass&out Class, FName&out Name, bool&out Transient, bool&out WeakValid) const` | created: exact candidate identity, Outer=`GetTransientPackage()`, class=`UTexture2D`, name `CoverageGCNewObjectOuter`, transient input reflected exactly; released-before-GC weak `true`; after GC strong null/weak false. | Runner supplies Outer and owns final GC. |
| `Test_GCRootReachability.as` | `TS-LANG-GC-ROOT-REACHABILITY`; `rooted_after_gc`, `unrooted_after_gc` | `void PrepareRootedCandidate()`; `void RemoveCandidateFromRoot()`; `bool IsRootedCandidateWeakReferenceValid() const` | rooted after later GC `true`; after remove-root and later GC `false`. | Cleanup owner is runner **and** fixture safety teardown: always call `RemoveFromRoot` if weak target remains live, including aborted cases, then GC. |
| `Test_GCStrongCycleReclaim.as` | `TS-LANG-GC-STRONG-CYCLE`; `created`, `collected` | `void CreateUnrootedCycle()`; `void ReadCycleValidity(bool&out NodeAValid, bool&out NodeBValid) const` | after creation `true,true`; after the creation call returns and runner GC runs `false,false`. Node names, classes, transient-package Outers, and mutual `Other` identity are creation facts. | No harness UPROPERTY may retain either node. Runner final GC. |
| `Test_GCWeakPtrInvalidation.as` | `TS-LANG-GC-WEAK-INVALIDATION`; `prepared`, `released`, `collected` | `void PrepareCandidate()`; `void ReleaseStrongReference()`; `bool IsWeakReferenceValid() const` | `true`, `true`, `false` across separate calls. | Runner GC between release and final read; teardown owner runner. |

### C3 — destruction/timer cleanup must be observed after TimerManager advance

These two World cases are Critical because their defining claim is “callbacks stop after owner destruction.” The current AS payload is usable, but the contract must forbid direct callback invocation and must require a real TimerManager advance after destruction.

| File | CaseId / subcases | Complete declarations | Typed vectors, phases, cleanup |
| --- | --- | --- | --- |
| `World/Actor/Test_TimerActorDestroyStopsCallbacks.as` | `TS-WORLD-TIMER-ACTOR-DESTROY`; `active_before_destroy`, `after_destroy_and_advance` | fixed `void BeginPlay()`; fixed-by-FName `void CleanupCallback()`; `void ReadDestroyTimerState(int&out CallbackCount, bool&out ActiveBeforeDestroy) const` | after BeginPlay: `0,true`; runner destroys actor, ticks world once, advances TimerManager by `0.5`, then reads `0,true` from retained safe property access used by current C++ test. Runner owns actor/world teardown. |
| `World/Component/Test_TimerDestroyedComponentStopsCallbacks.as` | `TS-WORLD-TIMER-COMPONENT-DESTROY`; `active_before_destroy`, `after_component_destroy_and_advance` | fixed-by-FName `void CallbackAfterDestroy()`; `void ConfigureTimer()`; `void DestroyTimerComponent()`; `void SnapshotDestroyedComponent()`; `void ReadDestroyedComponentTimerState(bool&out ActiveBeforeDestroy, bool&out ComponentDestroyed, int&out CallbackCount) const` | setup `true,false,0`; after destroy + TimerManager advance `true,true,0`. The runner, not an AS observer, orders destroy/advance/snapshot. Owner actor/world cleanup is runner-owned. |

## High map — DefaultComponent null false positives

The 52 files in this section are High. A parameterless AS actor declaration is a null handle; it is not evidence about a generated actor’s components. For every row, delete the null-success predicate and use the listed raw accessor declarations. Each accessor has a vector with a non-null spawned actor input and a non-null exact-class result whose owner/Outer is that actor, whose world equals the fixture world, and which is registered unless the subcase explicitly occurs after destruction. Scene attachments are checked by identity, not only by count.

Common subcase: `spawned_default_component_identity`.  
Common phase: immediately after spawn/component initialization and before the behavior under test; add an `after_begin_play` vector only for state written by BeginPlay.  
Common comment facts: declared `DefaultComponent` property name/type/specifiers, spawned fixture identity, returned handle identity, expected owner/Outer/world/registration/attachment, null input throws setup error, runner cleanup.  
CaseId rule in the table is final; accessor names are semantic and contain no old-name alias.

| File | Final CaseId | Complete accessor declaration(s) |
| --- | --- | --- |
| `Feature/Inheritance/Test_CustomComponentLifecycleSuperCalls.as` | `TS-FEAT-COMPONENT-LIFECYCLE-SUPER` | `UCoverageDerivedLifecycleSuperComponent GetLifecycleSuperProbe(ACoverageComponentLifecycleSuperActor Actor)` |
| `Feature/Inheritance/Test_CustomComponentReuseInheritanceAndInstantiation.as` | `TS-FEAT-COMPONENT-REUSE` | `UCoverageReusableDerivedComponent GetDefaultReusableComponent(ACoverageComponentReusableActor Actor)` |
| `Feature/Inheritance/Test_DefaultStatementsAffectComponentCDOs.as` | `TS-FEAT-0183` | `USphereComponent GetDefaultSphere(AFunctionalDefaultOverrideActor Actor)`; `UStaticMeshComponent GetDefaultMesh(AFunctionalDefaultOverrideActor Actor)` |
| `Gameplay/Material/Test_ScriptCompilesDynamicMaterialAPI.as` | `TS-GAMEPLAY-MATERIAL-DYNAMIC-INSTANCE` | `UStaticMeshComponent GetMaterialMesh(AFunctionalDynamicMaterialActor Actor)`; `UMaterialInstanceDynamic GetCreatedDynamicMaterial(AFunctionalDynamicMaterialActor Actor)` |
| `World/Component/Test_BoxComponent.as` | `TS-WORLD-COMPONENT-BOX` | `UBoxComponent GetBoxComponent(ACoverageSpecialBoxActor Actor)` |
| `World/Component/Test_CameraComponent.as` | `TS-WORLD-COMPONENT-CAMERA` | `USceneComponent GetCameraRoot(ACoverageSpecialCameraActor Actor)`; `UCameraComponent GetCameraComponent(ACoverageSpecialCameraActor Actor)` |
| `World/Component/Test_CapsuleComponent.as` | `TS-WORLD-COMPONENT-CAPSULE` | `UCapsuleComponent GetCapsuleComponent(ACoverageSpecialCapsuleActor Actor)` |
| `World/Component/Test_CharacterMovementComponent.as` | `TS-WORLD-COMPONENT-CHARACTER-MOVEMENT` | `UCharacterMovementComponent GetCharacterMovementComponent(ACoverageSpecialCharacterMovementActor Actor)` |
| `World/Component/Test_ComponentActivation.as` | `TS-WORLD-COMPONENT-ACTIVATION` | `UCoverageActivationComponent GetActivationComponent(ACoverageComponentActivationActor Actor)` |
| `World/Component/Test_ComponentCollisionEventDispatch.as` | `TS-WORLD-COMPONENT-COLLISION-DISPATCH` | `USphereComponent GetCollisionDispatchSphere(ACoveragePhysicsComponentCollisionEventActor Actor)` |
| `World/Component/Test_ComponentDestruction.as` | `TS-WORLD-COMPONENT-DESTRUCTION` | `UCoverageDestructionComponent GetDestructionComponent(ACoverageComponentDestructionActor Actor)` |
| `World/Component/Test_ComponentDestructionCallbacksAndState.as` | `TS-WORLD-COMPONENT-DESTRUCTION-CALLBACKS` | `UCoverageDestroyStateComponent GetDestroyStateComponent(ACoverageComponentDestructionStateActor Actor)` |
| `World/Component/Test_ComponentFinding.as` | `TS-WORLD-COMPONENT-FINDING` | `USceneComponent GetFindingRoot(ACoverageComponentFindingActor Actor)`; `USceneComponent GetFindingChildOne(ACoverageComponentFindingActor Actor)`; `USceneComponent GetFindingChildTwo(ACoverageComponentFindingActor Actor)`; `UCoverageFindingLogicComponent GetFindingLogic(ACoverageComponentFindingActor Actor)` |
| `World/Component/Test_ComponentFindingByClassAndTag.as` | `TS-WORLD-COMPONENT-FINDING-BY-CLASS-TAG` | `UCoverageFindDerivedComponent GetFirstDerivedComponent(ACoverageComponentFindingByClassAndTagActor Actor)`; `UCoverageFindDerivedComponent GetSecondDerivedComponent(ACoverageComponentFindingByClassAndTagActor Actor)` |
| `World/Component/Test_ComponentRuntimeTickIntervalControl.as` | `TS-WORLD-COMPONENT-RUNTIME-TICK-INTERVAL` | `UCoverageRuntimeTickIntervalComponent GetRuntimeTickIntervalComponent(ACoverageComponentRuntimeTickIntervalActor Actor)` |
| `World/Component/Test_ComponentTags.as` | `TS-WORLD-COMPONENT-TAGS` | `UCoverageTagsComponent GetTaggedComponent(ACoverageComponentTagsActor Actor)` |
| `World/Component/Test_ComponentTickConfigurationAndPrerequisites.as` | `TS-WORLD-COMPONENT-TICK-CONFIG` | `UCoverageTickConfigComponent GetTickConfigurationComponent(ACoverageComponentTickConfigurationActor Actor)`; `UCoverageTickDisabledComponent GetInitiallyDisabledTickComponent(ACoverageComponentTickConfigurationActor Actor)` |
| `World/Component/Test_ComponentTickDispatchIsExact.as` | `TS-WORLD-COMPONENT-TICK-DISPATCH-EXACT` | `UTestComponentLifecycleExactTickProbe GetExactTickProbe(ATestComponentLifecycleExactTick Actor)` |
| `World/Component/Test_CustomScriptComponent.as` | `TS-WORLD-COMPONENT-CUSTOM-SCRIPT` | `UCustomLogicComponent GetCustomLogicComponent(ACoverageComponentCustomScriptActor Actor)` |
| `World/Component/Test_CustomScriptSceneComponent.as` | `TS-WORLD-COMPONENT-CUSTOM-SCENE` | `UCustomSceneComponent GetCustomSceneComponent(ACoverageSpecialCustomSceneActor Actor)` |
| `World/Component/Test_DestroyComponentUnregistersRuntimeComponent.as` | `TS-WORLD-COMPONENT-DESTROY-UNREGISTER` | `UTestComponentLifecycleDestroyProbe GetDestroyProbe(ATestComponentLifecycleDestroy Actor)` |
| `World/Component/Test_EventBuiltInActorAndComponentInstances.as` | `TS-WORLD-COMPONENT-BUILTIN-EVENTS` | `USphereComponent GetBuiltInEventSphere(ACoverageEventBuiltInActor Actor)` |
| `World/Component/Test_FourLevelAttachChainResolves.as` | `TS-WORLD-COMPONENT-FOUR-LEVEL-ATTACH` | `USceneComponent GetAttachRoot(AFunctionalMultiLevelActor Actor)`; `USceneComponent GetAttachMiddle(AFunctionalMultiLevelActor Actor)`; `UStaticMeshComponent GetAttachLeafMesh(AFunctionalMultiLevelActor Actor)`; `UPointLightComponent GetAttachDeepLight(AFunctionalMultiLevelActor Actor)` |
| `World/Component/Test_GetAllComponents.as` | `TS-WORLD-COMPONENT-GET-ALL` | `void ReadDeclaredComponentFamily(ATestActorGetAllComponents Actor, UTestCompA&out CompA, UTestCompB&out CompB, UTestCompB&out CompB2, UTestCompDerivedB&out DerivedB, UTestCompDerivedB&out DerivedB2, UBillboardComponent&out Billboard, UBillboardComponent&out Billboard2)` |
| `World/Component/Test_GetComponent.as` | `TS-WORLD-COMPONENT-GET-ONE` | `void ReadGetComponentFixture(ATestActorGetComponent Actor, USceneComponent&out Root, UStaticMeshComponent&out Mesh, UBillboardComponent&out Billboard)` |
| `World/Component/Test_GetOrCreateComponent.as` | `TS-WORLD-COMPONENT-GET-OR-CREATE` | `USceneComponent GetOrCreateRootComponent(ATestActorGetOrCreateComponent Actor)` |
| `World/Component/Test_HasBegunPlayTransitionsInWorld.as` | `TS-WORLD-COMPONENT-HAS-BEGUN-PLAY` | `UTestComponentLifecycleBeginPlayProbe GetBeginPlayProbe(ATestComponentLifecycleHasBegunPlay Actor)` |
| `World/Component/Test_InterfaceComponentAndInput.as` | `TS-WORLD-COMPONENT-INTERFACE-INPUT` | `UTestActorInterfaceRootComponent GetInterfaceRootComponent(ATestActorInterfaceComponentAndInput Actor)`; `UTestActorInterfaceExtraComponent GetInterfaceExtraComponent(ATestActorInterfaceComponentAndInput Actor)` |
| `World/Component/Test_MultipleShapeComponents.as` | `TS-WORLD-COMPONENT-MULTIPLE-SHAPES` | `void ReadShapeComponents(ACoverageSpecialMultipleShapesActor Actor, UCapsuleComponent&out Capsule, UBoxComponent&out Box, USphereComponent&out Sphere)` |
| `World/Component/Test_NameAndClassFilteringAreStrict.as` | `TS-WORLD-COMPONENT-NAME-CLASS-FILTER` | `void ReadNameClassFilterComponents(ATestActorComponentManagementNameClassFilter Actor, USceneComponent&out Root, UStaticMeshComponent&out Mesh)` |
| `World/Component/Test_PrimitiveCollisionChannelMatrixReadback.as` | `TS-WORLD-PRIMITIVE-COLLISION-CHANNEL-MATRIX` | `UStaticMeshComponent GetCollisionChannelMesh(ACoveragePrimitiveCollisionChannelMatrixActor Actor)` |
| `World/Component/Test_PrimitiveCollisionConfigurationReadback.as` | `TS-WORLD-PRIMITIVE-COLLISION-CONFIG` | `USphereComponent GetCollisionConfigurationSphere(ACoveragePrimitiveCollisionConfigurationReadbackActor Actor)` |
| `World/Component/Test_PrimitiveCollisionEvents.as` | `TS-WORLD-PRIMITIVE-COLLISION-EVENTS` | `USphereComponent GetCollisionEventSphere(ACoveragePrimitiveCollisionEventsActor Actor)` |
| `World/Component/Test_PrimitiveCollisionResponse.as` | `TS-WORLD-PRIMITIVE-COLLISION-RESPONSE` | `UStaticMeshComponent GetCollisionResponseMesh(ACoveragePrimitiveCollisionResponseActor Actor)` |
| `World/Component/Test_PrimitiveHiddenInGame.as` | `TS-WORLD-PRIMITIVE-HIDDEN` | `UStaticMeshComponent GetHiddenStateMesh(ACoveragePrimitiveHiddenInGameActor Actor)` |
| `World/Component/Test_PrimitiveHitEvents.as` | `TS-WORLD-PRIMITIVE-HIT-EVENTS` | `UStaticMeshComponent GetHitEventMesh(ACoveragePrimitiveHitEventsActor Actor)` |
| `World/Component/Test_PrimitivePhysics.as` | `TS-WORLD-PRIMITIVE-PHYSICS` | `USphereComponent GetPhysicsSphere(ACoveragePrimitivePhysicsActor Actor)` |
| `World/Component/Test_PrimitivePhysicsStateReadback.as` | `TS-WORLD-PRIMITIVE-PHYSICS-STATE` | `USphereComponent GetPhysicsStateSphere(ACoveragePrimitivePhysicsStateReadbackActor Actor)` |
| `World/Component/Test_PrimitiveRendering.as` | `TS-WORLD-PRIMITIVE-RENDERING` | `UStaticMeshComponent GetRenderingMesh(ACoveragePrimitiveRenderingActor Actor)` |
| `World/Component/Test_PrimitiveTraceObjectQueryReadback.as` | `TS-WORLD-PRIMITIVE-TRACE-OBJECT-QUERY` | `USphereComponent GetTraceQuerySphere(ACoveragePrimitiveTraceObjectQueryActor Actor)` |
| `World/Component/Test_ReturnComponentsToCpp.as` | `TS-WORLD-COMPONENT-RETURN-TO-CPP` | `void ReadReturnComponentFamily(ATestActorReturnComponentsToCpp Actor, USceneComponent&out Root, UReturnComponentBase&out BaseA, UReturnComponentBase&out BaseB, UReturnComponentDerived&out DerivedA, UReturnComponentDerived&out DerivedB, UBillboardComponent&out BillboardA, UBillboardComponent&out BillboardB)` |
| `World/Component/Test_SceneComponentCompleteTransform.as` | `TS-WORLD-SCENE-COMPLETE-TRANSFORM` | `USceneComponent GetCompleteTransformRoot(ACoverageSceneComponentCompleteTransformActor Actor)` |
| `World/Component/Test_SceneComponentHierarchy.as` | `TS-WORLD-SCENE-HIERARCHY` | `void ReadSceneHierarchy(ACoverageSceneComponentHierarchyActor Actor, USceneComponent&out Root, USceneComponent&out Child1, USceneComponent&out Child2, USceneComponent&out GrandChild)` |
| `World/Component/Test_SceneComponentRelativeTransform.as` | `TS-WORLD-SCENE-RELATIVE-TRANSFORM` | `void ReadRelativeTransformComponents(ACoverageSceneComponentRelativeTransformActor Actor, USceneComponent&out Root, USceneComponent&out Child)` |
| `World/Component/Test_SceneComponentTags.as` | `TS-WORLD-SCENE-TAGS` | `void ReadSceneTagComponents(ACoverageSceneComponentTagsActor Actor, USceneComponent&out Root, USceneComponent&out Child)` |
| `World/Component/Test_SceneComponentWorldTransform.as` | `TS-WORLD-SCENE-WORLD-TRANSFORM` | `USceneComponent GetWorldTransformRoot(ACoverageSceneComponentWorldTransformActor Actor)` |
| `World/Component/Test_SpecialComponentOperations.as` | `TS-WORLD-COMPONENT-SPECIAL-OPERATIONS` | `void ReadSpecialComponents(ACoverageSpecialComponentOperationsActor Actor, USceneComponent&out Root, UArrowComponent&out Arrow, UAudioComponent&out Audio, UInputComponent&out Input)` |
| `World/Component/Test_SphereComponent.as` | `TS-WORLD-COMPONENT-SPHERE` | `USphereComponent GetSphereComponent(ACoverageSpecialSphereActor Actor)` |
| `World/Component/Test_SpringArmComponent.as` | `TS-WORLD-COMPONENT-SPRING-ARM` | `USceneComponent GetSpringArmRoot(ACoverageSpecialSpringArmActor Actor)`; `USpringArmComponent GetSpringArmComponent(ACoverageSpecialSpringArmActor Actor)` |
| `World/Component/Test_StaticMeshComponent.as` | `TS-WORLD-COMPONENT-STATIC-MESH` | `UStaticMeshComponent GetStaticMeshComponent(ACoverageSpecialStaticMeshActor Actor)` |
| `World/Component/Test_TimerComponentCallbacksRunOnOwnerWorld.as` | `TS-WORLD-TIMER-COMPONENT-OWNER-WORLD` | `UCoverageTimerRuntimeComponent GetTimerComponent(ACoverageTimerComponentOwnerActor Actor)` |
| `World/Component/Test_TimerDestroyedComponentStopsCallbacks.as` | `TS-WORLD-TIMER-COMPONENT-DESTROY` | `UCoverageTimerDestroyableComponent GetDestroyableTimerComponent(ACoverageTimerDestroyedComponentOwner Actor)` |

The accessors above do not replace each file’s behavior snapshot. They prevent the precondition itself from being inverted. Behavior values (radius, transform, count, tag, tick state, etc.) remain separate raw-return or `&out` functions with their own vectors.

## High map — direct lifecycle and callback calls

The runner must own engine dispatch. Existing callback/override names remain fixed, but no semantic test entry may invoke them directly. The final declarations below are snapshots or explicit non-engine APIs only.

| File | CaseId / subcase | Final declaration(s), vector, phase, cleanup |
| --- | --- | --- |
| `Definitions/UClass/Test_ActorLifecycle.as` | `TS-DEF-ACTOR-LIFECYCLE`; `after_world_tick` | fixed `void Tick(float DeltaTime)`; `void ReadActorLifecycleState(int&out TickCount, float&out LastDelta) const`. Runner world tick with `0.0f`; outputs exact count increment and delta. Actor/world cleanup runner-owned. |
| `Definitions/UClass/Test_ComponentLifecycle_03.as` | `TS-DEF-COMPONENT-LIFECYCLE-03`; `after_world_tick` | fixed component `void Tick(float DeltaTime)`; raw state snapshot. Never call `Comp.Tick(...)`. |
| `Feature/Inheritance/Test_BlueprintOverrideBeginPlayTickAndSuperExecute.as` | `TS-FEAT-BLUEPRINT-OVERRIDE-LIFECYCLE`; `spawn_begin_play`, `world_tick` | fixed `BeginPlay`/`Tick`; `void ReadOverrideLifecycleState(...&out...) const`. Runner begins play/ticks world; vector records child and Super counters independently. |
| `Feature/Inheritance/Test_CustomComponentLifecycleSuperCalls.as` | `TS-FEAT-COMPONENT-LIFECYCLE-SUPER`; `component_begin_play`, `world_tick_0`, `world_tick_0_025` | fixed `BeginPlay`/`Tick`; `void ReadLifecycleSuperState(ACoverageComponentLifecycleSuperActor Actor, int&out BaseBeginPlayCount, int&out DerivedBeginPlayCount, int&out BaseTickCount, int&out DerivedTickCount, int&out LastDeltaMillis)`. No direct calls; DefaultComponent non-null vector applies. |
| `Feature/Inheritance/Test_CustomComponentReuseInheritanceAndInstantiation.as` | `TS-FEAT-COMPONENT-REUSE`; `after_component_begin_play` | fixed component `BeginPlay`; `void ReadReusableComponentState(...&out...)`. Runner begins play in world; it does not invoke the override on a local component. |
| `Feature/Inheritance/Test_InheritsTick.as` | `TS-FEAT-INHERITS-TICK`; `after_world_tick` | fixed `Tick`; raw parent/child counter snapshot; runner dispatch only. |
| `Feature/Inheritance/Test_MultiLevelInheritanceLifecycle.as` | `TS-FEAT-MULTILEVEL-LIFECYCLE`; `after_begin_play`, `after_world_tick`, `instance_isolation` | fixed `BeginPlay`/`Tick`; `void ReadMultiLevelLifecycleState(...&out...)`. Use two separately spawned actors for isolation, never two null/local handles with direct calls. |
| `Feature/Inheritance/Test_OverrideChain.as` | `TS-FEAT-OVERRIDE-CHAIN`; `after_world_tick` | fixed `Tick`; raw per-level counter/order snapshot. |
| `Feature/Inheritance/Test_BlueprintOverrideNativeActorEventParameterMatrix.as` | `TS-FEAT-NATIVE-ACTOR-EVENT-MATRIX`; `native_reset`, `native_overlap`, `native_end_play_destroy` | keep fixed native override names. Remove direct `ActorBeginOverlap`/`ActorEndOverlap` entries. C++/world dispatches native events; snapshot returns each counter/reason/transform score. |
| `Feature/Inheritance/Test_NativeUFunctionCanBeInvoked.as` | `TS-FEAT-0169`; `native_console_invoke_77`, `native_console_invoke_zero` | fixed reflected `void ReceiveNativeValue(int Value)` because C++ invokes it by name; `void ReadNativeInvocationState(ATestScriptActorNativeUFunctionCanBeInvoked Actor, int&out InvokeCount, int&out LastValue)`. Runner uses `CallFunctionByNameWithArguments`; vectors `(1,77)` and `(1,0)`. |
| `Feature/Inheritance/Test_InheritanceParentBlueprintEventDispatches.as` | `TS-FEAT-0175`; `world_begin_play`, `native_blueprint_event_zero` | fixed `OnPickedUp` and `BeginPlay`; raw state snapshot. If the zero boundary is kept, dispatch it through the same reflected/native path, not `Actor.OnPickedUp(0)`. |
| `Feature/Inheritance/Test_InheritanceChildOverridesBlueprintEvent.as` | `TS-FEAT-0176`; `child_world_begin_play`, `parent_native_dispatch`, `child_native_zero` | fixed `OnPickedUp`/`BeginPlay`; raw parent/child state snapshot. Each subcase uses a fresh spawned instance. |
| `Gameplay/Anim/Test_EventRepNotifyExecutesStateChange.as` | `TS-GAMEPLAY-ANIM-REPNOTIFY`; `replication_notify_87`, `replication_notify_zero` | `void SetTrackedHealthWithoutNotify(int NewHealth)` may be an explicit setup API; fixed `void OnRep_TrackedHealth()` remains reflection target; `void ReadRepNotifyState(...&out...)`. Runner invokes the UFunction/replication notify path. Do not hide a direct `OnRep` call inside `ApplyReplicatedHealth`. |

Medium follow-up with the same ruling: the container/value files that currently call `BeginPlay` merely to populate arrays/maps (`FLinearColor`, `FRotator`, `FTransform`, `FVector`, `FVector2D`, and matching EdgeCases container stories) should expose an ordinary semantic population method or use real BeginPlay. They are not permitted to keep a direct lifecycle call while claiming lifecycle execution.

## High map — timers require real TimerManager phases

For every timer row:

- callback names in the “fixed callbacks” column remain exact because `System::SetTimer(this, n"Name", ...)` resolves them by `FName`;
- callback comments say `requiredNameReason=referenced by System::SetTimer FName`; no test entry calls the callback;
- the runner starts BeginPlay/configuration, snapshots `active/paused/remaining`, advances the fixture world’s TimerManager by exact deltas, snapshots counts/state, then clears all live handles before actor/world destruction;
- floating values are raw and compared by relation/range in the vector, not pre-computed bool fields.

| File | CaseId / subcases | Fixed callbacks | Complete semantic snapshot declaration and typed vector |
| --- | --- | --- | --- |
| `Gameplay/Timer/Test_EventTimer.as` | `TS-GAMEPLAY-TIMER-EVENT`; `setup`, `paused`, `resumed`, `cleared` | `HandleTimer`, `HandleLoopTimer` | `void ReadEventTimerState(ACoverageEventTimerActor Actor, int&out SingleCount, int&out LoopCount, bool&out SinglePaused, bool&out LoopPaused)`. Vectors follow set/pause/resume/clear phases; invalid handle reports not paused. |
| `Test_TimerBasicUsage.as` | `TS-GAMEPLAY-TIMER-BASIC`; `before_deadline`, `after_single_deadline`, `after_second_loop` | `SingleShotCallback`, `LoopingCallback` | `void ReadBasicTimerState(..., int&out SingleCount, int&out LoopCount, bool&out SingleExecuted, bool&out SingleActive, bool&out LoopActive)`. Counts `0,0` before advance; `1,>=1` after real advance. |
| `Test_MultipleTimers.as` | `TS-GAMEPLAY-TIMER-MULTIPLE`; `setup`, `after_0_1`, `after_0_25`, `after_0_5` | `FastTimerCallback`, `MediumTimerCallback`, `SlowTimerCallback` | `void ReadMultipleTimerState(..., int&out FastCount, int&out MediumCount, int&out SlowCount, bool&out FastActive, bool&out MediumActive, bool&out SlowActive)`. Vectors prove staggered TimerManager firing, not three direct calls. |
| `Test_TimerDelayExecution.as` | `TS-GAMEPLAY-TIMER-DELAY`; `before_0_3`, `after_0_3`, `after_0_5`, `after_1_0` | `ShortDelayCallback`, `LongDelayCallback`, `RepeatingCallback` | raw three counts and three active states; exact phase deltas determine which callbacks may fire. |
| `Test_TimerImmediateExecution.as` | `TS-GAMEPLAY-TIMER-IMMEDIATE`; `setup`, `after_0_001` | `ImmediateCallback` | `void ReadImmediateTimerState(..., int&out Count, bool&out Active, float&out Remaining)`. setup count 0, remaining `[0,0.01]`; after advance count 1 and inactive. |
| `Test_TimerManagement.as` | `TS-GAMEPLAY-TIMER-MANAGEMENT`; `set`, `pause_and_advance`, `resume_and_advance`, `clear_and_advance` | `ManagedCallback` | raw count/active/paused. Paused advance leaves count unchanged; resumed advance increments; clear advance leaves it unchanged. |
| `Test_TimerClearThenReuseHandleVariable.as` | `TS-GAMEPLAY-TIMER-CLEAR-REUSE`; `first_set`, `first_cleared`, `second_set`, `second_fired` | `FirstCallback`, `SecondCallback` | raw first/second counts, handle validity/active, first/second remaining. Identity is the handle generation, not merely a bool named “reused.” |
| `Test_TimerDynamicFunctionNameReflectionLifecycle.as` | `TS-GAMEPLAY-TIMER-DYNAMIC-NAME`; `configure`, `pause`, `resume`, `fire`, `clear` | `DynamicCallback` | keep `bool ConfigureDynamicTimer(FName CallbackName, float DelaySeconds, bool bLooping)`, `bool PauseDynamicTimer()`, `bool ResumeDynamicTimer()`, `bool ClearDynamicTimer()`; add `void ReadDynamicTimerState(...&out...)`. Vector uses `n"DynamicCallback",0.5,true`; callback count changes only after TimerManager advance. |
| `Test_TimerHandlePauseUnpauseAndClear.as` | `TS-GAMEPLAY-TIMER-HANDLE-STATE`; `set`, `pause`, `unpause`, `clear` | `NoopTimerCallback` | `void ReadTimerHandleState(ACoverageTimerHandleActor Actor, bool&out Valid, bool&out Active, bool&out Paused)`. Delete `NoopMarksCompile`; compilation is source-shape coverage and execution is TimerManager-owned. |
| `Test_TimerRepeatedFunctionNameReplacesExistingTimer.as` | `TS-GAMEPLAY-TIMER-REPLACE-BY-NAME`; `first_set`, `replacement_set`, `replacement_fires` | `SharedCallback` | raw two-handle active/valid states, remaining, and callback count. Replacement vector proves first inactive, replacement active, then one real callback. |
| `Test_TimerUiCountdownAndAiStatePatterns.as` | `TS-GAMEPLAY-TIMER-UI-AI`; `setup`, `after_0_1`, `countdown_to_zero`, `after_0_2` | `HidePrompt`, `AdvanceCountdown`, `UnlockAttack`, `EnterAlertState` | one `ReadUiCountdownAiTimerState(...&out...)` with typed ints/bools/handle states. Remove direct helper-call subcases; TimerManager controls each transition. |
| `Test_TimerUseCaseBuffDuration.as` | `TS-GAMEPLAY-TIMER-BUFF`; `applied`, `before_expiry`, `expired` | `RemoveSpeedBuff` | keep `void ApplySpeedBuff(float Duration)` as user API; raw buff flag/multiplier/remaining/active snapshot. Expiry comes only from TimerManager. |
| `Test_TimerUseCasePeriodicCheck.as` | `TS-GAMEPLAY-TIMER-PERIODIC-CHECK`; `healthy_tick`, `zero_health_tick`, `after_clear` | `CheckHealth` | raw health/count/active snapshot. Runner sets health through an explicit setter, advances timer, and observes clear. |
| `Test_TimerUseCaseSkillCooldown.as` | `TS-GAMEPLAY-TIMER-SKILL-COOLDOWN`; `first_use`, `blocked_second_use`, `expiry`, `reuse_after_expiry` | `OnCooldownComplete` | keep ordinary API `void UseSkill()`; raw cooldown/count/remaining/active snapshot. The completion callback is never called directly. |
| `World/Actor/Test_TimerDelayedSpawnUseCaseRunsFromWorldTimer.as` | `TS-WORLD-TIMER-DELAYED-SPAWN`; `setup`, `before_deadline`, `after_deadline` | `SpawnDelayedActor` | `void ReadDelayedSpawnState(..., AActor&out SpawnedActor, int&out SpawnCount, bool&out TimerActive, float&out Remaining)`. Vector checks spawned identity/class/world only after real advance. Runner destroys both actors. |
| `World/Component/Test_TimerComponentCallbacksRunOnOwnerWorld.as` | `TS-WORLD-TIMER-COMPONENT-OWNER-WORLD`; `setup`, `running`, `paused_advance`, `cleared` | `ComponentCallback` | keep configure/pause/clear APIs; `void ReadComponentTimerState(..., int&out Count, bool&out Active, bool&out Paused)`. World identity is exact owner world; paused advance leaves count unchanged. |

The two Critical destroy cases are specified in C3 and occur before the remaining timer batch.

## High map — delegates require broadcast and cleanup

For each row, current handler names are fixed because `AddUFunction`/`BindUFunction` stores those names. The runner creates publisher and receiver fixtures, invokes the real native/event `Broadcast`, snapshots raw counts/payload, then removes bindings or destroys publisher/receiver before teardown. Direct handler calls are deleted. Cleanup is a required final phase even if the owning UObject would eventually be collected.

| File | CaseId / subcases | Complete contract declarations and typed vectors |
| --- | --- | --- |
| `Gameplay/Widget/Test_AdditionalWidgetDynamicEventsInvokeScriptHandlers.as` | `TS-GAMEPLAY-WIDGET-ADDITIONAL-EVENTS`; `bound`, `broadcast_values`, `empty_selection`, `unbound` | keep `void Bind(UEditableText Editable, USlider Slider, UComboBoxString Combo)` and fixed handlers; add `void ReadAdditionalWidgetEventState(...&out...)`. Native broadcasts yield counts `1,1,1`, text `Committed`, slider `0.625`, item `High`; empty-selection uses a separate broadcast. Runner removes dynamic bindings/destroys widgets. |
| `Gameplay/Widget/Test_EventWidgetEventInstances.as` | `TS-GAMEPLAY-WIDGET-EVENT-INSTANCES`; `bound`, `broadcast_values`, `unbound` | keep Bind/fixed handlers; raw `Click/Press/Release`, slider and text snapshot. Delete `CppBroadcastValues` direct handler calls. |
| `Gameplay/Widget/Test_WidgetDynamicEventsInvokeScriptHandlers.as` | `TS-GAMEPLAY-WIDGET-DYNAMIC-EVENTS`; `bound`, `broadcast_true_changed`, `broadcast_false`, `unbound` | keep Bind/fixed handlers; raw seven counts, checked value, text. Each vector comes from widget delegate broadcast. |
| `Gameplay/Physics/Test_CollisionEvents.as` | `TS-GAMEPLAY-PHYSICS-COLLISION-EVENTS`; `bound`, `native_hit_broadcast`, `native_overlap_broadcast`, `cleanup` | fixed `OnHit`, `OnBeginOverlap`, `OnEndOverlap`; raw counts/payload snapshot. Delete direct null-hit call; if null payload is a supported boundary, broadcast the delegate with that payload or classify it as direct-handler unit coverage under a different CaseId. |
| `Gameplay/Physics/Test_EventCollision.as` | `TS-GAMEPLAY-PHYSICS-EVENT-COLLISION`; `bound`, `begin_overlap_broadcast`, `end_overlap_broadcast`, `hit_broadcast`, `cleanup` | fixed handlers; raw counts/name snapshot. No direct `HandleBeginOverlap`. |
| `World/Actor/Test_ActorCollisionEvents.as` | `TS-WORLD-ACTOR-COLLISION-EVENTS`; `bound`, `three_native_broadcasts`, `cleanup` | fixed `OnActorHitEvent`, `OnActorBeginOverlapEvent`, `OnActorEndOverlapEvent`; `void ReadActorCollisionEventState(...&out...)`. Each count exactly 1 after C++ broadcasts. Runner clears bindings by destruction and asserts no further delivery. |
| `World/Component/Test_ComponentCollisionEventDispatch.as` | `TS-WORLD-COMPONENT-COLLISION-DISPATCH`; `bound`, `payload_broadcasts`, `cleanup` | fixed three handlers; raw counts and raw payload fields (component/actor identity, body index, sweep bool, vectors, bone name), not three aggregate “matched” booleans. |
| `World/Component/Test_EventBuiltInActorAndComponentInstances.as` | `TS-WORLD-COMPONENT-BUILTIN-EVENTS`; `bound`, `eight_broadcasts`, `cleanup` | fixed eight handler names; raw eight counts/payloads. Publisher actor and Sphere must be non-null DefaultComponents. |
| `World/Component/Test_PrimitiveCollisionEvents.as` | `TS-WORLD-PRIMITIVE-COLLISION-EVENTS`; `bound`, `begin_broadcast`, `end_broadcast`, `cleanup` | fixed two handlers; raw counts and OtherActor identity/name. |
| `World/Component/Test_PrimitiveHitEvents.as` | `TS-WORLD-PRIMITIVE-HIT-EVENTS`; `bound`, `hit_broadcast`, `cleanup` | fixed `HandleHit`; current C++ baseline that only observes count 0 is shallow. Add a native broadcast with typed `FHitResult`/normal/publisher identities and then prove count 1; teardown publisher/receiver. |

HotReload delegate runtime is covered separately below because its cleanup must also cross reload generations.

## High map — NewObject identity, Outer, name, class, and flags

| File | CaseId / subcases | Final complete declarations | Typed vectors, phase, cleanup |
| --- | --- | --- | --- |
| `Bindings/UObject/Test_Behavior_01.as` | `TS-BIND-UOBJECT-BEHAVIOR`; `named_transient`, `generated_name`, `named_non_transient`, `null_outer`, `invalid_class` | `UObject CreateObject(UObject Outer, const TSubclassOf<UObject>& Class, FName Name, bool bTransient)`; `void CreateObjectMatrix(UObject Outer, UObject&out NamedTransient, UObject&out GeneratedName, UObject&out NamedNonTransient, UObject&out NullOuterObject)`; `void CreateObjectWithInvalidClass()` | Vector records four distinct non-null identities; exact requested classes; exact Outer for first three; generated object name non-empty and not equal to named object; `RF_Transient` exactly follows input; null-Outer effective Outer is recorded rather than ignored. Invalid class is an exception vector. Runner releases handles and GC-cleans. |
| `Language/Syntax/EdgeCases/Test_GCNewObjectOuterAndCollection.as` | `TS-LANG-GC-NEWOBJECT-OUTER`; see C2 | `void CreateNamedCandidate(UObject Outer, FName Name, bool bTransient)` and `ReadCandidateIdentity(...)` from C2 | Creation identity and post-GC lifetime are separate subcases. |
| `Language/Syntax/EdgeCases/Test_UObjectFlagMutationAndTransientState.as` | `TS-LANG-UOBJECT-FLAGS`; `created`, `transactional_set`, `transactional_cleared` | `void CreateFlagObjects(UObject TransientOuter, UObject TransactionalOuter)`; `void ReadFlagObjectState(UObject&out TransientObject, UObject&out TransactionalObject, UObject&out ClearedTransactionalObject, bool&out TransientFlag, bool&out TransactionalFlag, bool&out ClearedTransactionalFlag) const` | All three object identities/classes/names/Outers are vectors; flags `true,true,false`. Actor owns the two actor-Outer objects; runner clears properties and tears down actor/world. |
| `Language/Syntax/EdgeCases/Test_UObjectOuterChainAndPathMatrix.as` | `TS-LANG-UOBJECT-OUTER-CHAIN`; `created_chain`, `path`, `released` | `void CreateOuterChain(UObject RootOuter)`; `void ReadOuterChain(UObject&out Root, UObject&out Child, UObject&out Leaf, UObject&out RootOuter, UObject&out ChildOuter, UObject&out LeafOuter, UObject&out Outermost, FString&out LeafPath) const` | Identity relations are explicit: child Outer is root, leaf Outer is child, root Outer is supplied transient package; depth `2` and exact name chain remain separate raw outputs. Runner clears leaf/child/root in that order then GC. |
| `World/Component/Test_ComponentManualNewObjectRegistration.as` | `TS-WORLD-COMPONENT-MANUAL-NEWOBJECT`; `created_unregistered`, `registered`, `activated`, `deactivated`, `destroyed` | `void CreateManualComponent()`; `void RegisterManualComponent()`; `void DestroyManualComponent()`; `void ReadManualComponentState(UCoverageManualNewObjectComponent&out Component, AActor&out Owner, UWorld&out World, bool&out Registered, bool&out Active, bool&out BeingDestroyed, int&out CustomValue) const` | Prove same component identity across phases; exact Outer/owner actor, world, transient flag, name; unregistered then registered; active then inactive; destroyed last. Runner destroys any surviving component then actor/world. |

## High map — Blueprint CDO and instance identity

The fixture kind is part of each vector. A function receiving `Actor` does not by itself prove whether the runner supplied a script CDO, Blueprint child CDO, spawned script instance, or spawned Blueprint child instance.

| File | CaseId / subcases | Final declarations and required typed fixture vectors |
| --- | --- | --- |
| `Definitions/UClass/Test_CDOHasExpectedDefaults.as` | `TS-DEF-CDO-DEFAULTS`; `script_cdo`, `spawned_script_instance`, `two_spawned_instances` | `void ReadClassDefaults(ATestScriptClassCDOHasExpectedDefaults Object, int&out Counter, bool&out Flag, FString&out Label)`. Same declaration, but vectors label exact fixture kind and identity: CDO has `RF_ClassDefaultObject`; spawned instance does not, has world/Outer level; two instances are distinct and mutations do not affect CDO or sibling. |
| `Definitions/UClass/Test_UClassUObjectDefaultObjectAndMethodDispatch.as` | `TS-DEF-0152`; `uobject_cdo`, `fresh_uobject_instance`, `instance_method_dispatch` | `void ReadPlainDataDefaults(UCoverageUClassPlainDataObject Object, int&out Counter, FString&out Label)`; keep ordinary `AddCounter`/`BuildLabel`. Never mutate the CDO in method-dispatch vectors; runner creates a fresh instance and records CDO flag/Outer separately. |
| `World/Blueprint/Test_DefaultPreservation.as` | `TS-WORLD-BLUEPRINT-DEFAULT-PRESERVATION`; `script_parent_cdo`, `blueprint_child_cdo`, `spawned_blueprint_child` | `void ReadBlueprintDefaultFields(ATestBPChildDefaultPreservationParent Object, int&out Counter, bool&out Toggle, FString&out Label)`. Vectors explicitly identify three different objects; values `23,true,"ScriptParentDefault"` on each; runner releases generated Blueprint asset/class and actors. |
| `World/Blueprint/Test_RecreateDoesNotLeakState.as` | `TS-WORLD-BLUEPRINT-RECREATE-NO-LEAK`; `first_instance_after_begin_play`, `first_instance_after_bump`, `fresh_second_instance` | keep fixed `BeginPlay`; keep ordinary `void BumpState()`; `void ReadRecreateState(ATestBPChildRecreateNoLeakParent Actor, int&out StatefulValue, int&out BeginPlayCount)`. Vectors are `(11,1)`, `(48,1)`, fresh distinct instance `(11,1)`; CDO stays `(10,0)`. Runner destroys each actor before/after recreation as the C++ scenario requires. |
| `Feature/Inheritance/Test_DefaultStatementsAffectComponentCDOs.as` | `TS-FEAT-0183`; `script_cdo_components`, `spawned_instance_components`, `instance_mutation_isolation` | component accessors from the DefaultComponent table plus `void ReadDefaultComponentValues(...&out Radius, ...&out Hidden, ...&out CastShadow, ...&out RelativeYaw)`. Both CDO template components and spawned instance components are non-null but have distinct identities/owners; mutation targets only spawned instance. |
| `Feature/Inheritance/Test_UClassDefaultInheritancePropertySurface.as` | `TS-FEAT-UCLASS-DEFAULT-INHERITANCE`; `leaf_cdo`, `spawned_leaf` | one raw field snapshot declaration. Vector explicitly marks leaf CDO vs spawned actor; tags/replication state that require world instance are never attributed to the CDO. |

The same identity rule is mandatory in the HotReload CDO/Blueprint-child scenarios below.

## High map — HotReload retained/replaced surface

### Required matrix shape

Every HotReload contract must contain a generation vector with:

- exact source version file and ordered transition;
- reload request/result (`SoftReloadOnly`, full reload, failure, discarded, etc.);
- objects captured before reload and whether each must be retained or replaced: module, `UClass`, CDO, Blueprint child class, existing instance, component, delegate receiver, function/property/struct/enum descriptor;
- old and new callable declarations and values;
- whether invoking an old object is required, forbidden, or expected to report a controlled error;
- cleanup owner for old/new modules, classes/assets, instances, rooted objects, delegates, PIE sessions, worlds, and diagnostics.

The following 25 files (9 scenarios) are High because retained runtime identity is the core oracle. Existing declarations shown are complete and must not be aliased. CaseId/subcases and vectors are final recommendations.

| Scenario files | CaseId / subcases | Complete retained declarations | Typed retained/replaced vectors and cleanup |
| --- | --- | --- | --- |
| `BlueprintDelegatePropertyReloadsAfterInstanceRuntime/Version_01..04.as` | `TS-HR-BLUEPRINT-DELEGATE-RUNTIME`; `v1_bound`, `v2_soft_body`, `v3_property_flags`, `v4_signature_full_reload` | V1–3 `delegate int FHotReloadRuntimeCompute(int Value)`; V4 `delegate int FHotReloadRuntimeCompute(int Value, int Bonus)`; fixed `BeginPlay`; exact `int HandleCompute(...)`; `int RunDelegate(int Value)` | V1 existing BP child instance: `RunDelegate(40)=41`, LastValue 40, BeginPlayCount 1. V2 same class/instance/binding, result 23/Last 20/count 1. V3 property flags replaced, result 28/24. V4 delegate/UFunction/property descriptors replaced; result 42/37; explicitly rebind new signature. Runner unbinds delegate, destroys child/asset/world, discards generations. |
| `CDOAndInstanceConsistency/Version_01..04.as` | `TS-HR-CDO-INSTANCE-CONSISTENCY`; `full_before`, `full_after_old_objects`, `full_after_fresh_objects`, `soft_before`, `soft_after_existing` | exact `int GetVersion()`, added `int GetMana()`, exact `int GetValue()` | Full: old/new UClass and CDO identities differ; old CDO Version 1 remains readable only under lease; new CDO/fresh actor Version 2/Mana 5. Soft: same class/CDO/instance identity, same Counter 5, existing `GetValue` changes 5→105. Runner records flags identifying CDO vs instance and releases old-class leases after reads. |
| `DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload/{Before,After}.as` | `TS-HR-DEFAULT-COMPONENT-HIERARCHY`; `before`, `after_existing_instance`, `after_fresh_instance` | `int GetVersion()`; component property declarations remain exact | UClass/CDO/existing actor/Root/Billboard/ReplacementBillboard identities retained on soft reload; function body replaced 1→2. Attachment and OverrideComponent metadata identical; existing and fresh components non-null/registered. Runner destroys actors/world and discards module. |
| `DelegateReceiverLifecycleBoundaryAcrossReload/{Before,After}.as` | `TS-HR-DELEGATE-RECEIVER-LIFECYCLE`; `before_live_receiver`, `before_destroyed_receiver`, `after_live_receiver`, `after_destroyed_receiver` | `event void FHotReloadLifecycleSignal(int Value)`; fixed `void HandleSignal(int Value)`; `int RunLifecycleCheck(AHotReloadDelegateRuntimeLifecycleReceiver Receiver)` | Real Broadcast only. Before live result Calls 3; after body reload live result Calls 6. Destroy receiver, broadcast again: no accumulation or controlled error exactly as C++ contract; never direct handler. Runner clears event and destroys broadcaster/receiver/world each generation. |
| `DoesNotReplayBeginPlayOnLiveActor/{Before,After}.as` | `TS-HR-NO-BEGINPLAY-REPLAY`; `before_begin_play`, `after_soft_reload_existing`, `after_soft_reload_fresh` | fixed `void BeginPlay()`; `int GetValue()` | Existing actor/class identity retained; BeginPlayCount stays 1; persistent counter retained; GetValue body changes. Fresh post-reload actor may run new BeginPlay once. Runner dispatches lifecycle, never direct call. |
| `MulticastDelegateRuntimeRunsAcrossReloads/{Before,After}.as` | `TS-HR-MULTICAST-RUNTIME`; `before_broadcast_unbind_clear`, `after_existing_actor_broadcast_unbind_clear` | `event void FHotReloadMulticastSignal(int Value)`; fixed handlers; `int RunMulticast()` | Existing actor and event property retained for soft body reload; handler bodies replaced. Contract expands `RunMulticast`’s error-code bool surrogate into raw intermediate counts after Broadcast, Unbind, and Clear. Runner guarantees Clear and teardown. |
| `MultipleSoftReloadsUpdateRunningBlueprintChildFunction/Version_01..04.as` | `TS-HR-BLUEPRINT-CHILD-SOFT-SEQUENCE`; `v1`, `v2_existing`, `v3_existing`, `v4_existing` | fixed `BeginPlay`; helper `int ComputeBonus()`; `int GetValue()` | Same parent UClass, Blueprint child class, live actor, Value 10, BeginPlayCount 1 across all versions. GetValue sequence 10,11,31,40. Runner destroys live child/Blueprint asset/world and discards all generations. |
| `StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults/Version_01..03.as` | `TS-HR-BLUEPRINT-CHILD-STRUCTURAL-DEFAULTS`; `v1`, `v2_existing_and_fresh`, `v3_existing_and_fresh` | `int GetValue()`; property declarations exactly as each version | Parent UClass/CDO replaced on each structural reload. Existing Blueprint child preserves Value 10 then Bonus 5; fresh parent/child take new defaults. V3 existing returns 15, fresh returns 27. Contract separately identifies old/new parent CDO, existing BP CDO, fresh BP CDO, existing/fresh instances. Cleanup generated assets/classes and actors. |
| `SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody/{Before,After}.as` | `TS-HR-BLUEPRINT-CHILD-SOFT-BODY`; `before`, `after_existing`, `after_fresh` | `int GetValue()` | parent UClass, BP child class, and existing actor identities retained; value changes 30→42 via replaced body. Fresh instance also 42 but has distinct identity. Runner destroys actor/asset/world and discards module. |

The remaining 184 HotReload files are Medium, not clean. Migrate them only after adding the same matrix. Deterministic Medium order: failure/rollback and discard; class/property/function/enum/struct structural changes; signature invocation matrices; dependency/provider changes; PIE/multi-player reload; broadcast-only notification tests; namespace/unrelated-module/no-change cases.

## High map — framework discovery names are fixed

Registry evidence: `FAngelscriptScriptTestDescriptor::Id` stores exact `ModuleName`, `SuiteName`, and `MethodName`; `DisplayName` is `Angelscript.ScriptTests.<Module>.<Suite>.<Method>`. Therefore every class/method below is a fixed external identity. Their contract `requiredNameReason` is “script-test registry and Automation display-name identity; C++ diagnostics/snapshot assertions resolve this exact name.” Do not rename them as part of the no-legacy-name sweep.

### `Test_SuiteAndMethodDiscovery.as`

CaseId `TS-FW-DISCOVERY-001`; subcases `published_direct_leaves`, `omitted_abstract`, `omitted_inherited_only`, `omitted_wrong_base`, `omitted_unmarked`.

Fixed complete marked declarations:

```angelscript
void InheritedMarkedMethodIsNotADirectLeaf()
void UnrelatedMarkedMethodIsNotASuiteLeaf()
void VerifySecondDiscoveredSuiteLeaf()
void VerifySuiteAndMethodDiscovery()
void VerifySecondMarkedDiscoveryLeaf()
```

Fixed suite names: `UTestSourceSuiteAndMethodDiscoveryAbstractSuite`, `UTestSourceSuiteAndMethodDiscoveryInheritedOnlySuite`, `UTestSourceSuiteAndMethodDiscoveryUnrelatedObject`, `UTestSourceSuiteAndMethodDiscoverySecondSuite`, `UTestSourceSuiteAndMethodDiscoverySuite`. Published leaves are exactly the last suite’s two methods plus `VerifySecondDiscoveredSuiteLeaf`, ordered by registry’s deterministic descriptor order. The first two marked methods are omission inputs, not aliases. Runner rebuilds snapshot and owns registry generation/module cleanup.

### `Test_AutomationFlagsAndDisabledCases.as`

CaseId `TS-FW-DISCOVERY-002`; subcases `invalid_unknown_flag`, `disabled_published_not_run`, `multi_context_flags`.

Fixed suite/method pairs and declarations:

```angelscript
UTestSourceAutomationFlagsInvalidTokenSuite::void VerifyInvalidFlagTokenIsOmitted()
UTestSourceAutomationFlagsDisabledSuite::void VerifyDisabledLeafIsDiscoverableButNotExecuted()
UTestSourceAutomationFlagsAndDisabledCasesSuite::void VerifyAutomationFlagsAndDisabledCases()
```

Vectors record exact flag strings and bitmasks. The Disabled descriptor is present but its unique `Fail` message never executes. Invalid suite is omitted with the exact unknown-token diagnostic and source line. Registry/module cleanup runner-owned.

### `Test_InvalidDiscoveryDiagnostics.as`

CaseId `TS-FW-DISCOVERY-003`; subcases `wrong_base`, `non_void`, `parameterized`, `duplicate_flag`, `unsupported_flag`, `valid_control`.

All of these fixed declarations are diagnostic identities:

```angelscript
void MarkedMethodOnWrongBaseIsOmitted()
int VerifyNonVoidMarkedMethodIsOmitted()
void VerifyParameterizedMarkedMethodIsOmitted(int UnusedValue)
void VerifyDuplicateFlagMetadataIsOmitted()
void VerifyUnsupportedFlagTokenIsOmitted()
void VerifyInvalidDiscoveryDiagnostics()
```

Vectors carry exact declaration, expected diagnostic text fragment, exact source line, and published/omitted status. The only published leaf from the file is the valid control. Runner owns snapshot/module cleanup.

### `Test_RegistryGenerationRebuild.as`

CaseId `TS-FW-DISCOVERY-004`; subcases `generation_a`, `generation_b`, `empty_generation`, `retained_old_snapshot`.

Fixed suite `UTestSourceRegistryGenerationRebuildSuite` and complete declaration:

```angelscript
void VerifyRegistryGenerationRebuild()
```

Generation B must be a real second source/version artifact in the runner contract, not only prose. Vectors record monotonically increasing generation numbers, immutable old snapshot identity/content, current snapshot content, module/suite/method identity, and A/B body marker. Empty discovery produces an empty new snapshot without mutating the retained A snapshot. Runner releases both snapshots and discards the module.

## Deterministic disjoint implementation batches

Later implementation should use these batches in this exact order. Paths are disjoint so the controller can parallelize within a numbered wave only after the contract infrastructure/pilot conventions are frozen.

1. **Critical dispatch/GC** — ProcessEvent file; the nine GC files. This fixes the test-model rules used by later contracts.
2. **Critical destruction timers** — actor-destroy and component-destroy timer files. Establish real world/TimerManager advance and cleanup helpers.
3. **DefaultComponent preconditions** — the 48 `World/Component` files, then the 3 `Feature/Inheritance` files, then Gameplay Material. Mechanical but large; verify every property accessor against spawned identity.
4. **Lifecycle/native dispatch** — Definitions lifecycle files, then Feature lifecycle/Blueprint-event/native-call files, then RepNotify. No file overlaps batch 3 except the two component inheritance stories; those are completed in batch 3 and only their phase vectors are added here.
5. **Gameplay timers** — state/query-only timers first, then callback-firing timers, then use-case timers. World delayed-spawn/component-owner timer stories last. Always clear handles.
6. **Delegates/events** — Gameplay Widget, Gameplay Physics, World Actor, World Component. Real broadcast and explicit cleanup are acceptance requirements.
7. **NewObject/UObject identity** — Bindings/UObject, flag/outer-chain EdgeCases, manual component NewObject. The GC NewObject file was already completed in batch 1.
8. **CDO/Blueprint identity** — Definitions, Feature, World Blueprint. Freeze fixture kinds before HotReload consumes them.
9. **High HotReload identity scenarios** — nine scenario directories/25 files in their table order. Within each directory versions are strictly ordered.
10. **Framework discovery** — four discovery files after naming rules are stable. Assert exact descriptor/display names before any global rename sweep.
11. **Medium HotReload and remaining scoped files** — use the retained/replaced matrix and raw-output rules; no severity downgrade is an exemption from strict audit.

## Acceptance checks for later implementation

- Strict contract validation passes for each batch before the next begins.
- Source contains no `Observe_*`, `SurfaceNNN`, `_Nominal`, old-name forwarding alias, `Expected*` oracle parameter, or compound bool as the sole multi-value oracle.
- No lifecycle/timer/delegate/repnotify/ProcessEvent test entry directly calls the callback it claims the engine invoked.
- Every DefaultComponent used by a spawned actor is first observed non-null with exact type/owner/world/registration and attachment identity.
- GC release, collection, and observation occur in separate invocation phases; rooted-object abort cleanup is proven.
- UObject-like vectors include identity, nullability, exact class, Outer/owner, name, and relevant flags.
- CDO/BP CDO/spawned/existing/fresh objects have explicit fixture kinds and identity relations.
- HotReload contracts distinguish retained objects from replaced descriptors and state exactly when old objects are still callable.
- Framework-required and FName-bound names have non-empty required-name reasons; all other old names are hard-renamed.
- Every timer/delegate/world fixture has an explicit cleanup owner and cleanup phase, including failure paths.
