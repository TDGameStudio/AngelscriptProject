# Canonical bitwise-or call rewrite (CTA-S150)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed operator-call rewrite and must not
rerun `asCCompiler`. `OperatorMethodNameFromText` mapped `+`/`-`/`*`/`/`/`%`
and comparisons, but not `|`/`&`/`^`/`**`/`<<`/`>>`/`>>>`. `Object | 2`
therefore sealed leftover `Binary |` of `T` and `int` even though
`T::opOr(int) const` existed. The lhs operator rewrite also called `ActOnCall`
without `ArrangeCallArguments`, so the first GREEN dump still used
`origin=generated` instead of a positional `Value` formal.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Object | 2` rewrites to `T::opOr(int) const` Call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      int opOr(int Value) const
      {
          return Stored | Value;
      }
  }

  int Entry()
  {
      T Object;
      Object.Stored = 8;
      return Object | 2;
  }
  ```
- **Canonical facts:**
  1. Entry's return expression is `asAST_EXPR_CALL` of
     `T::opOr(int) const`, not leftover `Binary |`.
  2. The Call seals `receiver=` of `Object`.
  3. VALUE-owner method dispatch is `DIRECT`.
  4. One positional `Value` formal records the rhs `2`.
  5. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  6. `Entry() == 10` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalBitwiseOrRewritesToOpOrCallWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalBitwiseOrExecutesOpOrCallWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opor-red` `20260901_074121_683_f900e2ed`
  **0/1 FAIL**. Build succeeded. Dump: `EXPR 20 Binary type=int literal=|`;
  `T::opOr(int) const` was DECL 4 and unused. Assertion: "Object | 2 must
  rewrite to a Call of T::opOr(int) const, not leftover Binary."
- **AST-green:** `cta-sema-call-53-opor-green` `20260901_074413_088_481e69bc`
  **1/1 PASS**. First mapping-only GREEN still had `origin=generated`.
  `ActOnBinaryExpr` now ranks lhs operators through
  `TryRewriteOverloadedBinaryToCall` so `ArrangeCallArguments` seals
  positional formals. `OperatorMethodNameFromText` also maps `**`/`|`/`&`/`^`
  /`<<`/`>>`/`>>>` to `opPow`/`opOr`/`opAnd`/`opXor`/`opShl`/`opShr`/`opUShr`.
  Reverse `_r` still applies except for `opEquals`/`opCmp`. Primitive
  `int | int` stays Binary.
- **CodeGen/provenance:** `cta-sema-call-53-opor-codegen-green`
  `20260901_074448_248_e5e97866` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 10`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **491/491** `cta-ast-first-sema`
  `20260901_074526_489_4a5323f0`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_074654_691_afee2967`, ProductionCodeGen
  **154/154** `cta-ast-first-prodcodegen` `20260901_074737_090_fc9a97e9`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
