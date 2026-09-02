# Canonical imported-dependency generation (CTA-S145)

Date: 2026-09-01

## Scope

Last Task 5.3 ProductionCodeGen remainder after CTA-S144. A prepared consumer
that `ImportModule`s only the current provider must Stage-2-bind
`PreparedDependency::Payload` to that current generation, even when an older
same-nominal script type remains alive for Hot Reload.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: current imported provider shadows coexisting old type

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:** current published
  `namespace PreparedDependency { class Payload { int Padding; int Value; } }`
  plus a coexisting staged old `Payload { int Padding; }`. Consumer:
  ```as
  int PreparedImportedDependencyProbe(PreparedDependency::Payload Value)
  {
      return 42;
  }
  ```
  with `ImportModule` of only the current provider.
- **Canonical facts:**
  1. `RunBuilderPipelineThroughLayout` succeeds on CANONICAL.
  2. Probe parameter Runtime type is the current Payload, not the old one.
  3. Sealed param QualType is `REFERENCE_OBJECT` and resolves to current.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalImportedDependencySealsCurrentProviderType`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::PreparedImportedDependencyGenerationShadowsCoexistingPublishedType`
- **AST-red:** ProductionCodeGen `cta-sema-call-53-import-dep-red`
  `20260901_062904_971_da53ef61` 0/1. Stage 2 `BuildGenerateFunctions` result=-1;
  Probe published as `Unknown PreparedImportedDependencyProbe()` because
  `PreparedDependency::Payload` was engine-wide ambiguous with a coexisting
  old module type.
- **AST-green:** SemaAuthority `cta-sema-call-53-import-dep-sema-green`
  `20260901_063539_285_ebd886f7` 1/1. Registered-type snapshot skips
  historical script modules unless the current build imports them; Stage 2
  QualType recovery resolves through that imported-type authority.
- **CodeGen/provenance:** `cta-sema-call-53-import-dep-codegen-green`
  `20260901_063615_313_2341cf72` 1/1.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **486/486** `cta-ast-first-sema`
  `20260901_063651_779_c389f9ad`; Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_063823_238_d731ad3e`; ProductionCodeGen
  **149/149** `cta-ast-first-prodcodegen` `20260901_063902_755_600571a2`.
- **Remaining boundary:** 5.3 stays `[ ]`. Named ProductionCodeGen is green;
  remaining 5.3/5.4–5.9/13.2 umbrellas and product-default LEGACY still open.
  Does not check section 10.
