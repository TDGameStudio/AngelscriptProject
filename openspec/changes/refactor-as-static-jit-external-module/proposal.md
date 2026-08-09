## Why

StaticJIT currently treats process-local `uint32 FunctionId` values, one global registration database, and a whole-cache `DataGuid` as persistent Native identity, so generated code cannot be safely provided by an independent game module or selectively reused after Editor hot reload. The plugin needs an external project-owned provider that works in Game, Editor, and PIE, validates Native entries per function, and falls back to the current VM function whenever an entry is missing or stale.

## What Changes

- Replace persisted FunctionId/DataGuid identity with the `as-script-artifact-identity` capability established by `refactor-as-incremental-function-cache`; consume no Cache V2 pack, generation, source-policy, or reload API.
- Replace the process-global `FJITDatabase`/single `FStaticJITCompiledInfo` activation model with a versioned provider ABI, provider catalog, and engine-owned immutable route snapshots.
- Generate deterministic per-function StaticJIT slices into a project Runtime module named `<ProjectName>AngelscriptStaticJIT`, with a fixed set of translation-unit buckets.
- Provide `Scaffold`, `Generate`, and `Verify` tool modes that create and maintain the project module and register it in `.uproject` for both Game and Editor targets.
- Enable exact-match StaticJIT dispatch in Editor and PIE while keeping ordinary AngelScript source compilation, hot reload, module swap, and ClassGenerator behavior authoritative.
- Route hot-reloadable script-to-script calls through the current function route so an unchanged Native caller cannot invoke an old content-specific callee.
- Add an explicit Editor Generate/Refresh action that generates changed slices, invokes Live Coding when available, validates the patched provider generation, and atomically refreshes routes.
- Keep Live Coding optional: generation or patch failure leaves affected functions on VM without invalidating the AngelScript function cache or the remaining matching Native entries.
- Prevent UASFunction soft reload from retaining stale cached JIT entry pointers in hot-reloadable profiles; preserve immutable cooked optimizations only after complete provider-set validation.

## Capabilities

### New Capabilities

- `as-static-jit-artifact-provider`: defines the external provider ABI, per-function entry matching, engine-owned route snapshots, provider generations, and VM fallback.
- `as-static-jit-editor-routing`: defines Editor/PIE StaticJIT attachment, routed cross-function calls, explicit Live Coding refresh, safe publication, and failure behavior.
- `as-static-jit-module-scaffolding`: defines deterministic `<ProjectName>AngelscriptStaticJIT` module generation, fixed buckets, `.uproject` registration, verification, and non-overwrite behavior.

### Modified Capabilities

- `as-static-jit-aot-test`: changes AOT proof from global FunctionId/DataGuid registration to provider-manifest registration and stable per-function routing.
- `static-jit-diagnostics`: reports stable identities, provider generations, route matches/misses, fallback reasons, and execution counts rather than only global FunctionId state.
- `uasfunction-dispatch-matrix-and-jit-paths`: requires hot-reloadable UASFunction dispatch to resolve the current script function/route without retaining stale JIT pointers.

## Impact

- Primarily affects `AngelscriptRuntime/StaticJIT`, ASFunction dispatch/ClassGenerator reload integration, the AngelscriptEditor generation/Live Coding surface, StaticJIT tests, and new project-module scaffolding tooling.
- Adds a versioned Runtime public provider interface consumed by generated project modules; `AngelscriptRuntime` never depends on the project module.
- The generated project module is a Runtime/PostDefault module and is therefore eligible for both Game and Editor targets through the `.uproject` module descriptor.
- Coordinates with, but does not reuse the ABI of, `refactor-as-native-module-binding-preseal-transport`: that change serves Runtime-independent target shards, while this provider module is allowed to depend on `AngelscriptRuntime`.
- Does not make Live Coding available on unsupported platforms, generate Native code on packaged end-user machines, or replace AngelScript VM execution as the correctness fallback.
