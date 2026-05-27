## Why

The current cross-module binding diagnostics stop at `target-module-disabled` for unexported-symbol candidates outside the enabled module set. That hides whether the 847 disabled-module candidates are actually safe frame-wrapper opportunities or blocked by signature/protocol work.

## What Changes

- Split disabled-module unexported-symbol diagnostics into protocol-aware reasons.
- Add an explicit `disabled-safe-cross-module` reason for candidates that would be safe if their module were enabled for cross-module generation.
- Preserve existing generated binding behavior: do not enable new modules, do not emit additional wrapper thunks, and do not change runtime ABI.

## Capabilities

### New Capabilities

- `as-cross-module-bind-diagnostics`: Diagnostics for disabled cross-module direct-bind candidates.

### Modified Capabilities

## Impact

- Affected code: `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs`.
- Affected tests: UHTTool resolver diagnostics tests under `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/`.
- Affected artifacts: generated `AS_FunctionTable_SkippedEntries.csv` and `AS_FunctionTable_SkippedReasonSummary.csv`.
