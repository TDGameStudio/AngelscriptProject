# Canonical reverse-operator call rewrite (CTA-S147)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed call rewrite and must not rerun
`asCCompiler`. AngelScript reverse operators (`opAdd_r`) live on the rhs when
the lhs has no matching `opAdd`. Clang publishes the selected operator as a
call with receiver, callee, and argument plan. Canonical Sema only ranked
`opAdd` on the lhs, so `40 + Object` sealed leftover `Binary +` of `int` and
`T` even though `T::opAdd_r(int) const` existed.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `40 + Object` rewrites to `T::opAdd_r(int) const` Call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 2;

      int opAdd_r(int Value) const
      {
          return Value + Stored;
      }
  }

  int Entry()
  {
      T Object;
      return 40 + Object;
  }
  ```
- **Canonical facts:**
  1. Entry's return expression is `asAST_EXPR_CALL` of
     `T::opAdd_r(int) const`, not leftover `Binary +`.
  2. The Call seals `receiver=` of `Object`.
  3. VALUE-owner method dispatch is `DIRECT`.
  4. One positional `Value` formal records the original lhs `40`.
  5. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  6. `Entry() == 42` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalReverseOperatorRewritesToOpAddRCallWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalReverseOperatorExecutesOpAddRCallWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opaddr-red` `20260901_070216_747_07720a1b`
  **0/1 FAIL**. Build succeeded, but Entry returned leftover
  `EXPR kind=Binary literal=+` of IntegerLiteral `40` and DeclRef `Object`.
  `T::opAdd_r(int) const` was present as DECL 4 and unused.
- **AST-green:** `cta-sema-call-53-opaddr-green` `20260901_070439_804_2388408d`
  **1/1 PASS** after `ActOnBinaryExpr` tries `opAdd_r` on the rhs when lhs
  `opAdd` misses. Primitive/enum/void receivers stay builtin Binary.
  `opEquals` / `opCmp` do not grow reverse names.
- **CodeGen/provenance:** `cta-sema-call-53-opaddr-codegen-green`
  `20260901_070520_836_e82bbc85` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **488/488** `cta-ast-first-sema`
  `20260901_070559_418_e01d26b7`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_070728_113_b02f8409`, ProductionCodeGen
  **151/151** `cta-ast-first-prodcodegen` `20260901_070807_341_640c74f7`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
