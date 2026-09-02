# Canonical call argument through implicit `opImplConv` (CTA-S170)

Date: 2026-09-01

## Scope

Task 5.3 / 13.2 remaining sentence: after overload selection, every implicit
object conversion used by a call argument must be represented by a resolved
Canonical Call before sealing. Before this card, candidate ranking recognized
`T::opImplConv() const`, but `ConvertCallArgumentsToFormalTypes` published a
generic Conversion annotated with that declaration. Production CodeGen then
had to reinterpret the annotation and failed closed.

This card follows the local Clang 22.1.8 design reference: Parser calls Sema,
Sema's `ActOnCallExpr` / `BuildCallExpr` boundary owns conversion and final call
construction, and CodeGen reads the completed typed expression. The adopted
AngelScript equivalent therefore materializes the conversion operator as an
ordinary `asAST_EXPR_CALL` in Sema; no CodeGen semantic fallback was added.

The rewrite is implicit-only (`allowExplicitOpConv=false`), so call arguments
cannot silently select an explicit `opConv`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10. Product default
stays LEGACY.

## Gate card: call argument through opImplConv

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

  int Consume(int Value)
  {
      return Value;
  }

  int Entry()
  {
      T Object;
      return Consume(Object);
  }
  ```
- **Canonical facts:**
  1. The sole sealed `Consume` argument is an actual Call of
     `T::opImplConv() const`, not a generic Conversion carrying a
     `resolvedDecl` annotation.
  2. The Call owns receiver `Object`; its enclosing argument record owns exact
     formal `Value`, formal index 0, positional origin, and canonical formal
     type.
  3. Public CANONICAL `Build()` publishes CodeGen with zero legacy compiler
     invocations, and `Entry() == 42`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalCallArgumentObjectRewritesThroughOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalCallArgumentObjectOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opimplconv-arg-red`
  `20260901_133454_183_c064f2b2` **0/1 FAIL**. Canonical CodeGen failed
  `code=-7 line=7751` with `unsupported conversion`, `srcType=T`,
  `dstType=int`, publisher count 0, and legacy count 0.
- **CodeGen-red:** `cta-sema-call-53-opimplconv-arg-codegen-red`
  `20260901_133536_786_582e9851` **0/1 FAIL** with the same unsupported
  Conversion and zero legacy invocations.
- **Build-green:** `cta-sema-call-53-opimplconv-arg-green`
  `20260901_133734_261_7a1d9be6` **PASS**.
- **AST-green:** `cta-sema-call-53-opimplconv-arg-green`
  `20260901_133900_388_25b9043a` **1/1 PASS**.
- **CodeGen/provenance:** `cta-sema-call-53-opimplconv-arg-codegen-green`
  `20260901_133934_915_fe8f7b26` **1/1 PASS**. Publisher is Canonical
  CodeGen, legacy count is 0, and `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **513/513** `cta-ast-first-sema`
  `20260901_134019_465_a5b28263`; Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_134218_459_3ab151d8`;
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **176/176**
  `cta-ast-first-prodcodegen` `20260901_134259_602_bf729e29`.
- **Remaining boundary:** 5.3 stays `[ ]`; `opHndlAssign`, funcdef-variable
  calls, remaining reverse operators, mixin/import execute leftovers, and
  converting-constructor execute are not closed by this argument-conversion
  card. Task 13.2 also stays `[ ]`.

