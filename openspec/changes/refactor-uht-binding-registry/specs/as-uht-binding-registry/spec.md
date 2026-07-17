## ADDED Requirements

### Requirement: UHT callable targets use canonical Runtime registration terminology

The Angelscript Runtime SHALL expose a canonical function-binding registration operation for UHT-produced and cross-module callable targets. The canonical operation SHALL describe registration of a callable target into the Runtime registry and SHALL NOT imply that AngelScript has already registered the final script function.

#### Scenario: Same-module generated shard registers a callable target

- **WHEN** a generated same-module function-table shard initializes
- **THEN** it calls the canonical function-binding registration operation
- **AND** the operation records the target in the Runtime function-binding registry
- **AND** the later BlueprintCallable pass remains responsible for AngelScript registration

#### Scenario: Cross-module injection registers a callable target

- **WHEN** `Bind_CrossModuleDirect.cpp` consumes a valid cross-module feature payload
- **THEN** it uses the canonical Runtime registration operation
- **AND** it preserves the existing Generic Call hook and per-function user-data behavior

### Requirement: Function-binding registration preserves existing precedence semantics

The canonical registration operation SHALL preserve the current duplicate policy. An existing valid direct binding or reflective-fallback binding SHALL not be overwritten by a later registration. An empty/stub slot MAY be replaced only by a later registration with a bound callable target.

#### Scenario: Existing direct binding wins

- **WHEN** a function slot already contains a bound direct callable target
- **AND** a later generated or cross-module registration targets the same class and function
- **THEN** the existing target remains unchanged

#### Scenario: Stub slot is upgraded by a bound target

- **WHEN** a function slot contains an unbound stub with no reflective fallback state
- **AND** a later registration supplies a bound callable target
- **THEN** the slot is replaced by the bound target

### Requirement: Internal binding records distinguish Runtime bindings from ABI payloads

The Runtime registry record, UHT generator records, and cross-module ABI payload records SHALL use distinct semantic names in source code. This terminology refactor MUST NOT change the cross-module feature name, field layout, flag meanings, layout-version token, generated artifact file names, or diagnostic artifact field names.

#### Scenario: Generated artifact schema remains compatible

- **WHEN** the UHT generator emits function-table diagnostics after the refactor
- **THEN** `AS_FunctionTable_Entries.csv`, `AS_FunctionTable_Summary.json`, and skipped-entry outputs retain their existing file names and schema fields
- **AND** internal source names may use `Binding` terminology without changing those artifact contracts

#### Scenario: Cross-module ABI remains compatible

- **WHEN** existing cross-module link-probe and runtime tests compile against the refactored source
- **THEN** the public cross-module POD sizes, feature name, flags, and layout-version validation remain unchanged
- **AND** existing direct-bind and reflective-fallback behavior remains unchanged

### Requirement: Legacy Runtime-side and cross-module names are removed

The refactor SHALL remove the legacy Runtime-side registry names and the legacy cross-module protocol names. New production code, generated output, tests, active specifications, and maintained documentation SHALL use the canonical function-binding vocabulary. Mixed old/new cross-module producers are not supported because the Modular Feature key changes.

#### Scenario: Old Runtime registry names are absent

- **WHEN** the migrated Runtime and generated source is compiled
- **THEN** `FFuncEntry`, `AddFunctionEntry`, `ClassFuncMaps`, and `GetClassFuncMaps` are not declared or referenced
- **AND** `FAngelscriptFunctionBinding`, `RegisterFunctionBinding`, `ClassFunctionBindings`, and `GetClassFunctionBindings` are used instead

#### Scenario: Cross-module protocol names are migrated together

- **WHEN** a target-module shard and AngelscriptRuntime are rebuilt
- **THEN** both use `FAngelscriptCrossModuleBinding`, `FAngelscriptCrossModuleBindingFeatureReader`, and `AngelscriptCrossModuleFunctionBindings`
- **AND** the old public header and Modular Feature key are not used

### Requirement: ModuleLocal binding compilation is explicitly opt-in

The project SHALL expose `bCompileAngelscriptModuleLocalBindings` in `UAngelscriptCompileOptions`, default it to `false`, and derive `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS` from the same project ini value in `AngelscriptRuntime.Build.cs`. The macro SHALL gate the Runtime module-local binding bridge, while UHT SHALL use the setting to gate emitted module-local shards and link-probe output.

#### Scenario: Default configuration leaves ModuleLocal bindings disabled

- **WHEN** `bCompileAngelscriptModuleLocalBindings=false`
- **THEN** UBT defines `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS=0`
- **AND** the Runtime ModuleLocal bridge is excluded from compilation
- **AND** UHT does not emit module-local binding shards or the link probe

#### Scenario: Enabled source-engine configuration compiles ModuleLocal bindings

- **WHEN** `bCompileAngelscriptModuleLocalBindings=true`
- **AND** the engine is classified as a source engine
- **THEN** UBT defines `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS=1`
- **AND** UHT may emit the configured module-local shards
- **AND** the Runtime bridge is compiled to consume their modular-feature payloads

### Requirement: ModuleLocal bindings require a source engine

The Editor, UBT, and UHT SHALL independently reject an enabled ModuleLocal binding option when the engine is installed, binary, or unknown. Installed classification SHALL take precedence over source-control markers, and unknown classification SHALL be treated as non-source.

#### Scenario: Editor rejects enabling ModuleLocal bindings on an installed engine

- **WHEN** the Project Settings value changes to `true` on a non-source engine
- **THEN** the Editor shows an actionable error stating that ModuleLocal bindings require a source engine
- **AND** restores the setting to `false`
- **AND** returns `false` from `ISettingsSection::OnModified` so the ini is not saved

#### Scenario: UBT rejects a direct ini edit on an installed engine

- **WHEN** the ini directly sets `bCompileAngelscriptModuleLocalBindings=true` on a non-source engine
- **THEN** `AngelscriptRuntime.Build.cs` raises a build error containing the engine classification/path and the source-engine requirement
- **AND** the Runtime bridge is not compiled

#### Scenario: UHT rejects a direct ini edit before generation

- **WHEN** the ini directly sets `bCompileAngelscriptModuleLocalBindings=true` on a non-source engine
- **THEN** `AngelscriptUHTTool` raises a generation error containing the engine classification/path and the source-engine requirement
- **AND** it emits no ModuleLocal shard or link-probe output
