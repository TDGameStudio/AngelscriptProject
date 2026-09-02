# Canonical Builder class/method identity oracle (CTA-S119)

Date: 2026-08-31

## Scope

Advances Task 4.6 beyond global `F(int)`: compare LEGACY Builder class and
method identity (owner, type, trait, source, dependency) against sealed
Canonical Decls without merging. Does not check 4.6. Product default remains
LEGACY. Enum/import families remain later slices.

## Gate card: Builder vs Canonical class T and method T::M

- **OpenSpec task(s):** `4.6`
- **Source fixture:**
  ```as
  class T
  {
      int M(int a)
      {
          return a;
      }
  }
  ```
- **Canonical fact:** `asCASTShadowDiffBuilderTypeIdentity` matches class `T`;
  `asCASTShadowDiffBuilderFunctionIdentity` matches method `M` with owner
  `class:T`. Perturbing Canonical parent/type/traits/range/dependencies reports
  `mismatch .<field>` and leaves Builder `T`/`M` unchanged.
- **AST test:**
  `AngelscriptNativeCanonicalASTShadowTests.cpp`
  `FCanonicalASTShadowTests::BuilderCanonicalClassMethodIdentityMismatchFailsClosedWithoutMerging`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow.FCanonicalASTShadowTests.BuilderCanonicalClassMethodIdentityMismatchFailsClosedWithoutMerging" -Label cta-builder-class-method-identity-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-class-method-identity-red/20260831_232042_767_99d28c15`
  `1/1 FAIL`, `diff=unimplemented`. LEGACY Build published class `T` and method
  `M`; Canonical Seal found both Decls. A later implementation RED was
  `decl.range left="BuilderCanonicalClassIdentity.as:1:7" right=":0:0"`
  (`cta-builder-class-method-identity-impl/20260831_233223_535_aea85448`):
  Canonical uses the class name token; Builder already computed `r,c` at
  register but left `asCTypeInfo::declaredAt` / `scriptSectionIdx` unset.
- **AST-green:**
  Same prefix, `-Label cta-builder-class-method-identity-green`
  Report: `Saved/Tests/cta-builder-class-method-identity-green/20260831_233326_520_17153096`
  `1/1 PASS`. Builder now publishes class `scriptSectionIdx`/`declaredAt` from
  the name token. `asCASTShadowDiffBuilderTypeIdentity` compares owner/type
  (kind+stableKey+quals)/traits/range/dependencies without merging graphs.
- **CodeGen/provenance:** `N/A` — declaration-identity oracle, not Bytecode
  publication. Production still publishes LEGACY Bytecode.
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow" -Label cta-builder-class-method-identity-shadow -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-class-method-identity-shadow/20260831_233415_901_16ad3460`
  **4/4 PASS**.
- **Remaining boundary:** enum/import families; production `Build()` fail-closed
  on mismatch. Does not check 4.6.
