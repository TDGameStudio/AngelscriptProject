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
| G7 | 🟢 Low | Widget animation/focus runtime assertions | AngelscriptCoverageWidgetTests.cpp | 🟡 | `WidgetAnimationAssetFreePlaybackBoundary` confirms that an asset-free `UWidgetAnimation` has no playable MovieScene in headless mode; animation/focus reflection surfaces remain the supported ceiling |
| G8 | 🟢 Low | UClass CDO and instance independence | AngelscriptCoverageUClassTests.cpp | ✅ | `UClassDefaultObjectAndInstanceStateIndependence` covers CDO mutation affecting later `NewObject` defaults, not retroactively changing existing instances, and instance mutation not polluting CDO or later instances |
| G9 | 🟡 Medium | Coverage-layer Actor Tick/EndPlay/Destroyed parity | AngelscriptCoverageClassLifecycleTests.cpp | ✅ | Functional Actor tests already execute Tick, EndPlay, and Destroyed. The Coverage layer intentionally keeps declaration plus BeginPlay to avoid duplicating the Functional lifecycle seam |
| G10 | 🟢 Low | UObject/Actor native-only virtual BlueprintOverride rejection boundaries | AngelscriptCoverageClassLifecycleTests.cpp | ✅ | `NativeOnlyVirtualOverrideBoundaries` locks compile-failure boundaries for `PostLoad`, `PreSave`, `PostInitProperties`, `BeginDestroy`, `FinishDestroy`, `Reset`, and similar native-only virtuals used as `BlueprintOverride`; legal `OnReset` is still covered by UFunction / Actor lifecycle tests |
| G11 | 🟢 Medium | FInstancedStruct Coverage semantic expansion | AngelscriptCoverageUStructTests.cpp | ✅ | `FInstancedStructCoverageSemantics` covers UPROPERTY reflection, TArray shape, reset behavior, and parameter/return declaration shape; known AS-struct initialization hazards remain documented separately |
| G12 | 🟢 Low | USTRUCT value semantics deep-copy independence | AngelscriptCoverageUStructTests.cpp | ✅ | `UStructNestedContainerCopySemantics` covers deep-copy independence for TArray/TMap/TSet members |
| G13 | 🟢 Low | USTRUCT operator overload subset expansion | AngelscriptCoverageUStructTests.cpp | ✅ | `UStructOperatorExpansion` covers opSub/opMul/opDiv/opNeg and compound assignments |
| G14 | 🟢 Low | FInstancedPropertyBag / FPropertyBag boundary proof | AngelscriptCoverageUStructTests.cpp | 🚫 | `UStructUnsupportedBoundaryInventory` locks the current PropertyBag boundary |
| G15 | 🟢 Low | HasNativeMake / HasNativeBreak specifier boundary proof | AngelscriptCoverageUStructTests.cpp | 🚫 | `UStructUnsupportedBoundaryInventory` locks the current native Make/Break specifier boundary |
| G16 | 🟢 Low | USTRUCT custom `Serialize(FArchive&)` boundary proof | AngelscriptCoverageUStructTests.cpp | 🚫 | `UStructUnsupportedBoundaryInventory` locks the current Serialize boundary |
| G17 | 🟢 Low | USTRUCT `NetSerialize` replication serialization boundary proof | AngelscriptCoverageUStructTests.cpp | 🚫 | `UStructUnsupportedBoundaryInventory` locks the current NetSerialize boundary |
| G18 | 🟢 Low | AS USTRUCT static member boundary proof | AngelscriptCoverageUStructTests.cpp | 🚫 | `UStructUnsupportedBoundaryInventory` locks the current static-member boundary |
| G19 | 🟢 Low | Characterize mutating containers during for-each iteration | AngelscriptCoverageLoopTests.cpp | 🟡 | `ForEachContainerMutationSurface` locks compile reachability and documents that runtime invalidation expectations need a dedicated follow-up assertion once the semantics are chosen |
| G20 | 🟢 Low | EnhancedInput full ETriggerEvent reflection preservation | AngelscriptCoverageInputTests.cpp | ✅ | `EnhancedInputTriggerEventReflectionPreservation` inspects Started/Ongoing/Triggered/Completed/Canceled after AS BindAction calls |
| G21 | 🟢 Low | EnhancedInput Modifier/Trigger `ModifyRaw` / `UpdateState` | AngelscriptCoverageInputTests.cpp | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records the current unbound ModifyRaw/UpdateState surface |
| G22 | 🟢 Low | FOVScaling Modifier reflection ceiling | AngelscriptCoverageInputTests.cpp | 🟡 | `EnhancedInputAndDeviceBoundaryInventory` proves `UInputModifierFOVScaling` is compile-exposed; Swizzle remains covered by the runtime mapping matrix |
| G23 | 🟢 Low | ChordedAction Trigger, distinct from Combo | AngelscriptCoverageInputTests.cpp | ✅ | `EnhancedInputAndDeviceBoundaryInventory` creates `UInputTriggerChordAction` and round-trips its `ChordAction` property |
| G24 | 🟢 Low | EnhancedInputUserSettings / PlayerMappableKeyProfile boundary proof | AngelscriptCoverageInputTests.cpp | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records the current UserSettings/Profile boundary |
| G25 | 🟢 Medium | Legacy InputComponent priority plus Consume/Pause behavior | AngelscriptCoverageInputTests.cpp | ✅ | `LegacyInputPriorityAndConsumeSurface` observes Priority, bBlockInput, bConsumeInput variants, and bExecuteWhenPaused |
| G26 | 🟢 Medium | PlayerController device API boundary proof | AngelscriptCoverageInputTests.cpp | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records GetMousePosition, GetInputMotionState, and GetInputAnalogKeyState; GetInputKeyTimeDown is already covered in InputStateQuery |
| G27 | 🟢 Low | Multi-player input routing, second gamepad / split-screen PlayerController | AngelscriptCoverageInputTests.cpp | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records CreatePlayer/GetPlayerControllerFromID as the current unsupported routing boundary |
| G28 | 🟢 Low | Cursor type / click / hover event boundaries | AngelscriptCoverageInputTests.cpp | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records SetMouseCursor, bEnableClickEvents, and bEnableMouseOverEvents as unsupported boundaries |
| G29 | 🟢 Low | Force Feedback / Haptic API boundaries | AngelscriptCoverageInputTests.cpp | 🚫 | `EnhancedInputAndDeviceBoundaryInventory` records ClientPlayForceFeedback and SetHapticsByValue as unsupported boundaries |

