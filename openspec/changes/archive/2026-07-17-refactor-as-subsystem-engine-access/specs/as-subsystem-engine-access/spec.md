## ADDED Requirements

### Requirement: `UAngelscriptSubsystem` is the engine-level owner
The runtime SHALL treat `UAngelscriptSubsystem` as an engine-level `UEngineSubsystem` and the authoritative owner/access point for the primary `FAngelscriptEngine`.

#### Scenario: Engine-level subsystem exposes primary engine
- **WHEN** `UAngelscriptSubsystem` is created by `GEngine`
- **THEN** it SHALL initialize or adopt exactly one primary `FAngelscriptEngine`
- **AND** `UAngelscriptSubsystem::Get()->GetEngine()` SHALL be the preferred subsystem path for retrieving that engine

#### Scenario: Runtime asks for current engine outside test scope
- **WHEN** no temporary `FAngelscriptEngineScope` is active and the engine-level subsystem has an initialized primary engine
- **THEN** `FAngelscriptEngine::TryGetCurrentEngine()` SHALL resolve that engine through `UAngelscriptSubsystem`

### Requirement: Native game-instance engine manager is removed
The runtime SHALL remove native `UAngelscriptGameInstanceSubsystem` because `UAngelscriptSubsystem` is the engine-level owner and `UScriptGameInstanceSubsystem` remains the script inheritance base.

#### Scenario: Native game-instance manager is deleted
- **WHEN** the refactor is complete
- **THEN** `UAngelscriptGameInstanceSubsystem` SHALL no longer exist in runtime source, tests, bindings, or current-engine lookup code
- **AND** no native game-instance subsystem SHALL create, own, tick, push, pop, or shut down `FAngelscriptEngine`

#### Scenario: Script game-instance subsystem remains available
- **WHEN** AngelScript code derives from `UScriptGameInstanceSubsystem`
- **THEN** script game-instance subsystem inheritance and lifecycle SHALL remain supported
- **AND** removing `UAngelscriptGameInstanceSubsystem` SHALL NOT remove `UScriptGameInstanceSubsystem`

#### Scenario: Tests cover game-instance helper routing without a runtime manager
- **WHEN** binding tests need a native `UGameInstanceSubsystem` instance for `USubsystemLibrary::GetGameInstanceSubsystem`
- **THEN** they MAY use a test-only fixture subsystem that does not own, tick, push, pop, or shut down `FAngelscriptEngine`
- **AND** scripts SHALL receive that fixture through generic `UClass` / `UObject` parameters rather than depending on a new AS-visible production subsystem type

### Requirement: Engine tick has a single owner
The primary `FAngelscriptEngine` SHALL be ticked by exactly one runtime owner.

#### Scenario: Engine subsystem ticks
- **WHEN** `UAngelscriptSubsystem` owns or adopts the primary engine and the engine reports `ShouldTick()`
- **THEN** `UAngelscriptSubsystem::Tick` SHALL be the runtime tick path
- **AND** no native game-instance subsystem SHALL suppress or duplicate that tick through `HasAnyTickOwner`

### Requirement: Test override scopes remain supported
Automation tests and temporary nested engine contexts SHALL continue to use `FAngelscriptEngineScope` without being overridden by subsystem lookup.

#### Scenario: Test scope is active
- **WHEN** `FAngelscriptEngineScope` has pushed a temporary engine
- **THEN** `FAngelscriptEngine::TryGetCurrentEngine()` SHALL return the scoped engine before consulting `UAngelscriptSubsystem`
- **AND** leaving the scope SHALL restore the previous current-engine behavior
