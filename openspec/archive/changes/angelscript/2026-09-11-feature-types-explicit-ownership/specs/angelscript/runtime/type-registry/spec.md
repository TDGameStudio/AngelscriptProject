## ADDED Requirements

### Requirement: Pre-Engine publications are BindInfo class records, not Image-owned TypeInfo

The SDK SHALL publish process IDs against UE BindInfo class records before any Engine TypeInfo exists, and SHALL treat asCMetadataImage as a unique intermediate that does not retain TypeInfo.

#### Scenario: Record Pair class facts without an Engine TypeInfo

- **GIVEN** a BindInfo store describing native struct Pair with int X, int Y and Sum() returning int

    Host values remain 20/22 and native Sum is 42. The unique Image helper may project those records but must not become the TypeInfo owner.

- **WHEN** the host publishes that store and destroys the unique Image helper
- **THEN** the publication ID and UE-facing class facts remain queryable without creating an Engine or a TypeInfo pointer
- **AND** no `std::shared_ptr` owns the Image or the class records
- **BUT** `GetTypeInfoById` without an Engine returns null

#### Scenario: Reject invalid publication without TypeInfo

- **WHEN** a candidate BindInfo record has an invalid identity, incomplete layout or name conflict
- **THEN** publication fails with no ID and no Engine TypeInfo
- **AND** previously published records remain unchanged

### Requirement: Engine TypeInfo is materialized uniquely and late

The SDK SHALL create TypeInfo only for a receiving Engine from a published BindInfo record, and SHALL give that Engine exclusive ownership of the resulting objects.

#### Scenario: Two Engines materialize Pair independently

- **GIVEN** one published Pair record with a process TypeId
- **WHEN** Engines A and B each materialize that publication
- **THEN** A and B obtain distinct TypeInfo pointers that report the same TypeId
- **AND** destroying the Image helper before or after materialize does not destroy those TypeInfo objects
- **BUT** A cannot return B's TypeInfo pointer from its queries

#### Scenario: Destroy one Engine after independent materialize

- **WHEN** A is destroyed while B still holds its Pair TypeInfo
- **THEN** B still resolves the same Pair ID and executes Sum as 42
- **AND** A's TypeInfo and sidecars are released without touching BindInfo or B

### Requirement: Runtime numeric identity is allocated independently and never reused in-process

The SDK SHALL preserve primitive and qualified integer TypeId semantics while allocating dynamic type/function numbers independently of Engine construction.

#### Scenario: Query one publication ID through multiple Engines

- **WHEN** multiple Engines materialize one published Pair record
- **THEN** its numeric ID is identical through all admitting Engines
- **AND** the ID was available from the BindInfo publication before those Engines existed

#### Scenario: Reach the numeric encoding limit

- **WHEN** a publication would exceed the supported dynamic ID range
- **THEN** it fails without creating TypeInfo
- **AND** fixed primitive IDs and existing live IDs are unchanged

### Requirement: Global host inspection does not grant Engine admission

The SDK SHALL expose published class facts and live Engine-private TypeInfo by process ID for host inspection, while each Engine admits only its own materialized TypeInfo for compilation and execution.

#### Scenario: Inspect another Engine's private type without using it

- **GIVEN** A and B independently compile same-named ScriptThing types with different IDs
- **WHEN** a host inspects B's ScriptThing through the process registry
- **THEN** the class facts are readable
- **BUT** Engine A cannot compile against or execute B's TypeInfo
