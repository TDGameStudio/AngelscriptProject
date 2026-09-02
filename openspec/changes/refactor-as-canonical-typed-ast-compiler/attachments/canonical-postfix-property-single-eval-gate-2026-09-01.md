# Canonical postfix property single-evaluation (CTA-S138)

Date: 2026-09-01

## Scope

Starts Task 5.4 remaining sequencing / single-evaluation of mutation
chains. Compound `Make().Value += 1` already seals one `OpaqueValue` plus
Get/Set. Clang postfix increment of a pseudo-object is still different:
`OpaqueValueExpr` of the base, load, increment, store, result is the
original. Canonical `ActOnUnaryExpr` currently wraps a property getter in
`Unary literal=post++` and does not capture the receiver or emit Set.

Does not check 5.4 as a whole, 5.5–5.9, 13.2, or section 10.
Compiler-generated ctor init-plan and Logical/Conditional remain separate
slices. Product default stays LEGACY.

## Gate card: `Make().Value++` captures Make() once and writes SetValue

- **OpenSpec task(s):** `5.4`
- **Source fixture:**
  ```as
  class T
  {
      int Stored = 0;

      int GetValue()
      {
          return Stored;
      }

      void SetValue(int Next)
      {
          Stored = Next;
      }
  }

  T Make()
  {
      T Object;
      return Object;
  }

  int Entry()
  {
      return Make().Value++;
  }
  ```
- **Canonical facts:**
  1. The returned expression unwraps to `asAST_EXPR_SEQUENCE` with
     `literal=opaque`.
  2. That Sequence owns one `asAST_EXPR_OPAQUE_VALUE` whose child is the
     unique `Make()` Call.
  3. `GetValue` and `SetValue` both use that OpaqueValue as receiver.
  4. Dump contains exactly one `callee=Make()` Call (single evaluation).
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalPostfixPropertyIncrementSealsOpaqueSequence`
- **AST-red:** `cta-sema-54-postfix-red` `20260901_042040_525_67758e89`
  **0/1 FAIL**. Canonical CodeGen `emitterLine=4911`: leftover Unary
  `post++` on a getter Call is not a DeclRef lvalue.
- **AST-green:** `cta-sema-54-postfix-green` `20260901_042622_872_96c82bdd`
  **1/1 PASS** after `ActOnUnaryExpr` rewrites postfix `Get*` increment to a
  Sequence of OpaqueValue receiver, captured Get, Binary, Set, original.
  First SemaAuthority prefix was **493/494**
  (`SemaStructuralPostfixExprTypedActionOwnsOrderedChainWithoutScriptNode`);
  opIndex postfix stays Unary. Getter-only rewrite then **494/494**.
- **CodeGen/provenance:** `N/A` (Sema/Seal fact)
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **494/494** `cta-ast-first-sema`
  `20260901_042951_560_c3b136e8`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_043121_233_e3c7b42d`
- **Remaining boundary:** 5.4 stays `[ ]` (compiler-generated init-plan
  umbrellas and backends still rerun Sema). Does not check 5.5–5.9, 13.2,
  or section 10. Product default stays LEGACY.
