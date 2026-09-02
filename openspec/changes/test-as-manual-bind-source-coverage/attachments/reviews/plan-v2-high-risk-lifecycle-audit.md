# TestSource Contract V2 high-risk lifecycle audit

Date: 2026-08-24  
Mode: plan-only review; this report does not authorize `TestSource` implementation.  
Target change: `openspec/changes/test-as-manual-bind-source-coverage`  
Verdict: **FAIL — the normalized plan is not yet semantically safe for high-risk implementation.**

## Scope and evidence

This review compares the normalized Contract V2 rows against:

- `attachments/contracts/audit-index.md`;
- `attachments/reviews/plan-review-guide.md`;
- `attachments/implementation/high-risk-lifecycle-audit.md`;
- the normalized JSONL shards under `attachments/contracts/normalized/`;
- the referenced authored sources under `TestSource/`, used as read-only evidence.

The review concentrates on paths where a renamed helper can appear to improve coverage while still bypassing the engine behavior being claimed: Actor lifecycle and `DefaultComponent`, `NewObject`/Outer/flags/GC, Blueprint/CDO/inheritance/`ProcessEvent`, TimerManager, delegates, HotReload, and Debugger/DAP evaluation.

At the review snapshot, the normalized corpus contains 12,624 rows for 3,041 authored sources. All 47 rows selected as `high-risk-replacement` and all six `high-risk-overlay` rows are currently design-blocked. That is a useful safety gate, but it is not sufficient: several blockers cover only comments or generic arguments, and many related rows outside those directives remain `review-ready` with incomplete or inverted raw oracles.

The high-risk design is accepted only when the normalized row freezes all of the following together:

1. the real engine/reflection driver rather than a direct AS callback;
2. the exact fixture identity, including CDO/template/spawned/retained/recreated distinctions;
3. the ordered lifecycle phases and cross-invocation boundaries;
4. cleanup on success, assertion failure, expected diagnostic, timeout, and early exit;
5. exact prohibited direct calls;
6. raw value, identity, Outer, flags, registration, attachment, writeback, or debugger-address oracles.

## Executive result by topic

| Topic | Current gate | Verdict | Principal unresolved risk |
|---|---|---|---|
| Actor / `DefaultComponent` | Many related rows are design-`review-ready` | **FAIL** | Null components and incomplete accessors can still pass; owner/Outer/world/class/registration/attachment are not frozen |
| `NewObject` / Outer / flags | Core binding rows blocked, manual component row ready | **FAIL** | Missing construction matrix; manual component oracle is inverted; phase identity is absent |
| GC | Selected lifecycle rows blocked | **BLOCKED BUT INCOMPLETE** | Most rows retain `BeginPlay` bodies and can unblock after comment-only work without separating host GC phases |
| Blueprint / CDO / `ProcessEvent` | Mixed blocked and ready | **PARTIAL / FAIL** | Missing readers and fixture identities; native `ProcessEvent` driver/writebacks not exact |
| Timer | 88 matched rows design-`review-ready` | **FAIL** | Generic `invoke`, `DiagnosticOnly`, direct-callback naming, and missing pre/post deadline state |
| Delegate | 69 matched rows design-`review-ready` | **FAIL** | Direct handlers/manual counter mutation can substitute for real `Broadcast` |
| HotReload | 323/323 matched rows blocked | **PASS AS BLOCKED** | Before/after identity and external generation oracles remain intentionally unresolved |
| Debugger | 4/4 rows blocked on line maps | **PASS AS BLOCKED, INCOMPLETE** | Resolving line maps alone would not add DAP evaluation and property-address oracles |

## Actor lifecycle and `DefaultComponent`

### Verdict

**FAIL.** The normalized projection does not consistently enforce that a spawned non-CDO actor materializes real default components. The review found 207 rows in 49 files matching the default-component/null-risk class; all 207 are design-`review-ready`, 160 have no non-empty raw-state channel, and 100 use `DiagnosticOnly`. Several sources can still turn a null component into success.

Representative authored risks include:

- `TestSource/World/Component/Test_BoxComponent.as`: null `BoxComp` and zero extents are accepted boundaries;
- `TestSource/World/Component/Test_GetComponent.as`: Root/Mesh/Billboard can all be null;
- `TestSource/World/Component/Test_FourLevelAttachChainResolves.as`: the four-level hierarchy can collapse to null;
- `TestSource/Gameplay/Material/Test_ScriptCompilesDynamicMaterialAPI.as`: null mesh/material results can be treated as a boundary instead of a failed fixture.

