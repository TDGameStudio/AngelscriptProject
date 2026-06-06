# runtime-engine-shared-state-flattening Specification

## Purpose

Defines the structural change that absorbs `FAngelscriptOwnedSharedState` into `FAngelscriptEngine` after the Clone mechanism is removed. Specifies the resulting one-level engine state layout, the lifecycle invariants on the inlined fields, and which previously-private accessors continue to honor their pre-init `nullptr` contract under the new layout.

## ADDED Requirements

### Requirement: Owned data members live directly on FAngelscriptEngine

The 7 owned data members previously held by `FAngelscriptOwnedSharedState` SHALL be private fields on `FAngelscriptEngine`. The owning struct SHALL NOT exist.

#### Scenario: Type / bind / registry databases live on the engine

- **WHEN** `FAngelscriptEngine` is constructed
- **THEN** the engine SHALL contain `TUniquePtr<FAngelscriptTypeDatabase> TypeDatabase`, `TUniquePtr<FAngelscriptBindState> BindState`, `TUniquePtr<TArray<FToStringType>> ToStringList`, `TUniquePtr<FAngelscriptBindDatabase> BindDatabase`, and `TUniquePtr<FBlueprintEventSignatureRegistry> BlueprintEventSignatureRegistry` as direct private fields
- **AND** these fields SHALL be empty (`nullptr`-equivalent) until `Initialize()` or `InitializeWithoutInitialCompile()` runs
- **AND** `Initialize*()` SHALL `MakeUnique` each field exactly once during the initialization pass that previously called `EnsureSharedStateCreated()`

#### Scenario: Per-engine static name table lives on the engine

- **WHEN** `FAngelscriptEngine` is constructed
- **THEN** the engine SHALL contain `TArray<FName> StaticNames` and `TMap<FName, int32> StaticNamesByIndex` as direct private fields
- **AND** the static-name routing functions (`GetOrAddStaticName`, `ReserveStaticNames`, `ResetStaticNames`, `AddStaticNameFromPrecompiled`, `GetStaticNames`) SHALL access `CurrentEngine->StaticNames[ByIndex]` directly without an intermediate struct dereference
- **AND** the legacy global fallback (`GLegacyStaticNames` / `GLegacyStaticNamesByIndex`) SHALL remain unchanged for the no-current-engine path

### Requirement: Mirror fields are deleted

`FAngelscriptOwnedSharedState`'s 5 raw-pointer mirror fields SHALL be deleted along with the struct. Resources are owned exactly once, by `FAngelscriptEngine` directly.

#### Scenario: ScriptEngine is owned only by FAngelscriptEngine::Engine

- **WHEN** an engine has been initialized
- **THEN** the underlying `asCScriptEngine*` SHALL be reachable only through `FAngelscriptEngine::Engine`
- **AND** there SHALL be no second pointer mirror to it

#### Scenario: PrecompiledData / StaticJIT / DebugServer are owned only by FAngelscriptEngine

- **WHEN** an engine has been initialized
- **THEN** `PrecompiledData`, `StaticJIT`, and `DebugServer` SHALL each be reachable only through their existing same-named field on `FAngelscriptEngine`
- **AND** the dual-ownership safety guards in `Shutdown()` (the `(LocalSharedState == nullptr || LocalSharedState->X == nullptr)` clauses) SHALL be replaced with the single-owner form `if (X != nullptr) { delete X; X = nullptr; }`

#### Scenario: PrimaryContext is owned only by GameThreadTLD

- **WHEN** an engine releases its primary execution context during `Shutdown()`
- **THEN** the engine SHALL release `GameThreadTLD->primaryContext` directly without consulting a struct mirror

### Requirement: Init / shutdown helpers collapse into the engine's own paths

The three free / member helpers that managed the old struct's lifecycle SHALL be deleted. Their bodies fold into the engine's own init/shutdown methods.

#### Scenario: EnsureSharedStateCreated and InitializeOwnedSharedState are gone

