# Canonical ApplyFormat FName + named Print (CTA-S153)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a unique sealed call plan and must not rerun
`asCCompiler`. `FormatSpecifiersAndNamedPrintCompile` failed because
`FString::ApplyFormat(GetName(), ">40")` tied `ApplyFormat(const FString&,
const FString&)` (implicit `FString(FName)` constructor, LEGACY
`asCC_TO_OBJECT_CONV`) with `ApplyFormat(const ?&, const FString&)`
(`asCC_VARIABLE_CONV`). Canonical ranked both as 0 and emitted
`ambiguous-overload`. Named `Print(..., Duration = 5.0)` never bound because
its argument was the unresolved ApplyFormat result.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: ApplyFormat(FName) selects FString overload; named Print Duration

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  class ASemaFormatPrintActor : AActor
  {
      void ShowFormatted()
      {
          Print(FString::ApplyFormat((GetName()), ">40"));
          Print("Jump was pressed!", Duration = 5.0);
      }
  }
  ```
- **Canonical facts:**
  1. `ApplyFormat(GetName(), ">40")` seals a unique Call whose first formal
     type is `FString`, not `?`.
  2. `Print(..., Duration = 5.0)` seals a named `Duration` argument.
  3. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  4. `FormatSpecifiersAndNamedPrintCompile` compiles the preprocessed f-string
     corpus through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalApplyFormatFNameSelectsFStringOverloadAndNamedPrintWithoutLegacyCompiler`
- **CodeGen/corpus test:**
  `AngelscriptNativeCanonicalASTProductionScriptCorpusTests.cpp`
  `FCanonicalASTProductionScriptCorpusTests::FormatSpecifiersAndNamedPrintCompile`
- **AST-red:** `cta-sema-call-53-applyformat-red` `20260901_083411_660_91625a75`
  **0/1 FAIL**. Seal failed `-10`. Diagnostics:
  `ambiguous-overload` then `unresolved-callee:ApplyFormat nargs=2 hits=13`
  with `hit11 params=FString,FString` and `hit12 params=?,FString`,
  `arg0=FName`. Print then failed with `arg0=<unresolved>`.
- **AST-green:** `cta-sema-call-53-applyformat-green`
  `20260901_083816_248_35e2a456` **1/1 PASS**. Equal-score ranking prefers
  fewer wildcard formals (LEGACY `asCC_TO_OBJECT_CONV` beats
  `asCC_VARIABLE_CONV`). CONSTRUCT of `FString(const FName&)` now passes the
  value-object lvalue address instead of `PushValue` of a wide VALUE.
- **CodeGen/provenance:** `cta-sema-call-53-applyformat-scriptcorpus`
  `20260901_083859_634_605b766f` **1/1 PASS**. Full ScriptCorpus
  `cta-sema-call-53-applyformat-scriptcorpus-all`
  `20260901_083957_276_4c6b634f` **18/18 PASS**.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **494/494** `cta-ast-first-sema`
  `20260901_084656_813_20df8ba9`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_084838_473_b1a20f1c`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
