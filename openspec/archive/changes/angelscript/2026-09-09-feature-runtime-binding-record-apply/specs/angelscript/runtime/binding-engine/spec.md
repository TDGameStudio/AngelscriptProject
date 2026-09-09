## Purpose

Expose an explicitly owned FAngelscriptEngine capable of installing and executing Runtime bindings while the project's automatic script runtime remains dormant.

## ADDED Requirements

### Requirement: Hosts can explicitly create a binding engine

The system SHALL provide `FAngelscriptEngine::CreateForBindings` for either a fresh full Runtime snapshot or an existing sealed snapshot, returning an owned usable engine or a diagnostic failure.

#### Scenario: Create without ambient runtime services
- **WHEN** a host explicitly creates a binding engine
- **THEN** Runtime types and native calls are available through that engine
- **BUT** the operation does not activate default subsystem ownership, script scanning, initial script compilation, hot reload, debugger or cache services

#### Scenario: Creation fails without a partially usable owner
- **WHEN** recording, dependency resolution, metadata installation or native call binding fails
- **THEN** creation returns no engine and identifies the failed provider, declaration and stage where applicable
- **AND** resources created by the failed attempt are released

### Requirement: Binding engine resources remain isolated

The system SHALL associate mutable type, adapter, context and native call state with its exact engine and release it deterministically.

#### Scenario: Destroy one of two engines
- **GIVEN** two engines created from one sealed snapshot
- **WHEN** one engine is destroyed
- **THEN** the surviving engine still resolves its types and invokes its methods correctly
- **AND** the destroyed engine's contexts and binding resources are released without changing any ambient default engine
