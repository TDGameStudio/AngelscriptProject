# Canonical `return Object` through implicit `opImplConv` (CTA-S168)

Date: 2026-09-01

## Scope

Task 5.3 / 13.2 remaining sentence: resolved ordinary/member/mixin/import/native
calls and call rewrites. LEGACY implicit conversion looks up 0-arg
`opImplConv` (not explicit `opConv`). Canonical return only converted
numeric-scalar to numeric-scalar, so `return Object` sealed leftover
DeclRef `T` and left `T::opImplConv() const` unused. Build could still
succeed with a type mismatch.

Explicit `Cast<int>(Object)` through `opConv` is CTA-S167 and stays on
`allowExplicitOpConv=true`. This card uses `false` so implicit return
cannot pick `opConv`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: implicit return through opImplConv

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  class T
  {
      int opImplConv() const
      {
          return 40 + 2;
      }
  }

  int Entry()
  {
      T Object;
      return Object;
  }
  ```
- **Canonical facts:**
  1. Sealed return is Call `T::opImplConv() const` with receiver `Object`.
  2. Not leftover DeclRef `T` and not leftover Conversion `dest=int src=T`.
  3. Public CANONICAL `Build()` publishes CodeGen, legacy count 0,
     `Entry() == 42`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalReturnObjectRewritesThroughOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalReturnObjectOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opimplconv-return-red`
  `20260901_125450_643_feaae34d` **0/1 FAIL**. Seal succeeded. Dump:
  leftover Return `EXPR id=9 kind=DeclRef type=T`. `T::opImplConv() const`
  unused.
- **AST-green:** `cta-sema-call-53-opimplconv-return-green`
  `20260901_125727_919_e38ebcb2` **1/1 PASS**. Call of `opImplConv` with
  receiver on `Object`.
- **CodeGen/provenance:** `cta-sema-call-53-opimplconv-return-codegen-green`
  `20260901_130241_310_e6b09276` **1/1 PASS**. Publisher is Canonical
  CodeGen, legacy 0, `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **511/511** `cta-ast-first-sema`
  `20260901_130509_797_a4d678fd`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_130657_339_d9b78116`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **174/174**
  `cta-ast-first-prodcodegen` `20260901_130742_201_92ae2c69`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining call families).
  13.2 stays `[ ]`. Implicit conversion through `opImplConv` on local
  init, assignment, and call arguments is not this card.