> G7/G9/G11-G29 now have implementation or explicit boundary disposition. Two 🟡 ceilings remain intentionally visible: G7 for asset-free WidgetAnimation playback and G19 for container-mutation runtime semantics. Current Coverage is mature overall at 89 test-bearing files / 90 Coverage `.cpp` files including one helper / **1022** methods. The unified build and focused Widget, ClassLifecycle, USTRUCT, Loop, and Input prefixes passed on 2026-08-01.

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
| 14 Widget/UMG | capability comparison found **G7**, animation/focus reflection-only surfaces | asset-free animation ceiling is now explicitly tested; actual focus transfer remains a headless ceiling |
| 15 networking/RPC | capability comparison | reflection/static surfaces are a **valid headless ceiling** because real multi-machine round trips are outside headless scope; not a gap |

**Overall conclusion**: this suite is highly mature after grounded sampling across all 18 domains. The current implementation baseline is 89 test-bearing files / 90 Coverage `.cpp` files including one helper / 1022 methods. G1/G2/G5/G6/G8/G10 and G11-G29 now have implementation or boundary disposition; G7/G19 remain explicit headless/semantic ceilings. The 2026-08-01 validation pass completed the unified build and all previously deferred focused prefixes.

### 2026-06-30 Capability-Surface Missing-Row Audit, Second Pass: 05/06/07/09/12

