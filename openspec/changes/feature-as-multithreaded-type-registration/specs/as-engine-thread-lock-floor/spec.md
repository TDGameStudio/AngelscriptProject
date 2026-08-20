## ADDED Requirements

### Requirement: Engine read-write lock macros are real on UE and Standalone

`DECLARECRITICALSECTION` / `ENTERCRITICALSECTION` / `LEAVECRITICALSECTION` and `DECLAREREADWRITELOCK` / `ACQUIREEXCLUSIVE` / `RELEASEEXCLUSIVE` / `ACQUIRESHARED` / `RELEASESHARED` SHALL map to working mutex / reader-writer lock objects when `AS_NO_THREADS` is not defined. `AngelscriptRuntime` SHALL use UE `FCriticalSection` and `FRWLock` (or a wrapper type `asCThreadCriticalSection` / `asCThreadReadWriteLock` around them). Standalone `UECompat` SHALL provide the same type names. The previous always-empty macro implementation SHALL NOT remain the production definition when threads are enabled.

#### Scenario: Standalone builds with threads on

- **WHEN** `-Suite Standalone` compiles `AngelscriptMaintainedFork`
- **THEN** `AS_NO_THREADS` is not a compile definition of that target
- **AND** `asCScriptEngine::engineRWLock` is a real lock object
- **AND** the Standalone lock-floor CTest links and runs

#### Scenario: Shared lookup does not data-race with insert

- **WHEN** one thread inserts a new type-id map entry under the exclusive lock
- **AND** another thread looks up a different already-published type by id under shared lock
- **THEN** the lookup returns the existing type
- **AND** neither thread hits container rehash use-after-free

### Requirement: RequestBuild is linearizable

`asCScriptEngine::RequestBuild` SHALL take exclusive `engineRWLock`, observe `isBuilding`, set it to true on success, and release the lock. A second concurrent `RequestBuild` SHALL return `asBUILD_IN_PROGRESS`. `BuildCompleted` SHALL clear `isBuilding` under exclusive `engineRWLock`.

#### Scenario: Two threads request a build

- **WHEN** two threads call `RequestBuild` on the same engine with no prior build in progress
- **THEN** exactly one call returns `0`
- **AND** the other returns `asBUILD_IN_PROGRESS`
- **AND** after `BuildCompleted` a later `RequestBuild` can succeed

### Requirement: Lazy type-id assign uses stock double-checked exclusive lock

`GetTypeIdFromDataType` SHALL, when `ot->typeId == -1`, acquire exclusive `engineRWLock`, re-read `ot->typeId`, assign `typeIdSeqNbr++` and insert `mapTypeIdToTypeInfo` only if still `-1`, then release. Primitive type ids SHALL remain unchanged. The leftover “waiting for the lock” comment without a lock SHALL NOT remain the production path.

#### Scenario: Two threads first-touch the same type id

- **WHEN** a type exists with `typeId == -1`
- **AND** two threads call `GetTypeIdFromDataType` for that type
- **THEN** exactly one sequence number is consumed
- **AND** both callers observe the same final `typeId`
- **AND** `GetTypeInfoById` returns that type

### Requirement: Public thread C APIs link on UE and Standalone

`asPrepareMultithread`, `asUnprepareMultithread`, `asGetThreadManager`, `asThreadCleanup`, `asAcquireExclusiveLock`, `asReleaseExclusiveLock`, `asAcquireSharedLock`, and `asReleaseSharedLock` SHALL have implementations on both the UE runtime module and the Standalone host. `asPrepareMultithread` SHALL NOT be documented as making `Register*` or `Build` concurrent.

#### Scenario: Standalone prepare/cleanup still works after dropping AS_NO_THREADS

- **WHEN** a Standalone CTest calls `asPrepareMultithread` then `asThreadCleanup` on a worker thread
- **THEN** both return success codes documented by stock AngelScript
- **AND** the application `asAcquireExclusiveLock` pair does not deadlock a single-thread acquire/release
