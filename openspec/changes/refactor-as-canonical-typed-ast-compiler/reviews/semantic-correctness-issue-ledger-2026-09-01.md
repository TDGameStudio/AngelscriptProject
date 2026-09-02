# Canonical compiler semantic-correctness issue ledger — 2026-09-01

## Purpose and status vocabulary

This ledger keeps the correctness problems that materially changed the
Canonical compiler design or its acceptance tests in one review-facing record.
It complements the per-card attachments: the attachments retain the complete
fixture and report lineage, while this file answers four questions for each
problem:

1. what observable behavior was wrong;
2. which semantic invariant was missing;
3. how the test distinguished a real fix from a false green;
4. whether the issue, its OpenSpec task, and its broader umbrella are actually
   closed.

Status terms are intentionally strict:

- **CLOSED** — production fix is committed, focused and broader gates pass, and
  the owning task is checked where applicable;
- **CODE-FIXED / VALIDATION OPEN** — focused RED/GREEN exists, but the complete
  task matrix and review have not closed;
- **OPEN** — an acceptance or implementation gap is still outstanding;
- **REDUCED / NOT REPRODUCIBLE** — the required minimal reproducer and its
  strengthened fresh/reused-context oracle are green, so no isolated product
  defect is established. The original broader observation remains retained as
  historical evidence and may reopen its owner only if a concrete reproducer
  is later produced;
- **DEFERRED** — explicitly outside the current critical path by user decision.

The authoritative formal progress is now **110/136 = 80.9%** after Task 15.8
was reopened by the CTA-S184a evidence correction. Task 5.5 is closed on
plugin `182da08`; Task 5.6 is closed by CTA-S181. The separately owned
lifetime, TypedASTJIT, Bytecode/install, default-cutover and final-matrix work
remains open.

## `+=` family: four different failures, not one bug

`+=` exposed several independent defects. They are grouped here because a
single happy-path `Object += 7` test would have hidden the later problems.

### CTA-S146 — overloaded lvalue `Object += 7` stayed a generic Assign

- **Status:** **CLOSED** as part of Task 5.3.
- **Symptom:** Canonical Sema left the authored compound assignment as an
  `Assign +=` and attempted to convert `int` to the receiver type `T`.
  Canonical CodeGen consequently failed instead of calling
  `T::opAddAssign(int)`.
- **Missing invariant:** overloaded compound assignment is a resolved Call
  semantic, not an ABI/backend inference. The sealed AST must record the exact
  callee, receiver, dispatch, formal argument plan and result type.
- **Fix:** `ActOnAssignExpr` rewrites non-generated, non-external object
  compound operators (`+=`, `-=`, `*=`, and siblings) to the corresponding
  operator Call before generic assignment conversion. Primitive and enum
  compound assignment remains an Assign.
- **Authentic RED:**
  `Saved/Tests/cta-sema-call-53-opaddassign-red/`
  `20260901_065144_030_88903aed`, **0/1 FAIL**, with
  `srcType=int dstType=T` on the leftover Assign path.
- **GREEN:**
  `cta-sema-call-53-opaddassign-green`
  `20260901_065353_197_2890de06`, **1/1 PASS**; production CodeGen
  `cta-sema-call-53-opaddassign-codegen-green`
  `20260901_065429_154_8c9af873`, **1/1 PASS**, Canonical publisher,
  zero LEGACY compiler invocations, `Entry() == 7`.
- **Commit lineage:** plugin checkpoint `11b41cd`; parent evidence card in
  `attachments/canonical-opaddassign-call-rewrite-gate-2026-09-01.md`.

### CTA-S157 — rvalue `Make() += 7` was rejected as non-assignable

- **Status:** **CLOSED** as part of Task 5.3.
- **Symptom:** the overloaded compound-assignment rewrite required an lvalue,
  so a valid non-const VALUE temporary failed with
  `expression-not-assignable`.
- **Missing invariant:** the receiver of an overloaded operator Call may be a
  materialized VALUE temporary. Assignability of a storage lvalue must not be
  confused with the ability to invoke `opAddAssign` on that temporary.
- **Fix:** materialize the rvalue receiver once, then seal
  `T::opAddAssign(int)` with that temporary as the receiver.
- **Authentic RED:**
  `Saved/Tests/cta-sema-call-53-rvalue-addassign-red2/`
  `20260901_095803_319_95667f0b`, **0/1 FAIL**.
- **GREEN:**
  `cta-sema-call-53-rvalue-addassign-green`
  `20260901_095913_231_e5bf06f6`, **1/1 PASS**; production CodeGen
  `cta-sema-call-53-rvalue-addassign-codegen-diag`
  `20260901_100331_234_928907f4`, **1/1 PASS**, Canonical publisher,
  zero LEGACY compiler invocations, `Entry() == 42`.
- **Commit lineage:** plugin `b40f4d3`; parent `78369910`; detailed evidence in
  `attachments/canonical-rvalue-opaddassign-call-rewrite-gate-2026-09-01.md`.

### CTA-S177 — indexed `+=` evaluated the RHS after receiver/index effects

- **Status:** **CLOSED** with Task 5.4 on plugin `01c4158`.
- **Symptom:** the first indexed compound lowering produced Canonical trace
  `1,2,3` while LEGACY required RHS-first `3,1,2`.
- **Missing invariant:** compound-index assignment is one explicit ordered
  operation. The canonical shape must evaluate the RHS, receiver, index or
  reference-producing operation, updated value, and writeback in language
  order, with each mutation target evaluated once.
- **Fix:** publish a five-phase `Sequence` using `OpaqueValue` captures for the
  observable RHS, receiver and index/reference facts, followed by update and
  single writeback.
- **Authentic RED:**
  `Saved/Tests/cta-s177-rhs-order-red/`
  `20260901_183128_172_881c9764`, **0/1 FAIL**.
- **GREEN:** covered by the final Task 5.4 matrix listed below and by the exact
  sequencing/single-evaluation assertions in the CTA-S177 attachment.

### CTA-S177 — scalar-reference RHS aliasing made a correct trace return `21`

- **Status:** **CLOSED** with Task 5.4 on plugin `01c4158`.
- **Trigger:**

  ```angelscript
  MutateAndReturn()[0] += GetSharedRhs();
  ```

  `GetSharedRhs()` returns a reference to the scalar value `10` and records
  marker `8`. `MutateAndReturn()` records marker `9` and changes the same
  storage to `20`. `opIndex()` records marker `2`; the sink starts at `1`.
- **Symptom:** the trace was already the required `8,9,2`, but Canonical
  returned `21` rather than `11`. A trace-only test therefore gave misleading
  confidence.
- **Root cause:** both index-compound branches created the RHS `OpaqueValue`
  while its type was still a scalar reference. That correctly captured an
  address for a reference-typed opaque, but the language phase requires the
  scalar value to be read and frozen before receiver evaluation. The later
  addition reread the mutated `20` through the saved address.
- **Semantic invariant:** the RHS expression is evaluated **and its scalar
  value is observed** before the receiver/index chain. Object references and
  handles still preserve their required address/identity semantics; the fix is
  not a blanket reference decay.
- **Fix:** both overloaded `opIndex` and raw Index fallback paths call
  `DecayScalarLValueReferenceToRValue(...)` before RHS
  `ActOnOpaqueValueExpr(...)` capture.
- **Authentic RED:** Build PASS at
  `Saved/Build/cta-s177-rhs-ref-alias-valid-red3-build/`
  `20260901_194936_528_9970874d`; differential test
  `Saved/Tests/cta-s177-rhs-ref-alias-valid-red3/`
  `20260901_194959_539_1dab4840`, **0/1 as expected**, exact result `21`.
- **GREEN:** Build PASS at
  `Saved/Build/cta-s177-rhs-ref-alias-green-build/`
  `20260901_195057_398_24dc402e`; differential test
  `Saved/Tests/cta-s177-rhs-ref-alias-green/`
  `20260901_195113_684_2dbd37cd`, **1/1 PASS**, exact result `11`, trace
  `8,9,2`, each operation once through independent LEGACY and CANONICAL
  Engines.
- **Final Task 5.4 gates:** Semantics **15/15**, SemaAuthority **538/538**,
  ProductionCodeGen **230/230**, Frontend CanonicalAST **189/189**; see
  `cta-s177-task-5.4-closure-review-2026-09-01.md` and
  `attachments/canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`.

## Task 5.5 issues found and closed by CTA-S178

The following entries were discovered after Task 5.4 closed. They now have
committed production fixes, authentic RED/GREEN evidence, complete fresh gates
and independent closure review.

### Authored statement safe-point roles were not consistently published

- **Status:** **CLOSED** with Task 5.5 on plugin `182da08`.
- **Symptom:** source-built `DeclStmt`, ordinary `ExprStmt` and `IfStmt` nodes
  had `None` instead of `Statement`. This meant the AST did not carry the
  source-stepping/safe-point distinction required by the statement contract.
- **Authentic RED:**
  `Saved/Tests/cta-s178-statement-safepoint-red/`
  `20260901_201741_831_168423b4`, **0/1 FAIL**.
- **Current fix:**
  - authored local declarations are marked `Statement`;
  - authored expression statements are marked `Statement`;
  - `If` and `Case` are marked `Statement`;
  - ordinary `Switch` retains `Statement`, while exhaustive enum Switch keeps
    the specialized `SwitchInvalidValue` role;
  - Call and Return keep their specialized `Call` and `Return` roles.
- **Important contract distinction:** local declaration lowering also creates
  a synthetic initializer sibling `ExprStmt`. The current implementation and
  focused test deliberately keep that generated phase at `None`, so one
  authored declaration does not create a second source stepping event. A
  historical HIR note said “every ExprStmt” and would imply the opposite. This
  is recorded as an explicit contract reconciliation point, not silently
  treated as covered.
- **Focused GREEN:** Build PASS at
  `Saved/Build/cta-s178-statement-safepoint-green-build/`
  `20260901_202728_784_75a1c87a`; exact Sema test
  `Saved/Tests/cta-s178-statement-safepoint-green/`
  `20260901_202757_121_3d19bf9e`, **1/1 PASS**.
- **Selector/cardinality review correction:** the final test identifies the
  synthetic initializer as the Assign whose RHS is the exact target Call,
  requires every other authored expression statement to carry `Statement`,
  and rejects any unclassified extra ExprStmt.
- **Final focused GREEN:** statement-role selector **1/1** at
  `Saved/Tests/cta-s178-statement-role-selector-green/`
  `20260901_205719_464_7d73d51d`.
