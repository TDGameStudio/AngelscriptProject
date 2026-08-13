## MODIFIED Requirements

### Requirement: Engine can capture side-effect-free reflectable state

`FAngelscriptEngine` and the public `FAngelscriptObservability` facade SHALL expose const capture APIs that read current engine state into reflected value views without changing runtime behavior; external tooling SHALL consume the facade instead of reflecting runtime ownership resources directly.

#### Scenario: Capture does not mutate engine state

- **WHEN** a reflection snapshot or observability snapshot is captured from an existing engine
- **THEN** the call SHALL NOT initialize the engine, compile modules, discard modules, emit diagnostics, change hot-reload queues, alter debugger execution state, or alter the current engine context stack
- **AND** the returned value SHALL contain a point-in-time diagnostic view of the engine

#### Scenario: Initialized engine reports core lifecycle state

- **WHEN** a state view is captured from an initialized engine
- **THEN** the value view SHALL indicate that the script engine resource is present
- **AND** it SHALL report initial compile status fields
- **AND** it SHALL report package/settings/world-context observation fields using reflected object references or stable names/paths where the broad reflection snapshot supports them
- **AND** the observability facade SHALL report script roots and active-module summaries without source contents

#### Scenario: Diagnostics are summarized

- **WHEN** an engine has captured compile diagnostics
- **THEN** the value view SHALL report diagnostic file count and diagnostic message count
- **AND** it SHALL distinguish error, warning, and info counts where that information exists on the engine diagnostics
- **AND** it SHALL report whether diagnostics are dirty
- **AND** the observability facade SHALL provide stable per-entry copies under the compilation lock

#### Scenario: External Toolset consumption

- **WHEN** a UE Toolset or other external consumer needs AngelScript state
- **THEN** it SHALL be able to use `FAngelscriptObservability` without friend access to `FAngelscriptEngine`
- **AND** the facade SHALL return reflected values rather than ownership-bearing engine internals
- **AND** synchronization-sensitive diagnostics and debugger state SHALL be copied by narrow owner-provided snapshot methods
