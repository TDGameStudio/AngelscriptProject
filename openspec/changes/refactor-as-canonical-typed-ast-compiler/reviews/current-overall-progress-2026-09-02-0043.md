# Current overall progress review — 2026-09-02 00:43 CST

## Executive result

- **Authoritative OpenSpec completion:** **110/136 = 80.9%**.
- **Unchecked rows:** **26**.
- **Calibrated engineering progress:** **about 84–85%**, with an honest range
  of **83–85%**.
- **Task 5.6 implementation progress:** approximately **75–80%**.
- **Task 5.6 closure readiness:** approximately **65–70%**.
- **Current readiness:** Task 5.6 is not ready to check; the change is not
  default-cutover-ready, final-All-ready, archive-ready or merge-ready.

Use **80.9%** when reporting an auditable project number. The approximately
**84–85%** number is only an engineering estimate that credits substantial work
inside coarse unchecked umbrella rows. No formal checkbox changed in this
review.

`openspec status` reports `isComplete=true` only for the presence of the
required proposal/design/spec/tasks artifacts. Its separate task progress is
the meaningful implementation count: **110 complete, 26 remaining**.

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

The remembered **102/136** checkpoint has moved by eight completed rows to
**110/136**. The numerator has stayed at 110 during CTA-S179 because Task 5.6
is one coarse umbrella row: its many internal sub-gates do not earn partial
checklist credit.

## Delta since the 00:32 review

### Two remaining Switch gaps now have authentic RED evidence

The earlier static-review findings are now locked by source-path
`SemaAuthority` tests. The test build passed, then both new behavior tests
failed for the expected product reasons:

| Gate | Result | Evidence |
|---|---:|---|
| test build | **PASS**, exit `0` | `Saved/Build/cta-s179-task56-selector-float-red-build/20260902_003844_330_3c6865a5` |
| selector + float constant RED | **0/2 PASS**, `2` failed, `0` skipped | `Saved/Tests/cta-s179-task56-selector-float-red/20260902_003935_650_159ba03a` |

The exact failures are:

1. `NonIntegralSwitchSelectorFailsInSemaWithoutLegacyCompiler`: a `bool`
   selector survived Canonical Sema and reached CodeGen, which failed with
   `code=-7` at the Switch lowering path. The required maintained diagnostic is
   `Switch expressions must be integral numbers` at the Sema boundary.
2. `FloatBinaryExplicitIntCaseMatchesLegacyConstant`:
   `int(0.5f + 0.5f)` was reported as `Case expressions must be constants`
   instead of folding to `1` and producing `Duplicate switch case` against a
   following `case 1`.

These failures are useful progress because they turn inferred compatibility
risks into exact permanent oracles. They are **not** implementation completion:
the production fixes and GREEN runs are still absent at this snapshot.

### Structured-control reconciliation is substantially better than the stale task prose

An independent, exact-method audit mapped every structured-control clause in
Task 5.6 to current CanonicalAST evidence. The following are already covered:

- structured targets and source-order phases for If/While/DoWhile/For/Switch;
- nearest Break/Continue targets and next-Case Fallthrough targets;
- wrong-kind, non-ancestor and skipped-nearer control edges;
- dangling or missing targets at the publication boundary;
- duplicate structural edges, duplicate Cases and default-last ordering;
- invalid Fallthrough placement/target, including the maintained legal
  targetless final-Case compatibility rule;
- malformed phase cardinality/kinds and transfer statements with payloads;
- fail-closed Seal/publication behavior and structured safe-point roles;
- public Snapshot compatibility and Sidecar V13 round-trip representation;
- primitive Switch CodeGen/VM consumption of authenticated domain facts.

Representative exact methods include:

- `ControlTargetsAndNamedPhasesSealTogetherOnCompileSealPath`;
- `RejectsBreakTargetNotAncestor`;
- `RejectsBreakSkippedNearerLoop`;
- `RejectsMissingBreakAndContinueTargetsBeforePublication`;
- `RejectsDuplicateCaseAndDefaultNotLast`;
- `RejectsFallthroughTargetNotNextCase`;
- `RejectsMalformedStructuredControlPhaseCounts`;
- `RejectsForgedStructuredControlSafePointRolesBeforePublication`;
- `RetainedV1StmtViewAppendsLoopBodyEdgeSafePointCompatibly`;
- `SidecarV13RoundTripPreservesLoopBodyEdgeSafePoint`;
- `SwitchDispatchConsumesAuthenticatedDomainFactNotAuthoredChild`.