- **Broader GREEN:** the final complete SemaAuthority prefix passed
  **542/542** at
  `Saved/Tests/cta-s178-task55-semaauthority-final2/`
  `20260901_210909_052_aa2811dd`.

### Canonical Bytecode dropped sealed loop safe points for `for` and `do-while`

- **Status:** **CLOSED** with Task 5.5 on plugin `182da08`.
- **Symptom:** Sema sealed `for`, `while` and `do-while` with
  `LoopBackedge`, but Canonical Bytecode emitted explicit `SUSPEND/JitEntry`
  only for `while`. `for`/foreach and `do-while` silently lost the sealed
  semantic fact.
- **Review finding:** this was found by comparing the AST producer and
  Bytecode consumer, not by an existing failing suite.
- **False-green trap:** the first execution test saw `SUSPEND` and passed, but
  default line cues later transform every `LINE` opcode into `SUSPEND`.
  Therefore that result did not prove loop-role consumption.
- **Test correction:** the module now builds with
  `asEP_BUILD_WITHOUT_LINE_CUES=1`; only explicit loop safe-point emission can
  satisfy the opcode assertion.
- **Authentic RED after removing the false green:** Build PASS at
  `Saved/Build/cta-s178-loop-safepoint-authentic-red-build/`
  `20260901_202306_913_5b2e6fa2`; test
  `Saved/Tests/cta-s178-loop-safepoint-authentic-red/`
  `20260901_202347_746_8eef2725`, **0/1 FAIL** on the `for` SUSPEND assertion,
  even though both functions executed to `3`.
- **Current fix:** the backend consumes an exact sealed
  `LoopBackedge` role through one helper and fails closed on a missing/corrupt
  role. It emits at the correct physical phase for each loop shape:
  - `while`: after the successful condition, before the body;
  - `do-while`: after the body, before the trailing condition;
  - `for`/foreach: after the successful condition, before the body.
- **Focused GREEN:** Build PASS at
  `Saved/Build/cta-s178-loop-safepoint-green-build/`
  `20260901_202455_045_74e7caa2`; test
  `Saved/Tests/cta-s178-loop-safepoint-green/`
  `20260901_202512_982_09d22008`, **1/1 PASS**.
- **Final review GREEN:** For/Do provenance **1/1** at
  `Saved/Tests/cta-s178-for-do-provenance-green/`
  `20260901_205819_108_ea2875f3`; While with line cues disabled **1/1** at
  `Saved/Tests/cta-s178-while-no-line-cues-green/`
  `20260901_205819_108_52e4d0f4`. These tests also require zero LEGACY
  compiler invocations for the Canonical publication path.
- **Boundary:** this closes the positive safe-point producer/consumer path;
  forged malformed-role rejection remains Task 5.6.

### VM control matrix covered only one of three authored transfer paths

- **Status:** **CLOSED TEST GAP** with Task 5.5; no production control-target
  defect was found.
- **Symptom:** `LoopsSwitchTransfersAndSafePoints` compiled a source fixture
  containing switch `break`, loop `continue`, default `return`, `for`, `while`
  and `do-while`, but executed only `Selector=1`. The `continue` and default
  branches were dead test text. Its AST assertions also accepted either a
  While or DoWhile and any one non-None safe-point role.
- **Risk:** the method name and green result overstated its coverage. In
  particular, no runtime result proved that Continue targeted the For rather
  than the nested Switch, and no exact role/count assertion protected all
  three loop shapes.
- **Correction:** the final isolated sentinel executes three independent calls
  and adds an observable `Total += 100` body tail after the Switch:
  - `Selector=1 -> 305`, proving Switch Break exits only the Switch and the
    body tail still runs on all three For iterations;
  - `Selector=2 -> 32`, proving Continue targets the For and skips that body
    tail;
  - `Selector=0 -> 0`, exercising the default early Return.
  It also requires exact counts for For/Switch/While/DoWhile/Cases/Returns,
  exact FunctionEntry/LoopEntry/LoopBackedge roles, Statement roles for
  Switch/Cases, Transfer roles, and exact Break/Continue targets.
- **Final focused GREEN:** Build PASS at
  `Saved/Build/cta-s178-vm-control-isolated-sentinel-build/`
  `20260901_210112_856_c3aa9094`; exact VM test **1/1 PASS** at
  `Saved/Tests/cta-s178-vm-control-isolated-sentinel-green/`
  `20260901_210130_993_a35f3dc4`.
- **Classification:** no new production defect was exposed. This was a
  false-confidence test gap, and is recorded separately from compiler bugs.

## Task 5.5 positive matrix closed in the committed snapshot

The six gaps from the first subagent closure review have now been implemented
or explicitly reconciled:

1. `IfWithoutElseAndBareReturnsSealExactSourceShape` covers no-else geometry,
   two successful bare returns, invalid return-value expressions, Return roles
   and FunctionEntry;
2. `ForMultipleIncrementExpressionsRetainsBodyAndContinueTargetOnCompileSealPath`
   now covers exact increment source order, increment-clause range, typed bool
   condition, phase identities, LoopBackedge/LoopEntry, and Continue target;
3. `UnsignedGroupedSwitchSealsOrderedTypedCases` covers a `uint` selector,
   ordered `0,1,2,default` Cases, empty first grouped label, owned shared body,
   Case roles and Switch targets;
4. `LoopInsideSwitchTransfersTargetNearestControl` covers the reverse nesting
   direction: inner loop Break/Continue target the loop while outer case
   Breaks target the Switch;
5. `SourceStatementsPublishDistinctSafePointRoles` covers authored DeclStmt,
   ExprStmt, If, ordinary Switch and Cases, while explicitly keeping the
   synthetic declaration-initializer ExprStmt at None;
6. the corrected complete SemaAuthority prefix passes **542/542** and the
   strengthened VM control matrix passes **1/1** with all three transfer paths
   observable.

The first full positive-matrix run was **521/522**, failing only the unsigned
grouped-switch test. AST inspection showed the production graph was correct:
the selector was `uint`, Cases were ordered, grouping geometry and targets
were correct. The test had added an unsupported extra rule that every authored
integer literal must itself be retagged to `uint`. The historical requirement
was switch normalization, which Canonical represents through the typed
selector plus ordered constant values and geometry. Removing that overstrong
literal-type assertion made the focused test pass at
`Saved/Tests/cta-s178-unsigned-grouped-switch-green/`
`20260901_203945_452_cfc0a154`. This event is a **test-design correction**, not
a production RED and not a compiler bug.

Task 5.5 is formally checked. Final gates are Build PASS, SemaAuthority
**542/542**, ProductionCodeGen **231/231**, Semantics **15/15**, and the exact
VM control sentinel **1/1**, all with zero failures/skips. Independent CodeGen
and test reviewers returned APPROVE with no blocker/major after the last source
range and selector-precision corrections.

At the Task 5.5 checkpoint, Task 5.6 remained separately open for forged
malformed graphs and verifier rejection: wrong-kind, dangling, non-ancestor,
skipped-nearer, duplicate case, default not last, invalid fallthrough
placement/target, invalid phase shape, and fail-closed publication. CTA-S181
later closes that list. Cleanup, lifetime, cutover and final regression remain
owned by their corresponding later tasks.

## Historical Task 5.6 verifier findings from CTA-S179 (superseded by CTA-S181)

These findings were recorded before Task 5.6 was checked so that a partially
green malformed-graph suite could not erase compatibility or schema problems
found during review. Status and percentage statements inside this section are
historical investigation state; CTA-S181 later in this ledger is the current
closure disposition.

### Last-Case `fallthrough;` is a legal warn-and-compile compatibility case

- **Status:** **CODE-FIXED / VALIDATION OPEN**. The local verifier now accepts
  targetless final-Case Fallthrough and rejects a forged final-Case target;
  Task 5.6 remains open until the complete fresh gate and independent re-review.
- **Compatibility behavior:** LEGACY accepts a final Case containing
  `fallthrough;`, emits a warning, and compiles it. `WireFallthroughTargets`
  intentionally has no next Case to seal as the transfer target. Canonical
  Bytecode likewise authenticates the target only **if present**.
- **Review finding:** the first Task 5.6 verifier implementation rejected a
  final-Case Fallthrough with `fallthrough-last-case`. That would turn an
  established warning into a Canonical-only hard error and is therefore not a
  valid malformed-graph rule.
- **Required invariant:** a non-final Case Fallthrough must have the exact next
  Case target; a final-Case Fallthrough may have no target. A forged valid
  target on the final Case must be rejected.
- **Design lineage:** `attachments/wave-b-55-next.md` explicitly says not to
  add a last-Case rejection because LEGACY warns and compiles;
  `attachments/wave-b-56-safepoint-next.md` preserves the target-if-present
  rule for last-Case/incomplete construction.
- **Closure requirement:** replace the overstrict negative test with a
  publication-positive final-Case oracle plus a negative forged-target oracle,
  then rerun the complete verifier and Frontend prefixes.

### A single node safe-point field collides on an unbraced loop body

- **Status:** **CODE-FIXED / VALIDATION OPEN**. The local V13 representation
  keeps the statement's intrinsic `safePointRole` and records `LoopEntry` on
  the structural Loop-to-body edge as `loopBodySafePointRole`; producer,
  verifier, CodeGen, dump/matcher, public view and Sidecar paths are in sync.
- **Trigger family:** legal source such as an outer loop whose unbraced body is
  another loop, `break`, `continue`, `if`, or `switch`.
- **Observed producer behavior:** loop finalization stamps the body statement
  with `LoopEntry`. When the body itself needs an intrinsic role such as
  `LoopBackedge`, `Statement`, or `Transfer`, the single-value field is
  overwritten.
- **Why this matters:** the verifier's exact-role rule can reject legal
  source-built ASTs, while relaxing the rule would allow a malformed graph to
  reach a backend that relies on the intrinsic role. This is not merely a
  missing test; it exposes that LoopEntry describes a Loop-to-body phase/edge
  while the current field is node-owned.
- **Required oracle:** build and inspect real Canonical source graphs for at
  least `while (a) while (b) break;`, `while (a) break;`, and an unbraced
  nested statement with its own authored role. The solution must preserve both
  facts without re-running Sema or teaching the backend to infer them.
- **Architecture constraint:** do not silently expand the verifier into Sema,
  and do not change a serialized/public AST fact without updating its schema,
  dump/matcher coverage and owning OpenSpec contract. Cache V2/V12 execution
  remains deferred, but that does not permit an undocumented AST ABI change.

