## ADDED Requirements

### Requirement: Compile settings select one strict global function-binding method

The Angelscript compile-options object SHALL expose the UE enum `EAngelscriptFunctionBindingMethod` through the `FunctionBindingMethod` property. The enum SHALL provide exactly `None`, `NativeRuntimeLinked`, and `NativeModuleFunctionAddress`. The selected method SHALL apply globally to the project/target; UHT SHALL NOT silently combine automatic backends for the same generation.

#### Scenario: UE config stores the semantic enum token

- **WHEN** the project compile-options configuration is inspected
- **THEN** it stores `FunctionBindingMethod=NativeRuntimeLinked` or another supported enumerator token under `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]`
- **AND** the C++ Editor property uses the UE enum
- **AND** UBT and UHT consume the same canonical enumerator names

#### Scenario: Missing method uses the migration default

- **WHEN** the method value is absent from the compile-options configuration
- **THEN** UBT and UHT select `NativeRuntimeLinked`
- **AND** they do not infer the method from the removed legacy boolean key

#### Scenario: Invalid method value is rejected

- **WHEN** the configuration contains an unsupported method token
- **THEN** UBT or UHT reports an actionable configuration error
- **AND** the build does not silently select a different binding backend

### Requirement: Compile settings configure the two module sets

The compile-options object SHALL expose `NativeRuntimeLinkedModules` and `NativeModuleFunctionAddressModules` as UE-configured `TArray<FName>` properties. The arrays SHALL be serialized using UE array syntax such as `+NativeRuntimeLinkedModules=Engine`. The arrays SHALL be method-specific candidate sets; the selected global method determines which array is active for a generation.

#### Scenario: Runtime-linked modules are configured in INI

- **WHEN** `FunctionBindingMethod=NativeRuntimeLinked` and the config contains `+NativeRuntimeLinkedModules=Engine`
- **THEN** UBT and UHT include `Engine` in the effective Runtime-linked module set
- **AND** the module is eligible for automatic Runtime-linked generation only if `AngelscriptRuntime` can legally depend on it

#### Scenario: Target modules are configured in INI

- **WHEN** `FunctionBindingMethod=NativeModuleFunctionAddress` and the config contains `+NativeModuleFunctionAddressModules=MyGameplayPlugin`
- **THEN** UHT includes `MyGameplayPlugin` in the effective target-module set
- **AND** it does not require a JSON profile to discover that module

### Requirement: Runtime-linked module configuration drives Build.cs dependencies and wrappers

For every effective `NativeRuntimeLinkedModules` item, `AngelscriptRuntime.Build.cs` SHALL dynamically add the module as a legal Runtime dependency and SHALL generate the wrapper files required to compile that module's UHT binding shards. The module array SHALL control automatic binding scope without replacing fixed Runtime implementation dependencies.

#### Scenario: Configured Runtime-linked module gets a wrapper

- **WHEN** `Engine` is in `NativeRuntimeLinkedModules`
- **THEN** Build.cs adds the required Runtime dependency if it is not already present
- **AND** Build.cs generates wrappers for `AS_FunctionBinding_Engine_*.gen.cpp`
- **AND** UHT may generate Runtime-linked shards for `Engine`

#### Scenario: Illegal Runtime-linked module is rejected

- **WHEN** a configured Runtime-linked module cannot be resolved or would create an invalid dependency direction
- **THEN** UBT reports the module name and dependency error
- **AND** the build does not accept partial generated binding output

### Requirement: Legacy module-binding compile configuration is removed

The active implementation SHALL completely remove `bCompileAngelscriptModuleBindings`, `WITH_ANGELSCRIPT_MODULE_BINDINGS`, and the JSON module profile files as configuration sources. The replacement SHALL be `FunctionBindingMethod` plus the two UE module arrays.

#### Scenario: Legacy configuration does not control generation

- **WHEN** a project still contains only the old boolean or old JSON profile
- **THEN** active UBT/UHT logic does not use them as a binding-method or module-set source
- **AND** the project receives migration guidance to use the UE compile-options properties

### Requirement: None disables all automatic UHT function binding

When `None` is selected, UHT SHALL emit no automatic Runtime-linked registrations, target-module registrations, or fallback-only `ERASE_NO_FUNCTION()` records. Handwritten `Bind_*.cpp` registrations and the Runtime binding framework SHALL remain available.

#### Scenario: None emits no automatic registrations

- **WHEN** `FunctionBindingMethod=None` and UHT processes AS-callable UFunctions
- **THEN** no automatic function-binding registration source is emitted
- **AND** generated statistics identify automatic function binding as disabled

#### Scenario: None leaves handwritten bindings available

- **WHEN** `None` is selected
- **THEN** existing handwritten binding translation units remain compilable and registrable
- **AND** selecting `None` does not remove the Runtime binding registry itself

### Requirement: NativeRuntimeLinked preserves the Runtime-linked fallback path

When `NativeRuntimeLinked` is selected, UHT SHALL generate the normal Runtime-linked registration shards for the effective configured Runtime-linked module set. Link-visible functions SHALL use the `NativeRuntimeLinked` category. Functions without a usable native pointer SHALL retain the automatic `ReflectiveFallback` path through a fallback-only generated binding record.

#### Scenario: Link-visible function uses native Runtime-linked binding

- **WHEN** an eligible UFunction belongs to an effective Runtime-linked module and its declaration is link-visible through an API macro, inline definition, or equivalent supported rule
- **THEN** the generated registration is classified as `NativeRuntimeLinked`
- **AND** the registration does not require `NativeModuleFunctionAddress`

