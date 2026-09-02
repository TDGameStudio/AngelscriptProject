# Canonical expression const-lvalue assignability (CTA-S131)

Date: 2026-09-01

## Scope

Starts Task 5.2 remaining expression authority: assignability is a Sema
decision over sealed `asCQualType` and value category. Clang rejects
assignment through `CheckForModifiableLvalue` / `CheckAssignmentOperands`
before CodeGen; Canonical must not leave that to `asCCompiler` bytecode
emission. A declaration initializer of a `const` variable remains legal.

Does not check 5.3–5.9, 13.2, or section 10.

## Gate card: const global is not a modifiable lvalue

- **OpenSpec task(s):** `5.2`
- **Source fixture:**
  ```as
  const int X = 1;
  int Entry()
  {
      X = 2;
      return X;
  }
  ```
  plus a control module `int Y = 1; int F() { Y = 2; return Y; }` that must
  still compile.
- **Canonical facts:**
  1. `X` is a const lvalue (`asAST_QUAL_CONST`, `asAST_VALUE_LVALUE`).
  2. The later assignment is not a declaration initializer.
  3. CANONICAL `Build()` fails closed with Sema token
     `expression-not-assignable` before snapshot publication.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalExprConstLvalueIsNotAssignable`
- **AST-red:** `cta-sema-expr-52-red`
  `Saved/Tests/cta-sema-expr-52-red/20260901_030013_890_e8e846da`
  **1/1 FAIL**. `const int X = 1; X = 2;` CANONICAL `Build()` returned **0**
  with empty messages: `ActOnAssign` copies lhs QualType and never checks
  const/lvalue.
- **AST-green:** `cta-sema-expr-52-green`
  `Saved/Tests/cta-sema-expr-52-green/20260901_030128_077_8d83453b`
  **1/1 PASS**. Authored assignment that is not a declaration initializer
  fail-closes when the lhs is not a modifiable lvalue (`asAST_VALUE_LVALUE`
  and not `asAST_QUAL_CONST`). Token `expression-not-assignable`; Seal
  returns `-10` and publishes no snapshot. Mutable `Y = 2` still compiles.
- **CodeGen/provenance:** `N/A`
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **487/487**
  `cta-ast-first-sema` `20260901_030206_494_e5bc15ba`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_030347_637_a85be34d`.
- **Remaining boundary:** 5.3 call provenance / overload. Does not check 5.3–
  5.9, 13.2, or section 10.
