# Canonical overloaded compound-assignment call rewrite (CTA-S146)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed call rewrite and must not rerun
`asCCompiler`. Clang publishes overloaded `+=` as a call
(`CXXOperatorCallExpr`) with receiver, callee, and argument plan. CTA-S139
rewrote authored `=` to `opAssign`. Compound `+=` still ranked leftover
`Assign` and converted `int→T`; CodeGen then failed closed instead of
emitting a Call of `opAddAssign`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Object += 7` rewrites to `T::opAddAssign(int)` Call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      T& opAddAssign(int Value)
      {
          Stored = Stored + Value;
          return this;
      }
  }

  int Entry()
  {
      T Object;
      Object += 7;
      return Object.Stored;
  }
  ```
- **Canonical facts:**
  1. Entry's compound assignment is `asAST_EXPR_CALL` of
     `T::opAddAssign(int)`, not leftover `Assign` with literal `+=`.
  2. The Call seals `receiver=` of `Object`.
  3. VALUE-owner method dispatch is `DIRECT`.
  4. One positional `Value` formal is recorded.
  5. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  6. `Entry() == 7` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalOverloadedCompoundAssignRewritesToOpAddAssignCallWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalOverloadedCompoundAssignExecutesOpAddAssignCallWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opaddassign-red` `20260901_065144_030_88903aed`
  **0/1 FAIL**. Canonical CodeGen `code=-7 line=7971`: leftover Assign converted
  `int→T` (`srcType=int dstType=T`) instead of ranking `T::opAddAssign(int)`
  on the authored rhs.
- **AST-green:** `cta-sema-call-53-opaddassign-green` `20260901_065353_197_2890de06`
  **1/1 PASS** after `ActOnAssignExpr` rewrites non-generated, non-external
  compound operators (`+=` → `opAddAssign`, and the sibling `-=`/`*=`/… map)
  to a Call before `ActOnAssign` converts the rhs. Primitive `int += 1`
  still stays Assign because primitive/enum/void owners are skipped.
- **CodeGen/provenance:** `cta-sema-call-53-opaddassign-codegen-green`
  `20260901_065429_154_8c9af873` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 7`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **487/487** `cta-ast-first-sema`
  `20260901_065509_444_0da33b85`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_065641_158_b24dad4e`, ProductionCodeGen
  **150/150** `cta-ast-first-prodcodegen` `20260901_065719_788_4cbc3ae5`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
