## Why

The maintained AngelScript frontend currently uses a short-lived generic `asCScriptNode` tree while `asCCompiler` interleaves semantic analysis, temporary/value planning, bytecode emission, and optional typed-HIR capture. This leaves final language semantics split between transient compiler state, VM bytecode, and a function-owned sidecar HIR, so every non-bytecode backend must either preserve duplicate state or reconstruct intent after the fact.

The fork is already structurally independent from upstream and now needs one canonical typed AST and a Clang-inspired frontend boundary so Bytecode, TypedASTJIT, Cache V2, public analysis tools, and future LLVM lowering can consume the same verified semantics without retaining the current duplicate representation.

## What Changes

- Add an AngelScript-native, Clang-architecture frontend: `SourceManager -> Parser + Sema actions -> ASTContext -> Decl/Type/QualType/Stmt/Expr`.
- Make the sealed canonical typed AST the sole source-level semantic authority. Parser syntax, Sema facts, and backend state become separate lifetimes and responsibilities.
- Add a read-only Bytecode CodeGen backend over the canonical AST and migrate the current AST StaticJIT backend to the same input without expanding its existing native eligibility surface.
- Use a shadow-convergence migration inside one long-lived change: establish semantic/differential baselines, build the new frontend beside the old path, migrate consumers, switch the production compiler, and only then remove the old `asCScriptNode` production path, sidecar HIR builder, and mixed Sema/Bytecode context.
- Preserve current AngelScript language behavior, public embedding behavior, VM/UE observable behavior, diagnostics covered by tests, and per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback. New and legacy bytecode need not be byte-for-byte identical when behavior and versioned persistence contracts remain correct.
- Add an explicitly versioned public read-only AST V1 API based on reference-counted immutable module snapshots, opaque node/type IDs, and size/versioned POD views; never expose internal arena pointers or Engine-local semantic pointers.
- Build a module-owned AST for every source compile. Capture-off profiles may release function bodies after CodeGen; capture-on profiles retain an immutable module snapshot for Editor, StaticJIT, diagnostics, and Cache V2.
- Replace the unimplemented `TypedHIRSidecar` plan with a versioned, pointer-free Cache V2 canonical-AST representation: declaration/type/source data align with existing module records and each FunctionBody may link an `ASTBodySidecar` for incremental body reuse.
- Absorb the complete intent of `refactor-as-primary-engine-typed-ast-generate`, including primary-Engine matching-profile Generate, contained non-matching generation Engines, Hot Reload freezing, native-form cataloguing, Cache restore, and dump/diagnostic behavior.
- **BREAKING**: replace the fork-private `TypedSemanticIR`/function-owned HIR inspection and capture surface with canonical AST snapshots after all production consumers and semantic tests migrate.
- Do not link or copy Clang AST/Sema, implement LLVM IR lowering, replace the entire Runtime `asCDataType/asCTypeInfo` system, change AngelScript language semantics, or require StaticJIT to native-emit language forms it currently rejects or falls back from.

## Capabilities

### New Capabilities

- `as-canonical-typed-ast`: Defines SourceManager, ASTContext ownership, Decl/Type/QualType/Stmt/Expr semantics, Sema construction, sealing, verification, deterministic inspection, module retention, Hot Reload leases, and the public AST V1 snapshot API.
- `as-canonical-compiler-pipeline`: Defines Parser-to-Sema actions, canonical AST completeness, read-only Bytecode CodeGen, shadow convergence, behavior parity, production cutover, and removal of the legacy mixed compiler path.
- `as-primary-engine-typed-ast-generate`: Carries forward the absorbed primary-Engine matching-profile Generate, non-matching generation-Engine, containment, native-form catalog, and Hot Reload coordination requirements using canonical AST snapshots.

### Modified Capabilities

- `as-typed-semantic-ir`: Replaces function-owned sidecar HIR capture and inspection with canonical AST semantics and removes the duplicate HIR representation only after all consumers migrate.
- `as-typed-ast-jit-backend`: Makes TypedASTJIT consume sealed canonical AST while preserving its existing eligibility, dependency, routing, cleanup, exception, and fallback contracts.
- `as-incremental-script-cache`: Adds canonical AST body sidecars, stable DTO reconstruction, complete verified snapshot publication, and capture-profile-aware restore without mixing AST data into VM payloads or `SaveByteCode`.
- `as-static-jit-backend`: Moves typed source capture/retention and generation input from sidecar HIR to canonical AST snapshots while preserving BytecodeJIT and generation containment.
- `as-static-jit-native-call-linkage`: Carries forward the process-global stable native-form recipe catalog required when primary-Engine AST generation does not replay binds in a sibling Engine.
- `as-static-jit-aot-test`: Reuses existing HIR/TypedASTJIT semantic oracles as canonical AST, Bytecode, StaticJIT, cache, and fallback differential acceptance coverage.
- `static-jit-diagnostics`: Replaces HIR-specific capture/dump terminology with canonical AST snapshot, verification, eligibility, generation, and fallback diagnostics.

## Impact

- Maintained frontend: parser, builder, compiler, bytecode generator, script/module/function ownership, type bridge, diagnostics, and public `angelscript.h`.
- Runtime integration: module build policy, Hot Reload publication, Cache V2 record/schema versions, primary/generation Engine orchestration, and Standalone compilation.
- StaticJIT: TypedASTJIT input and visitors, BytecodeJIT compatibility fallback, native-form catalogue, Provider generation, deterministic dumps, and tests.
- Public API: new versioned AST snapshot/retention surface; no public concrete node layout and no public LLVM dependency.
- Compatibility: language and observable execution compatibility remain required; bytecode/cache schema changes require explicit versions and safe misses rather than silent reinterpretation.
- Planning: `refactor-as-primary-engine-typed-ast-generate` is superseded in full and will be archived with `--skip-specs` after this replacement record validates. `feature-as-typed-semantic-aot` remains the completed semantic/test baseline and is not archived by this change.
