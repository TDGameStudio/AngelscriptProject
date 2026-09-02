# Current overall progress review — 2026-09-02 00:32 CST

## Executive result

- **Authoritative OpenSpec completion:** **110/136 = 80.9%**.
- **Unchecked rows:** **26**.
- **Calibrated overall engineering progress:** **about 85%**, with an honest
  range of **84–86%**.
- **Task 5.6 internal implementation progress:** approximately **80–85%**.
- **Task 5.6 closure readiness:** approximately **75–80%**, because the newest
  focused gate is green but the complete owning-prefix matrix and several
  language-parity edges are not yet closed.
- **Readiness:** not ready to check Task 5.6, not default-cutover-ready, not
  final-All-ready, not archive-ready, and not merge-ready.

Use **80.9%** when the number must be auditable from `tasks.md`. Use **about
85%** only as the engineering estimate that credits partial work inside coarse
umbrella rows. The engineering estimate must not be used to mark a task done.

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

The remembered `102/136` checkpoint has already moved by eight full rows to
`110/136`. The numerator has not changed during CTA-S179 because Task 5.6 is
one intentionally coarse structured-control umbrella row: partial sub-gates do
not earn fractional checklist credit.

## Delta since the 00:08 review

The previous review correctly identified Legacy-compatible Case constants,
exact diagnostics, and enum Case validation as hard blockers. Those specific
RED groups have now reached a real focused GREEN.

### Fresh evidence

| Gate | Result | Evidence |
|---|---:|---|
| enum/constant repair build | **PASS**, exit `0` | `Saved/Build/cta-s179-task56-enum-domain-green-build/20260902_002546_218_2827054b` |
| constant + enum focused gate | **11/11 PASS**, `0` failed, `0` skipped | `Saved/Tests/cta-s179-task56-constant-enum-green/20260902_002607_141_01c30edf` |
| plugin diff hygiene | **PASS** (`git diff --check`) | current plugin working tree |

The 11 focused methods cover:

1. logical `>>`;
2. arithmetic `>>>`;
3. 32-bit shift-count masking;
4. integer `**`;
5. mutable-global rejection;
6. readonly local, float-to-int and integer edge recovery matrix;
7. divide-by-zero, exponent-overflow, nonintegral and nonconstant diagnostics;
8. `asEP_DISABLE_INTEGER_DIVISION` as an expression-Sema type rule;
9. runtime enum Case rejection;
10. same-enum same-value duplicate rejection in Sema;
11. cross-enum rejection under `asEP_TYPECHECK_SWITCH_ENUMS`.

The enum RED before this repair was authentic: **0/3 PASS** at
`Saved/Tests/cta-s179-task56-enum-switch-red/`
`20260902_002011_097_a28350ee`. One program wrongly built, one duplicate was
rejected only by verifier fallback, and one cross-enum Case wrongly built. The
new 11/11 result therefore reflects an actual ownership correction rather than
a test-only expectation change.

### Architecture now established for the covered slice

- Expression Sema authors `asEP_DISABLE_INTEGER_DIVISION` as explicit float64
  conversions and a float64 Binary result. The constant evaluator consumes the
  sealed type rather than re-reading Engine policy.
- Switch Sema validates supported primitive and enum Case expressions, keeps
  exact enum nominal identity, computes the maintained 32-bit comparison
  value, and seals it in a `switch-case-domain` Conversion fact.
- The verifier authenticates the exact selector domain, one provenance child,
  range relation and 32-bit normalized value, then detects duplicates from the
  sealed facts.
- Primitive and enum CodeGen materialize the authenticated `literalBits`; they
  do not execute the authored Case expression.
- Case analysis is two-phase: all values are analyzed before graph mutation,
  so an error does not publish a normalized prefix plus authored suffix.

This is the intended LLVM/Clang-shaped direction: Sema owns meaning, the
verifier authenticates that meaning, and the backend performs mechanical
lowering.

## Why Task 5.6 remains unchecked

### 1. Unsupported selector types can still bypass the Sema diagnostic

Static review found a concrete remaining language-boundary hole. The current
`GetSwitchPrimitiveComparisonDomain` accepts integer primitives only, while
`NormalizeSwitchComparisonDomain` returns success when the selector is neither
such a primitive nor an enum. A `bool` selector can therefore survive Switch
Sema and fail only later in CodeGen with a generic unsupported result.

LEGACY rejects a non-integer/non-unsigned/non-enum Switch selector with
`Switch expressions must be integral numbers`. Task 5.6 cannot close while the
Canonical route moves that semantic decision into the backend.

Required next oracle: a Canonical-only `bool` selector RED/GREEN that asserts
the exact maintained diagnostic, zero Legacy compiler invocations, no Bytecode
publication and no retained snapshot.

### 2. Constant classification is not yet a complete typed/diagnostic matrix

The current implementation covers the discovered integer matrix, but static
review still exposes untested or partial shapes:

- direct bool literals and bool-producing comparison/logical expressions must
  be classified consistently as constant-but-nonintegral where LEGACY does so,
  rather than generically nonconstant;
- floating binary arithmetic beneath an explicit integer conversion, for
  example `int(0.5f + 0.5f)`, is not handled by the current floating helper;
- divide-by-zero and power-overflow recovery are represented as terminal
  status codes, so multi-diagnostic/duplicate recovery parity is not yet
  proven as diagnostic side-band behavior;
- readonly declaration provenance should be proven for authored initializer
  facts rather than relying only on a cached value marker where that marker
  also has storage-initialization uses.

These are focused closure tests, not a request to copy `asCCompiler` or create
a second semantic frontend. The right endpoint remains a small Sema-internal
typed numeric evaluator over exact Canonical `QualType`, conversion edges,
declaration identity and literal bits.

