# TestSource Authored Contract V2 Implementation Tasks

## Execution rules

- The writable implementation scope is `TestSource/**` plus this OpenSpec record. Plugin, host project, tooling, documents, and runner code are read-only evidence unless a later user request explicitly widens scope.
- Every source edit is gated by a reviewed contract row containing `caseId`, `subcaseId`, semantic function name, exact AngelScript declaration, knowledge comment, typed vectors, raw return oracle, `&out`/`&inout` writebacks, exception oracle, fixture, cleanup, and runner status.
- A source file MUST NOT be edited while any callable in that file lacks a predesigned semantic name and exact declaration.
- Hard rename means removing `Observe_*`, `SurfaceNNN`, `*_Nominal`, and generic `ExerciseExpectedFailure` declarations. Do not retain source aliases.
- Each namespace-level function and fixture method MUST have an English knowledge comment immediately above it. The comment identifies CaseId/subcase, role, inputs, raw result/writebacks, ownership or lifecycle boundary, and expected failure when relevant.
- Contract rows store expected values in typed vectors. Do not add `Expected*` parameters to source declarations.
- TDD tasks create a failing validator test first. Pure corpus migrations are marked non-TDD and are verified by contract/source parity plus strict corpus audit.
- Each implementation wave ends with a specification review and code-quality review before the next wave begins. Because this checkout already contains unrelated untracked work, reviews compare the named files and saved baseline snapshots rather than commits.

## 0. OpenSpec record and execution gates

- [x] 0.1 Preserve the pre-V2 proposal, design, tasks, and capability deltas under `attachments/history/2026-08-24-pre-contract-v2/`, and verify the preserved files match the originals before replacement.
- [x] 0.2 Record the exhaustive TArray migration as `attachments/implementation/tarray-contract-v2-audit.md` and the high-risk lifecycle audit as `attachments/implementation/high-risk-lifecycle-audit.md`.
- [x] 0.3 Update proposal, design, and capability deltas so they require Contract V2, hard semantic renames, exact declarations, typed vectors/writebacks, per-callable comments, truthful runner status, and TestSource-only implementation scope.
- [x] 0.4 Align `test-as-source-generation-rules` so authored export consumes only reviewed Contract V2 rows and never infers declarations from semicolon-packed `plannedSymbols`.
- [x] 0.5 Run `openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive` and `openspec validate test-as-source-generation-rules --type change --strict --no-interactive`; do not resume TestSource implementation until both pass.

## 1. Contract V2 infrastructure — TDD

- [ ] 1.1 RED: add focused tests under `TestSource/Generation/python/tests/` proving the validator rejects a missing function comment, legacy symbol, guessed or mismatched declaration, missing `&out`/`&inout` writeback, compound boolean self-oracle, untyped or payload-free vector comparison, contradictory return/exception/diagnostic, missing exception oracle, owner/role/return/parameter/default/annotation drift, duplicate CaseId/subcase, framework fixed-name or legacy-history bypass, and an unsupported verified-status evidence chain.
- [ ] 1.2 RED: add lexer tests that distinguish same declarations in different namespaces/types, class/actor/struct/interface methods, constructors/destructors, operators, delegates/events, imports, free mixins, `function()` and `[](){}` lambdas, properties, annotations, multiline declarations, default arguments, reference directions, trailing comments, and comments/strings containing declaration-like text.
- [ ] 1.3 GREEN: add `TestSource/Generation/schema/authored-case-contract-v2.json` and a lossless owner-qualified AS callable inventory/parser sufficient for all current `TestSource/**/*.as` syntax.
- [ ] 1.4 GREEN: implement deterministic Contract V2 loading, validation, owner/role/return/full-signature source parity, comment adjacency, same-owner uniqueness, comparison-specific vector typing, writeback, exception/diagnostic consistency, fixture, cleanup, fixed-name/legacy-history, and evidence-chain checks.
- [ ] 1.5 GREEN: generate `TestSource/Generation/Contracts/<SourceRelativePath>.json`, `Contracts/index.json`, and `TestSource/Generation/Tasks/<Domain>.md` only from reviewed rows after clean global/source parity; dirty input fails closed before writes and generated task text remains a projection, never the authority.
- [ ] 1.6 Migrate the active authored export so it requires a reviewed source-parity-clean V2 contract; keep v1 rules readable only as `legacy-unreviewed` / `audit-only` evidence and never infer declaration/entryPoint/compile pass from `plannedSymbols`; add the currently omitted `TS-BIND-FINSTANCEDSTRUCT-002::ExerciseExpectedFailure` to baseline parity.
- [ ] 1.7 Run `python -m pytest TestSource/Generation/python/tests -q` and the focused Generation strict audit; request specification and code-quality review for Step 1.

