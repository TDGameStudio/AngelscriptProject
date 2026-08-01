# Tasks — test-coverage

> This change is the coverage record and audit baseline. Sections 1-4 record the completed migration work. Section 5 records the implemented gap coverage and the completed 2026-08-01 build/test validation pass.
> Current implementation baseline: **89 test-bearing Coverage `.cpp` files**, **90 Coverage `.cpp` files including `AngelscriptCoverageGCTestHelpers.cpp`**, **90 distinct Automation prefixes**, and **1022 `TEST_METHOD`s**.
> Use only project entry points (`Tools\RunBuild.ps1` and `Tools\RunTests.ps1`) for verification, with tests filtered by Automation prefix.

## 1. Scan And Organize, Complete

- [x] 1.1 Scan `AngelscriptTest/Coverage/*.cpp` and extract each file's Automation prefix and `TEST_METHOD` count.
- [x] 1.2 Compare against historical `Documents/Coverage/` documents and identify stale or false-gap claims.

## 2. Write Unified Matrices, Complete

- [x] 2.1 Write `coverage-matrix.md`, listing implemented coverage by category with unified columns and legend.
- [x] 2.2 Write `coverage-gaps.md`, covering pending/enhancement items, fork-unsupported boundaries, and historical mislabel corrections.
- [x] 2.3 Write `specs/as-test-coverage/spec.md`, establishing OpenSpec as the coverage record source of truth.
- [x] 2.4 Split matrices by AS type / feature into 18 domain matrices under `matrices/`, with UStruct, containers, types, object references, physics, input, Widget, networking, timers, and related feature systems documented separately; converge `coverage-matrix.md` into the main index for legend, columns, domain index, and global summary.
- [x] 2.5 Expand all 18 domain matrices into **scenario-level design specifications**: one verifiable scenario per row, with status and the asserting `TEST_METHOD`, so the matrices can guide test implementation. During this work, audit code to calibrate the historical 89 test-file / 1010-method snapshot and close the original false gaps G3/G4.

## 3. Validate Records, Complete

- [x] 3.1 Validate the historical scan point: 89 test-bearing files / 90 themes / about 980 methods in the original estimate, then 89 test-bearing files / 90 themes / 1010 methods after the first reconciliation.
- [x] 3.2 Audit and overturn false gaps, including GC cycles and dynamic material parameters that were already covered, then update matrix status.
- [x] 3.3 Reconcile the current source against every domain summary: keep 89 test-bearing files, record the helper-only 90th `.cpp`, update the total to 1022 methods after the implementation pass, correct all affected domain totals, and remove stale G22/G26 claims.

---

## 4. Documentation Retirement Cutover, Complete

> Goal: retire `Documents/Coverage/`, redirect references to this OpenSpec record, and leave no dangling references.

- [x] 4.1 Redirect `Documents/Coverage/Coverage_*.md` references in 38 Coverage test `.cpp` header comments to `OpenSpec: test-coverage/coverage-matrix.md`.
- [x] 4.2 Update `.agents/skills/_angelscript-test-guide/SKILL.md` and `SKILL_ZH.md` references to `Documents/Coverage/`.
- [x] 4.3 After confirming no other documentation references remain, delete the full `Documents/Coverage/` directory with its 80 files.
- [x] 4.4 Confirm `git grep "Documents/Coverage"` has no remaining hits except explanatory mentions inside OpenSpec records.

## 5. Coverage Gap Implementation, Complete And Verified

> See `coverage-gaps.md §1`. G7/G9/G11-G29 now have implementation, characterization, or explicit unsupported-boundary coverage. The unified build and all previously deferred focused test runs passed on 2026-08-01. New tests follow `_angelscript-test-guide`.

