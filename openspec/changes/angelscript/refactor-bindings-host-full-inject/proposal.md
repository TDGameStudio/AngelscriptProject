## Why

The predecessor shared a HostProcess graph, but production still copies an eight-name whitelist and editor `BindScriptTypes` still replays every bind onto the live Engine. Old `RuntimeBindings.*` tests still prove Store/Apply. Host* tests call native pointers on a local collection and do not compile scripts after `BindScriptTypes`. Plugin binds are therefore not proven on the inject path, and there is no Temp oracle for "this engine bound, then TArray/FString/FVector/Print ran."

The user approved this successor in bindings-gap-audit Q69-Q78 and asked to create the Change on 2026-09-16. Creation delivers planning only.

## What Changes

- `EnsureProcessHostCollection` copies every registered `FAngelscriptBind` record. `ExecuteToHost` runs all seven phases and freezes the graph.
- `BindScriptTypes` injects that freeze and does not call `ExecuteRegisteredBinds`. Capture failure fails startup.
- No-argument `CreateForBindings()` uses the same Collection freeze.
- First bound-engine proof lives under `AngelscriptTest/Temp`: `InitializeWithoutInitialCompile`, then Prepare/Execute `TArray` / `FString` / `FVector` / `Print`, then assert `AS_BIND_*` / `GetLastSnapshot()`. Post-inject compile uses `asCBuilder`.
- HostScheme keeps S1 / S4-S6. Temp stays the S2/S3 compile/call oracle after inject. Perf gates P1-P4 remain recorded numbers with no speed bar.
- Family and Calls executable contracts move onto Host fixtures. Recording/Store tests and the Store/Apply production path are deleted at the end.

## Capabilities

### New Capabilities

None. Behavior stays on the existing binding and engine-creation capabilities.

### Modified Capabilities

- `angelscript/bindings/runtime`: full registered capture, seven-phase freeze, inject-only editor entry, Host-graph accounting, retirement of Store dump/validation requirements.
- `angelscript/runtime/binding-engine`: no-argument binding Engine creation uses the process Collection freeze, not Store/Apply.

## Impact

Product edits belong in the `Plugins/Angelscript` submodule (`AngelscriptRuntime` binds/engine and `AngelscriptTest/{Bindings,Temp}`). Parent-repository work owns this Change and later spec synchronization. `Source/AngelscriptProject` stays minimal.

Predecessor `angelscript/2026-09-16-refactor-bindings-process-host-typeinfo` stays archived and is not reopened. Historical Array AV / Calls.Native results are not claimed fixed until a migrating task proves them on Host.

## Non-goals and authority

No UHT generator, disk cache, manifest v2, wholesale directory rearrange, legacy revival, hot replacement of a published engine, unadapted Legacy Performance as a green gate, WriteWorkers speedup, Insights traces, or unconditional Quick/Integration. Creation and Ensure plan are authorized now; product edits wait for apply.
