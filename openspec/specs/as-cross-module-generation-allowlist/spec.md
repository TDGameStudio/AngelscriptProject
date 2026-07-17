# as-module-binding-generation-allowlist Specification

## Purpose
TBD - created by archiving change improve-as-module-binding-generation-allowlist. Update Purpose after archive.
## Requirements
### Requirement: Module binding generation uses a UHT-owned allowlist
AngelscriptUHTTool SHALL support a module-binding generation allowlist that is independent from `AngelscriptRuntime.Build.cs`. Modules listed only in this allowlist SHALL be eligible for target-module-local module-binding wrapper shards without being added to `AngelscriptRuntime` public or private dependencies.

#### Scenario: Allowlisted module is generated without Build.cs dependency
- **WHEN** a module is listed in the AngelscriptUHTTool module-binding generation allowlist and is present in the current UHT session
- **THEN** the generator may emit `AS_FunctionTable_<Module>_ModuleBinding_<NNN>.cpp` into that module's `OutputDirectory`
- **AND** `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` does not list that module solely for module-binding generation

### Requirement: Module binding-only modules do not emit normal runtime shards
Modules that are present only in the module-binding generation allowlist SHALL NOT emit normal AngelscriptRuntime same-module Direct/Stub shards. They SHALL emit only safe `EntryKind=ModuleBinding` wrapper entries that publish through `IModularFeatures`.

#### Scenario: Module binding-only module has no DirectNative or Stub rows
- **WHEN** a module is present in the module-binding generation allowlist but not in the runtime-linked module set from `AngelscriptRuntime.Build.cs`
- **THEN** `AS_FunctionTable_Entries.csv` contains only `EntryKind=ModuleBinding` rows for that module
- **AND** no `ThunkStyle=DirectNative` or `ThunkStyle=Stub` rows are emitted for that module
- **AND** no `AS_FunctionTable_<Module>_<NNN>.cpp` normal same-module shard is emitted under the AngelscriptRuntime output directory

### Requirement: Allowlisted module-binding candidates preserve existing safety gates
The allowlist SHALL NOT bypass existing module-binding safety gates. RPC/Net functions, unsupported signatures, private headers, interface paths, and script-this projection cases MUST remain excluded from automatic module-binding emission.

#### Scenario: RPC and unsupported signatures stay excluded
- **WHEN** an allowlisted module contains a `BlueprintCallable` UFunction that is RPC/Net or outside the safe automatic module-binding signature subset
- **THEN** no module-binding wrapper entry is emitted for that function
- **AND** skipped diagnostics continue to classify the reason with the existing protocol-oriented failure reason

### Requirement: Diagnostics distinguish realized module-binding coverage from disabled opportunity
Generated diagnostics SHALL show realized module-binding entries from allowlisted modules and SHALL reduce the corresponding `disabled-safe-module-binding` opportunity count for those modules.

#### Scenario: Pilot allowlist increases realized ModuleBinding count
- **WHEN** the project is rebuilt after enabling the pilot module-binding generation allowlist
- **THEN** `AS_FunctionTable_Entries.csv` contains `EntryKind=ModuleBinding` rows for at least one pilot module that was previously reported as `disabled-safe-module-binding`
- **AND** `AS_FunctionTable_Summary.json` reports a higher `totalModuleBindingEntries` than the previous `163` baseline
- **AND** `AS_FunctionTable_SkippedEntries.csv` no longer reports those realized rows as `disabled-safe-module-binding`

