# Remaining open problems — 2026-09-01 (after CTA-S177 sequencing closure)

This is an inventory of leftover problems discovered on path A, not a
checkbox-percentage report. Closed cards keep their own gate attachments.
Tasks 5.3 and 5.4 are closed; do not reopen them or check 13.2 / section 10
from this inventory without their own complete gates.

Product default stays `asCOMPILER_PIPELINE_LEGACY`.

## What is already recorded

- Each CTA-S132–S177 gate attachment records its authentic RED dump or
  characterization-first result,
  GREEN publisher/legacy/execute evidence, and a remaining-boundary
  sentence.
- `tasks.md` and the closure attachments retain the locked call/sequencing
  families and their non-claims.
- Implementation traps already on those cards:
  - S157: overloaded compound-assign rewrite required `LVALUE`, so
    rvalue `Make() += 7` failed `expression-not-assignable`.
  - S160: `ActOnIfStmt` rewrite was not the production while path;
    typed finish `ActOnWhileStatementAction` wrote `action.condition`
    directly.
  - S161: same for `ActOnForStatementAction`.
  - S162: already-bool skip of `RewriteValueToBoolViaOpImplConv`
    leftover Unary `!` typed `int`.
  - S177: index compound `+=` captured a scalar-reference RHS address before
    receiver evaluation but did not read/freeze the value; receiver mutation
    changed `10` to `20`, producing `21` instead of `11` despite the expected
    call order. Both index-compound paths now decay before RHS Opaque capture.
    See `attachments/canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`.

## Record gaps this inventory closes

- `tasks.md` previously listed “Hidden/WorldContext” as locked. Only
  the **dump** is locked (CTA-S135 characterization, CodeGen/provenance
  `N/A`). Execute is not.
- The 11:16 progress delta stops at CTA-S161 and does not include
  CTA-S162 (`!bool` typed bool).
- `asCCompiler` remaining construction sites were described only as
  “backends rerun Sema”, not as concrete Builder sites.

## Path A — closed expression/call/sequencing trail

1. **WorldContext hidden-call execute is characterization-green, not a
   gap.** `WithWorld(3)` already publishes Canonical CodeGen, legacy
   count is 0, injects `__WorldContext()` once, and `Entry() == 43`
   (`cta-sema-call-53-worldcontext-exec-red`
   `20260901_113904_179_f81237a9` **1/1 PASS immediately**). Keep the
   execute lock; do not treat dump-only CTA-S135 as unfinished execute.
2. **Logical `Object && true` leftover VALUE cond is closed by
   CTA-S164.** Authentic RED dump was Logical `&&` lhs=DeclRef `T`.
   `ActOnLogicalExpr` now rewrites both operands through
   `opImplConv` (covers `||` on the same path).
3. **Staged factory / CompileFunction / global-init `asCCompiler`
   sites are closed by CTA-S165.** CANONICAL skips
   `CompileGlobalVariables` and does not construct `asCCompiler` on
   restore miss. LEGACY keeps those sites.
4. **Object functor `Object(41)` is closed by CTA-S166.** Authentic
   RED was `unresolved-callee:Object` with a local `Var` hit. Sema
   now rewrites VALUE/REFERENCE objects through `T::opCall`.
5. **Postfix `Make()(41)` is characterization-green**, not a gap.
   `cta-sema-call-53-postfix-opcall-red` `20260901_123901_784_932b974a`
   **1/1 PASS immediately** through the S166 helper.
6. **Explicit `Cast<int>(Object)` is closed by CTA-S167.** Authentic
   RED dump was leftover Conversion `dest=int src=T` with unused
   `T::opConv() const`.
7. **Implicit `return Object` is closed by CTA-S168.** Authentic RED
   dump was leftover Return DeclRef `T` with unused
   `T::opImplConv() const`. Return rewrites with
   `allowExplicitOpConv=false`.
8. **Local initialization `int Value = Object` is closed by CTA-S169.**
   Authentic RED retained a VALUE `T` DeclRef / generic Conversion on the
   local declaration initializer with unused `T::opImplConv() const`.
   `EmitTypedLocalVariableStmts` now rewrites the init with
   `allowExplicitOpConv=false` before funcdef handling.
9. **Call argument `Consume(Object)` is closed by CTA-S170.** Ranking already
   recognized `T::opImplConv() const`, but Sema left a generic Conversion and
   CodeGen failed `unsupported conversion`. Formal conversion now publishes a
   real Call with exact receiver/result before the enclosing argument record is
   sealed. This follows Clang's Sema-owned `ActOnCallExpr` / `BuildCallExpr`
   boundary and adds no CodeGen inference.
