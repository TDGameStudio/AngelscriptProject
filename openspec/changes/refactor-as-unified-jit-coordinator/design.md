## Context

`refactor-as-static-jit-multi-provider` has already moved the maintained fork toward one lifecycle-aware `asIJITCompiler`, delayed publication of complete Bindings, stable function identity, Engine-local routes, reference slots, and active-reader retention. Its provider ABI is intentionally an AOT artifact contract: process-visible UE modules expose immutable functions that were compiled by the C++ toolchain before the process started.

Runtime compilation has different ownership. It starts from a live Engine function, may finish asynchronously after that function was replaced, owns executable memory, and must release code with the Engine/backend session that created it. Treating that code as another process-global artifact provider would blur revision ownership and unload behavior. Conversely, allowing each optional backend to install itself with `SetJITCompiler()` would make Static AOT, MIR, and LLVM mutually destructive.

The first Runtime slice targets Win64 Editor/Development, whole-function VMEntry compilation, and conservative per-function VM fallback. Static AOT remains the delivery path for reproducible packaged native code. The current bytecode-to-C++ implementation becomes `BytecodeJIT`; the later typed-semantic-HIR-to-C++ implementation becomes `TypedASTJIT`. Both are internal Static producers behind the same stable artifact route.

Current project generation creates a temporary `FAngelscriptEngine`, but it uses the ordinary initial-compile path. `CompileModules()` therefore enters `FAngelscriptClassGenerator::Setup()` and a Soft/Full Reload branch. The Engine object and Cache root are temporary, but script `UClass`/`UFunction`/CDO and reload effects are not inherently isolated. Multiple Static generators need a generation-only compilation purpose that retains complete Bind/compiler/descriptor information without materializing a second UE reflection surface.

## Goals / Non-Goals

**Goals:**

- Install exactly one JIT compiler/coordinator per `asIScriptEngine` and make all Native-tier selection Engine-local.
- Move the existing bytecode analyzer/emitter into one named `FAngelscriptBytecodeJIT` implementation before changing compiler ownership.
- Define a private Static backend contract and deterministic build-time generator that can host BytecodeJIT and TypedASTJIT without exposing a plugin ABI.
- Compile StaticJIT artifacts in a target-profile generation Engine that performs complete Bind replay and source compilation but no script UObject/class generation or reload.
- Preserve the current Static AOT provider ABI while adding a separate extensible Runtime backend factory/session ABI.
- Support deterministic execution modes and one explicitly selected Runtime backend per Engine.
- Implement synchronous eager, background eager, and first-call lazy compilation without retaining stale AngelScript pointers on workers.
- Reuse current Binding replacement, route publication, reference-slot, and reader-lease semantics for Runtime code lifetime.
- Keep bytecode lowering host-neutral and make UE integration a narrow adapter boundary.
- Make unsupported semantics, configuration errors, cancellation, staleness, and backend failure observable while VM remains correct.

**Non-Goals:**

- Changing BytecodeJIT generated C++, Provider identities, module-TU layout, or entry ABI during the extraction.
- Making Static backends externally loadable plugins or giving Static and Runtime backends a common polymorphic root.
- Persisting typed HIR in Cache V2 or enabling HIR capture in ordinary Editor/Runtime Engines.
- Persisting Runtime code in Cache V2 or publishing it as an AOT provider generation.
- Shipping/runtime-package support, executable-memory policy on other platforms, code signing, or anti-cheat integration.
- Raw/Parms Runtime entries, direct UFUNCTION/RPC invocation, ResumeVM, multiple bytecode resume labels, or function-internal VM fallback.
- Teaching a lowering backend about UObject, Blueprint, ClassGenerator, GC, World, or Editor types.
- Choosing MIR versus LLVM automatically or chaining Runtime backends per function.

## Decisions

### Static and Runtime JIT use independent contracts

Static generation and Runtime compilation have incompatible inputs, outputs, and lifetimes. `IAngelscriptStaticJITBackend` is a Runtime-module-private build-time interface. It consumes a complete synchronous generation view and returns C++ bodies plus stable references. Runtime plugins implement exported factory/session contracts, consume copied bytecode snapshots, and return executable entries plus code leases. Neither contract derives from a shared `JITBackend` base.