### Exact normalized rows and required declarations

| Task | Source | Current normalized decision | Required correction |
|---|---|---|---|
| `W11.B01.F0053.C0002` | `TestSource/World/Component/Test_BoxComponent.as` | `UBoxComponent GetBoxComponent(...)`; design-ready | Keep the accessor but add exact component identity, class, owner/Outer, world, registration, and non-CDO instance vectors |
| `W11.B01.F0054.C0002` | `TestSource/World/Component/Test_CameraComponent.as` | Only `GetCameraRoot(...)`; design-ready | Add `GetCameraComponent(...)` and independently validate root/component identity |
| `W11.B01.F0063.C0002` | `TestSource/World/Component/Test_ComponentFinding.as` | Only `GetFindingRoot(...)`; design-ready | Add ChildOne, ChildTwo, and Logic component channels |
| `W11.B01.F0083.C0001` | `TestSource/World/Component/Test_FourLevelAttachChainResolves.as` | Only `GetAttachRoot(...)`; design-ready | Return the complete chain and freeze every attachment parent |
| `W11.B01.F0085.C0001..C0009` | `TestSource/World/Component/Test_GetComponent.as` | Handle/out accessors; design-ready | Add exact non-null identity vectors; generic handle presence is insufficient |
| `W12.B01.F0179.C0002` | `TestSource/Gameplay/Material/Test_ScriptCompilesDynamicMaterialAPI.as` | Only `GetMaterialMesh(...)`; design-ready | Add the created MID channel and validate its owner/material relationship |
| `W10.B07.F0011.C0002` | `TestSource/Feature/Inheritance/Test_CustomComponentLifecycleSuperCalls.as` | Identity exists only in prose | Freeze typed owner/Outer/world/class/registration fields |
| `W10.B07.F0012.C0002` | `TestSource/Feature/Inheritance/Test_CustomComponentReuseInheritanceAndInstantiation.as` | Identity exists only in prose | Freeze CDO template versus spawned component identity |

Required declaration shapes include:

```angelscript
UBoxComponent GetBoxComponent(
    ACoverageSpecialBoxActor Actor)

UCameraComponent GetCameraComponent(
    ACoverageSpecialCameraActor Actor)

void ReadAttachChain(
    AFunctionalMultiLevelActor Actor,
    USceneComponent&out Root,
    USceneComponent&out Middle,
    UStaticMeshComponent&out LeafMesh,
    UPointLightComponent&out DeepLight)

UMaterialInstanceDynamic GetCreatedDynamicMaterial(
    AFunctionalDynamicMaterialActor Actor)
```

Each component channel must prove non-null exact identity, exact class, `Owner`/`Outer == Actor`, fixture world equality, registration, scene attachment parent where applicable, and distinct CDO-template versus spawned-component identities.

Add these blockers until that evidence exists:

- `coverage-unresolved`, field `vectors.expected.componentIdentity`;
- `fixture-unresolved`, field `fixture.instanceKind`;
- `vector-unresolved`, field `vectors.expected.attachmentParent` for scene hierarchies;
- `vector-unresolved`, field `vectors.expected.templateVsSpawnedIdentity` for CDO/default-component cases.

### Actor lifecycle state

`W09.B02.F0008.C0001`, `TestSource/Definitions/UClass/Test_ActorLifecycle.as`, currently proposes only:

```angelscript
UFUNCTION()
void ReadActorLifecycleState(
    int&out TickCount,
    float&out LastDelta) const
```

This omits BeginPlay, EndPlay, and destruction state. The current `vector-unresolved:plan` and `comment-unresolved:comment.exactText` blockers do not freeze post-destruction observation safety. The intended declaration is:

```angelscript
UFUNCTION()
void ReadActorLifecycleState(
    int&out BeginPlayCount,
    int&out TickCount,
    float&out AccumulatedDelta,
    int&out EndPlayCount,
    int&out DestroyedCount) const
```

