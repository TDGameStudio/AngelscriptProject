# Canonical prefix index increment Sequence (CTA-S155)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 5.4
and 13.2: Canonical Bytecode must consume a sealed `opIndex` rewrite and must
not rerun `asCCompiler`. Compound `Make()[0] += 1` already seals an OpaqueValue
Sequence (CTA-S132). Prefix `++Make()[0]` still intern leftover Unary `pre++`
of the `opIndex` Call; CodeGen `EmitPrimitiveIncrementOrDecrement` then fails
closed because the target is not a DeclRef lvalue.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `++Make()[0]` seals OpaqueValue opIndex/Assign Sequence

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
      return ++Make()[0];
  }
  ```
- **Canonical facts:**
  1. Entry's return expression is `asAST_EXPR_SEQUENCE` with one
     `OpaqueValue` of `Make()`, not leftover `Unary pre++` of `opIndex`.
  2. `T::opIndex(int)` uses that OpaqueValue as receiver. `Make()` is
     called once. The Sequence contains an Assign that writes the
     incremented value through the lvalue `opIndex` Call.
  3. The Sequence yields the incremented value (`Stored + 1`).
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 6` through Canonical CodeGen.
  6. By-value `opIndex` (rvalue Call) is not rewritten; the structural
     postfix action `v.Next(1)[2,3]++` still owns Unary `post++` of the
     Call.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalPrefixIndexIncrementSealsOpaqueSequence`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalPrefixIndexIncrementExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-prefix-index-red` `20260901_091610_608_dab83c01`
  **0/1 FAIL**. Build failed `result=-7`. Diagnostics:
  `Canonical CodeGen failed code=-7 line=4911: function=Entry()
  emitterLine=4911 error=-7`. Leftover Unary `pre++` of the opIndex Call
  is not a DeclRef lvalue.
- **AST-green:** `cta-sema-call-53-prefix-index-green`
  `20260901_092258_683_f5a3e7e1` **1/1 PASS**. Lvalue `opIndex` prefix/postfix
  reuses the OpaqueValue Sequence plus Assign through the Call. Rvalue
  `opIndex` stays Unary so the structural postfix action remains ordered.
- **CodeGen/provenance:** `cta-sema-call-53-prefix-index-codegen-green`
  `20260901_092339_064_da81d9ba` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 6`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **496/496** `cta-ast-first-sema`
  `20260901_092414_625_859cf5b2`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_092557_131_b99869ed`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **158/158**
  `cta-ast-first-prodcodegen` `20260901_092636_786_e744a5ef`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
