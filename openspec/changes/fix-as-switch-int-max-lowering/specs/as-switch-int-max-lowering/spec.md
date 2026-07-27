## ADDED Requirements

### Requirement: Switch lowering is safe at the signed upper boundary

The compiler SHALL group switch ranges and emit dense switch tables without
signed overflow for every legal signed 32-bit case label.

#### Scenario: Sparse labels approach the signed maximum

- **WHEN** a switch contains matching and non-matching labels at `INT_MAX - 5`
  and `INT_MAX - 4`
- **THEN** compilation SHALL terminate and execution SHALL select the exact
  matching case or default path

#### Scenario: Dense labels end at the signed maximum

- **WHEN** a dense switch range contains consecutive labels through `INT_MAX`
- **THEN** table generation SHALL terminate without counter wrap and execution
  SHALL select every high-end label correctly

### Requirement: Ordinary switch lowering remains compatible

The overflow repair SHALL preserve existing selection, fallthrough, exit, and
default behavior for ordinary low and middle signed values.

#### Scenario: Ordinary controls execute with the repaired compiler

- **WHEN** the existing switch regression executes its non-boundary controls
- **THEN** each control SHALL retain its exact result and cleanup behavior