Add `fixture-unresolved:fixture.phases`, `coverage-unresolved:vectors.expected.lifecycleState`, and `external-oracle-unresolved:fixture.postDestructionSnapshot`. The runner must drive lifecycle through the World and may not directly call `BeginPlay`, `Tick`, `EndPlay`, or `Destroyed`. If calling an AS reader after actor destruction is unsafe, the contract must require a runner-owned/native safe snapshot rather than assuming the destroyed object remains callable.

## `NewObject`, Outer, object flags, and manual component lifecycle

### Core construction matrix

`W05.B01.F0144.C0007`, `TestSource/Bindings/UObject/Test_Behavior_01.as`, is correctly blocked on unresolved arguments and result, but its single construction declaration does not cover the required identity matrix:

```angelscript
UObject CreateObject(
    UObject Outer,
    const TSubclassOf<UObject>& Class,
    FName Name,
    bool bTransient)

void CreateObjectMatrix(
    UObject Outer,
    UObject&out NamedTransient,
    UObject&out GeneratedName,
    UObject&out NamedNonTransient,
    UObject&out NullOuterObject)
```

The normalized corpus currently has no `CreateObjectMatrix`. Each output needs exact class, requested/effective Outer, explicit or generated name, `RF_Transient`, distinct identity, release, and host-owned GC vectors.

`W05.B01.F0144.C0010`, in the same source, currently proposes:

```angelscript
void TriggerGetTransientPackageInvalidDiagnostic(
    const TSubclassOf<UObject>&in EmptyClass,
    UObject Created)
```

That declaration pushes derived failure state into the caller instead of exercising the invalid-class path. Replace it with:

```angelscript
void CreateObjectWithInvalidClass()
```

and freeze the exact diagnostic phase, count, message, and post-failure state.

Required blockers are `coverage-unresolved:vectors.expected.objectIdentity`, `vector-unresolved:vectors.objectMatrix`, `fixture-unresolved:fixture.outerIdentity`, and `cleanup-unresolved:fixture.cleanupActions`.

### Manual `NewObject` component

`W11.B01.F0067.C0003`, `TestSource/World/Component/Test_ComponentManualNewObjectRegistration.as`, is a critical false oracle. It is design-`review-ready` and proposes `ReadManualNewObjectDefaultNullState(...)`, whose outputs assert `ManualComp == nullptr`, negate successful creation/owner/world/registration state, and therefore invert the C++ oracle that expects a created component with matching owner/world and value 42.

Replace that design with explicit phases:

```angelscript
void CreateManualComponent()

void RegisterManualComponent()

void DestroyManualComponent()

void ReadManualComponentState(
    UCoverageManualNewObjectComponent&out Component,
    AActor&out Owner,
    UWorld&out World,
    bool&out Registered,
    bool&out Active,
    bool&out BeingDestroyed,
    int&out CustomValue) const
```

Block until `vectors.expected.objectIdentity`, `fixture.phases`, `vectors.expected.registrationTransitions`, and `fixture.cleanupActions` are exact. The same component identity must survive create/read/register/read/activate/deactivate/read phases, followed by a runner-driven destroy and safe snapshot.

### Outer/flag readers

- `W08.B09.F0246.C0002`, `TestSource/Language/Syntax/EdgeCases/Test_UObjectFlagMutationAndTransientState.as`, has a directionally correct `ReadFlagObjectState(...)` but no raw flag/identity expectations.
- `W08.B09.F0247.C0002`, `TestSource/Language/Syntax/EdgeCases/Test_UObjectOuterChainAndPathMatrix.as`, has a directionally correct `ReadOuterChain(...)` but no raw Outer/path expectations.

Keep both blocked until writer arguments specify exact object identities, names, Outers, flags, and leaf path. Cleanup must clear leaf, child, and root references in that order before host GC; generic teardown prose is insufficient.

## Garbage collection

### Verdict

**BLOCKED BUT SEMANTICALLY INCOMPLETE.** The following lifecycle rows are blocked, but several remain fixed-name `BeginPlay` callbacks with a body plan that preserves the current callback body. A comment-only blocker can therefore be resolved without separating object creation, strong-reference release, host GC, and later observation.

