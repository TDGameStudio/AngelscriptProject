# Canonical declaration dependencies, lifecycle, and default-arg conflict (CTA-S128)

Date: 2026-09-01

## Scope

Starts Task 4.5 remaining declaration authority after inheritance/access
publication: Sema-owned class-base dependencies, generated `__InitDefaults`
lifecycle, global constant registration, and default-argument overload
conflict diagnostics. Clang records bases on CXXRecordDecl, implicit
constructors as generated CXXMethodDecl, VarDecl constants on the Decl, and
overload conflicts as Sema diagnostics rather than a parser-tree walk.

Does not check 4.6, 5.x, 13.2, or section 10. Editor-only `EDITOR` block
checks remain a later 4.5 family if this card does not cover them.

## Gate card: inheritance/global/lifecycle plus default-arg overload conflict

- **OpenSpec task(s):** `4.5`
- **Source fixture:**
  ```as
  class Base {}
  class Vault : Base
  {
    int Value;
    default Value = 7;
  }
  const int Global = 40 + 1;
  int Entry() { Vault Object; return Object.Value + Global; }
  ```
  plus a second module
  `int F(int a) { return a; } int F(int a, int b = 1) { return a + b; }`.
- **Canonical facts:**
  1. `Vault.bases` names `Base`; `Vault.dependencies` contains `Base`.
  2. Generated `__InitDefaults` is `GENERATED` with origin
     `canonical-init-defaults`.
  3. Global `Global` seals constant `41`.
  4. Default-arg overload `F(int)` vs `F(int, int = 1)` fails CANONICAL Build
     with Sema token `default-argument-overload-conflict` (not a Builder
     `asCScriptNode` walk).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalDeclInheritanceLifecycleGlobalAndDefaultArgConflict`
- **AST-red:** `cta-sema-decl-45-red`
  `Saved/Tests/cta-sema-decl-45-red/20260901_015341_123_83963602`
  **1/1 FAIL** at `ConflictModule->Build() < 0`. Inheritance/`__InitDefaults`/
  Global=41 already sealed; `F(int)` vs `F(int, int = 1)` still compiles.
- **AST-green:** `cta-sema-decl-45-green`
  `Saved/Tests/cta-sema-decl-45-green/20260901_015608_322_de96b8cd`
  **1/1 PASS**. `asCSema::ValidateDefaultArgumentOverloads` compares sealed
  formals and emits `default-argument-overload-conflict` before publication.
- **CodeGen/provenance:** `N/A`
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **484/484**
  `cta-ast-first-sema` `20260901_015933_699_bb79021c`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_020110_503_32a6e1ca`.
- **Remaining boundary:** editor-only override is closed by CTA-S129. 4.6
  production `Build()` shadow-mismatch fail-closed stays open.