## Why

Cross-module direct-bind generation is currently gated by modules listed in `AngelscriptRuntime.Build.cs`. That couples coverage to runtime link dependencies and makes the next coverage increase look like a Build.cs dependency change, even though target-module-local wrapper shards do not need AngelscriptRuntime to link those modules.

## What Changes

- Add an AngelscriptUHTTool-owned cross-module generation allowlist for target-module wrapper shards.
- Keep `AngelscriptRuntime.Build.cs` as the source for modules that may emit normal AngelscriptRuntime same-module shards.
- Generate cross-module-only shards for allowlisted modules without adding those modules to AngelscriptRuntime dependencies.
- Start with a small pilot allowlist drawn from the current `disabled-safe-cross-module` opportunity pool.
- Extend generated CSV/summary diagnostics so cross-module-only modules are visible without being counted as runtime-linked direct/stub shards.

## Capabilities

### New Capabilities
- `as-cross-module-generation-allowlist`: Defines how UHT-owned module allowlisting expands cross-module direct-bind shard generation without changing AngelscriptRuntime module dependencies.

### Modified Capabilities

## Impact

- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs`
- New UHT tool allowlist data file under `Plugins/Angelscript/Source/AngelscriptUHTTool/`
- UHTTool automation tests under `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/`
- Generated diagnostics: `AS_FunctionTable_Entries.csv`, `AS_FunctionTable_ModuleSummary.csv`, `AS_FunctionTable_Summary.json`, and skipped reason CSVs
