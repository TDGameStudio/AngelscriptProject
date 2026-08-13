## ADDED Requirements

### Requirement: Editor tool sources have stable memory virtual paths
Editor stateful tool source SHALL use a stable identity under `/Angelscript/Memory/Tools/` that is separate from the unique Immediate snippet namespace.

#### Scenario: Tool SourceId maps to canonical path
- **WHEN** the Editor tool source entry receives SourceId `MyPlugin/FixMaterials`
- **THEN** its virtual path SHALL be `/Angelscript/Memory/Tools/MyPlugin/FixMaterials.as`
- **AND** it SHALL NOT require a physical filename

#### Scenario: Tool path maps to stable module name
- **WHEN** a memory source has virtual path `/Angelscript/Memory/Tools/MyPlugin/FixMaterials.as`
- **THEN** its default module name SHALL be `Angelscript.Memory.Tools.MyPlugin.FixMaterials`

#### Scenario: Repeated tool source keeps identity
- **WHEN** the Editor tool source entry compiles repeated source updates with the same canonical SourceId
- **THEN** every update SHALL use the same virtual path and module name

#### Scenario: Different tool sources remain isolated
- **WHEN** two calls use different canonical SourceIds
- **THEN** they SHALL receive different Tool memory virtual paths and module names

#### Scenario: Tool and Immediate identities do not overlap
- **WHEN** both stateful tool source and realtime snippet source are compiled
- **THEN** tool source SHALL remain under `/Angelscript/Memory/Tools/`
- **AND** snippet source SHALL remain under `/Angelscript/Memory/Immediate/`
- **AND** the stable tool identity SHALL NOT change the snippet runner's unique-module behavior
