## MODIFIED Requirements

### Requirement: Hosts can explicitly create a binding engine

The system SHALL provide FAngelscriptEngine::CreateForBindings for a fresh Runtime snapshot, an existing sealed snapshot or an existing BindInfoStore preparation, returning an owned usable Engine or diagnostic failure. External BindInfo preparation SHALL be reusable without retaining an Image or sharing TypeInfo pointers.

#### Scenario: Create without ambient runtime services

- **WHEN** a host explicitly creates a binding Engine
- **THEN** supported Runtime types and native calls are available through that Engine
- **BUT** the operation does not activate default subsystem ownership, script scanning, initial compilation, hot reload, debugger or cache services

#### Scenario: Prepare once and create multiple Engines

- **GIVEN** a valid sealed BindInfoStore
- **WHEN** a host creates Engines A and B from that store
- **THEN** both materialize TypeInfo that report the same publication IDs without rerunning providers
- **AND** each Engine owns distinct TypeInfo pointers and mutable installation
- **AND** any Image helper used during materialize is unique and discarded

#### Scenario: Creation fails without a partially usable owner

- **WHEN** recording, dependency resolution, materialization, installation or native binding fails
- **THEN** creation returns no Engine and identifies the failed provider, declaration and stage where applicable
- **AND** resources created by that attempt are released without invalidating BindInfo or an existing consumer

### Requirement: Binding engine resources remain isolated

The system SHALL associate mutable adapter, context, native, template-operation and delegate state with its exact Engine while allowing BindInfo publications to be reused.

#### Scenario: Destroy one of two engines

- **GIVEN** two Engines created from one BindInfoStore
- **WHEN** one Engine is destroyed
- **THEN** the survivor still resolves the original publication IDs and invokes its methods correctly
- **AND** the destroyed Engine's TypeInfo and mutable resources are released without changing any ambient default Engine or BindInfo
