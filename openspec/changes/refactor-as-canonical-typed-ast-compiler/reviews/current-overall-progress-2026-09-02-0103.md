# Current overall progress review — 2026-09-02 01:03 CST

## Executive result

- **Authoritative checklist progress:** **110/136 = 80.9%**, with **26 open**.
- **Calibrated engineering progress:** **about 84%**, with an honest range of
  **83–85%**.
- **Task 5.6 implementation progress:** **about 80%**.
- **Task 5.6 closure readiness:** **about 65–70%**.
- **Delivery state:** not ready to check Task 5.6, switch the default pipeline,
  run the final All as closure evidence, archive, merge, or publish.

The auditable number remains **80.9%**. The **about 84%** estimate credits
verified work inside coarse unchecked umbrella rows, but discounts the breadth
and integration risk of the remaining lifetime, Bytecode, publication, entry
point, default-cutover, and final-verification work.

`openspec status` may report `isComplete=true` because the proposal, design,
specification, and task-list artifacts exist. That flag does not mean the
implementation is complete; the task ledger remains the authoritative
implementation count.

## Exact checklist state

| Section | Done | Total | Open |
|---|---:|---:|---:|
| 0 AST-first gate | 3 | 5 | `0.2, 0.3` |
| 1 Baselines | 6 | 6 | — |
| 2 AST foundation | 13 | 13 | — |
| 3 Snapshot / leases | 8 | 8 | — |
| 4 Declaration / type Sema | 7 | 7 | — |
| 5 Statement / lifetime / broad Sema | 6 | 10 | `5.6–5.9` |
| 6 Cache V2 containment | 12 | 12 | — |
| 7 TypedASTJIT | 5 | 8 | `7.2, 7.4, 7.5` |
| 8 Generate / diagnostics | 9 | 9 | — |
| 9 Canonical Bytecode | 5 | 9 | `9.1, 9.5–9.7` |
| 10 Product cutover | 2 | 9 | `10.1–10.4, 10.6, 10.7, 10.9` |
| 11 Public API / docs | 5 | 5 | — |
| 12 Final verification | 4 | 6 | `12.2, 12.4` |
| 13 Review convergence | 8 | 12 | `13.2, 13.6, 13.8, 13.12` |
| 14 Type identity / Runtime boundary | 6 | 6 | — |
| 15 Lifetime protocol subplan | 11 | 11 | — |
| **Total** | **110** | **136** | **26** |

No checkbox changed in this review. The old **102/136** checkpoint has already
moved by eight completed umbrella rows, but CTA-S179 has remained at 110
because Task 5.6 is a single coarse checkbox whose internal RED/GREEN cycles do
not earn formal partial credit.

## Delta since the 00:43 review

### Selector and typed float Case matrix moved from RED to GREEN

The earlier two-case RED was broadened before repair:

- unsupported selectors now cover `bool`, `float`, and an object value;
- float expressions cover float32 `+`, `-`, `*`, `/`, `%`, and `**` beneath an
  explicit integer conversion;
- `16777216.0f + 1.0f` locks float32 per-operation rounding rather than an
  accidental double-width evaluation.

Production Sema now rejects resolved selectors that are neither integral
primitive types nor enums before CodeGen/publication. The floating constant
evaluator now follows the exact typed expression tree and rounds float32 at
each operation.

| Gate | Result | Evidence |
|---|---:|---|
| expanded RED build | **PASS** | `Saved/Build/cta-s179-task56-selector-float-matrix-red-build/20260902_005235_956_1944917a` |
| expanded authentic RED | **0/2 PASS** | `Saved/Tests/cta-s179-task56-selector-float-matrix-red/20260902_005305_985_34c3ccae` |
| repaired-source build | **PASS** | `Saved/Build/cta-s179-task56-selector-object-fixture-build/20260902_005545_670_e69a1289` |
| final focused GREEN | **2/2 PASS**, zero failed/skipped | `Saved/Tests/cta-s179-task56-selector-float-matrix-green2/20260902_005615_177_33480f56` |

This raises Task 5.6 implementation confidence, but it does not close the
umbrella task because the result model still cannot represent the remaining
diagnostic/recovery semantics.

### Three new REDs expose the real constant-evaluator architecture gap

The latest build passed and all three intended behavior tests failed:

| Gate | Result | Evidence |
|---|---:|---|
| bool/recovery RED build | **PASS** | `Saved/Build/cta-s179-task56-bool-recovery-red-build/20260902_005834_332_252e5a70` |
| bool/recovery authentic RED | **0/3 PASS**, 3 failed, 0 skipped | `Saved/Tests/cta-s179-task56-bool-recovery-red/20260902_005904_749_5af3a86a` |

The exact failures are:

1. `SwitchBooleanCaseClassificationMatchesLegacy`: constant bool literal,
   comparison and logical expressions are currently classified as
   nonconstant. They must be classified as constant-but-nonintegral and emit
   the maintained integral diagnostic.
2. `SwitchRuntimeBooleanCasePreservesLegacyDiagnosticSequence`: a runtime bool
   Case currently emits only the nonconstant diagnostic. The maintained
   compiler emits nonconstant first and nonintegral second.
3. `SwitchArithmeticRecoveryContinuesDuplicateDiagnosisMatchesLegacy`: `/0`
   and integer-power overflow currently stop after the arithmetic diagnostic.
   The maintained behavior retains recovery value `0` and continues the Case
   scan, allowing a later `case 0` to emit `Duplicate switch case` as well.

The root cause is architectural rather than three unrelated missing branches.
`TryGetSwitchCaseConstant` currently returns one terminal enum, conflating:

- whether the expression is constant;
- whether its exact type is integral;
- whether a recovery value is available;
- whether divide-by-zero or power-overflow diagnostics occurred.

The repair needs a typed result carrying those facts independently. Domain
normalization must collect source-ordered diagnostics and continue duplicate
analysis with valid recovery values, while preserving the transaction rule
that no selector/Case wrapper is committed and no executable/snapshot is
published when any semantic diagnostic exists.

This is a medium-sized Sema refactor, not an edge-case `if` patch. It is the
main reason Task 5.6 remains only **65–70% closure-ready** even though its
structural-control foundation and most primitive/enum constant cases are
already green.

### Valid enum CodeGen authority has a narrower but important remaining gate

Independent review found that no new hook or hand-built AST is necessary. The
existing prepared-builder path can:

1. construct a real script enum Switch through Parser/Sema;
2. preserve the authored enum Case child as provenance;
3. mutate only the pre-Seal `switch-case-domain.literalBits` through the
   existing AST API;
4. Seal, run production `GeneratePreparedModule()`, and execute the VM result.

The strongest oracle uses authored enumerator value `7` but authenticated fact
`-1`. CodeGen must dispatch using the authenticated nominal-domain fact, not
the provenance child. The negative value additionally proves that the enum
comparison constant is emitted in the VM's signed 32-bit dword domain. The
current generic `SetConst()` path may instead follow the script enum's one-byte
storage size and truncate `0xFFFFFFFF` to `0xFF`. This RED and its smallest
production repair remain open.

### Existing focused GREEN evidence remains valid but is not final-state breadth

- constant/enum Sema matrix: **11/11 PASS** at
  `Saved/Tests/cta-s179-task56-constant-enum-green/20260902_002607_141_01c30edf`;
- primitive authenticated Switch fact CodeGen: **1/1 PASS** at
  `Saved/Tests/cta-s179-task56-codegen-authority-green/20260902_000354_747_483e0b6d`;
- selector/float matrix: **2/2 PASS** at the evidence above.

The final source state still needs fresh owning-prefix runs for Verifier,
Frontend CanonicalAST, SemaAuthority, ProductionCodeGen, Semantics, Module
CanonicalAST Snapshot, and Cache ASTBodySidecar. Older **74/74**, **203/203**,
**547/547**, and Sidecar **25/27** runs predate the latest production edits and
cannot be treated as final closure evidence.

## Why the formal number still appears stuck

The current work is concentrated inside one broad row, Task 5.6. Since the
last formal task update, work has added or repaired:

- typed selector rejection at the Sema boundary;
- primitive and enum normalized Switch-domain facts;
- verifier authentication and Bytecode consumption of those facts;
- integer shape, signedness, width, shift, power and recovery rules;
- float32 typed constant evaluation under explicit integer conversion;
- nominal enum identity, duplicate and cross-enum checks;
- structured target/phase/safe-point verifier, Snapshot and Sidecar V13
  coverage.

Those are real internal advances, but Task 5.6 remains one unchecked row until
all of its semantic and owning-prefix gates pass together. The checklist is
therefore intentionally conservative: it moves in steps, not continuously.