| Task | Source |
|---|---|
| `W08.B09.F0168.C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCBasicReclaim.as` |
| `W08.B09.F0169.C0009` | `TestSource/Language/Syntax/EdgeCases/Test_GCCollectionMethods.as` |
| `W08.B09.F0170.C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCContainerProtection.as` |
| `W08.B09.F0171.C0003/C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCCrossFrameHold.as` |
| `W08.B09.F0172.C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCIsValidCheck.as` |
| `W08.B09.F0173.C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCNewObjectOuterAndCollection.as` |
| `W08.B09.F0174.C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCRootReachability.as` |
| `W08.B09.F0175.C0003` | `TestSource/Language/Syntax/EdgeCases/Test_GCStrongCycleReclaim.as` |
| `W08.B09.F0176.C0004` | `TestSource/Language/Syntax/EdgeCases/Test_GCWeakPtrInvalidation.as` |

For example, `W08.B09.F0168.C0004` still proposes `UFUNCTION(BlueprintOverride) void BeginPlay()` and says to preserve the current body/execution phase; its only current blocker is the adjacent comment. `W08.B09.F0173.C0004` and `W08.B09.F0174.C0004` likewise preserve callback bodies and merely promise a future reader.

Required phase APIs are:

```angelscript
void PrepareCandidate()
void ReleaseStrongReference()
bool IsWeakReferenceValid() const
```

For named `NewObject` GC:

```angelscript
void CreateNamedCandidate(
    UObject Outer,
    FName Name,
    bool bTransient)

void ReleaseStrongReference()

void ReadCandidateIdentity(
    UObject&out Strong,
    UObject&out Outer,
    UClass&out Class,
    FName&out Name,
    bool&out Transient,
    bool&out WeakValid) const
```

For root reachability:

```angelscript
void PrepareRootedCandidate()
void RemoveCandidateFromRoot()
bool IsRootedCandidateWeakReferenceValid() const
```

Add `coverage-unresolved:proposal.bodyPlan`, `fixture-unresolved:fixture.phases`, `vector-unresolved:vectors.expected.preGcPostGcState`, and `external-oracle-unresolved:fixture.hostGarbageCollection`. Root cases also require `cleanup-unresolved:fixture.cleanupActions`; `RemoveFromRoot` must run on success, assertion failure, expected diagnostic, timeout, and early exit before references are cleared and GC is requested.

The required phase sequence is prepare → return to runner → release strong reference → return to runner → host/UE GC → later independent read. An AS callback that creates, releases, collects, and asserts in one invocation is prohibited.

## Blueprint, CDO, inheritance, and `ProcessEvent`

### Blueprint default preservation

`W11.B01.F0043.S000`, `TestSource/World/Blueprint/Test_DefaultPreservation.as`, is safely source-only blocked, but the exact callable named by the high-risk audit is absent. Add:

```angelscript
void ReadBlueprintDefaultFields(
    ATestBPChildDefaultPreservationParent Object,
    int&out Counter,
    bool&out Toggle,
    FString&out Label)
```

Vectors must independently cover the script parent CDO, Blueprint child CDO, and spawned Blueprint child. They must freeze object/class/Outer/world/`RF_ClassDefaultObject` identity and values `23`, `true`, and `"ScriptParentDefault"`. Required blockers are `signature-unresolved:sourceOnlyPlan.exactCallableDeclaration`, `fixture-unresolved:vectors.fixtureInputs.instanceKind`, `vector-unresolved:vectors.expected.blueprintDefaultFields`, and `external-oracle-unresolved:fixture.blueprintClassCreation`.

### Recreated Blueprint child state

`W11.B01.F0045.C0001/C0002`, `TestSource/World/Blueprint/Test_RecreateDoesNotLeakState.as`, are design-`review-ready` fixed callbacks (`BeginPlay` and `BumpState`) with no raw-state reader. Add:

```angelscript
void ReadRecreateState(
    ATestBPChildRecreateNoLeakParent Actor,
    int&out StatefulValue,
    int&out BeginPlayCount)
```

Freeze the CDO as `(10, 0)`, the first spawned actor after BeginPlay as `(11, 1)`, after bump as `(48, 1)`, and a fresh second actor as `(11, 1)`. The first and second instance identities must differ. Add `coverage-unresolved:proposal.bodyPlan` until the reader and recreate phase matrix are represented.

### CDO/default-statement fixture identity

- `W09.B02.F0013.C0001`, `TestSource/Definitions/UClass/Test_CDOHasExpectedDefaults.as`, proposes `ReadClassDefaults(...)`.
- `W10.B07.F0016.C0001..C0003`, `TestSource/Feature/Inheritance/Test_DefaultStatementsAffectComponentCDOs.as`, propose `ReadDefaultComponentValues(...)`, `GetDefaultSphere(...)`, and `GetDefaultMesh(...)`.

