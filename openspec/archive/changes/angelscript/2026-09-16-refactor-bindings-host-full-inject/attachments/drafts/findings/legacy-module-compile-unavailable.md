# Legacy module compilation is unavailable

Observation 2026-09-16 while applying task 1.0 of `angelscript/refactor-bindings-host-full-inject`.

## What was inspected

- `FAngelscriptEngine::CompileModule_Types_Stage1` (`AngelscriptEngine.cpp:7607`) always sets `bCompileError` and reports `Legacy module compilation is unavailable; use frozen Builder inputs.`
- `NativeEngine.Compile.SDK` asserts `asIScriptEngine` / `asCScriptEngine` have no `GetModule`, and `asIScriptModule` has no public `AddScriptSection` / `Build`.
- Task 1.0 and 2.1 Interfaces still named `ASTEST_AS` plus `asIScriptModule::AddScriptSection` / `Build`. Those symbols are not a maintained compile path.
- Default `FAngelscriptEngine` constructs a `FAngelscriptCacheService`. `InitializeWithoutInitialCompile` checks that the service is valid. `GetCacheService()` cannot stay null on this construction path. Cache V2 can be forced off with `bOverrideCacheV2Enablement` + `bEnableCacheV2 = false`.

## What that means for the Temp oracle

```text
InitializeWithoutInitialCompile
  -> BindScriptTypes -> ExecuteRegisteredBinds   // current editor path
  -> types exist on this live Engine

CompileModules / AddScriptSection / Build       // dead
asCBuilder + host Dependencies + Register       // needs the injected host graph (1.1+1.2)
Prepare / Execute on this Engine's functions    // available now
```

A Temp `ASTEST_AS` Build of `TArray` / `FString` / `FVector` / `Print` cannot go green on today's product path. The same bound engine can still Prepare/Execute those bound functions and read `GetLastSnapshot()`.

`asCBuilder` compile against the process host graph is not this oracle: the whitelist graph is not injected into the `BindScriptTypes` engine, and `TArray.Add` lives on `TArray.MethodSurface` (TypeInfrastructure), which `ExecuteToHost` currently skips.

## Settled for this Change

Task 1.0 proves bind-after-engine with Prepare/Execute plus bind logs. Task 2.1 owns `asCBuilder` + `asCEngineCompileRegistration` compile after inject-only. `GetCacheService()` null is not the cache exclusion; `IsCacheV2Enabled()` false is.