## 2. TArray pilot — exact declarations fixed before implementation

The authoritative function-by-function vectors and required knowledge-comment facts are in `attachments/implementation/tarray-contract-v2-audit.md`. The declarations below are frozen unless the AS compiler proves one of the two documented container-return fallbacks is required; any fallback must update the attachment, contract, and this task before source code changes.

- [ ] 2.1 Create reviewed V2 rows for all 68 declarations below, preserving `TS-BIND-TARRAY-001` through `-008` as CaseIds and the attachment's kebab-case subcaseIds, typed vectors, raw-result oracles, writebacks, and exact exception diagnostics.
- [ ] 2.2 Refactor `Bindings/TArray/Test_ConstructionAndAssignment_01.as` to exactly:
  - `void CopyAssignThenMutateSource(TArray<int32>&inout Source, int32 AppendedValue, TArray<int32>&out Destination)`
  - `void CopyAssignStrings(const TArray<FString>&in Source, TArray<FString>&out Destination)`
  - `bool AssignedMutableIteratorCanProceed(TArray<int32>&inout Values)`
  - `bool AssignedConstIteratorCanProceed(const TArray<int32>&in Values)`
  - `void MoveAssignArray(TArray<int32>&inout Source, TArray<int32>&inout Destination)`
- [ ] 2.3 Refactor `Bindings/TArray/Test_Operators_01.as` to exactly:
  - `int32 WriteIndexedValue(TArray<int32>&inout Values, int32 Index, int32 Replacement)`
  - `int32 ReadIndexedValue(const TArray<int32>&in Values, int32 Index)`
  - `FName ReadIndexedName(const TArray<FName>&in Names, int32 Index)`
  - `bool ArraysEqual(const TArray<int32>&in Left, const TArray<int32>&in Right)`
  - `int32 TriggerIndexReadPastEnd(const TArray<int32>&in Values, int32 Index)`
- [ ] 2.4 Refactor `Bindings/TArray/Test_IndexAndIteration_01.as` to exactly:
  - `bool IsArrayIndexValid(const TArray<int32>&in Values, int32 Index)`
  - `int32 FindFirstValueIndex(const TArray<int32>&in Values, int32 Value)`
  - `bool CopyConstructedMutableIteratorCanProceed(TArray<int32>&inout Values)`
  - `bool CopyConstructedConstIteratorCanProceed(const TArray<int32>&in Values)`
  - `int32 ProceedMutableAtIndex(TArray<int32>&inout Values, int32 ProceedIndex, int32 Replacement, bool&out CanProceedAfter)`
  - `int32 ProceedConstAtIndex(const TArray<int32>&in Values, int32 ProceedIndex, bool&out CanProceedAfter)`
  - `int32 TriggerMutableIteratorProceedPastEnd(TArray<int32>&inout Values)`
