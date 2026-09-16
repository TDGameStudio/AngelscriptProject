# Bound-engine proof uses Prepare/Execute until inject compile exists

## Reusable Insight

A local `FAngelscriptEngine` after `InitializeWithoutInitialCompile` is proven by Prepare/Execute on that engine's bound functions plus `GetLastSnapshot()`. It is not proven by `CompileModules` or `asIScriptModule::AddScriptSection`. Those entry points are gone; reconstruction compile is `asCBuilder` plus `asCEngineCompileRegistration` against an injected host graph.

## Evidence

`CompileModule_Types_Stage1` stubs legacy compile. `NativeEngine.Compile.SDK` asserts module compile APIs are absent. Default construction always owns a cache service object.

## Boundaries

Host* native calls on a local collection are not this proof. TypeInfo lookup without Prepare/Execute is not this proof. `GetCacheService()` may be non-null; unused Cache V2 is `IsCacheV2Enabled() == false`.

## Application

Temp `Angelscript.UnitTest.Temp.BasicTypes` AfterBind* cases. After inject-only, 2.1 adds `asCBuilder` compile.

## Sources

Finding `legacy-module-compile-unavailable.md`. Talk `talk-20260916-165201-bound-engine-call-path.md`.
