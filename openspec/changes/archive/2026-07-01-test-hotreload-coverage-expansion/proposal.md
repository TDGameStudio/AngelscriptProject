## Why

HotReload tests currently cover the crash-triggering property-specifier path, but the reload analyzer has several independent decision branches for functions, defaults, class metadata, class flags, enums, delegates, and Blueprint children. We need broader regression coverage so future reload changes fail in automation before they reach editor sessions.

## What Changes

- Add a decision-matrix style HotReload automation test family for non-UPROPERTY reload changes.
- Add a soft-reload Blueprint-child regression that exercises the crash-prone `DoSoftReload` path directly.
- Keep the scope to tests and records; no public runtime API or behavior contract changes are introduced by this change.

## Capabilities

### New Capabilities
- `hotreload-test-coverage`: Automation coverage for mapping common AngelScript source edits to expected soft/full reload decisions and Blueprint-child reload safety.

### Modified Capabilities
- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/`
- `openspec/changes/test-hotreload-coverage-expansion/`
