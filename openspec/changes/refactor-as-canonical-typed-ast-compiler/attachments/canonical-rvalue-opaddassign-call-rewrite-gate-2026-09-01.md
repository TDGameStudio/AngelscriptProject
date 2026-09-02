# Canonical rvalue `Make() += 7` opAddAssign Call (CTA-S157)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-rewrite sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed overloaded compound-assignment Call
and must not reconstruct `asCCompiler`. Lvalue `Object += 7` already rewrites
to `T::opAddAssign(int)` (CTA-S146). `Make() += 7` was `expression-not-assignable`
because the rewrite required an lvalue.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Make() += 7` is `T::opAddAssign(int)` on a materialized temporary

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

  T Make()
  {
      T Object;
      return Object;
  }

  int Entry()
  {
      Make() += 7;
      return 42;
  }
  ```
- **Canonical facts:**
  1. Entry's expression statement is `asAST_EXPR_CALL` of
     `T::opAddAssign(int)`, not leftover `Assign +=`.
  2. The Call has a receiver. `Make()` is called once.
  3. A non-lvalue VALUE temporary is materialized before the Call so
     CodeGen owns storage for `this`.
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 42` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalRvalueCompoundAssignRewritesToOpAddAssignCall`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalRvalueCompoundAssignExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-rvalue-addassign-red2`
  `20260901_095803_319_95667f0b` **0/1 FAIL**. Build failed
  `expression-not-assignable` (`result=-10`, publisher=0, legacy=0).
- **AST-green:** `cta-sema-call-53-rvalue-addassign-green`
  `20260901_095913_231_e5bf06f6` **1/1 PASS**. Overloaded compound
  assignment on a non-const VALUE temporary rewrites to `opAddAssign`.
- **CodeGen/provenance:** `cta-sema-call-53-rvalue-addassign-codegen-diag`
  `20260901_100331_234_928907f4` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **498/498** `cta-ast-first-sema`
  `20260901_100412_721_05254227`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_100619_479_0c81dcc8`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **160/160**
  `cta-ast-first-prodcodegen` `20260901_100704_554_6cf9e29f`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  still rerun `asCCompiler` for unsealed families). 13.2 stays `[ ]`.
