## Context

The current UHT pipeline has two generated output families:

- Runtime-linked modules produce one `AS_FunctionBinding_<Module>.gen.cpp` source per configured module, compiled through one guarded `AngelscriptRuntime` aggregator. Link-visible functions use a native C++ pointer. Functions without a usable pointer receive an empty binding record and can later be completed by `BlueprintCallableReflectiveFallback`. The source may use private bounded helper functions to stay below MSVC's function-size limit, but exposes one Runtime-linked callback with the stable bind name `UHT.FunctionBinding.<Module>`.
- Modules outside the Runtime-linked path can produce target-module shards in the module output directory. Those shards compile a module-local thunk and publish a POD binding payload through `IModularFeatures`; `AngelscriptRuntime` consumes the payload through the shared bridge.

The previous implementation derived Runtime-linked modules by parsing `AngelscriptRuntime.Build.cs` dependency blocks, while the same Build.cs separately maintained a hand-written generated-wrapper list. Target-module generation was controlled by a second JSON profile and a legacy boolean. These were different concerns and could drift.

The final design makes `UAngelscriptCompileOptions` the project-owned source of the selected binding method and the two method-specific module arrays. `Build.cs` consumes the same INI data to add Runtime-linked dependencies and generate wrappers. UHT consumes the same values to select one output family.

## Goals / Non-Goals

**Goals:**

- Introduce one project-wide UE enum setting that selects the automatic UHT binding method.
- Configure Runtime-linked and target-module module sets through UE `TArray<FName>` config properties.
- Dynamically add configured Runtime-linked modules to `AngelscriptRuntime` and generate their wrappers.
- Make `None`, `NativeRuntimeLinked`, and `NativeModuleFunctionAddress` strict, distinguishable modes.
- Preserve Runtime-linked reflection fallback while making `None` genuinely disable automatic UHT registrations.
- Keep target-module generation source-engine-only and limited to safe signatures.
- Retire the JSON profile/policy files as active configuration sources.
- Keep the bridge ABI source-owned and stable across Runtime and target-module compilation.
- Separate policy, analysis, signature resolution, emission, diagnostics, and stale-output responsibilities around one shared analysis result.

**Non-Goals:**

- Do not expand the automatic marshalling safety set.
- Do not add target-module reflection-only payload records in this change.
- Do not redesign `FAngelscriptFunctionBinding` as a runtime data structure.
- Do not change the current Modular Feature payload layout unless a separate ABI change is approved.
- Do not remove handwritten `Bind_*.cpp` files.
- Do not solve target-module unload or hot-reload pointer revocation in this naming/policy refactor.
- Do not infer arbitrary project-module dependencies into `AngelscriptRuntime`; UBT dependency cycles remain invalid.

## Decisions

### 1. Use one UE enum for the global method

`UAngelscriptCompileOptions` exposes:

- Enum type: `EAngelscriptFunctionBindingMethod`
- Property: `FunctionBindingMethod`
- Values: `None`, `NativeRuntimeLinked`, and `NativeModuleFunctionAddress`

