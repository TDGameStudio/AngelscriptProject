## Why

`AngelscriptUHTTool` only emitted direct-bind function tables into the `AngelscriptRuntime` module. Because of that, `AngelscriptHeaderSignatureResolver.HasLinkableExport` classified every `BlueprintCallable` function outside `AngelscriptRuntime` without `<MODULE>_API` / inline / constexpr visibility as `unexported-symbol`. Those entries became `ERASE_NO_FUNCTION()` stubs, forcing runtime calls through `BlueprintCallableReflectiveFallback`. Even with `FReflectiveParamCache`, comments in the code state that this path is still 3-6x slower than direct binding. The `unexported-symbol` row in `AS_FunctionTable_SkippedReasonSummary.csv` represents functions that could be direct-bound today but are blocked by link boundaries.

Verse already solves a similar engine-side problem by emitting callable thunk data into the function owner's module and using a central API in CoreUObject as the rendezvous point. AS can use the same shape, but because this plugin cannot modify engine source, the rendezvous point is UE's existing `IModularFeatures` registry in Core.

## What Changes

- **Scope correction**: the automatic safe subset explicitly excludes static `ScriptMethod` functions and class-level `ScriptMixin` projections. Those forms project a C++ parameter into script `this`; the current raw thunk bridge only passes explicit generic-call argument slots and does not inject implicit script-this. They stay on fallback/stub behavior or `cross-module-unsupported-signature` diagnostics for a follow-up.
- **AngelscriptUHTTool output shape**: keep exporter `ModuleName="AngelscriptRuntime"` as required by UE UHT plugin exporters, but build cross-module output paths explicitly from target `UhtModule.Module.OutputDirectory` and `CommitOutput(...)`. Each target module emits `AS_FunctionTable_<Module>_CrossModule_*.cpp` under its own OutputDirectory, preserving the `AS_FunctionTable_*.cpp` prefix so engine CodeGen culling does not delete it.
- **Cross-module rendezvous via `IModularFeatures` (Core)**: each emitted cpp registers a POD-payload feature named `"AngelscriptCrossModuleBindings"` at DLL load. AS Runtime gathers them at `EOrder::Late + 60` without linking any engine module, and handles later modules via `OnModularFeatureRegistered`.
- **Cross-module ABI**: add public runtime header `UHT/AngelscriptCrossModuleBindings.h` with `FAngelscriptCrossModuleEntry`, layout reader, `LayoutVersionExpected`, and double-ended `static_assert` checks. Emitted engine-module cpp files use generator-emitted matching layout, not the runtime header, so engine modules do not depend on `AngelscriptRuntime`.
- **Raw thunk signature**: emitted thunks are `void(*)(UObject* Self, void** Args, void* Ret)`. They include only `Features/IModularFeatures.h` and target class headers, not `angelscript.h` or AS Runtime headers. AS Runtime owns the single generic hook that bridges `asIScriptGeneric*` to raw buffers.
- **Runtime injection**: add `Bind_CrossModuleDirect.cpp`; at `EOrder::Late + 60`, read all `"AngelscriptCrossModuleBindings"` features, validate layout/version/payload, register the generic hook, and fill empty `FAngelscriptBinds::ClassFuncMaps` slots. Late feature registration is marshaled to GameThread.
- **HasLinkableExport narrowing**: "cross-module + no API macro" no longer automatically means `unexported-symbol`. Safe signatures become `CrossModule`; recognized-but-deferred signatures become `cross-module-unsupported-signature`; disabled modules become `target-module-disabled`; RPC/Net functions become `rpc-net-function`.
- **RPC / Net functions stay reflective**: functions with `FUNC_Net | FUNC_NetServer | FUNC_NetClient | FUNC_NetMulticast` are never emitted as cross-module direct binds. Raw C++ calls would bypass UE RPC routing and break network semantics, so they continue through `BlueprintCallableReflectiveFallback`.
- **Safe signature subset**: automatic emit covers signatures that do not require extra BPVM writeback or WorldContext injection: supported returns include `void`, bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`; supported parameters include bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`, `UClass*`, soft object, and weak object. Out params, WorldContext, ref returns, static arrays, and `TArray/TSet/TMap` remain fallback or diagnostics.
- **Constructor-only feature instances**: generated feature payload objects use explicit constructors, not brace aggregate initialization.
- **LayoutVersion contract**: any layout add/remove/reorder/widen/narrow operation must bump `cross-module-layout-version.txt`, the single source of truth consumed by both generator and runtime.
- **Stale shard cleanup**: extend stale-output cleanup from only `AngelscriptRuntime` to every supported module OutputDirectory, otherwise old cross-module shards can remain and link duplicate definitions.
- **Multiple shards per module**: each shard registers its own feature instance. AS Runtime iterates feature instances and does not deduplicate by ModuleName.
- **Shutdown safety**: `OnPreExit` sets shutdown flags and removes delegates; `~FAutoReg` no-ops during shutdown instead of calling `IModularFeatures::Get()` after Core teardown begins.
- **Thread safety**: `OnModularFeatureRegistered` may fire off the main thread, so AS Runtime marshals injection to GameThread before touching `ClassFuncMaps` or binding AS methods.
- **Modular / Monolithic path**: the design does not depend on the PE export table. Source-build Editor is the validation target for this change; Monolithic Shipping and Launcher-engine smoke coverage are deferred to release-hardening. If no target module emits shards, runtime finds no features and fallback behavior remains unchanged.
- **Three ABI guards**: compile-time `static_assert(sizeof(...))`, runtime LayoutVersion warning+skip on mismatch, and null/range payload validation.
- **Day-0 link probe gate**: before engineering the full feature, emit a minimal Engine-module self-registering `IModularFeatures` cpp and prove UBT compiles it into the target module and AS Runtime can read it at Late+60. If that fails, stop the change.

