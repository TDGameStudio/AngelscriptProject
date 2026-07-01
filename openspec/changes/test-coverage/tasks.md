# Tasks — test-coverage

> This change bridges past and future work: sections 1-3 are **completed records** of existing coverage work, while sections 4-6 are **follow-up work**. Unchecked items remain pending and can continue in later sessions.
> Use only `Tools\RunTests.ps1` for verification, filtered by Automation prefix.

## 1. Scan And Organize, Complete

- [x] 1.1 Scan `AngelscriptTest/Coverage/*.cpp` and extract each file's Automation prefix and `TEST_METHOD` count.
- [x] 1.2 Compare against historical `Documents/Coverage/` documents and identify stale or false-gap claims.

## 2. Write Unified Matrices, Complete

- [x] 2.1 Write `coverage-matrix.md`, listing implemented coverage by category with unified columns and legend.
- [x] 2.2 Write `coverage-gaps.md`, covering pending/enhancement items, fork-unsupported boundaries, and historical mislabel corrections.
- [x] 2.3 Write `specs/as-test-coverage/spec.md`, establishing OpenSpec as the coverage record source of truth.
- [x] 2.4 Split matrices by AS type / feature into 18 domain matrices under `matrices/`, with UStruct, containers, types, object references, physics, input, Widget, networking, timers, and related feature systems documented separately; converge `coverage-matrix.md` into the main index for legend, columns, domain index, and global summary.
- [x] 2.5 Expand all 18 domain matrices into **scenario-level design specifications**: one verifiable scenario per row, with status and the asserting `TEST_METHOD`, so the matrices can guide test implementation. During this work, audit code to calibrate true counts, currently 89 files / 1010 methods, and close the original false gaps G3/G4.

## 3. Validate Records, Complete

- [x] 3.1 Validate matrix summary numbers, 89 files / 90 themes / about 980 methods at the original scan point, against scan results.
- [x] 3.2 Audit and overturn false gaps, including GC cycles and dynamic material parameters that were already covered, then update matrix status.

---

## 4. Documentation Retirement Cutover, Complete

> Goal: retire `Documents/Coverage/`, redirect references to this OpenSpec record, and leave no dangling references.

- [x] 4.1 Redirect `Documents/Coverage/Coverage_*.md` references in 38 Coverage test `.cpp` header comments to `OpenSpec: test-coverage/coverage-matrix.md`.
- [x] 4.2 Update `.agents/skills/_angelscript-test-guide/SKILL.md` and `SKILL_ZH.md` references to `Documents/Coverage/`.
- [x] 4.3 After confirming no other documentation references remain, delete the full `Documents/Coverage/` directory with its 80 files.
- [x] 4.4 Confirm `git grep "Documents/Coverage"` has no remaining hits except explanatory mentions inside OpenSpec records.

## 5. Fill Coverage Gaps, Pending Low/Medium Priority, TDD

> See `coverage-gaps.md §1`. All items are non-blocking; execute individually as needed. New tests must follow `_angelscript-test-guide`.

- [x] 5.1 (G1) Extend `AngelscriptCoverageAnimInstanceTests.cpp`: add `AnimInstanceQueryFunctionsExecute`, instantiate an AS `UAnimInstance` using a transient `USkeletalMeshComponent` outer, execute owner / montage / curve queries through reflection, and assert asset-free runtime state. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Animation.AnimInstance"` -> `3/3`.
- [x] 5.2 (G2) Extend `AngelscriptCoverageSaveGameTests.cpp`: assert save -> load round trip for nested struct and array fields. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.SaveGame"` -> `4/4`.
- [x] 5.3 (G3) Audit `TArray<TWeakObjectPtr<T>>` element round trip / invalidation -> **covered** by `WeakObjectPtrArrayContainer` / `HandlesTests::WeakObjectPtrArrayContainerAndReassignment`; close.
- [x] 5.4 (G4) Audit explicit `TObjectPtr<T>` property declaration/read/write -> **covered** by `HandleTests::TObjectPtrRouting` / `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences`; close.
- [x] 5.5 (G5) Measure TArray out-of-bounds `[]` runtime semantics in `AngelscriptCoverageTArrayAdvancedTests.cpp`; add `TArrayOutOfBoundsIndexAccess`, asserting both read and write out-of-bounds `[]` throw the stable script exception `Array index out of bounds.` Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.TArrayAdvanced"` -> `23/23`.
- [x] 5.6 (G6) Extend `AngelscriptCoverageTMapAdvancedTests.cpp`: add round-trip assertions for `TMap<K, user USTRUCT>` values. Existing `TMapValueTypes` only covered FString/FVector/int. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.TMapAdvanced"` -> `11/11`.
- [ ] 5.7 (G7) Test whether `AngelscriptCoverageWidgetTests.cpp` can add headless runtime assertions for animation playback and focus/input mode, such as animation advancement and focus transfer. If viable, upgrade `WidgetAnimationPlaybackReflectionSurfaces` / `WidgetFocusAndInputModeReflectionSurfaces` from 🟡 to ✅; otherwise record the reflection ceiling. Verification: `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Widget"`.

