# Canonical PreClass ShadowType QualType gate (CTA-S122)

Date: 2026-08-31

## Scope

Advances Task 4.3 Builder/`PreClassData::ShadowType` Sema: intern the native
shadow as a Clang-style `QualType` on the Canonical native-view Decl. Implicit-
handle hosts (`asOBJ_IMPLICIT_HANDLE`) must seal `HANDLE`; bare reference hosts
must not. Parser→Sema→Seal only; no CodeGen, no `CreateDataTypeFromNode`.

Does not check 4.3. Remaining template-declaration authority, contextual
lambda/funcdef inference, and production Builder-adapter isolation stay open.
Does not check 4.4–4.6, 5.x, 13.2, or section 10.

## Gate card: PreClass ShadowType interned QualType

- **OpenSpec task(s):** `4.3` (advances; umbrella stays `[ ]`)
- **Source fixture:**
  ```as
  class DerivedHandleShadow
  {
  }

  class DerivedBareShadow
  {
  }
  ```
  Host `ShadowHandleHost` registers `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`.
  Host `ShadowBareHost` registers `asOBJ_REF | asOBJ_NOCOUNT`.
  Module `AddPreClassData` captures each as `ShadowType`.
- **Canonical fact:** after Parser → Sema → Seal, `DerivedHandleShadow` has one
  native-view base whose interned QualType is `REFERENCE_OBJECT`
  `ShadowHandleHost` with `HANDLE`. `DerivedBareShadow`'s native-view base is
  `REFERENCE_OBJECT` `ShadowBareHost` without `HANDLE`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::SemaPreClassShadowTypeInternsImplicitHandleQualType`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.SemaPreClassShadowTypeInternsImplicitHandleQualType" -Label cta-sema-shadow-qualtype-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-sema-shadow-qualtype-red/20260831_235323_268_3b98330b`
  `1/1 FAIL`. Parse/Seal succeeded and native-view bases were present, but
  `ShadowHandleHost` interned `quals=0` instead of `HANDLE`.
- **AST-green:**
  Same prefix, `-Label cta-sema-shadow-qualtype-green`
  Report: `Saved/Tests/cta-sema-shadow-qualtype-green/20260831_235429_756_87e4e62f`
  `1/1 PASS`. `ProjectCanonicalRegisteredBaseType` now copies
  `asOBJ_IMPLICIT_HANDLE` onto the interned native-view QualType.
- **CodeGen/provenance:** `N/A` for this QualType-intern slice.
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-ast-first-sema -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-sema/20260831_235509_316_a4bb2f04`
  **478/478 PASS**.
- **Remaining boundary:** does not close AST-local template declaration
  authority, contextual lambda/funcdef inference, or production default cutover.
  Does not check 4.3.

## Locked authority

1. Native-view Decl identity remains `origin=canonical-native-type-view` plus
   stable key. QualType handle bits are a separate interned fact.
2. Implicit-handle derivation uses the copied registered-declaration flags,
   not a live `asCObjectType*` or `CreateDataTypeFromNode`.
3. Bare `asOBJ_REF` hosts stay without `HANDLE`.
