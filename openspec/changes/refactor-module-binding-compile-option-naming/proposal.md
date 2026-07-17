## Why

The ModuleBinding compile gate still exposes the obsolete `ModuleLocal` vocabulary even though the generated capability, Runtime bridge, and diagnostics are named `ModuleBinding`. This makes the editor setting, UBT macro, UHT gate, and user documentation describe different concepts for the same opt-in feature.

## What Changes

- **BREAKING** Rename `bCompileAngelscriptModuleLocalBindings` to `bCompileAngelscriptModuleBindings`.
- **BREAKING** Rename `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS` to `WITH_ANGELSCRIPT_MODULE_BINDINGS`.
- Update UBT, UHT, Runtime, Editor validation, tests, README, and maintained build documentation to use the new names.
- Preserve the default-disabled behavior and source-engine-only validation.
- Preserve unrelated `ModuleLocal` wording when it specifically describes generated code location rather than the feature switch.

## Capabilities

### New Capabilities

- `as-module-binding-compile-option`: Defines the canonical compile option and preprocessor gate for the opt-in ModuleBinding feature.

### Modified Capabilities

- `as-uht-binding-registry`: Rename the existing compile-gate requirement while preserving its behavior.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime`: Build rules, compile options, Runtime bridge guard, and Editor validation.
- `Plugins/Angelscript/Source/AngelscriptUHTTool`: UHT setting lookup and source-engine error diagnostics.
- `Plugins/Angelscript/Source/AngelscriptTest`: Compile-definition validation and UHT gate source scans.
- `Config`, plugin README, and maintained build/UHT documentation.
- Existing projects must rename the ini setting before enabling the feature; the default remains `false`.
