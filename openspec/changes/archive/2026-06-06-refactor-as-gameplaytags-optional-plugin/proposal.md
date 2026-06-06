## Why

GameplayTag support currently lives inside `AngelscriptRuntime` as process-level caches plus a manual rebind path, which means every runtime user pays for logic that only some projects need. Users who want GameplayTags but do not use GAS should be able to opt into that support without inheriting the GAS plugin as a dependency.

## What Changes

- Move the current GameplayTag binding, cache, and rebind behavior out of `AngelscriptRuntime`.
- Provide GameplayTag support through an optional plugin that registers with the new runtime extension seam.
- Preserve the current behavior of cached tag registration, dedup lookup, and rebind-to-current-engine semantics for users who enable the plugin.
- **BREAKING**: GameplayTag script bindings are no longer guaranteed to be available from the core Angelscript runtime module alone.
- Keep the runtime-side extension seam generic so future optional features can reuse it without coupling to GAS.

## Capabilities

### New Capabilities
- `angelscript-gameplaytags-extension`: Defines optional GameplayTag script bindings, cached tag registration, dedup lookup, and replay-to-current-engine behavior through a separate plugin.

### Modified Capabilities
- `as-engine-extension-registry`: The new extension registry is required to host the optional GameplayTag extension.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGameplayTag.*`: GameplayTag-specific binding code moves out of the core runtime.
- New optional plugin source for GameplayTag support, with its own runtime module and dependencies.
- `Plugins/AngelscriptGAS/` may stop owning GameplayTag binding concerns if it no longer needs them for GAS-specific behavior.
- Build rules and plugin metadata for whichever optional plugin carries the GameplayTag extension.
- Runtime users that do not enable the optional plugin no longer pay the cost of GameplayTag binding and replay logic.
