## ADDED Requirements

### Requirement: GameplayTag support is optional
The system SHALL provide GameplayTag script bindings only when the optional GameplayTag extension plugin is enabled.

#### Scenario: Core runtime without the plugin has no GameplayTag extension behavior
- **WHEN** Angelscript runs with the optional GameplayTag plugin disabled
- **THEN** the core runtime SHALL not register GameplayTag-specific extension state or replay logic

#### Scenario: Enabled plugin provides GameplayTag bindings
- **WHEN** the optional GameplayTag plugin is enabled
- **THEN** GameplayTag script bindings SHALL be available through the extension system

### Requirement: GameplayTag support preserves cached registration behavior
The optional GameplayTag extension SHALL preserve the current cached GameplayTag registration and deduplication behavior.

#### Scenario: Duplicate tag registration is suppressed
- **WHEN** the same GameplayTag is discovered more than once through the extension
- **THEN** the extension SHALL not create duplicate script globals for that tag

#### Scenario: Parent tags are still cached with the child tag
- **WHEN** a tag is registered through the extension
- **THEN** its parent tags SHALL also be cached and made available through the same script binding surface

### Requirement: GameplayTag support can replay to the current engine
The optional GameplayTag extension SHALL provide a replay path that rebinds cached tags to the currently scoped engine.

#### Scenario: Rebind to a fresh engine
- **WHEN** the current engine changes and the GameplayTag extension replays its cached state
- **THEN** the cached GameplayTags SHALL be bound again on the new engine

#### Scenario: Rebind works after late engine attachment
- **WHEN** the extension is enabled after an engine is already active
- **THEN** the current engine SHALL receive the GameplayTag globals without requiring a process restart

### Requirement: GameplayTag support does not require GAS
The optional GameplayTag extension SHALL be usable without enabling `AngelscriptGAS`.

#### Scenario: GameplayTag plugin works without GAS
- **WHEN** a project enables the GameplayTag extension plugin but does not enable `AngelscriptGAS`
- **THEN** GameplayTag script bindings SHALL still be available

## Testing Requirements

- Target test layer: Runtime CppTests or Runtime Integration tests, depending on whether the test needs real engine attach/replay behavior.
- Expected Automation prefix: `Angelscript.TestModule.CppTests.GameplayTags.*`
- Recommended helper/harness: the runtime extension registry test fixture from `as-engine-extension-registry`, plus engine lifecycle helpers that can swap active engines deterministically.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.GameplayTags" -Label angelscript-gameplaytags-extension -TimeoutMs 900000`
