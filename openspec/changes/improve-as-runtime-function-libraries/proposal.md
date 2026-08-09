## Why

`AngelscriptRuntime/FunctionLibraries` exposes a large script-facing API through reflected `UFUNCTION` metadata, class-level `ScriptMixin` targets, and several post-reflection manual supplements, but that surface has no exhaustive contract and invalid mixin metadata can silently fall back to an unrelated static namespace. The same area also contains confirmed behavioral defects and dead or misleading wrappers, so it needs one Runtime-owned closure before more helpers are added.

## What Changes

- Add a metadata-driven contract for every Runtime FunctionLibrary function: each entry is exposed, explicitly hidden, or removed, with deterministic namespace/mixin placement and full-declaration uniqueness.
- Reject invalid `ScriptMixin` targets and receiver signatures with actionable initialization diagnostics instead of silently binding the function as static.
- Correct confirmed math, curve, input, widget, asset-manager, component, level-streaming, and script-helper defects against current plugin source and UE5-main source behavior.
- **BREAKING**: Remove unused parameters from the two engine-defined `UPlayerInput` mapping helpers.
- **BREAKING**: Remove dead bare-`UFUNCTION` AssetManager wrappers and component wrappers that duplicate richer UE APIs while discarding sweep/hit/teleport semantics.
- Consolidate Runtime FunctionLibrary automation tests into a flat `AngelscriptTest/FunctionLibraries/` directory with the root prefix `Angelscript.TestModule.FunctionLibraries.*`.
- Record the current Editor FunctionLibrary binding gap without adding an Editor bind provider, Editor test surface, or compatibility fiction in this change.

## Capabilities

### New Capabilities

- `as-runtime-function-library-contract`: Defines discovery, exposure classification, mixin receiver validation, declaration identity, and failure behavior for Runtime FunctionLibraries.
- `as-runtime-function-library-behavior`: Defines the corrected script-visible behavior and intentional breaking cleanup for Runtime FunctionLibrary helpers.

### Modified Capabilities

- `as-bindings-test-execute-and-naming`: Adds the flat FunctionLibraries test theme, canonical automation prefixes, migration rules, and current unit-test conventions.

## Impact

- Runtime reflection signature generation and post-reflection FunctionLibrary supplements under `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/`.
- Runtime helper headers and the Script-library implementation under `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/`, plus a Runtime Core adapter for VM-private global-initialization state.
- FunctionLibrary-focused tests currently spread across `AngelscriptTest/Bindings`, `AngelscriptTest/Core`, and related suite/catalog configuration.
- Script call sites using the removed Input parameters or removed dead/redundant helpers will require migration; no compatibility aliases are planned.
- `AngelscriptEditor/FunctionLibraries`, optional GameplayTags/GAS plugins, UHT binding strategy, Standalone, and the host project remain unchanged.
