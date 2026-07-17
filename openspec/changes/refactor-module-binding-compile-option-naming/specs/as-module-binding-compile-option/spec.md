## ADDED Requirements

### Requirement: ModuleBinding compile gate uses canonical names

The project SHALL expose `bCompileAngelscriptModuleBindings` and derive `WITH_ANGELSCRIPT_MODULE_BINDINGS` from the same project compile-options ini value. The old `bCompileAngelscriptModuleLocalBindings` and `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS` names SHALL not remain in the active production gate.

#### Scenario: Default configuration keeps ModuleBinding disabled

- **WHEN** `Config/DefaultAngelscriptCompileOptions.ini` contains `bCompileAngelscriptModuleBindings=false`
- **THEN** UBT defines `WITH_ANGELSCRIPT_MODULE_BINDINGS=0`
- **AND** the Runtime ModuleBinding bridge is excluded from compilation
- **AND** UHT emits no ModuleBinding shards or link probe

#### Scenario: Source engine enables ModuleBinding compilation

- **WHEN** `bCompileAngelscriptModuleBindings=true` is read for a source engine
- **THEN** UBT defines `WITH_ANGELSCRIPT_MODULE_BINDINGS=1`
- **AND** UHT may emit configured target-module ModuleBinding shards

### Requirement: Non-source engines reject enabled ModuleBinding compilation

The Editor, UBT, and UHT SHALL reject an enabled `bCompileAngelscriptModuleBindings` value for installed, binary, or unknown engine distributions.

#### Scenario: Installed engine rejects the option

- **WHEN** an installed engine attempts to enable `bCompileAngelscriptModuleBindings`
- **THEN** the Editor or build pipeline reports that ModuleBinding compilation requires a source engine
- **AND** no ModuleBinding bridge or shard is accepted

### Requirement: Active diagnostics and documentation use the new gate names

Maintained tests and documentation SHALL refer to `bCompileAngelscriptModuleBindings` and `WITH_ANGELSCRIPT_MODULE_BINDINGS` when describing the compile gate. Historical change records MAY retain the names that were valid when they were written.

#### Scenario: Source scans find no legacy active gate names

- **WHEN** the focused compile-gate source scan examines active Runtime, UHT, Editor, test, config, and maintained documentation paths
- **THEN** it finds the canonical setting and macro names
- **AND** it does not find the legacy setting or macro names in those active paths
