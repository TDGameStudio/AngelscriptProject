# Canonical declaration defaults, lambda body, and list-pattern factory (CTA-S126)

Date: 2026-09-01

## Scope

Starts Task 4.4 remaining declaration authority: default/named argument
ownership, lambda body attachment, and list-pattern factory Decls. Clang
ParmVarDecl owns the default Expr; CXXDefaultArgExpr / named call args refer
to those formals; lambda is a FunctionDecl with a body Block; list-factory
registration is a generated method whose structured `{repeat int}` pattern is
a Decl origin, not a Runtime node walk.

Does not check 4.5/4.6, 5.x, 13.2, or section 10. Public Runtime comparison
authority for other 4.4 families remains open if this card only seals the
combined fixture.

## Gate card: source function + lambda + list pattern seal Decl facts

- **OpenSpec task(s):** `4.4`
- **Source fixture:**
  ```as
  int F(int a, int b = 7)
  {
    return a + b;
  }

  int Entry()
  {
    TSemaDeclLambdaGate L = function()
    {
      FSemaDeclPatternBox Box = {1, 2};
      return F(a: 3);
    };
    return L();
  }
  ```
  with host `FSemaDeclPatternBox` list factory `{repeat int}`.
- **Canonical facts:**
  1. Param `b` owns authored default `7` and one int-typed init Expr.
  2. Call `F(a: 3)` seals named formal `a` and default formal `b`.
  3. The unique lambda Decl has a function-owned Block body.
  4. The list-factory Decl (`asAST_TRAIT_LIST_FACTORY`) carries structured
     origin `repeat int` from the registered `{repeat int}` pattern.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalDeclDefaultsLambdaBodyAndListPatternFactoryOrigin`
- **AST-red:** `cta-sema-decl-44-red`
  `Saved/Tests/cta-sema-decl-44-red/20260901_013009_206_b05eaca9`
  then `20260901_012821_362_1bc55f8e`. First retarget rejected script `auto`
  lambda inference; second RED showed list-factory origin empty.
- **AST-green:** `cta-sema-decl-44-green`
  `Saved/Tests/cta-sema-decl-44-green/20260901_013329_083_e8114d41`
  **1/1 PASS**. `InternNativeBehaviourList` publishes structured
  `repeat int` origin; lambda body is Decl `body`, not the first owned Block.
- **CodeGen/provenance:** `N/A` — declaration facts only.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **482/482** then **483/483** after
  CTA-S127; Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_014940_764_074d6f19`.
- **Remaining boundary:** closed together with CTA-S127 for Task 4.4.
  4.5/4.6 stay open.
