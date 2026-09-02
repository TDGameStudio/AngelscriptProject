# Canonical Builder must not construct `asCCompiler` (CTA-S165)

Date: 2026-09-01

## Scope

Task 5.3 / 13.2 remaining sentence: Canonical Bytecode must not rerun
`asCCompiler`. Public CANONICAL `Build()` already skips
`BuildCompileCode`. Staged Builder still called
`CompileGlobalVariables` from `BuildLayoutFunctions`, and
`BuildCompileCode` / `CompileFunctions` / public Builder
`CompileFunction` constructed `asCCompiler` on restore miss.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY. Explicit LEGACY may still construct
`asCCompiler`.

## Gate card: staged factory / CompileFunction / global-init

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  const int G = 40 + 2;

  class T
  {
      int Stored = 0;
  }

  int Entry()
  {
      return G;
  }
  ```
- **Canonical facts:**
  1. Sealed AST has const `G` (folded 42), class `T`, and `Entry`.
  2. CANONICAL staged `BuildLayoutFunctions` does not construct
     `asCCompiler` (global-init).
  3. CANONICAL staged `BuildCompileCode` does not construct
     `asCCompiler` (factory / CompileFunction).
  4. Public CANONICAL `Build()` publishes CodeGen, legacy count 0,
     `Entry() == 42`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalStagedBuilderDoesNotConstructCompilerForFactoryFunctionOrGlobalInit`
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalConstGlobalAndClassFactoryExecuteWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-no-legacy-compiler-sites-red2`
  `20260901_120920_691_2a1e5c3d` **0/1 FAIL**. Seal succeeded. After
  `BuildLayoutFunctions`, `legacy=1` from `CompileGlobalVariables`.
- **AST-green:** `cta-sema-call-53-no-legacy-compiler-sites-green`
  `20260901_121141_334_1a031b34` **1/1 PASS**. CANONICAL skips
  `CompileGlobalVariables` and does not construct `asCCompiler` on
  factory / CompileFunction restore miss.
- **CodeGen/provenance:** `cta-sema-call-53-no-legacy-compiler-sites-codegen-green`
  `20260901_121228_688_dffbc76b` **1/1 PASS**. Publisher is
  Canonical CodeGen, legacy 0, `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **507/507** `cta-ast-first-sema`
  `20260901_121333_741_bbbbb93b`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_121535_901_b3fdc7b2`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **170/170**
  `cta-ast-first-prodcodegen` `20260901_121624_496_d8a83524`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining call families).
  13.2 stays `[ ]`. LEGACY `BuildCompileCode` still uses `asCCompiler`.