- [x] 5.1 (G1) Extend `AngelscriptCoverageAnimInstanceTests.cpp`: add `AnimInstanceQueryFunctionsExecute`, instantiate an AS `UAnimInstance` using a transient `USkeletalMeshComponent` outer, execute owner / montage / curve queries through reflection, and assert asset-free runtime state. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Animation.AnimInstance"` -> `3/3`.
- [x] 5.2 (G2) Extend `AngelscriptCoverageSaveGameTests.cpp`: assert save -> load round trip for nested struct and array fields. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.SaveGame"` -> `4/4`.
- [x] 5.3 (G3) Audit `TArray<TWeakObjectPtr<T>>` element round trip / invalidation -> **covered** by `WeakObjectPtrArrayContainer` / `HandlesTests::WeakObjectPtrArrayContainerAndReassignment`; close.
- [x] 5.4 (G4) Audit explicit `TObjectPtr<T>` property declaration/read/write -> **covered** by `HandleTests::TObjectPtrRouting` / `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences`; close.
- [x] 5.5 (G5) Measure TArray out-of-bounds `[]` runtime semantics in `AngelscriptCoverageTArrayAdvancedTests.cpp`; add `TArrayOutOfBoundsIndexAccess`, asserting both read and write out-of-bounds `[]` throw the stable script exception `Array index out of bounds.` Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.TArrayAdvanced"` -> `23/23`.
- [x] 5.6 (G6) Extend `AngelscriptCoverageTMapAdvancedTests.cpp`: add round-trip assertions for `TMap<K, user USTRUCT>` values. Existing `TMapValueTypes` only covered FString/FVector/int. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.TMapAdvanced"` -> `11/11`.
- [x] 5.7 (G7) Add `WidgetAnimationAssetFreePlaybackBoundary` to confirm the headless asset-free ceiling and retain reflection coverage for animation/focus surfaces. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Widget"` -> `25/25`.

### 2026-06-30 Second Deep Audit Additions, G8-G29

> See the G8-G29 table in `coverage-gaps.md §1` and the "2026-06-30 Capability-Surface Missing-Row Audit, Second Pass" section. G8/G10 were closed on 2026-07-01; the remaining items now have implementation or explicit boundary disposition. New tests follow `_angelscript-test-guide`, CQTest, and theme-first Automation prefixes.

#### 05-uclass Domain, 3 Items

- [x] 5.8 (G8) Add `UClassDefaultObjectAndInstanceStateIndependence` in `AngelscriptCoverageUClassTests.cpp`: assert runtime CDO mutation affects subsequent `NewObject` defaults, does not retroactively modify existing instances, and instance mutation does not pollute the CDO or later instances. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UClass"` -> `60/60`.
- [x] 5.9 (G9) Resolve the Coverage-layer Actor lifecycle seam: Functional Actor tests already execute Tick / EndPlay / Destroyed, so the Coverage layer keeps declaration plus BeginPlay without duplicating the Functional scenario. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.ClassLifecycle"` -> `9/9`.
- [x] 5.10 (G10) Add `NativeOnlyVirtualOverrideBoundaries` in `AngelscriptCoverageClassLifecycleTests.cpp`, covering compile-failure boundaries for native-only virtuals such as `PostLoad`, `PreSave`, `PostInitProperties`, `BeginDestroy`, `FinishDestroy`, and `Reset` when marked `BlueprintOverride`. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.ClassLifecycle"` -> `9/9`.

#### 06-ustruct Domain, 8 Items

- [x] 5.11 (G11) Add `FInstancedStructCoverageSemantics` for USTRUCT member / UPROPERTY reflection, `FInstancedStruct` container shape, reset behavior, and parameter/return declaration shape. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UStruct"` -> `51/51`.
- [x] 5.12 (G12) Add `UStructNestedContainerCopySemantics` for deep-copy independence across TArray/TMap/TSet members. Verification: same `51/51` prefix run.
- [x] 5.13 (G13) Add `UStructOperatorExpansion` for opSub/opMul/opDiv/opNeg and compound assignments. Verification: same `51/51` prefix run.
- [x] 5.14-5.18 (G14-G18) Add `UStructUnsupportedBoundaryInventory` covering PropertyBag, HasNativeMake/Break, Serialize, NetSerialize, and static-member boundaries. Verification: same `51/51` prefix run.

