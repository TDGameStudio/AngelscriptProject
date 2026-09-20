## MODIFIED Requirements

### Requirement: Hosts can explicitly create a binding engine

The system SHALL create explicitly owned FAngelscriptEngine consumers from a fresh eligible Runtime collection or an existing retained frozen collection, returning a usable Engine or diagnostic failure. Host definitions SHALL be collected once and shared through InjectDefinitions without per-Engine host materialization.

#### Scenario: Create without ambient runtime services

- **WHEN** a host explicitly creates a binding Engine
- **THEN** supported Runtime types and actual native calls are available
- **BUT** default subsystem ownership, script scanning, initial compilation, hot reload, debugger and cache startup remain dormant

#### Scenario: Prepare once and create multiple Engines

- **GIVEN** one frozen FAngelscriptBindCollection
- **WHEN** a host creates A and B from it
- **THEN** both receive the same HostProcess type and function pointers and process IDs without rerunning registration callbacks
- **AND** shared objects report null GetEngine while mutable execution state remains local

#### Scenario: Creation fails without a partially usable owner

- **WHEN** collection, dependency resolution, freeze, injection or required native binding fails
- **THEN** creation returns no usable Engine and identifies the failed registration, declaration and stage where applicable
- **AND** resources of that attempt are released without changing the retained collection or an existing consumer

### Requirement: Binding engine resources remain isolated

The system SHALL keep mutable adapter, Context, native override, template-operation, delegate and auxiliary state with its exact Engine while retaining shared immutable HostProcess graphs for all valid consumers.

#### Scenario: Destroy one of two engines

- **GIVEN** A and B created from one collection whose external host reference has been released
- **WHEN** A is destroyed
- **THEN** B retains the same type/function pointers and IDs and executes Pair.Sum(20,22) as 42
- **AND** A's local resources are released without retiring the shared graph or changing an ambient default Engine

#### Scenario: Release the final consumer

- **WHEN** the final collection consumer and type/function/native leases are released
- **THEN** the shared graph and retained namespaces are destroyed exactly once without internal reference cycles
