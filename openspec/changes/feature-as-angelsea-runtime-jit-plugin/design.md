## Context

Angelsea demonstrates an AngelScript Runtime JIT pipeline that translates bytecode to C, compiles C through c2mir, and generates native code through MIR. Its upstream wrapper targets AngelScript 2.37/2.38 `asIJITCompilerV2`, uses upstream context/frame details, and contains experimental direct-call/fallback switches that do not match the maintained fork's `FScriptExecution`, complete Binding, Engine-local routes, or UE lifecycle.

The project already retains Angelsea only as a pinned research reference. Product code must not compile from `Reference/angelsea`, import its bundled AngelScript, or allow a plugin to replace the unified compiler. This change therefore creates a separate optional plugin that ports the useful lowering/backend pieces onto the contract delivered by `refactor-as-unified-jit-coordinator`.

The first slice is a Win64 Editor/Development feasibility implementation. It answers whether pure scalar/control-flow functions can regain useful native performance after source compilation without a C++ rebuild. It is not a claim of full AngelScript or UE semantic coverage.

## Goals / Non-Goals

**Goals:**

- Add a disabled-by-default sibling `AngelseaRuntimeJIT` plugin with BackendId `angelsea-mir`.
- Import a minimal, auditable Angelsea-derived BytecodeToC/runtime layer and pinned MIR/c2mir sources into plugin-owned ThirdParty directories.
- Compile the unified coordinator's immutable snapshot into whole-function Win64 x64 VMEntry code.
- Support the shared scalar/control-flow subset with exact VM semantics and complete-function fallback.
- Operate correctly under EagerSync, EagerBackground, and LazyFirstCall, including cancellation, stale results, active readers, and per-Engine session teardown.
- Produce differential correctness and compile/steady-state resource benchmarks against VM and available AOT tiers.

**Non-Goals:**

- Compiling from `Reference/angelsea`, using Angelsea's bundled AngelScript/fmt/tests, or preserving its public API.
- Enabling Angelsea's experimental exception/suspend/context-ignore or direct generic/native ABI hacks.
- Script/system/native/UFUNCTION calls, object/handle/reference lifetime, Raw/Parms, ResumeVM, or function-internal fallback.
- UObject, Blueprint, ClassGenerator, GC, World, Editor-aware lowering, or direct UE header use in the backend core.
- Game/Shipping packaging, platforms other than Win64 x64, or making Runtime JIT the default.

## Decisions

### The PoC is a sibling optional plugin

The planned root is `Plugins/AngelseaRuntimeJIT/` with:

- `AngelseaRuntimeJIT`: Runtime adapter/factory/session and backend integration;
- `AngelseaRuntimeJITTest`: Editor automation and benchmarks;
- `Source/ThirdParty/AngelseaDerived`: audited BytecodeToC and small runtime pieces;
- `Source/ThirdParty/MIR`: only MIR/c2mir sources required for Win64 x64 codegen.

The plugin is disabled by default and restricted to Win64 Editor/Development in the first descriptor/build rules. It depends publicly on `AngelscriptRuntime`; the core plugin has no reverse dependency. The directory is initially a normal sibling plugin so remote/submodule setup cannot block the PoC.

Alternative rejected: add MIR to `AngelscriptRuntime`. That would increase every consumer's build surface and make an experimental third-party compiler part of the core deliverable.

### Third-party sources are pinned, minimal, and attributable

The import baselines are:

- Angelsea `1d367d431cdfd7e5e51b2341312078fd40cc10a4`, BSD-2-Clause;
- MIR `3cb30b39b81b2a8d7348cd4db66f8b219a9ebee0`, MIT.

The plugin records copied files, local modifications, upstream paths, commit hashes, licenses, and compiler definitions in a provenance manifest. It imports no upstream AngelScript (`0601da...`), fmt, Catch2, nanobench, samples, or unused MIR targets/tools/tests. `Reference/angelsea` remains a read-only comparison source and is never referenced by Build.cs.

The first build probe compiles MIR with only required sources such as `mir.c`, `mir-gen.c`, `c2mir.c`, Win64 x86_64 support, and the minimal allocator/code-memory implementation. Existing Angelsea flags that remove MIR scan/bin compression/I/O may be retained only after tests prove they do not remove a required API.

### The backend ports the pipeline, not the upstream compiler wrapper

The session pipeline is:

```text
FAngelscriptRuntimeJITCompileSnapshot
  -> supported-subset scan
  -> Angelsea-derived bytecode-to-C emitter
  -> c2mir C module
  -> MIR link/optimization/code generation
  -> Win64 x64 whole-function VMEntry
  -> FAngelscriptRuntimeJITCompileResult + code lease
```

The plugin implements `IAngelscriptRuntimeJITBackendFactory` and one `IAngelscriptRuntimeJITBackendSession` per Engine. It never constructs Angelsea's `Jit`, never receives upstream `asIScriptFunction*`, and never calls `SetJITCompiler()` or `SetJITFunction()` directly.

Generated C targets a small versioned neutral Runtime JIT ABI: scalar frame access, exception status, and approved C runtime helpers. It does not include Unreal or maintained-fork private headers. The UE adapter wraps the returned native entry into the coordinator's VMEntry Binding.

The backend consumes the coordinator's normalized function profile, not source
modifiers or raw `asEFuncTrait` bits. A non-`None` receiver profile—including
`external_implicit_this` as a declared-parameter-zero alias—and an unknown
profile value are rejected before C emission in the first slice. The backend
never erases parameter zero, fabricates a native object slot, or reconstructs
a call already compiled out of bytecode. The shared rationale and tests are in
`refactor-as-unified-jit-coordinator/research/function-modifier-and-receiver-boundary.md`.

