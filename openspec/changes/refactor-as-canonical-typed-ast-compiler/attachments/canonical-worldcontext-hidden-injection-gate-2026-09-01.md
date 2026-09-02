# Canonical WorldContext hidden-argument injection (CTA-S135)

Date: 2026-09-01

## Scope

Starts the remaining Task 5.3 Hidden/WorldContext sentence. Production
`Helper_FunctionSignature` stamps `hiddenArgumentIndex` on the WorldContext
formal and `hiddenArgumentDefault = "__WorldContext()"`. Clang's analogue is
an implicit argument (`CXXDefaultArgExpr` / implicit object) authored by Sema
before CodeGen. Canonical must not rank `WithWorld(3)` against a two-formal
native as if the caller supplied `WorldContext`, and must not leave the
injected slot as a default-integer or constructor-less conversion.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10. The remaining
import/mixin call-family matrix still keeps 5.3 open after this slice.

## Gate card: `WithWorld(3)` injects `__WorldContext()` as hidden formal zero

- **OpenSpec task(s):** `5.3`
- **Source fixture:**
  Native host:
  ```text
  WorldContextHost __WorldContext()
  int WithWorld(WorldContextHost WorldContext, int Visible)
  hiddenArgumentIndex = 0
  hiddenArgumentDefault = "__WorldContext()"
  ```
  Script:
  ```as
  int Entry()
  {
      return WithWorld(3);
  }
  ```
- **Canonical facts:**
  1. `WithWorld` is one Call with two `callArguments` records.
  2. Formal zero is origin `HIDDEN`, name `WorldContext`, no source ordinal.
  3. That hidden expression unwraps to `asAST_EXPR_CALL` of `__WorldContext()`.
  4. Formal one is origin `POSITIONAL`, name `Visible`, source ordinal 0, integer `3`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalWorldContextHiddenCallSealsInjectedCall`
- **AST-red:** attempted `cta-sema-call-53-worldcontext-red`
  `20260901_040208_689_a5ef281b` — **1/1 PASS immediately**. This is
  characterization of the existing intern/inject path (CTA-S72 + hidden
  formal origin), not a new Sema gap. Production-shaped
  `hiddenArgumentIndex=0` + `__WorldContext()` is already sealed.
- **AST-green:** same report (already green; no production change).
- **CodeGen/provenance:** `N/A` (Sema/Seal fact). Dump-only. The fixture
  does not assert `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, zero
  `asCCompiler` invocations, or `Entry()` executing the injected
  `__WorldContext()` host pointer.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **493/493** `cta-ast-first-sema`
  `20260901_041135_244_e747affc`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_041310_601_6332049f`
- **Remaining boundary:** mixin `IMPLICIT_RECEIVER` and import named+default
  dumps are locked by characterization fixtures in the same SemaAuthority
  file. Construct dump `callArgs=` is CTA-S137. WorldContext **execute**
  (hidden Call actually runs, publisher is CodeGen, legacy count is 0)
  remains open. 5.3 stays `[ ]`. Does not check 5.4–5.9, 13.2, or
  section 10.
