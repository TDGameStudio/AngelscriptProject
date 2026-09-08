## Purpose

Define actual engine-independent type/function metadata, immutable definition ownership and atomic single-engine registration.

## Requirements

### Requirement: Detached actual type and function definitions
The system SHALL create actual TypeInfo, ObjectType and ScriptFunction objects in explicit definition images without creating an Engine.

#### Scenario: Query a detached recursive type graph
- **WHEN** a caller declares type shells, defines fields and methods, resolves signatures and freezes a valid image
- **THEN** type/member/function queries expose the actual objects and relationships without Engine IDs
- **AND** immutable language options and image-owned namespaces remain valid after the Builder is destroyed
- **BUT** invalid by-value recursion, incomplete required layout or post-freeze mutation fails explicitly

### Requirement: Atomic image lifetime without internal reference cycles
The system SHALL keep a definition image alive through external type/function leases and SHALL release its internally recursive graph after the final owner releases it.

#### Scenario: Retain only a method after destroying its producer
- **WHEN** the Builder and Engine are destroyed while an external method reference remains
- **THEN** the method signature, owner and required type graph remain readable
- **AND** releasing the final lease destroys the owned graph and namespaces exactly once
  > Boundaries: Cross-image dependencies retain frozen owners without strong dependency cycles; concurrent references use actual atomic operations.

### Requirement: Transactional single-engine definition binding

The system SHALL register a complete frozen image without copying its metadata objects or exposing a partial registration.

#### Scenario: Publish a valid image
- **WHEN** registration validates all identities, dependencies and layouts successfully
- **THEN** Engine queries return the original type/function pointers and Engine-local IDs
- **BUT** stable identity remains independent of those IDs

#### Scenario: Reject conflicting or competing registration
- **WHEN** preparation fails for any member, or another Engine attempts to attach an already attached image
- **THEN** the failed attempt publishes no partial graph
- **AND** concurrent attempts to attach the same frozen image have at most one successful winner
  > Observables: Duplicate registration reports an explicit state; it does not merge distinct objects by hash.

#### Scenario: Retire an attached image

- **WHEN** the owning Engine retires or is destroyed
- **THEN** it stops new executable admissions and completes active runtime cleanup before removing binding visibility and Engine-owned resources

  1. Active Contexts stop or unwind while their type, callable and native bindings remain valid.
  2. Runtime objects and executable leases finish their required cleanup.
  3. Runtime IDs and binding visibility retire; externally held metadata remains readable.

- **BUT** Engine-only queries and reattachment of the retired image fail explicitly

  > A metadata lease preserves the definition, not a live Engine binding. Shutdown requested within an active callback is deferred until that execution lease exits rather than deadlocking or retiring underneath it.

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

### Requirement: Native definitions preserve explicit member addressing

The SDK SHALL define native fields using explicit validated storage and addressing facts and SHALL preserve those facts through freeze, fingerprinting and Engine registration.

#### Scenario: Define a padded native object

- **GIVEN** a C++ object with declared size, alignment and member offsets
- **WHEN** its native definition is frozen and registered
- **THEN** member queries and runtime access use the declared C++ storage rather than recomputed AS sequential offsets

  > Padding is observable: writing one declared member changes only that member, leaving surrounding sentinel bytes intact.

- **AND** direct, inline-composite and indirect-composite addressing remain distinguishable in layout compatibility
- **BUT** a null indirect composite cannot be dereferenced and produces a runtime exception

#### Scenario: Reject an invalid native address without mutation

- **WHEN** a definition request supplies invalid native member storage

  - Foreign owner, duplicate member or frozen mutation.
  - Overflow, out-of-bounds extent, unsupported alignment/packing or overlapping direct members.
  - Incomplete or incompatible composite storage contracts.

- **THEN** the request returns a specific failure and leaves member count, layout and prior fields unchanged

### Requirement: Executable bodies remain separate from immutable callable declarations

The SDK SHALL allow frozen callable declarations to acquire Engine-local executable bindings without modifying their semantic metadata, stable identity or single-Engine ownership.

#### Scenario: Bind a declared method body

- **GIVEN** a frozen class with a declared method and complete return/parameter contract
- **WHEN** its owning Engine installs a compatible executable body
- **THEN** the original method and owner pointers remain unchanged and the executable binding is owned separately
- **BUT** an undeclared method, incompatible signature or already installed body is rejected without modifying the frozen class

#### Scenario: Use equivalent definitions in separate Engines

- **WHEN** two Engines register separately constructed equivalent definition images
- **THEN** their keys and compatible fingerprints agree while their object pointers and runtime IDs are independently owned
- **BUT** one attached or retired image cannot be shared or reattached to obtain cross-Engine execution
