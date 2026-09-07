## ADDED Requirements

### Requirement: Callable definitions use structured metadata instead of funcdef registration

The maintained SDK SHALL expose nominal callable types and structural signatures through structured MetadataImage APIs, without source-string funcdef registration or legacy funcdef-named public interfaces.

#### Scenario: Construct and register a retained callable type
- **WHEN** a host defines a signature and a nominal callable type using stable keys and typed parameter/return definitions, then freezes and registers the image
- **THEN** named callable identity, signature compatibility, indirect invocation and reference ownership remain valid
- **AND** distinct nominal delegate/event types may share one structural signature without losing nominal identity

#### Scenario: Rebuild an old funcdef SDK caller
- **WHEN** C++ code attempts to call a removed funcdef registration/query interface
- **THEN** that interface is absent from the maintained public SDK rather than forwarded through a compatibility alias
  > Boundaries: Migration uses structured callable creation and MetadataImage registration; no replacement source-string parser is introduced.

### Requirement: Definition membership does not use script shared-owner policy

The maintained SDK SHALL use definition-image ownership, explicit provider dependencies and Engine registration rather than shared declaration flags or legacy module-owner reassignment to manage retained definitions.

#### Scenario: Use a frozen provider without shared declarations
- **WHEN** a compilation or Engine receives a valid externally supplied definition image
- **THEN** existing dependency leases, compatibility checks and registration lifecycle determine visibility and lifetime
- **BUT** no source shared/external flag or mutable legacy module query grants ownership

#### Scenario: Preserve native generic invocation
- **WHEN** a registered native callback uses asIScriptGeneric and typed runtime bindings
- **THEN** argument access, return handling and callable lifetime remain available despite removing user templates and funcdef APIs