Therefore the old explanation that “HIR control tests are not fully migrated”
is stale and must not be interpreted as a requirement to recreate HIR. Task
13.2 explicitly states that HIR is physically absent. The current CanonicalAST
source, verifier, Snapshot, Sidecar and execution tests are the replacement
evidence. Likewise, cleanup-on-transfer belongs to Tasks 5.7/5.8/7.5/9.5,
while complete backend/cutover isolation belongs to Tasks 9/10/13.6; neither
should be invented as an extra Task 5.6 structured-control blocker.

This reconciliation narrows Task 5.6. It does **not** justify checking it while
the two current REDs, the enum CodeGen positive case and final-state regression
matrix remain open.

### Maintained-LEGACY oracle exposes additional parity edges

A second independent audit traced the maintained compiler rather than relying
on test names. Direct source verification confirms:

- LEGACY rejects `bool`, floating and object Switch selectors before scanning
  Cases, with exactly `Switch expressions must be integral numbers`; enum
  selectors remain accepted through the integral comparison domain.
- constant bool Case expressions (`true`, constant comparison, `!`, `&&`,
  `||`, `^^`) are constant-but-nonintegral, so their primary diagnostic is the
  integral diagnostic rather than the nonconstant diagnostic;
- a runtime bool Case such as `Selector == 1` produces the nonconstant and
  nonintegral diagnostics in LEGACY. Canonical currently uses a
  single-primary-diagnostic Sema policy, so exact diagnostic multiplicity
  needs an explicit compatibility decision rather than accidental drift;
- float32 binary folding rounds at float32 operation width before an explicit
  integer cast. `int(16777216.0f + 1.0f)` must therefore remain `16777216`, not
  a double-evaluated `16777217`;
- integer divide-by-zero reports `Divide by zero`, recovers constant value `0`
  and continues scanning. With a later `case 0`, LEGACY subsequently emits
  `Duplicate switch case` as well;
- integer power overflow reports `Overflow in exponent operation`, retains the
  recovered value and likewise continues duplicate checking.

The current `SwitchCaseConstantErrorDiagnosticsMatchLegacy` test validates only
the isolated first diagnostic. Its name overstates the untested recovery and
continuation parity. The independent review initially described `/0` as
silently producing only a duplicate; direct inspection corrected that detail:
`CompileOperator` emits the divide diagnostic before the constant-fold branch,
and the branch then supplies the zero recovery value without returning.

Readonly/global constant provenance and forward/cyclic global dependency
resolution also need a broader AST-first contract. That work is routed mainly
to Tasks 5.9/13.2; Task 5.6 should consume only a successfully sealed constant
fact and must not expand into a second global-initialization subsystem.

## What remains before Task 5.6 can close

1. **Reject unsupported selector types in Canonical Sema.** Preserve recovery
   behavior for missing/error nodes, but a resolved authored selector that is
   neither an integral primitive nor an enum must emit the maintained integral
   diagnostic before Case scanning, CodeGen or publication. Expand the locked
   bool RED to floating and object selectors while retaining an enum success.
2. **Finish typed float constant evaluation under explicit integer
   conversion.** At minimum the locked binary-addition RED must reach the same
   constant result and duplicate diagnostic as LEGACY. Any broader `/`, `%` or
   `**` support must preserve diagnostic side-band behavior rather than hiding
   divide-by-zero/overflow recovery behind a value-only helper.
3. **Add a valid enum Switch CodeGen authority oracle.** It must prove the
   exact nominal enum domain, selected Case result, zero LEGACY compiler
   construction, and that a contradictory authored provenance child cannot
   override the verifier-authenticated `switch-case-domain` fact.
4. **Reconcile the final constant-expression edge matrix against LEGACY.** Add
   exact REDs for constant bool/comparison/logical classification, float32
   per-operation rounding and diagnostic/recovery continuation. Decide and
   record whether Canonical intentionally keeps one primary Sema diagnostic
   for runtime bool Cases or matches LEGACY's second integral diagnostic. Do
   not add production behavior without the chosen contract and an authentic
   RED.
5. **Run fresh final-state owning prefixes** after the production state stops
   changing:
   - `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier`;
   - `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST`;
   - `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`;
   - `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`;
   - `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics`;
   - `Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot`;
   - `Angelscript.TestModule.Cache.ASTBodySidecar`.

