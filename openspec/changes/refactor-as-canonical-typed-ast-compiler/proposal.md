## Implementation status (reconciled 2026-08-28)

This proposal remains the **completion contract**, not a claim that cutover is
finished. Product source compilation still defaults to LEGACY during
migration. An explicitly selected CANONICAL build publishes its supported
Bytecode through `asCBytecodeCodeGen` from a sealed AST, and public attached
and detached `CompileFunction` use the same Canonical authority boundary.

The added function-owned TypedSemantic HIR is now physically deleted: its
model/builder files, capture/configuration, function storage/accessors,
TypedASTJIT compatibility branches, Editor dump surfaces, Standalone wiring,
diagnostics and HIR-only tests are absent. `ASTBodySidecar` is the retained
default-off Cache V2 prototype and is not HIR. AngelScript's native
`asCScriptNode` syntax tree, Parser, `asCBuilder`, `asCCompiler`, and explicit
LEGACY selection remain intentionally available.

The change is still not archive-ready. Residual declaration/type/scope
identity bridges and lifetime coverage prevent complete CANONICAL Sema
independence; Canonical Bytecode and direct AOT do not yet cover the complete
language/object/exception surface; the product default and final subsystem
gates remain open. The 2026-08-28 Clang 22.1.8 review also found that lifetime
selection, verification and lowering are split across Sema, the publication
verifier, Bytecode, and an AOT-private proof.

The approved correction is the B2 lifetime architecture: Sema seals exact
action/activation/region/construction facts in a versioned Canonical lifetime
protocol; a shared deterministic, transient lifetime/control view proves
reverse live-only edge coverage; Bytecode and AOT retain backend-local cleanup
stacks, labels, slots and exception tables. The derived view is not persisted,
published, read from dumps, or used as a renamed HIR. Existing normal/transfer
cleanup statements remain during migration and are checked against the shared
view. The active exact-version Sidecar schema remains unchanged for a semantic
slice unless an AST-first RED proves that a required sealed fact cannot be
reconstructed. Accepted revisions are append-only, reject the previous schema
as an ordinary miss, and retain their RED/GREEN chronology. Review and issue
evidence:
`reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md` and
`attachments/final-completion-issue-log-2026-08-27.md`.

The 2026-08-27 type-identity review narrows a previously ambiguous boundary.
Canonical AST identity, target/runtime compatibility, generation-local Runtime
bindings, and AngelScript's public numeric `typeId` are distinct contracts.
This change owns the stable AST/detached-artifact boundary and requires all
current-Engine type resolution to complete before an atomic module-generation
publication. It does **not** make the public `typeId` deterministic or durable,
and it does not absorb a wholesale VM opcode/PrecompiledData type-relocation
rewrite. That later work requires a dedicated OpenSpec. The evidence and
scope split are recorded in
`reviews/type-identity-runtime-boundary-reconciliation-2026-08-27.md`.

The 2026-08-27 native-AST retention revision separates two previously conflated
removal targets. This change still removes the added function-owned
TypedSemantic HIR after every consumer migrates. It does **not** physically
remove AngelScript's native `asCScriptNode` syntax tree, `asCBuilder`, or
`asCCompiler`: they remain as one explicitly selected LEGACY compatibility,
reference, syntax-coverage, and rollback pipeline. CANONICAL must nevertheless
construct complete semantics through typed Parser-to-Sema actions and may not
silently fall back to, merge with, or semantically replay that native tree. A
later dedicated `retire-as-legacy-native-compiler-pipeline` OpenSpec owns any
eventual native-AST/compiler deletion. This change does not create that
follow-up. See
`attachments/legacy-native-ast-retention-scope-revision-2026-08-27.md`.

Cache V2 is now an explicitly deferred, experimental integration. It is
**disabled by default**, and its cross-Engine restore, complete AST DTO remap,
and function-granular incremental reuse are no longer completion gates for this
change. With Cache V2 disabled, authoritative `.as` source proceeds directly
through preprocessing and compilation without Cache restore, compile capture,
Hot Reload capture, or shutdown persistence. The existing sidecar/restore code
and focused tests remain as opt-in prototype assets for a later Cache V2
redesign; see `attachments/cache-v2-default-off-and-redesign-boundary-2026-08-24.md`.

## Why

The maintained AngelScript frontend currently uses a short-lived generic `asCScriptNode` tree while `asCCompiler` interleaves semantic analysis, temporary/value planning, bytecode emission, and optional typed-HIR capture. This leaves final language semantics split between transient compiler state, VM bytecode, and a function-owned sidecar HIR, so every non-bytecode backend must either preserve duplicate state or reconstruct intent after the fact.