- [ ] 2.5 Refactor `Bindings/TArray/Test_Queries_01.as` to exactly:
  - `bool ContainsIntValue(const TArray<int32>&in Values, int32 Value)`
  - `bool ContainsStringValue(const TArray<FString>&in Values, const FString&in Value)`
  - `int32 ArrayCount(const TArray<int32>&in Values)`
  - `int32 ArrayCapacity(const TArray<int32>&in Values)`
  - `int32 ReserveAndReadCapacity(TArray<int32>&inout Values, int32 ReservedSize)`
  - `int64 ReserveAndReadAllocatedBytes(TArray<int32>&inout Values, int32 ReservedSize)`
  - `bool IsArrayEmpty(const TArray<int32>&in Values)`
  - `int32 ReserveAndReadSlack(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
- [ ] 2.6 Refactor `Bindings/TArray/Test_MutationAndLifecycle_01.as` to exactly:
  - `void AddIntValue(TArray<int32>&inout Values, int32 Value)`
  - `void AddStringValue(TArray<FString>&inout Values, const FString&in Value)`
  - `void AddObjectReference(TArray<UObject>&inout Objects, UObject Value)`
  - `void AppendValues(TArray<int32>&inout Values, const TArray<int32>&in Other)`
  - `void ShuffleValues(TArray<int32>&inout Values)`
  - `void InsertValueAtIndex(TArray<int32>&inout Values, int32 Value, int32 Index)`
  - `void InsertValueAtDefaultIndex(TArray<int32>&inout Values, int32 Value)`
  - `bool AddUniqueValue(TArray<int32>&inout Values, int32 Value)`
  - `void EmptyArray(TArray<int32>&inout Values)`
  - `void EmptyArrayWithReserve(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
  - `void ResetArray(TArray<int32>&inout Values)`
  - `void ResetArrayWithReserve(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
  - `void ReserveArrayCapacity(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
  - `void ReserveArrayDefault(TArray<int32>&inout Values, int32&out Capacity)`
  - `void SetArrayNum(TArray<int32>&inout Values, int32 NewNum)`
  - `void SetArrayNumDefault(TArray<int32>&inout Values)`
  - `void SetArrayNumZeroed(TArray<int32>&inout Values, int32 NewNum)`
  - `void SetArrayNumZeroedDefault(TArray<int32>&inout Values)`
  - `void TriggerInsertAtNegativeIndex(TArray<int32>&inout Values, int32 Value, int32 Index)`
- [ ] 2.7 Refactor `Bindings/TArray/Test_MutationAndLifecycle_02.as` to exactly:
  - `int32 RemoveFirstValue(TArray<int32>&inout Values, int32 Value)`
  - `int32 RemoveAllValues(TArray<int32>&inout Values, int32 Value)`
  - `int32 RemoveFirstValueBySwap(TArray<int32>&inout Values, int32 Value)`
  - `int32 RemoveAllValuesBySwap(TArray<int32>&inout Values, int32 Value)`
  - `void RemoveValueAt(TArray<int32>&inout Values, int32 Index)`
  - `void RemoveValueAtBySwap(TArray<int32>&inout Values, int32 Index)`
  - `void SortValuesAscending(TArray<int32>&inout Values)`
  - `void SortValuesByDirection(TArray<int32>&inout Values, bool bDescendingOrder)`
  - `int32 ShrinkReservedArray(TArray<int32>&inout Values, int32 ReservedSize, int32&out SlackBefore)`
  - `void TriggerRemoveAtNegativeIndex(TArray<int32>&inout Values, int32 Index)`
- [ ] 2.8 Refactor `Bindings/TArray/Test_Behavior_01.as` to exactly:
  - `TArray<int32> ConstructEmptyIntArray()`
  - `TArray<FName> ConstructEmptyNameArray()`
  - `void SwapElements(TArray<int32>&inout Values, int32 FirstIndex, int32 SecondIndex)`
  - `int32 ReadLastValueFromEnd(const TArray<int32>&in Values, int32 IndexFromEnd)`
  - `int32 WriteLastValueFromEnd(TArray<int32>&inout Values, int32 IndexFromEnd, int32 Replacement)`
  - `void CopyRangeToStart(TArray<int32>&inout Destination, const TArray<int32>&in Source, int32 SourceIndex, int32 Count)`
  - `void CopyRangeAtIndex(TArray<int32>&inout Destination, const TArray<int32>&in Source, int32 SourceIndex, int32 Count, int32 TargetIndex)`
  - `int32 IncrementMutableValues(TArray<int32>&inout Values, int32 Increment)`
  - `int32 SumConstValues(const TArray<int32>&in Values)`
  - `int32 AddIndicesToMutableValues(TArray<int32>&inout Values)`
  - `int32 SumConstValuesAndIndices(const TArray<int32>&in Values)`
  - `bool MutableIteratorCanProceedAfterSteps(TArray<int32>&inout Values, int32 Steps)`
  - `void TriggerSwapWithNegativeIndex(TArray<int32>&inout Values, int32 NegativeIndex, int32 ValidIndex)`
- [ ] 2.9 Refactor `Bindings/TArray/Test_Behavior_02.as` to exactly `bool ConstIteratorCanProceedAfterSteps(const TArray<int32>&in Values, int32 Steps)`.
- [ ] 2.10 Compile-probe container returns, reference directions, iterator copies, and exact exception diagnostics. If a documented fallback is needed, update contract/design/task first; never silently weaken the function.
- [ ] 2.11 Run focused pytest, TArray source/contract parity, legacy-name zero scan, all 50 MB-100 surface checks, specification review, and code-quality review.

## 3. Remaining Bindings — non-TDD corpus migration

- [ ] 3.1 Inventory every callable under `TestSource/Bindings/**` excluding TArray and generate `attachments/contracts/bindings-function-contracts.md` plus V2 rows. The inventory MUST enumerate every old declaration and its replacement CaseId, subcaseId, semantic name, exact AS declaration, comment facts, typed vectors, fixture, cleanup, and runner status before any corresponding source edit.
- [ ] 3.2 Expand this section from the reviewed inventory into per-file checkbox tasks containing the exact declarations; review the expansion before starting Step 3.3.
- [ ] 3.3 Migrate pure value, text/name, math, enum, struct, delegate, and standard-library bindings, preserving raw non-bool returns and explicit writebacks.
- [ ] 3.4 Migrate TSet/TMap/TOptional/iterator/container bindings with ordered or multiset oracles, aliasing checks, invalidation checks, and exact boundary exceptions.
- [ ] 3.5 Migrate UObject/NewObject/class/function/property bindings using the exact lifecycle declarations and ownership rulings in `attachments/implementation/high-risk-lifecycle-audit.md`.
- [ ] 3.6 Migrate world-dependent, latent, async, networking, input, asset, and subsystem bindings using explicit fixtures and cleanup; mark unsupported runner capabilities truthfully.
- [ ] 3.7 Prove every `Bindings/**` source callable has one reviewed V2 row and adjacent knowledge comment; run strict domain audit plus reviews.

## 4. Containers and Language — non-TDD corpus migration

- [ ] 4.1 Generate and review `attachments/contracts/containers-language-function-contracts.md` with every old-to-new callable and exact declaration before editing either domain; expand this section into per-file tasks.
- [ ] 4.2 Migrate `Containers/**` to external inputs, raw results, explicit alias/writeback observation, deterministic order/multiset rules, and boundary exceptions.
- [ ] 4.3 Migrate `Language/**` operators, casts, references, handles, values, flow control, exceptions, closures, namespaces, templates, and syntax probes without converting compile-only behavior into runtime claims.
- [ ] 4.4 Replace parser-spoofing declarations embedded in comments/strings and make all intentional compile-failure entries exact negative contracts.
- [ ] 4.5 Run strict domain audits, source/compiler probes available in the current runner, and both reviews.

## 5. Definitions and Feature — non-TDD corpus migration

- [ ] 5.1 Generate and review `attachments/contracts/definitions-feature-function-contracts.md`; expand this section into per-file exact-declaration tasks before source edits.
- [ ] 5.2 Migrate `Definitions/**` classes, actors, components, structs, UClass/UFunction/UProperty metadata, delegates, namespaces, and generated-type identity using explicit instance/CDO inputs and typed outputs.
- [ ] 5.3 Migrate `Feature/**`, including inheritance and Blueprint inheritance, with separate CDO-vs-instance state, base-vs-derived dispatch, override-chain, default propagation, and ownership observations.
- [ ] 5.4 Replace the ProcessEvent false-positive case with the predesigned declaration `void ReadProcessEventDispatchState(ATestInhHealthPickup3 Actor, int&out ParentCallCount, int&out ChildCallCount, int&out ChildCollectorHash)` and contract each dispatch count independently.
- [ ] 5.5 Run strict domain audits and lifecycle-focused reviews.

## 6. World, Gameplay, and Optional — non-TDD corpus migration

- [ ] 6.1 Generate and review `attachments/contracts/world-gameplay-optional-function-contracts.md`; include every actor/component/subsystem/timer/delegate fixture, exact declaration, lifecycle phase, cleanup, and isolation flag before editing source.
- [ ] 6.2 Correct all DefaultComponent-null false positives listed in `attachments/implementation/high-risk-lifecycle-audit.md`; spawned actor fixtures observe materialized default components, while CDO observations are separate contracts.
- [ ] 6.3 Migrate Actor/Component/World/Subsystem functions to explicit fixture inputs and independent lifecycle outputs for construction, registration, BeginPlay, ticking, destruction, ownership, and world identity.
- [ ] 6.4 Split GC cases into explicit prepare, release, host-GC, and observe phases; use the audit's exact declarations, `Exclusive` plus `FixtureIsolated`, and do not call script-side GC as a substitute for a host phase.
- [ ] 6.5 Migrate timers so looping handles are cleared unless destruction is the behavior under test; expose callback count, active state, owner validity, and post-destroy behavior independently.
- [ ] 6.6 Migrate delegates so binding, invocation, payload, duplicate policy, unbind/clear, owner destruction, and post-cleanup behavior are separate typed observations.
- [ ] 6.7 Migrate remaining Gameplay and Optional cases, preserving world context, latent/async completion, network/authority boundaries, and cleanup.
- [ ] 6.8 Run strict domain audits, fixture-leak scan, high-risk review, and code-quality review.

## 7. HotReload — non-TDD corpus migration

- [ ] 7.1 Generate and review `attachments/contracts/hotreload-function-contracts.md`; each scenario identifies old/new source version, retained/replaced object identity, property migration, delegate/timer cleanup, compile expectation, and exact callable declarations before source edits.
- [ ] 7.2 Migrate HotReload sources without treating mere compilation as reinstancing proof; expose old/new class identity, object replacement or retention, migrated values, default updates, and dispatch behavior separately.
- [ ] 7.3 Preserve negative and unsupported scenarios with exact diagnostics and truthful `designed`, `compile-verified`, `runner-blocked`, or `strict-pass` status.
- [ ] 7.4 Run strict HotReload audit and lifecycle-focused reviews.

## 8. TestFramework and Debugger — non-TDD corpus migration

- [ ] 8.1 Generate and review `attachments/contracts/testframework-debugger-function-contracts.md`; preserve framework-required discovery names explicitly and predesign all non-required helper names/declarations before source edits.
- [ ] 8.2 Keep framework-required entry names such as `Test_*`, `BeforeAll`, `BeforeEach`, `AfterEach`, and `AfterAll`; encode the naming exception in the contract instead of renaming discovery APIs.
- [ ] 8.3 Migrate framework assertions, lifecycle, latent/network, expected-error, and fixture cases so setup/action/observation/cleanup are individually visible.
- [ ] 8.4 Migrate Debugger cases while preserving required line layout and breakpoint/watch/evaluation semantics; comment adjacency must not invalidate line-sensitive contracts.
- [ ] 8.5 Run strict domain audits, debugger line-map checks, and reviews.

## 9. Full corpus closure

- [ ] 9.1 Generate and review exact callable maps for any remaining `TestSource/**` directory not covered by Steps 3–8, expand this task before editing, and complete its source/contract migration.
- [ ] 9.2 Regenerate all V2 contracts, domain task projections, canonical index, manifests, summaries, and inventories deterministically; a second generation run must produce no diff.
- [ ] 9.3 Require zero source declarations matching `Observe_*`, `Surface[0-9]{3}`, `*_Nominal`, or generic `ExerciseExpectedFailure`, with documented framework exceptions only for actual discovery names.
- [ ] 9.4 Require every discovered callable to have exactly one reviewed contract row and one immediately adjacent knowledge comment; no orphan contract rows or duplicate CaseId/subcase pairs.
- [ ] 9.5 Require typed external inputs, raw results, explicit writebacks, exact exceptions, fixtures, cleanup, and truthful runner status across all 3,041 materialized `.as` sources.
- [ ] 9.6 Reconcile authored rules, MB-100 surfaces, manifests, and source declarations; record any intentionally retired legacy surface with a reviewed replacement mapping rather than an alias.

## 10. Verification and completion

- [ ] 10.1 Run `python -m pytest TestSource/Generation/python/tests -q`.
- [ ] 10.2 Run the full deterministic generation command twice and prove the second pass is clean.
- [ ] 10.3 Run the full strict TestSource validator and zero scans for legacy names, missing comments, zero-argument reason omissions, compound boolean self-oracles, missing writebacks, duplicate identities, fixture leaks, and stale generated files.
- [ ] 10.4 Run every compiler/runner command available without modifying code outside TestSource; classify unexecuted engine-only cases as runner-blocked and do not claim runtime pass.
- [ ] 10.5 Request final specification compliance review and code-quality review; apply findings with the receiving-review workflow and rerun all affected checks.
- [ ] 10.6 Re-run strict OpenSpec validation, reconcile completed checkboxes with evidence, and report changed files, validation results, runner boundaries, and any genuinely blocked external execution.
