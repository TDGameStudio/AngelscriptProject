# OpenSpec `tasks.md` schema review for TestSource Contract V2

Date: 2026-08-24  
Mode: plan-only review; no `TestSource`, OpenSpec, plugin, product, runner, or documentation file was modified by this review.  
Target change: `openspec/changes/test-as-manual-bind-source-coverage`

## Executive verdict

The current change is syntactically valid (`openspec validate ... --strict` passes), but its `tasks.md` is not yet review-ready under the user's stronger requirement:

> Before implementation, every source file and every replacement callable must already have its stable identity, semantic name, exact AngelScript declaration, adjacent comment, typed inputs/results/writebacks, vectors, fixture/phase/cleanup, status, and exact verification command fixed in the OpenSpec plan.

The current `tasks.md` has only 69 top-level checkboxes. It fully lists the 68 proposed `Bindings/TArray` declarations, but groups them beneath eight file tasks instead of one callable task each. Sections 3 through 9 explicitly defer detailed design through phrases such as “generate,” “expand this section,” and “any remaining directory.” That is a valid rolling implementation plan, but it is not the complete predesigned plan the user now wants to review.

The four large audit JSONs and their Markdown reports are valuable evidence, and the OpenSpec copies match the scratch copies byte-for-byte except for one trailing blank line in the high-risk Markdown. They are not interchangeable Contract V2 documents. They use four incompatible schemas, contain unresolved blockers, omit concrete vectors in most domains, and disagree with the current canonical callable inventory. They must first be normalized and reconciled; `tasks.md` should then be generated as a complete per-file/per-replacement-callable projection and checked into the OpenSpec change before any further `TestSource` implementation.

## Evidence and coverage reconciliation

### Current canonical source inventory

The implemented V2 scanner currently reports:

```text
sources=3041
callables=11987
```

Top-level scanner counts are:

| Domain | Files | Current scanner callables |
|---|---:|---:|
| Bindings | 576 | 2,556 |
| Containers | 186 | 481 |
| Optional | 116 | 382 |
| Language | 642 | 2,221 |
| Definitions | 519 | 2,073 |
| Feature | 367 | 1,946 |
| World | 123 | 376 |
| Gameplay | 262 | 1,463 |
| HotReload | 209 | 273 |
| TestFramework | 38 | 212 |
| Debugger | 3 | 4 |
| **Total** | **3,041** | **11,987** |

This scanner inventory must be the final source/callable denominator. Audit-specific parser counts are evidence to reconcile, not an alternative denominator.

### Audit artifact coverage

| Audit artifact | Files | Current callables represented by that artifact | Proposed declarations / readiness | Hard gaps before executable tasks |
|---|---:|---:|---|---|
| Bindings / Containers / Optional JSON | 812 | 3,255 | 3,526 replacements: 2,330 `reviewed-exact`, 284 `reviewed-required-name`, 317 `candidate-needs-source-refactor`, 595 `blocking-review-required` | Excludes both TArray subtrees; 117 files have unmatched authored surfaces; no concrete vectors; no callable owner/kind/annotations; generic non-exact diagnostic vector on all 3,255 current rows |
| Language / Definitions / Feature JSON | 1,528 | 6,248 | Claims exhaustive exact proposals | 4,438 callable rows have no owner; no per-row review/blocker state; no concrete vectors; 972 proposed `void` declarations retain non-void `rawReturnType` metadata and need channel/comment reconciliation; 166 source-only files cannot fit current `functions.minItems=1` schema |
| World / Gameplay JSON | 385 | 1,839 | 853 `reviewed-exact`; 986 `blocking-review-required` | 1,128 proposed writebacks are explicitly marked intermediate/raw-type-review-blocked; 10 high-risk file directives contain shorthand ellipses; no concrete vectors; 12 source-only files |
| HotReload / TestFramework / Debugger JSON | 250 | 489 | 484 reviewed by its own audit; 5 blocked | No concrete vectors; per-callable status is encoded indirectly through `runnerStatus`/`blockers`; 50 source-only HotReload files; five line-map/last-good-generation blockers |
| Bindings/TArray Markdown | 8 | 45 current callables | 68 explicit replacements with declarations, vectors, comments, diagnostics, and coverage assignment | Not machine-readable Contract V2; two container-return signatures and several marshalling surfaces still carry explicit compile/runner confirmation gates |
| Containers/TArray | **58** | **98 by the current V2 scanner** | **No dedicated contract audit exists** | Entire subtree is omitted from the four JSONs and from the Bindings/TArray report |

The four JSONs represent 11,831 audit-parser callables. Adding the 45 current Bindings/TArray callables and the current scanner's 98 Containers/TArray callables produces 11,974, still 13 short of the canonical 11,987 scanner count. The mismatch is not uniformly distributed:

- Bindings excluding `Bindings/TArray`: scanner 2,511 versus audit 2,495 — audit is short by 16.
- Containers excluding `Containers/TArray`: scanner 383 versus audit 378 — audit is short by 5.
- Language + Definitions + Feature: scanner 6,240 versus audit 6,248 — audit has 8 extra rows.
- Optional, World + Gameplay, and HotReload + TestFramework + Debugger reconcile numerically.

Therefore, no aggregate task count should be frozen from the audit summaries alone. The normalizer must map every raw audit row back to the canonical scanner's `sourcePath + owner + exact current declaration + callable kind + source position` identity and fail on the 21 missing / 8 extra discrepancy until each row is explained.

### Source-only files conflict with the current Contract V2 schema

The audit artifacts contain at least 230 files with zero parsed callables:

- Bindings / Containers / Optional: 2
- Language / Definitions / Feature: 166
- World / Gameplay: 12
- HotReload / TestFramework / Debugger: 50

The current `authored-case-contract-v2.json` requires `functions` with `minItems: 1`. That makes complete 3,041-source coverage impossible without inventing fake callable entries. The OpenSpec must explicitly plan a source-only contract shape before claiming all-source coverage. Recommended rule:

- `functions` may be empty only when a non-empty `sourceAssertions` block exists.
- `sourceAssertions` identifies declarations/types/properties/version-diff/compile-diagnostic behavior, exact evidence, vectors or diagnostics, fixture, cleanup, and status.
- A source-only task is still a per-file checkbox, but it must not manufacture a callable name.

The 58-file Containers/TArray audit may add more source-only cases; the count above is a lower bound until that subtree is audited.

## Why the four JSON formats cannot feed tasks directly

The raw artifacts use incompatible names and semantics:

| Canonical concept | Bindings / Containers / Optional | Language / Definitions / Feature | World / Gameplay | HotReload / Framework / Debugger | Bindings/TArray Markdown |
|---|---|---|---|---|---|
| File collection | `cases[]` | `files[]` | `files[]` | `sources[]` plus top-level `callables[]` | eight headings |
| Current declaration | `oldDeclaration` | `legacyDeclaration` | `currentExactDeclaration` | `oldDeclaration` | old-callable tables |
| Current owner/kind | absent | `owner` only, null in 4,438 rows; kind absent | explicit owner/kind/namespace/container | explicit owner/kind | namespace in file header; no structured owner/kind |
| Proposed name | parent `semanticName` and each `replacementDeclarations[].semanticName` | `replacementName` | `semanticReplacementName` | `proposedName` | prose semantic name |
| Proposed declaration | parent and split-level `exactDeclaration` | `proposedDeclaration` | `exactProposedDeclaration` | `proposedDeclaration`, often including annotation lines | prose `Declaration:` |
| Split model | one current row can have multiple `replacementDeclarations` | primarily folds compound state into `&out` fields | primarily one row, sometimes high-risk additions at file level | one row | explicit 45-to-68 split |
| Typed inputs | `typedInputs` plus split-level `inputs` | `inputs` | `typedInputs` | `typedInputs` using `asType` | prose vectors |
| Return | `rawResult.type` / split `resultType` | `rawReturnType` | `rawReturn` object | `rawResult.returnType` | prose vector result |
| Writebacks | parent and split-level arrays | array | array, often explicitly intermediate/blocked | nested in `rawResult.writebacks` | prose pre/post vector state |
| Exact vectors | absent | absent | absent | absent | present only in prose |
| Diagnostics | generic `expected-diagnostic`, no exact message | `exceptions` | `exceptionVectors` | `diagnostics` | exact messages in prose |
| Fixture/cleanup | compact `fixture` object | free-text fixture and cleanup | phases, isolation, cleanup | fixture/version/boundary/cleanup fields | prose ownership/boundary |
| Review state | four `declarationReviewStatus` values | absent | two `declarationReviewStatus` values | source `reviewStatus`, callable `blockers`, runner status | “implementation-ready” prose plus six confirmation gates |
| Subcase spelling | CaseId-prefixed `...-SC001[-A]` | snake/dot plus ordinal | lowercase name plus dot ordinal | version plus dot/snake | kebab-case |

Every raw subcase spelling fails the current lowercase-kebab Contract V2 pattern except the TArray prose IDs. This includes all 3,526 BCO replacements, all 6,248 LDF rows, all 1,839 WG rows, and all 489 HFD rows. A deterministic normalization rule is therefore mandatory.

## Required normalized planning record

Before regenerating `tasks.md`, create one OpenSpec-local normalized planning record per source. This is planning evidence, not a second editable TestSource contract. It is frozen by source/audit hashes and is later materialized into the TestSource Contract V2 sidecars without semantic reinterpretation.

Recommended location:

```text
openspec/changes/test-as-manual-bind-source-coverage/
  attachments/contracts/normalized/
    manifest.json
    Bindings.jsonl
    Containers.jsonl
    Optional.jsonl
    Language.jsonl
    Definitions.jsonl
    Feature.jsonl
    World.jsonl
    Gameplay.jsonl
    HotReload.jsonl
    TestFramework.jsonl
    Debugger.jsonl
```

