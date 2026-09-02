# Canonical production shadow-mismatch fail-closed (CTA-S130)

Date: 2026-09-01

## Scope

Closes Task 4.6 remaining production publication: when sealed Canonical
declaration owner/type/trait/source/dependency identity disagrees with the
candidate Runtime function installed by Canonical CodeGen, `Build()` must fail
closed and must not merge the two graphs. Clang keeps Sema as the single
semantic authority; a CodeGen-installed function is not allowed to rewrite
sealed Decl traits. Existing Frontend Shadow oracles (CTA-S118–S121) compare
graphs off the production `Build()` path and do not count as this gate.

Does not check 5.x, 13.2, or section 10.

## Gate card: production Build fails closed on FINAL Runtime vs un-FINAL Decl

- **OpenSpec task(s):** `4.6`
- **Source fixture:**
  ```as
  int F(int a)
  {
      return a;
  }
  ```
  Unperturbed CANONICAL `Build()` of the same text must still succeed. A
  test-only seam then marks the CodeGen-installed Runtime `F` FINAL after
  Generate and before candidate promotion, leaving the sealed Canonical Decl
  without `asAST_TRAIT_FINAL`.
- **Canonical facts:**
  1. Unperturbed sealed `F` matches the installed Runtime function
     (`asCASTShadowDiffBuilderFunctionIdentity` returns `match`).
  2. Perturbing Runtime `F` to FINAL reports `mismatch .traits`.
  3. CANONICAL `Build()` returns `< 0` with token
     `shadow-declaration-mismatch`.
  4. `GetCanonicalASTContext()` stays null and the public module publishes no
     `F` (no merge of Builder/Runtime facts into Canonical, and no merge of
     Canonical facts into the published Runtime function).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalProductionBuildFailsClosedOnBuilderShadowMismatch`
- **AST-red:** `cta-sema-decl-46-red`
  `Saved/Tests/cta-sema-decl-46-red/20260901_023317_227_a1254b80`
  **1/1 FAIL**. CANONICAL `Build()` returned **0** with empty messages after
  Runtime `F` was marked FINAL: publication did not compare sealed Decl
  traits against the candidate function.
- **AST-green:** `cta-sema-decl-46-green`
  `Saved/Tests/cta-sema-decl-46-green/20260901_023809_576_e1c98d36`
  **1/1 PASS**. `asCASTValidateBuilderShadowIdentity` runs after Generate on
  the snapshot context (PrepareCanonicalASTSnapshot nulls `pending`). Token
  `shadow-declaration-mismatch`; snapshot and Runtime `F` stay unpublished.
  Production compares owner/type/trait/source. CodeGen
  `artifactDependencies` are a lowering product, not Sema Decl.dependencies.
  Overloads match by trying every same-name Canonical function until identity
  matches. Namespace owners use `ns:`; product `float` aliases `double`/
  `float64` (not `float32`).
- **CodeGen/provenance:** `N/A` — publication is refused on mismatch.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **486/486**
  `cta-ast-first-sema` `20260901_025214_805_c5a28808`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_025347_764_17a4a64c`.
- **Remaining boundary:** 5.2 expression Sema authority. This card closes 4.6
  production fail-closed. Does not check 5.x, 13.2, or section 10.
