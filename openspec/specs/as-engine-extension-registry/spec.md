# as-engine-extension-registry Specification

## Purpose
TBD - created by archiving change refactor-as-engine-extension-hooks. Update Purpose after archive.
## Requirements
### Requirement: Optional engine extensions can register with Angelscript
The runtime SHALL provide a registry for optional engine extensions to register and unregister themselves without changing runtime behavior when the registry is unused.

#### Scenario: No extensions keeps runtime behavior unchanged
- **WHEN** Angelscript initializes and shuts down with no registered extensions
- **THEN** existing runtime behavior SHALL remain unchanged and no extension-specific work SHALL be performed

#### Scenario: Extension registers before an engine is active
- **WHEN** an extension registers while no engine is currently active
- **THEN** the registry SHALL remember the extension and attach it to the next active engine

#### Scenario: Extension registers after an engine is already active
- **WHEN** an extension registers while an engine is already active
- **THEN** the registry SHALL attach that extension to the current engine without requiring a process restart

### Requirement: Registered extensions can replay cached state to the current engine
The runtime SHALL expose an explicit replay path so an extension can rebind its cached state to the currently scoped engine.

#### Scenario: Replay reattaches cached state
- **WHEN** a registered extension requests a replay against the current engine
- **THEN** the extension SHALL be able to reregister its engine-local bindings using its cached process-level state

#### Scenario: Replay works after the active engine changes
- **WHEN** the current engine changes and a registered extension requests a replay
- **THEN** the extension SHALL be able to materialize its state on the new current engine without a process restart

### Requirement: Unregistering an extension stops future lifecycle callbacks
The runtime SHALL stop delivering future engine attach and replay callbacks to an unregistered extension.

#### Scenario: Unregistered extension is not replayed
- **WHEN** an extension is unregistered
- **AND** a new engine becomes current later
- **THEN** the registry SHALL not invoke that extension for the new engine