Out of scope: internal `UASFunction` dispatch, StaticJIT, and reflective fallback internals. Those are covered by `uasfunction-runtime-dispatch-coverage` and `uasfunction-dispatch-matrix-and-jit-paths`.

## Capabilities

### New Capabilities

- `as-blueprintcallable-direct-bind`: defines the observable behavior of `BlueprintCallable` UFunction direct binding through "UHT cross-module emit + IModularFeatures rendezvous + POD payload constructor instance + raw thunk + AS Runtime generic-hook bridge"; records the safe signature subset, three ABI guards, RPC/Net skip contract, stale shard cleanup responsibility, shutdown safety, `OnModularFeatureRegistered` GameThread marshal, and `unexported-symbol` coverage acceptance.

### Modified Capabilities

<!-- No existing requirements are modified. `uasfunction-*` specs cover UASFunction internal dispatch, while this change covers the binding path from AS to external UFunctions. -->

## Impact

- **Code**:
  - `AngelscriptFunctionTableExporter.cs`: keep plugin exporter `ModuleName`, extend output strategy, and distribute by target module OutputDirectory absolute paths.
  - `AngelscriptFunctionTableCodeGenerator.cs`: add cross-module shard shape: IModularFeatures self-registration + raw thunk + POD table; distinguish Direct / CrossModule / Stub in CSV and Summary outputs.
  - `AngelscriptHeaderSignatureResolver.cs`: remove "cross-module means unreachable" from `unexported-symbol` classification.
  - `AngelscriptRuntime/Public/UHT/AngelscriptCrossModuleBindings.h`: new POD layout, reader, `LayoutVersionExpected`, double-ended `static_assert`.
  - `AngelscriptRuntime/Binds/Bind_CrossModuleDirect.cpp`: new Late+60 injection, generic hook, and late-registration subscription.
  - `AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp`: existing logic; it only relies on `ClassFuncMaps` being filled.
- **No new engine-module dependency in `AngelscriptRuntime.Build.cs`**. `Features/IModularFeatures.h` is from Core, already in dependencies.
- **Generated outputs**: `AS_FunctionTable_<Module>_CrossModule_NNN.cpp` in target module `Intermediate/Build/.../<Module>/`; same-module multi-shard means multiple feature instances; Summary/CSV files gain CrossModule fields and reasons.
- **New source file**: `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt`.
- **Stale cleanup boundary**: `DeleteStaleOutputs` enumerates all supported module OutputDirectories, not just AngelscriptRuntime.
- **Build**: source-build target linker must compile extra `.cpp` files under target module OutputDirectory; Day-0 probe verifies absolute-path `CommitOutput`. Launcher and Monolithic do not require target modules to emit cross-module shards; fallback handles missing features.
- **Tests**: add `Angelscript.CppTests.UHTToolResolver.*` tests covering probe, public header, ABI guards, raw bridge, late module registration, worker-thread marshal, same-module feature non-deduplication, static generated-output boundaries, and diagnostics. Bindings CQTest / full dual-build matrices are deferred.
- **Docs**: root `AGENTS.md` / `AGENTS_ZH.md` record cross-module direct-bind maintenance boundaries. `BindGapAuditMatrix.md` number refresh and `TestPerformance.md` micro-bench baseline are deferred to follow-up audit.
- **Risks**: handled by Day-0 probe, three ABI guards, Core static initialization validation, late-registration callback, RPC/Net skip tests, shutdown flags, GameThread marshal, and stale cleanup across all supported modules.
