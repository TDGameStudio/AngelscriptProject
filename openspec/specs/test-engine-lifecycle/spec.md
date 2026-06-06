# test-engine-lifecycle Specification

## Purpose
TBD - created by archiving change refactor-as-engine-clone-removal. Update Purpose after archive.
## Requirements
### Requirement: Shared Engine Singleton

`FAngelscriptTestEngine::GetSharedEngine()` SHALL return a reference to a long-lived Full engine instance that persists across test cases within a test session.

#### Scenario: First access creates the engine

- **WHEN** `GetSharedEngine()` is called for the first time
- **THEN** a new Full engine SHALL be created with type bindings initialized
- **AND** subsequent calls SHALL return the same instance

#### Scenario: Shared engine survives between tests

- **WHEN** a test case completes
- **AND** another test case calls `GetSharedEngine()`
- **THEN** the same engine instance SHALL be returned without re-running type binding

### Requirement: Module Reset Isolation

`ResetModules()` SHALL discard all compiled script modules while preserving the engine's type binding databases and VM instance.

#### Scenario: Modules are cleared between tests

- **WHEN** `ResetModules()` is called on the shared engine
- **THEN** all previously compiled modules SHALL be discarded
- **AND** the type database SHALL remain intact
- **AND** the bind database SHALL remain intact
- **AND** subsequent module compilation SHALL succeed without re-binding

#### Scenario: No cross-test contamination

- **WHEN** Test A compiles a module with class `FooActor`
- **AND** `ResetModules()` is called
- **AND** Test B compiles a different module
- **THEN** Test B SHALL NOT see `FooActor` in its module namespace

### Requirement: Isolated Engine Creation

`FAngelscriptTestEngine::Create()` SHALL produce a fully independent engine instance for tests requiring complete isolation.

#### Scenario: Create returns independent engine

- **WHEN** `FAngelscriptTestEngine::Create(Config)` is called
- **THEN** a new Full engine SHALL be created with its own type bindings
- **AND** it SHALL NOT share state with the shared engine singleton
- **AND** it SHALL be destroyed when the owning `TUniquePtr` goes out of scope

### Requirement: Engine Destruction

`DestroySharedEngine()` SHALL release all resources held by the shared engine singleton.

#### Scenario: Explicit destruction releases resources

- **WHEN** `DestroySharedEngine()` is called
- **THEN** the shared engine's `FAngelscriptOwnedSharedState` SHALL be fully released
- **AND** the next `GetSharedEngine()` call SHALL create a fresh engine

