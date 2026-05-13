## Why

`UnrealEvent` has now disabled the GMP editor-side modules in its plugin descriptor while keeping their source directories available as reference material. A follow-up change is needed to physically remove or archive those modules only after dependency and replacement decisions are explicit.

## What Changes

- Plan the removal of `Source/GMPEditor/GMPEditor`, `Source/GMPEditor/MessageTags`, and `Source/GMPEditor/MessageTagsEditor` from the standalone `UnrealEvent` plugin.
- Preserve the current descriptor behavior where only the `GMP` runtime module is declared and editor/tag modules are not loaded by the plugin.
- Remove editor-only plugin dependency declarations that exist only for the disabled modules when the corresponding source is deleted.
- Keep GMP runtime event dispatch code, runtime dependencies, ThirdParty code needed by `GMP`, and license attribution intact.
- Defer any replacement UnrealEvent editor tooling, message-key UI, or tag-authoring workflow to separate OpenSpec changes.

## Capabilities

### New Capabilities

- `unrealevent-gmp-editor-pruning`: Captures the expected plugin shape after the unused GMP editor-side modules are removed or archived.

### Modified Capabilities

- None.

## Impact

- Plugin descriptor: `Plugins/UnrealEvent/UnrealEvent.uplugin`.
- Disabled reference source: `Plugins/UnrealEvent/Source/GMPEditor/GMPEditor`, `Plugins/UnrealEvent/Source/GMPEditor/MessageTags`, and `Plugins/UnrealEvent/Source/GMPEditor/MessageTagsEditor`.
- Build metadata: module `.Build.cs` files under `Source/GMPEditor` and any plugin dependency entries that become unnecessary.
- Repository workflow: `Plugins/UnrealEvent` submodule commit plus host gitlink/OpenSpec tracking in `AngelscriptProject`.
