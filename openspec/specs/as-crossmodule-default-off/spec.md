# as-crossmodule-default-off Specification

## Purpose
TBD - created by archiving change improve-as-crossmodule-default-off. Update Purpose after archive.
## Requirements
### Requirement: ModuleBinding generation is disabled by default
The Angelscript UHTTool SHALL NOT generate engine-side ModuleBinding wrapper shards unless ModuleBinding generation is explicitly enabled in its configuration.

#### Scenario: Default configuration omits opt-in
- **WHEN** the UHTTool loads ModuleBinding generation configuration without an explicit enabled gate
- **THEN** the effective ModuleBinding-only module set is empty
- **AND** no target-module `AS_FunctionTable_<Module>_ModuleBinding_*.cpp` shards are generated

### Requirement: Engine link probe follows ModuleBinding gate
The Angelscript UHTTool SHALL treat the Engine link probe as part of ModuleBinding engine-side generation.

#### Scenario: ModuleBinding generation is disabled
- **WHEN** the Engine module is present in the UHT session
- **THEN** the UHTTool does not generate `AS_FunctionTable_Engine_LinkProbe.cpp`

### Requirement: Explicit opt-in preserves configured profiles
The Angelscript UHTTool SHALL preserve existing `common`, `source`, and `installed` profile selection when ModuleBinding generation is explicitly enabled.

#### Scenario: ModuleBinding generation is enabled on a source engine
- **WHEN** the configuration enables ModuleBinding generation and the engine profile resolves to `source`
- **THEN** the effective ModuleBinding-only module set is derived from `common + source` minus runtime-linked modules

### Requirement: Summary diagnostics expose ModuleBinding gate state
Generated function-table summary diagnostics SHALL include whether ModuleBinding generation was enabled for the current UHT run.

#### Scenario: Summary is written
- **WHEN** the UHTTool writes `AS_FunctionTable_Summary.json`
- **THEN** the summary contains the selected ModuleBinding profile
- **AND** the summary contains the ModuleBinding generation enabled state