#### 09-control-flow-language Domain, 1 Item

- [x] 5.19 (G19) Add `ForEachContainerMutationSurface` to lock compile reachability and document that runtime invalidation expectations require a focused follow-up pass. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Loop"` -> `9/9`.

#### 12-input Domain, 10 Items

- [x] 5.20 (G20) Add `EnhancedInputTriggerEventReflectionPreservation` for all five ETriggerEvent values.
- [x] 5.21 (G21) Add ModifyRaw / UpdateState unsupported-boundary coverage through `EnhancedInputAndDeviceBoundaryInventory`.
- [x] 5.22-5.24 (G22-G24) Use `EnhancedInputAndDeviceBoundaryInventory` to prove FOVScaling type exposure, create `UInputTriggerChordAction` and round-trip `ChordAction`, and retain the UserSettings/Profile unsupported boundary; Swizzle remains covered by the runtime mapping matrix.
- [x] 5.25 (G25) Add `LegacyInputPriorityAndConsumeSurface` for InputComponent priority/block state, bConsumeInput variants, and bExecuteWhenPaused.
- [x] 5.26-5.29 (G26-G29) Add device, multi-player, cursor/hover, force-feedback, and haptic unsupported-boundary coverage through `EnhancedInputAndDeviceBoundaryInventory`; `GetInputKeyTimeDown` remains covered by `InputStateQuery`.

Verification for 5.20-5.29: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Input"` -> `25/25`.

## 5b. Assertion-Layer Deep Audit, Complete As A Disposition Record

> Motivation: the user questioned whether every ✅ had been checked at the assertion layer. Apply a mixed standard: capability rows need runtime behavior assertions; pure declaration/reflection/syntax rows may be covered by reflection or compile-level assertions. See the "2026-06-30 Assertion-Layer Deep Audit Record" in `coverage-gaps.md`.

- [x] 5b.1 Deep-audit flagged domains: AnimInstance, SaveGame, Material, AssetLoading, LiteralAsset, Preprocessor, Comment, Const, and OperatorOverload. Confirm most are true behavior assertions; G1 was the only capability compile-only case.
- [x] 5b.2 Add missing rows in the container matrix: G5 for out-of-bounds semantics and G6 for USTRUCT map values.
- [x] 5b.4 Audit capability-surface missing rows by comparing UE/AS capability surfaces with what should be tested: grounded spot checks across 01/02/03/08/10/11/13/14/15 domains. Result is in `coverage-gaps.md`, "2026-06-30 Capability-Surface Missing-Row Audit". Add G7 as a soft Widget animation/focus candidate; other domains are saturated or valid headless ceilings.
- [x] 5b.3 Decide disposition for another line-by-line audit of `05-uclass`, `06-ustruct`, `07`, `09`, and `12`: defer it. Two capability-surface passes already covered all 18 domains; the implementation pass then added the identified semantic and boundary cases. Reopen this as a focused change only when new binding or runtime work justifies it.

## 6. Maintenance Policy, Ongoing And Not A Completion Gate

- When adding or deleting Coverage test files, update the matching scenario rows in `matrices/<domain>.md`, then update the domain counts and global summary in `coverage-matrix.md`.
- If the fork later binds an API currently marked unsupported in `coverage-gaps.md §2`, migrate that row from 🚫 to ⬜ and schedule a focused test or explicitly record why it remains outside scope.
- If a domain matrix becomes too large, split it into sub-files and add the new files to the main index; do not let matrix size silently obscure scenario coverage.

## 7. Completion Boundary

The implementation, matrix synchronization, and validation are complete. On 2026-08-01, `Tools\RunBuild.ps1` succeeded and the previously deferred focused prefixes passed: Widget `25/25`, ClassLifecycle `9/9`, USTRUCT `51/51`, Loop `9/9`, and Input `25/25`.
