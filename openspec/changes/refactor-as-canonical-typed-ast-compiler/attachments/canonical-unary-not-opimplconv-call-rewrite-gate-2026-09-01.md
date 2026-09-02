# Canonical unary-not `opImplConv` Call rewrite (CTA-S158)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-rewrite sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed implicit-conversion Call and must
not reconstruct `asCCompiler`. LEGACY `CompileUnaryOperator` converts a
VALUE object through `bool opImplConv()` then emits NOT. Canonical
`ActOnUnaryExpr` ranked operator methods (`opNeg` / `opCom` / `opInc`)
but left `!Object` as leftover Unary `!` of `T` typed as `int`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

Mixin omitted-default `Object.MixHelper()` and member named+default
`Object.Pack(B: 7)` were already sealed (characterization lock-in in the
same batch, not authentic REDs). They stay as permanent execute gates.

## Gate card: `!Object` is Unary `!` of `T::opImplConv()`

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
      return !Object ? 42 : 0;
  }
  ```
- **Canonical facts:**
  1. The Conditional condition is `asAST_EXPR_UNARY` `!` of an
     `asAST_EXPR_CALL` of `T::opImplConv() const`, not leftover Unary `!`
     of `T` typed as `int`.
  2. The Call has a receiver (`Object`). Unary `!` of that Call is typed
     `bool`.
  3. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  4. `Entry() == 42` through Canonical CodeGen (`Stored == 0` so
     `!opImplConv()` is true).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalUnaryNotRewritesValueOpImplConvWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalUnaryNotOpImplConvExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-unary-not-red`
  `20260901_101808_022_8c99b271` **0/1 FAIL**. Build succeeded. Dump:
  `EXPR id=15 kind=Unary type=int quals=0 literal=!` as Conditional
  `cond=`. `T::opImplConv() const` was DECL 4 and unused as the `!`
  operand.
- **AST-green:** `cta-sema-call-53-unary-not-green`
  `20260901_101954_006_850c93ec` **1/1 PASS**. `ActOnUnaryExpr` for `!`
  intern `opImplConv` when the inner type is not already `ttBool`,
  arranges a zero-arg Call as receiver, then wraps Unary `!` typed
  `bool`.
- **CodeGen/provenance:** `cta-sema-call-53-unary-not-codegen-green`
  `20260901_102035_097_a1d054ab` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **501/501** `cta-ast-first-sema`
  `20260901_102114_678_4a6368a8`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_102326_106_439491a0`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **163/163**
  `cta-ast-first-prodcodegen` `20260901_102802_514_736135af`.
- **Adjacent lock-in (characterization, already green):**
  mixin omitted-default Sema
  `CanonicalMixinOmittedDefaultSealsFilledBinaryWithoutLegacyCompiler`
  `cta-sema-call-53-mixin-default-red` **1/1**, CodeGen
  `CanonicalMixinOmittedDefaultExecutesWithoutLegacyCompiler`
  `cta-sema-call-53-mixin-default-codegen` **1/1** `Entry()==41`;
  member named+default Sema
  `CanonicalMemberNamedDefaultSealsFilledFormalPlanWithoutLegacyCompiler`
  `cta-sema-call-53-member-named-red` **1/1**, CodeGen
  `CanonicalMemberNamedDefaultExecutesWithoutLegacyCompiler`
  `cta-sema-call-53-member-named-codegen` **1/1** `Entry()==17`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  still rerun `asCCompiler` for unsealed families). 13.2 stays `[ ]`.
  Primitive `!bool` leftover Unary typed as `int` and VALUE `Object` used
  as a Conditional/If condition without `!` are not this card.
