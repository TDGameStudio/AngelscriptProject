# Canonical implicit constructor conversion (CTA-S134)

Date: 2026-09-01

## Scope

Starts Task 5.3 remaining constructor provenance: Clang's converting
constructor becomes a `CXXConstructExpr` before CodeGen. Canonical must not
rank `Consume(3)` as viable and then pass `3` through a constructor-less
conversion. The sealed argument is a Construct of `TConv::TConv(int)` with a
positional formal plan.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.

## Gate card: `Consume(3)` constructs `TConv::TConv(int)`

- **OpenSpec task(s):** `5.3`
- **Source fixture:**
  ```as
  struct TConv
  {
      TConv(int A)
      {
      }
  }

  int Consume(TConv Value)
  {
      return 1;
  }

  int Entry()
  {
      return Consume(3);
  }
  ```
- **Canonical facts:**
  1. `Consume` is one Call with one argument record.
  2. That argument unwraps to `asAST_EXPR_CONSTRUCT` of `TConv::TConv(int)`.
  3. The Construct has one positional `asSASTCallArgument` for formal `A`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalImplicitCtorConversionSealsConstructPlan`
- **AST-red:** `cta-sema-call-53-ctor-red` `20260901_034447_196_7b6c0e1a`
  (1/1 FAIL, `rank0=-1` until script converting constructors were accepted)
- **AST-green:** `cta-sema-call-53-ctor-green` `20260901_034632_085_81358cbb` 1/1
- **CodeGen/provenance:** `N/A` (Sema/Seal fact)
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **490/490** then later **493/493**
  after CTA-S135–S137 fixtures; Frontend CanonicalAST **189/189**
- **Remaining boundary:** Construct dump `callArgs=` is CTA-S137. 5.3 stays
  open because production Bytecode still reruns `asCCompiler`. Does not check
  5.4–5.9, 13.2, or section 10.
