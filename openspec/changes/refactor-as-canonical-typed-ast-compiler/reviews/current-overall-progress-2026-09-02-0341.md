# Current overall progress review — 2026-09-02 03:41 CST

## Executive result

- **Authoritative OpenSpec progress:** **111/136 = 81.6%**.
- **Remaining checklist rows:** **25**.
- **Calibrated engineering progress:** **about 86%**, honest range
  **85–87%**.
- **Latest committed semantic checkpoint:** plugin commit `41cafb7`
  (`[CanonicalAST] Refactor: author temporary full-expression lifetime`).
- **Latest advance:** CTA-S182 closes the first direct value-object temporary
  full-expression lifetime-authority slice inside Task 5.7.
- **Formal numerator:** unchanged. Task 5.7 is an umbrella matrix and is still
  open; this checkpoint must not be reported as 112/136.

Use **81.6%** for the mechanically auditable checklist number. Use **about 86%**
for planning. The engineering estimate remains at 86 rather than being raised
for one internal slice because the outstanding rows still concentrate product
risk in lifetime breadth, backend/install closure, default cutover and final
focused/All verification.

## Exact formal state

| Section | Done | Total | Open |
|---|---:|---:|---|
| 0 AST-first gate | 3 | 5 | `0.2, 0.3` |
| 1 Baselines | 6 | 6 | — |
| 2 AST foundation | 13 | 13 | — |
| 3 Snapshot / leases | 8 | 8 | — |
| 4 Declaration / type Sema | 7 | 7 | — |
| 5 Statement / lifetime / broad Sema | 7 | 10 | `5.7, 5.8, 5.9` |
| 6 Cache containment | 12 | 12 | — |
| 7 TypedASTJIT | 5 | 8 | `7.2, 7.4, 7.5` |
| 8 Generate / diagnostics | 9 | 9 | — |
| 9 Canonical Bytecode | 5 | 9 | `9.1, 9.5, 9.6, 9.7` |
| 10 Product cutover | 2 | 9 | `10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9` |
| 11 Public API / docs | 5 | 5 | — |
| 12 Final verification | 4 | 6 | `12.2, 12.4` |
| 13 Review convergence | 8 | 12 | `13.2, 13.6, 13.8, 13.12` |
| 14 Type identity / Runtime boundary | 6 | 6 | — |
| 15 Lifetime protocol subplan | 11 | 11 | — |
| **Total** | **111** | **136** | **25** |

The exact unchecked list from `openspec instructions apply --json` is:

`0.2, 0.3, 5.7, 5.8, 5.9, 7.2, 7.4, 7.5, 9.1, 9.5, 9.6, 9.7,
10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9, 12.2, 12.4, 13.2, 13.6,
13.8, 13.12`.

## What advanced after Task 5.6 closed

CTA-S182 implemented the first remaining source lifetime family identified by
the Task 5.7 audit. For this direct source shape:

```angelscript
struct FTracked
{
    int Value = 41;
}

void Entry()
{
    FTracked();
}
```

Sema now owns the full-expression boundary. The source
`ExprStmt -> Cleanup -> MaterializeTemporary -> Construct` publishes one exact
pointer-free record:

- subject kind `TEMPORARY`;
- action `DESTROY_VALUE` targeting the exact destructor Decl;
- subject and activation equal to the Materialize Expr;
- semantic region equal to the owning ExprStmt;
- phase `FULL_EXPRESSION`;
- supported routes `NORMAL | EXCEPTION`;
- no lexical scope edge and no complete-object commit.

The shared verified lifetime view derives the success-sensitive commit and a
transient full-expression exit plan. Neither Bytecode nor TypedASTJIT chooses a
destructor by name/type scan in this slice.

## Why review mattered

The first apparently green implementation was not accepted. Read-only
subagent review found one Critical and two Important firewall issues:

1. a boolean shape probe conflated “not in this slice” with “supported shape
   is malformed”, allowing a missing/foreign destructor plus no record to evade
   bidirectional completeness;
2. Construct owner/type was not authenticated against the materialized value;
3. Cleanup wrapper type was not authenticated.

Those findings became focused failing verifier tests, then were repaired with
a three-state `NOT_CANDIDATE / MALFORMED / VALID` classifier and exact
constructor/destructor/wrapper ownership checks.

A later complete SemaAuthority gate found a second real regression:
`ClassTemporaryConstructInternsReferenceObjectNotValueObject` failed at
**566/567**. A legal `class C { } ... C();` is a coherent
`REFERENCE_OBJECT + HANDLE + AUTO_HANDLE` temporary, not a value-object
`DESTROY_VALUE` family. The final classifier excludes only a completely
authenticated reference-object shape; a partial reference disguise remains
malformed. The class source gate explicitly proves zero
`TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` records.

The final independent review found no Critical or Important issue and returned
**Ready to commit**. Its remaining observations are non-blocking maintenance
items: the coherent-reference predicate is duplicated in Sema and verifier,
one diagnostic token is narrower than the facts it validates, and an eventual
recovered-statement replay feature may need an idempotent finish hook.

## Fresh verified checkpoint

