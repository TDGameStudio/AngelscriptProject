# Canonical Conditional `opImplConv` Call rewrite (CTA-S159)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-rewrite sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed implicit-conversion Call and must
not reconstruct `asCCompiler`. CTA-S158 sealed `!Object` as Unary `!` of
`T::opImplConv()`. LEGACY `CompileCondition` also converts a VALUE object
through `bool opImplConv()` before the branch. Canonical
`ActOnConditionalExpr` left `Object ? 42 : 0` as leftover Conditional
`cond=` DeclRef of `T`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Object ? 42 : 0` is Conditional of `T::opImplConv()`

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      bool opImplConv() const
      {
          return Stored != 0;
      }
  }

  int Entry()
  {
      T Object;
      return Object ? 42 : 0;
  }
  ```
- **Canonical facts:**
  1. The Conditional condition is `asAST_EXPR_CALL` of
     `T::opImplConv() const` typed `bool`, not leftover DeclRef of `T`.
  2. The Call has a receiver (`Object`).
  3. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  4. `Entry() == 0` through Canonical CodeGen (`Stored == 0` so
     `opImplConv()` is false). Leftover object-as-cond would be truthy.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalConditionalRewritesValueOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalConditionalOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-cond-implconv-red`
  `20260901_103314_213_a149c09e` **0/1 FAIL**. Build succeeded. Dump:
  `EXPR id=14 kind=DeclRef type=T literal=Object` as Conditional
  `cond=14`. `T::opImplConv() const` was DECL 4 and unused as the
  condition.
- **AST-green:** `cta-sema-call-53-cond-implconv-green`
  `20260901_103744_917_b39fdc0b` **1/1 PASS**. Shared
  `RewriteValueToBoolViaOpImplConv` intern `opImplConv` when the
  condition is not already `ttBool`; `ActOnConditionalExpr` and unary
  `!` both consume it.
- **CodeGen/provenance:** `cta-sema-call-53-cond-implconv-codegen-green`
  `20260901_103828_445_08d69c22` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 0`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **502/502** `cta-ast-first-sema`
  `20260901_103912_922_701ff05f`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_104142_252_6e3255bc`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **164/164**
  `cta-ast-first-prodcodegen` `20260901_104228_529_43d9e184`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  still rerun `asCCompiler` for unsealed families). 13.2 stays `[ ]`.
  `if (Object)` / `while (Object)` statement conditions and leftover
  Unary `!` of primitive `bool` typed as `int` are not this card.
