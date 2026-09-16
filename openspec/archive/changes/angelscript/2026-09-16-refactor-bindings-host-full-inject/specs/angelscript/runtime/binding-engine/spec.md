## MODIFIED Requirements

### Requirement: Hosts can explicitly create a binding engine

The system SHALL create explicitly owned FAngelscriptEngine consumers from the process HostProcess freeze or an existing retained frozen collection, returning a usable Engine or diagnostic failure. Host definitions SHALL be collected once and shared through InjectDefinitions without per-Engine host materialization or Store/Apply.

#### Scenario: Create without ambient runtime services

- **WHEN** a host explicitly creates a binding Engine

    No-argument `CreateForBindings()` and `CreateForBindings(Collection)` both inject the frozen HostProcess graph. `CreateForBindings(Store)` is not a production entry after this Change.

- **THEN** supported Runtime types and actual native calls are available
- **BUT** default subsystem ownership, script scanning, initial compilation, hot reload, debugger and cache startup remain dormant

    `GetBindingInstallation()` is empty. Success is inject, not an Apply Installation.

#### Scenario: Prepare once and create multiple Engines

- **GIVEN** one frozen FAngelscriptBindCollection
- **WHEN** a host creates A and B from it
- **THEN** both receive the same HostProcess type and function pointers and process IDs without rerunning registration callbacks
- **AND** shared objects report null GetEngine while mutable execution state remains local

#### Scenario: Creation fails without a partially usable owner

- **WHEN** collection, dependency resolution, freeze, injection or required native binding fails
- **THEN** creation returns no usable Engine and identifies the failed registration, declaration and stage where applicable
- **AND** resources of that attempt are released without changing the retained collection or an existing consumer
