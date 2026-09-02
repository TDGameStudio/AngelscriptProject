# Canonical Builder declaration-identity oracle (CTA-S118)

Date: 2026-08-31

## Scope

Advances Task 4.6: a migration gate that compares Builder/Runtime function
identity (owner, type, trait, source, dependency) against the sealed Canonical
declaration without merging the two graphs. Production default remains LEGACY.
Does not close 4.3, 4.4, 4.5, 5.x, 13.2, or section 10.

## Gate card: Builder vs Canonical F(int) identity

- **OpenSpec task(s):** `4.6`
- **Source fixture:**
  ```as
  int F(int a)
  {
      return a;
  }
  ```
  LEGACY `Build()` publishes Builder `asCScriptFunction` facts. Parser→Sema→Seal
  publishes Canonical Decl facts for the same section text.
- **Canonical fact:** `asCASTShadowDiffBuilderFunctionIdentity` returns `match`
  for owner/type/trait/source/dependency. Perturbing Canonical parent, type,
  traits, range, or dependencies reports `mismatch .<field>` and leaves Builder
  `F`/`int` unchanged.
- **AST test:**
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTShadowTests.cpp`
  `FCanonicalASTShadowTests::BuilderCanonicalDeclarationIdentityMismatchFailsClosedWithoutMerging`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow.FCanonicalASTShadowTests.BuilderCanonicalDeclarationIdentityMismatchFailsClosedWithoutMerging" -Label cta-builder-identity-oracle-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-identity-oracle-red/20260831_230540_455_95424c8d`
  `1/1 FAIL`, `diff=unimplemented`. LEGACY Build and Canonical Seal succeeded.
  A later implementation RED was `decl.range left=...:1:5 right=...:1:1`: Canonical
  used the name token, Builder `declaredAt` uses the function-node start (return
  type). Parser now copies the return-type token offset as `beginOffset`.
- **AST-green:**
  Same prefix, `-Label cta-builder-identity-oracle-green`
  Report: `Saved/Tests/cta-builder-identity-oracle-green/20260831_231035_938_d97eaa6f`
  `1/1 PASS`.
- **CodeGen/provenance:** `N/A` — this gate is a declaration-identity oracle,
  not Bytecode publication. Production still publishes LEGACY Bytecode.
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow" -Label cta-builder-identity-oracle-shadow -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-identity-oracle-shadow/20260831_231138_978_63e28898`
  **3/3 PASS**.
  SemaAuthority after the function-range Parser change:
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-ast-first-sema -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-sema/20260831_231221_461_4e952ffd`
  **477/477 PASS**.
- **Remaining boundary:** global `F(int)` only. Class/method/enum/import
  families and production `Build()` fail-closed on mismatch are not claimed.
  Does not check 4.6.
