## ADDED Requirements

### Requirement: Runtime JIT VMEntry-only boundaries remain explicit in UASFunction dispatch

The UASFunction/JIT dispatch matrix SHALL distinguish a Runtime VMEntry from Static AOT Raw/Parms entries. A Runtime-compiled function MUST NOT be treated as having direct reflected entry points that the backend did not publish, and reflected execution SHALL remain VM-correct.

#### Scenario: Runtime function has only VMEntry

- **WHEN** an eligible script function has a Runtime VMEntry but null Runtime Raw and Parms entries
- **THEN** script context execution may reach the Runtime VMEntry
- **AND** `UASFunction` dispatch that requires Raw or Parms continues through its current VM/context path
- **AND** return values and parameter writeback remain correct

#### Scenario: Runtime function is unsupported

- **WHEN** a reflected script function is outside the Runtime backend subset
- **THEN** the generated UASFunction wrapper and current virtual override routing remain unchanged
- **AND** execution falls back to the current VM Binding rather than calling a stale or partial Runtime entry
