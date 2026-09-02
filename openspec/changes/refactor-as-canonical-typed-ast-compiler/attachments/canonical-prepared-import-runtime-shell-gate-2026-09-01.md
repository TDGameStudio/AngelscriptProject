# Canonical prepared-import Runtime shell (CTA-S143)

Date: 2026-09-01

## Scope

Next Task 5.3 ProductionCodeGen remainder after CTA-S142. Prepared Stage 2
must create exactly one import Runtime shell from sealed Canonical import
QualTypes. Full CANONICAL `Build()` already seals import named+default call
plans (CTA-S136). The prepared pipeline still walked `snImport` children
through `GetParsedFunctionDetails`, which could not recover Sema QualTypes
until this card.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: Stage2 import shell from sealed `asAST_DECL_IMPORT`

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  Provider:
  ```as
  int PreparedSharedValue(int A = 1, int B = 2)
  {
      return A * 10 + B;
  }
  ```
  Consumer:
  ```as
  import int PreparedSharedValue(int A = 1, int B = 2)
      from "SemaPreparedImportProvider";

  int PreparedImportEntry()
  {
      return PreparedSharedValue(B: 7);
  }
  ```
- **Canonical facts:**
  1. `RunBuilderPipelineThroughLayout` succeeds on CANONICAL.
  2. Sealed `asAST_DECL_IMPORT` named `PreparedSharedValue` with origin
     `SemaPreparedImportProvider`.
  3. Module owns exactly one imported function shell whose
     `canonicalASTStableDeclKey` is the sealed declaration.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalPreparedImportSealsExactRuntimeShell`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::PreparedImportBindsExactShellAndExecutes`
- **AST-red:** `cta-sema-call-53-import-red` `20260901_060354_851_7477bbb2` 0/1.
  `BuildGenerateFunctions` result=-1,
  `Canonical function registration cannot recover Sema QualTypes`.
  Parser binds completed identity on `snImport`; Stage 2 looked up the inner
  `snFunction`.
- **AST-green:** `cta-sema-call-53-import-green` `20260901_061038_438_cb9dba5d` 1/1.
  `FindCanonicalParsedCallableDeclaration` falls back to parent `snImport`.
- **CodeGen/provenance:** `cta-sema-call-53-import-codegen-green`
  `20260901_061114_164_ea767737` 1/1.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **484/484** `cta-ast-first-sema`
  `20260901_061152_437_f7c1bec3`; Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_061319_387_6a74cd10`; ProductionCodeGen
  **147/149** `cta-ast-first-prodcodegen` `20260901_061357_349_e698d4a3`.
  Remaining ProductionCodeGen: imported-dependency generation, native non-POD
  getter.
- **Remaining boundary:** 5.3 stays `[ ]`. Does not check 5.4–5.9, 13.2, or
  section 10.
