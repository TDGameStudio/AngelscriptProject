# Stage 1 — Layout and formatting normalization (done)

## 1. Full-Scope Audit

- [x] 1.1 <!-- Non-TDD --> Expand scope from the old modified-file set to every C++ test file under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` (`89` `.cpp`, `6` `.h`).
- [x] 1.2 <!-- Non-TDD --> Run a repeatable raw-string and source-variable audit over the full Bindings directory.
- [x] 1.3 <!-- Non-TDD --> Run a repeatable inline AS style audit over the full Bindings directory.
- [x] 1.4 <!-- Non-TDD --> Run a repeatable helper-result audit over the full Bindings directory.
- [x] 1.5 <!-- Non-TDD --> Run a repeatable C++ `TEST_CLASS_WITH_FLAGS` column-zero audit over the full Bindings directory.
- [x] 1.6 <!-- Non-TDD --> Run repeatable AS control-flow brace and C++ `TEST_METHOD` column-zero audits over the full Bindings directory.

## 2. Source Refactor

- [x] 2.1 <!-- Non-TDD --> Normalize Bindings inline AS fixtures to `ASTEST_AS(...)` / `ASTEST_AS_ANSI(...)` where they are test source.
- [x] 2.2 <!-- Non-TDD --> Reformat embedded AS snippets to avoid column-zero content, column-zero closers, K&R braces, missing function/class blank lines, and missing `UPROPERTY()` spacing.
- [x] 2.3 <!-- Non-TDD --> Rename generic inline AS source locals where multiple snippets or generated templates need scenario-specific names.
- [x] 2.4 <!-- Non-TDD --> Convert dynamic AS builders away from `FString::Printf(ASTEST_AS(...))` to normalized templates plus token replacement.
- [x] 2.5 <!-- Non-TDD --> Wrap ignored `ExpectGlobal*`, `Execute*`, parity, and math verification helper returns in matcher-backed assertions.
- [x] 2.6 <!-- Non-TDD --> Keep Bindings changes test-only with no runtime/editor binding behavior changes.

## 3. Records

- [x] 3.1 <!-- Non-TDD --> Update `proposal.md` and the spec delta to describe the full Bindings directory audit scope.
- [x] 3.2 <!-- Non-TDD --> Rewrite `file-audit.md` from the stale 39-file issue table into the current 95-file full-scope audit result.
- [x] 3.3 <!-- Non-TDD --> Keep `review-notes.md` as the historical second-review root cause and mark it superseded by the full-scope audit.
- [x] 3.4 <!-- Non-TDD --> Record final build and Bindings automation results in `verification.md`.
- [x] 3.5 <!-- Non-TDD --> Record the Bindings-vs-Coverage responsibility boundary and update the spec so Bindings remains a binding-surface contract layer.

## 4. Stage 1 Verification

- [x] 4.1 <!-- Non-TDD --> Run all four full-directory audits and confirm `issue_files=0`.
- [x] 4.2 <!-- Non-TDD --> Run `git -C Plugins\Angelscript diff --check -- Source\AngelscriptTest\Bindings`.
- [x] 4.3 <!-- Non-TDD --> Run `openspec validate "refactor-bindings-test-layout" --strict --json`.
- [x] 4.4 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label bindings-layout-review-build-final-2 -TimeoutMs 1800000 -NoXGE`.
- [x] 4.5 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-layout-review-final-3 -TimeoutMs 900000`.

# Stage 2 — Responsibility narrowing and source consolidation (implemented)

> Detailed rubric, per-file first-batch disposition, `Bind_*.cpp` contract inventory approach, and migration safety rule live in `contract-scope-plan.md`. Execute batches in the listed order; do not delete before Coverage has an equivalent row.

## 5. Doc realignment (do first, so future work stops duplicating Coverage)

- [x] 5.1 <!-- Non-TDD --> Rewrite `Documents/UnitTest/UnitTest.md` §4 ("Bindings 大矩阵按场景拆成多个 `TEST_METHOD`") to describe Bindings as a binding-surface contract/smoke layer; move "type matrix / API entry-point coverage / boundary / exception" guidance to `Coverage/`. Update the Chinese guide first per doc conventions.
- [x] 5.2 <!-- Non-TDD --> Update `Documents/Guides/TestConventions.md` Bindings rows (currently "按类型的绑定覆盖" at the layer matrix and wave table) to the contract-smoke framing and cross-link `Coverage/`.
- [x] 5.3 <!-- Non-TDD --> Verify `openspec/changes/test-coverage` docs already claim ownership of the matrices Bindings will shed; note any gaps to fill in Coverage before migration.

## 6. Contract inventory and per-file disposition

- [x] 6.1 <!-- Non-TDD --> Produce a `Bind_*.cpp` → Bindings contract-smoke inventory (`~121` binds vs current `90` Bindings `.cpp` files): for each high-value manual bind, mark `has dedicated contract smoke` / `only indirectly covered` / `missing`.
- [x] 6.2 <!-- Non-TDD --> Read each active Bindings `.cpp` and assign one disposition: `Keep as contract`, `Trim to smoke`, `Move/Delete duplicate (Coverage owns it)`, or `Needs missing contract`. Record the table in `contract-scope-plan.md`.
- [x] 6.3 <!-- Non-TDD --> Decide and record the FunctionLibraries mixin placement (keep in Bindings as contract, or split directory/prefix), resolving the `Angelscript.TestModule.FunctionLibraries.*` vs `Angelscript.TestModule.Bindings.*` inconsistency.

## 7. Execute dispositions (per-method map in `contract-scope-plan.md` §First-batch per-method disposition)

Each subtask: (a) if the Coverage target is `ADD FIRST`, add the row + `Coverage/` test and verify it passes; (b) fold the `Keep` methods into the named contract smoke; (c) delete the `Move` methods **and their now-unused file-level `Verify*`/`Run*Section` helpers**; (d) run the file's `Bindings.<...>` prefix.

- [x] 7.2 <!-- Non-TDD --> `AngelscriptFStringBindingsTests.cpp`: keep `Construction`, `Operators`, `OperatorIndexError`, `TypeConcat`, `StaticConstruction`, `ReturnFString`, `PassFString`; move `LengthAndCapacity`/`Substring`/`Search`/`Mutation`/`MutationExtended`/`CaseAndTrim`/`Split`/`SplitExtended`/`Conversion`/`FormatString`/`Join`/`ApplyFormat`/`Logging` (confirm `01-basic-types` §4 rows; `Format`/`Join`/`ApplyFormat` add-first if absent). 21 → ~7 methods.
- [x] 7.3 <!-- Non-TDD --> Containers: `TArray` — fold `TArrayBaseline`/`TArrayIteration`/`TArrayOperations` into `TArrayContractSmoke`, keep one `TArrayNestedContainerRejection` negative, move `TArrayTypeMatrix`/`TArrayObjectTypes`/`TArrayReturnValues`/`TArrayErrorPaths`; `TMap` — keep `TMapContractSmoke` (baseline + `MapFindFailureAndFindOrAddRef`), move `MapTypeMatrix`/`MapApiCoverage`/`MapReturnTypes`/`MapLogDiagnostics`; `TSet` — keep `TSetContractSmoke` (baseline), move `SetTypeMatrix`/`SetApiCoverage`/`SetReturnTypes`/`SetLogDiagnostics`; re-triage `...SetBindingsAdvancedTests.cpp` + `...ContainerCompareBindingsTests.cpp`. All targets are covered in `03-containers`.
- [x] 7.4 <!-- Non-TDD --> WorldCollision: `AngelscriptWorldCollisionBindingsTests.cpp` — split `SyncQueries` into `SyncQueryEntrypointSmoke` (one LineTrace + one Sweep + one Overlap callable); move hit/miss parity + stale-output clearing to `13-physics-collision` §3. Apply same trim to `...FunctionLibraryTraceTests.cpp`, `...FunctionLibraryComponentTests.cpp`, `...AsyncBindingsTests.cpp`, `...AsyncSweepBindingsTests.cpp` (keep async-registration smoke only).
- [x] 7.5 <!-- Non-TDD --> `AngelscriptUObjectBindingsTests.cpp`: keep `CreateAndIdentity`/`NewObjectVariants`/`TypeQueryAndCast`/`ClassReflection`/`NullAndIsValid`/`ReturnValueCrossCheck`/`CppToScriptPassthrough`/`FindAndLookup`; trim `HierarchyAndOuter` to a `GetOuter` contract; move `RootLifecycle`→`04` `GCRootReachability`, `LogAndDiagnostics`→`17`; `FlagMutation` and `ObjectChainAndNesting` are add-first (no clear Coverage row).
- [x] 7.6 <!-- Non-TDD --> `AngelscriptEnhancedInputBindingsTests.cpp`: keep the 8 InputActionValue/BindAction/ConstAccess/RemoveBinding/DebugKey/EditorDelegate methods; move `InputMappingContextRuntimeConstruction` → `12-input` `EnhancedInputMappingContextAndActionValues`. `AngelscriptAssetRegistryBindingsTests.cpp`: keep namespace-function resolvable/callable smoke; move `QueryFilters` live-registry comparison to the assets matrix.
- [x] 7.7 <!-- Non-TDD --> `AngelscriptMathBindingsTests.cpp`: replace `ShortestPathAndTransformSemantics` + `PlanarProjectionAndColorFormatting` with one `MathNamespaceBindSmoke`; move transform/color numerics to `02-math-structs` (shortest-path rotation and planar projection are add-first if absent).
- [x] 7.8 <!-- Non-TDD --> Add missing contract smokes flagged in 6.1 for high-value binds (`Bind_AActor`, `Bind_APlayerController`, `Bind_UActorComponent`, `Bind_USceneComponent`, `Bind_UProjectileMovementComponent`, `Bind_Delegates`, `Bind_BlueprintCallable`, `Bind_BlueprintEvent`, `Bind_BlueprintType`, `Bind_UStruct`).

## 8. Stage 2 Verification

- [x] 8.1 <!-- Non-TDD --> Rerun the Stage 1 full-directory audits; confirm still `issue_files=0`.
- [x] 8.2 <!-- Non-TDD --> `Tools\RunBuild.ps1` (fresh label) passes.
- [x] 8.3 <!-- Non-TDD --> `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings."` passes; record new (smaller) total.
- [x] 8.4 <!-- Non-TDD --> For migrated content, `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage."` passes for the affected matrices.
- [x] 8.5 <!-- Non-TDD --> `openspec validate "refactor-bindings-test-layout" --strict --json` passes; update `verification.md`.