The old broad checkpoints—Verifier **74/74**, Frontend CanonicalAST **203/203**
and SemaAuthority **547/547**—predate later evaluator/enum changes. The
constant/enum focused result remains a valid **11/11 PASS**, but it cannot
substitute for the final-state prefixes. Sidecar V13 is still recorded at
**25/27** from its pre-assertion-fix run until rerun.

## Working-tree risk

- Latest committed plugin checkpoint: `182da08`.
- Latest committed parent checkpoint: `5b8afcd1`.
- CTA-S179 currently modifies **23 plugin files** with approximately **4645
  insertions and 250 deletions**.
- The diff crosses AST/public/Sidecar schema, verifier, expression and
  statement Sema, Bytecode CodeGen, Snapshot API and tests. The scope is too
  large to characterize from the current narrow GREEN alone.
- The parent contains the modified plugin gitlink and review/attachment edits.
  Unrelated untracked `.claude/skills/openspec-design.md` and `list/` are
  preserved and outside this change.

## `+=` issue record

Four distinct compound-assignment defects remain recorded as resolved:

1. overloaded lvalue `Object += 7` remained a generic Assign instead of a
   resolved operator Call;
2. valid rvalue `Make() += 7` was rejected instead of being materialized once;
3. indexed `+=` evaluated RHS/receiver/index in the wrong order;
4. scalar-reference RHS aliasing reread mutated storage and returned `21`
   instead of the value-snapshotted `11`.

The separate `Tail += 100` anomaly remains **OPEN**, but the current evidence
does not support calling it a fifth compound-assignment semantic defect. The
same bad scalar appears on a control route that does not execute the compound
write. It remains owned first by Task 9.2 as a DeclId/local-slot identity issue
and by Task 9.6 only if identical AST declaration identity proves a physical
frame-layout defect.

There is an explicit checklist caveat: Task 9.2 is currently checked. The
existing failure came from an intermediate broad control sentinel and has not
yet been reduced to the standalone `Probe` below. Therefore this review does
not silently reopen 9.2 or reduce the formal numerator on incomplete root-cause
evidence. If the minimal oracle reproduces a Canonical local read/write/slot
failure, 9.2 must be reopened and the formal count becomes **109/136 = 80.1%**.
If the minimal oracle is green, the broader fixture must be debugged and the
issue rerouted or closed without changing 9.2. Leaving the issue indefinitely
under a checked 9.2 row is not an acceptable final state.

The next oracle remains:

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
`false -> true -> false = 0 -> 100 -> 0`, while asserting that the initializer,
compound lhs and Return DeclRef all use the same exact `Tail` DeclId.

## Cache V2 boundary

Cache V2/V12 prototype refactoring remains **explicitly deferred by the
user**. It is not reopened by this review and is not a Task 5.6 gate. Sidecar
V13 maintenance belongs to the active Canonical AST representation and does
not authorize or require Cache V2 restore/cutover work.

## Remaining 26 rows by critical path

| Critical path | Open rows | Count |
|---|---|---:|
| AST-first/final gate records | 0.2, 0.3 | 2 |
| statement/lifetime/broad Sema | 5.6, 5.7, 5.8, 5.9 | 4 |
| TypedASTJIT consumers | 7.2, 7.4, 7.5 | 3 |
| Canonical Bytecode/differential | 9.1, 9.5, 9.6, 9.7 | 4 |
| product cutover/LEGACY isolation | 10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9 | 7 |
| final verification | 12.2, 12.4 | 2 |
| review convergence/publication | 13.2, 13.6, 13.8, 13.12 | 4 |
| **Total** |  | **26** |

The main remaining risk is no longer AST foundation or basic expression Sema.
It is cross-cutting lifetime closure, broad Canonical Bytecode coverage,
immutable generation publication, all production entry points, differential
breadth, the default pipeline switch and final whole-change verification.

## Bottom line

> **Formal progress is 80.9% (110/136). Calibrated engineering progress is
> about 84–85% (honest range 83–85%). Task 5.6 is about 75–80% implemented and
> about 65–70% closure-ready.**

The structural-control portion of Task 5.6 is much closer to complete than its
stale prose suggests. The immediate blockers are now sharply bounded: two
current REDs in selector/float constant semantics, missing bool/float32/
diagnostic-recovery parity oracles, one missing valid-enum CodeGen authority
test, and final-state prefix validation. Formal progress stays at 110 until the
entire umbrella row is actually closed.
