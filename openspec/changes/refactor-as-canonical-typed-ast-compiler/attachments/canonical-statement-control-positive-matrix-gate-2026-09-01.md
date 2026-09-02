# Canonical statement/control positive-matrix gate (CTA-S178)

## Decision

Task 5.5 is accepted on plugin commit `182da08`. The supported source-to-sealed
AST path now publishes exact statement geometry, authored/source-safe-point
roles, loop phases and nearest legal transfer targets. Canonical Bytecode
consumes the sealed loop-backedge role for While, DoWhile and For/foreach.

This gate closes the positive statement/control matrix only. Task 5.6 remains
open for forged malformed graphs and fail-closed verifier/publication behavior.
Lifetime cleanup on transfer, complete backend/install work, product cutover
and final regression retain their later task ownership.

## Requirement-to-evidence map

| Task 5.5 surface | Sealed AST evidence | Execution/consumer evidence |
|---|---|---|
| block and declaration/expression statements | exact root and child cardinality; authored Decl/Expr carry Statement; generated declaration-initializer ExprStmt remains None | statement-role selector test rejects unknown extra ExprStmt |
| if/else and return | no-else If has exactly one child; two bare Returns have no value expression, exact ranges and Return roles | default early Return sentinel produces `0` |
| for phases | init Block/Decl/Assign, bool condition, body, ordered multi-increment Sequence and exact ranges; Continue targets For | Selector `2` produces `32` and skips the observable loop tail |
| while/do-while | exact distinct nodes, LoopEntry/LoopBackedge roles | line-cue-disabled bytecode contains explicit SUSPEND; both functions execute to `3` |
| switch/case/default/grouping | `uint` selector; ordered `0,1,2,default`; empty grouped label followed by owned shared body; Case targets Switch | Break sentinel produces `305`; default path returns `0` |
| reverse nesting | inner loop Break/Continue target While; outer case Breaks target Switch | complements the switch-inside-loop VM fixture |
| safe-point roles | exact FunctionEntry, Statement, Call, Return, LoopEntry, LoopBackedge and Transfer counts/subjects | Canonical publisher, zero LEGACY compiler invocations |

## Authentic RED/GREEN history

### Authored statement roles

Source-built DeclStmt, ordinary ExprStmt and IfStmt did not consistently carry
the required Statement role.

- RED: `Saved/Tests/cta-s178-statement-safepoint-red/`
  `20260901_201741_831_168423b4`, **0/1 FAIL**.
- Initial GREEN Build:
  `Saved/Build/cta-s178-statement-safepoint-green-build/`
  `20260901_202728_784_75a1c87a`, PASS.
- Initial focused GREEN:
  `Saved/Tests/cta-s178-statement-safepoint-green/`
  `20260901_202757_121_3d19bf9e`, **1/1 PASS**.
- Final selector-precise GREEN:
  `Saved/Tests/cta-s178-statement-role-selector-green/`
  `20260901_205719_464_7d73d51d`, **1/1 PASS**.

The final oracle distinguishes the synthetic initializer ExprStmt by exact
Assign geometry and target Call identity. It deliberately keeps that generated
phase at None so one authored declaration does not publish two source-stepping
events. All other authored expression statements must carry Statement, and the
test requires zero unclassified ExprStmt nodes.

### Loop safe-point AST-to-Bytecode loss

Sema already sealed LoopBackedge roles, but Canonical Bytecode emitted the
explicit SUSPEND/JitEntry only for While. For/foreach and DoWhile dropped the
semantic fact.

The first test was a false green: default line cues can later become SUSPEND,
so merely finding that opcode did not prove role consumption. The corrected
module sets `asEP_BUILD_WITHOUT_LINE_CUES=1`.

- Authentic RED Build:
  `Saved/Build/cta-s178-loop-safepoint-authentic-red-build/`
  `20260901_202306_913_5b2e6fa2`, PASS.
- Authentic RED:
  `Saved/Tests/cta-s178-loop-safepoint-authentic-red/`
  `20260901_202347_746_8eef2725`, **0/1 FAIL** on For SUSPEND.
- Fix: one consumer helper requires the exact sealed LoopBackedge role and
  emits at the physical phase appropriate to While, DoWhile and For/foreach.
- Initial GREEN Build:
  `Saved/Build/cta-s178-loop-safepoint-green-build/`
  `20260901_202455_045_74e7caa2`, PASS.
- Initial GREEN:
  `Saved/Tests/cta-s178-loop-safepoint-green/`
  `20260901_202512_982_09d22008`, **1/1 PASS**.
- Final focused gates:
  `cta-s178-for-do-provenance-green/20260901_205819_108_ea2875f3`
  and
  `cta-s178-while-no-line-cues-green/20260901_205819_108_52e4d0f4`,
  each **1/1 PASS**.

### Observable transfer paths

