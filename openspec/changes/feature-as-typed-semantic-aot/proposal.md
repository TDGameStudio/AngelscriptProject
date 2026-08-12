## Why

StaticJIT currently follows AngelScript's bytecode-oriented JIT contract, so its C++ generator must reconstruct typed expressions, structured control flow, and call intent from VM instructions even when the AOT build has the complete AngelScript source and resolved compiler semantics. Unreal AngelScript needs an opt-in, source-semantic AOT path that can generate native bodies from a compiler-owned typed IR while preserving the proven bytecode backend as the compatibility fallback and differential oracle.

## What Changes

- Add an optional compiler-owned typed semantic HIR sidecar that is built during normal source compilation after type, conversion, overload, and call resolution; normal bytecode generation remains authoritative and byte-identical.
- Add a `Legacy`, `Semantic`, and test-only `Dual` StaticJIT backend selection at precompiled-data generation time, with `Legacy` remaining the default.
- Generate Semantic AOT C++ for an initial safe subset of ordinary scalar/enum UFUNCTION roots, covering typed expressions, structured control flow, and statically resolved calls without decoding bytecode.
- Add an explicit cross-module native-call linkage contract so generated project DLLs directly call only exported, publicly declared symbols or fully defined header-inline/template targets; existing native-form names alone are not treated as linkability proof.
- Export a reviewed scalar subset of Runtime-owned binding call targets with `ANGELSCRIPTRUNTIME_API`, or expose an exported Runtime thunk when the FBind provider/helper should remain private; do not export registrar lambdas or every binding implementation wholesale.
- Allow proven cross-DLL raw/native calls and bridge individual private or otherwise unsupported calls through the existing StaticJIT/VM call contract instead of rejecting the entire caller.
- Reject unsupported signatures or semantics with typed, source-located eligibility reasons and fall back per function to the existing bytecode StaticJIT or VM.
- Add deterministic HIR dumps, backend/fallback diagnostics, and test-only dual generation/execution that compares legacy and semantic results on isolated fixtures.
- Retain the existing bytecode StaticJIT implementation and generated entry ABI; this change contains no removal task for the legacy backend.
- Keep artifact identity, external provider ABI, fixed-bucket packaging, Editor routing, and Live Coding refresh owned by `refactor-as-static-jit-multi-provider`; Semantic AOT integrates with that provider contract after its ABI lands.

## Capabilities

### New Capabilities

- `as-typed-semantic-ir`: defines the optional compiler-owned, host-neutral, structured typed HIR, its lifetime, supported node contract, deterministic inspection, and bytecode non-interference.
- `as-semantic-aot-backend`: defines generation-time backend selection, UFUNCTION-first eligibility, HIR-to-C++ lowering, call-level bridging, typed fallback, and legacy coexistence.
- `as-static-jit-native-call-linkage`: defines which C++ binding targets an independently linked StaticJIT project module may name directly, the export/header/module metadata required, and the bridge/fallback behavior for provider-private helpers.

### Modified Capabilities

- `as-static-jit-aot-test`: adds Semantic AOT generation/registration proof and test-only legacy-versus-semantic differential execution.
- `static-jit-diagnostics`: reports selected/requested backend, actual per-function backend, HIR availability, eligibility, and typed fallback reasons.
- `uasfunction-dispatch-matrix-and-jit-paths`: requires Semantic AOT to reuse the existing VM/raw/parameter entry paths without bypassing Unreal virtual, event, or RPC routing.

## Impact

- Primarily affects the maintained AngelScript compiler fork, `AngelscriptRuntime/StaticJIT`, native-form metadata, a reviewed subset of FBind callable declarations, generation-time engine configuration, UFUNCTION descriptor lookup, and StaticJIT/compiler tests.
- Adds fork-private HIR types readable by the UE and Standalone hosts; it does not add a public `angelscript.h` ABI in this change.
- Does not persist HIR in `PrecompiledScript.Cache`, add an independent IR cache, or change the bytecode archive schema.
- Keeps RPC, BlueprintEvent, suspend/coroutine, object/reference/container signatures, and complex lifetime/exception cleanup on the legacy/VM paths in the first version.
- Does not make every `FAngelscript*Binds` provider type a public ABI. Only explicitly selected external call symbols receive an owning-module export contract; private helpers remain reachable through exported thunks or the call bridge.
- Coordinates with `refactor-as-static-jit-multi-provider` but does not duplicate its stable identity, provider registration, routing, scaffolding, or hot-refresh responsibilities.
