# Canonical CodeGen provenance transaction — 2026-08-24

## Outcome

Canonical module Build provenance now survives the candidate-to-active module
promotion transaction. The diagnostic counter that records construction of the
legacy `asCCompiler` can no longer be lost while the final module publishes a
canonical publisher flag and sealed-AST digest.

```text
canonical Build
    |
    v
temporary candidate module
    |  publisher
    |  sealed AST digest
    |  legacy compiler invocation count
    v
PromoteCanonicalBuildCandidate
    |
    v
active module / deterministic CodeGen dump / cutover gate
```

## Root cause

`asCCompiler` already records every construction against its builder's owning
module. Canonical Build points the builder at a temporary candidate module, so
any accidental legacy compiler construction is correctly counted on that
candidate. `PromoteCanonicalBuildCandidate()` copied the final bytecode
publisher and canonical AST digest, but omitted
`lastLegacyCompilerInvocationCount`. The active module could therefore report
zero even if the candidate had entered `asCCompiler`.

## AST-first/provenance gate

- Test source:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`
- Exact method:
  `CanonicalCandidatePromotionPublishesLegacyCompilerInvocationProvenance`
- Fixture:
  an active module starts with one stale invocation, the candidate records two,
  and promotion must replace the active value with the candidate's complete
  transaction provenance.
- RED:
  `Saved/Tests/cta-canonical-provenance-promotion-red/20260824_202357_991_fb950ceb`
  — `0/1 PASS`; promotion left the stale active value instead of publishing
  the candidate count.
- GREEN:
  `Saved/Tests/cta-canonical-provenance-promotion-green/20260824_202456_421_4f9e1ac8`
  — `1/1 PASS`.

## Verification

- Runtime/plugin build:
  `Saved/Build/cta-canonical-provenance-promotion-green-build/20260824_202442_493_e2298e79`
  — PASS.
- Complete canonical cutover group:
  `Saved/Tests/cta-canonical-cutover-provenance-green/20260824_202535_661_f1a8665b`
  — `12/12 PASS`.
- Production canonical CodeGen matrix:
  `Saved/Tests/cta-production-codegen-provenance-green/20260824_202622_028_7c52130e`
  — `73/73 PASS`.

The cutover group proves that canonical-selected module Build and public
`CompileFunction` publish from `asCBytecodeCodeGen`, record a non-zero digest
of the exact sealed AST supplied to CodeGen, and retain a zero legacy compiler
invocation count. Explicit LEGACY selection still publishes
`asBYTECODE_PUBLISHER_COMPILER` and reports a non-zero count.

