# Current overall progress review — 2026-09-02 00:08 CST

## Executive result

- Authoritative OpenSpec completion remains **110/136 = 80.9%**.
- **26** task rows remain unchecked.
- Recommended risk-weighted engineering estimate remains **about 84%**;
  use **84–85%** as the honest current range rather than rounding the local
  Task 5.6 work into a completed umbrella row.
- Task 5.6 itself is approximately **70–75% complete internally**. This is an
  engineering estimate over its focused gates, not a new checkbox count.
- The newest real closure is primitive Switch CodeGen authority: CodeGen now
  consumes the verifier-authenticated `switch-case-domain.literalBits` instead
  of re-evaluating the authored provenance child.
- Task 5.6 is still not checkable. Legacy-equivalent Case constant folding and
  diagnostics, plus the enum Case constant-expression firewall, remain hard
  correctness blockers.
- CANONICAL remains opt-in. The change is not default-cutover-ready,
  final-regression-ready, archive-ready, or merge-ready.

Use **80.9%** when an auditable task percentage is required. Use **about 84%**
for overall engineering progress. The latter includes substantial partially
complete umbrella rows but discounts the still-large lifetime, backend,
publication, cutover, differential and final-All gates.

## Exact task ledger

| Section | Done | Total | Exact |
|---|---:|---:|---:|
| 0 Mandatory AST-first gate | 3 | 5 | 60.0% |
| 1 Baselines | 6 | 6 | 100% |
| 2 SourceManager / AST foundation | 13 | 13 | 100% |
| 3 Public AST / ownership / leases | 8 | 8 | 100% |
| 4 Declaration / namespace / type Sema | 7 | 7 | 100% |
| 5 Expression / statement / call / lifetime Sema | 6 | 10 | 60.0% |
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
| **Total** | **110** | **136** | **80.9%** |

The formal numerator has moved from the remembered **102/136 = 75.0%**
checkpoint to **110/136 = 80.9%**. The eight-row gain closed call semantics,
explicit sequencing/single evaluation, positive statement/control geometry and
related prerequisite rows. It has not moved during CTA-S179 because Task 5.6
is intentionally one coarse umbrella row: partial implementation does not earn
a checkbox.

## Task 5.6 internal state

### Code-fixed, but complete owning-prefix validation is still pending

- Last-Case targetless `fallthrough;` compatibility and malformed fallthrough
  payload handling.
- Same-parent repeated-child rejection and structural incoming-edge checks.
- Structured For/Foreach phase-kind validation and transfer leaf invariants.
- Loop-body safe-point edge representation through Sidecar/public schema V13,
  without overwriting the body node's intrinsic role.
- Primitive signed/unsigned 32-bit selector comparison-domain facts and
  normalized duplicate Case checking.
- Primitive CodeGen consumption of the authenticated domain fact.

The last item has an authentic provenance-disagreement RED and GREEN:

| Gate | Result | Evidence |
|---|---:|---|
| authority RED | **0/1 PASS**; normal execution observed default `90` | `Saved/Tests/cta-s179-task56-codegen-authority-red5/20260902_000156_273_f7beb309` |
| repair build | **PASS** | `Saved/Build/cta-s179-task56-codegen-authority-green-build/20260902_000335_787_7eed5198` |
| authority GREEN | **1/1 PASS** | `Saved/Tests/cta-s179-task56-codegen-authority-green/20260902_000354_747_483e0b6d` |

The forged pre-Seal graph deliberately stores fact `9` over authored child `7`.
Before the repair, execution finished normally but selected the default branch;
after the repair, the authenticated fact selects the Case branch. The authored
child is now provenance only and is not emitted by primitive Switch CodeGen.

### Still open and blocking Task 5.6

1. **Legacy Case constant evaluator parity.** The focused REDs currently cover
   logical `>>`, arithmetic `>>>`, 32-bit shift masking, integer `**`, mutable
   global rejection, readonly local constants, explicit float-to-int constants,
   `MIN / -1` recovery, divide-by-zero, power overflow and
   `asEP_DISABLE_INTEGER_DIVISION`.
2. **Exact diagnostics.** The Canonical route must preserve `Divide by zero`,
   `Overflow in exponent operation`, `Switch expressions must be integral
   numbers`, and `Case expressions must be constants` without constructing
   `asCCompiler`.
3. **Enum Case firewall.** Enum selectors still need common constant validation,
   nominal enum identity, `typeCheckSwitchEnums` behavior and sealed duplicate
   authority. A runtime parameter must never survive as an executable Case
   expression.
