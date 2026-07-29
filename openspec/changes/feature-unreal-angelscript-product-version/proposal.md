## Why

The embedded runtime currently reports the upstream-derived `2.33.0 WIP` value as though it were the version of this deeply diverged Unreal Engine plugin. The core plugin and planned standalone distribution need an owned, releaseable product version that can advance through GitHub releases without misrepresenting upstream compatibility.

## What Changes

- Establish `Unreal AngelScript 1.0.0` as the owned product version for the core UE plugin, embedded runtime, and planned standalone distribution.
- **BREAKING** Replace the public `ANGELSCRIPT_VERSION` value `23300` with `10000`; callers compiled against the old 2.33 header are intentionally rejected and must use this fork's header.
- Replace the old major/minor compatibility check with a SemVer rule: the requested and available versions must share a major version, and the requested version must not be newer than the available runtime.
- Add a public upstream-lineage query while keeping `AngelScript 2.33.0 WIP lineage + selective 2.38 backports` separate from the product version.
- Synchronize the core `.uplugin` descriptor and add a non-mutating validator for release and standalone packaging workflows.
- Keep `AngelscriptGameplayTags` and `AngelscriptGAS` on independent plugin versions.

## Capabilities

### New Capabilities

- `unreal-angelscript-product-version`: Defines the owned product version, encoded compatibility semantics, runtime query surface, descriptor synchronization, and release validation contract.

### Modified Capabilities

- `unreal-angelscript-identity`: Replaces the provisional `UEAS Runtime` label with the concrete public form `Unreal AngelScript <semver>` while preserving upstream lineage as separate technical metadata.

## Impact

- Runtime API: `angelscript.h`, `asGetLibraryVersion()`, `asCreateScriptEngine()`, and one new lineage query.
- Plugin packaging: `Angelscript.uplugin` and a plugin-owned read-only version validator.
- Tests: raw AngelScript SDK engine version coverage plus removal of obsolete 2.33 current-version assertions.
- Documentation and release records: Chinese-first agent guidance, plugin README, fork strategy, and the active standalone release OpenSpec.
- Serialization, bytecode, script syntax, module names, config keys, automation prefixes, and optional plugin versions are unchanged.
