# UHT FunctionBinding Hardening

`AngelscriptUHTTool` is a build-time exporter. Its output is selected by the project-level `FunctionBindingMethod` enum and the matching module array in `Config/DefaultAngelscriptCompileOptions.ini`.

## Responsibilities

- `AngelscriptFunctionBindingConfiguration.cs` parses the canonical UE INI section and implements unprefixed replacement, `+` append, `-` removal, and `!` clear semantics.
- `AngelscriptFunctionBindingConfigurationResolver.cs` locates the effective project configuration and classifies the engine as `source`, `installed`, or `unknown`.
- `AngelscriptFunctionBindingPolicy.cs` owns callable/event/RPC/custom-thunk eligibility and conservative target signature policy.
- `AngelscriptFunctionBindingCodeGenerator.cs` traverses UHT types and coordinates analysis results.
- `AngelscriptFunctionBindingEmitters.cs` emits Runtime-linked shards, target-module address shards, and the target bridge probe.
- `AngelscriptFunctionBindingArtifacts.cs` writes JSON/CSV statistics and per-function diagnostics.
- `AngelscriptFunctionBindingCleanup.cs` removes stale current and migration-era files only below UHT `Intermediate` output directories.

Every eligible UFunction contributes one result. Runtime-linked functions are either `NativeRuntimeLinked` or `ReflectiveFallback`; target-module functions are emitted only when declaration visibility, overload identity, include dependencies, and marshalling safety are proven. Unknown or unsupported cases are skipped with a stable reason.

## Lifecycle safety

Target-module descriptors are owned by the modular feature registered by the generated source module. The Runtime bridge keeps a registration state for each feature, defers worker-thread injection to the game thread, retries unresolved classes after UObject construction, and removes injected bindings when the feature unregisters. This makes a module unload/reload invalidate old descriptor and thunk ownership before the module storage can disappear.

## Troubleshooting

- `NativeModuleFunctionAddress compilation requires a source engine` means the engine is installed, binary, or could not be classified. Select `None` or `NativeRuntimeLinked`, or use a source checkout.
- A non-zero configured-module miss count means a configured module was absent from the current UHT session. Check the module name and target/plugin dependencies; the exporter does not silently switch backends.
- `AS_FunctionBindingStatistics.json`, `AS_FunctionBindingDiagnostics.csv`, and `AS_FunctionBindingSkippedFunctions.csv` are the authoritative generated diagnostics. Compare `totalAnalyzedFunctions` with the category and skipped totals when investigating output gaps.
- Switching methods triggers cleanup of target shards, bridge probes, old `AS_FunctionTable_*` artifacts, and stale FunctionBinding shards before the next output is consumed.

The normal validation entry points are `Tools\RunBuild.ps1` and `Tools\RunTests.ps1`. The UHT C# project can be compiled with the engine-bundled .NET SDK when validating the exporter in isolation.
