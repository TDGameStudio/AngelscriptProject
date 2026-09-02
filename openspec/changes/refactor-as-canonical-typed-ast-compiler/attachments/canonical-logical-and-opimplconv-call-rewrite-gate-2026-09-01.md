# Canonical logical `Object && true` `opImplConv` rewrite (CTA-S164)

Date: 2026-09-01

## Scope

Continues remaining Task 5.3 / 13.2 Sema authority. CTA-S158–S161 rewrite
VALUE objects through `bool opImplConv()` for unary `!`, Conditional,
`if`/`while`, and `for` conditions. Production `&&`/`||` go through
`ActOnLogicalExpr`, which did not. `Object && true` sealed leftover
Logical `&&` of DeclRef `T`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY. The same `ActOnLogicalExpr` rewrite
covers `||`; this card locks `&&`.

## Gate card: `Object && true` is Logical `&&` of `T::opImplConv()`

- **OpenSpec task(s):** `5.3`, overlapping `13.2` / `5.4` short-circuit
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
      return Object && true ? 42 : 0;
  }
  ```
- **Canonical facts:**
  1. Conditional cond is `asAST_EXPR_LOGICAL` spelling `&&` whose lhs
     is `asAST_EXPR_CALL` of `T::opImplConv() const`, not leftover
     DeclRef of `T`.
  2. Publisher is Canonical CodeGen; legacy compiler count is 0.
  3. `Entry() == 0` (`Stored == 0`). Leftover object-as-true would
     return 42.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalLogicalAndRewritesValueOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalLogicalAndOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-logical-and-implconv-red`
  `20260901_115138_107_82ac47fd` **0/1 FAIL**. Dump:
  `EXPR id=16 kind=Logical type=bool literal=&& lhs=14 rhs=15` with
  `lhs` DeclRef `Object type=T`. `T::opImplConv() const` was DECL 4
  and unused as the operand.
- **AST-green:** `cta-sema-call-53-logical-and-implconv-green`
  `20260901_115449_402_962dd2ce` **1/1 PASS**. `ActOnLogicalExpr`
  rewrites both operands through `RewriteValueToBoolViaOpImplConv`
  before sealing Logical.
- **CodeGen/provenance:** `cta-sema-call-53-logical-and-implconv-codegen-green`
  `20260901_115551_929_9cdc838d` **1/1 PASS**. `Entry() == 0`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **506/506** `cta-ast-first-sema`
  `20260901_115703_576_d2986168`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_115921_308_8003d9d4`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **169/169**
  `cta-ast-first-prodcodegen` `20260901_120006_362_7539f38d`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/
  mixin/import/native families; `asCCompiler` still constructed when
  `TryRestoreBuildArtifact` is not RESTORED). 13.2 stays `[ ]`.
