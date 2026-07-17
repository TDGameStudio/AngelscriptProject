## ADDED Requirements

### Requirement: Module binding protocol uses canonical names

The module-provided callable binding protocol SHALL use `ModuleBinding` names for its public header, POD records, protocol namespace, Modular Feature key, Runtime bridge, and UHT generator output. The protocol SHALL preserve the existing field order, sizes, flag meanings, and layout token value.

#### Scenario: Runtime and generated producer use one protocol vocabulary

- **WHEN** `AngelscriptRuntime` consumes a target-module binding feature and UHT emits a target-module shard
- **THEN** both sides use the `AngelscriptModuleBinding` protocol vocabulary
- **AND** neither side uses the legacy `CrossModule` protocol symbols
- **AND** the call-frame, binding, and feature-view sizes remain `48`, `32`, and `32` bytes

### Requirement: Module binding artifacts use canonical names

The UHT tool SHALL write target-module binding shards as `AS_FunctionTable_<Module>_ModuleBinding_<NNN>.cpp`, use `module-binding-generation-modules.json` and `module-binding-layout-version.txt` as its owned configuration files, and remove stale outputs matching the new artifact pattern.

#### Scenario: Target module receives a ModuleBinding shard

- **WHEN** ModuleLocal binding generation is enabled for a profile-configured module
- **THEN** the shard is emitted into that module's UHT `OutputDirectory`
- **AND** the filename contains `_ModuleBinding_`
- **AND** no new `_CrossModule_` shard is emitted

### Requirement: Module binding diagnostics use canonical fields

Generated JSON, CSV, entry-kind values, and binding-protocol skip reasons SHALL use `ModuleBinding` terminology. Direct, stub, safety, and profile behavior SHALL remain unchanged.

#### Scenario: Summary reports ModuleBinding counts

- **WHEN** UHT writes `AS_FunctionTable_Summary.json`
- **THEN** it reports `totalModuleBindingEntries`, `moduleBindingRate`, and `moduleBindingGenerationEnabled`
- **AND** module summaries report `moduleBindingEntries` and `moduleBindingRate`

#### Scenario: Entry diagnostics classify ModuleBinding rows

- **WHEN** UHT writes `AS_FunctionTable_Entries.csv`
- **THEN** ModuleBinding rows use `EntryKind=ModuleBinding`
- **AND** no binding-path row uses `EntryKind=CrossModule`

### Requirement: ModuleLocal remains the compile-policy vocabulary

The existing `bCompileAngelscriptModuleLocalBindings` setting and `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS` macro SHALL remain unchanged because they describe compilation location and opt-in policy rather than the ModuleBinding protocol.

#### Scenario: Compile gate remains stable during naming migration

- **WHEN** the project uses the existing ModuleLocal compile option
- **THEN** UBT, UHT, Editor validation, and Runtime conditional compilation continue to use the same setting and macro names
- **AND** only the binding protocol and generated artifact vocabulary changes

### Requirement: Unrelated cross-module terminology remains unchanged

The migration SHALL NOT rename “cross-module” terminology used by unrelated AngelScript compiler dependency semantics or other non-ModuleBinding behavior.

#### Scenario: Builder dependency diagnostics remain stable

- **WHEN** the AngelScript builder dependency tests report a cross-module global initializer dependency
- **THEN** that diagnostic retains its existing compiler meaning and is not renamed as a ModuleBinding diagnostic
