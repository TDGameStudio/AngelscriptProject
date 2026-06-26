# Proposal: Refactor AS Current Engine Access Through Execution Context

## Why

`FAngelscriptEngine::Get()` is currently the default way to discover the active AngelScript engine from anywhere in the runtime, editor, bindings, and tests. That makes `FAngelscriptEngine` act as both an engine instance and an ambient global context resolver, hiding ownership and execution state behind a broad static API.

This change introduces an explicit execution-context boundary so most code stops "getting the engine" and instead receives the specific dependency it needs. The goal is to reduce `FAngelscriptEngine` god-object pressure without forcing a risky single-step migration of hundreds of existing call sites.

## What Changes

- Introduce `FAngelscriptExecutionContext` as the narrow representation of the current AngelScript call chain: engine, script engine, world context, and phase.
- Introduce `FAngelscriptExecutionScope` as the RAII push/pop mechanism for current execution context.
- Keep `FAngelscriptEngine::Get()` and `TryGetCurrentEngine()` as compatibility wrappers during migration, but make them forward through the execution-context resolver.
- Migrate subsystem/module/test scope ownership first, then migrate internal helper code to explicit parameters such as `FAngelscriptEngine&`, `asIScriptEngine&`, module registry, settings view, or world context.
- Treat long-lived systems such as coverage, crash snapshot, debug, and StaticJIT as engine-attached services/extensions rather than call-site global lookups.
- Add migration guardrails so new code does not add raw `FAngelscriptEngine::Get().Engine`, `Get().StaticJIT`, `Get().DebugServer`, or other god-object style access.

## Capabilities

### New Capabilities

- `as-execution-context`: Defines the current AngelScript execution/compile/bind/test context boundary, allowed lookup points, and migration rules away from broad `FAngelscriptEngine::Get()` usage.

### Modified Capabilities

<!-- None. `as-engine-scoped-runtime-state` remains related context, but this change does not modify its requirements. -->

## Impact

- Runtime core: `AngelscriptEngine.h/.cpp`, engine scope/context stack code, subsystem/module ownership paths.
- Runtime services: debug, coverage, crash snapshot, StaticJIT, diagnostics, and future extension migration points.
- Bindings and helper APIs: gradual shift from hidden current-engine lookup to explicit `FAngelscriptEngine&` / `asIScriptEngine&` parameters.
- Tests: `FAngelscriptEngineScope` remains as a compatibility wrapper initially, then test helpers can adopt `FAngelscriptExecutionScope`.
- Documentation and guardrails: add design guidance and static scans to prevent new `FAngelscriptEngine::Get()` expansion.
