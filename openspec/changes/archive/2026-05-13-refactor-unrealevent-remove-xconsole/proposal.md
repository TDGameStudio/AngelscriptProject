## Why

`UnrealEvent` still carries GMP's XConsole command pipeline, including command-line execution hooks, HTTP command server support, and optional Python execution. This surface is unrelated to the standalone event runtime direction and keeps unnecessary runtime/editor dependencies in the plugin.

## What Changes

- **BREAKING**: Remove GMP XConsole pipeline support from `UnrealEvent`, including `z.XCmdList`, `z.Pipeline*`, `z.RequestExitWithStatus`, and `z.PipelineRunPy` commands.
- Remove automatic XConsole command-line processing from map-load and post-start-play startup hooks.
- Remove XConsole Python helper and commandlet support.
- Remove XConsole-only dependencies on `HTTPServer` and `PythonScriptPlugin`.
- Preserve lightweight GMP signal debug controls through standard Unreal console APIs where practical.
- Remove XConsole references from the disabled `Source/GMPEditor` reference tree so it cannot reintroduce the dependency later.

## Capabilities

### New Capabilities

- `unrealevent-xconsole-removal`: Captures the expected plugin behavior after GMP XConsole support is removed from runtime and reference editor source.

### Modified Capabilities

- None.

## Impact

- Runtime source under `Plugins/UnrealEvent/Source/UnrealEvent`, especially `GMPModule.cpp`, `GMPSignalsImpl.cpp`, and XConsole source/header files.
- Disabled reference source under `Plugins/UnrealEvent/Source/GMPEditor`.
- Build metadata in `Plugins/UnrealEvent/Source/UnrealEvent/UnrealEvent.Build.cs`.
- Plugin descriptor dependency declarations in `Plugins/UnrealEvent/UnrealEvent.uplugin`.
- Repository workflow: `Plugins/UnrealEvent` submodule commit plus host gitlink/OpenSpec tracking in `AngelscriptProject`.
