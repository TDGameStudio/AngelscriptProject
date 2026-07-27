## ADDED Requirements

### Requirement: Engine properties have deterministic defaults

Every engine-property field SHALL be explicitly initialized by the engine
constructor to the current fork's documented default.

#### Scenario: Fresh engines expose the same baseline

- **WHEN** multiple engines are created from independent allocations
- **THEN** every readable engine property, including switch-enum type checking,
  SHALL expose the same intended baseline

### Requirement: Engine property state is isolated and restorable

Changing a property on one engine SHALL not affect another engine, and restoring
the captured baseline SHALL reproduce the original value.

#### Scenario: Apply both values and restore

- **WHEN** a property is set to each supported value and then restored
- **THEN** readback SHALL match each applied value and the original baseline
  without changing an independent control engine