These rows are currently blocked, but generic arrange/invoke/observe phases do not distinguish script class CDO, CDO template component, spawned actor, and spawned component. Keep `fixture-unresolved:vectors.fixtureInputs.instanceKind` and add `vector-unresolved:vectors.expected.templateVsSpawnedIdentity` until flags, Outer, world, values, and distinct identities are explicit.

### Native `ProcessEvent`

`W10.B07.F0021.C0001`, `TestSource/Feature/Inheritance/Test_InheritanceProcessEventDispatchesToChildOverride.as`, has the correct reader declaration:

```angelscript
void ReadProcessEventDispatchState(
    ATestInhHealthPickup3 Actor,
    int&out ParentCallCount,
    int&out ChildCallCount,
    int&out ChildCollectorHash)
```

The direct wrappers `W10.B07.F0021.C0006..C0008` must remain retire-with-replacement. C0001 is blocked, but its driver and phase are still generic. Add `fixture-unresolved:fixture.invocationDriver`, `vector-unresolved:vectors.expected.writebacks`, `coverage-unresolved:vectors.phaseMatrix`, and exact `prohibitedCalls=["direct-call:OnPickedUp"]`.

The runner must use native UFunction lookup/`ProcessEvent`. Vectors are initial `(0,0,0)`, native `ProcessEvent(777)` resulting in `(0,1,777)`, and a fresh actor with native `ProcessEvent(0)` resulting in `(0,1,0)`.

## TimerManager

### Verdict

**FAIL.** The review found 88 timer-risk rows across 16 files; all 88 are design-`review-ready`, 62 have no non-empty raw state, and 33 are `DiagnosticOnly`. Generic `phase="invoke"` and generic driver text do not prove that the World TimerManager crossed a deadline.

The following rows still encode `DirectCallback` in the semantic name while claiming direct callback invocation is prohibited:

| Task | Source | Current semantic name |
|---|---|---|
| `W12.B01.F0223.C0006` | `TestSource/Gameplay/Timer/Test_MultipleTimers.as` | `ReadMultipleTimersDirectCallbacksState` |
| `W12.B01.F0226.C0005` | `TestSource/Gameplay/Timer/Test_TimerBasicUsage.as` | `ReadTimerBasicUsageDirectCallbacksState` |
| `W12.B01.F0228.C0005` | `TestSource/Gameplay/Timer/Test_TimerClearThenReuseHandleVariable.as` | `ReadTimerClearReuseDirectCallbacksState` |
| `W12.B01.F0229.C0006` | `TestSource/Gameplay/Timer/Test_TimerDelayExecution.as` | `ReadTimerDelayDirectCallbacksState` |
| `W12.B01.F0230.C0007` | `TestSource/Gameplay/Timer/Test_TimerDynamicFunctionNameReflectionLifecycle.as` | `ReadDynamicFunctionNameDirectCallbackState` |
| `W12.B01.F0234.C0004` | `TestSource/Gameplay/Timer/Test_TimerImmediateExecution.as` | `ReadTimerImmediateDirectCallback` |
| `W12.B01.F0237.C0004` | `TestSource/Gameplay/Timer/Test_TimerManagement.as` | `ReadTimerManagementDirectCallback` |
| `W12.B01.F0239.C0004` | `TestSource/Gameplay/Timer/Test_TimerRepeatedFunctionNameReplacesExistingTimer.as` | `ReadRepeatedFunctionNameDirectCallback` |

Rename these readers to `Read...PostTimerAdvanceState`, or retire them when another post-advance reader already exists. Vectors require exact `before-deadline` and `after-timer-manager-advance` phases, advance duration/deadline, handle state, and callback counts.

`W11.B01.F0039.C0001/C0002`, `TestSource/World/Actor/Test_TimerActorDestroyStopsCallbacks.as`, has no independent raw reader. Add:

```angelscript
UFUNCTION()
void ReadDestroyTimerState(
    int&out CallbackCount,
    bool&out ActiveBeforeDestroy) const
```

Because calling AS after actor destruction may be unsafe, keep `external-oracle-unresolved:fixture.postDestructionSnapshot` until the runner/native fixture owns the snapshot. The runner must destroy the actor, tick the World, advance TimerManager at least 0.5 seconds, and prove the callback count does not grow.

