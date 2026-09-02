# CTA-S178 / Task 5.5 closure review — 2026-09-01

## Review result

**APPROVE. Task 5.5 is complete on plugin commit `182da08`.** Both independent
subagent reviews report no blocker and no major after the statement-selector,
For source-range and VM transfer-sentinel findings were corrected. Formal
OpenSpec progress becomes **110/136 = 80.9%**, with **26** rows open.

## Production review outcome

Two production defects were found and fixed.

First, authored local declarations, ordinary expression statements, If and
Case did not consistently publish the required Statement safe-point role.
Authored nodes now carry the source-stepping fact; Call, Return and specialized
loop/transfer roles retain their exact identities. The generated initializer
ExprStmt beside a declaration deliberately remains None, preventing a duplicate
source event for one authored declaration.

Second, Canonical Bytecode consumed LoopBackedge for While but dropped it for
For/foreach and DoWhile. One fail-closed helper now requires the exact sealed
role and emits the safe point at the correct physical phase:

- While: after the successful condition, before the body;
- DoWhile: after the body, before the trailing condition;
- For/foreach: after the successful condition, before the body.

The CodeGen reviewer checked all three call sites, the shared foreach path and
the role authentication. Final result: APPROVE, no blocker/major.

## Positive AST matrix review

The final source-built matrix locks exact geometry rather than node presence:

- For initializer is a two-child synthetic Block containing the authored Decl
  and its generated Assign ExprStmt; the Assign lhs resolves to that exact
  declaration. Init Block, declaration, assignment and multi-increment clause
  all have exact source ranges. Increment targets remain in source order.
- If-without-else has exactly one child. The FunctionEntry root has exactly
  If, Observe ExprStmt and final Return in order. Both bare Returns have no
  value expression, exact Return roles and exact ranges.
- The grouped unsigned Switch has a `uint` selector, exact ordered
  `0,1,2,default` Cases, an empty first grouped label, the shared body under the
  second label, Statement roles and Switch targets.
- Loop-inside-Switch proves the reverse nesting direction: inner Break and
  Continue target the loop, while outer case Breaks target the Switch.
- Statement-role selection uses exact Assign/RHS-Call identity for the
  synthetic initializer and requires zero unknown extra ExprStmt nodes.

The test reviewer initially identified three major closure gaps: Continue was
not observable at runtime, If hierarchy/order was underasserted, and For init
shape/roles were incomplete. After those corrections it found one final range
gap on InitAssignment. That range is now asserted and the final focused test
and full SemaAuthority prefix pass. Final result: APPROVE, no blocker/major.

## Runtime transfer oracle

The strengthened `LoopsSwitchTransfersAndSafePoints` fixture executes all
three authored paths and uses `Total += 100` after the Switch as an observable
body-tail sentinel:

- Selector 1 returns `305`, so Switch Break exits only the Switch and body-tail
  work continues;
- Selector 2 returns `32`, so Continue targets the For and skips the body tail;
- Selector 0 returns `0`, so default Return exits early.

It also locks exact node and role counts, all Case targets, Break-to-Switch,
Continue-to-For and all Transfer roles. The old fixture executed only Selector
1 and therefore gave false confidence about Continue/default; that coverage
gap is now closed.

## False-green and test-overconstraint handling

Two validation traps are explicitly retained in the evidence:

1. The first loop-safe-point test was a false green because line cues can turn
   LINE opcodes into SUSPEND. Final tests disable line cues, so SUSPEND proves
   explicit sealed-role consumption.
2. The first complete positive matrix was 521/522 because the test demanded
   that each integer Case literal itself be retagged to `uint`. That was beyond
   the Switch normalization contract. The typed selector, ordered constants,
   grouping geometry and targets were correct, so this was a test-design
   correction rather than a production bug.

## Verification reviewed

| Gate | Result |
|---|---:|
| final Build | PASS |
| SemaAuthority | **542/542 PASS** |
| ProductionCodeGen | **231/231 PASS** |
| Semantics | **15/15 PASS** |
| isolated VM transfer sentinel | **1/1 PASS** |

Complete paths and RED/GREEN lineage are in
`attachments/canonical-statement-control-positive-matrix-gate-2026-09-01.md`.
All listed test reports have zero failures/skips.

## Related `+=` records and the Tail boundary

The semantic ledger now preserves four distinct resolved compound-assignment
issues:

1. overloaded lvalue operator-call rewrite;
2. rvalue receiver materialization;
3. indexed RHS/receiver/index sequencing;
4. scalar-reference RHS value snapshotting.

CTA-S178 also exposed a separate local `Tail` anomaly while using
`Tail += 100` as a broader sentinel. Correct control values were shifted by the
same garbage scalar even on the path that never executed the compound write.
Reusing the established `Total` local made the exact `305/32/0` control oracle
pass. The current evidence therefore points to DeclId/local-slot or downstream
operand/frame mapping, not another compound-assignment semantic rule and not a
control-target defect. It remains explicitly open under Task 9.2, with 9.6 as
the physical-layout fallback owner, and does not block Task 5.5.

## Acceptance boundary

Task 5.5 closes valid positive source-to-sealed statement/control geometry and
its loop safe-point consumer. It does not close:

- Task 5.6 forged wrong-kind, dangling, non-ancestor, skipped-nearer,
  default/fallthrough/phase and fail-closed publication negatives;
- transfer cleanup or complete lifetime Tasks 5.7/5.8;
- broad remaining Sema authority Task 13.2;
- complete TypedASTJIT/Bytecode install consumers;
- product default cutover, LEGACY isolation/deletion or final regression.

Cache V2/V12 remains user-deferred and was not used as evidence.

## Final recommendation

Keep 5.5 checked and move the semantic critical path to 5.6. In parallel with
that audit, create the minimal Tail DeclId/slot discriminator described in the
semantic ledger so the separate backend issue cannot disappear inside a broad
control fixture.
