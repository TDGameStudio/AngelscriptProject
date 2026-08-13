## Why

The maintained fork now has lifecycle-aware JIT Bindings, stable artifact identity, Engine-local routes, and a multi-provider Static AOT registry, but `FAngelscriptStaticJIT` still combines the sole `asIJITCompiler` lifecycle with the complete bytecode-to-C++ generator. That shape blocks a second Static generator and makes optional Runtime JIT plugins mutually destructive if they independently replace `SetJITCompiler()`.

## What Changes

- Extract the current bytecode-to-C++ implementation into `StaticJIT/BytecodeJIT/FAngelscriptBytecodeJIT` without changing generated output, Provider ABI, or default behavior.
- Add an internal, per-generation-task `IAngelscriptStaticJITBackend` contract and `FAngelscriptStaticJITGenerator`; select Static backends by stable string BackendId, initially `"bytecode"` and later `"typed-ast"`.
- Add a StaticJIT generation-only Engine path that replays the complete target-profile Bind surface and compiles the complete source graph, but performs ClassGenerator descriptor analysis without creating script `UClass`, `UFunction`, CDO, or reload state.
- Keep `FAngelscriptJITGeneration` as the backend-neutral deterministic Provider packager and retain existing generation functions as bytecode-default compatibility facades.
- **BREAKING** Replace the Engine-owned `FAngelscriptStaticJIT` compiler role with one `FAngelscriptJITCoordinator`; Static generators never install an `asIJITCompiler`.
- Add an extensible Runtime JIT factory/session contract registered by optional external plugins without a dependency from `AngelscriptRuntime` to any concrete Runtime code generator.
- Add immutable Engine-local bytecode snapshots, revision-checked Runtime results, executable-code leases, explicit execution modes, and synchronous/background/first-call compile policies.
- Preserve the Static AOT provider registry as the catalog for prebuilt artifacts; Runtime-generated code remains Engine-local and is never published as an AOT Provider generation.
- Extend non-Shipping diagnostics with requested/actual Static backend, capture profile, fallback chain, Runtime policy/session state, and actual execution tier.

## Capabilities

### New Capabilities

- `as-static-jit-backend`: Internal Static generators consume one complete generation view, use stable BackendIds, return backend-neutral emitted functions, and share deterministic Provider packaging and per-function fallback.
- `as-unified-jit-coordinator`: One Engine-owned compiler coordinates Static AOT, one selected Runtime JIT backend, and VM fallback with deterministic routing and lifetime safety.
- `as-runtime-jit-backend`: Optional plugins register Engine-local backend sessions that consume immutable bytecode snapshots and return revision-bound VMEntry code leases.

### Modified Capabilities

- `static-jit-diagnostics`: Report Static backend selection/capture/fallback provenance in addition to coordinator mode, selected Runtime backend, compile state, actual tier, and current AOT diagnostics.
- `uasfunction-dispatch-matrix-and-jit-paths`: Keep Static BytecodeJIT/TypedASTJIT entries on the existing VM/Raw/Parms Provider ABI while making the Runtime-JIT VMEntry-only boundary explicit.

## Impact

- Affects `AngelscriptRuntime/StaticJIT`, project/test generation orchestration, `FAngelscriptEngine` generation configuration, the pure-analysis seam in ClassGenerator, maintained-fork JIT compiler installation, Binding/route publication, diagnostics, and StaticJIT/RuntimeJIT/UASFunction tests.
- Depends on the lifecycle, stable identity, reference-slot, current-route, and reader-lease foundations in `refactor-as-static-jit-multi-provider`.
- Establishes the Static contract consumed by `feature-as-typed-semantic-aot` and the Runtime contract consumed by `feature-as-angelsea-runtime-jit-plugin` and `feature-as-angelsea-llvm-jit-plugin`.
- Does not change Cache V2 formats, persist typed HIR, expose a public Static backend plugin ABI, or add concrete MIR/LLVM dependencies to `AngelscriptRuntime`.