### Structured-control phase cardinality alone is not enough

- **Status:** **CODE-FIXED / VALIDATION OPEN**. The local verifier now checks
  For/Foreach phase kinds as well as cardinality and requires Break, Continue
  and Fallthrough to be leaf transfers. Focused RED/GREEN exists; final owning
  prefixes remain to be rerun after the switch-constant blockers below close.
- **Review finding:** the first verifier pass checked counts and some positions
  but could still accept a `For` initializer containing an invalid transfer,
  insufficiently authenticated Foreach initializer/body/increment phases, or
  transfer statements carrying payload children.
- **Required invariant:** each structured-control phase must have the exact
  canonical kind produced by Sema; `Break`, `Continue`, and `Fallthrough` must
  be leaf transfers with no expression, declaration or structural children.
- **Tests already added:** wrong `For` increment kind and invalid direct-Case/
  terminal Fallthrough placement now have forged-graph negatives.
- **Still required:** source-shape evidence for the allowed For/Foreach
  initializer kinds, forged wrong-kind phase tests for every authenticated
  position, and leaf-transfer negatives before Task 5.6 can close.

### Duplicate Case values must be compared in the selector's normalized domain

- **Status:** **CODE-FIXED / VALIDATION OPEN for the primitive selector
  representation; evaluator parity remains OPEN below**.
- **Authentic RED:** raw decimal `1` versus a sealed conversion wrapping raw
  hexadecimal `0x1` initially escaped duplicate detection at
  `Saved/Tests/cta-s179-task56-conversion-duplicate-red/`
  `20260901_220635_722_f7b73630`, **0/1 FAIL as expected**.
- **Current local correction:** the verifier's sealed-constant reader unwraps
  one-child `Construct`, `Conversion`, `MaterializeTemporary`, and `Cleanup`
  nodes. This correction is not yet a committed Task 5.6 close.
- **Remaining risk:** exact expression-type equality is not itself proof of
  equality after switch-selector normalization. For example, signed and
  unsigned constants may denote the same Case in the selector domain even if
  their immediate AST types differ.
- **Required invariant:** compare sealed Case constants using the exact
  selector-normalized fact established by Sema. Do not grow a second general
  constant evaluator inside the structural verifier.
- **Closure requirement:** prove whether Sema already converts every Case to
  the selector type, add a mixed-exact-type normalized duplicate oracle, and
  make the sealed representation or verifier consume that authoritative fact.

### Reusing the same child twice under one parent is still a malformed graph

- **Status:** **CODE-FIXED / VALIDATION OPEN**. The local parent-map verifier
  rejects a second incoming structural edge even when both edges name the same
  parent; same-Block and same-Switch forged negatives are present.
- **Review finding:** the parent map rejected a child owned by two different
  parents but could accept the same child ID repeated twice by one Block or
  Switch. The backend would then emit the supposedly unique statement twice.
- **Required invariant:** every structural statement node has one incoming
  structural edge, not merely one distinct parent ID.
- **Closure requirement:** add same-Block duplicate-child and same-Switch
  duplicate-Case negatives, reject the second edge even when the parent ID is
  equal, and prove fail-closed Seal/publication behavior.

### Switch Case constant evaluation was only a partial, drifting language clone

- **Status:** **OPEN — Task 5.6 blocker confirmed by two independent reviews**.
- **Symptom:** the initial primitive selector-domain wrapper solved the
  structural duplicate problem, but its private `TryGetSwitchCaseConstant`
  helper recognized only a subset of the expressions that the maintained
  LEGACY compiler folds. It also collapsed distinct error classes into
  `Case expressions must be constants`.
- **Missing invariant:** the sealed Case fact must be produced from the same
  typed constant-expression semantics as the maintained language: actual
  intermediate width/signedness, engine properties, readonly provenance and
  exact diagnostic class all matter before the final selector-domain
  conversion.
- **Authentic RED — operator/provenance set:** Build PASS at
  `Saved/Build/cta-s179-task56-constant-subset-red-build2/`
  `20260901_234319_213_9ef44dae`; focused tests
  `Saved/Tests/cta-s179-task56-constant-subset-red2/`
  `20260901_234351_125_d7df4012`, **0/5 FAIL as expected**.
- **Authentic RED — edge/diagnostic set:** Build PASS at
  `Saved/Build/cta-s179-task56-constant-edge-red-build2/`
  `20260901_234806_609_9de49390`; focused tests
  `Saved/Tests/cta-s179-task56-constant-edge-red/`
  `20260901_234838_108_c1fd0e8c`, **0/3 FAIL as expected**.
- **Required design correction:** replace the boolean evaluator with a typed
  result that separates valid integral constant, nonconstant, constant but
  nonintegral, divide-by-zero and power-overflow outcomes. All operands and
  branches must be visited for diagnostics; host-language short-circuiting may
  not hide errors in a Canonical child.

#### `>>`, `>>>` and shift-count width were evaluated with the wrong rules

- **Status:** **OPEN**.
- **Observed defects:** `>>` was selected as logical/arithmetic from result
  signedness even though this fork defines `>>` as logical and `>>>` as
  arithmetic; `>>>` was unrecognized; every shift count used `& 63` although
  32-bit operations require `& 31` and 64-bit operations require `& 63`.
- **Locked RED cases:** `-2 >> 1` versus `2147483647`, `-2 >>> 1` versus `-1`,
  and `1 << 32` versus `1` must each be diagnosed as duplicate Cases.

#### Integer power `**` and its overflow diagnostic were missing

- **Status:** **OPEN**.
- **Observed defects:** `2 ** 3` was classified nonconstant instead of
  duplicating `8`; `2 ** 31` lost the language diagnostic
  `Overflow in exponent operation`.
- **Required invariant:** use the maintained fork's exact signed/unsigned
  32/64-bit power rules, including zero/negative-exponent and overflow
  recovery, rather than inventing a generic host multiplication loop.

#### Constant declaration provenance admitted mutable globals and lost local consts

- **Status:** **OPEN**.
- **Observed defects:** a mutable global with a known initializer carried
  `hasConstantValue` and was incorrectly accepted as a Case, while a primitive
  readonly local such as `const int K = 1` was rejected.
- **Missing invariant:** “initializer value is known” is not the same semantic
  fact as “this declaration is a language pure constant.” Case eligibility
  must require primitive/enum readonly provenance and must evaluate the local
  const initializer when no cached pure-constant value is available.

#### Explicit float-to-integer constants and nonintegral diagnostics diverged

- **Status:** **OPEN**.
- **Observed defects:** `case int(1.9f)` was rejected although LEGACY folds it
  to integral `1`; a direct constant float Case was routed to the generic
  nonconstant diagnostic instead of `Switch expressions must be integral
  numbers`.
- **Required invariant:** constantness and final Case integrality are separate
  decisions. A constant conversion may become an integral Case even when its
  authored child is floating point.

#### Exceptional division/modulo and the integer-division engine property drifted

- **Status:** **OPEN**.
- **Observed defects:** division or modulo by zero was downgraded to
  nonconstant instead of preserving `Divide by zero`; 32/64-bit MIN divided by
  `-1` did not preserve LEGACY's zero recovery; the historical unsigned
  bit-pattern special case drifted; and `asEP_DISABLE_INTEGER_DIVISION=1` was
  ignored, so an expression that becomes float64 reached the primitive fact
  verifier instead of being rejected as nonintegral.
- **Locked RED cases:** `int32/int64 MIN / -1` versus zero, the unsigned
  `0x80000000 % 0xFFFFFFFF` bit-pattern case, exact divide-by-zero diagnostic,
  and the enabled engine-property case.

### Enum selector Cases bypass the common constant-expression firewall

- **Status:** **OPEN — Task 5.6 blocker**.
- **Symptom:** primitive selectors take the new two-phase normalization path,
  but enum selectors currently bypass it. The verifier's nonprimitive fallback
  cannot reject every dynamic expression, and CodeGen may compare a runtime
  Case expression that LEGACY requires to be a compile-time constant.
- **Required invariant:** every switch Case is constant-validated before
  sealing. Enum selectors must additionally preserve nominal enum identity,
  the `typeCheckSwitchEnums` policy and the maintained 32-bit duplicate
  identity; this cannot be approximated by the primitive int/uint path.
- **Required RED:** an enum selector with a parameter used as Case must be
  rejected as nonconstant; same-enum duplicate values and cross-enum mismatch
  under `typeCheckSwitchEnums=true` must retain their exact behavior.

### Verifier and CodeGen currently disagree on the authoritative Case value

- **Status:** **CODE-FIXED / TARGETED GREEN; owning-prefix validation still
  open**.
- **Symptom:** Sema seals the selector-normalized value in an outer
  `Conversion` marker named `switch-case-domain`, and the verifier authenticates
  and compares its `literalBits`; `EmitSwitch` still calls `EmitExpr` on that
  wrapper, whose ordinary conversion path executes the authored child and
  ignores the authenticated bits.
- **Missing invariant:** the authenticated sealed fact is the single runtime
  authority. The authored expression remains source/provenance only; CodeGen
  must materialize the selector-typed Case constant directly from the fact.
- **Required authentic RED:** forge a pre-Seal graph whose fact is `9` and
  authored child is `7`, seal it successfully, execute `switch (9)`, and require
  the Case body selected by fact `9`. Current child-driven CodeGen selects the
  default path.
- **Authentic RED:** the native-observer fixture executed normally but observed
  the default branch (`status=0 observed=90`) at
  `Saved/Tests/cta-s179-task56-codegen-authority-red5/`
  `20260902_000156_273_f7beb309` (**0/1 PASS**).
- **Correction:** primitive `EmitSwitch` now mechanically validates the sealed
  `switch-case-domain` wrapper, materializes its selector-typed `literalBits`,
  and never emits the authored provenance child. Enum Cases deliberately stay
  on their nominal typed path until the separate enum constant firewall below
  is implemented.
- **Targeted GREEN:** **1/1 PASS** at
  `Saved/Tests/cta-s179-task56-codegen-authority-green/`
  `20260902_000354_747_483e0b6d`; build PASS at
  `Saved/Build/cta-s179-task56-codegen-authority-green-build/`
  `20260902_000335_787_7eed5198`.

### Sidecar V13 exposed two stale schema-number assertions

- **Status:** **CODE-FIXED / VALIDATION OPEN — test maintenance defect, not
  Cache V2 scope expansion**.
