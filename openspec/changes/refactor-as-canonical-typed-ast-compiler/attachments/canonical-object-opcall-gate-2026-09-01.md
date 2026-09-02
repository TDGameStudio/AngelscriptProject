# Canonical object `opCall` rewrite (CTA-S166)

Date: 2026-09-01

## Scope

Task 5.3 / 13.2 remaining sentence: resolved ordinary/member/mixin/import/native
calls. LEGACY `CompileFunctionCall` rewrites `Object(args)` on a VALUE object
to `T::opCall`. Canonical `ActOnCallExpr` treated the identifier as a function
name and failed `unresolved-callee:Object`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: object functor call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  class T
  {
      int opCall(int n)
      {
          return n + 1;
      }
  }

  int Entry()
  {
      T Object;
      return Object(41);
  }
  ```
- **Canonical facts:**
  1. Sealed return is Call `T::opCall(int)` with receiver `Object`.
  2. Not `unresolved-callee:Object` and not a leftover named `Object` Call.
  3. Public CANONICAL `Build()` publishes CodeGen, legacy count 0,
     `Entry() == 42`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalObjectCallRewritesToOpCallWithoutLegacyCompiler`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalObjectOpCallExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opcall-red`
  `20260901_122532_466_782b9ebb` **0/1 FAIL**. Seal failed `r=-10`.
  Diagnostic: `unresolved-callee:Object nargs=1 hits=1 hit0 kind=12 params=(0)`.
- **AST-green:** `cta-sema-call-53-opcall-green`
  `20260901_123029_454_55daaa81` **1/1 PASS**. Call of `T::opCall(int)`
  with receiver on `Object`.
- **CodeGen/provenance:** `cta-sema-call-53-opcall-codegen-green`
  `20260901_123107_718_21cafc35` **1/1 PASS**. Publisher is Canonical
  CodeGen, legacy 0, `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **508/508** `cta-ast-first-sema`
  `20260901_123212_501_c83fc3db`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_123347_348_bc33cde2`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **171/171**
  `cta-ast-first-prodcodegen` `20260901_123431_710_743e93e7`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining call families).
  13.2 stays `[ ]`. Postfix `Make()(41)` shares the same rewrite helper
  but is not this card's execute lock.