### 2026-06-30 Second Deep Audit Additions, G8-G29

> See the G8-G29 table in `coverage-gaps.md §1` and the "2026-06-30 Capability-Surface Missing-Row Audit, Second Pass" section. G8/G10 were closed by tests on 2026-07-01; the remaining 20 items are optional enhancements and non-blocking. New tests must follow `_angelscript-test-guide`, CQTest, and theme-first Automation prefixes.

#### 05-uclass Domain, 3 Items

- [x] 5.8 (G8) Add `UClassDefaultObjectAndInstanceStateIndependence` in `AngelscriptCoverageUClassTests.cpp`: assert runtime CDO mutation affects subsequent `NewObject` defaults, does not retroactively modify existing instances, and instance mutation does not pollute the CDO or later instances. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UClass"` -> `60/60`.
- [ ] 5.9 (G9) Extend `ActorLifecycle` / `MultiLevelInheritanceLifecycle` in `AngelscriptCoverageClassLifecycleTests.cpp` with runtime dispatch assertions for Actor Tick / EndPlay / Destroyed, using the Component-side `DispatchComponentTick` + `DestroyComponent` implementation as reference. Verification: `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.ClassLifecycle"`.
- [x] 5.10 (G10) Add `NativeOnlyVirtualOverrideBoundaries` in `AngelscriptCoverageClassLifecycleTests.cpp`, covering compile-failure boundaries for native-only virtuals such as `PostLoad`, `PreSave`, `PostInitProperties`, `BeginDestroy`, `FinishDestroy`, and `Reset` when marked `BlueprintOverride`. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.ClassLifecycle"` -> `9/9`.

#### 06-ustruct Domain, 8 Items

- [ ] 5.11 (G11) Extend `AngelscriptCoverageUStructTests.cpp`: cover `FInstancedStruct` as a USTRUCT member / UPROPERTY reflection, `InitializeAs<FFoo>` / `Get<FFoo>()` round trip, and container/parameter forms. The fork already binds it in `Bind_FInstancedStruct.cpp`. Verification: `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.UStruct"`.
- [ ] 5.12 (G12) Extend `UStructValueSemantics`: assert deep-copy independence for structs containing TArray/TMap/TSet members, where mutating copied containers does not affect source containers. Verification: same as above.
- [ ] 5.13 (G13) Extend `UStructOperators`: add runtime assertions for `opSub`, `opMul`, `opDiv`, `opNeg`, and compound assignments `opAddAssign`, `opSubAssign`, `opMulAssign`, `opDivAssign`. Verification: same as above.
- [ ] 5.14 (G14) Add one compile-failure row in the USTRUCT boundary domain for `FInstancedPropertyBag Foo;` / `FPropertyBag Foo;`; expected 🚫, then move to the boundary matrix after confirmation. Verification: same as above.
- [ ] 5.15 (G15) Add one compile-failure row for USTRUCT `HasNativeMake` / `HasNativeBreak` specifiers; expected 🚫. Verification: same as above.
- [ ] 5.16 (G16) Add one compile-failure row for declaring `void Serialize(FArchive& Ar)` inside USTRUCT; expected 🚫. Verification: same as above.
- [ ] 5.17 (G17) Add one compile-failure row for declaring `bool NetSerialize(FArchive&, UPackageMap*, bool&)` inside USTRUCT; expected 🚫. Verification: same as above.
- [ ] 5.18 (G18) Add one compile-failure row for `static int Foo;` inside AS USTRUCT; expected 🚫 and related to the `BindStatic` boundary in §2.4. Verification: same as above.

