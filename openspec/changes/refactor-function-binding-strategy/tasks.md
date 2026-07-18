## 1. Confirm the binding method contract

- [x] 1.1 Confirm the UE enum type and property: `EAngelscriptFunctionBindingMethod` / `FunctionBindingMethod`.
- [x] 1.2 Confirm the final method values: `None`, `NativeRuntimeLinked`, and `NativeModuleFunctionAddress`.
- [x] 1.3 Confirm the final `FunctionBindingCategory` values: `NativeRuntimeLinked`, `ReflectiveFallback`, and `NativeModuleFunctionAddress`.
- [x] 1.4 Confirm that `None` disables all automatic UHT registrations, including fallback-only records.
- [x] 1.5 Confirm that `NativeRuntimeLinked` retains automatic `ReflectiveFallback`.
- [x] 1.6 Confirm the target-module binding descriptor name: `FAngelscriptNativeModuleFunctionBinding`; do not use `Entry` or `Protocol` as final identifiers.
- [x] 1.7 Confirm the per-function statistics category name: `FunctionBindingCategory`.
- [x] 1.8 Confirm the aggregate statistics name: `FunctionBindingStatistics`.
- [x] 1.9 Confirm the shared bridge names and source-owned bridge-header direction.
- [x] 1.10 Confirm the method-specific compile capability macro vocabulary: `WITH_ANGELSCRIPT_NATIVE_MODULE_FUNCTION_ADDRESS`.
- [x] 1.11 Confirm UE-configured module arrays: `NativeRuntimeLinkedModules` and `NativeModuleFunctionAddressModules`.
- [x] 1.12 Confirm the old JSON profile/policy files are retired as active configuration sources.
- [x] 1.13 Confirm the UHT outer concept and generated source prefix: `FunctionBinding` / `AS_FunctionBinding_`.
- [x] 1.14 Confirm that the selected method is strict and global rather than a hybrid per-module fallback selector.
- [x] 1.15 Confirm UE enum and array config serialization, including `+ArrayProperty=ModuleName` syntax.
- [x] 1.16 Confirm that Runtime-linked modules must be legal `AngelscriptRuntime` dependencies and Build.cs dynamically adds them.
- [x] 1.17 Confirm that target-module arrays may explicitly name Engine, plugin, or project modules present in the UHT session.
- [x] 1.18 Confirm that `NativeRuntimeLinked` and `NativeModuleFunctionAddress` conflict at generation time for the same function/module.

## 2. Define the compile method and config model

- [x] 2.1 Add `EAngelscriptFunctionBindingMethod` and the `FunctionBindingMethod` property to `UAngelscriptCompileOptions` with `NativeRuntimeLinked` as the default.
- [x] 2.2 Add `TArray<FName> NativeRuntimeLinkedModules` and `TArray<FName> NativeModuleFunctionAddressModules` to `UAngelscriptCompileOptions`.
- [x] 2.3 Make UBT and UHT parse the canonical UE enum tokens and UE array config syntax.
- [x] 2.4 Remove `bCompileAngelscriptModuleBindings` and `WITH_ANGELSCRIPT_MODULE_BINDINGS` from active configuration/build logic.
- [x] 2.5 Remove active loading of `module-binding-generation-modules.json` and any successor profile JSON.
- [x] 2.6 Write the checked-in default method and Runtime-linked module array values.
- [x] 2.7 Add tri-state source/installed/unknown engine validation for `NativeModuleFunctionAddress`.
- [x] 2.8 Add Editor validation that rejects and does not save an invalid target-module method on non-source engines.

## 3. Dynamically configure Runtime-linked generation