The fork is already structurally independent from upstream and now needs one canonical typed AST and a Clang-inspired frontend boundary so Bytecode, TypedASTJIT, public analysis tools, and future lowering can consume the same verified semantics without retaining the current duplicate representation. A later Cache V2 design may consume the same snapshot contract, but the compiler cutover does not depend on it.

## What Changes

- Add an AngelScript-native, Clang-architecture frontend: `SourceManager -> Parser + Sema actions -> ASTContext -> Decl/Type/QualType/Stmt/Expr`.
- Make the sealed canonical typed AST the sole source-level semantic authority for the CANONICAL pipeline. The retained LEGACY pipeline remains a separately selected compatibility/reference implementation; Parser syntax, Canonical Sema facts, and backend state have separate lifetimes and responsibilities.
- Add a Sema-authored, verifier-authenticated, snapshot-owned Canonical lifetime protocol for exact cleanup action, activation/commit point, semantic region/phase, transfer target, construction step, and reviewed exit-kind facts. Derive edge liveness and reverse cleanup through one shared transient view; keep backend labels, slots, cleanup/EH stacks, tables, and native frame layout backend-local.
- Add a read-only Bytecode CodeGen backend over the canonical AST and migrate the current AST StaticJIT backend to the same input without expanding its existing native eligibility surface.
- Use a shadow-convergence migration inside one long-lived change: establish semantic/differential baselines, build the new frontend beside the old path, migrate consumers, keep the now-completed HIR retirement closed, make CANONICAL independently complete and then default, and remove every CANONICAL semantic dependency on the native syntax tree. Retain the native `asCScriptNode`/Builder/Compiler implementation behind explicit LEGACY selection for later removal by a dedicated change.
- Preserve current AngelScript language behavior, public embedding behavior, VM/UE observable behavior, diagnostics covered by tests, and per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback. New and legacy bytecode need not be byte-for-byte identical when behavior and versioned persistence contracts remain correct.
- Add an explicitly versioned public read-only AST V1 API based on reference-counted immutable module snapshots, opaque node/type IDs, and size/versioned POD views; never expose internal arena pointers or Engine-local semantic pointers.
- Separate snapshot-local `asASTTypeRef`, durable semantic type keys, target/profile ABI-layout compatibility, generation-local Runtime bindings, and the legacy public numeric `typeId`. A numeric `typeId` is an ephemeral projection of the current Engine generation, never canonical or persisted identity.
- Make detached canonical CodeGen artifacts describe type/property dependencies with stable symbolic identity and expected compatibility until candidate installation resolves them. Active generation bytecode may carry already-resolved pointers, offsets, slots, or public IDs only under that generation's lifetime.
- Build a module-owned AST for every source compile. Capture-off profiles may release function bodies after CodeGen; capture-on profiles retain an immutable module snapshot for Editor, StaticJIT, diagnostics, and public tooling. Cache V2 consumption is optional and default-disabled.
- Preserve the implemented pointer-free `ASTBodySidecar`/ExactStartup prototype as dormant research input. Do not require its unfinished cross-Engine remap or incremental-reuse contracts for canonical compiler cutover; redesign them in a later dedicated Cache V2 change.
- Absorb the complete intent of `refactor-as-primary-engine-typed-ast-generate`, including primary-Engine matching-profile Generate, contained non-matching generation Engines, Hot Reload freezing, native-form cataloguing, Cache restore, and dump/diagnostic behavior.
- **BREAKING**: the fork-private `TypedSemanticIR`/function-owned HIR inspection and capture surface is replaced by canonical AST snapshots and remains physically absent. This removal does not include AngelScript's native syntax AST or the explicitly selected LEGACY compiler pipeline, and no lifetime CFG/side table may recreate a function-owned HIR transport.
- Do not link or copy Clang AST/Sema, implement LLVM IR lowering, replace the entire Runtime `asCDataType/asCTypeInfo` system, make public `typeId` globally stable/hash-derived, rewrite every legacy VM opcode or PrecompiledData relocation in this change, change AngelScript language semantics, or require StaticJIT to native-emit language forms it currently rejects or falls back from.

## Capabilities

### New Capabilities

