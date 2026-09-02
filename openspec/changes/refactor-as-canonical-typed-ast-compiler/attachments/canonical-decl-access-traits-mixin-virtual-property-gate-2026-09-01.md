# Canonical declaration access, traits, mixin, and virtual-property rejection (CTA-S127)

Date: 2026-09-01

## Scope

Finishes the remaining Task 4.4 declaration families after CTA-S126:
named access-specifier Decls and permission children, method trait masks,
mixin kind/trait/origin, generated field accessors, and preservation of the
virtual-property rejection (do not restore `refactor-as-remove-autoaccessor`).

Clang mapping: `AccessSpecDecl` is a child of the record DeclContext; method
`isConst`/`isFinal`/`override` live on the method Decl; mixin is an
AngelScript FunctionDecl with `asAST_TRAIT_MIXIN`; generated Get/Set are
implicit CXXMethodDecl-shaped methods that must carry the same access as the
backing FieldDecl. Virtual-property blocks must intern no PropertyDecl.

Does not check 4.5/4.6, 5.x, 13.2, or section 10.

## Gate card: compile-seal access/traits/mixin plus virtual-property rejection

- **OpenSpec task(s):** `4.4`
- **Source fixture:**
  ```as
  class Base
  {
    int F() const { return 1; }
  }

  class Vault : Base
  {
    access Internal = private, Friend(inherited), *(readonly, editdefaults);
    access:Internal int Value;
    private int F() const final override { return Value; }
  }

  mixin int MixHelper(Vault self)
  {
    return self.F();
  }

  int Entry()
  {
    Vault Object;
    return Object.MixHelper();
  }
  ```
  plus a second module `class Broken { int Prop { get { return 1; } } }`.
- **Canonical facts:**
  1. `Internal` is an `AccessSpecifier` child of `Vault` with `PRIVATE` and
     two `AccessPermission` children (`Friend` inherited, `*` readonly+editdefaults).
  2. Field `Value` and its generated `GetValue`/`SetValue` methods all point at
     that specifier DeclId; getters/setters are `GENERATED` with `accessorKind`
     GET/SET and `accessorField == Value`.
  3. Method `Vault::F` packs `PRIVATE | CONST_METHOD | FINAL | OVERRIDE`.
  4. Mixin `MixHelper` is `asAST_DECL_MIXIN` with `asAST_TRAIT_MIXIN` and origin `Vault`.
  5. Virtual-property syntax fails compile, emits
     `TXT_VIRTUAL_PROPERTY_REMOVED`, and intern no `asAST_DECL_PROPERTY`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalDeclAccessTraitsMixinAndVirtualPropertyRejection`
- **AST-red:** `cta-sema-decl-44-remain-red`
  `Saved/Tests/cta-sema-decl-44-remain-red/20260901_014538_729_9cc08571`
  **1/1 FAIL**. Sealed graph already has `Vault::Internal` permissions, `Vault::F`
  traits `29`, mixin `MixHelper` origin `Vault`, and generated
  `GetValue`/`SetValue` accessors, but those accessors have empty
  `accessSpecifier` while field `Value` is `access=Vault::Internal#7`.
- **AST-green:** `cta-sema-decl-44-remain-green`
  `Saved/Tests/cta-sema-decl-44-remain-green/20260901_014704_039_32d4d5b4`
  **1/1 PASS**. `EnsureGeneratedAccessors` copies the backing field's
  `accessSpecifier` onto generated Get/Set methods.
- **CodeGen/provenance:** `N/A` — declaration/access facts only.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **483/483**
  `cta-ast-first-sema` `20260901_014746_098_c9cf659e`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_014940_764_074d6f19`.
- **Remaining boundary:** 4.5 conflict/editor-only/lifecycle registration and
  4.6 production shadow-mismatch fail-closed stay open.
