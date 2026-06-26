# Design: Angelscript Execution Context

## Context

`FAngelscriptEngine` currently combines several responsibilities:

- engine instance state: AS engine pointer, modules, bind state, diagnostics, package references;
- current-engine resolution: `TryGetCurrentEngine()` / `Get()`;
- current world context: ambient world assignment and lookup;
- lifecycle coordination: subsystem/module/game-instance fallback ownership;
- service hub: debug server, StaticJIT, code coverage, reload hooks, compile/reload hooks.

The codebase already uses scoped engine context heavily. A recent scan found hundreds of `FAngelscriptEngine::Get()` / `TryGetCurrentEngine()` references and over one thousand `FAngelscriptEngineScope` references across runtime, editor, and tests. A direct removal of `Get()` would create a large mechanical migration with high regression risk.

The safer design is to split the access model before splitting major runtime features:

1. make "current context" a first-class concept;
2. keep compatibility wrappers so behavior stays stable;
3. move ownership and current-context resolution out of `FAngelscriptEngine`;
4. migrate internal helpers to explicit dependencies;
5. move long-lived systems to engine-attached services/extensions.

## Goals

- Make ambient current-engine access explicit and named around execution context rather than engine singleton semantics.
- Keep `FAngelscriptEngine` as the owner of per-engine state, not the owner of current-context resolution.
- Represent the current call chain with a narrow object containing `Engine`, `ScriptEngine`, `WorldContext`, and `Phase`.
- Let boundary code resolve current context, while lower-level helper code receives concrete dependencies as parameters.
- Preserve existing behavior during migration through wrappers and compatibility scopes.
- Enable later refactors of coverage, crash snapshot, debug, StaticJIT, diagnostics, module registry, and compilation pipeline.

## Non-Goals

- Do not delete `FAngelscriptEngine::Get()` in the first implementation step.
- Do not replace `FAngelscriptEngine::Get()` with another unconstrained global `Resolver::Get()` used everywhere.
- Do not move compile/reload pipeline ownership in this change.
- Do not migrate all binding call sites in one pass.
- Do not put coverage/debug/static-jit services inside `FAngelscriptExecutionContext`.
- Do not turn `FAngelscriptExecutionContext` into a new god object.

## Proposed Types

### `FAngelscriptExecutionContext`

`FAngelscriptExecutionContext` is a non-owning view of the current AngelScript call chain.

Expected responsibilities:

- expose the current `FAngelscriptEngine&`;
- expose the current `asIScriptEngine&`;
- expose the current world context object or world when available;
- expose the current phase, such as runtime, bind, compile, reload, or test;
- provide `TryCurrent()` and `Current()` for boundary-layer code;
- provide diagnostics when `Current()` is requested outside a valid scope.

It does not own engine state, service state, modules, bind state, or AS runtime objects.

Sketch:

```cpp
enum class EAngelscriptExecutionPhase : uint8
{
	Runtime,
	Bind,
	Compile,
	Reload,
	Test,
};

struct FAngelscriptExecutionContext
{
	static FAngelscriptExecutionContext* TryCurrent();
	static FAngelscriptExecutionContext& Current();

	FAngelscriptEngine& Engine() const;
	asIScriptEngine& ScriptEngine() const;
	UObject* WorldContextObject() const;
	UWorld* World() const;
	EAngelscriptExecutionPhase Phase() const;
};
```

### `FAngelscriptExecutionScope`

`FAngelscriptExecutionScope` is the RAII object that pushes and pops current execution context.

Sketch:

```cpp
struct FAngelscriptExecutionScope
{
	FAngelscriptExecutionScope(
		FAngelscriptEngine& Engine,
		UObject* WorldContextObject = nullptr,
		EAngelscriptExecutionPhase Phase = EAngelscriptExecutionPhase::Runtime);
	~FAngelscriptExecutionScope();
};
```

`FAngelscriptEngineScope` should initially become a compatibility wrapper around `FAngelscriptExecutionScope` so existing tests and runtime paths continue compiling.

## Access Model

### Boundary code may use current context

Allowed examples:

- subsystem/module initialization and tick boundaries;
- game-instance scope ownership;
- commandlets and console commands;
- script call dispatch;
- AS-to-UObject or UObject-to-AS bridge entry points;
- debug server request entry points;
- automation test helper scopes.

Boundary code may use:

