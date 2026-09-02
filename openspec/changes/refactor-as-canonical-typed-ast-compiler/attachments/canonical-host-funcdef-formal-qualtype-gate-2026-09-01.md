# Canonical host-funcdef formal QualType gate (CTA-S124)

Date: 2026-09-01

## Scope

Advances Task 4.3 remaining host-funcdef type authority: project a registered
host `funcdef` as a native-view Canonical FUNCDEF Decl whose return and
formals are interned `asCQualType`s. `IsLambdaViableForFuncdef` and
`ContextualizeLambdaToFuncdef` then consume those Decls and must not consult
`asCRuntimeTypeBridge` / live `asCFuncdefType`. Parser→Sema→Seal only.

Does not check 4.3. Remaining Builder-adapter isolation for
`CreateDataTypeFromNode` stays open. Does not check 4.4–4.6, 5.x, 13.2, or
section 10.

## Gate card: host funcdef formals interned as QualTypes

- **OpenSpec task(s):** `4.3` (advances; umbrella stays `[ ]` until this card
  plus named SemaAuthority/Frontend prefixes are green)
- **Source fixture:**
  ```as
  void F()
  {
      TSemaHostFnGate Callback = function(int x)
      {
      };
  }
  ```
  Host `RegisterFuncdef("void TSemaHostFnGate(int)")`.
- **Canonical fact:** after Parser → Sema → Seal, a native-view
  `DECL_FUNCDEF` `TSemaHostFnGate` exists with interned primitive `void`
  return and one `int` formal (`quals=0`). Lambda conversion to that QualType
  is viable from the sealed Decl, not a Runtime funcdef object.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::SemaHostFuncdefInternsCanonicalFormalQualTypesWithoutRuntimeBridge`
- **AST-red:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.SemaHostFuncdefInternsCanonicalFormalQualTypesWithoutRuntimeBridge" -Label cta-sema-host-funcdef-formals-red -TimeoutMs 600000`
  Report: `Saved/Tests/cta-sema-host-funcdef-formals-red/20260901_002542_672_23515261`
  `1/1 FAIL`. Parse/Seal succeeded and the lambda interned `int x`, but there
  was no native-view `DECL_FUNCDEF` `TSemaHostFnGate`.
- **AST-green:**
  Same prefix, `-Label cta-sema-host-funcdef-formals-green`
  Report: `Saved/Tests/cta-sema-host-funcdef-formals-green/20260901_003222_854_b7ae332f`
  `1/1 PASS`. Registered funcdef facts now carry pointer-free return/formal
  QualType spellings; Sema projects a native-view FUNCDEF Decl;
  `IsLambdaViableForFuncdef` / `ContextualizeLambdaToFuncdef` /
  `BuildCallableFormalView` no longer resolve live `asCFuncdefType` through
  `asCRuntimeTypeBridge`. Indirect VAR/PARAM calls keep `argument.formal`
  empty. CodeGen skips native-view FUNCDEF Decls.
- **CodeGen/provenance:** native-view FUNCDEF is not a Bytecode publisher.
- **Lifecycle:** `N/A`
- **Focused regression:**
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-ast-first-sema -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-sema/20260901_004244_591_5b2c020a`
  **480/480 PASS**.
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label cta-ast-first-frontend -TimeoutMs 600000`
  Report: `Saved/Tests/cta-ast-first-frontend/20260901_004419_605_81d7408f`
  **189/189 PASS**.
- **Remaining boundary:** production Builder `CreateDataTypeFromNode` isolation
  and remaining 4.4+ umbrellas stay open. Does not check 4.3.
