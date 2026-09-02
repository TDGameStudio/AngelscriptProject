# Canonical swapped opCmp rewrite (CTA-S151)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed operator-call rewrite and must not
rerun `asCCompiler`. `opEquals`/`opCmp` have no `_r` names. AngelScript retries
the same method on the rhs when the lhs cannot host it, and inverts comparison
operators (`3 < Object` is `Object.opCmp(3) > 0`). Canonical Sema skipped that
swap, so `3 < Object` sealed leftover `Binary <` of `int` and `T` even though
`T::opCmp(int) const` existed.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `3 < Object` seals swapped `opCmp > 0`

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      int opCmp(int Value) const
      {
          return Stored - Value;
      }
  }

  int Entry()
  {
      T Object;
      Object.Stored = 5;
      return 3 < Object ? 42 : 0;
  }
  ```
- **Canonical facts:**
  1. Entry's Conditional condition is `asAST_EXPR_BINARY` `>` whose lhs is
     a Call of `T::opCmp(int) const` and whose rhs is IntegerLiteral `0`.
  2. The comparison operator is inverted (`<` → `>`), not leftover
     `Binary <` of `int` and `T` and not unswapped `opCmp < 0`.
  3. The Call seals `receiver=` of `Object` and one positional `Value` formal
     (the original lhs `3`).
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 42` through Canonical CodeGen (`5 > 3`).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalSwappedLessThanRewritesToOpCmpComparedAgainstZeroWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalSwappedLessThanExecutesOpCmpComparedAgainstZeroWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opcmp-swap-red` `20260901_075220_885_104afa44`
  **0/1 FAIL**. Build succeeded. Dump: `EXPR 20 Binary type=bool literal=<`
  of IntegerLiteral `3` and DeclRef `Object`; `EXPR 23 Conditional cond=20`.
  `T::opCmp(int) const` was DECL 4 and unused.
- **AST-green:** `cta-sema-call-53-opcmp-swap-green` `20260901_075357_516_29b3a99e`
  **1/1 PASS**. After lhs `opEquals`/`opCmp` miss, Sema retries the same method
  on the rhs and wraps swapped comparisons with `InvertComparisonOperator`
  against 0. Reverse `_r` still applies to other operators.
- **CodeGen/provenance:** `cta-sema-call-53-opcmp-swap-codegen-green`
  `20260901_075445_215_5fc7361e` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **492/492** `cta-ast-first-sema`
  `20260901_075521_020_39eaf01e`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_075649_388_47f41398`, ProductionCodeGen
  **155/155** `cta-ast-first-prodcodegen` `20260901_075728_562_6190b19b`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