JSON Lines keeps 12,000-plus callable records reviewable and permits deterministic per-domain regeneration. `manifest.json` records the exact input hashes, normalizer version, canonical scanner version/hash, plan revision, file/current-callable/replacement-callable/source-only counts, blocker counts, and output hashes.

Each normalized file record must contain all of the following. A missing mandatory field is a planning blocker, not a value for an implementation agent to infer.

### File identity and drift control

```text
planRevision
taskFileId
sourcePath
sourceSha256
domain
theme
batchId
batchOrdinal
fileOrdinal
caseId
namespace
sourceShape
sourceOnly
lineSensitive
lineMapEvidence
scenario
version
previousVersionSourcePath
nextVersionSourcePath
```

- `sourcePath` is normalized to forward slashes and starts with `TestSource/`.
- `sourceSha256` is the pre-edit source hash used to fail closed on drift.
- HotReload version files keep explicit ordered predecessor/successor relationships; lexical filename order is not assumed.
- Debugger files carry exact line-map evidence and a line-budget decision before per-callable comment insertion.

### Current callable identity

```text
currentCallableId
sourceLine
owner
ownerKind
namespaceScope
callableKind
annotations[]
currentName
currentCoreDeclaration
currentDeclarationBlock
currentBodySha256
legacySymbols[]
legacyDeclaration
splitGroupId
```

- `callableKind` and behavioral `role` are different fields. `method`, `constructor`, `delegate`, `event`, `import`, `mixin`, `lambda`, and `operator` are kinds; `Arrange`, `Act`, `Read`, `Release`, `Cleanup`, `Compile`, and `Framework` are phases/roles.
- `currentDeclarationBlock` includes annotations and the exact declaration formatting needed by source parity. `currentCoreDeclaration` excludes annotations for semantic parsing.
- Anonymous callables use the V2 scanner's stable outer-callable identity plus source position. No fake public function name is invented.

### Replacement callable identity and exact declaration

```text
replacementCallableId
subcaseId
semanticName
disposition
requiredNameReason
zeroArgumentReason
replacementAnnotations[]
replacementCoreDeclaration
replacementDeclarationBlock
parameters[]
return
writebacks[]
bodyPlan[]
prohibitedCalls[]
```

- One normalized row represents one replacement callable. A 1-to-N split emits N rows sharing `splitGroupId`; no proposed callable is hidden inside an array on a single task row.
- `replacementDeclarationBlock` is the exact source text for annotations plus declaration. It must parse back to the separately stored owner, kind, name, return, parameter type/direction/default, qualifiers, and annotations.
- `parameters[]` records exact declaration spelling, name, AS type, direction, default expression, whether the vector supplies or intentionally omits the argument, and value source.
- `bodyPlan[]` records ordered API calls, out assignments, return expression, guards, and cleanup handoff. A declaration alone is not executable when the old compound wrapper must be split.
- `prohibitedCalls[]` records direct lifecycle/timer/delegate/RepNotify/ProcessEvent calls that would recreate a false positive.

### Adjacent knowledge comment

```text
comment.exactText
comment.placement
comment.caseAndSubcase
comment.roleAndPurpose
comment.inputsOrFixture
comment.rawOutputsWritebacksOrSideEffects
comment.boundary
comment.cleanup
comment.requiredNameReason
```

- `exactText`, not only comment facts, belongs in the plan so an implementation agent cannot omit a fact or alter line budgeting.
- For annotated callables the exact placement is above the first callable annotation.
- For lambdas the placement is above the containing assignment/call expression.
- For Debugger line-sensitive files the record states how old line coordinates are preserved or identifies the exact paired expectation update; “be careful with lines” is not executable.

### Concrete typed vectors and diagnostics

```text
vectors[].vectorId
vectors[].phase
vectors[].arguments{}
vectors[].omittedArguments[]
vectors[].fixtureInputs{}
vectors[].expectedReturn
vectors[].expectedWritebacks[]
vectors[].expectedObservations[]
vectors[].expectedSideEffects[]
vectors[].expectedException
vectors[].expectedCompileDiagnostic
vectors[].postFailureState[]
```

Each expected channel records AS type, comparison kind, and the comparison-specific payload. For example:

- `exact` requires a typed value.
- `near` requires a typed value and positive tolerance.
- identity comparisons require named fixture identities.
- ordered/unordered container comparisons require typed elements and duplicate policy.
- `relation` requires named typed operands and an allowed relation identifier, not free-form prose.
- exception and compile diagnostics require phase, category/code when available, exact or explicitly normalized message, source/line/column policy, and recovery/post-failure state.

Arguments omitted to exercise a default parameter must be represented in `omittedArguments`; absence in an object is otherwise ambiguous between “use default” and “forgot to design input.” Expected values never become `Expected*` AngelScript parameters.

