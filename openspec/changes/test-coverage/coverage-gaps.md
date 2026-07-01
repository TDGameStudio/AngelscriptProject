# AngelScript Coverage Pending / Boundary Matrix

> Use this with `coverage-matrix.md`, the main index, and the domain matrices under `matrices/`. This file records two kinds of items:
>
> 1. **Pending / enhancement items** (⬜ / 🟡): real sub-items not covered yet or worth strengthening.
> 2. **Fork unsupported / not applicable boundaries** (🚫): capabilities explicitly unsupported by the current AngelScript fork, already guarded by boundary tests or excluded from the plan, to avoid repeated future attempts.
>
> Important principle: historical documents under `Documents/Coverage/` overestimated gaps for a long time by marking implemented items as ⬜. This file removes those false gaps. Items marked `needs audit` must be checked against actual test files before implementation.

## Legend

| Marker | Meaning |
|------|------|
| ⬜ | Pending coverage, recommended new test |
| 🟡 | Partial coverage, recommended enhancement to existing tests |
| 🚫 | Fork unsupported / not applicable, record only with no planned test |

---

## 1. Pending / Enhancement Candidates

> After auditing actual test code, false gaps have been removed. For example, GC cycle references, covered by `GCStrongCycleReclaim` / `GCRootReachability` / `GCUPropertyReachabilityChain`, and dynamic material parameters, covered by `DynamicMaterialParametersAndAssignment` / `...Readback`, are already covered and are no longer listed as gaps.