The old VM fixture contained Break, Continue and default Return source but
executed only the Break selector. Its green result could not prove the Continue
target or default path.

The final fixture places `Total += 100` after the Switch inside the For body:

- `Selector=1 -> 305`: Switch Break exits only the Switch, so the body tail
  still executes on all three iterations;
- `Selector=2 -> 32`: Continue targets the For and skips that tail; an incorrect
  fallthrough into the remaining body would produce `332`;
- `Selector=0 -> 0`: default Return exits before later loop work.

It also requires exact For/Switch/While/DoWhile/Case/Return cardinality, exact
safe-point roles, all Case targets, Break-to-Switch, Continue-to-For and all
Transfer roles.

- Final Build:
  `Saved/Build/cta-s178-vm-control-isolated-sentinel-build/`
  `20260901_210112_856_c3aa9094`, PASS.
- Final exact VM sentinel:
  `Saved/Tests/cta-s178-vm-control-isolated-sentinel-green/`
  `20260901_210130_993_a35f3dc4`, **1/1 PASS**.

## Positive matrix and test-design correction

The matrix contains dedicated source-built tests for:

1. exact For init/condition/body/multi-increment phase structure, roles,
   targets, source order and ranges;
2. no-else If and exact bare-Return shape/ranges;
3. unsigned grouped Switch with ordered Cases and default-last geometry;
4. loop-inside-Switch nearest-target resolution;
5. authored versus generated statement-role distinctions.

The first full positive run was **521/522**. The only failure was an
overconstrained test that required each integer Case literal itself to be
retagged to `uint`. The sealed graph already had the required typed `uint`
selector, ordered constant values, grouping geometry and targets. Removing the
unsupported literal-retagging assertion made the focused case pass at
`Saved/Tests/cta-s178-unsigned-grouped-switch-green/`
`20260901_203945_452_cfc0a154`. This is recorded as a test-design correction,
not a production RED.

The final For review also added exact Init Block, Init Decl and Init Assignment
source ranges. Its last focused gate is
`Saved/Tests/cta-s178-for-init-range-final/`
`20260901_210909_052_dc8168ec`, **1/1 PASS**.

## Separate `Tail += 100` diagnostic

An intermediate, broader sentinel introduced a new local `Tail`. Both correct
control results were shifted by the same uninitialized-looking value:
`6 -> 13879` and `32 -> 13905`. Because Selector 2 never executes
`Tail += 100`, and because the final sentinel passes when it reuses the already
established `Total` local, this is not classified as a fifth compound-assignment
semantic failure or a control-target defect.

The issue is retained in
`reviews/semantic-correctness-issue-ledger-2026-09-01.md`. Superseding result
2026-09-02: `LocalCompoundTailKeepsOneDeclAndFreshFrameAcrossContextReuse` is
**1/1 PASS** at `Saved/Tests/cta-s179-tail-declid-strengthened/`
`20260902_011308_781_6e3217c8`. Fresh and same-context executions produce
`0 -> 100 -> 0`, and initializer lhs, compound lhs and Return DeclRef share one
exact `Tail` DeclId. The disposition is **REDUCED / NOT REPRODUCIBLE**; this is
not a fifth `+=` semantic defect and does not reopen checked Task 9.2.

## Final verified checkpoint

| Gate | Result | Report |
|---|---:|---|
| Build after final range assertion | PASS | `Saved/Build/cta-s178-task55-final-range-build/20260901_210824_618_ef1ee6a7` |
| SemaAuthority | **542/542 PASS** | `Saved/Tests/cta-s178-task55-semaauthority-final2/20260901_210909_052_aa2811dd` |
| ProductionCodeGen | **231/231 PASS** | `Saved/Tests/cta-s178-task55-production-full/20260901_204744_392_f2dd925c` |
| Semantics | **15/15 PASS** | `Saved/Tests/cta-s178-task55-semantics-final/20260901_210237_478_09e2cf78` |
| isolated VM control sentinel | **1/1 PASS** | `Saved/Tests/cta-s178-vm-control-isolated-sentinel-green/20260901_210130_993_a35f3dc4` |

All listed test gates have zero failures and zero skips. The final code-focused
and test-focused subagent reviews returned APPROVE with no blocker or major.
Cache V2/V12 was intentionally not run: its prototype refactor/testing remains
user-deferred and is not part of this statement/control acceptance boundary.

## Non-claims

- Task 5.6 malformed-graph rejection and publication firewall were closed by
  the later CTA-S181 seven-owner gate; this attachment remains the Task 5.5
  positive-matrix checkpoint.
- Transfer-aware cleanup and the complete lifetime umbrellas are not closed.
- This gate does not authorize default CANONICAL selection, LEGACY deletion,
  complete TypedASTJIT/Bytecode install cutover, or final archive readiness.
- The separate Tail local-storage anomaly is **REDUCED / NOT REPRODUCIBLE** by
  the superseding oracle above and remains visible as historical evidence.
