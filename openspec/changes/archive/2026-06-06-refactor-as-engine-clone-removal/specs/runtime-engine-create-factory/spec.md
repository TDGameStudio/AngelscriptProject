# runtime-engine-create-factory Specification

## Purpose

Defines the single-entry-point factory contract for `FAngelscriptEngine` after the Clone-mode and SharedState removals (Phases 3, 4, 6) leave only one ownership / lifecycle path. Specifies how `FAngelscriptEngineConfig::bSkipInitialCompile` drives the post-construction initialization branch, and removes the redundant `CreateUncompiled` factory.

## ADDED Requirements

### Requirement: Single Create factory dispatches on bSkipInitialCompile

`FAngelscriptEngine` SHALL expose exactly one public static factory function that constructs an engine instance and returns ownership via `TUniquePtr<FAngelscriptEngine>`.

#### Scenario: Default config runs the full Initialize path

- **WHEN** `FAngelscriptEngine::Create(Config, Dependencies)` is called with `Config.bSkipInitialCompile == false`
- **THEN** a new engine SHALL be constructed via `MakeUnique<FAngelscriptEngine>(Config, Dependencies)`
- **AND** the engine's `Initialize()` method SHALL be invoked exactly once
- **AND** the returned `TUniquePtr<FAngelscriptEngine>` SHALL hold sole ownership

#### Scenario: Config flag skips the initial compile pass

- **WHEN** `FAngelscriptEngine::Create(Config, Dependencies)` is called with `Config.bSkipInitialCompile == true`
- **THEN** a new engine SHALL be constructed via `MakeUnique<FAngelscriptEngine>(Config, Dependencies)`
- **AND** the engine's `InitializeWithoutInitialCompile()` method SHALL be invoked exactly once instead of `Initialize()`
- **AND** the returned `TUniquePtr<FAngelscriptEngine>` SHALL hold sole ownership

#### Scenario: Construction order is identical regardless of flag

- **WHEN** two engines are created with the same `Config` differing only in `bSkipInitialCompile`
- **THEN** both engines SHALL be constructed by the same `MakeUnique<FAngelscriptEngine>` call
- **AND** the only observable difference SHALL be whether the post-construction initial-compile pass ran
- **AND** the dependency injection wiring SHALL fire identically in both paths

### Requirement: bSkipInitialCompile lives on FAngelscriptEngineConfig

`FAngelscriptEngineConfig` SHALL expose a public `bool bSkipInitialCompile` field defaulting to `false`.

#### Scenario: Default config is the production path

- **WHEN** a caller constructs `FAngelscriptEngineConfig` via its default constructor or `FAngelscriptEngineConfig::FromCurrentProcess()`
- **THEN** `bSkipInitialCompile` SHALL be `false`
- **AND** subsequent `FAngelscriptEngine::Create(Config, ...)` SHALL dispatch to the full Initialize path

#### Scenario: Test-side opt-in via the flag

- **WHEN** a caller wants to skip the initial-compile pass (e.g. test fixtures that compile their own modules)
- **THEN** the caller SHALL set `Config.bSkipInitialCompile = true;` on a local config copy before invoking `FAngelscriptEngine::Create`
- **AND** the production-shipped factory SHALL not be a separate function

### Requirement: FAngelscriptTestEngine::Create owns the test-side flag set

`FAngelscriptTestEngine::Create(Config, Dependencies)` SHALL internally set `bSkipInitialCompile = true` before delegating to `FAngelscriptEngine::Create`, so test-module callers never set the flag manually.

#### Scenario: Test wrapper sets the flag and delegates

- **WHEN** test code calls `FAngelscriptTestEngine::Create(Config, Dependencies)`
- **THEN** the wrapper SHALL copy `Config` into a local config
- **AND** it SHALL set `LocalConfig.bSkipInitialCompile = true`
- **AND** it SHALL call `FAngelscriptEngine::Create(LocalConfig, Dependencies)` and return its result
- **AND** the original `Config` argument SHALL not be mutated

#### Scenario: Test code uses the wrapper, not the runtime factory directly

- **WHEN** test code in `AngelscriptTest/Core/*` or `AngelscriptTest/Functional/*` requires an engine without the initial-compile pass
- **THEN** the call SHALL be `FAngelscriptTestEngine::Create(Config, Deps)`
- **AND** the call SHALL NOT be `FAngelscriptEngine::Create(Config, Deps)` with `bSkipInitialCompile = true` inline

### Requirement: AngelscriptEditor tests set the flag inline

`AngelscriptEditor/Tests/*` callers (which cannot depend on `AngelscriptTest` per the Build.cs module graph) SHALL set `bSkipInitialCompile = true` on their local `FAngelscriptEngineConfig` before calling `FAngelscriptEngine::Create`.

#### Scenario: Editor test sets the flag inline

- **WHEN** an editor test (e.g. `AngelscriptDirectoryWatcherTests.cpp`) needs an engine that skips the initial compile pass
- **THEN** the test SHALL build a local `FAngelscriptEngineConfig` (typically from `FAngelscriptEngineConfig::FromCurrentProcess()`)
- **AND** the test SHALL set `Config.bSkipInitialCompile = true;` immediately after, at the engine-construction site
- **AND** the test SHALL invoke `FAngelscriptEngine::Create(Config, Deps)` (not `CreateUncompiled` — that factory no longer exists)

## REMOVED Requirements

### Requirement: FAngelscriptEngine::CreateUncompiled exists as a separate factory

The `CreateUncompiled` static factory function SHALL no longer exist on `FAngelscriptEngine`.

#### Scenario: CreateUncompiled is unavailable

- **WHEN** any caller in `Plugins/Angelscript/Source/` references `FAngelscriptEngine::CreateUncompiled`
- **THEN** compilation SHALL fail (function removed)

#### Scenario: Existing CreateUncompiled callers migrate to Create

- **WHEN** the migration in tasks 7.4 / 7.5 / 7.6 lands
- **THEN** all 47 known caller sites SHALL be redirected:
  - 33 sites in `AngelscriptTest/Core/*` and `AngelscriptTest/Functional/*` SHALL call `FAngelscriptTestEngine::Create`
  - 2 sites in `AngelscriptTest/Shared/*` (the wrapper helpers) SHALL call `FAngelscriptTestEngine::Create`
  - 12 sites in `AngelscriptEditor/Tests/*` SHALL set `Config.bSkipInitialCompile = true;` inline and call `FAngelscriptEngine::Create`
- **AND** zero callers SHALL retain a reference to the old `CreateUncompiled` symbol

## Testing Requirements

- Target test layer: Engine + Multi-engine + TestEngine + Editor tests (existing prefixes — the factory consolidation is mechanical and preserves observable behavior; the existing test coverage is the contract)
- Expected Automation prefixes covered:
  - `Angelscript.TestModule.Engine.*` — verifies test-module callers see no behavior change after migrating through the wrapper
  - `Angelscript.TestModule.Engine.TestEngine.*` — verifies the wrapper itself still produces an engine with the expected lifecycle
  - `Angelscript.AngelscriptEditor.*` — verifies the 12 editor-test sites still produce a working engine after the inline flag set
- Verification entry points:
  - Build (sanity): `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label clone-removal-7.7-delete-uncompiled -TimeoutMs 900000 -NoXGE`
  - Engine + functional regression: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule" -Label clone-removal-7.8-final -TimeoutMs 1800000`
  - Editor tests: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.AngelscriptEditor" -Label clone-removal-7.8-editor -TimeoutMs 1200000`