| # | Priority | Sub-Item | Related Test File | Status | Notes |
|---|-------|------|------------|------|------|
| G1 | 🟡 Medium | AnimInstance behavior coverage | AngelscriptCoverageAnimInstanceTests.cpp | ✅ | `AnimInstanceQueryFunctionsExecute` upgrades owner / montage / curve queries from compile-only to asset-free runtime assertions; state machines, animation notifies, and real animation asset paths are out of scope for this headless Coverage pass |
| G2 | 🟢 Low | SaveGame complex structure serialization | AngelscriptCoverageSaveGameTests.cpp | ✅ | `ComplexStructAndArraySlotRoundTrip` covers nested USTRUCT, `TArray<int>`, and `TArray<USTRUCT>` save -> load round trips |
| G5 | 🟢 Low | TArray out-of-bounds `[]` semantics | AngelscriptCoverageTArrayAdvancedTests.cpp | ✅ | `TArrayOutOfBoundsIndexAccess` covers read/write out-of-bounds `[]` and asserts the stable script exception `Array index out of bounds.` |
| G6 | 🟢 Low | TMap value as user USTRUCT | AngelscriptCoverageTMapAdvancedTests.cpp | ✅ | `TMapUserStructValues` covers Add/Find/index/overwrite runtime round trips for `TMap<int, user USTRUCT>` |
| G7 | 🟢 Low | Widget animation/focus runtime assertions | AngelscriptCoverageWidgetTests.cpp | 🟡 / needs audit | `WidgetAnimationPlaybackReflectionSurfaces` / `WidgetFocusAndInputModeReflectionSurfaces` cover reflection surfaces only; test whether headless can assert animation advancement or focus transfer, otherwise keep the reflection ceiling |
| G8 | 🟢 Low | UClass CDO and instance independence | AngelscriptCoverageUClassTests.cpp | ✅ | `UClassDefaultObjectAndInstanceStateIndependence` covers CDO mutation affecting later `NewObject` defaults, not retroactively changing existing instances, and instance mutation not polluting CDO or later instances |
| G9 | 🟡 Medium | Actor Tick/EndPlay/Destroyed runtime dispatch | AngelscriptCoverageClassLifecycleTests.cpp | 🟡 | `ActorLifecycle` / `MultiLevelInheritanceLifecycle` cover script declarations but only assert BeginPlay; Component tests already drive real behavior through `DispatchComponentTick` + `DestroyComponent`, but Actor-side equivalents are missing |
| G10 | 🟢 Low | UObject/Actor native-only virtual BlueprintOverride rejection boundaries | AngelscriptCoverageClassLifecycleTests.cpp | ✅ | `NativeOnlyVirtualOverrideBoundaries` locks compile-failure boundaries for `PostLoad`, `PreSave`, `PostInitProperties`, `BeginDestroy`, `FinishDestroy`, `Reset`, and similar native-only virtuals used as `BlueprintOverride`; legal `OnReset` is still covered by UFunction / Actor lifecycle tests |
| G11 | 🟢 Medium | FInstancedStruct as USTRUCT member | AngelscriptCoverageUStructTests.cpp | ⬜ | Fork already binds it in `Bind_FInstancedStruct.cpp`; Coverage lacks UPROPERTY reflection, `InitializeAs<FFoo>` / `Get<FFoo>()` round trip, and container/parameter forms |
| G12 | 🟢 Low | USTRUCT value semantics deep-copy independence | AngelscriptCoverageUStructTests.cpp | 🟡 | `UStructValueSemantics` covers copy independence for int+FString members only; missing deep-copy independence assertions for TArray/TMap/TSet members |
| G13 | 🟢 Low | USTRUCT operator overload subset expansion | AngelscriptCoverageUStructTests.cpp | 🟡 | `UStructOperators` covers opEquals/opAdd/opAssign/opCmp/opIndex; missing opSub/opMul/opDiv/opNeg and compound assignments opAddAssign/opSubAssign/opMulAssign/opDivAssign |
| G14 | 🟢 Low | FInstancedPropertyBag / FPropertyBag boundary proof | AngelscriptCoverageUStructTests.cpp | ⬜ / needs audit | Fork grep has no `Bind_FPropertyBag*`, likely 🚫 boundary; first add one compile-failure proof row before final status |
| G15 | 🟢 Low | HasNativeMake / HasNativeBreak specifier boundary proof | AngelscriptCoverageUStructTests.cpp | ⬜ / needs audit | Fork grep finds no parsing path; current `UStructUnsupportedSpecifiers` covers only Atomic/Immutable/NoExport; add one compile-failure proof row to lock 🚫 |
| G16 | 🟢 Low | USTRUCT custom `Serialize(FArchive&)` boundary proof | AngelscriptCoverageUStructTests.cpp | ⬜ / needs audit | Fork has no `FArchive` AS binding; add one compile-failure proof row to lock 🚫 |
| G17 | 🟢 Low | USTRUCT `NetSerialize` replication serialization boundary proof | AngelscriptCoverageUStructTests.cpp | ⬜ / needs audit | Fork grep finds no `NetSerialize` binding; add one compile-failure proof row to lock 🚫 |
| G18 | 🟢 Low | AS USTRUCT static member boundary proof | AngelscriptCoverageUStructTests.cpp | ⬜ / needs audit | AS language does not support class/struct static fields, already recorded in delegate domain as the `BindStatic` boundary in §2.4; USTRUCT domain lacks the matching compile-failure row |
| G19 | 🟢 Low | Mutating containers during for-each iteration, iterator invalidation semantics | AngelscriptCoverageLoopTests.cpp | ⬜ | `ForEach` only asserts in-place element modification through `int& Val`; runtime semantics for Add/Remove during iteration are missing |
| G20 | 🟢 Low | EnhancedInput full ETriggerEvent reflection preservation | AngelscriptCoverageInputTests.cpp | 🟡 | Five ETriggerEvents are compile-reachable through BindAction; `GetTriggerEvent()` reflection assertions only cover Started+Triggered, missing Ongoing/Completed/Canceled |
| G21 | 🟢 Low | EnhancedInput Modifier/Trigger `ModifyRaw` / `UpdateState` | AngelscriptCoverageInputTests.cpp | 🟡 | Tests only assert Add+Count; missing `ModifyRaw` / `UpdateState` behavior or reflection assertions |
| G22 | 🟢 Low | Swizzle / FOVScaling Modifier reflection ceiling | AngelscriptCoverageInputTests.cpp | ⬜ / needs audit | `UInputModifierSwizzleAxis` is exposed in `Bindings/AngelscriptEnhancedInputBindingsTests.cpp` but missing in Coverage; `UInputModifierFOVScaling` has zero grep references |
| G23 | 🟢 Low | ChordedAction Trigger, distinct from Combo | AngelscriptCoverageInputTests.cpp | ⬜ / needs audit | `UInputTriggerChordAction` has zero grep references; use compile-failure boundary or reflection assertion to lock exposure state |
| G24 | 🟢 Low | EnhancedInputUserSettings / PlayerMappableKeyProfile boundary proof | AngelscriptCoverageInputTests.cpp | ⬜ / needs audit | Zero grep references; AS exposure state for UE5 PlayerMappable Key Settings is unknown |
| G25 | 🟢 Medium | Legacy InputComponent priority plus Consume/Pause behavior | AngelscriptCoverageInputTests.cpp | ⬜ | `bConsumeInput` / `bExecuteWhenPaused` default parameters are exposed, but runtime consume/pass-through and `InputComponent.Priority` / Block / Override / DontBlock behavior are not asserted |
| G26 | 🟢 Medium | PlayerController device API boundary proof | AngelscriptCoverageInputTests.cpp | ⬜ | `GetMousePosition`, `GetInputMotionState`, `GetInputAnalogKeyState`, and `GetInputKeyTimeDown` have zero fork bindings by grep; need independent compile-failure boundaries |
| G27 | 🟢 Low | Multi-player input routing, second gamepad / split-screen PlayerController | AngelscriptCoverageInputTests.cpp | ⬜ | All methods only construct one PlayerController; CreatePlayer / GetPlayerControllerFromID / second gamepad InputComponent isolation is not asserted through reflection or behavior |
| G28 | 🟢 Low | Cursor type / click / hover event boundaries | AngelscriptCoverageInputTests.cpp | ⬜ | Zero grep bindings; `InputModeControl` only covers `SetShowMouseCursor`; missing independent compile-failure boundaries for `SetMouseCursor`, `bEnableClickEvents`, and `bEnableMouseOverEvents` |
| G29 | 🟢 Low | Force Feedback / Haptic API boundaries | AngelscriptCoverageInputTests.cpp | ⬜ | APlayerController feedback APIs have zero fork bindings by grep; need compile-failure boundaries |

