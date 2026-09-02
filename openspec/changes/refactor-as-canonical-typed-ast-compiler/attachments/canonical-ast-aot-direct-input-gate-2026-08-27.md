# Canonical AST AOT direct-input gate — 2026-08-27

## Decision

TypedASTJIT/AST AOT directly consumes the verified sealed Canonical AST from
the authoritative source compilation. A textual or JSON AST dump is a
diagnostic projection only; it is not an artifact-generation stage, input,
cache key, success condition, or reconstruction format.

The production route is:

```text
source
  -> native Parser syntax/recovery tree
  -> typed Parser actions + Canonical Sema
  -> verify/seal Canonical ASTContext
  -> immutable snapshot lease + generation-local Runtime binding view
  -> EmitTypedASTJITFunction(ASTContext, DeclId, Shape, ...)
  -> generated C++ / Provider artifacts
```

The forbidden route is:

```text
Canonical AST -> text/JSON dump -> parse/readback -> TypedASTJIT/AOT
```

This follows the change requirements:

- `as-typed-ast-jit-backend`: TypedASTJIT lowers sealed Canonical AST and must
  not reconstruct input from Bytecode or dump files;
- `as-primary-engine-typed-ast-generate`: AST dump is separate from artifact
  generation and is not a Provider input or compilation trigger;
- `as-static-jit-aot-test`: differential tests compare maintained observable
  behavior rather than identical instruction bytes.

If a future cross-process compiler needs persistence, it requires a separately
versioned, pointer-free Canonical AST snapshot schema with stable declaration/
type identity and target/profile ABI validation. The human-readable diagnostic
dump must not silently become that ABI.

## Production/test cleanup

The AOT generation result no longer contains `TypedASTNormalizedAST`.
`AngelscriptStaticJITAotGeneration.cpp` no longer includes `as_ast_dump.h`,
dumps the scalar/probe AST, normalizes physical paths, or treats a dump as a
generation-success gate. Determinism compares Provider generation, artifact-set
digest, stable per-backend function identities, and generated C++.

The direct-input implementation compiled successfully at:

`Saved/Build/cta-aot-direct-canonical-no-dump-build/20260827_201850_394_8c34ee71/RunMetadata.json`.

Generated Canonical-only AOT output was refreshed by the commandlet, audited
for worktree/scratch/HIR leakage, and compiled at:

`Saved/Build/cta-aot-canonical-generated-baseline-build/20260827_203629_396_16a0b788/RunMetadata.json`.

## Issues exposed by the direct route

### Qualified native namespace projection

`InternParsedCall()` attempted exact `Math::...`/`FDateTime::...` scope lookup
before lazy native namespace projection. It now calls the existing idempotent
`InternNativeGlobals` projection before explicit-scope resolution. This is a
Canonical declaration-environment fix, not a Builder replay or LEGACY
fallback. Build evidence:

`Saved/Build/cta-qualified-native-scope-green-build/20260827_202650_384_879051f6/RunMetadata.json`.

### Cross-authority content hash expectation

The repeated-generation test required isolated LEGACY Bytecode and CANONICAL
TypedAST artifacts to have equal `ExecutionHash`/`DebugHash`. Those values are
exact content identities used by Provider matching; semantically equivalent
backends may emit different valid content. The test now requires non-empty
hashes and complete first-versus-second identity equality independently for
each backend. Common stable FunctionKey/profile/entry ABI and installed
Raw/VM/Parms behavior parity remain required.

The test change compiled at:

`Saved/Build/cta-aot-cross-authority-hash-green-build/20260827_205153_940_b73070a8/RunMetadata.json`.

The exact repeated-generation method completed **1/1 PASS** after two full
production-plus-twelve-isolated-backend generation passes:

`Saved/Tests/cta-aot-cross-authority-hash-green-exact/20260827_205311_123_d88ffd53/RunMetadata.json`.

One earlier command omitted the CQTest class segment and matched zero tests;
it is recorded as a selector error, not evidence:

`Saved/Tests/cta-aot-cross-authority-hash-green/20260827_205229_011_fd7e1c36/RunMetadata.json`.

## Boundary and non-claims

- Read-only AST list/dump/query/verify/diff remains supported for diagnostics.
- Cache and artifact generation ignore diagnostic dump files.
- No AST-to-HIR compatibility adapter exists; TypedSemantic HIR is physically
  retired.
- BytecodeJIT/VM remain valid independent/fallback execution routes.
- This gate does not claim final CANONICAL default cutover. CANONICAL Sema still
  has named Parser-node expression/statement/lifetime adapters that must move
  to typed actions before Tasks 10.2/10.6/10.7 can close.
- The native `asCScriptNode`/Parser/Builder/Compiler and explicit LEGACY path
  remain intentionally available for syntax/recovery/reference/differential/
  rollback use.