Static BackendId and Runtime BackendId are separate stable string value types. Static v1 reserves `"bytecode"` for the current generator and `"typed-ast"` for `FAngelscriptTypedASTJIT`. Runtime IDs remain plugin-owned. A value from one namespace is invalid in the other even when its spelling happens to match.

Alternative rejected: one generic backend interface with tagged requests/results. It would expose build-only C++ emission and Engine-local executable-memory ownership through one abstraction while every implementation rejects half the methods.

### BytecodeJIT is extracted before compiler ownership moves

`FAngelscriptBytecodeJIT` owns the current bytecode analysis, `FStaticJITContext`, opcode handlers, bind lowering, cross-function/reference analysis, and C++ entry emission. The extraction moves those responsibilities together into `StaticJIT/BytecodeJIT/`; it does not rewrite them as per-function helpers or alter generated text.

The first migration stage retains `FAngelscriptStaticJIT` as a delegating facade so mechanical file/class movement is verified independently from `asIJITCompiler` lifecycle changes. After `FAngelscriptJITCoordinator` owns function-ready/release callbacks, the class facade is removed. Existing `GenerateStaticJITProviderArtifacts(...)` overloads remain as compatibility entry points whose default BackendId is always `"bytecode"`.

Alternative rejected: move coordinator ownership and bytecode generation in one patch. The current class is large and mixes both responsibilities; a combined change would make generated-output regressions indistinguishable from lifecycle regressions.

### Static backends are per-generation-task instances

`FAngelscriptStaticJITGenerator` validates a complete generation request, creates one backend instance for that task, runs any task-wide analysis, and collects per-function outcomes. The immutable generation view deliberately separates `CompiledSourceGraph` from `EmitModuleSet`. The complete graph contains target/profile/Provider facts; every compiled module, function, type and global needed for semantic resolution; stable identities; descriptor-derived UFUNCTION roots and shared Entry Plans; artifact dependencies; external native-call descriptors; bytecode views; and optional verified typed HIR. `EmitModuleSet` limits which AS modules publish generated translation units. A backend may inspect task-local Engine/function/type/descriptor pointers only synchronously while the generation Engine lives; backend output is pointer-free and stable-identity-based.

Backends return emitted bodies/references or typed per-function dispositions. The generator owns fallback and Provider packaging. For primary `"typed-ast"`, the production chain is TypedASTJIT, then BytecodeJIT, then no Static entry/VM. `"dual"` is not a BackendId; differential tests may run two isolated generation passes and compare them.

Alternative rejected: let each backend package its own Provider. That would duplicate stable naming/manifests, prevent one module TU from containing mixed TypedASTJIT/BytecodeJIT functions, and make fallback a cross-backend dependency.

### Static generation uses a side-effect-free Engine purpose

Generation orchestration freezes target profile, primary BackendId, requested module set, and typed-HIR capture before Engine creation. It creates `FAngelscriptEngine` with explicit purpose `EAngelscriptEnginePurpose::StaticJITGeneration`; ordinary Runtime/Editor remains the default purpose. The generation Engine replays the complete sealed Bind collection into its own `asIScriptEngine`, compiles the complete source graph for the Provider domain, and performs ClassGenerator descriptor analysis sufficient to resolve script functions, UFUNCTION roots, receivers, signatures, and Entry Plans.

The generation-only path MUST NOT create script `UClass`, `UScriptStruct`, `UDelegateFunction`, `UFunction`, or CDO objects; perform Soft/Full Reload, class redirects, reinstancing, or default-object initialization; or publish routes into the current Editor Engine. ClassGenerator must expose or factor a pure descriptor-analysis seam rather than call its ordinary `Setup()`/reload lifecycle unchanged. Existing native UE reflection may be read to bind target-profile declarations and classify ABI, but no new script reflection object is materialized. Native Bind callbacks are replayed into the temporary `asIScriptEngine`; this is required per Engine, but it does not recreate native UE reflection objects.

The generated view is frozen while the temporary Engine is alive. Any backend-visible `asIScriptFunction*`, `asITypeInfo*`, descriptor, or UObject pointer is task-local and cannot appear in output or async work. Stable module/function/profile/reference identities are the only cross-Engine representation.

Alternative rejected: compile through the live Editor Engine with capture toggled in place. That would make HIR availability depend on prior Cache/source history and expose generation to Hot Reload and active world state. A child process is also deferred because descriptor-only generation provides the required isolation without IPC or another serialized IR.