> The remaining 21 ⬜/🟡 candidates are **optional enhancements** and non-blocking. From the earlier pass, only G7 remains; G1/G2/G5/G6 were closed by tests on 2026-07-01. The 2026-06-30 second deep audit of the five previously unaudited domains, 05-uclass / 06-ustruct / 07-macros / 09-control-flow / 12-input, added G8-G29; G8/G10 were closed by tests on 2026-07-01. Remaining distribution: 05-uclass 1, 06-ustruct 8, 07-macros 0, 09-control-flow 1, 12-input 10. Current Coverage is mature overall, with 89 files / **1010** methods after AnimInstance +1, SaveGame +1, TArrayAdvanced +1, TMapAdvanced +1, UClass +1, ClassLifecycle +1, and the backfilled Comment +1. There are no hard "very high priority" gaps. New tests must follow `AGENTS.md` test layering and `_angelscript-test-guide`.

### 2026-06-30 Assertion-Layer Deep Audit Record

> Motivation: previous matrix ✅ status was often inferred from a same-named `TEST_METHOD`, without checking the assertion layer. The user asked whether everything marked complete was really complete. This pass uses a **mixed standard**: capability rows require runtime behavior assertions for ✅; pure declaration/reflection/syntax rows may use reflection or compile-level ✅.

