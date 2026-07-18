## Why

The generated Angelscript function-binding pipeline currently mixes binding mechanism names, ownership boundaries, fallback states, and compile gates. `ModuleBinding`, `DirectBind`, and `Stub` do not clearly communicate whether a function is called through a Runtime-linked native pointer, a target-module-generated thunk, or Unreal reflection. The compile settings also expose the target-module path as a boolean instead of selecting one explicit automatic binding method.

The refactor establishes one project-wide `FunctionBindingMethod` backed by the Unreal `EAngelscriptFunctionBindingMethod` enum. Module membership is configured through UE compile-option arrays so Editor, UBT, and UHT use one project-owned configuration surface. `NativeRuntimeLinked` remains the migration default; `NativeModuleFunctionAddress` remains an explicit source-engine-only choice.

## What Changes

- Add the UE enum/property pair `EAngelscriptFunctionBindingMethod` / `FunctionBindingMethod` to the compile-options object.
- Add `NativeRuntimeLinkedModules` and `NativeModuleFunctionAddressModules` `TArray<FName>` settings to the same compile-options object.
- Serialize the settings through UE config syntax, for example `FunctionBindingMethod=NativeRuntimeLinked` and `+NativeRuntimeLinkedModules=Engine`.
- Make `AngelscriptRuntime.Build.cs` dynamically add configured Runtime-linked modules and generate their Runtime wrapper files.
- Require every `NativeRuntimeLinkedModules` item to be a module that `AngelscriptRuntime` can legally depend on; the array controls automatic binding scope, not arbitrary dependency cycles.
- Completely remove the old `bCompileAngelscriptModuleBindings` configuration key and `WITH_ANGELSCRIPT_MODULE_BINDINGS` gate.
- Make `None` suppress all automatic UHT registrations, including fallback-only `ERASE_NO_FUNCTION()` slots; handwritten `Bind_*.cpp` registrations remain available.
- Preserve automatic `ReflectiveFallback` inside `NativeRuntimeLinked` when a generated Runtime-linked binding has no usable native address.
- Make `NativeModuleFunctionAddress` emit only safe target-module thunks for explicitly configured target modules and skip unsupported signatures rather than silently falling back through the Runtime-linked path.
- Make `NativeRuntimeLinked` and `NativeModuleFunctionAddress` mutually exclusive at generation time: one module/function cannot receive both automatic output families in one generation.
- Retire the JSON module profile/policy files and their `enabled`, `common`, `source`, and `installed` fields; module lists come from UE config arrays.
- Require a source-built engine for `NativeModuleFunctionAddress`; installed and unknown distributions fail in Editor, UBT, and UHT.
- Keep `FunctionBindingMethod` as the global selector while allowing the two method-specific arrays to contain candidates for different mode selections.
- Move the stable bridge header under `Source/AngelscriptRuntime/FunctionBinding/`; keep generated target-module shards in module output directories.
- Replace the current mechanism/state terminology with the confirmed method, category, and statistics names.
- Use `FunctionBinding` as the outer UHT pipeline and generated-artifact concept; reserve `Table` for an actual contiguous binding-data table.
- Refactor UHT generation around one per-function analysis result so generation, statistics, and skipped-function diagnostics do not independently reclassify the same UFunction.
- Update generated diagnostics, tests, configuration documentation, and migration guidance.

## Capabilities

### New Capabilities

- `as-function-binding-strategy`: Selects and validates the automatic UHT function-binding method and its module boundary.

### Modified Capabilities

None. The existing compile-settings specification remains the storage and editor-surface baseline; this change adds the binding-method behavior as a separate capability.

## Impact

- `AngelscriptRuntime` compile settings, UBT rules, dynamic Runtime dependencies, generated binding wrappers, Runtime registration, and the source-owned bridge header.
- `AngelscriptUHTTool` method parsing, configured module-set handling, function analysis, target-module emission, statistics, stale-output cleanup, and exporter naming.
- `AngelscriptEditor` validation for method changes, module arrays, and engine distribution compatibility.
- Automation tests covering method selection, config arrays, dynamic dependency/wrapper generation, strict backend conflict rejection, `None`, Runtime-linked reflection fallback, target-module safe-signature filtering, source-engine validation, and diagnostics.
- Build documentation and all maintained generated-binding statistics terminology.