### One Engine-owned coordinator is the only `asIJITCompiler`

`FAngelscriptJITCoordinator` replaces the compiler/attachment role currently held by `FAngelscriptStaticJIT` and is the only object passed to `asIScriptEngine::SetJITCompiler()`. It owns:

- function-ready/release callbacks from the maintained AngelScript fork;
- execution-tier policy and selected Runtime BackendId;
- the Engine-local Runtime compile state table;
- Runtime backend session lifetime and work queues;
- publication of revision-checked Runtime Bindings;
- coordination with current Static AOT route construction.

Static code generation remains in `FAngelscriptStaticJITGenerator` and deterministic `FAngelscriptJITGeneration` packaging. Provider matching remains in the existing provider registry/matcher. The Runtime coordinator consumes compiled Provider entries; it never instantiates BytecodeJIT or TypedASTJIT.

Alternative rejected: let a plugin replace the current compiler. One Engine supports only one `asIJITCompiler`; replacement would lose AOT attachment callbacks and make plugin load order authoritative.

Alternative rejected: make Runtime code a transient `IAngelscriptJITArtifactProvider`. AOT providers describe prebuilt process-visible generations; a Runtime result belongs to one Engine function revision and backend session.

### Runtime plugins register factories and create per-Engine sessions

`AngelscriptRuntime` exports a current-revision `IAngelscriptRuntimeJITBackendFactory` modular feature. A factory exposes stable BackendId, display name, ABI revision, supported platform/configuration, and compile concurrency. The coordinator copies and validates factory metadata, rejects duplicate BackendIds, and creates at most one `IAngelscriptRuntimeJITBackendSession` for the selected factory in each Engine.

The session owns compiler contexts and executable resources. No backend may use the process current Engine or retain a caller-owned metadata view after the compile call returns. A session declaring serialized compilation receives requests through one ordered queue; sessions for different Engines remain independent.

Backend values remain extensible identifiers rather than a core enum. Initial command-line values are `angelsea-mir` and `angelsea-llvm`, but the core contract contains no link dependency or concrete factory class for either plugin.

### Workers consume immutable compile snapshots

`FAngelscriptRuntimeJITCompileSnapshot` is constructed while the function/module graph is current and owns every value needed by the first-slice lowering:

- stable module/function identity and full function content revision;
- coordinator publication ordinal and cancellation generation;
- Runtime Entry ABI revision, target triple, pointer width, endianness, and calling convention;
- parameter/result/local scalar descriptors and stack/register layout;
- coordinator-normalized invocation/effective-receiver/profile fields that
  preserve declared-parameter versus native-object-slot ABI without exposing
  maintained-fork trait bit numbers;
- a copied bytecode stream with verified instruction boundaries and control-flow targets;
- ordered host-helper/reference tokens, never live UObject or AngelScript pointers;
- debug-only declaration/source identity used for diagnostics, not attachment.

Snapshot creation performs structural validation on the Engine thread. Backends perform their own supported-subset scan and return typed unsupported reasons. Snapshot data is not serialized, cached, or reused after the owning function revision retires.

Source modifiers are normalized at this boundary, never parsed by Runtime
backends. In particular, `external_implicit_this` remains a global function
whose declared parameter zero is both a real frame argument and the callee's
effective receiver; it never gains a second native object slot. The first
scalar slice rejects that object-receiver profile before backend invocation.
Mixin, hidden/default arguments, and compile-out behavior likewise use the
authoritative final bytecode/frame shape. See
`research/function-modifier-and-receiver-boundary.md`.

Alternative rejected: pass `asIScriptFunction*` and call `GetByteCode()` from a worker. Hot Reload or module discard may release both function and referenced metadata before background work finishes.

### Compile results are revision-bound and lease-owned

`FAngelscriptRuntimeJITCompileResult` reports `Compiled`, `Unsupported`, `Cancelled`, `Stale`, `BackendFailure`, or `InvalidInput`; a successful result also returns one whole-function VMEntry, a backend-owned `FAngelscriptRuntimeJITCodeLease`, compile latency, code size, and diagnostics.

