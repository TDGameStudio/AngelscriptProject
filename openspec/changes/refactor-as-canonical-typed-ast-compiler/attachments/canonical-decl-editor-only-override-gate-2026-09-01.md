# Canonical editor-only override (CTA-S129)

Date: 2026-09-01

## Scope

Closes the remaining Task 4.5 editor-only family: a derived `override` of an
editor-only parent method that is not itself editor-only is a Sema diagnostic
over sealed Decl traits and `asSASTMethodRelation` BASE_OVERRIDE edges.
Clang maps this to availability on CXXMethodDecl; Canonical stores
`asAST_TRAIT_EDITOR_ONLY` and must not recover the fact from
`asCBuilder::IsNodeInEditorOnlyCode` walking `asCScriptNode`.

Does not check 4.6, 5.x, 13.2, or section 10.

## Gate card: editor-only parent vs non-editor override

- **OpenSpec task(s):** `4.5`
- **Source fixture:**
  ```as
  class EditorOnlyBase
  {
    void EditorHook() {}
  }
  class EditorOnlyDerived : EditorOnlyBase
  {
    void EditorHook() override {}
  }
  ```
  with Builder editor-only line range covering only `EditorOnlyBase::EditorHook`.
- **Canonical facts:**
  1. Base `EditorHook` is treated as editor-only from the copied source
     character range (Decl trait `asAST_TRAIT_EDITOR_ONLY`).
  2. Derived `EditorHook` is an override outside that range.
  3. CANONICAL Build fails closed with Sema token
     `editor-only-override-mismatch` before snapshot publication.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalDeclEditorOnlyOverrideMismatchIsSemaOwned`
- **AST-red:** `cta-sema-decl-45-editor-red`
  `Saved/Tests/cta-sema-decl-45-editor-red/20260901_021218_961_ebf6ccec`
  **1/1 FAIL**. Native CANONICAL `Build()` returned **0** with empty messages:
  editor-only line ranges never became Decl traits, and the Builder node walk
  is not on this publication path.
- **AST-green:** `cta-sema-decl-45-editor-green`
  `Saved/Tests/cta-sema-decl-45-editor-green/20260901_021635_148_547b0d75`
  **1/1 PASS**. `asCSema::ApplyEditorOnlyTraitFromSource` copies Builder
  character ranges onto sealed method traits; `ValidateEditorOnlyOverrides`
  emits `editor-only-override-mismatch` and Seal fails closed before snapshot
  publication (`GetCanonicalASTContext()` stays null).
- **CodeGen/provenance:** `N/A`
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **485/485**
  `cta-ast-first-sema` `20260901_021713_171_051d023e`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_021845_916_995b08df`.
- **Remaining boundary:** 4.6 production `Build()` shadow-mismatch fail-closed.