- **Verified file-by-file as true behavior assertions**: `Material`, with spawn -> BeginPlay -> MID creation / parameter readback / native override value assertions; `AssetLoading`, with executed AS functions asserting load and async callback counts; `LiteralAsset`, with asset materialized value assertions; `Const`; `OperatorOverload`, with function execution and return value assertions; `Preprocessor`, with module order, code inclusion, diagnostics, and summary count assertions.
- **`Comment` remains ✅**: `CommentFormsCompile` only uses `AssertCompiles`, but comments are pure syntax with no runtime behavior to assert, so compile-level coverage is the ceiling under the mixed standard and not a gap.
- **New true gaps found**: container G5/G6 were both closed by tests; G1/G2 were already 🟡/⬜ in the matrix and are now also closed by tests.
- **Conclusion**: under the mixed standard, false ✅ scope is small, mainly `AnimInstance` G1, now covered by runtime assertions. If a later pass checks the remaining ~80 files one by one, it may still find isolated compile-only items; downgrade and add ⬜ rows using this standard.

### 2026-06-30 Capability-Surface Missing-Row Audit

> Method: compare each domain against that type/system's UE/AS capability surface and existing matrix rows. Candidate gaps are first confirmed by grepping the corresponding test files, avoiding invented work.

| Domain | Audit Method | Conclusion |
|----|---------|------|
| 01 basic types, int/float/bool/FString | capability comparison + grep `StartsWith/EndsWith/Left/Right/Chop` | **saturated**, with 151 methods and common methods covered; no true gaps |
| 02 math structs, six structs plus Math and geometry | capability comparison across three axes, Math namespace, and geometry structs | **saturated**, with 142 methods; unsupported items are locked as 🚫 |
| 03 containers | capability comparison + grep struct elements / out-of-bounds / struct-as-value | added two true gaps, **G5/G6** |
| 08 delegates/events | execution marker density comparison, Delegate 60:11 and Event 70:14 | mostly **true coverage**, no new gaps |
| 10 components | capability comparison, 4 files / 55 methods covering lifecycle, Tick, attachment, destruction, specialized components | **saturated**, no true gaps |
| 11 timers | capability comparison for handles, delayed, periodic, parameters, callbacks, use cases | **saturated**; Latent/Lambda are already 🚫 |
| 13 physics/collision | grep `AddRadialForce/GetMass/SetCenterOfMass/damping` | candidates are **already covered**, saturated; Chaos cloth/destruction are future subsystems |
| 14 Widget/UMG | capability comparison found **G7**, animation/focus reflection-only surfaces | runtime-testable parts are covered; animation/focus remain soft candidates |
| 15 networking/RPC | capability comparison | reflection/static surfaces are a **valid headless ceiling** because real multi-machine round trips are outside headless scope; not a gap |

**Overall conclusion**: this suite, with 89 files / 1010 methods, is highly mature after grounded sampling across multiple domains. True hard gaps are sparse; G1/G2/G5/G6/G8/G10 were closed by tests on 2026-07-01, and G7 is a soft candidate.

### 2026-06-30 Capability-Surface Missing-Row Audit, Second Pass: 05/06/07/09/12

> Motivation: the first audit did not cover five large domains. The user requested parallel subagent review of these five domains down to capability-surface rows, with discovered gaps or downgrades recorded in matrices and `coverage-gaps.md`.
> Method: one subagent per domain, checking `TEST_METHOD` assertion layers under the mixed standard and using grep against the UE/AS capability surface to find rows that should be tested but are not. Candidate gaps were grep-verified before adding. Subagents could only modify matching `matrices/0X-*.md`; the main agent summarized G numbers and tasks.