- **Authentic RED:** complete ASTBodySidecar prefix **25/27 PASS** at
  `Saved/Tests/cta-s179-task56-sidecar-v13-red/`
  `20260901_233258_737_abfbe8d1`; only two old assertions still expected schema
  `12` while their messages and production contract required V13.
- **Correction:** both assertions now expect `13`. The prefix must be rerun;
  no Cache V2 execution/cutover work is being claimed or reopened.

### Ordinary conditional `?:` was briefly assigned an invalid test oracle

- **Status:** **TEST ORACLE CORRECTED — not a compiler defect**.
- **Event:** an early RED expected `(true ? 7 : 9)` to fold as a Case constant.
  Independent comparison against the maintained compiler showed that ordinary
  primitive conditional compilation deliberately clears its constant flag, so
  the correct outcome is `Case expressions must be constants`.
- **Disposition:** the false duplicate oracle was removed and replaced with an
  explicit rejection case. It is excluded from product-defect counts and from
  progress credit.

### CTA-S179 constant/enum follow-up — 2026-09-02 00:26 CST

- **Status:** **TARGETED GREEN / TASK 5.6 CLOSURE STILL OPEN**. This update
  supersedes the earlier `OPEN` implementation status for the specifically
  tested constant/operator/diagnostic and enum-firewall cases above; it does
  not erase their authentic RED history and does not close the umbrella task.
- **Repair build:** **PASS**, exit `0`, at
  `Saved/Build/cta-s179-task56-enum-domain-green-build/`
  `20260902_002546_218_2827054b`.
- **Focused GREEN:** **11/11 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s179-task56-constant-enum-green/`
  `20260902_002607_141_01c30edf`.
- **Now covered:** logical `>>`, arithmetic `>>>`, 32-bit shift masking,
  integer `**`, readonly-local and mutable-global provenance, explicit
  float-to-integer conversion, 32/64-bit MIN division recovery, unsigned
  historical modulo recovery, divide-by-zero, exponent overflow,
  `asEP_DISABLE_INTEGER_DIVISION`, runtime enum Case rejection, same-value
  enum duplicate rejection, and cross-enum `typeCheckSwitchEnums` diagnostics.
- **Authority correction:** `asEP_DISABLE_INTEGER_DIVISION` is now authored by
  expression Sema as float64 operand conversions/result type. The Switch
  evaluator consumes that sealed type and does not query Engine policy to
  reinterpret an integer AST. Both primitive and enum Case values are sealed
  as `switch-case-domain` facts; verifier and CodeGen authenticate/consume the
  fact instead of executing the authored provenance child.
- **Still open before Task 5.6 can close:** direct unsupported selector types
  such as `bool` must fail in Canonical Sema with the maintained integral
  diagnostic; bool/comparison/logical constant classification and floating
  binary subexpressions beneath explicit integer conversion need focused
  parity oracles; diagnostic recovery/side-band behavior needs review; a valid
  enum Switch needs positive CodeGen authority evidence; and the final source
  state still needs fresh Verifier, Frontend, SemaAuthority,
  ProductionCodeGen, Semantics, Snapshot/API, Sidecar V13 and migrated-control
  owning-prefix runs.
- **Independent review:** Task 5.6 remains approximately **80–85%** internally
  and is not ready to check. Formal change progress remains **110/136 =
  80.9%**; calibrated overall engineering progress is approximately **85%**.

### CTA-S179 selector/float follow-up — 2026-09-02 00:43 CST

- **Status:** **AUTHENTIC RED / PRODUCTION FIX OPEN**. Two remaining Switch
  compatibility gaps that were previously static-review findings now have
  exact source-path `SemaAuthority` oracles.
- **Build evidence:** `cta-s179-task56-selector-float-red-build` passed with
  exit `0` at
  `Saved/Build/cta-s179-task56-selector-float-red-build/`
  `20260902_003844_330_3c6865a5`.
- **RED evidence:** the combined gate is **0/2 PASS**, `2` failed and `0`
  skipped at `Saved/Tests/cta-s179-task56-selector-float-red/`
  `20260902_003935_650_159ba03a`.
- **Unsupported selector failure:**
  `NonIntegralSwitchSelectorFailsInSemaWithoutLegacyCompiler` observed a
  `bool` selector reaching Canonical CodeGen and failing with `code=-7`, rather
  than Canonical Sema emitting the maintained
  `Switch expressions must be integral numbers` diagnostic. This confirms
  that unsupported selector classification is still incorrectly backend-owned.
- **Typed floating constant failure:**
  `FloatBinaryExplicitIntCaseMatchesLegacyConstant` observed
  `int(0.5f + 0.5f)` fail as `Case expressions must be constants`, rather than
  fold to `1` and collide with `case 1` as `Duplicate switch case`. This
  confirms that the current floating helper handles literals/unary/wrappers
  but not the typed Binary subtree.
- **Publication contract in both tests:** the final GREEN must require zero
  LEGACY compiler invocations and no Runtime Bytecode or retained Canonical
  snapshot on semantic rejection.
- **Structured-control reconciliation:** an independent exact-method audit
  found that the Task 5.6 structural target/phase/verifier/Snapshot/Sidecar
  clauses already have current CanonicalAST coverage. The old “HIR tests not
  migrated” wording is stale and must not cause HIR recreation. Task 5.6
  remains open for these two REDs, final constant-recovery parity, a positive
  valid-enum CodeGen authority test and fresh complete owning-prefix runs.
- **Maintained-LEGACY oracle correction:** constant bool/comparison/logical
  Cases are constant-but-nonintegral; float32 arithmetic must round at each
  float32 operation before an explicit integer cast. Integer `/0` reports
  `Divide by zero`, recovers value `0` and continues Case scanning, so a later
  `case 0` also reports `Duplicate switch case`. Integer power overflow
  similarly reports overflow, retains its recovery value and continues. The
  current Canonical terminal-status model proves the isolated first diagnostic
  but not the recovery-value/continued-duplicate contract. An initial
  subreview statement that `/0` was silent was rejected after direct source
  inspection: `CompileOperator` emits the diagnostic before its constant-fold
  recovery branch.
- **Broader provenance routing:** readonly/global constant provenance and
  forward/cyclic global dependency resolution belong mainly to Tasks 5.9/13.2.
  Task 5.6 must consume an authenticated sealed constant fact and must not grow
  a second global-initialization authority.

### CTA-S179 selector/float GREEN and bool/recovery RED — 2026-09-02 01:03 CST

- **Status:** **SELECTOR/FLOAT TARGETED GREEN; BOOL/RECOVERY AUTHENTIC RED;
  TASK 5.6 OPEN**.
- **Expanded selector/float RED:** build PASS at
  `Saved/Build/cta-s179-task56-selector-float-matrix-red-build/`
  `20260902_005235_956_1944917a`; behavior gate **0/2 PASS** at
  `Saved/Tests/cta-s179-task56-selector-float-matrix-red/`
  `20260902_005305_985_34c3ccae`.
- **Selector/float repair:** the selector gate now rejects `bool`, floating,
  and object selectors in Canonical Sema, and the typed float evaluator covers
  float32 `+`, `-`, `*`, `/`, `%`, and `**`, including per-operation rounding
  at `16777216.0f + 1.0f`.
- **Focused selector/float GREEN:** final build PASS at
  `Saved/Build/cta-s179-task56-selector-object-fixture-build/`
  `20260902_005545_670_e69a1289`; behavior **2/2 PASS**, zero failures/skips,
  at `Saved/Tests/cta-s179-task56-selector-float-matrix-green2/`
  `20260902_005615_177_33480f56`.
- **Bool/recovery RED:** build PASS at
  `Saved/Build/cta-s179-task56-bool-recovery-red-build/`
  `20260902_005834_332_252e5a70`; behavior **0/3 PASS**, three failures and no
  skips, at `Saved/Tests/cta-s179-task56-bool-recovery-red/`
  `20260902_005904_749_5af3a86a`.
- **Exact remaining semantic failures:** constant bool/comparison/logical
  expressions are misclassified as nonconstant instead of
  constant-but-nonintegral; a runtime bool Case loses the maintained second
  integral diagnostic; integer `/0` and power-overflow stop after their first
  diagnostic instead of retaining recovery value `0` and continuing duplicate
  Case diagnosis.
- **Root cause:** the current evaluator exposes one terminal status and thus
  conflates constness, exact integral classification, recovery-value
  availability, and arithmetic diagnostic sideband. The repair must return
  these as orthogonal typed facts, preserve source-ordered multi-diagnostics,
  continue duplicate analysis with valid recovery values, and commit no AST
  normalization/publication when any diagnostic occurred.
- **Enum CodeGen authority follow-up:** a production-graph prepared-builder
  oracle remains required with authored enum value `7` and authenticated
  nominal-domain fact `-1`. It must prove that CodeGen consumes the fact rather
  than its provenance child and emits enum comparison constants as signed
  32-bit dwords rather than following the script enum's one-byte storage size.
- **Assessment:** Task 5.6 is approximately **80% implemented** but only
  **65–70% closure-ready**. Formal progress remains **110/136 = 80.9%** and
  calibrated overall engineering progress is approximately **84%**.

## Historical `Tail += 100` probe state (superseded by CTA-S179)

- **Historical status at discovery:** **OPEN**, tracked under Task 9.2 first
  and Task 9.6 if physical frame-layout evidence confirmed the lower-layer
  ownership. This status is retained as authentic investigation history and is
  superseded by the reduced GREEN disposition in CTA-S179 below.
- **Checklist caveat:** Task 9.2 is currently checked. This failure was found
  in an intermediate broad sentinel and has not yet been reduced to the
  standalone probe below, so the formal numerator is not changed solely from
  the current ambiguous fixture. If the minimal probe reproduces a Canonical
  local read/write/slot failure, reopen 9.2 and revise formal progress from
  `110/136` to **`109/136 = 80.1%`**. If it does not reproduce, debug the broad
  fixture and reroute or close the finding; do not leave an unresolved 9.2
  defect permanently hidden beneath a checked row.
- **Trigger:** an intermediate control sentinel introduced a new local
  `int Tail = 0;`, executed `Tail += 100` after the Switch, and returned a sum
  containing `Tail`.
- **Observed result:** the correct control-path values `6` and `32` were both
  shifted by the same garbage value `13873`, producing `13879` and `13905`.
  The same-context pattern suggests storage reuse amplifies the symptom, but
  does not establish the root cause.
- **Why this is not a fifth `+=` semantic bug:** moving the same observable
  sentinel to the already established `Total` local makes the Break/Continue/
  Return matrix pass exactly as `305/32/0`. The operator sequencing, target and
  transfer behavior are therefore independently green. The unresolved fact is
  whether the declaration initializer, compound-assignment lhs and returned
  DeclRef agree on the same DeclId-to-slot mapping.
- **Diagnostic evidence:** broad probe **0/1** at
  `Saved/Tests/cta-s178-vm-control-sentinel-green/`
  `20260901_205819_110_28162e20`; exact-value diagnostic rerun at
  `Saved/Tests/cta-s178-vm-control-sentinel-diagnostic/`
  `20260901_205941_039_32cbb3dd`.
- **Required next oracle:** compile
  `int Probe(bool M) { int Tail = 0; if (M) Tail += 100; return Tail; }` and
  require fresh-context `false=0`, `true=100` plus same-context
  `false -> true -> false = 0 -> 100 -> 0`. At the AST layer, assert that the
  initializer lhs, compound lhs and Return DeclRef all resolve to the same
  `Tail` DeclId. Different AST IDs route the issue to Sema/13.2; identical AST
  IDs with inconsistent CodeGen storage route it to 9.2/9.6.

## Deferred/non-gating work

Cache V2/V12 prototype refactor and testing is **DEFERRED** by the user's prior
decision. The completed Cache containment contract is not reopened, Cache is
not used as evidence in this ledger, and it was not a gate for either the
closed Task 5.4 sequencing slice or the closed Task 5.5 statement/control
slice.

## CTA-S179 follow-up — 2026-09-02 01:42 CST

This section supersedes the stale current-status statements above without
removing their authentic RED history.

### Typed Switch constants and recovery are now focused GREEN

- **Status:** **CLOSED AT FOCUSED GATE / TASK 5.6 STILL OPEN**.
- The original bool/recovery gate moved from **0/3** to **3/3 PASS** at
  `Saved/Tests/cta-s179-task56-typed-result-green/`
  `20260902_012201_844_79b4f8ae`.
- Runtime dividend with a constant zero `/` or `%` divisor moved from **0/1**
  to **1/1 PASS** at
  `Saved/Tests/cta-s179-task56-runtime-zero-diagnostic-green/`
  `20260902_013335_648_5430444a`.
- Constness, exact type, recovery-value availability and arithmetic diagnostic
  sidebands are now represented independently. `/0` and power-overflow retain
  recovery values for later duplicate checking; a nonconstant dividend still
  emits divide-by-zero before the independent nonconstant-Case diagnostic.

### Enum comparison-domain authority is focused GREEN

- **Status:** **32-BIT CASE FACT CONSUMPTION CLOSED; INVALID-VALUE ROUTE OPEN**.
- Authentic production RED: **0/1** at
  `Saved/Tests/cta-s179-task56-enum-codegen-authority-red/`
  `20260902_012651_278_c7f4ffed`.
- Repair GREEN: **1/1 PASS** at
  `Saved/Tests/cta-s179-task56-enum-codegen-authority-green/`
  `20260902_012800_093_992fd4b6`.
- CodeGen now consumes authenticated enum `switch-case-domain` bits as a
  32-bit VM dword instead of truncating them to the enum's one-byte storage
  width. Authored enumerator `7` versus authenticated fact `-1` proves that the
  sealed fact, not the provenance child, owns comparison behavior.
- Negative enumerator exhaustiveness normalization separately moved from RED
  to GREEN at
  `Saved/Tests/cta-s179-task56-negative-enum-exhaustive-green/`
  `20260902_013032_170_9656d547`.

### Mutable global provenance broad RED is repaired

- **Status:** **CLOSED**.
- Current-source SemaAuthority first ran **563/564**, with only
  `MutableGlobalCaseFailsInSemaWithoutLegacyCompiler` failing, at
  `Saved/Tests/cta-s179-task56-sema-current/`
  `20260902_013649_855_83a9e332`.
- Root cause: `hasConstantValue` was accepted before declaration ownership and
  constness, so mutable global storage with a folded initializer became a Case
  constant.
- The classifier now distinguishes enum members, readonly locals, sealed const
  globals and mutable/field storage. Focused GREEN is **1/1** at
  `Saved/Tests/cta-s179-task56-mutable-global-green/`
  `20260902_013946_760_2d98ecc1`; the complete current SemaAuthority prefix is
  **564/564 PASS** at
  `Saved/Tests/cta-s179-task56-sema-current-green/`
  `20260902_014022_928_1231d762`.

### Sidecar V13 stale-assertion issue is now closed

- **Status:** **CLOSED**.
- The old **25/27** report remains valid RED history for stale V12 assertions.
- The corrected current prefix is **27/27 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s179-task56-sidecar-current/`
  `20260902_013550_625_c42eea1b`.