- `as-canonical-typed-ast`: Defines SourceManager, ASTContext ownership, Decl/Type/QualType/Stmt/Expr semantics, stable type identity versus ABI/runtime projections, the Canonical lifetime protocol and shared derived lifetime/control verification view, Sema construction, sealing, verification, deterministic inspection, module retention, Hot Reload leases, and the public AST V1 snapshot API.
- `as-canonical-compiler-pipeline`: Defines Parser-to-Sema actions, canonical AST/lifetime completeness, detached/read-only Bytecode CodeGen, backend-local cleanup/EH lowering, symbolic relocation and resolve-before-publication, shadow convergence, behavior parity, CANONICAL-default cutover, and strict separation from the retained explicitly selected LEGACY native-AST/compiler path.
- `as-primary-engine-typed-ast-generate`: Carries forward the absorbed primary-Engine matching-profile Generate, non-matching generation-Engine, containment, native-form catalog, and Hot Reload coordination requirements using canonical AST snapshots.

### Modified Capabilities

- `as-typed-semantic-ir`: Records the completed physical retirement of function-owned sidecar HIR, moves failure/cleanup semantics to the Canonical lifetime protocol plus a transient derived view, and forbids recreating HIR under a new lifetime/CFG name; this is independent from retaining AngelScript's native syntax AST.
- `as-typed-ast-jit-backend`: Makes TypedASTJIT consume sealed canonical AST, the verifier-authenticated lifetime protocol/shared view, and a generation-local Runtime type-resolution view while preserving its existing eligibility, dependency, routing, cleanup, exception, and fallback contracts without rerunning lifetime Sema.
- `as-incremental-script-cache`: Makes Cache V2 default-disabled, defines a true lifecycle bypass when disabled, preserves explicit opt-in for prototype tests, and removes cross-Engine restore/incremental AST reuse from this compiler change's acceptance boundary.
- `as-static-jit-backend`: Moves typed source capture/retention and generation input from sidecar HIR to canonical AST snapshots, keeps generated identity independent from generation-Engine numeric type IDs, and preserves BytecodeJIT and generation containment.
- `as-static-jit-native-call-linkage`: Carries forward the process-global stable native-form recipe catalog required when primary-Engine AST generation does not replay binds in a sibling Engine.
- `as-static-jit-aot-test`: Reuses existing HIR/TypedASTJIT semantic oracles as canonical AST, Bytecode, StaticJIT, cache, and fallback differential acceptance coverage.
- `static-jit-diagnostics`: Replaces HIR-specific capture/dump terminology with canonical AST snapshot, verification, eligibility, generation, and fallback diagnostics.

## Impact

- Maintained frontend: parser, builder, compiler, bytecode generator, script/module/function ownership, type bridge, diagnostics, and public `angelscript.h`.
- Lifetime boundary: exact Sema action/activation/region/construction facts, shared publication verification, Bytecode/AOT parity, partial-construction committed prefixes, and fail-closed unsupported exception/suspend forms.
- Runtime integration: module build policy, Hot Reload publication, default-off Cache V2 containment, and primary/generation Engine orchestration. Standalone host adaptation/final verification is deferred to a separate future OpenSpec; the maintained compiler remains standard C++ and UE-free at that boundary.
- Type identity and installation: stable AST/artifact keys remain pointer-free; ABI/layout expectations and generation-local resolved views participate in candidate validation and publication; existing embedding-facing numeric type-ID APIs remain compatible and Engine-local.
- StaticJIT: TypedASTJIT input and visitors, BytecodeJIT compatibility fallback, native-form catalogue, Provider generation, deterministic dumps, and tests.
- Public API: new versioned AST snapshot/retention surface; no public concrete node layout and no public LLVM dependency.
- Compatibility: language and observable execution compatibility remain required; bytecode/cache schema changes require explicit versions and safe misses rather than silent reinterpretation.
- Legacy retention: `asCScriptNode` remains native syntax/recovery/reference infrastructure, while the complete `asCBuilder`/`asCCompiler` function-body compiler remains available through explicit LEGACY selection in this change. CANONICAL may pass the already prepared Stage 1/2 `asCBuilder` Runtime registration/transaction shell to CodeGen, but never semantically replays its native tree, invokes `asCCompiler`, auto-falls back, or combines both publishing compilers in one build; physical retirement is deferred to a later dedicated OpenSpec.
- Planning: `refactor-as-primary-engine-typed-ast-generate` is superseded in full and will be archived with `--skip-specs` after this replacement record validates. `feature-as-typed-semantic-aot` remains the completed semantic/test baseline and is not archived by this change.
