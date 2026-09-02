# Canonical Builder enum identity oracle (CTA-S120)

Date: 2026-08-31

## Scope

Advances Task 4.6 beyond class/method: compare LEGACY Builder enum identity
(owner, type, trait, source, dependency) against a sealed Canonical enum Decl
without merging. Does not check 4.6. Product default remains LEGACY. Import
families remain a later slice.

## Gate card: Builder vs Canonical enum E

- **OpenSpec task(s):** `4.6`
- **Source fixture:**
  ```as
  enum E
  {
      A
  }
  ```
- **Canonical fact:** `asCASTShadowDiffBuilderTypeIdentity` matches enum `E`
  against Builder `asCEnumType`. Perturbing Canonical parent/type/traits/range/
  dependencies reports `mismatch .<field>` and leaves Builder `E` unchanged.
- **AST test:**
  `AngelscriptNativeCanonicalASTShadowTests.cpp`
  `FCanonicalASTShadowTests::BuilderCanonicalEnumIdentityMismatchFailsClosedWithoutMerging`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow.FCanonicalASTShadowTests.BuilderCanonicalEnumIdentityMismatchFailsClosedWithoutMerging" -Label cta-builder-enum-identity-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-enum-identity-red/20260831_233746_939_f3696cdc`
  `1/1 FAIL`, `diff=unimplemented`. LEGACY Build published `asCEnumType` `E`;
  Canonical Seal found the enum Decl. The `asCTypeInfo` overload was a stub.
- **AST-green:**
  Same prefix, `-Label cta-builder-enum-identity-green`
  Report: `Saved/Tests/cta-builder-enum-identity-green/20260831_234014_070_2fa5c08f`
  `1/1 PASS`. Type identity now compares `asCTypeInfo` (enum and object)
  owner/type/traits/range/dependencies. Builder publishes enum
  `scriptSectionIdx`/`declaredAt` from the name token.
- **CodeGen/provenance:** `N/A`
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow" -Label cta-builder-enum-identity-shadow -TimeoutMs 600000`
  Report: `Saved/Tests/cta-builder-enum-identity-shadow/20260831_234054_280_45fcbe32`
  **5/5 PASS**.
- **Remaining boundary:** import families; production `Build()` fail-closed on
  mismatch. Does not check 4.6.
