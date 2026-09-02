# Canonical provenance closure audit — 2026-08-24

## Decision

Task 13.1 is complete. Its remaining recorded blocker was the real
`FAngelscriptEngine` staged primary route, which had originally paired a
canonical sidecar with Bytecode emitted by `asCCompiler`. The current Stage 3
implementation instead performs:

```text
prepared builder shells from Stage 1/2
              |
              v
      SealCanonicalAST()
              |
              v
       TakeCanonicalAST()
              |
              v
asCBytecodeCodeGen::GeneratePreparedModule()
              |
              v
CANONICAL_CODEGEN + exact AST digest + legacy count 0
```

The LEGACY branch still calls `BuildCompileCode()` explicitly. That is the
intended comparison/opt-out boundary during convergence and does not falsify
canonical provenance.

## Requirement-to-evidence audit

### Native module Build and public CompileFunction

`FCanonicalASTCutoverTests` covers canonical module Build, attached and
detached `CompileFunction`, rejected compilation, nested lambda identity,
candidate promotion, exact publisher/digest, and the legacy-construction
counter. It also verifies that LEGACY selection is observable and cannot be
mistaken for canonical publication.

Fresh result:

- `Saved/Tests/cta-131-native-cutover-audit/20260824_235448_777_53bf6686`
  — **12/12 PASS**, zero failures/skips.

### Real UE staged primary compiler

`FAngelscriptPrimaryEngineCanonicalASTGenerateTests` constructs real temporary
UE-hosted projects and drives the normal initial-compile Stage 1–4 lifecycle.
The permanent gates assert:

- the Engine selects CANONICAL for the fixture;
- the active source module publishes `CANONICAL_CODEGEN`;
- the legacy compiler invocation count is exactly zero;
- a prepared scalar global owns its canonical initializer and executes `42`;
- authored and generated constructors/factories execute through prepared
  Runtime shells;
- the generated static-class object global is default-constructed before
  ClassGenerator observes it;
- retained snapshots and matching-profile StaticJIT generation lease the
  primary generation without a sibling compilation fallback.

Fresh result:

- `Saved/Tests/cta-131-ue-primary-audit/20260824_235528_424_96c3617b`
  — **12/12 PASS**, zero failures/skips.

## Source boundary

The current staged selection is explicit in
`FAngelscriptEngine::CompileModule_Code_Stage3`: CANONICAL seals and calls
`GeneratePreparedModule`; LEGACY alone calls `BuildCompileCode`. The prepared
backend emits detached bodies and restores the original shells on failure, so
the provenance result cannot be obtained by publishing a flag beside legacy
Bytecode.

## Non-claims

This closes R01 naming/provenance. It does not close:

- Task 10.1's complete purpose matrix (Hot Reload, generation, commandlet,
  Standalone, and public compile policies still require their final combined
  gate);
- complete language/lifetime/debug CodeGen coverage;
- final production default/LEGACY isolation;
- TypedASTJIT migration or physical HIR removal;
- the final focused and All-suite cutover matrix.

Those remain independently open; closing 13.1 does not use provenance evidence
as a substitute for semantic or lifecycle parity.
