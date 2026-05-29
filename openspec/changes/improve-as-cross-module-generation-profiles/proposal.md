## Why

Cross-module generation is now decoupled from `AngelscriptRuntime.Build.cs`, but the module expansion policy is still a flat UHTTool text allowlist. The next coverage step needs an explicit source-engine vs installed-engine policy so source builds can expand aggressively without making binary engine builds write or compile unexpected engine-module wrapper shards.

## What Changes

- Replace the flat cross-module generation allowlist with a UHTTool-owned JSON profile configuration.
- Select `common + source` modules when the current engine is a source distribution.
- Select `common + installed` modules when the current engine is an installed/binary distribution.
- Keep installed/binary engine expansion conservative by default.
- Include the current `disabled-safe-cross-module` opportunity pool in the source profile.
- Add generated diagnostics that report the selected profile and effective configured modules.

## Capabilities

### New Capabilities
- `as-cross-module-generation-profiles`: Defines profile-based cross-module wrapper generation policy for source and installed engine environments.

### Modified Capabilities

## Impact

- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-generation-modules.json`
- `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/AngelscriptCrossModuleLinkProbeTests.cpp`
- Generated diagnostics: `AS_FunctionTable_Summary.json`, `AS_FunctionTable_Entries.csv`, `AS_FunctionTable_ModuleSummary.csv`, and skipped diagnostics
