# Canonical for-cond `opImplConv` Call rewrite (CTA-S161)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-rewrite sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed implicit-conversion Call and must
not reconstruct `asCCompiler`. CTA-S158–S160 sealed unary `!Object`,
Conditional `Object ? :`, and `if`/`while (Object)` through
`RewriteValueToBoolViaOpImplConv`. LEGACY `CompileCondition` also converts
a VALUE object through `bool opImplConv()` before `for`. Canonical left
`for (; Object; )` as leftover stmt cond DeclRef of `T`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `for (; Object; )` is a stmt cond Call of `T::opImplConv()`

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
      int Value = 0;
      for (; Object; )
      {
          Value = 1;
          break;
      }
      return Value;
  }
  ```
- **Canonical facts:**
  1. The For stmt cond is `asAST_EXPR_CALL` of `T::opImplConv() const`
     typed `bool`, not leftover DeclRef of `T`.
  2. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  3. `Entry() == 0` through Canonical CodeGen (`Stored == 0` so the loop
     is skipped). Leftover object-as-cond would be truthy.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalForCondRewritesValueOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalForCondOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-for-implconv-red`
  `20260901_110108_737_1bdc5f9c` **0/1 FAIL**. Build succeeded. Dump:
  `STMT For expr=17` was DeclRef `Object type=T`. `T::opImplConv() const`
  was DECL 4 and unused as the condition.
- **AST-green:** `cta-sema-call-53-for-implconv-green`
  `20260901_110238_866_636b24ed` **1/1 PASS**. Typed for finish
  (`ActOnForStatementAction`) wrote `action.condition` directly and now
  rewrites through `RewriteValueToBoolViaOpImplConv`. `ActOnForStmt`
  also rewrites so the helper path matches.
- **CodeGen/provenance:** `cta-sema-call-53-for-implconv-codegen-green`
  `20260901_110546_244_1a88677e` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 0`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **504/504** `cta-ast-first-sema`
  `20260901_110630_450_438d9790`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_111036_640_dfc1bd63`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **166/166**
  `cta-ast-first-prodcodegen` `20260901_111131_914_cde5bbd1`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  still rerun `asCCompiler` for unsealed families). 13.2 stays `[ ]`.
  Leftover Unary `!` of primitive `bool` typed as `int` and WorldContext
  hidden-call execution are not this card.
