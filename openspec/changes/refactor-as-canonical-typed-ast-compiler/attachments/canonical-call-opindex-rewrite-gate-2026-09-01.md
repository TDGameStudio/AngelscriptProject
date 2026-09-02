# Canonical opIndex call rewrite (CTA-S132)

Date: 2026-09-01

## Scope

Starts Task 5.3 remaining call provenance: overloaded `[]` is a Sema call
rewrite. Clang's `CreateOverloadedArraySubscriptExpr` publishes a
`CXXOperatorCallExpr` with an exact callee, receiver and argument plan before
CodeGen. Canonical must not leave `Values[3]` as an `Index` node that backends
reinterpret as `opIndex`. Builtin array indexing without an `opIndex`
declaration may still intern `Index`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.

## Gate card: `Values[3]` rewrites to `T::opIndex(int)`

- **OpenSpec task(s):** `5.3`
- **Source fixture:**
  ```as
  class T
  {
      int opIndex(int Index)
      {
          return Index;
      }
  }

  int Entry()
  {
      T Values;
      return Values[3];
  }
  ```
- **Canonical facts:**
  1. `Entry`'s returned expression is `asAST_EXPR_CALL`, not leftover `Index`.
  2. The callee is the exact method `T::opIndex(int)`.
  3. `receiver=` is a valid sealed expression.
  4. `callDispatch` is not `NONE`.
  5. One positional `asSASTCallArgument` owns formal `Index`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalIndexReadRewritesToOpIndexCall`
- **AST-red:** `cta-sema-call-53-red`
  `Saved/Tests/cta-sema-call-53-red/20260901_032103_922_39b00e7b`
  **1/1 FAIL**. Production CANONICAL `Build()` of `Values[3]` sealed
  `EXPR kind=Index literal=[] callee=T::opIndex(int)` with no `receiver=`,
  `callArgs`, or `dispatch`. `ActOnIndexExpr` only `SetResolvedDecl` on an
  Index node; `SetExprReceiver` / `AddCallArgument` reject `INDEX`.
- **AST-green:** `cta-sema-call-53-green`
  `Saved/Tests/cta-sema-call-53-green/20260901_032408_725_68b878e7`
  **1/1 PASS**. When `ResolveNativeIndexOp` finds `opIndex`, Sema now
  `ArrangeCallArguments` with the base as implicit receiver, `ActOnCall`, and
  `SetExprReceiver`. Compound `Make()[0] += 1` rebuilds that same Call on an
  `OpaqueValue` of the original receiver. Builtin indexing without `opIndex`
  still intern `Index`.
- **CodeGen/provenance:** `N/A` (Sema/Seal fact)
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **488/488**
  `cta-ast-first-sema` `20260901_032737_604_6b620666`;
  Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_032902_886_6e2a7b71`.
- **Remaining boundary:** constructor provenance and the complete
  import/mixin/native/Hidden/WorldContext/native-ABI family still keep 5.3
  open. Does not check 5.4–5.9, 13.2, or section 10.
