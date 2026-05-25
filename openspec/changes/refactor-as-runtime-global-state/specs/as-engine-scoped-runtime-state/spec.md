# as-engine-scoped-runtime-state Specification

## Purpose

Defines the deglobalization boundary for Angelscript runtime state. Any state that references objects owned by a specific `asIScriptEngine` must be owned by `FAngelscriptEngine`, keyed by engine, or cleared by engine lifecycle.

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

### Requirement: Formatting validates deglobalized type identity

`FString::Format` and `FText::Format` SHALL act as acceptance coverage for deglobalized native type-info.

#### Scenario: FString argument after previous engine populated cache

- **GIVEN** a previous engine has bound `FString`
- **AND** a different current engine executes script code
- **WHEN** script calls `FString::Format("{0}", "Hello")`
- **THEN** the result SHALL be `Hello`
- **AND** the argument SHALL NOT be rejected because the previous engine's `asITypeInfo*` differs from the current engine's pointer

#### Scenario: FText argument after previous engine populated cache

- **GIVEN** a previous engine has bound `FText`
- **AND** a different current engine executes script code
- **WHEN** script formats an `FText` argument through the text formatting path
- **THEN** the argument SHALL be accepted using the current engine's `FText` type identity
- **AND** stale static type-info state SHALL NOT affect the result

### Requirement: Legacy fallbacks cannot hide engine-owned state

No-current-engine fallback registries SHALL NOT become hidden cross-engine owners for AngelScript runtime objects.

#### Scenario: Legacy fallback receives AS runtime object

- **WHEN** code attempts to store an AS runtime object pointer in a legacy fallback such as ToString, type database, bind state, or bind database storage
- **THEN** the code SHALL route the write to engine-owned state, key it by engine, clear it by lifecycle, or reject the path
- **AND** that pointer SHALL NOT later be read as if it belonged to another engine

#### Scenario: Context pool stores AS contexts

- **WHEN** a context pool stores `asCContext*`
- **THEN** taking a context SHALL match the requested script engine
- **AND** destroying an engine SHALL release or invalidate contexts owned by that engine

## Testing Requirements

- Target test layer: Bindings + Runtime CppTests / Engine lifecycle.
- Expected Automation prefixes:
  - `Angelscript.TestModule.Bindings.FString.*`
  - `Angelscript.TestModule.Bindings.*` for `FText` or shared formatting coverage
  - `Angelscript.TestModule.Engine.*` for lifecycle cleanup and multi-engine behavior
- Recommended helpers:
  - Existing Angelscript binding test macros and engine acquisition helpers from `Source/AngelscriptTest/Shared/`
  - Existing engine lifecycle / multi-engine test helpers when two engines are required
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-fstring -TimeoutMs 900000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-engine -TimeoutMs 1200000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-build -TimeoutMs 1800000`