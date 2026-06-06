# as-cross-module-generation-allowlist Specification

## Purpose
TBD - created by archiving change improve-as-cross-module-generation-allowlist. Update Purpose after archive.
## Requirements
### Requirement: Cross-module generation uses a UHT-owned allowlist
AngelscriptUHTTool SHALL support a cross-module generation allowlist that is independent from `AngelscriptRuntime.Build.cs`. Modules listed only in this allowlist SHALL be eligible for target-module-local cross-module wrapper shards without being added to `AngelscriptRuntime` public or private dependencies.

#### Scenario: Allowlisted module is generated without Build.cs dependency
- **WHEN** a module is listed in the AngelscriptUHTTool cross-module generation allowlist and is present in the current UHT session
- **THEN** the generator may emit `AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp` into that module's `OutputDirectory`
- **AND** `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` does not list that module solely for cross-module generation

### Requirement: Cross-module-only modules do not emit normal runtime shards
Modules that are present only in the cross-module generation allowlist SHALL NOT emit normal AngelscriptRuntime same-module Direct/Stub shards. They SHALL emit only safe `EntryKind=CrossModule` wrapper entries that publish through `IModularFeatures`.

#### Scenario: Cross-module-only module has no DirectNative or Stub rows
- **WHEN** a module is present in the cross-module generation allowlist but not in the runtime-linked module set from `AngelscriptRuntime.Build.cs`
- **THEN** `AS_FunctionTable_Entries.csv` contains only `EntryKind=CrossModule` rows for that module
- **AND** no `ThunkStyle=DirectNative` or `ThunkStyle=Stub` rows are emitted for that module
- **AND** no `AS_FunctionTable_<Module>_<NNN>.cpp` normal same-module shard is emitted under the AngelscriptRuntime output directory

### Requirement: Allowlisted cross-module candidates preserve existing safety gates
The allowlist SHALL NOT bypass existing cross-module safety gates. RPC/Net functions, unsupported signatures, private headers, interface paths, and script-this projection cases MUST remain excluded from automatic cross-module emission.

#### Scenario: RPC and unsupported signatures stay excluded
- **WHEN** an allowlisted module contains a `BlueprintCallable` UFunction that is RPC/Net or outside the safe automatic cross-module signature subset
- **THEN** no cross-module wrapper entry is emitted for that function
- **AND** skipped diagnostics continue to classify the reason with the existing protocol-oriented failure reason

### Requirement: Diagnostics distinguish realized cross-module coverage from disabled opportunity
Generated diagnostics SHALL show realized cross-module entries from allowlisted modules and SHALL reduce the corresponding `disabled-safe-cross-module` opportunity count for those modules.

#### Scenario: Pilot allowlist increases realized CrossModule count
- **WHEN** the project is rebuilt after enabling the pilot cross-module generation allowlist
- **THEN** `AS_FunctionTable_Entries.csv` contains `EntryKind=CrossModule` rows for at least one pilot module that was previously reported as `disabled-safe-cross-module`
- **AND** `AS_FunctionTable_Summary.json` reports a higher `totalCrossModuleEntries` than the previous `163` baseline
- **AND** `AS_FunctionTable_SkippedEntries.csv` no longer reports those realized rows as `disabled-safe-cross-module`

