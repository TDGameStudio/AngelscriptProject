# Bind replay vs a cached bind snapshot

Response to the proposal: run bind lambdas once at process start, cache all bind
information, and skip replay on later Engines.

**Verdict for this change:** do not do that here. Keep per-Engine lambda replay.
The native-form **catalog** only caches JIT spelling/linkage recipes.

A bind-surface snapshot that skips walking `Bind_*.cpp` + UE reflection for a
**second Engine of the same surface** can be a later, separate OpenSpec if bind
startup cost is proven.

## Why “bind once for the process” fails

Each `FAngelscriptEngine` owns an `asIScriptEngine`. Types, functions, and
numeric IDs are engine-local. Skipping lambdas without `Register*` into the new
engine leaves it empty. AngelScript does not share one type registry across
engines.

The lambdas are not pure. They read `GetTargetEngine()`:

- `ShouldUseEditorScripts()`, editor-only properties
- `IsEditorOnlyClassForTarget` / `ShouldBindEngineTypeForTarget`
- `AS_USE_BIND_DB` (cooked BindDB vs Editor reflection walk)
- generation traits (`bSimulateCooked`, Shipping vs Editor)

Editor primary and `GameShipping` generation Engines must not share one frozen
declaration set.

Tests and generation containment also require isolated `asIScriptEngine`
instances.

## BindDB is already a different cache

`FAngelscriptBindDatabase` (`Binds.Cache`) stores UFunction / USTRUCT bind
metadata so cooked games can bind without full Editor reflection. It is not a
native-form table, not an `asIScriptEngine` clone, and not a JIT include
catalog. Cooked still executes bind into that Engine; the data source is the
cache instead of scanning UClasses. Do not merge BindDB, the JIT recipe catalog,
and a hypothetical full bind snapshot into one “all bind information” table.

## If replay cost is later the bottleneck

Cache by **bind surface**, not by process:

```text
key = EditorDevelopment | GameDevelopment | GameShipping (+ BindDB mode)
first Engine of that surface: run lambdas, record pointer-free Register operations
later Engine of the same surface: apply the snapshot into a new asIScriptEngine
other surface: other snapshot, or run lambdas again
```

`RegisterGlobalFunction` still runs per function. What you save is
`Bind_BlueprintType` reflection walks, not the small `CoreGlobals` lambdas.

That is a second installation path that must stay in lockstep with 121
`Bind_*.cpp` files. It is out of `refactor-as-primary-engine-typed-ast-generate`.
