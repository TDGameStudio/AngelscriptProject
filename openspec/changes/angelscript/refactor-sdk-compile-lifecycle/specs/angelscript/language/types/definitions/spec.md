## Purpose

Define actual engine-independent type/function metadata, immutable definition ownership and atomic single-engine registration.

## ADDED Requirements

### Requirement: Script TypeInfo lives on a module definition set until batch Engine transfer

The system SHALL create actual script TypeInfo during compile without an Engine, uniquely owned by `asCModuleDefinitionSet` until `asCEngineCompileRegistration` transfers them.

#### Scenario: Query script types before Registration

- **WHEN** a snapshot Builder successfully compiles `class Node { Node@ Next; }` and the caller Takes the definition set
- **THEN** member and method queries on the Node TypeInfo expose the described relationships without an Engine pointer

    `GetEngine()` is null. `GetTypeId()` is -1. Recursive handle fields are legal.

- **AND** destroying the set deletes Node
- **BUT** BindInfo publication remains a separate Image-backed host path until a later Binding Change

    BindInfo may still construct `asCMetadataImage`. Script compile does not.

## MODIFIED Requirements

### Requirement: Transactional single-engine definition binding

The system SHALL give each Engine exclusive ownership of the TypeInfo it materializes or compiles, while allowing multiple Engines to materialize the same BindInfo publication independently.

#### Scenario: Publish a valid image

- **WHEN** Engine materialization of a BindInfo publication, or `asCEngineCompileRegistration` of a compiled definition set, validates identities, dependencies and layouts successfully
- **THEN** Engine queries return that Engine's TypeInfo pointers and the published numeric IDs
- **AND** BindInfo publication IDs remain identical in every admitting Engine while TypeInfo pointers differ
- **BUT** stable identity remains independent of those IDs

    Script compile Registration assigns TypeIds at Install. BindInfo publications keep their process IDs from the host store.

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