4. **Fresh complete regressions.** All broad results below predate the newest
   CodeGen change and therefore remain useful baselines, not final closure
   evidence.

Current authentic RED groups:

| Gate | Result | Evidence |
|---|---:|---|
| constant subset | **0/5 PASS** | `Saved/Tests/cta-s179-task56-constant-subset-red2/20260901_234351_125_d7df4012` |
| constant edge/diagnostic | **0/3 PASS** | `Saved/Tests/cta-s179-task56-constant-edge-red/20260901_234838_108_c1fd0e8c` |
| Sidecar V13 maintenance baseline | **25/27 PASS**; two stale schema assertions, already corrected | `Saved/Tests/cta-s179-task56-sidecar-v13-red/20260901_233258_737_abfbe8d1` |

## Latest broad baseline and its limitation

Before the newest selector-evaluator and CodeGen-authority edits, the local
checkpoint was:

| Prefix | Result | Evidence |
|---|---:|---|
| Verifier | **74/74 PASS** | `Saved/Tests/cta-s179-task56-verifier-final2/20260901_232834_394_e50312af` |
| Frontend CanonicalAST | **203/203 PASS** | `Saved/Tests/cta-s179-task56-frontend-final/20260901_232909_568_030a26ed` |
| SemaAuthority | **547/547 PASS** | `Saved/Tests/cta-s179-task56-semaauthority-final/20260901_232951_094_5060898a` |

These results prove that the structured-control repair had a broad green
checkpoint, but they cannot close Task 5.6 after subsequent production edits.
Fresh Verifier, Frontend, SemaAuthority, ProductionCodeGen, Semantics,
Snapshot/API and Sidecar V13 owning-prefix runs are still required.

## Related correctness ledger

The related `+=` history is recorded as four distinct resolved defects, not one
repeated issue:

1. overloaded lvalue `Object += 7` remained generic Assign;
2. valid rvalue `Make() += 7` was rejected instead of materializing once;
3. indexed `+=` used the wrong RHS/receiver/index evaluation order;
4. scalar-reference RHS aliasing re-read mutated storage.

The `Tail += 100` anomaly remains a separate open local-slot/declaration
identity issue under Task 9.2/9.6. Evidence currently indicates that it is not
a fifth compound-assignment semantic bug: both control paths acquire the same
bad scalar, including the path that never executes the compound write.

Exact symptom, cause, RED/GREEN and status details live in
`reviews/semantic-correctness-issue-ledger-2026-09-01.md`.

## Remaining 26 rows by critical path

1. Task 5.6 constant/enum closure and fresh broad validation.
2. Lifetime and advanced Sema umbrellas: 5.7–5.9 and 13.2.
3. TypedASTJIT consumers: 7.2, 7.4 and 7.5.
4. Bytecode/differential closure: 9.1, 9.5–9.7 and 13.6.
5. Snapshot publication/races: 13.8.
6. Product entry points/default cutover: 10.1–10.4, 10.6, 10.7 and 10.9.
7. Complete AST-first/final evidence: 0.2, 0.3, 12.2, 12.4 and 13.12.

Cache V2/V12 prototype refactoring remains user-deferred. Its completed
containment row is not reopened, and opt-in Cache restore work is not being used
as evidence for Task 5.6. The Sidecar V13 schema update belongs to the active AST
representation and test maintenance boundary, not to Cache V2 cutover.

## Worktree state and confidence

- Latest committed plugin checkpoint: `182da08` (`[CanonicalAST] Refactor:
  close statement and control semantics`).
- Latest committed parent checkpoint: `5b8afcd1` (`[CanonicalAST] Docs: close
  statement and control matrix`).
- CTA-S179 is still an uncommitted multi-file slice spanning AST schema,
  verifier, Sema, CodeGen and tests. The focused CodeGen authority test is green,
  but the constant and enum gates are deliberately still red/open.
- Unrelated untracked `.claude/skills/openspec-design.md` and `list/` remain
  preserved and excluded.

## Bottom line

> **Formal completion: 80.9%. Risk-weighted overall engineering completion:
> about 84% (honest range 84–85%). Task 5.6 internal completion: about 70–75%.**
> The current work is real progress rather than numerator stagnation: most
> structured-control/verifier geometry and primitive CodeGen authority are now
> implemented. The checkbox correctly remains at 110/136 until Legacy Case
> constant semantics, enum validation and fresh complete regressions are all
> green and independently approved.
