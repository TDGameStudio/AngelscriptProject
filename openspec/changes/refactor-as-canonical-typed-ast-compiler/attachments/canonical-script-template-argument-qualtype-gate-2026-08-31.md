# Canonical script template-argument QualType gate (CTA-S123)

Date: 2026-08-31

## Scope

Advances Task 4.3 AST-local template declaration authority: intern a host
template instance whose subtype is a current-TU script class as Clang
`TemplateSpecializationType` arguments (`QualType`s), not a Runtime
`GetTemplateInstanceType` object and not a key-string parse. Parser→Sema→Seal
only.

Does not check 4.3. Contextual lambda/funcdef inference and remaining
Builder-adapter isolation stay open. Does not check 4.4–4.6, 5.x, 13.2, or
section 10.

## Gate card: script subtype interned as template argument QualType

- **OpenSpec task(s):** `4.3` (advances; umbrella stays `[ ]`)
- **Source fixture:**
  ```as
  class LocalScript
  {
  }

  void F(TSemaScriptArgGate<LocalScript> Values)
  {
  }
  ```
  Host `TSemaScriptArgGate<class T>` is `asOBJ_REF | asOBJ_TEMPLATE |
  asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`.
- **Canonical fact:** after Parser → Sema → Seal, `Values` interned type is
  `kind=TEMPLATE`, `stableKey=TSemaScriptArgGate<LocalScript>`, one template
  argument whose interned type is `REFERENCE_OBJECT` `LocalScript` with
  `HANDLE`. `templateInstanceBuckets` is unchanged.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::SemaScriptTemplateSubtypeInternsAstLocalTemplateArguments`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.SemaScriptTemplateSubtypeInternsAstLocalTemplateArguments" -Label cta-sema-script-template-arg-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-sema-script-template-arg-red/20260901_001235_932_0f3b6118`
  `1/1 FAIL`. Parse/Seal succeeded and `templateInstanceBuckets` stayed `0`,
  but interned `TSemaScriptArgGate<LocalScript>` had empty
  `asCType::templateArguments`.
- **AST-green:**
  Same prefix, `-Label cta-sema-script-template-arg-green`
  Report: `Saved/Tests/cta-sema-script-template-arg-green/20260901_001535_475_2e317e60`
  `1/1 PASS`. Structured QualType intern now passes
  `finalArgumentTypes` into `InternCanonicalTemplateInstanceType`, which
  stores Clang-style argument QualTypes on the interned `asCType`. Identity
  remains kind + `stableKey`.
- **CodeGen/provenance:** `N/A` for this QualType-intern slice.
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-ast-first-sema -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-sema/20260901_001620_538_2d334f6e`
  **479/479 PASS**.
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label cta-ast-first-frontend -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-frontend/20260901_001812_401_8d1503ff`
  **189/189 PASS**.
- **Remaining boundary:** does not close contextual lambda/funcdef inference
  or production Builder-adapter isolation. Does not check 4.3.
