## ADDED Requirements

### Requirement: CrossModule generation is disabled by default
The Angelscript UHTTool SHALL NOT generate engine-side CrossModule wrapper shards unless CrossModule generation is explicitly enabled in its configuration.

#### Scenario: Default configuration omits opt-in
- **WHEN** the UHTTool loads CrossModule generation configuration without an explicit enabled gate
- **THEN** the effective CrossModule-only module set is empty
- **AND** no target-module `AS_FunctionTable_<Module>_CrossModule_*.cpp` shards are generated

### Requirement: Engine link probe follows CrossModule gate
The Angelscript UHTTool SHALL treat the Engine link probe as part of CrossModule engine-side generation.

#### Scenario: CrossModule generation is disabled
- **WHEN** the Engine module is present in the UHT session
- **THEN** the UHTTool does not generate `AS_FunctionTable_Engine_LinkProbe.cpp`

### Requirement: Explicit opt-in preserves configured profiles
The Angelscript UHTTool SHALL preserve existing `common`, `source`, and `installed` profile selection when CrossModule generation is explicitly enabled.

#### Scenario: CrossModule generation is enabled on a source engine
- **WHEN** the configuration enables CrossModule generation and the engine profile resolves to `source`
- **THEN** the effective CrossModule-only module set is derived from `common + source` minus runtime-linked modules

### Requirement: Summary diagnostics expose CrossModule gate state
Generated function-table summary diagnostics SHALL include whether CrossModule generation was enabled for the current UHT run.

#### Scenario: Summary is written
- **WHEN** the UHTTool writes `AS_FunctionTable_Summary.json`
- **THEN** the summary contains the selected CrossModule profile
- **AND** the summary contains the CrossModule generation enabled state

## Testing Requirements

- Target test layer: Runtime CppTests / UHTTool resolver tests.
- Expected Automation prefix: `Angelscript.CppTests.UHTToolResolver.*`.
- Recommended helper/harness: existing helpers in `AngelscriptCrossModuleLinkProbeTests.cpp`.
- Verification entry point: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label crossmodule-default-off-uhttool -TimeoutMs 900000`.