- This validates the active Canonical AST sidecar representation only; it does
  not reopen or complete the user-deferred Cache V2 restore/product redesign.

### Three Task 5.6 Major issues found by CTA-S180 (superseded by CTA-S181)

The list below is retained as the pre-repair review finding. All three issues
are **CLOSED** by the RED-to-GREEN evidence and seven-owner gate recorded under
CTA-S181 later in this ledger.

1. Sema publishes `SwitchInvalidValue` for an exhaustive enum Switch, but
   Production Bytecode does not consume it; an unmatched raw enum selector
   silently jumps to the Switch end instead of following LEGACY's exception
   path.
2. Cross-enum nominal mismatch returns before normalized duplicate checking,
   dropping the maintained second `Duplicate switch case` diagnostic.
3. Enum exhaustiveness does not exclude `MAX` and `*_MAX` sentinels as LEGACY
   does, so the invalid-value role can be classified incorrectly.

These were correctness gaps, not merely missing broad tests. They blocked Task
5.6 until focused RED/GREEN evidence existed for all three and the final
Verifier, Frontend, ProductionCodeGen, Semantics and Module Snapshot prefixes
joined the current SemaAuthority and Sidecar owners. CTA-S181 records that
completed condition.

### `+=` permanent disposition

The compound-assignment ledger remains exactly four resolved defects:

1. overloaded lvalue `Object += 7` needed resolved `opAddAssign` Call rewrite;
2. rvalue `Make() += 7` needed one-time receiver materialization;
3. indexed `+=` needed RHS-first `3,1,2` evaluation order;
4. scalar-reference RHS aliasing needed a pre-mutation value snapshot, yielding
   `11` instead of `21`.

The separate Tail probe is now **REDUCED / NOT REPRODUCIBLE**. The strengthened
oracle is **1/1 PASS** at
`Saved/Tests/cta-s179-tail-declid-strengthened/`
`20260902_011308_781_6e3217c8`: fresh and reused contexts produce
`0 -> 100 -> 0`, and initializer, `Tail += 100` lhs and Return share one exact
DeclId. It is not a fifth `+=` bug and Task 9.2 remains checked.

## CTA-S179 point-in-time bottom line (historical; superseded by CTA-S184a)

- The important `+=` defects are now permanently recorded as four distinct
  failures: overloaded-call rewrite, rvalue receiver materialization,
  sequencing order, and scalar-reference value snapshotting.
- Task 5.4 remains genuinely **CLOSED** at plugin `01c4158`.
- The statement-role and loop-safe-point defects are **CLOSED** on plugin
  `182da08`; Task 5.5's positive matrix is independently approved.
- Primitive and enum Switch Case-domain authority is **CLOSED**: Sema seals
  typed constant facts, verifier authenticates them, and the backend consumes
  normalized values and the exhaustive-enum invalid-value role instead of
  evaluating authored provenance or recomputing Sema policy.
- The `Tail` anomaly is recorded separately because its surface syntax uses
  `+=`, but the reduced oracle proves declaration/storage identity and
  compound-assignment sequencing are both correct in the isolated case. Its
  current disposition is **REDUCED / NOT REPRODUCIBLE**, not open.
- Formal progress after CTA-S181 is **111/136 = 81.6%**. Task 5.6 is checked;
  the resolved `Tail` probe does not reopen Task 9.2 and is not hidden by the
  Task 5.5 close.

## CTA-S180 independent enum/switch review — 2026-09-02 01:51 CST

Three independent read-only reviews rechecked the remaining Task 5.6 gaps
against current Canonical Sema/Verifier/Bytecode and the LEGACY compiler. They
made no source changes and did not promote any checklist row. All three gaps
are confirmed as real behavior differences:

1. **`SwitchInvalidValue` CodeGen consumption is missing.** Sema authors and
   the verifier accepts `asAST_SAFEPOINT_SWITCH_INVALID_VALUE`, but
   `asCCanonicalBytecodeEmitter::EmitSwitch()` currently chooses only between a
   source `default` label and the switch end. LEGACY routes an unmatched raw
   value from an exhaustive enum switch to `asBC_ThrowException(0)`, whose VM
   message is `Invalid enum value passed to switch`. The repair must consume
   only the authenticated role, preserve ordinary last-case fallthrough with a
   jump over the synthetic throw block, and must not recompute exhaustiveness
   in CodeGen.
2. **Cross-enum mismatch recovery stops too early.** With
   `asEP_TYPECHECK_SWITCH_ENUMS=1`, LEGACY diagnoses the nominal mismatch, then
   continues signed 32-bit normalization and duplicate checking. Canonical
   currently returns `asSWITCH_DOMAIN_SEAL_ENUM_TYPE_MISMATCH` immediately.
   The focused closure fixture must produce the mismatch first and
   `Duplicate switch case` second, then prove publisher `NONE`, zero LEGACY
   compiler calls, no Runtime function and no retained snapshot.
3. **`MAX` / `*_MAX` sentinel parity is absent.** LEGACY excludes an exact
   case-sensitive `MAX` or a case-sensitive `_MAX` suffix from enum
   exhaustiveness requirements. Canonical currently requires every enum child
   value to be covered. The rule belongs only in
   `SwitchHasInvalidEnumValueEdge()` using the enum child's bare Canonical
   declaration name; Bytecode and TypedASTJIT must not scan names or rebuild
   the rule.

The agreed minimal TDD closure is therefore:

- one ProductionCodeGen prepared-script-enum VM oracle for a valid row and an
  invalid raw enum row, with Canonical publisher and zero LEGACY invocation;
- one cross-enum two-diagnostic analyze-all/commit-none Sema oracle;
- three sealed-role Sema rows for exact `MAX`, suffix `_MAX`, and ordinary
  case-sensitive `Max`;
- the neighboring switch fallthrough/control tests and all seven Task 5.6
  owning prefixes after the repairs.

