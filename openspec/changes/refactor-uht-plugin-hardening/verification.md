# Verification

## Completed

- `dotnet restore` and `dotnet build` for `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj` using the UE 5.7.2 bundled .NET SDK passed with 0 warnings and 0 errors.
- Source-engine UHT execution through `Tools/RunBuild.ps1` reached the real exporter and generated `373` `NativeModuleFunctionAddress` bindings, `3679` stable skipped diagnostics, and `3` generated files.
- The source-engine run confirmed the updated `AngelscriptUHTTool.ubtplugin.csproj` is discoverable by UE 5.7 `CsProjBuilder` after declaring the `net8.0` target framework.
- Installed UE 5.8 Runtime-linked baseline: `5830` analyzed functions, `1247` native registrations, `4583` reflective fallbacks, `29` real UHT shards, and `11` stable per-module aggregators.
- `Tools/RunTests.ps1 -TestPrefix Angelscript.CppTests.UHTToolResolver -NoReport` passed all `3/3` focused contract tests.
- Installed UE 5.8 rejection probe failed at UBT rules evaluation with the expected source-engine-only diagnostic for `NativeModuleFunctionAddress`.
- `openspec validate refactor-uht-plugin-hardening --strict` passed.
- Final installed-engine rebuild after generator extraction: UHT analyzed `5830` functions, emitted `29` shards, and the editor target completed successfully (`4/4` final actions; the 525.57 second wall time included external UBA contention).
- Final `Tools/RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver"` passed `3/3`.
- Final UHT C# compilation after removing the legacy generator implementation passed with `0` warnings and `0` errors.
- Runtime-linked output simplification first established the negative contract: the old implementation built successfully, then `Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Engine.GeneratedFunctionBinding' -Label 'uht-single-module-binding-red-20260722' -TimeoutMs 900000` failed the new layout contract as expected (`2/3` passed; numeric filenames, missing `UHT.FunctionBinding.<Module>` names, and generated timing code were detected).
- Final installed-engine rebuild: `Tools\RunBuild.ps1 -Label 'uht-single-module-binding-helper-green-20260722' -TimeoutMs 1800000 -ExtraArgs '-NoHotReloadFromIDE'` passed. UHT analyzed `5830` functions, emitted `11` Runtime-linked module sources, with `1247` native registrations and `4583` reflective fallbacks. Each module has one public `FBind` named `UHT.FunctionBinding.<Module>`; the generated source may call private registration helpers capped at `256` bindings, which avoids MSVC C4883 for large modules while retaining one physical `.gen.cpp` and one public bind per module.
- `Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Engine.GeneratedFunctionBinding' -Label 'uht-single-module-binding-green-20260722' -TimeoutMs 900000` passed `3/3`. The generated files contain no numeric Runtime-linked suffix, `GeneratedFunctionBindingStartSeconds`, `RecordGeneratedFunctionBindingShardTiming`, or `[UHT] Registered` log string.
- `openspec validate refactor-uht-plugin-hardening --strict` and `openspec validate refactor-function-binding-strategy --strict` both passed after the output-layout update.
- User-requested full automation run: `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix 'uht-single-module-binding-all-20260722' -TimeoutMs 900000 -ContinueOnFail` completed all `36` groups. Its reported tests totalled `1543` passed, `22` failed, and `0` skipped, so this is not a green full-suite result. The new `GeneratedRuntimeModulesUseSingleNamedBindingFile` contract passed inside the Engine group as well as in the dedicated `3/3` focused run. The non-green outcomes are recorded for follow-up rather than attributed to this layout change: Editor `3` failures, Engine lifecycle/database/type-state `7` failures, FunctionLibraries `2` failures, StaticJIT `10` failures; AngelScriptSDK terminated with a fatal error before reporting results; ClassGenerator and ScriptClass each matched no tests; Debugger exceeded the `900000` ms automation-execution limit. Reports are under `Saved/Tests/uht-single-module-binding-all-20260722_*`.

## Blocked

- Full source-engine C++ build remains blocked by the repository's existing UE 5.8-to-UE 5.7 compatibility gap. The UE 5.7 run reports duplicate `CoreNative`/`FunctionCallers` declarations and unrelated UE API incompatibilities in existing Runtime/Editor code.
- The installed-engine target-mode rejection probe was validated before the final generator-only extraction; the extraction does not change Build.cs engine gating, while a dedicated target-mode runtime test remains unavailable when the installed-engine default is Runtime-linked.

## Lifecycle coverage

- UE 5.7.2 and UE 5.8 both expose `IModularFeatures::OnModularFeatureUnregistered`.
- `FCoreUObjectDelegates::OnObjectConstructed` is available for retrying unresolved `UClass` descriptors.
- The Runtime registry now owns feature state, invalidates queued work on unregister, removes owned `ClassFunctionBindings`, and requeues registered features when a new Angelscript bind state is initialized.