## Remaining work and dependency-correct route

The 26 open rows are all covered by the execution plan, but three ordering
corrections are required:

1. Task `0.2` is a continuous AST-first gate for every applicable production
   slice, not a final-phase-only task.
2. Task `0.3` must be completed before `10.2/10.7` change the default pipeline.
3. Tasks `13.6` and `13.8` span phases: `13.6` cannot close before full-language
   `10.4`, and `13.8` cannot close before the production/default publisher
   audit in the entry-point phase.

The strict route is:

1. resolve the `Tail` minimal oracle and finish Task 5.6;
2. close `5.7–5.9` together with broad Sema authority `13.2`;
3. close TypedASTJIT `7.2/7.4/7.5`;
4. close canonical Bytecode/install/metadata/differential `9.1/9.5–9.7`, pair
   full-language `10.4` with final `13.6`, and advance the non-default portion
   of `13.8`;
5. finish entry points `10.1/10.3/10.6`, run `0.3`, switch the reversible
   default in `10.2`, isolate LEGACY in `10.7`, close final `13.8`, then run
   `10.9`;
6. reconcile all `0.2` cards, run the combined `12.2/13.12` focused matrix,
   then the combined `12.4/13.12` final All;
7. refresh already-checked but now-stale final rows `12.1/12.5/12.6`, audit all
   136 rows, commit the plugin first and then the parent gitlink/reviews.

Archiving remains outside this route unless the user explicitly requests it.

## `+=` and `Tail` record

Four distinct compound-assignment defects remain recorded as resolved:

1. overloaded lvalue `Object += 7` remained a generic Assign instead of a
   resolved operator Call;
2. valid rvalue `Make() += 7` was rejected instead of materialized once;
3. indexed `+=` evaluated RHS/receiver/index in the wrong order;
4. scalar-reference RHS aliasing reread mutated storage and returned `21`
   instead of value-snapshotted `11`.

The `Tail += 100` anomaly is recorded separately and is not yet established as
a fifth compound-assignment bug. The next required oracle is the reduced
function:

```angelscript
int Probe(bool M)
{
    int Tail = 0;
    if (M)
        Tail += 100;
    return Tail;
}
```

It must prove fresh-context `false=0`, `true=100`, same-context
`false -> true -> false = 0 -> 100 -> 0`, and a single exact `Tail` DeclId for
the initializer, compound lhs, and Return DeclRef.

- If it is green, Task 9.2 stays checked and the broad fixture is reduced and
  rerouted.
- If it reproduces, Task 9.2 must reopen and formal progress becomes
  **109/136 = 80.1%**, with different DeclIds routing to Sema/13.2 and identical
  DeclIds plus bad storage routing to Bytecode metadata/layout 9.2/9.6.

The ambiguity must be resolved before final reporting; it cannot remain hidden
under a checked Task 9.2 row.

## Cache V2 boundary

Cache V2/V12 prototype product refactor and restore remain explicitly deferred
by the user. They are not reopened by Task 5.6 and are not counted as a
remaining product-cutover blocker. Active Canonical AST Snapshot/Sidecar V13
validation is still required because it belongs to the current AST
representation, not to the deferred Cache V2 restore product path.

## Working-tree state

- committed plugin checkpoint: `182da08`;
- committed parent checkpoint: `5b8afcd1`;
- current CTA-S179 plugin diff: **23 files**, approximately **5069 insertions /
  250 deletions**;
- touched layers include public AST/Sidecar schema, verifier, expression and
  statement Sema, Bytecode CodeGen, Snapshot API, and tests;
- parent changes contain the plugin gitlink and OpenSpec review/attachment
  records;
- unrelated untracked `.claude/skills/openspec-design.md` and `list/` remain
  preserved outside this change.

The current narrow focused GREENs are useful but not proportional to the size
of this cross-layer diff. A fresh broad matrix is mandatory before Task 5.6 or
the CTA-S179 checkpoint can be considered closed.

## Bottom line

> **Report 80.9% as the formal, auditable progress and about 84% as the single
> engineering-progress estimate.** Task 5.6 is about **80% implemented** but
> only **65–70% closure-ready**. Its remaining work is now well localized:
> orthogonal constant-analysis facts and diagnostic recovery, one valid enum
> CodeGen authority/32-bit-domain gate, the `Tail` ownership decision, and a
> fresh seven-prefix regression matrix.