#### Scenario: Missing native address uses reflective fallback

- **WHEN** an eligible Runtime-linked UFunction cannot provide a usable native address but satisfies the reflection fallback contract
- **THEN** the generated binding record is classified as `ReflectiveFallback`
- **AND** `Bind_BlueprintCallable` can complete the record through the existing reflection fallback implementation

### Requirement: NativeModuleFunctionAddress uses explicit target-module arrays

When `NativeModuleFunctionAddress` is selected, UHT SHALL emit only safe target-module thunk shards for effective `NativeModuleFunctionAddressModules`. It SHALL NOT emit ordinary Runtime-linked automatic binding output for the same generation and SHALL NOT silently fall back to API binding. The configured target set MAY contain Engine, Engine plugin, project, or project plugin modules that are present in the current UHT session.

#### Scenario: Safe function emits target-module thunk

- **WHEN** a safe AS-callable UFunction belongs to an effective configured target module
- **THEN** UHT emits the `NativeModuleFunctionAddress` shard into that module's output directory
- **AND** the generated thunk invokes the target module's C++ function inside that module's compilation boundary
- **AND** the target module publishes the binding payload through the Runtime bridge

#### Scenario: Unsupported target-module signature is skipped

- **WHEN** a configured target-module UFunction violates the current safe-signature contract
- **THEN** UHT emits no target-module thunk for that function
- **AND** the function is recorded as a skipped diagnostic with its safety failure reason
- **AND** UHT does not generate a Runtime-linked API binding for it

#### Scenario: Unconfigured module is warning-only

- **WHEN** a UHT module contains AS-callable functions but is absent from `NativeModuleFunctionAddressModules`
- **THEN** UHT reports a profile-miss/configuration warning
- **AND** it records the functions in skipped statistics
- **AND** it does not silently activate another automatic backend

### Requirement: NativeModuleFunctionAddress requires a source-built engine

The `NativeModuleFunctionAddress` method SHALL be accepted only when the engine distribution is classified as `SourceBuilt`. Installed and unknown distributions MUST reject the method during Editor validation, UBT evaluation, or UHT generation.

#### Scenario: Source-built engine accepts the method

- **WHEN** `NativeModuleFunctionAddress` is selected with a `SourceBuilt` engine
- **THEN** Editor validation accepts the setting
- **AND** UBT and UHT may generate target-module output subject to configured module and signature safety rules

#### Scenario: Installed or unknown engine rejects the method

- **WHEN** `NativeModuleFunctionAddress` is selected with an `Installed` or `Unknown` engine
- **THEN** the Editor shows an actionable error and rejects the setting change
- **AND** direct UBT/UHT configuration fails with an error naming the required source-built engine condition

### Requirement: Binding backends conflict at generation time

`NativeRuntimeLinked` and `NativeModuleFunctionAddress` SHALL be mutually exclusive automatic output categories for one function/module in one generation. The selected method SHALL activate only its corresponding module array. UHT SHALL detect an ambiguous native-plus-target-module output state before committing generated files.

#### Scenario: One module receives only one output family

- **WHEN** a module is active under `NativeRuntimeLinked`
- **THEN** UHT emits only Runtime-linked binding shards for that module
- **AND** it emits no target-module function-address shard for the same generation

#### Scenario: Ambiguous output is rejected before commit

- **WHEN** generation would classify the same function/module as both `NativeRuntimeLinked` and `NativeModuleFunctionAddress`
- **THEN** UHT reports the module/function and both conflicting categories
- **AND** it commits neither ambiguous output family

### Requirement: Function-binding diagnostics use category and statistics terminology

Generated summaries and CSV diagnostics SHALL distinguish `NativeRuntimeLinked`, `ReflectiveFallback`, and `NativeModuleFunctionAddress` through `FunctionBindingCategory`. Aggregate diagnostics SHALL use `FunctionBindingStatistics` terminology and SHALL report analyzed-function counts separately from generated shard counts.

#### Scenario: Statistics use analyzed functions as the rate denominator

- **WHEN** UHT writes function-binding statistics
- **THEN** it reports `AnalyzedFunctionCount`, category counts, and `SkippedFunctionCount`
- **AND** category rates use `AnalyzedFunctionCount` as the denominator
- **AND** shard count is reported as a separate output metric

#### Scenario: Diagnostics do not use legacy categories

- **WHEN** UHT writes binding diagnostics
- **THEN** it does not use generic `Direct`, `Stub`, or `ModuleBinding` category values
- **AND** it uses the final `FunctionBindingCategory` values consistently in JSON, CSV, logs, tests, and documentation

### Requirement: Function-binding artifacts use the final outer vocabulary

The UHT exporter identifier SHALL be `AngelscriptFunctionBinding`, generated source shards SHALL use the `AS_FunctionBinding_` prefix, and the source-owned bridge SHALL live under `Source/AngelscriptRuntime/FunctionBinding/`. Old artifact names SHALL not be emitted as production output.

#### Scenario: New output uses FunctionBinding names

- **WHEN** UHT generates Runtime-linked or target-module output
- **THEN** generated source, statistics, and bridge identifiers use the final `FunctionBinding` vocabulary
- **AND** target-module descriptors use `FAngelscriptNativeModuleFunctionBinding`

#### Scenario: Old output is cleaned during migration

- **WHEN** UHT runs after a previous generation using legacy artifact names
- **THEN** stale cleanup removes matching legacy `AS_FunctionTable_*` artifacts
- **AND** the current generation emits only `AS_FunctionBinding_*` artifacts
