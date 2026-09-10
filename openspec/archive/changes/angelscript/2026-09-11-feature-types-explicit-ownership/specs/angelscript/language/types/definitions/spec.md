## MODIFIED Requirements

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
