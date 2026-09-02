# Canonical Builder import identity oracle (CTA-S121)

Date: 2026-08-31

## Scope

Advances Task 4.6 beyond enum: compare LEGACY Builder imported-function
identity (owner, type, trait, source, dependency including origin module)
against a sealed Canonical import Decl without merging. Does not check 4.6.
Product default remains LEGACY.

## Gate card: Builder vs Canonical `import int F(int) from "Other"`

- **OpenSpec task(s):** `4.6`
- **Source fixture:**
  ```as
  import int F(int a) from "Other";
  ```
  Explicit import shells (`asEP_AUTOMATIC_IMPORTS=0`).
- **Canonical fact:** `asCASTShadowDiffBuilderFunctionIdentity` matches import
  `F` against Builder `asFUNC_IMPORTED` with origin `Other`. Perturbing
  Canonical parent/type/traits/range/dependencies reports `mismatch .<field>`
  and leaves Builder `F`/`int` unchanged.
- **AST test:**
  `AngelscriptNativeCanonicalASTShadowTests.cpp`
  `FCanonicalASTShadowTests::BuilderCanonicalImportIdentityMismatchFailsClosedWithoutMerging`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow.FCanonicalASTShadowTests.BuilderCanonicalImportIdentityMismatchFailsClosedWithoutMerging" -Label cta-builder-import-identity-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-import-identity-red/20260831_234422_151_1a300da6`
  `1/1 FAIL`, `diff=mismatch path=decl.range left="BuilderCanonicalImportIdentity.as:1:12" right=":0:0"`.
  LEGACY Build published the import shell; Canonical Seal found `kind=Import`
  `F`. Imported functions had no `scriptData`/`declaredAt`.
- **AST-green:**
  Same prefix, `-Label cta-builder-import-identity-green`
  Report: `Saved/Tests/cta-builder-import-identity-green/20260831_234604_982_c0860175`
  `1/1 PASS`. Builder now publishes import `scriptSectionIdx`/`declaredAt` from
  the name token and includes `importFromModule` in dependency identity.
- **CodeGen/provenance:** `N/A`
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow" -Label cta-builder-import-identity-shadow -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-import-identity-shadow/20260831_234652_205_05e866bb`
  **6/6 PASS**.
- **Remaining boundary:** production `Build()` fail-closed on mismatch. Does
  not check 4.6.
