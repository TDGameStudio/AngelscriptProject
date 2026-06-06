# as-engine-scoped-runtime-state Specification

## Purpose

Defines the deglobalization boundary for Angelscript runtime state. Any state that references objects owned by a specific `asIScriptEngine` must be owned by `FAngelscriptEngine`, keyed by engine, or cleared by engine lifecycle. This baseline spec captures the rules already enforced for static TypeInfo, legacy fallback registries, and the context pool. Subsequent changes (`refactor-as-runtime-globals-enum-and-tostring`) extend the same capability with enum / ToString incremental requirements.

## ADDED Requirements

### Requirement: Engine-owned AngelScript objects are not process-wide state

Runtime code SHALL NOT store engine-owned AngelScript objects in unpartitioned process-wide statics.

#### Scenario: Runtime state stores AS object pointers

- **WHEN** a runtime cache stores `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, or `asCContext*`
- **THEN** the cache SHALL be owned by `FAngelscriptEngine`, keyed by the owning engine, or cleared before that engine releases its AS runtime
- **AND** a lookup while Engine B is current SHALL NOT return an object created by Engine A

#### Scenario: Runtime state stores replayable metadata

- **WHEN** a runtime registry stores only names, UE reflection objects, bind descriptors, function pointers, configuration, or replayable registration callbacks
- **THEN** the registry MAY remain process-wide
- **AND** it SHALL NOT promote that metadata into cached AS runtime object pointers without engine scoping

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

## Testing Requirements

- Target test layer: Runtime CppTests / Engine lifecycle.
- Expected Automation prefixes:
  - `Angelscript.TestModule.Engine.*` for lifecycle cleanup and multi-engine behavior
  - `Angelscript.TestModule.Bindings.FString` and `Angelscript.TestModule.Bindings` (existing FString / FText format coverage)
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label as-engine-scoped-runtime-state -TimeoutMs 1200000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-engine-scoped-runtime-state-build -TimeoutMs 1800000`