`W11.B01.F0118.C0007`, `TestSource/World/Component/Test_TimerDestroyedComponentStopsCallbacks.as`, currently proves only copy-independence/manual mutation. Add:

```angelscript
UFUNCTION()
void ReadDestroyedComponentTimerState(
    bool&out ActiveBeforeDestroy,
    bool&out ComponentDestroyed,
    int&out CallbackCount) const
```

`W11.B01.F0040.C0001/C0002`, `TestSource/World/Actor/Test_TimerDelayedSpawnUseCaseRunsFromWorldTimer.as`, also lacks an independent raw reader; keep `coverage-unresolved` until the exact source fields and declaration are fixed.

All timer-risk rows require `fixture-unresolved:fixture.invocationDriver`, `coverage-unresolved:vectors.phaseMatrix`, `vector-unresolved:vectors.expected.preDeadlinePostDeadlineState`, and `cleanup-unresolved:fixture.cleanupActions`. `prohibitedCalls` must list exact callback names. Every live handle must be cleared on every exit before actor/component/World teardown.

## Delegates

### Verdict

**FAIL.** The review found 69 delegate-risk rows across ten files; all 69 are design-`review-ready`, 51 have no non-empty raw oracle, and 21 are `DiagnosticOnly`. A real delegate test requires bind → exact typed `Broadcast` → raw snapshot/read → unbind → optional post-cleanup broadcast.

`W11.B01.F0003.C0001..C0004`, `TestSource/World/Actor/Test_ActorCollisionEvents.as`, has no independent reader. Add:

```angelscript
void ReadActorCollisionEventState(
    ACoveragePhysicsActorCollisionEventsActor Actor,
    bool&out DelegatesBound,
    int&out HitCount,
    int&out BeginOverlapCount,
    int&out EndOverlapCount)
```

The runner must broadcast the exact delegate properties with typed payloads; calling the handlers is prohibited.

`W12.B01.F0205.C0002/C0003/C0006`, `TestSource/Gameplay/Physics/Test_CollisionEvents.as`, needs special correction. C0006 still directly calls `OnHit` despite `direct-call:OnHit` being prohibited. C0002/C0003 treat callback `FHitResult`/`SweepResult` payloads as writebacks, which changes the callback contract. Keep the exact reflected callback signatures, capture payload into actor state, and expose it through a separate reader.

The following source-derived readers can currently substitute manual counter mutation for real dispatch and must gain explicit typed broadcast vectors:

- `W11.B01.F0060.C0006` — `TestSource/World/Component/Test_ComponentCollisionEventDispatch.as`;
- `W11.B01.F0082.C0011` — `TestSource/World/Component/Test_EventBuiltInActorAndComponentInstances.as`;
- `W11.B01.F0095.C0005` — `TestSource/World/Component/Test_PrimitiveCollisionEvents.as`;
- `W11.B01.F0098.C0004` — `TestSource/World/Component/Test_PrimitiveHitEvents.as`.

`W12.B01.F0245.C0006`, `TestSource/Gameplay/Widget/Test_AdditionalWidgetDynamicEventsInvokeScriptHandlers.as`, is directionally stronger because it contains payload/count expectations and bind/broadcast/snapshot/unbind/destroy phases, but it still needs an exact delegate-property `Broadcast` driver rather than generic dispatch.

Required blockers are `fixture-unresolved:fixture.invocationDriver`, `coverage-unresolved:vectors.broadcastPayload`, `vector-unresolved:vectors.expected.deliveryState`, and `cleanup-unresolved:fixture.cleanupActions`. `prohibitedCalls` must enumerate `OnHit`, `OnBeginOverlap`, `OnEndOverlap`, and other exact handlers. After cleanup, broadcast again and prove no delivery if the delegate surface permits that validation.

## HotReload

### Verdict

**PASS AS BLOCKED.** All 323 matched rows across 209 sources are currently blocked. The snapshot contains 3,124 `coverage-unresolved`, 50 `signature-unresolved`, and three `external-oracle-unresolved` blockers, so no HotReload source row is presently authorized for implementation.

Representative rows are:

