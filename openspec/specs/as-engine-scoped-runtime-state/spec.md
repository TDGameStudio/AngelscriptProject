# as-engine-scoped-runtime-state Specification

## Purpose
TBD - created by archiving change refactor-as-runtime-typeinfo-engine-scoped. Update Purpose after archive.
## Requirements
### Requirement: Engine-owned AngelScript objects are not process-wide state

Runtime code SHALL NOT store engine-owned AngelScript objects in unpartitioned process-wide statics. Lookup tables that resolve UE reflection identities (such as enum names) into engine-owned AngelScript objects SHALL be partitioned by engine.

#### Scenario: Runtime state stores AS object pointers

- **WHEN** a runtime cache stores `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, or `asCContext*`
- **THEN** the cache SHALL be owned by `FAngelscriptEngine`, keyed by the owning engine, or cleared before that engine releases its AS runtime
- **AND** a lookup while Engine B is current SHALL NOT return an object created by Engine A

#### Scenario: Runtime state stores replayable metadata

- **WHEN** a runtime registry stores only names, UE reflection objects, bind descriptors, function pointers, configuration, or replayable registration callbacks
- **THEN** the registry MAY remain process-wide
- **AND** it SHALL NOT promote that metadata into cached AS runtime object pointers without engine scoping

#### Scenario: Name-keyed lookup resolves an engine-owned AS object

- **WHEN** a process-wide lookup table maps UE reflection names (such as `FName`) to AS runtime objects (such as `asITypeInfo*` for script enums)
- **THEN** the table SHALL be partitioned by engine so each engine sees only its own entries
- **AND** engine teardown SHALL clear the entries belonging to the destroyed engine before its AS runtime is released

### Requirement: Static native type-info is engine-scoped

Native static type-info helpers SHALL NOT expose a single process-wide `asITypeInfo*` for C++ types registered into AngelScript.

#### Scenario: Same C++ type bound in two engines

- **GIVEN** Engine A and Engine B both bind the native `FString` value class
- **WHEN** the runtime stores static type info for `FString`
- **THEN** Engine A's `asITypeInfo*` SHALL be associated only with Engine A
- **AND** Engine B's `asITypeInfo*` SHALL be associated only with Engine B
- **AND** a current-engine lookup for Engine B SHALL NOT return Engine A's pointer

#### Scenario: Engine teardown clears native type-info entries

- **GIVEN** an engine has registered native static type-info entries
- **WHEN** that engine shuts down
- **THEN** entries owned by that engine SHALL be removed before releasing the underlying AS engine
- **AND** later engines SHALL NOT observe stale type-info entries from the destroyed engine

### Requirement: Legacy fallbacks cannot hide engine-owned state

No-current-engine fallback registries SHALL NOT become hidden cross-engine owners for AngelScript runtime objects.

#### Scenario: Legacy type / bind fallback receives only metadata

- **WHEN** code stores entries in legacy fallback registries (`LegacyDatabase`, `LegacyBindState`, `LegacyBindDatabase`)
- **THEN** the entries SHALL contain only UE-side metadata such as names, reflection objects, descriptors, or replayable callbacks
- **AND** the entries SHALL NOT cache `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, or `asCContext*`

#### Scenario: Context pool stores AS contexts

- **WHEN** a context pool stores `asCContext*`
- **THEN** taking a context SHALL match the requested script engine
- **AND** destroying an engine SHALL release or invalidate contexts owned by that engine

### Requirement: ToString fallback path does not expose cross-engine type info

The `FToStringType` fallback storage path SHALL NOT cache `asITypeInfo*` in a way that lets one engine's AS type identity be observed from another engine.

#### Scenario: ToString fallback receives a TypeInfo entry

- **WHEN** code routes a ToString registration through the legacy fallback (`LegacyToStringList`) instead of the engine-owned `ToStringList`
- **THEN** the fallback entry SHALL hold only metadata (UE reflection identifiers, formatter callbacks)
- **AND** the fallback SHALL NOT expose an `asITypeInfo*` originating from a different engine
- **AND** an engine-owned route SHALL be preferred whenever a current engine is available

### Requirement: Formatting validates deglobalized type identity

`FString::Format` and `FText::Format` SHALL act as acceptance coverage for deglobalized native type-info, including across engine recreation.

#### Scenario: FString argument after previous engine populated cache

- **GIVEN** Engine A has bound `FString` and populated the engine-keyed static type info
- **AND** Engine A has been destroyed
- **AND** Engine B has been created and bound `FString`
- **WHEN** script in Engine B calls `FString::Format("{0}", "Hello")`
- **THEN** the result SHALL be `Hello`
- **AND** the argument SHALL NOT be rejected because Engine A's `asITypeInfo*` lingered in the static cache

#### Scenario: FText argument after previous engine populated cache

- **GIVEN** Engine A has bound `FText`
- **AND** Engine A has been destroyed and Engine B has been created
- **WHEN** script in Engine B formats an `FText` argument through the text formatting path
- **THEN** the argument SHALL be accepted using Engine B's `FText` type identity
- **AND** stale static type-info state from Engine A SHALL NOT affect the result

