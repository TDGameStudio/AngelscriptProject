## REMOVED Requirements

### Requirement: Transactional single-engine definition binding

## ADDED Requirements

### Requirement: Definition admission follows explicit origin and is transactional

The SDK SHALL distinguish HostProcess, ScriptEngine and LiveRegister definitions, admit immutable host graphs without transferring them, and keep script/live private definitions bound to their receiving Engine.

#### Scenario: Inject one frozen host graph twice into different Engines

- **GIVEN** a frozen HostProcess graph containing Pair and Sum
- **WHEN** A and B inject it
- **THEN** both directories contain identical type/function pointers and IDs with null GetEngine
- **AND** reinjecting the identical graph into A reports AlreadyRegistered without duplicate admission

#### Scenario: Reject conflicting or competing registration

- **WHEN** a host injection has invalid origin, layout, identity or dependency admission, or a script batch competes for another private owner
- **THEN** it publishes no partial type/function entries and leaves previous admitted objects unchanged
- **AND** concurrent private adoption has at most one successful owner

    Distinct private objects are not merged by matching fingerprints. Conflicts include a previously registered live name.

#### Scenario: Retire an attached definition set

- **WHEN** an Engine retires or is destroyed
- **THEN** it stops new execution admission and completes admitted resource cleanup before removing its local bindings

    1. Active Contexts stop or unwind while their callable/native leases remain valid.
    2. Runtime objects and executable resources complete required cleanup.
    3. Private definitions retire and shared-host admission is detached without retiring the host graph.

- **AND** other Engines retain their admitted host and private definitions
- **BUT** retained pointers alone cannot authorize new execution on the retired Engine

#### Scenario: Transfer a private script graph with host dependencies

- **GIVEN** private script definitions depending on a frozen HostProcess graph already injected into A and B
- **WHEN** A registers and later retires its script definitions
- **THEN** only the private graph changes ownership and retirement state
- **AND** the shared host graph retains null Engine, Frozen state and unchanged IDs for B

## MODIFIED Requirements

### Requirement: Script TypeInfo lives on a module definition set until batch Engine transfer

The system SHALL create actual script TypeInfo without an Engine, uniquely owned by asCDefinitions until asCEngineCompileRegistration transfers the private graph.

#### Scenario: Query script types before Registration

- **WHEN** a snapshot Builder successfully compiles class Node with a Node handle field and the caller takes its definitions
- **THEN** member and method queries expose the graph with null GetEngine and TypeId -1
- **AND** recursive handles are legal and destroying the unregistered private definitions deletes Node
- **BUT** retained shared host dependencies are not deleted with the private graph

### Requirement: Detached actual type and function definitions

The SDK SHALL permit host callbacks to create actual HostProcess types and functions before any Engine, freeze their complete graph and publish shared identity without a descriptive replay product.

#### Scenario: Query a detached recursive type graph

- **WHEN** a host creates shells, fields and functions and freezes a valid host graph
- **THEN** actual TypeInfo member/function queries expose the declared relationships without an Engine
- **AND** external leases retain the graph after its producer reference is released
- **BUT** invalid by-value recursion, incomplete layout or post-freeze mutation fails explicitly without publishing a usable graph

#### Scenario: Publish a detached external graph

- **WHEN** the host freezes and publishes actual HostProcess definitions
- **THEN** type/function process IDs are fixed before the first Engine injection
- **AND** later injections return those same pointers and IDs without constructing host TypeInfo again

### Requirement: Atomic definition-set lifetime without internal reference cycles

The system SHALL retain a definition graph through its Collection, admitted consumers and external type/function/native leases, and SHALL release internally recursive owned objects exactly once after the final lease.

#### Scenario: Retain only a method after destroying its producer

- **WHEN** producer and Engine owners are destroyed while an external method reference remains
- **THEN** the method signature, declaring type and required graph remain readable
- **AND** releasing the final lease destroys the graph and namespaces exactly once

    Dependencies retain frozen owners without strong dependency cycles; concurrent references use actual atomic operations.

### Requirement: Executable bodies remain separate from immutable callable declarations

The SDK SHALL retain immutable host callable declarations and their shared native interface while allowing compatible Engine-local native overrides; private script runtime bytecode SHALL remain on its owning script function.

#### Scenario: Bind a declared method body

- **GIVEN** an admitted host declaration with complete return and parameter facts
- **WHEN** the receiving Engine supplies a compatible local callable implementation
- **THEN** shared declarations and the process-native target remain unchanged
- **BUT** an undeclared or incompatible target cannot alter the prior usable binding

#### Scenario: Use equivalent definitions in separate Engines

- **WHEN** two Engines compile separately constructed equivalent private ScriptThing sources
- **THEN** their keys and compatible fingerprints may agree while their TypeInfo objects and runtime IDs remain independently owned
- **BUT** one Engine cannot adopt the other's private objects

#### Scenario: Bind one external declaration independently

- **GIVEN** A and B inject one Pair host declaration
- **WHEN** each supplies its own compatible native binding
- **THEN** both report the same ID and pointer while retaining independent targets, auxiliary ownership and cleanup
- **AND** destroying A leaves B callable

### Requirement: MetadataImage is not a TypeInfo owner

The SDK SHALL use asCDefinitions for actual host and private script ownership and SHALL NOT construct asCMetadataImage or restore its registration APIs.

#### Scenario: No Image type on the script or BindInfo path

- **WHEN** a Builder takes private definitions or a host collection constructs its frozen graph
- **THEN** those objects have a Definitions owner and no MetadataImage

    Private script objects have null Engine and TypeId -1 before unique transfer. HostProcess objects keep null Engine permanently and receive IDs before injection.

- **AND** public SDK headers expose no asCMetadataImage, RegisterMetadataImage, metadataImages or GetRegisteredMetadataImages
- **BUT** commented binding tests or legacy startup cannot substitute for actual maintained binding execution