The setting is serialized by UE as a semantic config token:

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
FunctionBindingMethod=NativeRuntimeLinked
```

UBT and UHT cannot share the C++ enum binary type, so they parse the same canonical tokens at their build boundaries. Missing values default to `NativeRuntimeLinked`; unsupported values fail with an actionable error.

### 2. Configure module sets as UE arrays

The compile-options object also exposes:

```cpp
TArray<FName> NativeRuntimeLinkedModules;
TArray<FName> NativeModuleFunctionAddressModules;
```

The corresponding UE config syntax is:

```ini
+NativeRuntimeLinkedModules=Engine
+NativeRuntimeLinkedModules=UMG
+NativeModuleFunctionAddressModules=Engine
+NativeModuleFunctionAddressModules=MyGameplayPlugin
```

The two arrays are method-specific candidate sets. They may contain the same module when a project wants to switch global methods, but one generation activates only the array selected by `FunctionBindingMethod`.

### 3. Separate dependency capability from automatic binding scope

`AngelscriptRuntime.Build.cs` retains its fixed dependencies required by Runtime implementation. `NativeRuntimeLinkedModules` is an additional automatic-binding configuration:

- each configured module is validated as a legal Runtime dependency;
- Build.cs dynamically adds it to the appropriate dependency set, using private dependency visibility for generated binding compilation unless the module is already public;
- Build.cs dynamically generates one guarded Runtime aggregator for that module;
- UHT generates one Runtime-linked binding source only for each configured module that has registrations.

The module array is therefore the source of automatic binding intent, while Build.cs dependencies remain the link contract. A configured module that would create a dependency cycle or cannot be resolved by UBT fails before successful generation.

The Runtime-linked source-count policy is fixed at one source per configured module and is not exposed as a user-facing module configuration array. The aggregator uses `__has_include` so a module with no registrations produces no missing-include error. Source-engine target-module thunk sharding remains an implementation detail of that separate output family.

### 4. Use one strict global backend per generation

`None` emits no automatic Runtime-linked registrations, target-module registrations, or fallback-only `ERASE_NO_FUNCTION()` records. Handwritten `Bind_*.cpp` registrations and the Runtime binding framework remain available.

`NativeRuntimeLinked` activates only `NativeRuntimeLinkedModules`. It emits one named Runtime-linked generated registration source per module. Link-visible functions are classified as `NativeRuntimeLinked`; functions without a usable native address retain the existing `ReflectiveFallback` path through an empty generated binding record. The generated callback does not emit per-module registration timing or logging.

`NativeModuleFunctionAddress` activates only `NativeModuleFunctionAddressModules`. It emits safe target-module thunk shards and does not emit Runtime-linked/API binding output for the same generation. Unsupported signatures are skipped with explicit diagnostics.

`FunctionBindingCategory` is a per-function result category, not a second global setting. `NativeRuntimeLinked` and `NativeModuleFunctionAddress` cannot both classify the same function in one generation. `ReflectiveFallback` may coexist with `NativeRuntimeLinked` across different functions in Runtime-linked mode.

### 5. Enforce conflicts before committing generated output

UHT computes the selected method and effective module array before calling `CommitOutput`. It rejects a configuration or generation state that would cause one module/function to receive both automatic output families. The conflict is reported at generation time rather than being resolved by Runtime registration order.

When switching methods, stale cleanup removes the inactive method's old generated outputs after a successful generation. The old output family is never emitted as a compatibility duplicate.

### 6. Retire JSON profiles and use explicit target-module arrays

The old `module-binding-generation-modules.json` and the planned `native-module-function-address-profiles.json` are not active configuration sources. Their `enabled`, `common`, `source`, and `installed` fields are removed from the implementation.

`NativeModuleFunctionAddressModules` is an explicit allowlist. It may contain Engine modules, Engine plugin modules, project modules, or project plugin modules, provided they appear in the current UHT session and satisfy the target-module emission rules. The system does not auto-scan every module.

The global source-built engine requirement remains in force even for explicitly configured project/plugin modules. Relaxing that requirement for non-Engine modules would be a separate change.

Unconfigured modules with AS-callable functions are warning-only and contribute to profile-miss/skipped statistics; they do not silently fall back to Runtime-linked/API output.

### 7. Preserve source-engine validation

Engine distribution is classified as `SourceBuilt`, `Installed`, or `Unknown`. `NativeModuleFunctionAddress` is accepted only for `SourceBuilt`. Editor settings validation rejects and restores an invalid change before saving; direct UBT and UHT configuration also fails. `NativeRuntimeLinked` and `None` remain valid for installed and unknown distributions.

The Editor, UBT, and UHT implementations must preserve the same marker precedence: `InstalledBuild.txt` identifies installed builds first; source distribution markers identify source builds; otherwise the result is `Unknown` rather than silently treating the engine as source-built.

### 8. Keep the bridge source-owned

The shared bridge header is source code at:

```text
Source/AngelscriptRuntime/FunctionBinding/NativeModuleFunctionBindingBridge.h
```

It is not a generated UHT header. UHT generates only target-module `.cpp` shards into the target module's output directory. This keeps the ABI contract available before UHT generation and allows the Runtime and target module to compile against exactly the same layout/version contract.

### 9. Define statistics independently from generated shard count

`FunctionBindingStatistics` reports analyzed functions and category counts separately:

- `AnalyzedFunctionCount`
- `NativeRuntimeLinkedCount`
- `ReflectiveFallbackCount`
- `NativeModuleFunctionAddressCount`
- `SkippedFunctionCount`

Rates use `AnalyzedFunctionCount` as the denominator. Generated shard count is a separate build-output metric.

### 10. Apply the naming and compatibility policy

The UHT exporter identifier becomes `AngelscriptFunctionBinding`. The generated prefix becomes `AS_FunctionBinding_`. The target-module bridge and descriptor use the confirmed `NativeModuleFunctionBinding` vocabulary. `ThunkStyle` is removed because the final category and method names provide the required semantic classification.

The old configuration key and JSON profile files are not read. Old generated files are not emitted, but stale-output cleanup keeps the old `AS_FunctionTable_*` patterns for one migration cycle so switching branches cannot leave obsolete shards compiled. JSON/CSV diagnostic consumers must migrate to the new names; no dual production schema is emitted.

### 11. Split UHT around one analysis result

The generator now has responsibility-oriented methods for:

- module configuration loading;
- shared per-function analysis;
- Runtime-linked emission;
- target-module emission;
- statistics and diagnostics writing;
- stale-output cleanup;
- `AngelscriptFunctionBindingExporter` dispatch.

The module-configuration type reads the canonical compile-option arrays; it is not a separate user-facing policy file. All output, statistics, and skipped-function diagnostics consume one `AngelscriptFunctionBindingAnalysisResult` per analyzed UFunction. No downstream writer or emitter performs an independent classification pass.

## Risks / Trade-offs

- [Risk] Dynamic Runtime dependencies can create illegal dependency cycles. → Validate every configured module with UBT and report the module name and dependency direction before generation succeeds.
- [Risk] A configured module can produce more shards than the generated wrapper upper bound. → Use a documented fixed bound and fail with a clear diagnostic rather than silently dropping shards.
- [Risk] A strict global method may expose fewer functions than the previous hybrid implementation. → Report configured/effective modules, skipped functions, and profile misses clearly; do not silently re-enable API binding.
- [Risk] Removing the old configuration key and JSON profile breaks existing projects. → Treat both as intentional breaking migrations and document the exact UE array replacement.
- [Risk] Removing fallback-only records under `None` changes script visibility for UHT-discovered functions. → Make the behavior explicit in settings documentation and test that handwritten bindings remain available.
- [Risk] Splitting the generator can make output and statistics disagree. → Require consistency tests over the shared analysis result.

## Migration Plan

1. Add the UE enum and the two `TArray<FName>` properties.
2. Populate the checked-in default arrays from the current Runtime wrapper module list and set `FunctionBindingMethod=NativeRuntimeLinked`.
3. Make UBT and UHT parse UE array config syntax and dynamically derive Runtime dependencies/wrappers from `NativeRuntimeLinkedModules`.
4. Remove the old boolean key, old compile macro, and JSON profile loading.
5. Implement strict `None`, Runtime-linked, and target-module method branches with generation-time conflict validation.
6. Rename generated symbols, diagnostics, files, and bridge names; retain old patterns only for stale cleanup.
7. Refactor UHT around the shared analysis result.
8. Run focused method, config-array, dependency/wrapper, source-distribution, output, statistics, and Runtime injection tests.

Rollback is a source-level revert of the implementation commit. No compatibility output is intentionally maintained after the migration cycle.

## Open Questions

None. The module source, target-module scope, profile retirement, and configuration-array model are confirmed for implementation.
