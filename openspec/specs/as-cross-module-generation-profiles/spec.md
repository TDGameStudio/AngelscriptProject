# as-module-binding-generation-profiles Specification

## Purpose
TBD - created by archiving change improve-as-module-binding-generation-profiles. Update Purpose after archive.
## Requirements
### Requirement: Module binding generation uses profile configuration
AngelscriptUHTTool SHALL load module-binding-only generation modules from a UHTTool-owned JSON profile configuration instead of a hardcoded C# list or `AngelscriptRuntime.Build.cs`.

#### Scenario: Source profile is selected for source engines
- **WHEN** the engine root is detected as a source distribution
- **THEN** the effective module-binding-only module set includes modules from the `common` and `source` JSON profiles
- **AND** modules already listed as runtime-linked dependencies are excluded from the module-binding-only set

#### Scenario: Installed profile is selected for installed engines
- **WHEN** the engine root is detected as an installed or binary distribution
- **THEN** the effective module-binding-only module set includes modules from the `common` and `installed` JSON profiles
- **AND** the default installed profile does not expand beyond the common pilot set

### Requirement: Profile configuration preserves runtime dependency boundaries
Profile-configured modules SHALL be eligible only for target-module-local module-binding wrapper shards and SHALL NOT be added to `AngelscriptRuntime.Build.cs` dependencies for binding generation.

#### Scenario: Profile module is not a runtime dependency
- **WHEN** a module appears only in the JSON module-binding generation profile
- **THEN** `AngelscriptRuntime.Build.cs` does not list that module for generated binding coverage
- **AND** generated entries for that module use `EntryKind=ModuleBinding` and `ThunkStyle=FrameWrapper`
- **AND** no DirectNative or Stub rows are generated for that module-binding-only module

### Requirement: Profile diagnostics are observable
Generated summary diagnostics SHALL report which module-binding profile was selected and which configured modules were effective for the current UHT session.

#### Scenario: Summary reports selected profile
- **WHEN** UHTTool writes `AS_FunctionTable_Summary.json`
- **THEN** the summary includes the selected module-binding generation profile
- **AND** the summary includes configured and effective module-binding module lists

### Requirement: Source profile expands safe module-binding coverage
The source-engine profile SHALL include the current `disabled-safe-module-binding` opportunity module pool while preserving all existing safety gates.

#### Scenario: Source profile increases realized module-binding entries
- **WHEN** the project is built against a source engine
- **THEN** `AS_FunctionTable_Summary.json` reports more module-binding entries than the previous `546` pilot baseline
- **AND** RPC/Net functions and unsupported signatures remain excluded through existing skipped diagnostics

