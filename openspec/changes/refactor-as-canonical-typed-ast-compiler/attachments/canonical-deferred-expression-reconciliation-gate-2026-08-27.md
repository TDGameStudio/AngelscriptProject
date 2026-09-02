# Canonical deferred-expression reconciliation gate

Worktree: `D:\as-cta`

Status: bounded deferred primitive-binary parent reconciliation GREEN; broader
expression/action-only Sema umbrellas remain open.

Issue: CTA-S-06.

Related OpenSpec tasks: `4.3`, `5.3`, `5.4`, `5.6`, `13.2`.

## Source fixtures

Deferred qualified call:

```angelscript
double EntryCall()
{
	return Later::Target() + 1;
}

namespace Later
{
	double Target() { return 41.0; }
}
```

Deferred qualified global reference:

```angelscript
double EntryRef()
{
	return Later::Value + 1;
}

namespace Later
{
	double Value = 41.0;
}
```

## Required sealed semantic facts

1. Deferred exact-name reconciliation is not complete when only the child
   `CallExpr` or `DeclRefExpr` receives a valid declaration and type. Every
   reachable parent whose semantic result depended on the recovery ERROR type
   must be recomputed before sealing.
2. In both fixtures the reachable `+` expression has primitive `double` type
   and both operands are explicitly double after integer promotion. It must
   not retain the provisional `int` result chosen while the left child was
   ERROR-typed.
3. Reconciliation preserves the exact `Later` qualifier, removes only the
   matching recovery diagnostic and does not reparse source or retain
   `asCScriptNode` as durable semantic state.
4. Production Canonical CodeGen consumes the reconciled sealed AST, publishes
   with zero legacy compiler invocations and executes `EntryCall()` and
   `EntryRef()` as `42.0`.
5. If a dependent expression family cannot be recomputed safely, the build
   must fail closed before publication rather than lowering stale semantic
   facts.

## TDD sequence

- [x] AST RED: deferred call child resolves but its reachable `+` parent
      remains a stale non-double result or otherwise fails semantic closure.
- [x] AST RED: deferred DeclRef child resolves but its reachable `+` parent
      remains a stale non-double result or otherwise fails semantic closure.
- [x] AST GREEN: both sealed parents and operands carry the correct primitive
      double facts with no diagnostics.
- [x] Production GREEN: both functions build through Canonical CodeGen and
      execute as `42.0`, with no legacy compiler invocation.
- [x] Focused regression GREEN: complete SemaAuthority and ProductionCodeGen
      groups pass.

## RED and root cause

The combined focused run produced the intended **2/4 PASS** RED. In both
failures the deferred child was already exact and `double`, diagnostics were
empty, and sealing succeeded, but the AST still contained:

```text
Call/DeclRef type=double
Binary literal=+ type=int
Conversion dest=double src=int
```

The existing reconciliation updated only the deferred child plus provisional
ERROR lifetime wrappers. `ActOnBinaryExpr` had already selected its fallback
`int` while the left operand was ERROR-typed; no later pass revisited that
dependent semantic decision. The outer function-return conversion therefore
also retained a stale `int -> double` plan.

## Repair

The final deferred pass is now named `ResolveDeferredNames`, reflecting that it
handles both calls and `DeclRef`s. After exact child resolution it performs an
AST-only fixed-point recomputation for built-in primitive binary parents:

- typedef value types are resolved from canonical type facts;
- the common integer/float type is recomputed with the same promotion rules as
  ordinary Sema;
- missing operand conversions are materialized explicitly;
- arithmetic/comparison result types are replaced in place;
- exact no-op conversion wrappers whose child is the recomputed binary are
  disconnected from reachable ownership edges.

The pass does not read or retain `asCScriptNode`. The strengthened final
fixture uses `double + int`, so it proves both parent retyping and explicit RHS
promotion rather than only a coincidentally same-typed double addition.

The first implementation build failed because the recomputation helper was
placed before the existing primitive-classification helper definitions without
forward declarations. This was a compile-order defect only; explicit local
prototypes were added and the next supported-runner build passed. The failed
build is retained below rather than hidden.

## Evidence

- test-only build: PASS at
  `Saved/Build/cta-deferred-parent-test-build/20260827_080055_787_7cefdbd7/RunMetadata.json`;
- combined AST RED: **2/4 PASS** at
  `Saved/Tests/cta-deferred-parent-sema-red/20260827_080120_872_e3a18dc6/Report/index.json`;
- first repair build, compile-order failure: FAIL at
  `Saved/Build/cta-deferred-parent-fix-build/20260827_080343_636_64e6ec24/RunMetadata.json`;
- corrected repair build: PASS at
  `Saved/Build/cta-deferred-parent-fix-build2/20260827_080421_618_04bef917/RunMetadata.json`;
- initial same-typed focused AST and production GREENS: **4/4 PASS** and
  **1/1 PASS** at
  `Saved/Tests/cta-deferred-parent-sema-green/20260827_080434_792_9a93f86e/Report/index.json` and
  `Saved/Tests/cta-deferred-parent-production-green/20260827_080508_803_c7688b52/Report/index.json`;
- strengthened promotion-fixture build: PASS at
  `Saved/Build/cta-deferred-parent-promotion-test-build/20260827_080626_248_e520ce14/RunMetadata.json`;
- strengthened focused AST and production GREENS: **4/4 PASS** and
  **1/1 PASS** at
  `Saved/Tests/cta-deferred-parent-promotion-sema-green/20260827_080643_706_53bbb761/Report/index.json` and
  `Saved/Tests/cta-deferred-parent-promotion-production-green/20260827_080718_911_046def19/Report/index.json`;
- complete SemaAuthority: **308/308 PASS** at
  `Saved/Tests/cta-deferred-parent-sema-authority-final-green/20260827_080756_012_1a1caf8a/Report/index.json`;
- complete ProductionCodeGen: **114/114 PASS** at
  `Saved/Tests/cta-deferred-parent-production-codegen-final-green/20260827_080834_139_1721b586/Report/index.json`.

## Non-claims

- This gate does not prove arbitrary object-operator, assignment, conditional,
  cast, member-access or lifetime-plan reconciliation. Those families remain
  part of the open umbrella and require their own Gate 0 fixtures before any
  completion claim.
- It does not close the action-only Parser/Sema migration, complete candidate
  matrix, or Tasks `4.3`, `5.3`, `5.4`, `5.6`, and `13.2`.
- It does not change the LEGACY compiler default or Cache V2 default-disabled
  policy.