| Domain | Test Method Count | Audit Scope | New G IDs | Main Findings |
|----|----------|---------|-----------|---------|
| 05-uclass | 79 -> **83**, DefaultComponent corrected from 4 to 6, G8 +1, G10 +1 | 5 files and about 16 `Surface/Reflection/Lifecycle` methods checked to assertion layer | **G8 / G9 / G10**, 3 items; G8/G10 closed | Implemented but missing matrix row: `ClassFeatures::InterfaceImplementation`, covering script class implementation of native UINTERFACE runtime dispatch plus script-level interface rejection boundary; added ✅ row directly. G8 covers CDO/instance independence. G10 locks native-only virtual rejection boundaries. G9 remains: Actor Tick/EndPlay/Destroyed are declared but not truly asserted, while Component counterparts are truly driven. |
| 06-ustruct | 47, 16k-line file | 16 capability methods read one by one to assertion layer | **G11-G18**, 8 items | All 47 methods are true behavior/reflection assertions, with no broad false ✅ pattern. G11=FInstancedStruct, fork-bound but 0 Coverage coverage. G12/G13=value semantics/operator granularity. G14-G18=PropertyBag/HasNativeMake/Serialize/NetSerialize/static member boundary proof candidates; one compile-failure row each can lock them as 🚫. |
| 07-macros-enum-function-interface | 101 | 5 files grep + spot check | **0 items** | Domain is saturated. Flat tables were rewritten into five scenario-level sections: UEnum, UFunction, UInterface, Macros, MetaSpecifier. No new gaps. |
| 09-control-flow-language | 63 | all 11 files grepped + spot checked | **G19**, 1 item | Only missing item is `ForEach` runtime semantics when mutating containers during iteration. Other 11 files for control flow, namespaces, preprocessor, type conversion, mixin, const, and operators are saturated. |
| 12-input | 21 full audit | all 21 methods checked to assertion layer + full Enhanced Input capability comparison | **G20-G29**, 10 items | 21 methods are **not saturated at the reflection-ceiling level**. G20/G21 cover full ETriggerEvent reflection preservation and missing Modifier/Trigger `ModifyRaw`. G22/G23/G24 cover Swizzle/FOVScaling/ChordedAction/UserSettings reflection boundaries. G25 covers legacy InputComponent priority behavior. G26-G29 cover five PlayerController device API / multi-player / cursor / feedback clusters that have zero grep bindings but lack compile-failure boundaries. |

**Combined conclusion across two passes**: this suite, with 89 files / **1010** methods, was grounded across all 18 domains and is highly mature. The remaining 21 ⬜/🟡 candidates in G1-G29 are optional enhancements and non-blocking. There are zero true hard gaps. The two deep-audit passes downgraded 6 items, including historical G1/G3 and G9/G12/G13/G20/G21, added 21 ⬜/🟡 items, closed 4 historical false gaps, G3/G4 plus 2 fork-binding confirmations, and closed G1/G2/G5/G6/G8/G10 on 2026-07-01. `07-macros` is a zero-finding saturated domain; `12-input` is the highest-finding domain with 10 items, mostly because Enhanced Input capability surfaces were reachable but not yet tested and zero-grep bindings lacked compile-failure boundaries.

### Audited And Closed Historical Candidates, Original G3/G4

- **G3, weak/reference container elements, covered**: `WeakReferenceTests::WeakObjectPtrArrayContainer` and `HandlesTests::WeakObjectPtrArrayContainerAndReassignment` assert `TArray<TWeakObjectPtr<T>>` element round trip and reassignment. Invalidation assertions can be deepened later if desired, but this is no longer a gap.
- **G4, explicit TObjectPtr property round trip, covered**: `HandleTests::TObjectPtrRouting` and `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences` cover `TObjectPtr<T>` routing plus declaration/read/write as a reference property. This is no longer a gap.

## 2. Fork Unsupported / Not Applicable Boundaries

### 2.1 Unbound Container APIs