- `W13.B01.F0023.C0001` — `TestSource/HotReload/CDOAndInstanceConsistency/Version_01.as`;
- `W13.B01.F0038.C0001` — `TestSource/HotReload/DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload/After.as`;
- `W13.B01.F0003.C0001` — `TestSource/HotReload/BlueprintDelegatePropertyReloadsAfterInstanceRuntime/Version_01.as`.

Do not downgrade these blockers. Before accepting declarations, the plan must freeze ordered before/after generations; old/new module, UClass, CDO, Blueprint child, existing/fresh instance, component, delegate receiver, function/property/struct/enum identities; each relation as `retained`, `replaced`, or `not-applicable`; whether old-object invocation is legal; and cleanup/lease behavior on reload failure or timeout. No speculative AS signature should be approved before that matrix resolves.

## Debugger and DAP evaluation

### Verdict

**PASS AS BLOCKED, BUT INCOMPLETE.** All four rows are blocked on exact line maps:

- `W15.B01.F0001.C0001` — `TestSource/Debugger/FunctionEvaluationGuards/Test_Block_01.as`, `GetValue`;
- `W15.B01.F0001.C0002` — the same source, `NeedsArg`;
- `W15.B01.F0002.C0001` — `TestSource/Debugger/GetterPropertyTracking/Test_Block_01.as`, `GetHealth`;
- `W15.B01.F0003.C0001` — `TestSource/Debugger/InheritedGetterTracksBasePropertyAddress/Test_Block_01.as`, inherited `GetHealth`.

The D001/D002 line-map blockers prevent immediate edits, but all raw expectations are empty. Resolving only the line maps would leave the semantic debugger oracle undefined. Add `vector-unresolved:vectors.expected.debuggerEvaluation`, `coverage-unresolved:coverage.propertyAddress`, and, where the runner cannot yet provide the session, `external-oracle-unresolved:fixture.dapSession`.

Exact expectations are:

- `GetValue`: debugger evaluation returns 42 and increments `EvalCount` exactly as specified by the scenario;
- `NeedsArg`: the debugger does not auto-evaluate it and `EvalCount` remains unchanged; an explicit-evaluation vector, if retained, must include the exact input and return;
- getter tracking: `Health == 42` and the debugger resolves the exact `Health` property address on the world actor;
- inherited getter: the address resolves to the base-class property, not merely to another numeric value of 42.

## Unified acceptance gate

No row in these high-risk topics may enter implementation until all applicable checks below are true:

1. `fixture.invocationDriver` names the exact World, TimerManager, delegate property `Broadcast`, native UFunction/`ProcessEvent`, GC host, HotReload generation driver, or DAP operation. Generic `runner/engine/native/reflection according to vector phase` is not accepted.
2. `fixture.identity` and `instanceKind` distinguish CDO, CDO component template, spawned actor/component, retained pre-reload instance, fresh post-reload instance, and runner-owned snapshot.
3. `fixture.phases` gives exact ordered phases and explicit returns to the runner between lifecycle operations. Generic arrange/invoke/observe phases are not accepted.
4. `fixture.cleanupActions` covers success, assertion failure, expected diagnostic, timeout, and early exit. Rooted UObjects, timers, delegates, generated Blueprint assets/classes, HotReload generations, and DAP sessions each need their own cleanup.
5. `prohibitedCalls` lists exact lifecycle callbacks and delegate/timer handlers; generic “no direct callback” prose is insufficient.
6. `vectors.expected.rawExpectations` freezes raw values plus relevant identity, Outer, flags, registration, attachment, writebacks, pre/post deadline or GC state, generation relation, and debugger property address.
7. Copy-independence helpers or manual counter assignments cannot serve as TimerManager, delegate, `ProcessEvent`, GC, or lifecycle evidence.
8. A high-risk replacement must be the only implementable plan path for its source behavior; a related legacy `review-ready` row may not bypass it.
9. Resolving comments or line maps alone may not unblock a lifecycle row whose driver, fixture, phase, cleanup, or raw oracle remains unresolved.

## Final recommendation

Keep HotReload and Debugger rows blocked, strengthen Debugger with semantic DAP blockers, and return Actor/DefaultComponent, manual `NewObject`, Blueprint recreation, Timer, and Delegate rows to design-blocked status. GC rows need body-plan and host-phase blockers in addition to comment blockers. Only after the exact declarations and vectors above are represented in the normalized plan should `tasks.md` project these rows as executable TestSource work.
