Draft: `angelscript/metadata-image-architecture` (accepted 2026-09-11; user skipped remaining review and authorized Change creation)

# Problem

`asCMetadataImage` owns live TypeInfo/Function for Engine lifetime, scatter compile products, and a third bytecode object graph. Script compile already runs without an Engine; Image made that ownership Engine-shaped again.

# Success Criteria

- No public `asCMetadataImage` on the script-compile path.
- `asCBuilder` yields `asCCompileOutput` and `asCModuleDefinitionSet` without an Engine.
- Default `RunThrough` emits stable bytecode onto `asCScriptFunction`.
- A later unit compiles against earlier sets without Registration.
- One `asCEngineCompileRegistration` Install+Link after the DAG; runtime bytecode exists only then.
- VM `Prepare` reads Function runtime bytecode; public executable/snapshot/byte-code-image types are gone.
- Image-product NewVersion tests follow the new products; Binding Image tests may be commented.

# Evidence

- Snapshot `asCBuilder` has no Engine; DefinitionConsumer creates TypeInfo with `engine == nullptr`.
- `TakeDefinitions` moves `TUniquePtr<asCMetadataImage>`; `Options.Dependencies` is Image*.
- Link writes `asCExecutableFunction.scriptData`; Prepare looks up published executables.
- Host `CompileModules` Stage1–3 fail on purpose.

# Scope and Exclusions

In: SDK Builder products, DefinitionSet DAG, batch Registration, bytecode on Function, test rewrite for Image-as-product, comment Binding failures.

Out: BindInfo rewrite; host CompileModules/ClassGen UClass; module-wave parallelism; StableKey rename; in-flight body replace; bytecode image codec.

# Constraints

Binding stays out of implementation. `FAngelscriptModuleDesc` / `ClassDesc` are the ClassGen payload; `ScriptType` stays empty until host ClassGen. Current `type-registry` spec still describes Image as a non-retaining translator; this Change updates the script-compile side.

# Options

Forced: delete Image as a type; per-unit `asCModuleDefinitionSet`; compile all then one Registration.

# Decision and Rationale

Engine is not the compile-time type library. The missing cross-module ring after deleting Image is `asCModuleDefinitionSet`. Descriptions and the real type graph stay two products.

# Flip Condition

Require compiling a later unit only after the earlier unit is already on a live Engine (incremental host reload as the SDK default). Or require BindInfo to stop using Image in this same Change.

# Architecture, Components, and Data Flow

See `design.md`.

# Failures and Edge Cases

See `design.md` Error handling. Registration of the submitted list is all-or-nothing.

# Verification

See `design.md` Verification. Smallest proof is SDK NewVersion tests on Builder + Registration, not host CompileModules.

# OpenSpec Handoff

- Change ID: `angelscript/refactor-sdk-compile-lifecycle`
- Title: Retire MetadataImage for engine-free compile and batch registration
- Goal: Replace Image-owned TypeInfo with per-unit `asCModuleDefinitionSet`, two Builder products, and one Engine Install+Link after the compile DAG.
- Workflow: `angelscript`
- Affected capabilities: `angelscript/language/frontend/builder`, `angelscript/runtime/type-registry`, `angelscript/runtime/bytecode`, `angelscript/runtime/vm` (Prepare lookup), `angelscript/language/types/definitions` if Image is named there.
- Required artifacts: proposal, specs deltas, design, tasks.
- Task boundaries: (1) DefinitionSet + Builder Take/Dependencies without Engine; (2) CompileOutput + FAngelscript*Desc projection; (3) Emit onto Function, delete ByteCodeImage product; (4) Registration Install+Link, VM Prepare on Function; (5) rewrite Image-product tests, comment Binding failures.

# Exploration Carryover

User authorized Change creation without a separate carryover form; the following is the recommended set used as confirmed.

Talk candidates:

- `log.md` Round 8 Q21 + N1 → talk: Image’s cross-module TypeInfo holder becomes `asCModuleDefinitionSet`, not CompileOutput and not Engine.
- `log.md` Round 7 Q20 → talk: full compile never registers into Engine between units.
- `log.md` Round 5 Q15 + runtime-bytecode-timing → talk: both bytecodes on `asCScriptFunction`; runtime written only at Registration.Link.
- `log.md` Round 9 Q22–Q23 → talk: two products; ClassGen payload is existing `FAngelscript*Desc`.

Knowledge candidates:

- `findings/compile-then-batch-register.md` → knowledge: script TypeInfo is created without Engine; TypeId is -1 until Install.
- `findings/parallel-and-module-deps.md` → knowledge: SDK parallelism is body analysis inside one Builder, not a module-wave pool.

Discard: `asS` Hungarian prefix trivia; emitter vs Clang CodeGen naming (emitter stays public).