> Motivation: the first audit did not cover five large domains. The user requested parallel subagent review of these five domains down to capability-surface rows, with discovered gaps or downgrades recorded in matrices and `coverage-gaps.md`.
> Method: one subagent per domain, checking `TEST_METHOD` assertion layers under the mixed standard and using grep against the UE/AS capability surface to find rows that should be tested but are not. Candidate gaps were grep-verified before adding. Subagents could only modify matching `matrices/0X-*.md`; the main agent summarized G numbers and tasks.

| Domain | Test Method Count | Audit Scope | New G IDs | Main Findings |
|----|----------|---------|-----------|---------|
| 05-uclass | 79 -> **83**, DefaultComponent corrected from 4 to 6, G8 +1, G10 +1 | 5 files and about 16 `Surface/Reflection/Lifecycle` methods checked to assertion layer | **G8 / G9 / G10**, 3 items; all resolved | Implemented but missing matrix row: `ClassFeatures::InterfaceImplementation`, covering script class implementation of native UINTERFACE runtime dispatch plus script-level interface rejection boundary; added ✅ row directly. G8 covers CDO/instance independence. G10 locks native-only virtual rejection boundaries. G9 is resolved by the explicit Functional-versus-Coverage layer decision. |
| 06-ustruct | 51, 16k-line file | 20 capability methods read one by one to assertion layer | **G11-G18**, 8 items | All 51 methods now include FInstancedStruct semantic shape, nested container copy, operator expansion, and explicit PropertyBag/Make/Serialize/NetSerialize/static-member boundary coverage. |
| 07-macros-enum-function-interface | 101 | 5 files grep + spot check | **0 items** | Domain is saturated. Flat tables were rewritten into five scenario-level sections: UEnum, UFunction, UInterface, Macros, MetaSpecifier. No new gaps. |
| 09-control-flow-language | 64 | all 11 files grepped + spot checked | **G19**, 1 item | `ForEachContainerMutationSurface` locks compile reachability; runtime invalidation semantics remain a visible 🟡 ceiling. Other language surfaces are saturated. |
| 12-input | 25 full audit | all 25 methods checked to assertion layer + full Enhanced Input capability comparison | **G20-G29**, 10 items | G20, G23, and G25 have runtime/reflection assertions. G22 proves FOVScaling type exposure; G21/G24 and G26-G29 retain explicit compile-failure boundary inventory. Swizzle is exercised by the runtime mapping-context matrix and GetInputKeyTimeDown is already compile-reachable in InputStateQuery. |

**Combined conclusion across the two historical passes and implementation pass**: at the audit snapshot the suite was recorded as 89 files / **1010** methods. The current implementation baseline is 89 test-bearing files / **1022** methods. All G1-G29 items now have a test implementation, a deliberate Functional-layer disposition, or an explicit 🚫 boundary; G7 and G19 remain visible 🟡 ceilings. `07-macros` remains saturated, and `12-input` now owns explicit boundary inventory for the previously unconfirmed surfaces.

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
| MasterIndex overall completion ≈ 12% | ❌ Severely underestimated | The initial estimate was 89 files / about 980 methods; the current implementation baseline is 89 test-bearing files / 1022 methods, with most topics mature |

---

## 4. Documentation Retirement / Migration, Cutover Complete

`Documents/Coverage/` is retired and this OpenSpec record now owns the coverage record. Cutover status:

- ✅ References to `Documents/Coverage/Coverage_*.md` in **38** Coverage test `.cpp` header comments now point to `OpenSpec: test-coverage/coverage-matrix.md`.
- ✅ `.agents/skills/_angelscript-test-guide/SKILL.md` and `SKILL_ZH.md` now point to this record.
- ✅ After redirects completed, the full `Documents/Coverage/` directory was deleted with its 80 files; `git grep "Documents/Coverage"` has no remaining hits.

> The cutover strictly followed "redirect first, then delete", with no dangling-reference window. Edits were limited to comment strings.