### Fixture, invocation, cleanup, and status

```text
fixture.executionMode
fixture.requiredHarness[]
fixture.kind
fixture.instanceKind
fixture.identity
fixture.owner
fixture.class
fixture.outer
fixture.world
fixture.flags[]
fixture.setupPhases[]
fixture.invocationDriver
fixture.readPhase
fixture.cleanupOwner
fixture.cleanupActions[]
fixture.cleanupOn[]
fixture.isolation
fixture.exclusiveReason

status.designState
status.implementationState
status.sourceStrictState
status.compileState
status.runtimeState
status.externalOracleState
status.runnerBlocker
```

Required `instanceKind` values include at least plain object, native CDO, script CDO, Blueprint CDO, spawned native instance, spawned script instance, spawned Blueprint child, pre-reload retained instance, post-reload fresh instance, and replaced descriptor. Encoding all of those only in a free-text fixture identity is too ambiguous for the high-risk cases.

`cleanupOn` must explicitly include success, assertion failure, expected diagnostic, timeout, and early exit where the fixture owns mutable engine state. Timer handles, delegate bindings, actors/components, rooted objects, worlds, modules, globals/CVars, assets, PIE/editor state, and debugger pause/evaluator state are listed as concrete cleanup actions.

Status dimensions are orthogonal. `runner-blocked` is not a substitute for design or source status. A row may be design-reviewed and source-strict while runtime remains blocked; it may not claim compile/runtime/external pass without matching evidence.

### Coverage, evidence, review, and blockers

```text
coverage.authoredRule
coverage.bindingIds[]
coverage.surfaceIds[]
coverage.primaryApis[]
coverage.incidentalApis[]
coverage.cppEvidence[]
coverage.inventoryEvidence[]
coverage.highRiskDirectives[]

verification.staticCommands[]
verification.compileCommand
verification.runtimeCommand
verification.expectedResult

review.normalizationState
review.contractState
review.reviewer
review.reviewedAt
review.reviewedRecordSha256
review.notes

blockers[].code
blockers[].field
blockers[].reason
blockers[].evidenceNeeded
blockers[].resolutionTaskId
```

The current Contract V2 schema's `coverage` object only stores status/evidence and cannot carry MB surface/API ownership. That is insufficient for the TArray MB-100 reconciliation and the 117 BCO files with unmatched surfaces. The OpenSpec plan should require those coverage fields before the later schema/contract implementation task is considered complete.

## Deterministic normalization rules

1. **Canonical inventory wins.** Start with the 3,041 source / 11,987 callable V2 scanner inventory. Left-join every raw audit row to that inventory. Do not manufacture current callables from audit prose.
2. **Exact current key.** Match on `sourcePath + owner + callableKind + current declaration block + source position/body hash`. Name-only or declaration-without-owner matching is forbidden.
3. **Flatten replacements.** BCO `replacementDeclarations[]` and TArray 1-to-N prose become one normalized replacement row each. File-level high-risk `plannedContractAdditions` also become explicit replacement rows, not side notes.
4. **Preserve raw provenance.** Every normalized row records source audit file/hash and raw JSON pointer or Markdown line range.
5. **Normalize subcase IDs mechanically first.** Lowercase the raw ID, replace every non-alphanumeric run with `-`, collapse repeated hyphens, and trim them. Preserve the original as `auditSubcaseId`. If this creates a duplicate `(caseId, subcaseId)`, fail closed for a human semantic resolution; never append an invisible hash or ordinal automatically.
6. **Do not infer word boundaries.** `applyreplicatedhealth.001` may deterministically become `applyreplicatedhealth-001`; a reviewer may improve it to `apply-replicated-health-001`, but that is an explicit reviewed identity change.
7. **Directions come from the exact declaration.** Raw audit terms such as BCO `in`, WG/LDF `value`, and HFD `asType` are parsed into the canonical direction. The audit's direction is then compared and a disagreement blocks the row.
8. **Worst-state review wins.** For a split BCO row, combine parent and replacement statuses; any parent blocker, unmatched surface, placeholder type, generic diagnostic, missing owner, missing vector, or high-risk overlay makes every affected replacement non-executable until resolved.
9. **No placeholder outputs.** Names such as `ObservedCondition01`, `Variant2`, placeholder/generic types, ellipses, free-form “raw state,” and boolean writebacks that merely expose old comparison terms are blocker evidence, not final declarations.
10. **No generic diagnostics.** `expected-diagnostic` without an exact/normalized message, phase, and post-failure policy is not a vector.
11. **Source-only is explicit.** A zero-callable source receives a source-level assertion task and contract; it never gets a fake helper solely to satisfy schema cardinality.
12. **Version/scenario uniqueness.** Ordinary uniqueness is `sourcePath + owner + declaration`. HotReload additionally tracks `scenario + version` and permits the same owner/declaration across ordered versions while forbidding duplicates within one source version.
13. **No silent fallback.** TArray's two approved container-return alternatives are recorded as a decision branch. The primary signature stays provisional until its compile/marshalling gate is resolved; an executor cannot choose a fallback without updating the reviewed record and task.
14. **Hash the reviewed row.** User/independent review approves the normalized row hash. Any later change to declaration, vectors, comment, fixture, cleanup, body plan, or status invalidates approval.