The coordinator publishes only when BackendId, Engine lifetime, stable function identity, full content revision, Entry ABI, and cancellation generation still match. Otherwise it releases the result without exposing the entry. Published Runtime state holds the code lease alongside the Binding execution context. Replacement uses the existing immutable route/binding reader lease so in-flight calls may finish before code is reclaimed.

Backend code cannot publish directly to `asIScriptFunction`. The coordinator is the sole publication authority.

### Execution mode and Runtime backend selection are explicit

`FAngelscriptEngineConfig` gains:

```text
EAngelscriptJITExecutionMode: Auto | VMOnly | StaticAOTOnly | RuntimeOnly
FAngelscriptRuntimeJITBackendId RuntimeJITBackend
EAngelscriptRuntimeJITCompilePolicy: EagerSync | EagerBackground | LazyFirstCall
```

Process configuration accepts:

```text
-as-jit-mode=auto|vm|aot|runtime
-as-runtime-jit-backend=none|angelsea-mir|angelsea-llvm
-as-runtime-jit-compile=eager-sync|eager-background|lazy-first-call
```

Defaults are `Auto`, `none`, and `EagerSync`. `Auto` selects exact Static AOT, then the selected Runtime Binding, then VM. `VMOnly` bypasses all Native entries. `StaticAOTOnly` allows AOT then VM. `RuntimeOnly` bypasses AOT for differential tests/benchmarks and selects Runtime then VM.

An unknown mode is a configuration diagnostic and deterministically fails the
Engine closed to `VMOnly`. An unknown Runtime policy/backend or duplicate
BackendId disables Runtime compilation for that Engine without disabling an
otherwise exact Static AOT route. The coordinator never selects a backend by
plugin registration order, UE module load order, address, or display name.

### All three compile policies share one request/publication state machine

- `EagerSync`: the first authoritative route-ready safe point builds the snapshot, calls the session synchronously, validates the result, and publishes before that safe point returns. The earlier maintained-fork function-ready callback only records lifecycle state because verified stable route identity is not yet available there.
- `EagerBackground`: the first authoritative route-ready safe point publishes/retains VM, queues one snapshot, and later schedules result validation/publication at an Engine safe point.
- `LazyFirstCall`: the current route contains a coordinator-owned trigger state. The first caller atomically claims compilation, but that invocation retains and executes its VM lease. A completed result is visible only to later calls.

Concurrent triggers coalesce by stable identity plus revision. A function has at most one active request for the selected backend/policy generation. Unsupported and deterministic compile failures are memoized for that revision so every call does not retry. Backend-unavailable and transient cancellation may be retried only after a backend/configuration generation changes.

The first slice does not combine “lazy” with a second background/synchronous sub-option: LazyFirstCall compiles on the claiming call's thread, publishes safely, and lets that call continue through VM. A later change may add hot-count/background variants without changing Backend ABI.

### Runtime JIT is a whole-function VMEntry accelerator

The first Runtime Binding contains only VMEntry. Raw and Parms entries remain null, and reflected `UASFunction` dispatch continues through its current VM/context path when those entries are required. A function containing any unsupported opcode, managed lifetime, call, suspend/exception-cleanup boundary, debugger/coverage requirement, or Entry ABI mismatch receives VM for the whole function.

The VMEntry returns according to the maintained fork's whole-function completion/exception contract. There is no PC/SP continuation result and no attempt to reuse Angelsea's multi-entry ResumeVM convention.

When debugger or coverage behavior requires bytecode visibility, the coordinator suppresses Runtime entries and reports the gate. Existing Static AOT debugger behavior is not changed by this Runtime-specific rule; callers can select `VMOnly` when the whole Engine must remain interpreted.

### UE integration is a host boundary, not a lowering language

The exported backend ABI may use Runtime-owned POD/views and standard-width values, but lowering cores receive no UE headers or object models. An `AngelscriptRuntime` host adapter translates VMEntry state, stable helper/reference tokens, exception reporting, and code lease execution into current `FScriptExecution`/Binding rules.

The first-slice supported functions require no UObject or UFunction helper calls. Future call/object support must extend the versioned helper/reference ABI rather than add UE includes to backend emitters.

### Diagnostics distinguish request, availability, selection, compilation, and execution

Non-Shipping diagnostics report:

- configured execution mode, Runtime BackendId, and compile policy;
- factory/session availability and ABI compatibility;
- per-function AOT match state, Runtime request state, selected actual tier, and fallback reason;
- snapshot/result revisions, stale/cancel counts, compile latency, code size, and execution markers;
- queue/session totals and live/retired code lease counts.

Existing `as.StaticJIT.DumpDiagnostics` remains AOT-focused. A new coordinator/runtime surface may be exposed through `as.JIT.DumpDiagnostics` while the state dump adds generic JIT tables without test-only Engine APIs.

### Implementation is sequenced after the required multi-provider lifecycle gate

Implementation may begin after `refactor-as-static-jit-multi-provider` has complete Binding publication, stable reference slots, current routes, safe readers, and safe per-Provider generation publication/retirement. It does not depend on finishing AOT project scaffolding, generated buckets, Editor/PIE activation, Live Coding refresh, or packaged profiles.

`feature-as-typed-semantic-aot` depends on the Static backend contract and generation-only Engine seam from this change. It adds the function-owned optional typed HIR and `FAngelscriptTypedASTJIT`; it does not feed Runtime snapshots and does not wait for concrete Runtime plugins.

## Risks / Trade-offs

- **Coordinator refactoring overlaps an active AOT change** → Land the provider retirement gate first, keep AOT provider types intact, and stage compiler-ownership changes separately from project generation work.
- **Bytecode extraction changes generated text accidentally** → Capture current generated requests/artifacts first and require byte-for-byte parity before enabling the new backend registry.
- **A temporary Engine mutates process-global reflection** → Add an explicit generation purpose, factor descriptor analysis from reload/materialization, and test unique script reflection names remain absent before and after generation.
- **Complete Bind replay is mistaken for reusable Engine identity** → Keep all raw type/function IDs task-local and compare only stable identity across two simultaneously alive Engines.
- **Background compilation races Hot Reload** → Copy all compile input, bind every result to full identity/revision/generation, and publish only at an Engine safe point.
- **Lazy first-call adds dispatch overhead** → Store one small revision state in the Engine route, memoize terminal unsupported results, and remove the trigger after publication/retirement.
- **Executable code survives backend unload** → Require code leases and defer session/plugin unload until active readers and retired results release.
- **Runtime coverage bypasses debugging semantics** → Fail closed per function and expose the exact debugger/coverage gate in diagnostics.
- **A generic snapshot becomes another unstable IR** → Keep it private/current-revision, bytecode-oriented, non-persistent, and limited to information required for safe off-thread compilation.
- **Many configuration combinations obscure benchmarks** → Require explicit mode, backend, and policy in every Runtime JIT test/benchmark report.

## Migration Plan

1. Complete the multi-provider safe generation publication/retirement prerequisite and freeze current generated output and Binding/route behavior.
2. Extract `FAngelscriptBytecodeJIT` behind the temporary `FAngelscriptStaticJIT` facade and prove byte-for-byte output parity.
3. Add the private Static backend contract, `FAngelscriptStaticJITGenerator`, stable Static BackendIds, and bytecode-default compatibility API.
4. Add generation-only Engine compilation and pure descriptor analysis; prove complete Bind/profile information without script UObject or reload side effects.
5. Add Runtime coordinator configuration, fake factories/sessions, immutable snapshots, and the request/publication state machine while Static AOT remains the default.
6. Move `asIJITCompiler` installation/lifecycle to `FAngelscriptJITCoordinator`, then delete the old class facade.
7. Route AOT/Runtime/VM selection, diagnostics, debugger/coverage gates, and code leases through current immutable Bindings.
8. Allow TypedASTJIT and concrete MIR/LLVM changes to consume their respective contracts only after the relevant contract milestone passes.

Rollback is configuration to `VMOnly` or `RuntimeJITBackend=none`, followed by disabling the optional plugins. Static AOT provider artifacts and Cache V2 require no migration because their formats are not changed by Runtime code.

## Open Questions

There are no blocking questions for the first slice. Static IDs are `"bytecode"` and `"typed-ast"`; BytecodeJIT remains the default; TypedASTJIT capture-profile mismatch is a generation error; valid per-function TypedASTJIT gaps fall back through BytecodeJIT to VM. Hot-count compilation, Runtime Raw/Parms entries, ResumeVM, persistent native caches, packaged Runtime-JIT support, external Static plugins, and automatic backend ordering are deliberately deferred.
