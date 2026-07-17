## ADDED Requirements

### Requirement: DebugDatabaseSettings preserves Hazelight wire compatibility

The Angelscript DebugServer SHALL emit `DebugDatabaseSettings` using wire version `7` and the established Hazelight field order: automatic imports, float width, legacy compatibility slot, static-class deprecation, static-class disallowance, global-function compatibility slot, actor-generic deprecation compatibility slot, and actor-generic disallowance compatibility slot.

#### Scenario: Hazelight Language Server decodes settings

- **WHEN** a Hazelight VS Code Language Server 1.9.2 reads a `DebugDatabaseSettings` message from the plugin
- **THEN** it SHALL decode the complete message without a buffer over-read
- **AND** it SHALL continue to request and consume the Unreal debug database

#### Scenario: Removed Haze behavior remains disabled

- **WHEN** the compatibility slots are serialized
- **THEN** the legacy Haze slot SHALL be false
- **AND** the runtime SHALL not contain or evaluate `WITH_ANGELSCRIPT_HAZE`

### Requirement: Protocol regression coverage matches the external decoder

The Debugger database automation coverage SHALL include a decoder that consumes the emitted settings payload in the Hazelight Language Server field order.

#### Scenario: Short payload is rejected by the regression test

- **WHEN** the runtime omits one or more compatibility slots
- **THEN** the external-layout decoder test SHALL fail because the reader reaches an error state

#### Scenario: Compatible payload is accepted

- **WHEN** the runtime emits all version 7 settings fields
- **THEN** the external-layout decoder test SHALL pass
- **AND** the decoded version SHALL equal `7`