This section is the historical pre-repair review. At that point it added no
GREEN evidence and formal progress correctly remained **110/136 = 80.9%**.
CTA-S181 below supersedes its open-state conclusion.

## CTA-S181 Task 5.6 enum/switch closure — 2026-09-02 02:23 CST

- **Status:** **CLOSED**; OpenSpec Task 5.6 is checked.
- **Cross-enum recovery:**
  `CrossEnumCaseMismatchContinuesDuplicateDiagnosisWithoutPublishing`
  preserves mismatch-then-duplicate diagnostic order and proves
  analyze-all/commit-none. Authentic RED:
  `Saved/Tests/cta-s180-cross-enum-recovery-red/`
  `20260902_015652_174_d61ce4be`; focused GREEN **1/1**:
  `Saved/Tests/cta-s180-cross-enum-recovery-green/`
  `20260902_015759_680_c65f62c5`.
- **Enum sentinel role:**
  `EnumSentinelNamesPreserveLegacyExhaustivenessRoleCaseSensitively` proves
  omitted exact `MAX` and suffix `_MAX` produce `SwitchInvalidValue`, while
  case-sensitive `Max` remains ordinary `Statement`. Authentic RED:
  `Saved/Tests/cta-s180-enum-sentinel-role-red/`
  `20260902_020144_553_62c03bff`; focused GREEN **1/1**:
  `Saved/Tests/cta-s180-enum-sentinel-role-green3/`
  `20260902_020602_133_f98a7e3a`.
- **Invalid raw enum execution:**
  `PreparedExhaustiveScriptEnumSwitchRaisesVmExceptionForInvalidRawValue`
  proves the sealed role before CodeGen, Canonical publisher provenance, zero
  LEGACY calls, a valid raw control value and exact
  `Invalid enum value passed to switch` exception for an undefined raw value.
  Authentic RED **0/1**:
  `Saved/Tests/cta-s180-switch-invalid-red/`
  `20260902_020805_191_81a88276`; focused GREEN **1/1**:
  `Saved/Tests/cta-s180-switch-invalid-green/`
  `20260902_020922_550_f6a7fb3c`.
- **Independent review:** the post-repair read-only review found no blocker and
  confirmed that final current-source owner gates were the only remaining
  Task 5.6 closure condition.
- **Final seven-owner gate:** SemaAuthority **566/566**, Cache ASTBodySidecar
  **27/27**, Frontend Verifier **74/74**, Frontend CanonicalAST **203/203**,
  ProductionCodeGen **234/234**, Semantics **16/16**, and Module Snapshot
  **13/13** all pass with zero failures/skips. Exact directories and semantic
  non-claims are in
  `attachments/canonical-structured-control-verifier-closure-gate-2026-09-01.md`.

The `+=` disposition remains unchanged and explicit: exactly four resolved
semantic defects are recorded; `Tail += 100` is **REDUCED / NOT
REPRODUCIBLE**, shares one DeclId across initializer/lhs/Return, is not a fifth
compound-assignment bug, and does not reopen Task 9.2.

At the CTA-S181 checkpoint, formal progress was **111/136 = 81.6%** with
**25** checklist rows open. This historical value was superseded when
CTA-S184a reopened Task 15.8; the current authoritative value is stated at
the top of this ledger. At that checkpoint, calibrated engineering progress
was approximately **86%**; this was not a
release-readiness claim because lifetime umbrellas, TypedASTJIT, Bytecode and
install isolation, default cutover, and final focused/All matrices remain open.

## CTA-S182 temporary full-expression lifetime authority — 2026-09-02 03:41 CST

- **Status:** **SLICE CLOSED / COMMITTED** at plugin commit `41cafb7` under
  Task 5.7. The first direct constructor-temporary full-expression family is
  green, but the complete lifetime matrix is not closed and Task 5.7 remains
  unchecked.
- **Original semantic gap:** a source `FTracked();` statement sealed the exact
  `ExprStmt -> Cleanup -> MaterializeTemporary -> Construct` shape and exact
  `FTracked::~FTracked()` declaration, but published zero `TEMPORARY` lifetime
  records. The compatibility Cleanup wrapper was therefore still hidden
  lifetime authority.
- **Authentic source RED:** **0/1 FAIL** at
  `Saved/Tests/cta-s182-temporary-exprstmt-red/`
  `20260902_025052_561_53d30def` after a passing build.
- **Shared-view/verifier RED:** **70/72 PASS** at
  `Saved/Tests/cta-s182-temporary-verifier-red/`
  `20260902_025652_371_015d9da7`. The two failing gates required one derived
  full-expression cleanup plan and rejection of a supported source shape with
  no Sema-authored record.
- **Implemented invariant:** Sema completes a real expression statement by
  authoring one exact `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record.
  Its subject and activation are the Materialize Expr, its action is the exact
  destructor Decl, its semantic region is the owning ExprStmt, and its routes
  are `NORMAL | EXCEPTION`. The shared verifier authenticates the relation in
  both directions and derives a transient full-expression exit plan without a
  lexical scope edge.
- **Review-discovered firewall gaps:** the first implementation used a boolean
  supported-shape probe, so a direct value temporary with a missing/foreign
  destructor could be mistaken for a non-candidate. It also did not
  authenticate the inner Construct owner/type or Cleanup wrapper type. The
  repaired three-state classifier distinguishes `NOT_CANDIDATE`, `MALFORMED`
  and `VALID`; all supported-value malformations fail closed.
- **Forged negatives:** a foreign destructor, activation at Construct rather
  than Materialize, a missing record, a foreign Construct, a mismatched Cleanup
  type, and a partial reference-object disguise all fail before publication.
- **Regression found by the complete owner gate:** the first complete
  SemaAuthority run was **545/547**, failing the `for (; Object; )` conversion
  and unbraced-loop safe-point tests. The new hook had treated the legal empty
  initialization statement before the first `;` as an invalid full
  expression. The root-cause repair invokes the hook only when the expression
  ID is valid; both exact regressions then passed **1/1**.
- **Second complete-owner regression:** review hardening initially made
  SemaAuthority **566/567** because the exact source `class C { } ... C();`
  shape is a `REFERENCE_OBJECT + HANDLE + AUTO_HANDLE`, not a value-object
  `DESTROY_VALUE` family. The final predicate excludes only a fully coherent
  reference-object constructor temporary; any partial disguise stays
  `MALFORMED`. The class source test additionally proves no
  `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record is published.
- **Final GREEN:** build PASS, Frontend Verifier **80/80**, complete
  SemaAuthority **567/567**, ProductionCodeGen temporary execution **1/1**
  with direct Canonical publisher and zero LEGACY invocations, and AST Body
  Sidecar **27/27**. Final independent review found no Critical or Important
  issue and returned **Ready to commit**.
- **Boundary:** multiple temporaries, call-result/conditional/Return
  full-expressions, lifetime extension, non-POD deferred/inout, aliases,
  globals, delegating construction, suspend and runtime Bytecode/TypedASTJIT
  consumption remain open. This entry does not close 5.7, 5.8, 7.5 or 9.5.

The permanent compound-assignment disposition is unchanged by CTA-S182:
exactly four resolved `+=` defects remain recorded, and `Tail += 100` remains
**REDUCED / NOT REPRODUCIBLE**, not a fifth defect.

## CTA-S183 direct temporary Bytecode boundary — 2026-09-02 04:20 CST

- **Status:** **SLICE CLOSED / COMMITTED** at plugin commit `0816dd4` under
  Tasks 5.7, 5.8, 9.5 and 13.6. None of those broad umbrella rows is closed by
  this one consumer.
- **Semantic defect:** CTA-S182 already authored and sealed the exact direct
  expression-statement temporary record and full-expression exit plan, but
  Canonical Bytecode evaluated `FTracked(7);` without consuming that plan. The
  materialized object was therefore destroyed only by generic function-
  epilogue cleanup, after the following Return had already read the global
  destruction trace.
- **Authentic RED:** after the retained snapshot, lifetime-view and exact-plan
  assertions passed, `Entry()` returned `0` instead of `7` at
  `Saved/Tests/cta-s183-direct-temp-codegen-semantic-red/`
  `20260902_040948_183_ffc4b446`. This isolates a production-consumer timing
  bug rather than a missing Sema fact or a test-retention setup problem.
- **Repair:** `EmitStmt(ExprStmt)` consumes only its authenticated
  `FULL_EXPRESSION` plan after expression evaluation. The temporary cleanup
  route resolves the record's Materialize ExprId through the existing
  backend-local materialized-slot map, verifies the exact value-object type and
  exact destructor Runtime owner, emits the destructor call, marks the slot
  `UNINIT`, and retires it from generic epilogue cleanup. No Cleanup literal,
  destructor-name scan, dump text or `beh.destruct` action selection is used.
- **Behavior oracle:** `Entry()` returns `7`, proving destruction before the
  following Return reads the trace; the post-execution global remains `7`,
  proving no second epilogue destruction (`77`). Publisher provenance is
  Canonical and the LEGACY invocation count is zero.
- **GREEN evidence:** build PASS at
  `Saved/Build/cta-s183-direct-temp-codegen-green/`
  `20260902_041145_634_87fe466a`; focused **1/1 PASS** at
  `Saved/Tests/cta-s183-direct-temp-codegen-green/`
  `20260902_041203_747_21ba57b3`; complete ProductionCodeGen **235/235 PASS**
  at `Saved/Tests/cta-s183-production-owner/`
  `20260902_041245_215_3023a927`; AST Body Sidecar **27/27 PASS** at
  `Saved/Tests/cta-s183-sidecar-regression/`
  `20260902_041831_991_3b5f70e1`. All recorded GREEN summaries have zero
  failures/skips. The unchanged semantic/proof owners also pass:
  SemaAuthority **567/567** at
  `Saved/Tests/cta-s183-sema-regression/`
  `20260902_041910_961_d98a4de2`, and Frontend Verifier **80/80** at
  `Saved/Tests/cta-s183-verifier-regression/`
  `20260902_042045_841_93a07ffa`.
- **Independent review:** no Critical or Important issue was found. It
  specifically confirmed exact plan placement, ExprId-to-slot identity,
  destructor ABI/owner checks, `UNINIT + live=false` double-destroy prevention,
  separation from transfer cleanup, and the behavioral strength of the
  `7`/not-`77` oracle.