## Blocker-state model

Use blocker states that describe what is missing rather than mixing them with runtime coverage:

| State | Meaning | Can appear in the user review package? | Can source implementation start? |
|---|---|---|---|
| `audit-gap` | Source/callable has no raw audit row, for example Containers/TArray | Yes, as an explicit incomplete blocker report | No |
| `inventory-drift` | Raw audit row does not reconcile with the canonical scanner | Yes | No |
| `owner-kind-unresolved` | Qualified owner/kind/annotations are absent or disagree | Yes | No |
| `signature-unresolved` | Exact declaration contains a placeholder, intermediate output, or unresolved split | Yes | No |
| `vector-unresolved` | Concrete inputs/oracles/writebacks/diagnostics are absent | Yes | No |
| `fixture-unresolved` | Instance kind, phase driver, isolation, or cleanup is incomplete | Yes | No |
| `coverage-unresolved` | Authored surface/API mapping is unmatched or duplicated | Yes | No |
| `line-map-unresolved` | Required per-callable comment would invalidate debugger coordinates | Yes | No |
| `compile-probe-required` | Exact source declaration is selected but needs an allowed compile/ABI decision | Yes, clearly provisional | No, unless the user explicitly accepts the pre-recorded branch |
| `contract-review-ready` | All mandatory design fields are exact; independent/user review is pending | Yes | No |
| `contract-reviewed` | Reviewed row hash, reviewer, and date are recorded | Yes | Yes |
| `runner-blocked` | Source contract is complete but no authorized external runner can execute it | Yes | Yes for source/static work; runtime status stays blocked |

The final “OpenSpec is ready for your review” handoff should have zero `audit-gap`, `inventory-drift`, `owner-kind-unresolved`, `signature-unresolved`, `vector-unresolved`, `fixture-unresolved`, `coverage-unresolved`, and undocumented `line-map-unresolved` rows. `runner-blocked` is acceptable because this change intentionally does not implement the external runner.

Current blocker evidence includes, at minimum:

- 58 unaudited Containers/TArray files / 98 current scanner callables.
- 21 missing and 8 extra current-callable mappings across the existing parser outputs.
- 595 BCO blocking declarations, 317 BCO candidate declarations, and 117 files with unmatched authored surfaces.
- 986 WG blocking declarations, including 1,128 intermediate condition writebacks and 10 shorthand high-risk files.
- five HFD blockers.
- 4,438 LDF rows without a qualified owner and no explicit per-row review state.
- all non-TArray audit formats lacking concrete typed vector arrays.
- at least 230 source-only files that the current schema cannot represent.

## Deterministic `tasks.md` structure

### Header and global constraints

Retain the current scope and hard-rename rules, then add:

- plan revision and normalized-manifest SHA-256;
- canonical baseline `3,041 sources / 11,987 current callables`;
- exact proposed-callable count after reconciliation;
- exact source-only count;
- rule that the complete task plan is frozen before implementation;
- rule that source hashes and reviewed normalized-row hashes are pre-edit gates;
- rule that no implementation agent may “expand later,” invent signatures/vectors/comments, or resolve a blocker implicitly.

### Numbering

Use stable hierarchical identifiers stored in `manifest.json`, not ad-hoc renumbering after every insertion:

```text
WNN.BNN.FNNNN.DNNN   design/blocker resolution
WNN.BNN.FNNNN.CNNN   one replacement callable implementation
WNN.BNN.FNNNN.S000   one source-only assertion implementation
WNN.BNN.FNNNN.V000   per-file strict verification
WNN.BNN.R0000         batch review/reconciliation
```

- `WNN` is the topological wave.
- `BNN` is the deterministic batch from the audit manifest.
- `FNNNN` is assigned once from ordinal-sorted normalized `sourcePath` within the batch and is never renumbered in the same plan revision.
- `CNNN` is ordered by current source line, current callable identity, then split replacement order. New callables from high-risk additions follow the last current callable and use their reviewed planned order.
- `DNNN` exists only for an explicit blocker and disappears only by being completed and replaced with an exact `CNNN` row in a new recorded plan revision.
- All entries use OpenSpec checkbox syntax. There is one callable checkbox per proposed callable, not one checkbox containing a bullet list of several declarations.

Recommended wave topology keeps source ownership disjoint:

1. OpenSpec normalization, count reconciliation, source-only schema decision, and plan validator.
2. Resolve all design blockers and generate the complete review package; no source edits.
3. Bindings/TArray 68-callable pilot.
4. Containers/TArray dedicated audit and implementation, after its complete predesign is reviewed.
5. Critical ProcessEvent / GC / destruction-timer files, assigned to their owning domain batch rather than duplicated.
6. Remaining Bindings / Containers / Optional batches B01-B10.
7. Language / Definitions / Feature batches, high-risk priority first.
8. World / Gameplay batches WG01-WG09.
9. HotReload / TestFramework / Debugger batches B01-B12, respecting ordered versions and line-map gates.
10. Full corpus reconciliation and final reviews.

High-risk overlays change a file's priority and requirements but do not create a second implementation task for the same source path.

### Per-file task template

Every file section should be mechanically rendered in this shape:

````markdown
#### W06.B01.F0001 — `TestSource/Bindings/Example/Test_X.as`

- CaseId: `TS-...`
- Source SHA-256: `...`
- Source shape / execution / isolation: `...`
- Fixture setup and invocation driver: `...`
- Cleanup owner/actions/failure paths: `...`
- Coverage evidence: authored rule, surface IDs, C++ references
- Source status: `contract-review-ready`

- [ ] W06.B01.F0001.C0001 — `<caseId>/<subcaseId>` `<Owner>::<SemanticName>`
  - Current identity: `<owner>`; `<kind>`; line `<n>`; `<exact old declaration block>`
  - Disposition: hard rename / required name / split; required-name reason if applicable
  - Exact adjacent English comment: `// ...`
  - Exact replacement declaration block:

    ```angelscript
    <annotations if any>
    <exact declaration>
    ```

  - Parameters: `<name>: <exact AS type/direction/default/source>`
  - Raw return: `<type/channel>`
  - Writebacks: `<parameter, before/after type and meaning>`
  - Body plan: ordered calls/assignments/return; prohibited direct calls
  - Vectors: every concrete vector with typed arguments, omitted defaults, expected return/writebacks/observations, comparison payload, and exact diagnostic/post-failure state
  - Fixture/phase/cleanup: exact identity, driver, phase, ownership, isolation, cleanup-on paths
  - Static verification: exact command and expected exit/result
  - Runtime verification: exact command, or `runner-blocked: <specific missing capability>`

- [ ] W06.B01.F0001.V000 — run the file/domain strict command, source-drift check, legacy-name scan, coverage reconciliation, and record the evidence paths.
````

For a source-only file, replace `CNNN` rows with one `S000` task containing exact file declarations/assertions, compile/reload/version or diagnostic vectors, fixture/cleanup, and verification. Do not add a no-op function.

### TArray task correction

The existing TArray section is the closest to the requested quality, but it should be projected as 68 callable checkboxes rather than eight file checkboxes containing 68 bullets. Each callable task must include the existing report's exact:

- CaseId/subcaseId;
- semantic name and declaration;
- role/phase;
- MB-100 primary and incidental surface assignment;
- typed vectors and comparison policy;
- adjacent comment text/facts;
- exact exception message where applicable;
- zero-argument reason for the two default constructors;
- one of the explicitly approved runner/compiler branches.

The task plan should reconcile these counts explicitly:

```text
8 sources
45 current callables
68 replacement callables
50 MB-100 surfaces, all mapped at least once
2 legitimate zero-argument replacement callables
```

## Exact verification commands to record in the plan

The existing tasks use phrases such as “focused strict audit,” “full deterministic generation command,” and “run every compiler/runner command available.” Those are not exact commands. The rewritten task plan should use literal commands after the task that creates the invoked interface.

### OpenSpec plan record

```powershell
openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive
openspec validate test-as-source-generation-rules --type change --strict --no-interactive
```

### Canonical current-source inventory

```powershell
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode audit --max-diagnostics 0
```

Expected planning baseline until source migration starts:

```text
sources=3041 contracts=0 callables=11987
```

The non-zero exit is expected because contracts are not materialized; the task must assert the three counts and diagnostic categories rather than call the run “passing.”

### OpenSpec normalized-plan validator

Add an OpenSpec-only planning task that creates this exact interface before using it:

```powershell
python -B openspec/changes/test-as-manual-bind-source-coverage/scripts/normalize_contract_task_plan.py `
  --testsource TestSource `
  --audit-root openspec/changes/test-as-manual-bind-source-coverage/attachments/contracts `
  --high-risk openspec/changes/test-as-manual-bind-source-coverage/attachments/implementation/high-risk-lifecycle-audit.md `
  --tarray openspec/changes/test-as-manual-bind-source-coverage/attachments/implementation/tarray-contract-v2-audit.md `
  --normalized-root openspec/changes/test-as-manual-bind-source-coverage/attachments/contracts/normalized `
  --tasks openspec/changes/test-as-manual-bind-source-coverage/tasks.md `
  --check
