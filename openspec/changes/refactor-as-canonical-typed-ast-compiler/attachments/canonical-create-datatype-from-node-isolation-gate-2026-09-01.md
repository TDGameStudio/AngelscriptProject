# Canonical CreateDataTypeFromNode isolation gate (CTA-S125)

Date: 2026-09-01

## Scope

Closes Task 4.3 Builder-adapter isolation: CANONICAL type authority is Sema
`asCQualType`. `asCBuilder::CreateDataTypeFromNode` is a LEGACY node walk and
must not produce types on the CANONICAL script path. Parser→Sema→Seal→Stage 2
registration fills Runtime `asCDataType` from Canonical QualTypes.

Does not check 4.4–4.6, 5.x, 13.2, or section 10.

Host `Register*` APIs that parse C++ declaration strings still use the Builder
type walk on a Sema-less builder. Explicit LEGACY `asCCompiler` still walks
nodes. Those adapters remain comparison/host-entry surfaces, not CANONICAL
script type authority.

## Gate card: CANONICAL Stage 2 does not walk `CreateDataTypeFromNode`

- **OpenSpec task(s):** `4.3`
- **Source fixture:**
  ```as
  void F(int x)
  {
  }
  ```
- **Canonical fact:** after CANONICAL Stage 2 (`BuildParallelParseScripts` +
  `BuildGenerateTypes` + `BuildGenerateFunctions`) and `SealCanonicalAST()`,
  sealed `F` has one `int` parameter QualType, `CreateDataTypeFromNode`
  invocation count is 0, and legacy `asCCompiler` invocation count is 0.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalBuildDoesNotWalkCreateDataTypeFromNodeForScriptFunction`
- **AST-red:** native `asIScriptModule::Build()` already skipped registration
  (`count=0`) because it uses `BuildParallelParseScripts` only. The remaining
  walk is UE Stage 2 `ParseScripts`. Focused Stage 2 RED
  `cta-sema-create-datatype-red`
  `Saved/Tests/cta-sema-create-datatype-red/20260901_010819_417_2b7d47f6`
  failed with `count=2` (`void` return + `int` param) while the sealed graph
  already had `F(int)`.
- **AST-green:** focused `cta-sema-create-datatype-green`
  `Saved/Tests/cta-sema-create-datatype-green/20260901_011154_394_8de23667`
  **1/1 PASS**. Stage 2 fills Runtime shells from Sema QualTypes via
  `asCRuntimeTypeBridge::Resolve` + `NormalizeScriptParameterABI`. Script
  `CreateDataTypeFromNode` fail-closes when `canonicalSema` is attached.
- **CodeGen/provenance:** native CANONICAL `Build()` already published from
  sealed QualTypes. Stage 2 now uses the same QualType authority for function
  formals, globals, class/mixin properties, enums, and virtual-property
  emulated types.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **481/481**
  `cta-ast-first-sema`
  `Saved/Tests/cta-ast-first-sema/20260901_011715_678_d2dab629`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend`
  `Saved/Tests/cta-ast-first-frontend/20260901_011917_742_68f71682`.
- **Remaining boundary:** 4.4+ declaration/body umbrellas stay open. Host
  `ParseFunctionDeclaration` / `ParseDataType` remain LEGACY/host adapters.
