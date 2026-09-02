# Canonical prefix property increment Sequence (CTA-S154)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 5.4
and 13.2: Canonical Bytecode must consume a sealed Get/Set rewrite and must
not rerun `asCCompiler`. Postfix `Make().Value++` already seals a Sequence
(CTA-S138). Prefix `++Make().Value` still intern leftover Unary `pre++` of
the `GetValue` Call; CodeGen `EmitPrimitiveIncrementOrDecrement` then fails
closed because the target is not a DeclRef lvalue.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `++Make().Value` seals OpaqueValue Get/Set Sequence

- **OpenSpec task(s):** `5.3`, overlapping `5.4` and `13.2`
- **Source fixture:**
  ```as
  class T
  {
      int Stored = 5;

      int GetValue()
      {
          return Stored;
      }

      void SetValue(int Next)
      {
          Stored = Next;
      }
  }

  T Make()
  {
      T Object;
      return Object;
  }

  int Entry()
  {
      return ++Make().Value;
  }
  ```
- **Canonical facts:**
  1. Entry's return expression is `asAST_EXPR_SEQUENCE` with one
     `OpaqueValue` of `Make()`, not leftover `Unary pre++` of `GetValue`.
  2. `T::GetValue()` and `T::SetValue(int)` both use that OpaqueValue as
     receiver. `Make()` is called once.
  3. The Sequence yields the incremented value (`Stored + 1`).
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 6` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalPrefixPropertyIncrementSealsOpaqueSequence`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalPrefixPropertyIncrementExecutesWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-prefix-inc-red` `20260901_090302_155_e64d77c1`
  **0/1 FAIL**. Build failed `result=-7`. Diagnostics:
  `Canonical CodeGen failed code=-7 line=4911: function=Entry()
  emitterLine=4911 error=-7`. Leftover Unary `pre++` of the GetValue Call
  is not a DeclRef lvalue.
- **AST-green:** `cta-sema-call-53-prefix-inc-green`
  `20260901_090458_727_5db4dbc6` **1/1 PASS**. Prefix `++`/`--` now reuse
  the property Get/Set Sequence rewrite and yield the incremented value.
- **CodeGen/provenance:** `cta-sema-call-53-prefix-inc-codegen-green`
  `20260901_090533_977_0c03ce0c` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 6`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **495/495** `cta-ast-first-sema`
  `20260901_090724_547_10d33db7`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_090906_382_8d1e74f2`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **157/157**
  `cta-ast-first-prodcodegen` `20260901_090949_590_664ba19c`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
