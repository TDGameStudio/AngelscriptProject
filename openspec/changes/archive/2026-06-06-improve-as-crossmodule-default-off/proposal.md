## Why

Cross-module direct-bind generation currently writes target-module wrapper shards into engine module output directories by default on source-engine workspaces. This makes a plugin build mutate and compile engine-side generated code unless users explicitly edit the allowlist, which is too surprising for a feature that should be opt-in.

## What Changes

- Add an explicit build-time CrossModule generation gate to the Angelscript UHTTool configuration, defaulting to disabled.
- Preserve the existing module profile lists as an opt-in allowlist for users who explicitly enable CrossModule generation.
- Stop generating engine-side CrossModule wrapper shards and the Engine link probe while the gate is disabled.
- Keep normal AngelscriptRuntime generated function-table shards active for runtime-linked modules.
- Extend generated summary diagnostics so the selected profile and disabled generation state are visible.

## Capabilities

### New Capabilities
- `as-crossmodule-default-off`: Defines the default-disabled build-time behavior for Angelscript UHTTool CrossModule engine-side code generation.

### Modified Capabilities

## Impact

- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-generation-modules.json`
- UHTTool tests in `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleLinkProbeTests.cpp`
- Generated diagnostics: `AS_FunctionTable_Summary.json`, `AS_FunctionTable_Entries.csv`, `AS_FunctionTable_ModuleSummary.csv`
