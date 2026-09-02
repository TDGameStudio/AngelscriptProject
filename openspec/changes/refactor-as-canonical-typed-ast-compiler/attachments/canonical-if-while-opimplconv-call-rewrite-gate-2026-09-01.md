# Canonical if/while `opImplConv` Call rewrite (CTA-S160)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-rewrite sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed implicit-conversion Call and must
not reconstruct `asCCompiler`. CTA-S158/S159 sealed unary `!Object` and
Conditional `Object ? :` through `RewriteValueToBoolViaOpImplConv`. LEGACY
`CompileCondition` also converts a VALUE object through `bool opImplConv()`
before `if` / `while`. Canonical left `if (Object)` / `while (Object)` as
leftover stmt cond DeclRef of `T`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `if (Object)` / `while (Object)` are stmt cond Calls of `T::opImplConv()`

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
      if (Object)
      {
          Value = 1;
      }
      while (Object)
      {
          Value = 2;
          break;
      }
      return Value;
  }
  ```
- **Canonical facts:**
  1. The If stmt cond is `asAST_EXPR_CALL` of `T::opImplConv() const`
     typed `bool`, not leftover DeclRef of `T`.
  2. The While stmt cond is the same Call shape.
  3. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  4. `Entry() == 0` through Canonical CodeGen (`Stored == 0` so both
     branches are skipped). Leftover object-as-cond would be truthy.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalIfWhileRewritesValueOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalIfWhileOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-if-while-implconv-red`
  `20260901_104710_813_9a9871de` **0/1 FAIL**. Build succeeded. Dump:
  `STMT If expr=17` and `While expr=21` were both DeclRef `Object type=T`.
  `T::opImplConv() const` was DECL 4 and unused as either condition.
- **AST-green:** `cta-sema-call-53-if-while-implconv-green`
  `20260901_105225_262_887c5cb2` **1/1 PASS**. `ActOnIfStmt` rewrites
  through `RewriteValueToBoolViaOpImplConv`. Typed while/do-while finish
  (`ActOnWhileStatementAction`) wrote `action.condition` directly and
  also had to rewrite; `ActOnWhileStmt` alone was not the production
  while path.
- **CodeGen/provenance:** `cta-sema-call-53-if-while-implconv-codegen-green`
  `20260901_105305_350_7541c833` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 0`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **503/503** `cta-ast-first-sema`
  `20260901_105345_268_ad6bbd4b`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_105622_183_15889422`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **165/165**
  `cta-ast-first-prodcodegen` `20260901_105709_266_a6994173`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  still rerun `asCCompiler` for unsealed families). 13.2 stays `[ ]`.
  `for (; Object; )` statement conditions and leftover Unary `!` of
  primitive `bool` typed as `int` are not this card.