```cpp
FAngelscriptExecutionContext& Context = FAngelscriptExecutionContext::Current();
```

### Internal code should use explicit dependencies

Lower-level code should not rediscover the current engine. It should receive only what it needs:

```cpp
ResolveFunction(asIScriptEngine& ScriptEngine, int32 FunctionId);
GenerateClass(FAngelscriptModuleRegistry& Modules, FAngelscriptClassDesc& ClassDesc);
BindType(FAngelscriptBindContext& BindContext);
SpawnWithWorld(UWorld& World, const FSpawnRequest& Request);
```

This keeps dependency requirements visible in function signatures and prevents `FAngelscriptExecutionContext::Current()` from becoming the new hidden global.

### Long-lived services attach to engines

Systems with engine-lifetime behavior should not perform ad hoc current-engine lookups from arbitrary call sites. They should attach/detach through `IAngelscriptExtension` or a similar engine service interface:

- code coverage;
- crash snapshot;
- debug server;
- StaticJIT/precompiled state;
- reload observers;
- diagnostics exporters.

Those systems may receive `FAngelscriptEngine&` in `OnEngineAttached` and cache only scoped, lifetime-safe state.

## Compatibility Strategy

Phase 1 keeps existing public APIs but changes their implementation:

```cpp
FAngelscriptEngine* FAngelscriptEngine::TryGetCurrentEngine()
{
	return FAngelscriptExecutionContext::TryCurrentEngine();
}

FAngelscriptEngine& FAngelscriptEngine::Get()
{
	return FAngelscriptExecutionContext::Current().Engine();
}
```

This avoids breaking hundreds of call sites while moving the real current-context logic out of `FAngelscriptEngine`.

Phase 2 migrates ownership/scoping call sites:

- `UAngelscriptEngineSubsystem`;
- `UAngelscriptGameInstanceSubsystem`;
- `FAngelscriptRuntimeModule::InitializeAngelscript`;
- test helper scopes and context-stack test access.

Phase 3 migrates high-risk god-object access patterns:

- `FAngelscriptEngine::Get().Engine`;
- `FAngelscriptEngine::Get().StaticJIT`;
- `FAngelscriptEngine::Get().DebugServer`;
- `FAngelscriptEngine::Get().CodeCoverage`;
- direct access to settings where a settings view is sufficient.

Phase 4 migrates domain access to facades:

- module/class lookup to module registry;
- hooks to event bus or engine extension attach points;
- diagnostics to diagnostics store;
- script engine usage to explicit `asIScriptEngine&` parameters.

## Guardrails

The migration should add static scans or tests that fail on new usage of the worst patterns:

- `FAngelscriptEngine::Get().Engine`;
- `FAngelscriptEngine::Get().StaticJIT`;
- `FAngelscriptEngine::Get().DebugServer`;
- `FAngelscriptEngine::Get().CodeCoverage`;
- new long-lived hook subscription through direct `Get().GetOnXxx().Add...` outside an extension.

Plain `FAngelscriptEngine::Get()` may remain temporarily, but new code should justify it as boundary-layer access or use explicit parameters.

## Risks and Trade-offs

### Risk: The context object becomes a new god object

Mitigation: keep it non-owning and narrow. It exposes current engine, script engine, world context, and phase only. It does not own modules, services, diagnostics, coverage, debug, StaticJIT, or compile/reload logic.

### Risk: Migration stalls with wrappers only

Mitigation: add guardrails for the worst access patterns first, then migrate by directory and purpose. Wrappers are a compatibility bridge, not the final API.

### Risk: Too much parameter threading

Mitigation: pass cohesive domain contexts where they already exist or are justified, such as `FAngelscriptBindContext`, module registry, settings view, or diagnostics store. Avoid passing the whole engine when a narrower dependency is sufficient.

### Risk: Test churn

Mitigation: keep `FAngelscriptEngineScope` as a wrapper initially. Update shared test helpers before mass-changing individual test files.

## Relationship to Existing Specs

- `as-engine-scoped-runtime-state` defines where engine-owned AS runtime objects may live. `as-execution-context` defines how call sites discover or receive the current engine and related call-chain state.
- `as-engine-extension-registry` remains the preferred lifecycle mechanism for long-lived engine-attached services.
- Existing code coverage and crash snapshot extension refactors are downstream examples of the long-lived service rule.