10. **The remaining-call inventory is reconciled by CTA-S171.** A wider
    SemaAuthority run exposed two stale post-S170 oracles, not production
    failures: ordinary VALUE-to-reference `opImplConv` arguments now correctly
    seal `MaterializeTemporary(Call(opImplConv))`, while the tests still
    required a generic Conversion. Exact receiver/result/formal assertions now
    lock the real Call. Converting-constructor execute, mixin omitted-default
    and method calls, direct/import named/default calls, and local funcdef
    `CallPtr` execution all pass Canonical CodeGen with zero LEGACY compiler
    invocation. The authentic task-5.3 call-family remainder is now only
    `opHndlAssign` plus reverse-operator family completeness beyond `opAdd_r`.
11. **ASHANDLE plain assignment is closed by CTA-S172.** The authentic RED
    sealed `Left = Right` as `Assign(... callee=opAssign)` even though the left
    registered type carried `asOBJ_ASHANDLE`. Sema now projects the
    pointer-free ordinary/template type fact, selects and seals an exact
    `Call(opHndlAssign)`, and allows that exact EXTERNAL native operator without
    changing ordinary `opAssign` storage handling. A second authentic RED
    proved the first implementation could fall back to `opAssign` when
    `opHndlAssign` was missing; it now emits
    `no-appropriate-opHndlAssign` and publishes no generic Assign. Production
    execution returns `42` where the hostile `opAssign` would return `-100`,
    with Canonical CodeGen publisher and zero LEGACY invocation.
12. **The complete reverse-operator family is characterization-green in
    CTA-S173.** All twelve LEGACY reverse names (`opAdd_r` through
    `opUShr_r`) seal exact rhs-receiver Calls, publish through Canonical
    CodeGen with zero LEGACY invocation, and execute to the unique sentinel
    sum `78`. Focused Sema and execution are **1/1 PASS immediately**. No
    production edit was needed.
13. **The historical `TypedSemanticIR/Call*` acceptance audit is closed.** Git
    history contains seven literal Call-path test methods. CTA-S174 closed the
    compile-out call-rewrite gap; CTA-S175 proves import bind/rebind/unbind
    changes only Runtime slot state while Canonical dump and Sidecar bytes stay
    identical. Task 5.3 is now `[x]`.
    Native ABI/bridge details remain deliberately owned by 7.4 rather than
    copied into the ABI-independent AST. See
    `reviews/task-5.3-call-oracle-closure-audit-2026-09-01.md`.
14. **Explicit sequencing/single-evaluation is closed by CTA-S177.** Property
    and index compound/prefix/postfix forms publish exact Sequence/Opaque
    phases; logical/conditional/value-temporary/generated-struct behavior is
    locked in independent LEGACY/CANONICAL Engines. The final alias RED proved
    that trace order alone was insufficient: scalar-reference RHS `+=` must
    freeze the value before receiver mutation. Final gates are Semantics
    **15/15**, SemaAuthority **538/538**, ProductionCodeGen **230/230**, and
    Frontend CanonicalAST **189/189**. Task 5.4 is now `[x]`.

## Path A umbrellas still `[ ]`

| Task | Why still open |
|------|----------------|
| 13.2 | Broader Sema environment and every remaining semantic fact; 5.3 closure alone will not close this umbrella |
| 5.5 / 5.6 | Statement/control environment; verifier control tests not fully migrated |
| 5.7 / 5.8 | Lifetime umbrellas (section 15 protocol cards are 11/11, umbrellas are not) |
| 5.9 | Containers/templates/delegates/lambdas/imports/generated lifecycle at cutover |

## Later paths (do not jump here)

- C: 9.1 / 9.5 / 9.6 / 13.6 Bytecode consume of authenticated lifetime
- D: 7.2 / 7.4 / 7.5 TypedASTJIT
- E: 13.8 snapshot protocol
- F: 10.1–10.4 / 10.6 / 10.7 / 10.9 default cutover
- G: 0.2 / 0.3 / 12.2 / 12.4 / 13.12
- 9.7 Native SDK + `Script/` differential

## Latest named-prefix checkpoint (CTA-S177)

- Semantics **15/15** `cta-s177-semantics-review-minor-final`
  `20260901_200316_367_3f9c6dc5`
- SemaAuthority **538/538** `cta-s177-semaauthority-review-final`
  `20260901_195404_651_f90409d2`
- Frontend CanonicalAST **189/189**
  `cta-s177-frontend-review-final`
  `20260901_195549_039_e733d7ab`
- ProductionCodeGen **230/230**
  `cta-s177-production-codegen-review-final`
  `20260901_195628_961_558bda16`
- Build after the final review minor: PASS
  `cta-s177-review-minor-final-build/20260901_200257_097_841d5980`
- Cache V2/V12 was intentionally not rerun; its prototype refactor/testing is
  user-deferred and is not a Task 5.4 closure gate.

Formal status is **109/136 (80.1%)** with 27 rows open. Tasks 5.3 and 5.4 are
closed; 13.2, statement/control/lifetime umbrellas, native ABI/backend
consumption, snapshot publication, cutover, LEGACY isolation and final
regression remain independently open. The immediate next row is 5.5.