### The first subset is deliberately identical to the LLVM backend subset

Eligible functions may contain:

- `bool`, 32/64-bit signed/unsigned integer, `float`, and `double` parameters, return values, and locals;
- constants, scalar loads/stores, explicit numeric conversions, and boolean normalization;
- add/subtract/multiply/divide/modulo, bitwise operations, shifts, comparisons, and boolean logic;
- branches, loops, and `break`/`continue` bytecode control flow;
- whole-function return and maintained-fork exception reporting.

Integer divide/modulo by zero and signed minimum divided by minus one use explicit guards and produce the same script exception/result behavior as VM. Shifts, narrowing, float/integer conversion, NaN, infinities, and signed/unsigned comparisons are emitted explicitly where C semantics could differ.

Any other opcode or lifetime/call/suspend requirement rejects the entire function before c2mir. The emitter never guesses an unsupported semantic, and the first slice never resumes VM at a bytecode PC.

### Calls and host symbols are closed by default

The only external symbols available to MIR are a fixed allowlist required by the scalar ABI, such as coordinator-owned exception helpers and carefully reviewed math/memory functions. No process-wide arbitrary symbol resolver, FFI, filesystem, network, UObject lookup, or dynamic library API is exposed.

Script/system/native call opcodes are unsupported even if Angelsea upstream can lower some of them. Direct native/generic vtable simulation is explicitly disabled. A later call-bridge change must use versioned helper/reference slots supplied by the coordinator.

### Session compilation is serialized and each result owns a disposable MIR context

One backend session owns the Engine-local configuration, helper allowlist, ordered compile queue, and resource accounting. Each accepted function revision is compiled in an isolated MIR context/code arena that becomes part of the successful code lease. Because the Angelsea-derived MIR flow is not fully thread-safe, the factory advertises serialized compilation per session. EagerBackground requests use the coordinator queue; EagerSync and LazyFirstCall enter the same session lock. Different Engine sessions may compile independently.

This per-result context is intentional: MIR does not provide a reliable “unload one function from a long-lived shared context” contract, while the first slice has no JIT-to-JIT calls and therefore does not need one linked shared module. Destroying the code lease can call the matching MIR context teardown and reclaim that revision's native code. A later JIT-to-JIT/shared-module design must introduce a generation arena and memory budget explicitly rather than weakening lease ownership.

The plugin does not implement its own hot counter, task system, route table, or stale-result publication. All three policies are coordinator policy; the backend always performs one complete snapshot compile and returns a result.

### Executable memory is owned by the backend code lease

Every successful compile creates a lease that owns the complete per-result MIR context/code arena and any stable runtime state required by the entry. Unpublished or stale results immediately release the lease and tear down that context. Published code remains valid until coordinator Binding readers retire, even if a newer script revision is installed.

The first slice uses MIR's Win64 x64 code allocator only after verifying write/execute transitions and instruction-cache flushing. It must not leave general RWX pages or transfer allocation ownership to a process-global singleton.

### Correctness gates completion before performance

The plugin uses the same inline AngelScript fixture corpus as LLVM and executes each case in explicit `VMOnly` and `RuntimeOnly` Engines. Return values, exception state, and declared scalar observations must match for boundary inputs. A backend execution marker proves native code ran.

Benchmarks record compile latency, first/second-call latency for each policy, steady-state ns/op, generated code bytes, session memory, and release behavior. The PoC may complete as a technically correct feasibility result even if performance is not sufficient for productization; it remains disabled by default and records a no-go result honestly.

## Risks / Trade-offs

- **Upstream Angelsea bytecode assumptions differ from the maintained fork** → Port opcode handling against the coordinator snapshot and current StaticJIT/VM tests; never compile against upstream AngelScript internals.
- **C semantics diverge from AngelScript semantics** → Emit explicit guards/casts/helpers and require VM differential boundary tests before marking an opcode supported.
- **MIR/c2mir context is not fully thread-safe** → Serialize context creation/compilation within one Engine session and test separate sessions independently.
- **A context per compiled revision increases compile/memory overhead** → Accept the cost for the no-call PoC, measure it explicitly, and defer shared generation arenas until JIT-to-JIT calls justify them.
- **Third-party import grows or becomes unreviewable** → Keep a file-level provenance manifest, exclude unused targets/dependencies, and make upstream refresh an explicit audited task.
- **Generated C can access unintended process APIs** → Use an external-symbol allowlist and no arbitrary loader/FFI path.
- **Microbenchmarks overstate value** → Include compile/first-call/resource data and representative loop/control-flow kernels; do not change defaults from this change.

## Migration Plan

1. Land/freeze the unified Runtime backend ABI and fake-backend conformance suite.
2. Scaffold the disabled Win64 Editor plugin and compile a minimal MIR/c2mir ThirdParty probe with provenance/licenses.
3. Register an empty `angelsea-mir` factory/session and pass coordinator registration, isolation, policy, and teardown tests.
4. Port snapshot validation and the minimal scalar BytecodeToC/runtime ABI; add VM differential tests opcode family by opcode family.
5. Add c2mir/MIR code generation, code lease ownership, native-hit markers, stale-result/active-reader tests, and three-policy coverage.
6. Run the shared conformance corpus and benchmarks, publish results under the change, and decide separately whether to widen the subset.

Rollback is disabling/removing the optional plugin. The main plugin, VM, Cache V2, and Static AOT artifacts require no migration.

## Open Questions

There are no blocking first-slice decisions. JIT-to-JIT calls, system/native bridges, hot-count policies, ResumeVM, non-Windows code generation, packaging, and Shipping are deferred to separate changes after the PoC data is reviewed.
