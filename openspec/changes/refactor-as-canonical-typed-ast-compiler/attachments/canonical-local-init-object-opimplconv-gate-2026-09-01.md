# Canonical local initialization through implicit `opImplConv` (CTA-S169)

Date: 2026-09-01

## Scope

Task 5.3 / 13.2 remaining sentence: implicit object conversion must be a
resolved Canonical Call before sealing. After CTA-S168 closed
`return Object`, local initialization still kept `int Value = Object` as a
VALUE `T` declaration reference / generic Conversion and did not select
`T::opImplConv() const` in Sema.

This card applies the same implicit-only rule used by return:
`allowExplicitOpConv=false`, so local initialization cannot silently choose
an explicit `opConv`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10. Product default
stays LEGACY.

## Gate card: local initialization through opImplConv

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
      int Value = Object;
      return Value;
  }
  ```
- **Canonical facts:**
  1. The sealed `Value` declaration initializer is a Call of
     `T::opImplConv() const` with receiver `Object`.
  2. It is not a leftover DeclRef of `T` and not a generic Conversion from
     `T` to `int`.
  3. Public CANONICAL `Build()` publishes CodeGen with zero legacy compiler
     invocations, and `Entry() == 42`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalLocalInitObjectRewritesThroughOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalLocalInitObjectOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opimplconv-init-red`
  `20260901_131237_872_d1e996b9` **0/1 FAIL**. The assertion reported that
  `int Value = Object` was not rewritten to a Call of
  `T::opImplConv() const`; the sealed dump retained the pre-rewrite form.
- **AST-green:** `cta-sema-call-53-opimplconv-init-green`
  `20260901_131349_241_cd61fc59` **1/1 PASS**.
- **CodeGen/provenance:** `cta-sema-call-53-opimplconv-init-codegen-green`
  `20260901_131427_149_9e24b4d0` **1/1 PASS**. Publisher is Canonical
  CodeGen, legacy count is 0, and `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **512/512** `cta-ast-first-sema`
  `20260901_131504_061_96d355a1`; Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_131648_284_c5dc602f`;
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **175/175**
  `cta-ast-first-prodcodegen` `20260901_132413_481_dca91aa3`.
- **Remaining boundary:** 5.3 stays `[ ]`; call-argument implicit conversion,
  `opHndlAssign`, funcdef-variable calls, remaining reverse operators,
  mixin/import execute leftovers, and converting-constructor execute are not
  closed by this local-init card. Task 13.2 also stays `[ ]`.
