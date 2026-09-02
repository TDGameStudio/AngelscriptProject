# Current overall progress review — 2026-09-01 20:05 CST

## Executive result

- Authoritative OpenSpec completion: **109/136 = 80.1%**.
- Remaining task rows: **27**.
- Recommended engineering-progress estimate: **about 83% (±4%)**.
- Task 5.4 explicit sequencing/single-evaluation is now closed by CTA-S177.
- The product is not default-cutover-ready, final-regression-ready,
  archive-ready or merge-ready. CANONICAL remains opt-in and the broad
  control/lifetime/backend/install/cutover gates remain open.
- There is no single persistent failing test or external blocker. Remaining
  progress is gated by broad acceptance rows whose evidence must be completed
  before their checkboxes may move.

Use **80.1%** when the number must be mechanically auditable from `tasks.md`.
Use **about 83%** for a risk-weighted engineering estimate. The estimate moved
only modestly because closing a difficult correctness surface reduces risk, but
does not eliminate the still-open backend and product-cutover work.

## Exact section status

| Section | Done | Total | Exact |
|---|---:|---:|---:|
| 0 Mandatory AST-first gate | 3 | 5 | 60.0% |
| 1 Baselines | 6 | 6 | 100% |
| 2 SourceManager / AST foundation | 13 | 13 | 100% |
| 3 Public AST / ownership / leases | 8 | 8 | 100% |
| 4 Declaration / namespace / type Sema | 7 | 7 | 100% |
| 5 Expression / statement / call / lifetime Sema | 5 | 10 | 50.0% |
| 6 Cache V2 containment | 12 | 12 | 100% |
| 7 TypedASTJIT migration | 5 | 8 | 62.5% |
| 8 Primary Generate / diagnostics | 9 | 9 | 100% |
| 9 Canonical Bytecode CodeGen | 5 | 9 | 55.6% |
| 10 Product cutover / LEGACY isolation | 2 | 9 | 22.2% |
| 11 Public API / documentation closure | 5 | 5 | 100% |
| 12 Final verification / archive readiness | 4 | 6 | 66.7% |
| 13 Review-blocking convergence work | 8 | 12 | 66.7% |
| 14 Type identity / Runtime-install boundary | 6 | 6 | 100% |
| 15 Canonical lifetime protocol subplan | 11 | 11 | 100% |
| **Total** | **109** | **136** | **80.1%** |

Section 5 has now reached **5/10**. Its remaining rows are broad statement,
control, lifetime and advanced-language umbrellas; their row count understates
their engineering scope.

## Movement from the remembered 102/136 checkpoint

Formal progress moved from **102/136 (75.0%)** to
**109/136 (80.1%)**, a gain of seven rows and 5.1 percentage points:

1. **4.3** — remaining CANONICAL type Sema dependency on the script adapter was
   closed.
2. **4.4** — function/default/named/access/trait/virtual-property/mixin/lambda/
   list-pattern declaration facts were sealed canonically.
3. **4.5** — declaration dependencies, conflicts, inheritance, registration,
   generated lifecycle and diagnostics became Sema-owned.
4. **4.6** — declaration shadow mismatches fail deterministically without
   merging LEGACY and CANONICAL meaning.
5. **5.2** — the accepted expression Sema/builder boundary was closed.
6. **5.3** — the complete ABI-independent call model and historical call-oracle
   audit were closed.
7. **5.4** — explicit sequencing and single-evaluation were closed, including
   the final scalar-reference `+=` alias correctness fix.

The earlier apparent stall at 102 was primarily checklist granularity. Large
CTA-S sequences often strengthened one umbrella for many commits before the
complete source/test/history audit allowed one row to be checked. Task 5.3
needed CTA-S132–S175; Task 5.4 then required the CTA-S176/CTA-S177 review and
several authentic RED/GREEN corrections. The work was moving even when the
numerator did not.

## What CTA-S177 completed

Canonical Sema and CodeGen now preserve explicit, mechanically consumable
ordering for supported:

- property compound assignment and property prefix/postfix rewrite;
- overloaded/raw index compound assignment;
- overloaded index prefix/postfix with receiver/reference/value capture;
- logical short-circuit and conditional value/reference selection;
- value temporary construction/destruction;
- compiler-generated struct/value execution.

The most important review finding involved:

```angelscript
MutateAndReturn()[0] += GetSharedRhs();
```

The first Canonical rewrite captured the address returned by
`GetSharedRhs()` rather than the scalar value `10`. Receiver evaluation changed
that storage to `20`, so Canonical produced `21` instead of the required `11`
despite an apparently correct call trace. Both index-compound branches now
decay scalar references before RHS Opaque capture. Final LEGACY/CANONICAL
execution gives result `11` and exact single-evaluation trace `8,9,2`.

Full case history, root cause, invalid diagnostic attempts and final boundaries
are recorded in
`attachments/canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`.

