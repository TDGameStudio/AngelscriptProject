# Canonical overloaded assignment call rewrite (CTA-S139)

Date: 2026-09-01

## Scope

Starts the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed call rewrite and must not rerun
`asCCompiler`. Clang publishes overloaded `=` as a call
(`CXXOperatorCallExpr`) with receiver, callee, and argument plan. Canonical
Sema currently ranks `opAssign` onto a leftover `Assign` node; CodeGen then
reinterprets that Assign as a native reference `opAssign` ABI instead of
emitting a Call.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Object = 7` rewrites to `T::opAssign(int)` Call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      T& opAssign(int Value)
      {
          Stored = Value;
          return this;
      }
  }

  int Entry()
  {
      T Object;
      Object = 7;
      return Object.Stored;
  }
  ```
- **Canonical facts:**
  1. Entry's assignment expression is `asAST_EXPR_CALL` of
     `T::opAssign(int)`, not leftover `Assign`.
  2. The Call seals `receiver=` of `Object`.
  3. VALUE-owner method dispatch is `DIRECT`.
  4. One positional `Value` formal is recorded.
  5. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  6. `Entry() == 7` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalOverloadedAssignRewritesToOpAssignCallWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalOverloadedAssignExecutesOpAssignCallWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opassign-red` `20260901_044409_422_f7649271`
  **0/1 FAIL**. Canonical CodeGen `emitterLine=7950`: leftover Assign converted
  `int→T` instead of ranking `T::opAssign(int)` on the authored rhs.
- **AST-green:** `cta-sema-call-53-opassign-green` `20260901_044831_226_a8999e8b`
  **1/1 PASS** after `ActOnAssignExpr` rewrites non-generated, non-external
  `opAssign` to a Call before `ActOnAssign` converts the rhs. Final focused
  confirmation `cta-sema-call-53-opassign-final` `20260901_050158_011_306275f6`
  **1/1**.
- **CodeGen/provenance:** `cta-sema-call-53-opassign-codegen-green`
  `20260901_044908_780_52a088ab` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 7`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **495/495** `cta-ast-first-sema`
  `20260901_045210_282_d29fb05b`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_045506_464_ff4efe8b`. ProductionCodeGen
  prefix **188/198** `cta-ast-first-prodcodegen` `20260901_045545_714_7f92d78d`
  — ten remaining failures are array/native/import/namespace/print families,
  not this `opAssign` card.
- **Remaining boundary:** 5.3 stays `[ ]` (array/native/import call families
  and product-default LEGACY still rerun `asCCompiler`). Does not check
  5.4–5.9, 13.2, or section 10. Product default stays LEGACY.
