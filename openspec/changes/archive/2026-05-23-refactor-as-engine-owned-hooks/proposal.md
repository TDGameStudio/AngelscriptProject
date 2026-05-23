## Why

`FAngelscriptRuntimeModule` still acts as a process-wide hook container even though most of those hooks describe the current `FAngelscriptEngine` lifecycle, compilation flow, runtime binding behavior, or engine-scoped debug behavior. This makes multi-engine behavior harder to reason about and keeps optional extensions tied to module-level globals instead of engine-owned state.

## What Changes

- Add an engine-owned hook surface for runtime and compilation extension points that currently live as static getters on `FAngelscriptRuntimeModule`.
- Move engine-scoped hook storage to `FAngelscriptEngine` while keeping structured observational compilation events in `FAngelscriptCompilationEvents`.
- Update runtime, preprocessor, bind, debug, and editor call sites to use the new owner appropriate to each hook.
- Remove the migrated hook getters and delegate storage from `FAngelscriptRuntimeModule` after call sites are moved.
- Keep `FAngelscriptRuntimeModule` as the UE module entry and initialization compatibility surface only.
- **BREAKING**: C++ callers using `FAngelscriptRuntimeModule::Get*` hook APIs must migrate to the new engine-owned or editor/debug bridge APIs.

## Capabilities

### New Capabilities
- `as-engine-owned-hooks`: Defines ownership, lifecycle, and migration behavior for AngelScript runtime hooks that move from module-level globals to `FAngelscriptEngine` or the appropriate editor/debug bridge.

### Modified Capabilities
- `as-compilation-events`: Confirms structured compilation event broadcasting remains observational and separate from behavior-changing engine hooks.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.*`: remove hook delegate declarations/getters after migration.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`: add engine-owned hook access and route lifecycle/compile notifications through it.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Compilation/*`: keep structured event API behavior-compatible while documenting the boundary with engine hooks.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`: route class analysis through the current engine hook surface.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/*` and `Debugging/*`: migrate runtime/debug hook usage away from the module.
- `Plugins/Angelscript/Source/AngelscriptEditor/*`: migrate editor-owned debug and asset creation hook registration away from `FAngelscriptRuntimeModule`.
- `Plugins/Angelscript/Source/AngelscriptTest/*`: update and add tests for engine-owned hook isolation and compatibility.