```

`--check` must fail without writes on:

- source set not exactly 3,041;
- canonical callable set not exactly 11,987 before implementation;
- missing or extra audit mapping;
- any unresolved review-package blocker;
- invalid/duplicate CaseId-subcase identity;
- missing owner/kind/annotation/signature/comment/vector/fixture/cleanup/status;
- source-only file lacking source assertions;
- task/manifest count or content-hash drift;
- placeholder/ellipsis/intermediate condition output;
- a command in a task that does not exist or lacks an expected result.

The task that creates this script should include focused tests for all five raw input formats and the 1-to-N split model. Until that task is implemented, this command is a planned interface, not current verification evidence.

### Contract tooling tests already present

```powershell
python -B -m pytest TestSource/Generation/python/tests/test_as_callable_inventory_v2.py TestSource/Generation/python/tests/test_as_inventory_current_forms_v2.py -q
python -B -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py TestSource/Generation/python/tests/test_authored_source_export.py -q
python -B -m pytest TestSource/Generation/python/tests -q
```

Current scratch evidence reports 97 tests passing, but OpenSpec tasks 1.1-1.7 are all unchecked. The rewritten task plan should separate “implementation present with recorded GREEN evidence” from “independent re-review pending.” It must not simultaneously describe the infrastructure as wholly pending and cite it as the authoritative current scanner.

### Per-domain source/contract strict validation after later implementation

Use one literal domain per task, for example:

```powershell
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain Bindings/TArray --max-diagnostics 100
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain Containers/TArray --max-diagnostics 100
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain World --max-diagnostics 100
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain Gameplay --max-diagnostics 100
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain HotReload --max-diagnostics 100
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain TestFramework --max-diagnostics 100
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain Debugger --max-diagnostics 100
```

The generated per-file task records the exact enclosing domain command rather than using `<Domain>` placeholders.

### Runtime/UE verification

Use only repository entry points and a literal known test prefix, always with an explicit timeout. Examples that can be assigned only where the contract's C++ evidence maps to that prefix are:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label testsource-v2-bindings -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptDebugger -Label testsource-v2-debugger -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix testsource-v2-all -TimeoutMs 600000
```

Do not assign one of these commands merely because a source is in a similarly named directory. The normalized row must record the actual automation prefix or explicitly state `runner-blocked`. The current TestSource-only change does not provide a typed external runner, so static Contract V2 success must not be promoted to runtime success.

## Field gaps that currently make tasks ambiguous or non-executable

These are hard findings, not optional schema polish:

1. **Missing domain:** all 58 `Containers/TArray` files and their 98 current scanner callables lack a complete audit.
2. **Inventory disagreement:** existing audit parsers are net 13 rows short and hide a 21-missing / 8-extra distribution.
3. **No normalized owner-qualified identity:** BCO has no callable owner/kind/annotations; LDF has 4,438 null owners.
4. **No uniform callable kind:** current V2 parity needs constructor/destructor/operator/delegate/event/import/mixin/lambda/method distinctions, but two audit formats omit them.
5. **All raw subcase formats violate the current lowercase-kebab V2 schema.**
6. **Most domains have no concrete typed vectors.** Input lists and prose boundary rules do not specify actual nominal/empty/null/boundary/repeat/copy/order/exception values.
7. **BCO diagnostics are not exact:** all 3,255 current rows carry a generic expected-diagnostic registration rule, with zero exact messages in that JSON.
8. **Intermediate writebacks are not raw outputs:** 1,128 WG writebacks are explicitly marked blocked pending raw-type review; `ObservedCondition01`-style outputs would merely export the old boolean comparisons.
9. **Review states are incompatible:** BCO has four statuses, WG two, HFD encodes blockers indirectly, LDF has none, and TArray has prose gates.
10. **Source-only files are unrepresentable:** at least 230 audited source files conflict with `functions.minItems=1`.
11. **The V2 coverage schema cannot encode API/surface ownership:** MB-100 and unmatched authored surfaces would be lost.
12. **No ordered body plan:** declarations alone do not tell an agent which old operations to split, which raw values to assign, or which direct callback calls are prohibited.
13. **Fixture kinds are too coarse:** native/script/Blueprint CDO, spawned/fresh/retained/replaced identity is left in free text.
14. **Cleanup is too weak:** a single `cleanupOwner` string cannot enforce success/failure/timeout/early-exit cleanup actions.
15. **Default-argument invocation is ambiguous:** vectors cannot distinguish intentionally omitted arguments from forgotten arguments.
16. **Diagnostic shape is incomplete:** parser/compiler/debugger cases need phase/category/message/line/column/recovery and line-sensitivity policy.
17. **Debugger comment requirement conflicts with line maps unless an exact line-neutral budget or paired expectation update is predesigned.** The latter is outside the current TestSource-only write scope.
18. **TArray still has conditional signatures:** the two container-return fallbacks and marshalling gates are explicit but not yet a single reviewed declaration decision.
19. **Task state drift:** Contract V2 infrastructure and 97-test evidence exist, while every Step 1 checkbox remains unchecked and the progress ledger still says re-review required.
20. **Tasks defer their own required detail:** Sections 3-9 contain future expansion instructions instead of the per-file/per-callable names and declarations the user requested.

