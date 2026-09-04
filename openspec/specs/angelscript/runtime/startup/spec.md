# Runtime Startup

## Purpose

Define the hard reconstruction boundary that keeps the legacy AngelScript source available for reference while making project startup observably dormant.

## Requirements

### Requirement: Legacy runtime is locked dormant during reconstruction

The system SHALL apply one non-configurable startup-wide reconstruction gate that keeps the preserved legacy AngelScript runtime disabled.

#### Scenario: Default startup remains dormant
- **GIVEN** the project is in the reconstruction baseline
- **WHEN** the host project starts and loads the AngelScript modules
- **THEN** the `UAngelscriptSubsystem` is created but owns no primary engine, publishes no ambient engine, and is not allowed to tick
- **AND** legacy runtime, editor, JIT-provider, script-test, coverage, crash-snapshot, directory-watcher, menu, debug-bridge, and optional GameplayTags extension side effects are not started
- **BUT** the AngelScript project settings remain available in the editor

#### Scenario: Compatibility initializer cannot bypass dormancy
- **GIVEN** the hard reconstruction gate is active
- **WHEN** a caller invokes `FAngelscriptRuntimeModule::InitializeAngelscript()` or requests subsystem engine initialization
- **THEN** no AngelScript engine is created, adopted, or published

#### Scenario: Configuration cannot reactivate legacy startup
- **GIVEN** the hard reconstruction gate is active
- **WHEN** project configuration is changed or a compatibility initializer is invoked
- **THEN** the legacy runtime remains dormant
- **AND** reactivation requires a later explicit implementation Change with its own verification

### Requirement: Dormant modules retain reversible shells

The system SHALL keep legacy runtime, editor, test, JIT carrier, and optional-plugin module shells loadable while cleaning up only the services each module actually started.

#### Scenario: Disabled module shutdown is side-effect safe
- **GIVEN** a module loaded under the hard reconstruction gate
- **WHEN** Unreal shuts down that module
- **THEN** shutdown does not unregister, detach, or cancel legacy services that were never started
- **AND** the retained settings registration is removed normally
