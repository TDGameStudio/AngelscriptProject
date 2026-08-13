## ADDED Requirements

### Requirement: Callers can request an asynchronous cache update

The Runtime SHALL expose one cache-update request that discovers current authoritative loose source, compiles it through the existing engine mutation gate at a game-thread safe point, freezes a successful result, and publishes on the existing worker Pack/Manifest path. The request MUST return without waiting for Pack compression or pointer replacement. The Runtime MUST NOT compile, preprocess, or discover source from this request after Engine shutdown has begun.

#### Scenario: Idle update is queued

- **WHEN** Blueprint, C++, or `as.Cache.Update` requests an update while Cache V2 is enabled and the engine is not shutting down
- **THEN** the request returns `Queued`
- **AND** the game thread is not blocked on Pack I/O
- **AND** a later completion reports `Published`, `NoChanges`, `CompileFailed`, or `Cancelled`

#### Scenario: Source already matches Current

- **WHEN** the discovered source snapshot equals the committed Current generation and no publication is in flight
- **THEN** completion is `NoChanges`
- **AND** the store is not rewritten

#### Scenario: Update is requested during shutdown

- **WHEN** Engine shutdown has started
- **THEN** the request returns `ShuttingDown`
- **AND** no new compile or publication is started

#### Scenario: Cache V2 is disabled

- **WHEN** `bEnableCacheV2` is false
- **THEN** the request returns `Disabled`
- **AND** no store mutation occurs

### Requirement: Concurrent updates coalesce instead of stacking compiles

At most one cache-update compile may own the engine mutation gate. A second request that arrives while a compile or publication is in flight SHALL return `Busy`. The service MAY keep a single coalesced follow-up that runs after the in-flight publication commits. It MUST NOT start an unbounded queue of compiles.

#### Scenario: Two rapid update requests

- **WHEN** a second update is requested while the first is compiling or publishing
- **THEN** the second request returns `Busy`
- **AND** at most one follow-up compile runs after the first publication completes

### Requirement: Successful update uses the same freeze-and-publish contract as hot reload

A successful update compile SHALL freeze pointer-free artifacts inside the mutation gate after module swap and ClassGenerator/reinstancing succeed, then schedule asynchronous publication. It MUST NOT recapture mutable VM objects from diagnostic compile-end callbacks. A failed compile MUST leave last-good modules and Current unchanged.

#### Scenario: Update compile succeeds

- **WHEN** current source compiles and activates successfully
- **THEN** workers publish from the frozen DTO
- **AND** Current advances only after the same validation as an Editor reload publication

#### Scenario: Update compile fails

- **WHEN** parsing, compilation, or ClassGenerator fails
- **THEN** completion is `CompileFailed`
- **AND** Current and active modules remain the last-good generation