## Self-review checklist for the final OpenSpec package

Before handing the OpenSpec back to the user for review, run this checklist against the normalized manifest and generated `tasks.md`:

### Scope and inventory

- [ ] Exactly 3,041 unique `.as` source paths are present.
- [ ] Exactly 11,987 canonical pre-edit callable identities are reconciled, with every audit-only missing/extra row resolved.
- [ ] All 58 Containers/TArray files are included.
- [ ] Every zero-callable source has a source-level assertion contract and no fabricated function.
- [ ] Current-to-replacement count reconciliation is explicit for every split/merge/retirement; no legacy surface disappears silently.

### Identity and declarations

- [ ] Every replacement callable has one stable `(caseId, subcaseId, sourcePath, owner)` identity.
- [ ] Every subcase matches lowercase kebab syntax and duplicates fail closed.
- [ ] Every task shows semantic name and exact annotation-plus-declaration block.
- [ ] Parsed owner, kind, name, return, parameters, directions, defaults, qualifiers, and annotations match the exact block.
- [ ] Required names have a non-empty evidence-based reason; every other forbidden legacy name is hard-renamed without alias.

### Behavior and oracle quality

- [ ] Every externally variable operation input is a typed parameter/fixture input; every legitimate zero-argument callable has a reason.
- [ ] Every API raw return is returned or independently written back; compound comparison booleans are not the sole oracle.
- [ ] Every `out`/`inout` channel has concrete pre/post vectors and a comparison payload.
- [ ] Every vector includes concrete typed values for applicable empty/default/nominal/boundary/false-null/repeat/copy-alias/order/exception dimensions and records non-applicable dimensions explicitly.
- [ ] Every diagnostic is exact or uses a reviewed normalization rule and includes phase plus post-failure/recovery state.
- [ ] No `Expected*`/`bExpect*`, `ObservedConditionNN`, placeholder type, ellipsis, `VariantNN`, “similar to,” “remaining,” or “expand later” survives in an executable callable task.

### Comments, fixtures, and high-risk semantics

- [ ] Every callable task contains the exact immediate English comment and placement.
- [ ] Every World/UObject-like vector distinguishes identity, null, class, Outer/owner, name/flags, world, registration, attachment, and destruction state as applicable.
- [ ] DefaultComponents on spawned fixtures are non-null with exact owner/world/type; CDO observations are separate.
- [ ] ProcessEvent, lifecycle, RepNotify, timer, and delegate acceptance never direct-call the callback being claimed.
- [ ] GC prepare/retain/release/host-collect/read phases cross invocation boundaries and rooted abort cleanup is explicit.
- [ ] HotReload records ordered versions, retained instances, replaced descriptors/bodies/defaults, old-object invocation permission, rollback, and cleanup.
- [ ] TestFramework required registry identities are preserved.
- [ ] Debugger comments have an exact line-map-preservation decision.

### Status, tasks, and commands

- [ ] Every unresolved design blocker has been eliminated before calling the package review-ready; runner blockers remain separately truthful.
- [ ] Every proposed callable is represented by exactly one checkbox task, and every file has exactly one verification task.
- [ ] Task/manifest counts and row hashes reconcile deterministically.
- [ ] Every referenced attachment path and every command exists at the point the task uses it.
- [ ] Every verification command has a literal domain/prefix, expected exit code, and expected result; no “run applicable tests” prose remains.
- [ ] Infrastructure task checkboxes match actual implementation/review evidence.
- [ ] A second plan generation/check produces byte-identical normalized records and `tasks.md`.
- [ ] Both related OpenSpec changes pass strict validation.
- [ ] No further `TestSource` or product implementation was performed during this plan-only review phase.

## Recommended immediate OpenSpec-only sequence

1. Amend design/spec to support source-only contracts, normalized plan records, separate callable kind/phase, concrete side-effect observations, richer fixture/cleanup, API/surface coverage, ordered body plans, blocker states, and reviewed row hashes.
2. Add an OpenSpec-only normalizer/plan-validator task and its exact CLI contract. The implementation of that script remains an OpenSpec planning artifact; do not resume TestSource source migration.
3. Audit the missing 58-file `Containers/TArray` subtree.
4. Reconcile the 21 missing / 8 extra callable differences against the 11,987-callable canonical scanner.
5. Resolve every current signature/vector/fixture/coverage/line-map blocker. Do not convert an unresolved audit row into an implementation checkbox.
6. Normalize all five input formats and generate complete per-source/per-replacement-callable tasks, including 68 individual Bindings/TArray callable checkboxes.
7. Run the self-review and strict OpenSpec validation.
8. Stop and hand the full OpenSpec plan to the user for review. No `TestSource` fixture implementation should resume until that review is accepted.

