# Canonical native REF method direct dispatch (CTA-S133)

Date: 2026-09-01

## Scope

Starts Task 5.3 remaining native route/ABI: a registered native method on an
`asOBJ_REF` type is a system CALLSYS target. Clang treats a non-virtual
`CXXMethodDecl` as a direct call; Canonical must not seal that call as
`VIRTUAL` merely because the owner is a reference class.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.

## Gate card: native `Host.Read()` seals `dispatch=direct`

- **OpenSpec task(s):** `5.3`
- **Source fixture:**
  native `NativeDispatchHost` (`asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`)
  with `int Read() const`, plus
  ```as
  int Entry(NativeDispatchHost Host)
  {
      return Host.Read();
  }
  ```
- **Canonical facts:**
  1. `Host.Read()` is `asAST_EXPR_CALL` of the interned native method.
  2. `receiver=` is valid.
  3. The interned method carries `asAST_TRAIT_EXTERNAL`.
  4. `callDispatch` is `asAST_CALL_DISPATCH_DIRECT`, not `VIRTUAL`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalNativeRefMethodCallSealsDirectDispatch`
- **AST-red:** `cta-sema-call-53-native-red`
  `Saved/Tests/cta-sema-call-53-native-red/20260901_033536_639_02c95689`
  **1/1 FAIL**. Production CANONICAL `Build()` of `Host.Read()` sealed
  `dispatch=virtual`. `ClassifyCallDispatch` treated every non-VALUE method as
  virtual-eligible; interned native methods had origin `int Read() const` and
  `traits=4` (`CONST_METHOD`) with no `EXTERNAL` bit.
- **AST-green:** `cta-sema-call-53-native-green`
  `Saved/Tests/cta-sema-call-53-native-green/20260901_033656_472_ca8fcaf5`
  **1/1 PASS**. Native method intern now stamps `asAST_TRAIT_EXTERNAL`.
  `ClassifyCallDispatch` seals `EXTERNAL` methods as `DIRECT`. Script-class
  virtual calls remain `VIRTUAL`. Value-object methods remain `DIRECT`.
- **CodeGen/provenance:** `N/A` (Sema/Seal fact)
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **489/489**
  `cta-ast-first-sema` `20260901_033732_702_7f687a9c`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_033856_321_e1d97aad`.
- **Remaining boundary:** constructor provenance, Hidden/WorldContext, import
  route, mixin family still keep 5.3 open. Does not check 5.4–5.9, 13.2, or
  section 10.