### 3. Valid enum CodeGen authority is not freshly proven

The new enum tests are negative Sema-authority cases. The enum CodeGen branch
now consumes `switch-case-domain`, but the final source state still needs a
positive valid-enum execution oracle. It should prove the exact nominal enum
domain, selected Case result, zero Legacy construction, and that disagreement
in the authored provenance child cannot override the authenticated fact.

### 4. The complete structured-control migration must be reconciled

Task 5.6 names wrong-kind, non-ancestor, skipped-nearer, dangling,
duplicate/default-order and invalid-fallthrough rejection using migrated HIR
control tests. CTA-S179 contains extensive forged verifier coverage, but the
task record still states that the full migrated control matrix is incomplete.
That statement must be reconciled against exact test methods and current
evidence before the row can be checked.

### 5. Broad validation is stale after the latest production changes

The most recent broad checkpoint before the constant/enum edits remains:

| Prefix | Result | Evidence |
|---|---:|---|
| Verifier | **74/74 PASS** | `Saved/Tests/cta-s179-task56-verifier-final2/20260901_232834_394_e50312af` |
| Frontend CanonicalAST | **203/203 PASS** | `Saved/Tests/cta-s179-task56-frontend-final/20260901_232909_568_030a26ed` |
| SemaAuthority | **547/547 PASS** | `Saved/Tests/cta-s179-task56-semaauthority-final/20260901_232951_094_5060898a` |

Those are useful baselines, but they predate the current evaluator, enum
normalization, expression-Sema typing and enum CodeGen changes. Fresh final
state runs are still required for Verifier, Frontend CanonicalAST,
SemaAuthority, ProductionCodeGen, Semantics, Snapshot/API, Sidecar V13 and the
migrated structured-control matrix. The Sidecar result remains **25/27** from
the pre-fix V13 assertion run until the prefix is rerun.

## Current working-tree risk

- Latest committed plugin checkpoint: `182da08`.
- Latest committed parent checkpoint: `5b8afcd1`.
- CTA-S179 is uncommitted and currently spans **23 plugin files**, approximately
  **4540 insertions / 250 deletions**.
- The slice crosses AST/public/Sidecar schema, verifier, expression and
  statement Sema, CodeGen, Snapshot/API and tests. Passing 11 focused tests is
  therefore insufficient to characterize regression risk across the entire
  diff.
- The parent has uncommitted review/attachment records plus the modified
  plugin gitlink. Unrelated untracked `.claude/skills/openspec-design.md` and
  `list/` remain preserved and excluded.

## `+=` and related issue record

The `+=` history is now explicitly recorded in
`semantic-correctness-issue-ledger-2026-09-01.md` as four distinct resolved
semantic defects:

1. overloaded lvalue `Object += 7` stayed a generic Assign instead of a
   resolved operator Call;
2. valid rvalue `Make() += 7` was rejected instead of being materialized once;
3. indexed `+=` evaluated RHS/receiver/index in the wrong order;
4. scalar-reference RHS aliasing reread storage after mutation and returned
   `21` instead of `11`.

The separate `Tail += 100` anomaly remains **open**, but current evidence does
not classify it as a fifth compound-assignment defect. Both control paths see
the same bad scalar, including the route that never executes the compound
write. It remains routed first to Task 9.2 as a DeclId/local-slot identity
problem and to 9.6 only if identical AST identity proves a physical
frame-layout defect.

Required next oracle remains:

```angelscript
int Probe(bool M)
{
    int Tail = 0;
    if (M)
        Tail += 100;
    return Tail;
}
```

It must prove fresh-context `false=0`, `true=100` and same-context
`false -> true -> false = 0 -> 100 -> 0`, while asserting that initializer,
compound lhs and Return DeclRef use the same exact `Tail` DeclId.

## Remaining 26 rows by critical path

1. **Immediate:** Task 5.6 selector/constant/enum closure, structured-control
   reconciliation and fresh broad validation.
2. **Lifetime / broad Sema:** 5.7, 5.8, 5.9 and 13.2.
3. **TypedASTJIT consumers:** 7.2, 7.4 and 7.5.
4. **Canonical Bytecode / differential:** 9.1, 9.5, 9.6, 9.7 and 13.6.
5. **Snapshot publication/races:** 13.8.
6. **Product cutover:** 10.1, 10.2, 10.3, 10.4, 10.6, 10.7 and 10.9.
7. **Whole-change evidence:** 0.2, 0.3, 12.2, 12.4 and 13.12.

The major remaining risk is no longer AST foundation or basic expression
Sema. It is the cross-cutting closure of lifetime, complete Canonical backend
coverage, immutable generation publication, all production entry points,
differential breadth and default cutover.

## Cache V2 scope

Cache V2/V12 prototype refactoring remains **explicitly deferred by the
user**. It is not reopened by this review and is not a Task 5.6 gate. The
Sidecar V13 work in CTA-S179 belongs to the active Canonical AST representation
and its test maintenance; it does not authorize or require Cache V2 restore or
cutover work.

## Bottom line

> **Formal progress is 80.9% (110/136). Calibrated engineering progress is
> about 85% (honest range 84–86%). Task 5.6 is about 80–85% implemented and
> about 75–80% closure-ready.**

The newest work is material: it turns the constant/enum RED set into 11/11
focused GREEN and establishes Sema → verifier → CodeGen authority for the
covered Switch Case facts. The formal numerator correctly remains unchanged
until unsupported selector diagnostics, remaining constant-classification
edges, valid enum CodeGen authority, migrated-control reconciliation and fresh
complete owning-prefix regressions are all closed.