#### 09-control-flow-language Domain, 1 Item

- [ ] 5.19 (G19) Extend `AngelscriptCoverageLoopTests.cpp::ForEach`: add runtime semantic assertions for modifying containers with Add/Remove during for-each iteration, documenting iterator invalidation or legal behavior. Verification: `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Loop"`.

#### 12-input Domain, 10 Items

- [ ] 5.20 (G20) Extend `EnhancedInputComponentBindingEventsAndRemoval` / `EnhancedInputBindingHandlesAndRemoval`: add reflection-preservation assertions for `GetTriggerEvent()` covering Ongoing, Completed, and Canceled.
- [ ] 5.21 (G21) Extend `EnhancedInputModifiersAndTriggers`: add reflection or behavior assertions for `ModifyRaw` / `UpdateState`.
- [ ] 5.22 (G22) Add reflection-ceiling or compile-failure boundaries for Swizzle / FOVScaling modifiers. Swizzle is exposed in the Bindings domain but missing in Coverage; FOVScaling has zero grep references.
- [ ] 5.23 (G23) Add reflection or compile-failure boundary coverage for ChordedAction Trigger, separate from existing Combo coverage.
- [ ] 5.24 (G24) Add compile-failure boundaries for EnhancedInputUserSettings / PlayerMappableKeyProfile.
- [ ] 5.25 (G25) Extend legacy InputComponent tests: after setting `bConsumeInput`, `bExecuteWhenPaused`, and `Priority` with Block / Override / DontBlock behavior, add reflection or runtime assertions for the input chain.
- [ ] 5.26 (G26) Add independent compile-failure boundaries for `GetMousePosition`, `GetInputMotionState`, `GetInputAnalogKeyState`, and `GetInputKeyTimeDown`, which have zero fork bindings by grep.
- [ ] 5.27 (G27) Add multi-player input routing tests, covering CreatePlayer / GetPlayerControllerFromID / second controller InputComponent isolation through reflection or behavior.
- [ ] 5.28 (G28) Add compile-failure boundaries for cursor type, click events, and hover events, including `SetMouseCursor`, `bEnableClickEvents`, and `bEnableMouseOverEvents`.
- [ ] 5.29 (G29) Add compile-failure boundaries for Force Feedback / Haptic APIs such as `ClientPlayForceFeedback` / `SetHapticsByValue`.

Verification for 5.20-5.29: `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Input"`.

## 5b. Assertion-Layer Deep Audit, First Pass Complete On 2026-06-30

> Motivation: the user questioned whether every ✅ had been checked at the assertion layer. Apply a mixed standard: capability rows need runtime behavior assertions; pure declaration/reflection/syntax rows may be covered by reflection or compile-level assertions. See the "2026-06-30 Assertion-Layer Deep Audit Record" in `coverage-gaps.md`.

- [x] 5b.1 Deep-audit flagged domains: AnimInstance, SaveGame, Material, AssetLoading, LiteralAsset, Preprocessor, Comment, Const, and OperatorOverload. Confirm most are true behavior assertions; G1 was the only capability compile-only case.
- [x] 5b.2 Add missing rows in the container matrix: G5 for out-of-bounds semantics and G6 for USTRUCT map values.
- [x] 5b.4 Audit capability-surface missing rows by comparing UE/AS capability surfaces with what should be tested: grounded spot checks across 01/02/03/08/10/11/13/14/15 domains. Result is in `coverage-gaps.md`, "2026-06-30 Capability-Surface Missing-Row Audit". Add G7 as a soft Widget animation/focus candidate; other domains are saturated or valid headless ceilings.
- [ ] 5b.3 Optional expansion: later audit large domains not line-by-line checked yet, such as `05-uclass`, `06-ustruct`, `07`, `09`, and `12`, using capability-surface and mixed standards. Expected yield is limited.

## 6. Maintenance Rules, Ongoing

- [ ] 6.1 When adding or deleting Coverage test files later, first update the matching row in `matrices/<domain>.md`, then update the domain file/method counts and global summary in `coverage-matrix.md`.
- [ ] 6.2 If the fork later binds APIs currently marked unsupported in `coverage-gaps.md §2`, migrate the row from 🚫 to ⬜ and schedule a test.
- [ ] 6.3 If a single domain matrix grows too large, such as `06-ustruct.md` for a 16k-line test file, split it into sub-files and add rows to the main index.
