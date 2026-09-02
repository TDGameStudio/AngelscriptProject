# Canonical opCmp less-than rewrite (CTA-S149)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed operator-call rewrite and must not
rerun `asCCompiler`. AngelScript `<`/`>`/`<=`/`>=` all rank `opCmp`, which
returns `int`; the language meaning is that ranking compared against 0
(`CMPIi` then `TS`/`TP`/`TNP`/`TNS`). Canonical Sema already rewrote
`Left < Right` to a Call of `T::opCmp`, but left that Call as the condition,
so any non-zero ranking executed as true (`3 < 1` became truthy because
`opCmp` returned 2).

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Left < Right` seals `opCmp < 0`, not a leftover Call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      int opCmp(const T&in Other) const
      {
          return Stored - Other.Stored;
      }
  }

  int Entry()
  {
      T Left;
      T Right;
      Left.Stored = 3;
      Right.Stored = 1;
      return Left < Right ? 42 : 0;
  }
  ```
- **Canonical facts:**
  1. Entry's Conditional condition is `asAST_EXPR_BINARY` `<` whose lhs is
     a Call of `T::opCmp` and whose rhs is IntegerLiteral `0`.
  2. The Call seals `receiver=` of `Left`.
  3. The Binary result type is `bool`.
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 0` through Canonical CodeGen (`3 < 1` is false; leftover
     truthy `opCmp` would have returned 42).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalLessThanRewritesToOpCmpComparedAgainstZeroWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalLessThanExecutesOpCmpComparedAgainstZeroWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opcmp-lt-red` `20260901_072804_392_205c9579`
  **0/1 FAIL**. Build succeeded. Dump: `EXPR 30 Call T::opCmp(const T&in) const
  receiver=Left`; `EXPR 33 Conditional cond=30 then=42 else=0`. Assertion:
  "Left < Right must seal Binary < of T::opCmp against 0, not leftover
  Binary of T or a bare opCmp Call."
- **AST-green:** `cta-sema-call-53-opcmp-lt-green` `20260901_072923_116_3895b5fc`
  **1/1 PASS** after `ActOnBinaryExpr` wraps a rewritten `opCmp` Call in
  `ActOnBinary(op, result, 0, bool)` for `<`/`>`/`<=`/`>=`. Uses
  `ActOnBinary` rather than re-entering `ActOnBinaryExpr` so the wrap cannot
  re-rank `opCmp`. `!=` still wraps `opEquals` in Unary `!`. Primitive
  comparisons stay builtin Binary.
- **CodeGen/provenance:** `cta-sema-call-53-opcmp-lt-codegen-green`
  `20260901_073000_612_04cbf720` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 0`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **490/490** `cta-ast-first-sema`
  `20260901_073316_833_a5c1a20a`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_073450_491_3c24299d`, ProductionCodeGen
  **153/153** `cta-ast-first-prodcodegen` `20260901_073528_418_ed109df9`.
  First Sema prefix after the wrap was **489/490**:
  `OperatorLessSelectsOpCmpNotBuiltinBinary` still forbade any Binary `<`
  (the leftover-Call lock). It now requires `type=bool` Binary `<` wrapping
  the `opCmp` Call and still rejects leftover Binary of two `T` values.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