| Container | Unbound API | Current State |
|------|-----------|------|
| TArray | `RemoveAll(Pred)` / `Find` / `FindLast` / `StableSort` / `Reverse` / `FilterByPredicate` / `FindByKey` / `FindByPredicate` / `Heapify`/`HeapPop`/`HeapPush` / `LowerBound`/`UpperBound` | 🚫 Not exposed by current bindings; use `FindIndex` / `Contains` / `Sort` instead |
| TMap | pointer-style `Find(Key)` / `GenerateKeyArray` / `GenerateValueArray` / `FindRef` / `FindChecked` / `Reserve`/`Shrink` / `Append` / `FilterByPredicate` / `for (auto& Pair)` syntax | 🚫 Use `Find(Key,Out)` / `GetKeys` / `GetValues` / explicit iterators instead |
| TSet | `Find(Value)` / `Array()` / `Union` / `Intersect` / `Difference` / `Includes` / `FilterByPredicate` | 🚫 Use `Contains` / `Append` for union / manual for-each instead |

### 2.2 Container Nesting

| Combination | Current State |
|------|------|
| `TArray<TArray<T>>` / `TArray<TMap<>>` / `TMap<K,TArray<>>` / `TArray<TSet<>>` / `TMap<K,TMap<>>` | 🚫 Compiler diagnostic: `Containers cannot be nested in other containers`, already covered by boundary tests |
| struct containing an array and used as an array element | ✅ Allowed and covered, listed here for contrast |

### 2.3 Interface References

| Capability | Current State |
|------|------|
| Script-level `interface` / `TScriptInterface<I>` declaration, assignment, polymorphic calls, or container elements | 🚫 Current fork does not support script-level interface; `UInterfaceTests` cover the C++ UINTERFACE implementation path |

### 2.4 Other Boundaries

| Capability | Current State |
|------|------|
| Delegate `BindStatic`, binding global/static functions | 🚫 AS has no static function concept; use `BindUFunction` / `BindLambda` |
| Multicast delegate return values | 🚫 Semantically unsupported because multiple listeners cannot provide one meaningful return value |
| Full `SetInputMode` path for input mode switching | 🚫 Recorded as `InputModeSwitchingUnsupportedBoundary` under headless |
| Runtime widget lookup through `GetWidgetFromName` | 🚫 Recorded as `GetWidgetFromNameUnsupportedBoundary` |

---

## 3. Items Historical Docs Mislabelled As Uncovered

> `Documents/Coverage/` marked the following **implemented** topics as ⬜/planned in multiple places. This table corrects the record; no "todo" migration is needed when removing old docs.

| Historical Claim | Actual State | Actual Test Location |
|------------|---------|------------|
| Physics / collision / Trace / constraints = 0% planned | ✅ Covered | PhysicsTests.cpp, 25 methods including Trace / Constraint / CharacterMovement |
| Enhanced Input UE5 / touch = ⬜ planned | ✅ Covered | InputTests.cpp, IMC / modifiers / triggers / touch boundaries |
| UI/UMG controls / animation / binding = ⬜ planned | ✅ Covered | WidgetTests.cpp, controls / layout / animation / focus / events |
| Delegates / events / dynamic delegates = ⬜ | ✅ Covered | Delegate / Multicast / Dynamic / Event tests |
| Handles / weak references / soft references / GC = partial ⬜ | ✅ Covered | Handle / Handles / Weak / Soft / GC tests |
| MasterIndex overall completion ≈ 12% | ❌ Severely underestimated | Actual baseline is 89 files / 980 methods at the initial estimate, with most topics mature |

---

## 4. Documentation Retirement / Migration, Cutover Complete

`Documents/Coverage/` is retired and this OpenSpec record now owns the coverage record. Cutover status:

- ✅ References to `Documents/Coverage/Coverage_*.md` in **38** Coverage test `.cpp` header comments now point to `OpenSpec: test-coverage/coverage-matrix.md`.
- ✅ `.agents/skills/_angelscript-test-guide/SKILL.md` and `SKILL_ZH.md` now point to this record.
- ✅ After redirects completed, the full `Documents/Coverage/` directory was deleted with its 80 files; `git grep "Documents/Coverage"` has no remaining hits.

> The cutover strictly followed "redirect first, then delete", with no dangling-reference window. Edits were limited to comment strings.
