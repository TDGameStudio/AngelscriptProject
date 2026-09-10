## Purpose

Define actual engine-independent type/function metadata, immutable definition ownership and atomic single-engine registration.

## Requirements

### Requirement: Detached actual type and function definitions

The system SHALL describe class information for publication without creating an Engine, and SHALL create actual TypeInfo only when a receiving Engine materializes a publication or adopts a private compilation.

#### Scenario: Query a detached recursive type graph

- **WHEN** a caller records type shells, fields and methods into BindInfo and freezes a valid unique Image helper
- **THEN** UE-facing member/function queries expose the described relationships without an Engine TypeInfo pointer
- **AND** destroying the Image helper leaves BindInfo records valid
- **BUT** invalid by-value recursion, incomplete required layout or post-freeze mutation of the helper fails explicitly

#### Scenario: Publish a detached external graph

- **WHEN** the host publishes the BindInfo record
- **THEN** the publication gains queryable IDs before an Engine exists
- **AND** later Engine materialization creates Engine-owned TypeInfo that report those IDs without sharing TypeInfo pointers

### Requirement: Atomic image lifetime without internal reference cycles

The system SHALL keep a definition image alive through external type/function leases and SHALL release its internally recursive graph after the final owner releases it.

#### Scenario: Retain only a method after destroying its producer

- **WHEN** the Builder and Engine are destroyed while an external method reference remains
- **THEN** the method signature, owner and required type graph remain readable
- **AND** releasing the final lease destroys the owned graph and namespaces exactly once

    > Boundaries: Cross-image dependencies retain frozen owners without strong dependency cycles; concurrent references use actual atomic operations.

### Requirement: Transactional single-engine definition binding

The system SHALL give each Engine exclusive ownership of the TypeInfo it materializes or compiles, while allowing multiple Engines to materialize the same BindInfo publication independently.

#### Scenario: Publish a valid image

- **WHEN** Engine materialization or private compilation validates identities, dependencies and layouts successfully
- **THEN** Engine queries return that Engine's TypeInfo pointers and the published numeric IDs
- **AND** publication IDs remain identical in every admitting Engine while TypeInfo pointers differ
- **BUT** stable identity remains independent of those IDs

#### Scenario: Reject conflicting or competing registration

- **WHEN** preparation fails for any member or another Engine attempts to adopt TypeInfo that already belongs to a different Engine
- **THEN** the failed attempt publishes no partial TypeInfo
- **AND** concurrent private adoption has at most one successful owner

    Duplicate registration reports explicit state. Distinct Engine TypeInfo objects are not merged solely by hash.

#### Scenario: Retire an attached image

- **WHEN** an Engine retires or is destroyed
- **THEN** it stops new executable admissions and completes active runtime cleanup before removing its TypeInfo and resources

    1. Active Contexts stop or unwind while their type, callable and native bindings remain valid.
    2. Runtime objects and executable leases finish their required cleanup.
    3. The retiring Engine's TypeInfo and execution bindings retire; BindInfo publications remain readable.

- **AND** other Engines' materialized TypeInfo remain valid
- **BUT** a retained pointer to the destroyed Engine's TypeInfo cannot execute

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

The SDK SHALL allow published callable descriptions to acquire Engine-local executable bindings on that Engine's TypeInfo without modifying BindInfo records.

#### Scenario: Bind a declared method body

- **GIVEN** a published class with a declared method and complete return/parameter contract
- **WHEN** an Engine that materialized that publication installs a compatible executable body
- **THEN** BindInfo records remain unchanged and the executable binding is owned by that Engine
- **BUT** an undeclared method, incompatible signature or already installed body is rejected without modifying BindInfo

#### Scenario: Use equivalent definitions in separate Engines

- **WHEN** two Engines compile separately constructed equivalent private ScriptThing sources
- **THEN** their keys and compatible fingerprints may agree while their TypeInfo objects and runtime IDs are independently owned
- **BUT** one Engine's TypeInfo cannot be adopted by the other Engine

#### Scenario: Bind one external declaration independently

- **GIVEN** one Pair publication materialized by Engines A and B
- **WHEN** each Engine supplies its own compatible native binding
- **THEN** both report the same publication ID while preserving independent call targets, auxiliary ownership and cleanup
- **AND** destroying A leaves B's binding usable
