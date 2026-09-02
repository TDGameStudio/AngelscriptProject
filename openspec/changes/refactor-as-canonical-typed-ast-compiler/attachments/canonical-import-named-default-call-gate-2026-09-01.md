# Canonical import named+default call plan (CTA-S136)

Date: 2026-09-01

## Scope

Continues Task 5.3 remaining import/mixin call-family after Hidden/WorldContext
and mixin `IMPLICIT_RECEIVER` both proved already sealed. Import dump tests
only lock `route=import` on a zero-argument `SharedValue()`. Canonical must
seal named plus default argument records on an Import callee the same way
ordinary functions do.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.

## Gate card: `SharedValue(a: 3)` on an import fills default `b=7`

- **OpenSpec task(s):** `5.3`
- **Source fixture:**
  Provider `CanonicalASTSemaImportNamedProvider`:
  ```as
  int SharedValue(int a, int b = 7)
  {
      return a + b;
  }
  ```
  Consumer:
  ```as
  import int SharedValue(int a, int b = 7) from "CanonicalASTSemaImportNamedProvider";

  int Entry()
  {
      return SharedValue(a: 3);
  }
  ```
- **Canonical facts:**
  1. One Call whose callee is `asAST_DECL_IMPORT` origin `CanonicalASTSemaImportNamedProvider`.
  2. Two `callArguments` records.
  3. Formal `a` is origin `NAMED`, source ordinal 0, authored name `a`, integer `3`.
  4. Formal `b` is origin `DEFAULT`, no source ordinal, integer `7`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalImportCallSealsNamedAndDefaultArguments`
- **AST-red:** attempted `cta-sema-call-53-import-red`
  `20260901_040748_359_36b062be` — **1/1 PASS immediately**. Characterization
  of existing CTA-S72 import named+default arrangement.
- **AST-green:** same report (already green; no production change).
- **CodeGen/provenance:** `N/A` (Sema/Seal fact)
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **493/493** `cta-ast-first-sema`
  `20260901_041135_244_e747affc`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_041310_601_6332049f`
- **Remaining boundary:** 5.3 stays `[ ]` because production Bytecode still
  reruns `asCCompiler`. Does not check 5.4–5.9, 13.2, or section 10.
