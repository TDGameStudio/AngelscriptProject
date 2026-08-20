## ADDED Requirements

### Requirement: Concurrent independent type registration is defined inside a registration window

`asCScriptEngine` SHALL provide `BeginConcurrentTypeRegistration` and `EndConcurrentTypeRegistration` on `asIScriptEngine`. The window SHALL default to closed. While the window is active, independent calls to `RegisterObjectType`, `RegisterEnum`, `RegisterInterface`, and `RegisterTypedef` from multiple threads on that same engine SHALL be defined behavior. `CreateContext`, module `Build` / `RequestBuild`, `PrepareEngine`, `RegisterObjectMethod`, `RegisterObjectBehaviour`, `RegisterObjectProperty`, `RegisterGlobalFunction`, `RegisterFuncdef`, `RegisterEnumValue`, and `AddScriptFunction` SHALL return `asINVALID_CONFIGURATION` (or `asBUILD_IN_PROGRESS` for `RequestBuild`) while the window is open. Nested `BeginConcurrentTypeRegistration` SHALL return `asINVALID_CONFIGURATION`. `BeginConcurrentTypeRegistration` while `isBuilding` SHALL return `asBUILD_IN_PROGRESS`.

#### Scenario: Window starts closed

- **WHEN** a new `asCScriptEngine` is constructed
- **THEN** concurrent type registration is disabled
- **AND** existing single-thread `RegisterObjectType` callers behave as they do today

#### Scenario: Independent types register from two threads

- **WHEN** the window is open
- **AND** thread A registers object type `ConcurrentTypeA` and thread B registers object type `ConcurrentTypeB` with no shared name or namespace
- **THEN** both calls return success type ids
- **AND** `GetTypeInfoByName` finds each type
- **AND** the two type ids are distinct

#### Scenario: Begin is rejected during Build

- **WHEN** `RequestBuild` has succeeded and `BuildCompleted` has not run
- **AND** a thread calls `BeginConcurrentTypeRegistration`
- **THEN** the call returns `asBUILD_IN_PROGRESS`
- **AND** the window remains closed

#### Scenario: RequestBuild is rejected during the window

- **WHEN** the window is open
- **AND** a thread calls `RequestBuild`
- **THEN** the call returns `asBUILD_IN_PROGRESS` or `asINVALID_CONFIGURATION`
- **AND** `isBuilding` remains false

#### Scenario: Method registration is rejected during the window

- **WHEN** the window is open
- **AND** a thread calls `RegisterObjectMethod`
- **THEN** the call returns `asINVALID_CONFIGURATION`
- **AND** the engine does not claim defined concurrent method registration

### Requirement: Type ids are unique and published with the type

A successful type registration SHALL assign a unique sequence number and insert `mapTypeIdToTypeInfo` under exclusive `engineRWLock` (or the documented equivalent intern lock) before the register call returns on the registering thread. The sequence increment MAY be a plain `++` or an atomic; it SHALL NOT be the only synchronization. Two concurrent successful registrations SHALL never receive the same sequence number. `GetTypeInfoById` on the returned id SHALL return that type after the registering thread's call returns.

#### Scenario: Concurrent registers receive unique ids

- **WHEN** N worker threads each successfully register a uniquely named value type inside the window
- **THEN** the set of returned type ids has N distinct values after masking with `asTYPEID_MASK_SEQNBR`
- **AND** `GetTypeInfoById` on each id returns the matching `asITypeInfo`

#### Scenario: Lazy id assign does not double-issue

- **WHEN** two threads observe the same newly inserted type with `typeId == -1` and both enter `GetTypeIdFromDataType`
- **THEN** exactly one sequence number is consumed for that type
- **AND** both callers observe the same final `typeId`

### Requirement: Duplicate names are linearizable

Concurrent registration of the same name in the same namespace SHALL yield exactly one live type. Other callers SHALL receive `asALREADY_REGISTERED` (or a documented equivalent failure). The name tables SHALL NOT contain two entries for that key.

#### Scenario: Two threads register the same name

- **WHEN** the window is open
- **AND** two threads call `RegisterObjectType("ConcurrentDup", ...)` in the default namespace
- **THEN** one call succeeds
- **AND** the other returns `asALREADY_REGISTERED`
- **AND** `GetObjectTypeCount` increases by one for that name

### Requirement: Default namespace is not a cross-thread singleton write during the window

While the window is open, a registration SHALL capture the namespace used for that call without requiring other threads' `SetDefaultNamespace` to mutate it concurrently. `SetDefaultNamespace` during the window SHALL take exclusive ownership of the intern lock for the duration of the pointer swap.

#### Scenario: Two threads register in the default namespace without SetDefaultNamespace

- **WHEN** both threads leave the default namespace unchanged
- **AND** they register different type names
- **THEN** both types land in the default namespace

#### Scenario: SetDefaultNamespace does not tear another thread's register

- **WHEN** thread A has already snapshotted `defaultNamespace` at `RegisterObjectType` entry
- **AND** thread B calls `SetDefaultNamespace`
- **THEN** thread A's type is stored under the snapshotted namespace pointer
- **AND** B waits for exclusive access so the engine default pointer is not written while A is still reading it without a snapshot

### Requirement: Native tests cover concurrent type registration without UObject

The plugin native SDK tests and Standalone CTest SHALL include a concurrent type-registration case that opens the window, registers unique types from multiple threads, and asserts unique ids and lookups. Tests SHALL NOT require `UObject` or World.

#### Scenario: Native SDK concurrent register test

- **WHEN** `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.AngelScriptSDK.Engine.ConcurrentTypeRegistration` runs on a build that implements the window
- **THEN** the test PASSes
- **AND** the test file name starts with `Angelscript`

#### Scenario: Standalone CTest concurrent register

- **WHEN** `Tools\RunTestSuite.ps1 -Suite Standalone` runs
- **THEN** the concurrent type-registration CTest PASSes on the same fork
