## Why

`AngelscriptRuntime` has several observer-style delegates, but it does not have a first-class way for optional features to register stateful behavior that follows engine initialization, shutdown, and replay to the current engine. The existing GameplayTag binding code is the clearest example of the gap: it owns process-level caches and a manual rebind entry point that should live behind a reusable extension seam instead of inside core runtime bindings.

## What Changes

- Add an engine-owned extension registry and extension interface in `AngelscriptRuntime`.
- Add lifecycle callbacks for extension registration, engine attach/detach, and replay to the currently scoped engine.
- Add a stable entry point for reattaching an extension's cached state to the current engine without requiring a process restart.
- Keep the extension system behavior-preserving and effectively no-op when no extensions are registered.
- Preserve the existing compile and runtime delegates; this change adds a separate seam rather than replacing current observer hooks.

## Capabilities

### New Capabilities
- `as-engine-extension-registry`: Defines the runtime extension registry, lifecycle hooks, and current-engine replay contract for optional engine-scoped extensions.

### Modified Capabilities
- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/`: new extension registry and lifecycle integration.
- `FAngelscriptEngine` and `FAngelscriptRuntimeModule`: attach, detach, and replay points for engine lifecycle transitions.
- Future optional plugin modules that need engine-scoped replay or cached state management.
