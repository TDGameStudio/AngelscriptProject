# Talk: bound-engine call path for Temp

## Context

Task 1.0 required `ASTEST_AS` Build/Execute after `InitializeWithoutInitialCompile`. Apply found the maintained SDK no longer exposes module `AddScriptSection`/`Build`, and `CompileModules` Stage 1 is stubbed.

## Evidence

Finding `legacy-module-compile-unavailable.md`. `CompileModule_Types_Stage1` and `NativeEngine.Compile.SDK` `HasModules` / `HasCompile` asserts.

## Options

1. Keep 1.0 as written and wait for a new product compile entry — unprovable; 1.0 forbids production bind/compile edits.
2. Drop Temp scripts and keep only logs / TypeInfo presence — contradicts the user Temp oracle and the spec BUT that TypeInfo alone is not proof.
3. 1.0 Prepare/Execute on the bound engine's `TArray` / `FString` / `FVector` / `Print`; 2.1 compiles with `asCBuilder` + Register after inject.

## Settled Decision

Option 3. Same Temp prefix, same numeric oracles (5, 24, Print finishes). Cache exclusion is `IsCacheV2Enabled() == false`, not a null `GetCacheService()`.

## Consequences and Flip Condition

If Prepare/Execute cannot reach `TArray<int>` on a `BindScriptTypes` engine, record the diagnostic and replan the TArray case. Do not restore `AddScriptSection` or treat Host* collection pointer calls as this oracle.

## Sources

`AngelscriptEngine.cpp:7607`, `SDKTests.cpp` module/compile absence asserts, task 1.0 Interfaces before this replan.
