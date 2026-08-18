## Why

BytecodeJIT must reconstruct typed expressions, structured control flow, and call intent from VM instructions even when Static AOT generation owns the complete source build and resolved compiler semantics. Unreal AngelScript needs an opt-in `TypedASTJIT` backend that consumes a compiler-owned typed HIR while preserving BytecodeJIT as the default compatibility backend, fallback, and differential oracle.

## What Changes

- Add an optional function-owned `TypedSemanticIR`/typed-HIR sidecar built while resolved compiler state exists; raw parser AST is not retained and capture-off bytecode remains identical.
- Integrate `FAngelscriptTypedASTJIT` as the `"typed-ast"` implementation of the internal Static backend contract established by `refactor-as-unified-jit-coordinator`; the existing implementation is `FAngelscriptBytecodeJIT` with BackendId `"bytecode"`.
- Make the Editor/Commandlet orchestrator create a generation-only Engine, replay the complete target-profile Bind surface, compile the complete Provider source graph from source with capture enabled, perform descriptor-only ClassGenerator analysis, expose that complete `CompiledSourceGraph` to the backend, and restrict output through a separate `EmitModuleSet`.
- Separate test-only HIR inspection from StaticJIT generation. Compiler tests use a private test helper, and UE integration tests/developers use a dedicated `UAngelscriptHIRDumpCommandlet`; neither path is a StaticJIT backend, emits Provider/C++, performs fallback, or creates a persisted input for TypedASTJIT.
- For a real `BackendId="typed-ast"` StaticJIT request, capture HIR in memory during the generation-only Engine's single authoritative source compile and consume it synchronously; do not create a second HIR Engine or write `.hir.txt`/`.hir.json` unless a separate explicit dump request is run. `BackendId="bytecode"` keeps capture disabled.
- Contain the generation-only Engine on both success and failure: prohibit live package/route/cache ownership, DebugServer/coverage/hot-reload/test/runtime-provider services, UObject/CDO materialization, and destructive cleanup of primary-Engine globals; release only generation-owned AngelScript state and descriptor/HIR data.
- Make Editor TypedASTJIT refresh a read-only freshness gate. It may consume the current source snapshot, but if the primary Engine is stale it returns `AuthoritativeEngineStale` and asks the existing normal hot-reload path to run; it does not force-clean/recompile/reload the primary Engine and therefore does not introduce a second primary compile.
- Reject a `"typed-ast"` request against capture-off compilation with task-level `CaptureProfileMismatch`; for a correctly captured function, use per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback.
- Do not register `"dual"` as a backend. Differential tests run isolated BytecodeJIT and TypedASTJIT generations and compare both with VM.
- Generate TypedASTJIT C++ for an initial scalar/enum UFUNCTION-root slice, including typed expressions, structured control flow, exact evaluation/mutation semantics, resolved calls, exception propagation, recursion limits, and explicit execution capability gates without reading bytecode.
- Reuse the shared Static Entry Plan and backend-neutral Provider packager; backend provenance is diagnostic metadata rather than Provider identity.
- Add an explicit cross-module native-call linkage contract, reviewed exported Runtime callables/thunks, and bridge-or-fallback behavior for provider-private or unsafe calls.
- Preserve bytecode/VM as correctness oracles, retain current language rejection of source `try`/`catch`, and require explicit typed fallback for unproven object lifetime, global/import, instrumentation, cleanup, suspend, RPC, Blueprint, and virtual-routing semantics.
- Keep HIR fork-private, default-off, non-persistent, and absent from Cache V2, bytecode archives, Runtime JIT snapshots, and public `angelscript.h` ABI.

## Capabilities

### New Capabilities

- `as-typed-semantic-ir`: Defines the optional compiler-owned, host-neutral typed HIR, transaction/lifetime rules, deterministic verifier/dump, and capture-off bytecode non-interference.
- `as-typed-ast-jit-backend`: Defines `"typed-ast"` Static backend integration, generation-time capture/profile validation, strict generation-Engine containment, separation from test-only HIR dumps, UFUNCTION-root eligibility, HIR-only analysis/emission, per-function BytecodeJIT/VM fallback, and differential testing.
- `as-static-jit-native-call-linkage`: Defines which C++ targets an independently linked StaticJIT Provider may name directly and the export/header/module/bridge requirements.

### Modified Capabilities

- `as-static-jit-aot-test`: Adds independent compiler/UE HIR snapshot tests, TypedASTJIT Provider registration proof, and isolated VM/BytecodeJIT/TypedASTJIT differential execution without treating dump output as an AOT input.
- `static-jit-diagnostics`: Reports request kind plus requested/actual Static BackendId, capture profile, HIR validity, eligibility, call disposition, and typed fallback while keeping `AngelscriptHIRDump` separate from StaticJIT diagnostics.
- `uasfunction-dispatch-matrix-and-jit-paths`: Requires TypedASTJIT to reuse existing VM/raw/parameter Provider entries without bypassing Unreal virtual, event, RPC, or `ProcessEvent` routing.

## Impact

- Affects the maintained compiler fork, `AngelscriptRuntime/StaticJIT/TypedASTJIT`, the dedicated development/test HIR dump surface, generation-only Engine orchestration, ClassGenerator descriptor views, explicit native-call metadata/exports, and compiler/StaticJIT/AOT tests.
- Depends on groups 1-3 of `refactor-as-unified-jit-coordinator` for BytecodeJIT extraction, the internal Static backend contract, deterministic packaging, and no-UClass generation Engine. It does not depend on concrete Runtime JIT plugins or feed typed HIR into Runtime snapshots.
- Preserves the current Provider ABI, stable identity, one-module-one-TU layout, BytecodeJIT output, and VM route.
- Does not modify Unreal Engine source, add LLVM/SSA lowering, persist or read back HIR dumps, create an external Static backend ABI, let StaticJIT mutate the primary Editor Engine, or make every bind helper public.
