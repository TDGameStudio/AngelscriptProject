# Canonical Construct dump call-argument plan (CTA-S137)

Date: 2026-09-01

## Scope

Hidden/WorldContext, mixin `IMPLICIT_RECEIVER`, and import named+default
call plans already seal. Remaining Task 5.3 constructor provenance on the
dump surface: `asCASTDump` prints `callArgs=` only for `asAST_EXPR_CALL`,
so a converting `CXXConstructExpr` analogue (`Consume(3)` → `TConv::TConv(int)`)
loses its sealed argument plan in the public dump even though the node
already has `callArguments`.

Does not check 5.3 as a whole until that dump line is green and named
prefixes pass. Does not check 5.4–5.9, 13.2, or section 10.

## Gate card: Construct dump of `TConv::TConv(int)` prints `callArgs=`

- **OpenSpec task(s):** `5.3`
- **Source fixture:** same as CTA-S134 `Consume(3)`
- **Canonical facts:**
  1. The Construct node still has one positional formal `A` (CTA-S134).
  2. The dump line `EXPR id=N kind=Construct` includes `callArgs=1`,
     `origin=positional`, and `formal=A`.
- **AST test:**
  `FCanonicalASTSemaAuthorityTests::CanonicalImplicitCtorConversionSealsConstructPlan`
- **AST-red:** `cta-sema-call-53-construct-dump-red`
  `20260901_040943_545_b28ae870` **0/1 FAIL**. Dump line was
  `EXPR id=3 kind=Construct ... nargs=1 args=3 typeKind=ValueObject` with no
  `callArgs=`.
- **AST-green:** `cta-sema-call-53-construct-dump-green`
  `20260901_041055_966_bb36e185` **1/1 PASS** after `as_ast_dump.cpp` prints
  the sealed argument plan for `asAST_EXPR_CONSTRUCT`.
- **CodeGen/provenance:** `N/A` (dump of already-sealed Sema facts)
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **493/493** `cta-ast-first-sema`
  `20260901_041135_244_e747affc`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_041310_601_6332049f`
- **Remaining boundary:** 5.3 stays `[ ]` because production Bytecode still
  reruns `asCCompiler`. 13.2 stays open. Product default stays LEGACY.
