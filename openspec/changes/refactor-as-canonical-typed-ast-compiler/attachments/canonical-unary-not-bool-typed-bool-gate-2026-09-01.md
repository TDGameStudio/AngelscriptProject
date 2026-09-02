# Canonical leftover `!bool` typed bool (CTA-S162)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 / 13.2 Sema-authority sentence:
Canonical Bytecode must consume sealed expression types and must not
reconstruct `asCCompiler`. CTA-S158 rewrites VALUE `!Object` through
`bool opImplConv()` then wraps Unary `!` typed bool. Already-bool
operands skipped that wrap (`conv.value == inner.value`) and fell
through `ActOnUnaryExpr` with `resultType = intType`, so leftover
Unary `!` of `bool Flag` sealed as `type=int`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `!Flag` is Unary `!` typed bool, not leftover int

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  int Entry()
  {
      bool Flag = false;
      return !Flag ? 42 : 0;
  }
  ```
- **Canonical facts:**
  1. The Conditional cond is `asAST_EXPR_UNARY` spelling `!` whose
     primitive type is `ttBool`, not leftover Unary `!` typed int.
  2. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  3. `Entry() == 42` through Canonical CodeGen (`!false` is true).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalUnaryNotOfBoolIsTypedBoolWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalUnaryNotOfBoolExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-unary-not-bool-red`
  `20260901_112135_653_1f8273b5` **0/1 FAIL**. Build succeeded. Dump:
  `EXPR id=5 kind=Unary type=int quals=0 literal=!` as Conditional
  `cond=5`. Inner DeclRef `Flag type=bool` was already bool, so the
  VALUE `opImplConv` rewrite returned the same inner and the fallthrough
  defaulted Unary `!` to int.
- **AST-green:** `cta-sema-call-53-unary-not-bool-green`
  `20260901_112412_175_339cbd59` **1/1 PASS**. `ActOnUnaryExpr`
  fallthrough now intern `ttBool` for spelling `!` instead of leftover
  int.
- **CodeGen/provenance:** `cta-sema-call-53-unary-not-bool-codegen-green`
  `20260901_112509_703_844a1d49` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **505/505** `cta-ast-first-sema`
  `20260901_112621_054_25ae60fe`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_112841_818_34e0841b`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **167/167**
  `cta-ast-first-prodcodegen` `20260901_112932_501_6ed1dc70`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  still rerun `asCCompiler` for unsealed families; WorldContext dump is
  sealed but hidden-call execute is not this card). 13.2 stays `[ ]`.