- [x] 3.1 Read `NativeRuntimeLinkedModules` in `AngelscriptRuntime.Build.cs` and register the config file as an external dependency.
- [x] 3.2 Dynamically add configured Runtime-linked modules as legal Runtime dependencies without replacing fixed implementation dependencies.
- [x] 3.3 Dynamically generate Runtime wrapper files for each configured Runtime-linked module.
- [x] 3.4 Validate unresolved modules and dependency-cycle risks before accepting the build.
- [x] 3.5 Enforce a documented wrapper shard upper bound and report overflow instead of silently dropping generated shards.
- [x] 3.6 Make UHT generate Runtime-linked shards only for the configured Runtime-linked module array.

## 4. Enforce strict method and module boundaries

- [x] 4.1 Make `None` suppress Runtime-linked, target-module, and fallback-only automatic UHT output.
- [x] 4.2 Preserve Runtime-linked native bindings plus automatic reflection fallback under `NativeRuntimeLinked`.
- [x] 4.3 Make `NativeModuleFunctionAddress` emit only target-module shards for effective configured target modules.
- [x] 4.4 Skip unsafe target-module signatures with explicit diagnostics and no API fallback.
- [x] 4.5 Reject ambiguous Runtime-linked plus target-module output before committing generated files.
- [x] 4.6 Make target-module generation warning-only for unconfigured modules and include profile-miss/skipped statistics.

## 5. Migrate terminology and artifacts

- [x] 5.1 Rename UHT domain records and fields according to `naming-map.md`.
- [x] 5.2 Rename `FunctionBindingCategory` values and `FunctionBindingStatistics` fields in JSON, CSV, logs, and tests.
- [x] 5.3 Rename the UHT exporter identifier to `AngelscriptFunctionBinding` and split the Runtime bridge names/files.
- [x] 5.4 Rename generated prefixes, output files, bridge files, layout-version files, and compile-capability macros.
- [x] 5.5 Remove `DirectBind`, `Stub`, `ModuleBinding`, `EntryKind`, `Protocol`, `ThunkStyle`, and active profile/policy identifiers from final names.
- [x] 5.6 Update tests, CSV/JSON readers, documentation, and migration guidance.
- [x] 5.7 Do not emit legacy output names; retain legacy patterns only in stale-output cleanup for one migration cycle.

## 6. Verify each method and configuration path

- [x] 6.1 Verify UE enum and array serialization through Project Settings and `DefaultAngelscriptCompileOptions.ini`.
- [x] 6.2 Verify dynamic Runtime dependencies and wrapper generation from `NativeRuntimeLinkedModules`.
- [x] 6.3 Verify `None` emits no automatic entries and handwritten bindings remain available.
- [x] 6.4 Verify `NativeRuntimeLinked` direct binding and `ReflectiveFallback` behavior on installed and unknown engines.
- [ ] 6.5 Verify source-engine `NativeModuleFunctionAddress` output, explicit target-module arrays, safe-signature filtering, and target-module registration.
- [ ] 6.6 Verify installed/unknown source validation and Editor save rejection.
- [x] 6.7 Verify generation-time backend conflict rejection and stale-output cleanup.
- [x] 6.8 Verify statistics denominators, category counts, skipped/profile-miss counts, and shard counts.
- [x] 6.9 Run focused UHT, generated-binding, compile-settings, Editor validation, dependency, and Runtime injection tests.

## 7. Refactor the UHT pipeline

- [x] 7.1 Introduce one `AngelscriptFunctionBindingAnalysisResult` per analyzed UFunction containing eligibility, category, signature data, target-module binding data, includes, and failure reason.
- [x] 7.2 Make `AngelscriptFunctionBindingExporter` and all emitters consume the shared analysis result instead of independently reclassifying UFunctions.
- [ ] 7.3 Split module configuration loading, function analysis, signature resolution, Runtime-linked emission, target-module emission, statistics writing, and stale-output cleanup into responsibility-oriented types.
- [x] 7.4 Replace duplicated Build.cs/UHT configuration interpretation with canonical method tokens and module arrays.
- [x] 7.5 Add consistency tests proving generated output, `FunctionBindingStatistics`, and skipped-function diagnostics agree for the same analyzed functions.
