# Canonical explicit `Cast<int>(Object)` through `opConv` (CTA-S167)

Date: 2026-09-01

## Scope

Task 5.3 / 13.2 remaining sentence: resolved ordinary/member/mixin/import/native
calls and call rewrites. LEGACY `CompileConversion` for explicit Cast looks
up 0-arg `opConv`, then `opImplConv`. Canonical `ActOnCastExpr` sealed a
leftover Conversion `dest=int src=T` and left `T::opConv() const` unused.

Postfix `Make()(41)` was first attempted as the next 5.3 family. It is
characterization-green from the CTA-S166 `TryRewriteObjectOpCall` helper
(`cta-sema-call-53-postfix-opcall-red` `20260901_123901_784_932b974a`
**1/1 PASS immediately**). Keep that execute lock; do not treat it as a
production-change card.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: explicit Cast through opConv

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  class T
  {
      int opConv() const
      {
          return 40 + 2;
      }
  }

  int Entry()
  {
      T Object;
      return Cast<int>(Object);
  }
  ```
- **Canonical facts:**
  1. Sealed return is Call `T::opConv() const` with receiver `Object`.
  2. Not leftover Conversion `dest=int src=T`.
  3. Public CANONICAL `Build()` publishes CodeGen, legacy count 0,
     `Entry() == 42`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalCastIntRewritesObjectThroughOpConvWithoutLegacyCompiler`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalCastIntOpConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opconv-red2`
  `20260901_124354_945_2954a3f5` **0/1 FAIL**. Seal succeeded. Dump:
  `EXPR id=10 kind=Conversion type=int dest=int src=T`. `T::opConv() const`
  unused. (First attempt `cta-sema-call-53-opconv-red` failed too early:
  lowercase `cast<int>` is not this fork's keyword.)
- **AST-green:** `cta-sema-call-53-opconv-green`
  `20260901_124542_859_25229fe3` **1/1 PASS**. Call of `opConv` with
  receiver on `Object`.
- **CodeGen/provenance:** `cta-sema-call-53-opconv-codegen-green`
  `20260901_124619_986_fa72b143` **1/1 PASS**. Publisher is Canonical
  CodeGen, legacy 0, `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **510/510** `cta-ast-first-sema`
  `20260901_124657_137_d4fd5c40`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_124833_937_09bf1aad`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **173/173**
  `cta-ast-first-prodcodegen` `20260901_124913_857_398b7af9`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining call families).
  13.2 stays `[ ]`. Implicit conversion through `opConv` outside explicit
  `Cast<>` is not this card.