| Gate | Result | Evidence directory |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-s182-reference-boundary-final/20260902_033534_942_1e2dbb2e` |
| Frontend Verifier | **80/80 PASS** | `Saved/Tests/cta-s182-verifier-final/20260902_033609_637_0e812273` |
| SemaAuthority | **567/567 PASS** | `Saved/Tests/cta-s182-sema-final/20260902_033609_637_f01926f7` |
| Production temporary | **1/1 PASS** | `Saved/Tests/cta-s182-production-final/20260902_033707_375_9a2b3619` |
| AST Body Sidecar | **27/27 PASS** | `Saved/Tests/cta-s182-sidecar-final/20260902_033707_375_b689e880` |

All final test reports have zero failures and zero skips. The production fixture
asserts Canonical publisher and zero LEGACY compiler invocations. It is the
existing return-owned execution fixture; this checkpoint does **not** claim a
new runtime destruction trace for the direct `FTracked();` ExprStmt fixture.

No lifetime-record schema revision was required. The record uses existing
typed fields; `FULL_EXPRESSION` is appended only to the transient derived exit
plan kind. Sidecar round-trip remains green.

## Why Task 5.7 and 5.8 remain open

Task 5.7 requires a complete source-first lifetime matrix, not one temporary
shape. Section 15 has already closed the shared protocol architecture, lexical
local/owning-reference cleanup, success-sensitive activation, constructor
committed prefixes and aggregate cursors. The remaining live source families
are narrower than the historical row text but still substantial:

1. multiple temporaries and call/conditional/Return-owned full expressions;
2. lifetime extension and returned-temporary ownership;
3. non-POD/value-object `&out`, `&inout` and reference-return alias contracts;
4. global initialization failure and reverse shutdown destruction;
5. suspend/resume lifetime ownership and the supported abort/exception matrix;
6. source-authored delegating construction;
7. appropriate Bytecode/TypedASTJIT execution or precise fallback in Tasks
   9.5 and 7.5.

Task 5.8 is an umbrella over the completed section-15 architecture **plus** the
complete Task 5.7 source matrix. Therefore it also remains open. This is not
evidence that section 15 must be rebuilt; it means the remaining source
families must use that shared protocol and pass the owning consumer gates.

## Permanent `+=` record

The compound-assignment ledger remains exactly four resolved defects:

| Defect | Corrected requirement | Status |
|---|---|---|
| overloaded lvalue rewrite | `Object += 7` resolves to exact `opAddAssign` Call | closed |
| rvalue receiver materialization | `Make() += 7` materializes/evaluates the receiver once | closed |
| indexed RHS-first order | required side-effect order is `3,1,2`, not `1,2,3` | closed |
| scalar-reference RHS snapshot | snapshot `10` before mutation and return `11`, not `21` | closed |

`Tail += 100` is **not** a fifth defect. The strengthened reduced oracle is
**1/1 PASS** at `Saved/Tests/cta-s179-tail-declid-strengthened/`
`20260902_011308_781_6e3217c8`; its permanent disposition is
**REDUCED / NOT REPRODUCIBLE**. The long-lived issue history remains in
`reviews/semantic-correctness-issue-ledger-2026-09-01.md`.

## Cache V2 boundary

The user's earlier decision remains authoritative: Cache V2/V12 product
restore redesign is deferred and is not a current completion gate. The AST
Body Sidecar is different: it is the pointer-free Canonical snapshot transport
owned by this change and remains in scope. Its current result is **27/27 PASS**.
This does not reopen or claim the deferred Cache product path.

## Critical path from here

1. Continue Task 5.7 with temporary lifetime extension/Return ownership, then
   deferred/reference/global/suspend/delegating source families; close 5.8 only
   after the complete matrix and its owner consumers are green.
2. Close broad advanced Sema `5.9` and convergence row `13.2`.
3. Finish TypedASTJIT `7.2/7.4/7.5` and Canonical Bytecode/install
   `9.1/9.5/9.6/13.6` without semantic replay.
4. Close full differential `9.7`, snapshot publication/races `13.8`, and
   non-default entry-point isolation.
5. Run pre-cutover `0.3`, then the deliberately late product-default and no-
   fallback rows in section 10.
6. Reconcile rolling Task 0.2 cards, run focused final gate `12.2/13.12`, then
   final All `12.4/13.12`.

## Worktree and integration state

- plugin checkpoint is committed and clean at `41cafb7`;
- parent is pending only the plugin gitlink and this OpenSpec documentation
  checkpoint;
- unrelated `.claude/skills/openspec-design.md` and `list/` remain untouched;
- no Task 5.7/5.8 checkbox was changed, no default-pipeline switch was made,
  and no archive/merge/release claim is made.

## Bottom line

> **Formal progress remains 111/136 = 81.6%; calibrated engineering progress
> remains about 86% (85–87%).** CTA-S182 is a real internal advance: the first
> direct value temporary now has Sema-authored, verifier-authenticated
> full-expression lifetime authority, and review-discovered fail-open and
> reference-object misclassification defects are closed. The numerator does
> not move because Task 5.7 still owns the remaining lifetime source matrix;
> after it, the critical path is TypedASTJIT, Bytecode/install, product cutover
> and final complete verification.
