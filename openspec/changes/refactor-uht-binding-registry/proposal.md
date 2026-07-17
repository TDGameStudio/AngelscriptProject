## Why

The UHT-generated binding pipeline and the runtime lookup table still use legacy names such as `AddFunctionEntry`, `FFuncEntry`, and `ClassFuncMaps`. These names describe an implementation detail rather than the actual responsibility: recording a callable target that is later consumed by the BlueprintCallable binding pass. The same generic `Entry` vocabulary is also reused for generated records and cross-module ABI payloads, making the build-time/runtime boundary difficult to reason about.

This refactor is timely before further UHT coverage and cross-module work expands the current API surface. The change will clarify ownership and terminology while preserving generated binding behavior, fallback behavior, cross-module ABI semantics, and artifact formats.

## What Changes

- Introduce canonical `FunctionBinding` / `FunctionBindingRegistry` terminology for the Runtime-side callable-target table.
- Rename UHT generator-internal records, helpers, locals, and diagnostics code to distinguish binding records from ABI payloads.
- Replace generated calls to `AddFunctionEntry` with the canonical registration API.
- Preserve first-registration and bound-entry precedence semantics exactly.
- Preserve `AS_FunctionTable_*` file naming, CSV/JSON field names, cross-module feature layout, layout-version checks, and reflective fallback behavior.
- **BREAKING** Remove the legacy Runtime-side names instead of retaining aliases or forwarding wrappers.
- Rename the cross-module public header, POD type names, namespace, and `IModularFeatures` key to the canonical function-binding vocabulary.

## Capabilities

### New Capabilities

- `as-uht-binding-registry`: Canonical naming and registration semantics for UHT-produced and cross-module callable binding records.

### Modified Capabilities

- `as-blueprintcallable-direct-bind`: update the named Runtime registry and cross-module protocol symbols while preserving all behavioral requirements.

## Impact

- Parent repository: OpenSpec records under `openspec/changes/refactor-uht-binding-registry/`.
- `Plugins/Angelscript` submodule: `AngelscriptRuntime` registry headers, UHT C# generator sources, cross-module runtime bridge, legacy Editor generator output, and related tests.
- No new dependencies, module dependencies, generated artifact formats, or cross-module ABI fields. Existing source consumers must migrate to the new names before rebuilding.
- The plugin submodule and parent gitlink will remain a dual-repository change; source changes must be committed in the submodule before the parent records the updated gitlink.