## Fresh verified checkpoint

Plugin commit: `01c4158` (`[CanonicalAST] Refactor: close explicit sequencing
and alias semantics`).

| Gate | Result | Evidence label |
|---|---:|---|
| final Build after review fixes | PASS | `cta-s177-review-findings-final-build/20260901_195304_206_a8c6bdeb` |
| Semantics after review fixes | **15/15 PASS** | `cta-s177-semantics-review-final/20260901_195326_892_c43b936f` |
| SemaAuthority | **538/538 PASS** | `cta-s177-semaauthority-review-final/20260901_195404_651_f90409d2` |
| Frontend CanonicalAST | **189/189 PASS** | `cta-s177-frontend-review-final/20260901_195549_039_e733d7ab` |
| ProductionCodeGen | **230/230 PASS** | `cta-s177-production-codegen-review-final/20260901_195628_961_558bda16` |
| Build after final test-isolation minor | PASS | `cta-s177-review-minor-final-build/20260901_200257_097_841d5980` |
| Semantics after final test-isolation minor | **15/15 PASS** | `cta-s177-semantics-review-minor-final/20260901_200316_367_3f9c6dc5` |

All final test reports have zero failures and zero skips. Both final subagent
reviews returned APPROVE with no blocker/major. The last diagnostic-isolation
minor was corrected and reverified before closure.

Cache V2/V12 was deliberately not included. The user previously approved
deferring its prototype refactor/testing; it is neither a Task 5.4 gate nor a
reason to keep 5.4 open. The already completed section-6 containment contract
is not being reopened.

## Why engineering progress is about 83%, not 90%+

The architecture is mature: AST foundation, public snapshot ownership, type
identity, Cache containment, diagnostics absorption, declaration Sema, call
Sema, explicit sequencing and the eleven-row lifetime-protocol subplan are
complete. The remaining risk is concentrated in failure-amplifying delivery
surfaces:

- **Statement/control Sema:** 5.5/5.6 must finish block/loop/switch/transfer
  phases and verifier ownership.
- **Lifetime umbrellas:** 5.7/5.8 remain open even though section 15's protocol
  subplan is 11/11; the umbrella acceptance matrix and consumers are broader.
- **Advanced Sema:** 5.9 and 13.2 still cover containers, delegates, closures,
  globals/imports/generated lifecycle and all remaining semantic facts.
- **TypedASTJIT/Bytecode consumers:** 7.2/7.4/7.5 and 9.1/9.5/9.6/13.6 must
  consume authenticated Canonical facts without semantic replay.
- **Publication/differential:** 13.8 snapshot races and 9.7 full SDK/Script
  differential remain open.
- **Product cutover:** section 10 is still 2/9; CANONICAL is not product default
  and no final no-fallback/no-merge matrix authorizes the transition.
- **Final proof:** 0.3, 10.9, 12.2, 12.4 and 13.12 still require one stable
  committed snapshot and complete focused/All results.

These are not cosmetic tail work. An estimate above the high 80s would imply a
level of default-path and final-regression confidence that the repository does
not yet prove.

## Remaining 27 rows by critical path

1. **Continuous AST-first governance:** 0.2 remains open until all dependent
   semantic/cutover cards are closed; 0.3 is the complete pre-default gate.
2. **Sema closure:** 5.5–5.9 and 13.2.
3. **TypedASTJIT closure:** 7.2, 7.4, 7.5.
4. **Bytecode/differential closure:** 9.1, 9.5, 9.6, 9.7 and 13.6.
5. **Snapshot publication:** 13.8.
6. **Product cutover/LEGACY isolation:** 10.1–10.4, 10.6, 10.7 and 10.9.
7. **Final regression/archive readiness:** 12.2, 12.4 and 13.12.

The immediate next implementation row is **5.5**, followed by 5.6. It should
start from focused AST-first statement/control REDs; existing green loop/switch
slices are inputs to the audit, not automatic row completion.

## Worktree/integration state

- `Plugins/Angelscript` is clean at `01c4158` after the CTA-S177 commit.
- The parent is expected to contain only this OpenSpec documentation/gitlink
  update plus the previously preserved unrelated untracked
  `.claude/skills/openspec-design.md` and `list/` entries before the parent
  closure commit.
- Integration with `main` remains a later branch-finishing concern; it does not
  change the current task count or evidence assessment.

## Bottom line

> **Overall engineering progress: about 83%. Formal OpenSpec progress:
> 109/136 = 80.1%.** Task 5.4 is genuinely closed, including a review-discovered
> `+=` scalar-reference alias bug that ordinary trace-only coverage missed. The
> remaining work is the statement/control/lifetime/advanced Sema closure,
> authenticated backend and snapshot consumers, product-default cutover, and
> final focused/All verification—not a mysterious test that has been stuck for
> months.