- **Open boundary:** multiple/call/conditional/Return temporaries, lifetime
  extension, returned-result ownership, exception/abort/suspend execution and
  TypedASTJIT native cleanup are not claimed. Cache V2/V12 restore redesign
  remains deferred and non-gating; AST Body Sidecar remains in scope.

The permanent compound-assignment disposition is unchanged by CTA-S183:
exactly four resolved `+=` defects remain recorded, and `Tail += 100` remains
**REDUCED / NOT REPRODUCIBLE**, not a fifth defect.

## CTA-S184 pre-implementation audit: typed full-expression summary and scalar Return — 2026-09-02 04:32 CST

- **Status:** **OPEN / AUDITED / NO PRODUCTION CLAIM**. This entry records two
  concrete follow-on gaps discovered after CTA-S183. It does not reopen the
  direct ExprStmt Bytecode slice and does not promote any task checkbox.
- **TypedASTJIT gap:** the legal CTA-S182/CTA-S183
  `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record cannot currently become
  an authenticated typed lifetime summary. The typed flag model has no
  `FullExpression` bit, and summary construction has no stable ABI-identity
  route for a `SUBJECT_TEMPORARY` backed by a sealed
  `MATERIALIZE_TEMPORARY` ExprId. Eligibility therefore reports an unverified
  `InvalidCleanupPlan` instead of the required precise `UnsupportedLifetime`
  fallback for the missing native object-frame ABI.
- **Provider diagnostics contract:** the installed provider manifest accepts
  lifetime exit-plan flags only through `0x07`. Supporting the new diagnostic
  bit requires `0x0f` plus a diagnostics schema revision from 2 to 3 so old
  catalogs fail closed. The Provider entry structure/layout does not change
  solely for this typed diagnostic flag, so this is not evidence for an entry
  ABI revision bump. The stable lifetime key already covers plan kind/order;
  the typed ABI key must also cover the new exit-plan flags/count requirement
  so distinct cleanup-plan families cannot share one semantic ABI identity.
- **Scalar Return gap:** source
  `return FTracked().Value + 1;` already seals a getter receiver containing
  `Cleanup -> MaterializeTemporary -> Construct`, but Return does not call
  `ActOnFinishFullExpression`, and the current lifetime classifier/verifier
  admits only ExprStmt ownership. No exact
  `semanticRegion=ReturnStmt / phase=FULL_EXPRESSION` record or exit plan is
  authored for the intermediate temporary. Existing lifetime protocol
  revision 1 and its current subject/action/phase vocabulary are sufficient;
  this bounded family does not require a protocol revision bump.
- **Required Bytecode ordering:** evaluate the Return expression; capture the
  scalar return value; consume the authenticated Return full-expression plan;
  then consume lexical TRANSFER cleanup; then jump. The backend must not infer
  the destructor from a Cleanup literal, object type or spelling.
- **Behavior oracle:** a local `FTracked(1)` plus returned intermediate
  `FTracked(7).Value + 1` must return `8` and leave trace `71`. This
  distinguishes temporary full-expression cleanup from lexical transfer
  cleanup; `17` exposes the current epilogue/transfer ordering defect and a
  repeated digit exposes double destruction.
- **Non-claims:** multiple, conditional and call-result temporaries, lifetime
  extension, returned-value ownership/RVO, exceptions/abort/suspend and native
  TypedASTJIT object-frame execution remain separate open families.
- **Ownership:** this audit advances the evidence for Tasks 5.7, 5.8, 7.5,
  9.5 and 13.6 but closes none of them. The next work must begin with source
  Sema/verifier and typed-summary RED tests before production lowering.
- **Detailed current assessment:**
  `reviews/current-overall-progress-2026-09-02-0432.md`.

The permanent compound-assignment disposition remains unchanged by this
audit: exactly four resolved `+=` defects are recorded; `Tail += 100` remains
**REDUCED / NOT REPRODUCIBLE**, not a fifth defect. Cache V2/V12 product restore
redesign remains deferred and non-gating; the default-disabled boundary and
AST Body Sidecar remain in scope.

## CTA-S184a typed full-expression summary implementation — 2026-09-02 05:01 CST

- **Status:** **CODE-FIXED / VALIDATION OPEN; TASK 15.8 REOPENED**. The source-authentic
  TypedASTJIT summary and installed-provider diagnostic firewall are green,
  but generated-provider regeneration and the complete owning matrix are
  blocked. The historical claim that every non-empty plan had a precise typed
  fallback is disproven until this gate closes.
- **Authentic source RED:** the real CANONICAL source fixture already proved
  the exact Sema-authored TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION record
  and plan, then failed because TypedASTJIT could not authenticate it as
  ScriptDestructor. Evidence: **0/1 expected FAIL** at
  Saved/Tests/cta-s184a-source-typed-red2/
  20260902_044639_481_314d263b.
- **Typed implementation:** Canonical FULL_EXPRESSION maps to typed exit-plan
  flag 0x08; temporary identity is authenticated through the exact
  MaterializeTemporary expression, materialized value-object type, destructor
  declaration and owner class, activation, ExprStmt region and
  NORMAL-plus-EXCEPTION routes. The Typed lifetime ABI hash domain is v3 and
  now includes exit-plan flags and count. Eligibility reports the precise
  UnsupportedLifetime fallback for the unavailable native object-frame ABI.
- **Provider firewall REDs:** schema/flag support failed at
  Saved/Tests/cta-s184a-provider-diagnostic-red/
  20260902_044714_216_96a7eeae; after the basic schema stage, a forged release
  action still passed and produced a second authentic **0/1 expected FAIL** at
  Saved/Tests/cta-s184a-provider-crossfield-red/
  20260902_045324_011_748fb198.
- **Provider implementation:** diagnostic schema and digest domain advance
  from v2 to v3; defined exit-plan mask becomes 0x0f; old schema, unknown bit
  0x10, empty record/plan, release-action, missing route and false
  native-frame claims fail closed. Provider execution-entry ABI revision and
  generated manifest schema remain unchanged because no execution-entry
  layout changed.
- **Focused GREEN:** build PASS at
  Saved/Build/cta-s184a-typed-full-expression-green-build/
  20260902_045533_832_733384fd; source summary **1/1 PASS** at
  Saved/Tests/cta-s184a-source-typed-green/
  20260902_045612_706_394644b3; installed-provider diagnostic and forgery
  matrix **1/1 PASS** at
  Saved/Tests/cta-s184a-provider-diagnostic-green/
  20260902_045646_986_362473b2.
- **New integration blocker:** RunStaticJITTests.ps1 -Mode Generate passed its
  baseline build, then function-fact capture skipped ASStaticJITAotFixture.
  ObjectLifetimeEntryForAOT used one stable class-graph dependency absent from
  its declared dependency set. The batch was Candidates=7, Captured=6,
  Skipped=1; the later provider probe consequently could not find
  SemanticScalarBranch in the 28 generated functions. Evidence:
  Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/
  20260902_045819_781_2d6bddbd.
- **Disposition:** keep the stable-dependency firewall and provider probe
  strict. Diagnose the missing dependency or capture granularity, regenerate
  the committed provider through the standard script, build generated source,
  run Verify and owner prefixes, and only then restore Task 15.8 and close and
  commit CTA-S184a.
- **Detailed progress snapshot:**
  reviews/current-overall-progress-2026-09-02-0501.md.

The permanent compound-assignment disposition is unchanged by CTA-S184a:
exactly four resolved `+=` defects are recorded. `Tail += 100` remains
**REDUCED / NOT REPRODUCIBLE**, not a fifth defect. Cache V2/V12 product restore
redesign remains deferred and non-gating; the Cache default-disabled boundary
and AST Body Sidecar remain in scope.

### Durable current dispositions

- compound-assignment issue count: **4**;
- closed issue identities: CTA-S146, CTA-S157, CTA-S177-ORDER and
  CTA-S177-SCALAR-REF-SNAPSHOT;
- owning completed rows: Tasks 5.3 and 5.4;
- Tail probe final identity: CTA-S179-TAIL-DECLID-STRENGTHENED;
- Tail probe status: **REDUCED / NOT REPRODUCIBLE**;
- Tail is a fifth compound-assignment defect: **false**;
- Task 9.2 reopened by Tail: **false**;
- Task 9.6 activated by Tail: **false**;
- Task 15.8 current status: **REOPENED / CTA-S184a VALIDATION OPEN**;
- Tail final evidence:
  Saved/Tests/cta-s179-tail-declid-strengthened/
  20260902_011308_781_6e3217c8;
- Cache V2 product restore redesign: **DEFERRED / NON-GATING**;
- Cache V2 product default: **DISABLED**;
- Cache default-disabled lifecycle boundary: **IN SCOPE / FINAL GATE**;
- AST Body Sidecar: **IN SCOPE**;
- opt-in restore prototype: **RETAINED / NON-BLOCKING**;
- Cache product-restore scope may be reopened only by explicit user direction,
  preferably through a dedicated future OpenSpec.

## CTA-S184a-DEP Complete-composition dependency oracle — 2026-09-02 05:30 CST

- **Status:** **OPEN / AUTHENTIC RED / EXISTING CTA-S184a GENERATION BLOCKER
  REFINED / PRODUCTION FIX NOT YET APPLIED**. This is the exact identity of the
  05:01 Generate blocker, not a second blocker count.
- **Prior coarse symptom:** StaticJIT Generate skipped the entire
  `ASStaticJITAotFixture` module after function-fact capture rejected
  `UStaticJITAotFunctionCarrier::ObjectLifetimeEntryForAOT`; the later
  provider probe then could not find the independent `SemanticScalarBranch`
  output.
- **Core control:** the existing
  `LargeFixtureBuildsVerifiedFactsWithoutCacheRecords` test remains
  **1/1 PASS** at
  `Saved/Tests/cta-s184a-generation-facts-root-red/`
  `20260902_052136_692_f1d71890`. The defect is therefore not a universal
  function-artifact failure.
- **New exact oracle:** the real Complete seven-module fixture now writes and
  validates the actual class-method function artifact, enumerates its
  `FUNCTION_SIGNATURE` uses and requires a pointer-exact
  `SIGNATURE/FUNCTION` compiler dependency for each use. The test source is
  `Source/AngelscriptTest/StaticJIT/AOT/Generation/`
  `AngelscriptStaticJITAotGenerationSnapshotTests.cpp`, method
  `CompleteFixtureFunctionRelocationsHaveDeclaredDependencies`.
- **Exact RED:** build PASS at
  `Saved/Build/cta-s184a-complete-fixture-dependency-red-build/`
  `20260902_052346_566_c7fd05fd`; test **0/1 expected FAIL** at
  `Saved/Tests/cta-s184a-complete-fixture-dependency-red/`
  `20260902_052413_511_370e5778`.
- **Exact missing dependency:** function artifact use 3 is
  `FString(const FString&inout)`, owner `FString`, stable key
  `5dd2e37454d592763ad2d32ca5788dc8ad3b050821c766703d27811006302af6`.
  The artifact carries the copy-constructor relocation, but the compiled
  function's dependency table lacks the exact compiler dependency.
- **Leading root cause:** `EmitCopyConstructValue` resolves the copy
  constructor and emits a `CALL/CALLSYS`, but unlike existing destructor and
  ordinary resolved-call paths does not currently mark that exact copy
  constructor through `builder->MarkDependency`. This is localized evidence,
  not yet a completed production fix.
- **Independent containment finding:** function-fact capture currently
  promotes only after all functions succeed, so one function error skips its
  whole module even though Provider routing is per-function. Treat
  per-function fail-closed isolation and dependent-caller closure as a
  separate follow-on. Do not weaken the exact-dependency firewall or hide the
  missing copy-constructor edge behind partial publication.
- **Ownership:** this blocker prevents generated-provider publication and
  therefore keeps CTA-S184a validation open and Task 15.8 unchecked. It also
  supplies evidence toward Tasks 9.1, 9.6 and 13.6 but closes none of them.
- **Detailed review:**
  `reviews/current-overall-progress-2026-09-02-0530.md`.

The permanent compound-assignment disposition is unchanged: exactly four
resolved `+=` defects remain recorded; `Tail += 100` remains **REDUCED / NOT
REPRODUCIBLE**, not a fifth defect. The `FString` copy-constructor dependency
failure is a separate generation-integrity defect and must not be merged into
the `+=` family.

## CTA-S184a-ISOLATION function-fact containment — 2026-09-02 05:30 CST

- **Status:** **OPEN / SEPARATE FOLLOW-ON / NOT A SUBSTITUTE FOR DEPENDENCY
  CORRECTNESS**.
- **Symptom:** one invalid function currently causes facts-only capture to
  skip its whole module, while final Provider eligibility and routing are
  already per-function. In the current Generate failure this evicts the
  independent `SemanticScalarBranch` together with the invalid
  `ObjectLifetimeEntryForAOT` function.
- **Required closure:** after CTA-S184a-DEP is fixed, add an independent RED
  proving that one fail-closed function does not evict unrelated functions,
  while direct and transitive dependent callers remain excluded. Retain
  module-wide rejection for failures that prevent module authority or
  preflight from being established.
- **Non-claim:** this item cannot weaken exact dependency authentication,
  publish partial facts for the invalid function, or make the missing
  `FString` copy-constructor edge acceptable.
- **Owner:** generation-integrity evidence for Tasks 9.1, 9.6 and 13.6; it
  closes none of them yet.

## CTA-S184a-DEP closure and fallback precedence follow-up — 2026-09-02 05:46 CST

- **CTA-S184a-DEP status:** **CLOSED / AUTHENTIC RED→GREEN**. Production
  `EmitCopyConstructValue` now publishes the exact selected copy constructor
  through `builder->MarkDependency(copyCtor, 0, 0)` before emitting its
  `CALL/CALLSYS` relocation. This preserves the exact dependency firewall.
- **Fresh official GREEN:** build PASS at
  `Saved/Build/cta-s184a-copy-dependency-green-build/`
  `20260902_053752_176_c55b0d1b`; exact Complete oracle **1/1 PASS** at
  `Saved/Tests/cta-s184a-copy-dependency-green/`
  `20260902_053809_351_b150797a`; full GenerationFacts **2/2 PASS** at
  `Saved/Tests/cta-s184a-generation-facts-green/`
  `20260902_053858_951_ff908399`.
- **Commandlet confirmation:** the next official StaticJIT Generate retained
  `Candidates=7 Captured=7 Skipped=0` across the observed Complete
  compositions. The old missing-copy-constructor dependency did not recur.
- **New independent blocker:** Generate later failed because the isolated
  non-final `ObjectLifetimeEntryForAOT` fixture still requires
  `UnsupportedFunctionTrait`, while the frozen entry-plan precheck now reports
  `UnsupportedSignature: StaticJITEntryPlanTypedReceiverUnsupported` before
  function-trait classification. Bytecode fallback remained emitted. Evidence:
  `Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/`
  `20260902_053952_303_3a8f460a/Commandlet.log`.
- **Independent-review disposition:** this is a stale exact-reason
  expectation, not a production lowering regression, not a reopened
  CTA-S184a-DEP and not a `+=` defect. The frozen receiver gate is authoritative
  and predates this worktree; synchronize the exact expectation to
  `UnsupportedSignature: StaticJITEntryPlanTypedReceiverUnsupported`, without
  accepting arbitrary categories, then rerun Generate, generated-source build,
  Verify and owner prefixes. The legacy `NonCloneableEffectRejected` label
  reaches the receiver gate before lifetime analysis and therefore cannot be
  counted as CTA-S184a full-expression evidence. Task 15.8 remains unchecked
  until the separate authentic lifetime summary/transport proof and the whole
  publication chain are green.
- **Detailed current assessment:**
  `reviews/current-overall-progress-2026-09-02-0546.md`.

The permanent compound-assignment ledger is unchanged: exactly four resolved
`+=` defects; `Tail += 100` is **REDUCED / NOT REPRODUCIBLE**, not a fifth.
CTA-S184a-ISOLATION remains a separate follow-on even though its original
natural reproducer disappeared after the exact dependency fix.

## CTA-S184a owner-gate findings — 2026-09-02 06:20 CST

- **Publication-chain status:** baseline build, Generate, generated-source
  build and Verify are **GREEN** in the official StaticJIT Mode All run.
  Generate remains deterministic and keeps `Candidates=7 Captured=7
  Skipped=0`. The final owner prefix is **RED / CRASH-ABORTED**, so Task 15.8
  remains open.
- **CTA-S184a-DIAG-SCHEMA:** **OPEN / STALE TEST EXPECTATION / LOW**.
  `InstalledProviderGenerationDiagnosticsAppearInStableCommandJson` still
  requires diagnostic schema revision 1 while the authenticated
  full-expression grammar correctly publishes revision 3. Synchronize the
  exact assertion; do not weaken it to accept arbitrary revisions.
- **CTA-S184a-DIFF-ORACLE:** **OPEN / RECURRING ORACLE AUTHENTICITY BLOCKER /
  HIGH**. The first Bytecode Raw comparison observes 1 versus 61. Generated
  code and independent production-case inspection support 61, so the leading
  root scope is the alleged fresh-interpreter session/profile/argument/route
  guarantee, not a proven generated Raw arithmetic regression. The same
  result existed in 2026-08-28 `cta-s53-15-8-verify_02_tests`, while older
  owner runs sometimes passed. Instrument and authenticate the oracle before
  assigning backend blame.
- **CTA-S184a-REF-INDIRECT-AV:** **OPEN / AUTHENTIC GENERATED-CODE DEFECT /
  CRITICAL**. `ObjectLifetimeEntryForAOT` loads a string address into
  `v_TEMP_11`, then emits
  `new (Object) FString((*(FString*)((&v_TEMP_11))))` and crashes at generated
  line 2182. The root scope is BytecodeJIT indirect-reference system-call
  argument lowering, where the address of the pointer slot is confused with
  its pointed value. The copy-constructor dependency and literal reference
  slots are present, so CTA-S184a-DEP stays closed.
- **Owner evidence:** 405 tests discovered; 39 Success and three Fail
  completion events; the next test crashed with
  `EXCEPTION_ACCESS_VIOLATION`; 362 tests did not complete. Evidence:
  `Saved/Tests/staticjit-testjit_05_tests/`
  `20260902_061127_197_1776782f`.
- **Cache disposition:** the observed opt-in Cache V2 restore failure remains
  **DEFERRED / NON-GATING** for the production restore redesign. The
  default-disabled lifecycle boundary remains an in-scope final gate, and AST
  Body Sidecar remains in scope.
- **Detailed review:**
  `reviews/current-overall-progress-2026-09-02-0620.md`.

The permanent compound-assignment disposition remains exactly four resolved
`+=` defects: CTA-S146, CTA-S157, CTA-S177-ORDER and
CTA-S177-SCALAR-REF-SNAPSHOT. `Tail += 100` remains **REDUCED / NOT
REPRODUCIBLE**, not a fifth defect. None of the owner-gate findings is a
compound-assignment issue.

## CTA-S184a main-checkpoint disposition — 2026-09-02 10:30 CST

- **CTA-S184a-DIAG-SCHEMA:** **CLOSED / FOCUSED PASS**. The assertion now
  consumes the Runtime ABI authority instead of hard-coding revision 1, and
  `InstalledProviderGenerationDiagnosticsAppearInStableCommandJson` passes in
  the focused two-test run.
- **CTA-S184a-REF-INDIRECT-AV:** **ROOT FIX IMPLEMENTED / PRODUCTION GATE
  GREEN / STATICJIT OWNER RECHECK OPEN**. Canonical Bytecode CodeGen now
  distinguishes pointer-storing expression results and emits `PshVPtr` for
  the source of the string-literal copy. The focused production regression is
  RED-to-GREEN and the complete ProductionCodeGen class passes **183/183**.
  Regenerated TestJIT source contains the corrected operand, but the generated
  DLL and the original owner crash case were not rebuilt/re-executed after the
  final regeneration; do not call the owner crash closed yet.
- **CTA-S184a-DIFF-ORACLE:** **OPEN / FOCUSED FAIL**. The focused rerun still
  reports 1 versus 61. The generated arithmetic supports 61, so the current
  leading scope remains interpreter-session/profile/route authenticity.
- **Cache V2:** the opt-in restore failure remains **DEFERRED / NON-GATING**.
- **Integration disposition:** merge the work as an unfinished checkpoint
  while the product default remains LEGACY. Task 15.8 stays unchecked, the
  OpenSpec stays active, and no complete StaticJIT owner result is claimed.

Focused evidence:

- `Saved/Tests/cta-production-codegen-after-source-provenance/`
  `20260902_101101_144_4769f5cd`
- `Saved/Tests/cta-staticjit-schema-and-route-targeted/`
  `20260902_102557_378_f2392580`
- `Saved/Build/cta-targeted-staticjit-fixes/`
  `20260902_102526_057_b8538f28`