- **WHEN** the engine initializes
- **THEN** `EnsureSharedStateCreated()` and `InitializeOwnedSharedState()` SHALL no longer exist
- **AND** the 7 `MakeUnique` calls previously performed by `EnsureSharedStateCreated()` SHALL run inline at the same point of `Initialize*()`
- **AND** the 5 mirror-field assignments previously performed by `InitializeOwnedSharedState()` SHALL not occur (those fields no longer exist)

#### Scenario: ReleaseOwnedSharedStateResources is gone

- **WHEN** the engine shuts down
- **THEN** `ReleaseOwnedSharedStateResources()` SHALL no longer exist
- **AND** `Shutdown()` SHALL release `DebugServer`, `StaticJIT`, `PrecompiledData`, the primary context, and the asCScriptEngine inline
- **AND** the type / bind / registry `TUniquePtr` fields SHALL be cleared via direct `Reset()` calls in `Shutdown()`

### Requirement: Public Get* accessors preserve pre-init nullptr semantics

The 5 `Get*()` accessors (`GetTypeDatabase`, `GetBindState`, `GetToStringList`, `GetBindDatabase`, `GetBlueprintEventSignatureRegistry`) SHALL return `nullptr` when called before `Initialize*()` and a valid pointer afterwards, matching their pre-flatten observable behavior.

#### Scenario: Pre-init access returns nullptr without an SharedState.IsValid() guard

- **WHEN** `GetTypeDatabase()` (or any of the 5 accessors) is called before `Initialize*()` has constructed the unique-ptr
- **THEN** it SHALL return `nullptr`
- **AND** the implementation SHALL achieve this by returning `Field.Get()` directly (an empty `TUniquePtr<>::Get()` returns `nullptr`)
- **AND** there SHALL be no remaining `SharedState.IsValid() ? SharedState->X.Get() : nullptr` ternary

#### Scenario: Post-init access returns the owned database

- **WHEN** `GetTypeDatabase()` is called after `Initialize*()` has run
- **THEN** it SHALL return the same `FAngelscriptTypeDatabase*` that the engine owns through the unique-ptr field
- **AND** that pointer SHALL remain valid until the engine destructs

## REMOVED Requirements

### Requirement: FAngelscriptOwnedSharedState struct exists

The struct SHALL no longer be defined.

#### Scenario: Struct definition is unreachable

- **WHEN** any caller in `Plugins/Angelscript/Source/AngelscriptRuntime/` references `FAngelscriptOwnedSharedState` by name
- **THEN** compilation SHALL fail (type removed)

### Requirement: Engine holds a TUniquePtr to FAngelscriptOwnedSharedState

The `SharedState` field SHALL no longer exist on `FAngelscriptEngine`.

#### Scenario: SharedState field is gone

- **WHEN** any code in `AngelscriptRuntime` accesses `Engine->SharedState`, `this->SharedState`, or `SharedState.IsValid()` / `SharedState->X`
- **THEN** compilation SHALL fail (field removed)

## Testing Requirements

- Target test layer: Engine + Multi-engine + TestEngine (existing prefixes — no new layer required because flattening preserves observable behavior)
- Expected Automation prefixes covered: `Angelscript.TestModule.Engine`, `Angelscript.TestModule.Engine.MultiEngine`, `Angelscript.TestModule.Engine.TestEngine`
- Verification entry points:
  - Build: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-6.7-flatten-build -TimeoutMs 900000 -NoXGE`
  - Tests: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label clone-removal-6.7-flatten-engine-tests -TimeoutMs 1200000`
- Pre-existing tests already cover the relevant invariants:
  - `Angelscript.TestModule.Engine.TestEngine.SharedStateReleaseIsImmediate` — ratifies that engine destruction is synchronous (now also implicitly proves the inlined fields are released in the engine's own destructor)
  - `Angelscript.TestModule.Engine.TestEngine.DestroySharedEngineThenReconstructProducesFreshEngine` — ratifies that re-init after destroy produces fresh state
  - `Angelscript.TestModule.Engine.MultiEngine.*` (11 tests) — ratify cross-engine isolation, including independent injected dependencies and module isolation
