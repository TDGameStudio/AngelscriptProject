# Canonical postfix index increment old-value Sequence (CTA-S156)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 5.4
and 13.2: Canonical Bytecode must consume a sealed `opIndex` rewrite and must
not rerun `asCCompiler`. Prefix `++Make()[0]` already seals an OpaqueValue
Sequence (CTA-S155). Postfix `Make()[0]++` reused that Sequence but yielded
the lvalue `opIndex` Call (`parts=...,21`), so the result was the written
value rather than the loaded int.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Make()[0]++` yields the loaded rvalue int

- **OpenSpec task(s):** `5.3`, overlapping `5.4` and `13.2`
- **Source fixture:**
  ```as
  class T
  {
      int Stored = 5;

      int &opIndex(int Index)
      {
          return Stored;
      }
  }

  T Make()
  {
      T Object;
      return Object;
  }

  int Entry()
  {
      return Make()[0]++;
  }
  ```
- **Canonical facts:**
  1. Entry's return expression is `asAST_EXPR_SEQUENCE` with one
     `OpaqueValue` of `Make()`, not leftover `Unary post++`.
  2. `T::opIndex(int)` uses that OpaqueValue as receiver. `Make()` is
     called once. The Sequence contains an Assign that writes the
     incremented value through the lvalue `opIndex` Call.
  3. The Sequence yields a decayed rvalue int snapshot of the loaded
     value (`Stored`), not the lvalue Call after the write.
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 5` through Canonical CodeGen (postfix old value).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalPostfixIndexIncrementSealsOldValueSequence`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalPostfixIndexIncrementExecutesOldValueWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-postfix-index-red` `20260901_093228_479_8e7f2eef`
  **0/1 FAIL**. Build succeeded. Sequence `parts=20,21,23,24,21` yielded the
  lvalue `opIndex` Call (`EXPR 21`, `quals=8`) instead of a decayed loaded
  int.
- **AST-green:** `cta-sema-call-53-postfix-index-green`
  `20260901_093354_403_5ed4f9dc` **1/1 PASS**. Lvalue `opIndex` postfix
  decays the Call to an rvalue int, snapshots it in OpaqueValue, then
  Assigns `orig + 1` and yields `orig`.
- **CodeGen/provenance:** `cta-sema-call-53-postfix-index-codegen-green`
  `20260901_093431_589_511490b6` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 5`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **497/497** `cta-ast-first-sema`
  `20260901_093508_711_49a96479`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_093643_583_158d5adc`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **159/159**
  `cta-ast-first-prodcodegen` `20260901_093723_000_75c636e1`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
