# Canonical template callback install gate (CTA-S117)

Date: 2026-08-31

## Scope

Advances Task 4.3 by publishing the already-copied
`asSCanonicalTemplateDeclarationFact::requiresRuntimeValidation` marker onto
the interned Canonical `asCType` of a template instance. Canonical Sema still
does not instantiate a Runtime template or execute the application callback.
CodeGen/binding remain responsible for fail-closed install validation.

Does not close 4.3: AST-local template declaration authority, remaining
Builder-adapter reconciliation, `PreClassData::ShadowType` residual, and
contextual lambda/funcdef inference stay open. Does not close 4.4–4.6, 5.x,
13.2, or section 10.

## Gate card: template instance seals requiresRuntimeValidation

- **OpenSpec task(s):** `4.3`, `13.2` (advances; neither umbrella is checked)
- **Source fixture:**
  ```as
  void F(TSemaCallbackGate<int> Validated, TSemaNoCallbackGate<int> Direct)
  {
  }
  ```
  Host `TSemaCallbackGate<class T>` registers `asBEHAVE_TEMPLATE_CALLBACK`.
  Host `TSemaNoCallbackGate<class T>` does not.
- **Canonical fact:** after Parser → Sema → Seal, `Validated` interned type
  `TSemaCallbackGate<int>` has `kind=TEMPLATE` and
  `requiresRuntimeValidation=true`. Control `TSemaNoCallbackGate<int>` has
  `requiresRuntimeValidation=false`. Application callback invocations stay 0
  and `templateInstanceBuckets` is unchanged.
- **AST test:**
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::SemaTemplateCallbackValidationIsSealedWithoutRuntimeInstantiation`
  reads the sealed internal context types (not dump substring).
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.SemaTemplateCallbackValidationIsSealedWithoutRuntimeInstantiation" -Label cta-sema-template-callback-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-sema-template-callback-red/20260831_224641_875_a0905865`
  `1/1 FAIL`. Parse/Seal succeeded, `callbacks=0`, buckets `0→0`, QualTypes
  interned, and `requiresRuntimeValidation` remained false.
- **AST-green:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.SemaTemplateCallbackValidationIsSealedWithoutRuntimeInstantiation" -Label cta-sema-template-callback-green -TimeoutMs 600000`
  Report: `Saved/Tests/cta-sema-template-callback-green/20260831_225107_126_1517f130`
  `1/1 PASS`. `InternCanonicalTemplateInstanceType` now copies
  `requiresRuntimeValidation` onto the interned `asCType` after QualType intern.
  The test remains permanent.
- **CodeGen/provenance:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.CanonicalBuildFailsClosedWhenTemplateCallbackRejectsInstance" -Label cta-sema-template-callback-reject -TimeoutMs 600000`
  Report: `Saved/Tests/cta-sema-template-callback-reject/20260831_225543_773_ac78f89b`
  `1/1 PASS`. CANONICAL `Build()` of `void F(TSemaRejectGate<int> Validated) {}`
  with a rejecting application callback fails closed (`code=-12` materialize
  signature) and publishes no `F`. This locks existing install fail-closed
  behaviour; no new CodeGen emission was added. Sidecar V11 does not persist
  the flag; Cache restore may reconstruct it from the live registered template
  callback at install via `GetTemplateInstanceType` (safe miss, not a V12 bump).
- **Lifecycle:** `N/A` for this AST-seal slice.
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-ast-first-sema -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-sema/20260831_225209_715_265098ad`
  **476/476 PASS**.
- **Remaining boundary:** does not close Builder-adapter reconciliation,
  script-declared templates, `PreClassData::ShadowType`, or production default
  cutover. CodeGen still materializes Runtime instances through
  `GetTemplateInstanceType` rather than consuming only the sealed flag. Does
  not check 4.3.

## Locked authority

1. Template identity stays `kind + stableKey`. The new bool is an install
   gate copied from the Sema-generation declaration snapshot.
2. Sema must not call `GetTemplateInstanceType` or the application callback
   to decide Canonical QualType identity.
3. Backends consume the sealed flag; they do not re-query
   `beh.templateCallback` for type intern identity.
