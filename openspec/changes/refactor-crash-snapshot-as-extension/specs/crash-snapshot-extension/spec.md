# Spec: Crash Snapshot Extension

## ADDED Requirements

### Requirement: Extension Lifecycle Management

The crash snapshot system SHALL manage its lifecycle through the `IAngelscriptExtension` interface instead of globally initializing during module startup.

#### Scenario: Extension Registration During Module Startup

- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` executes
- **THEN** the crash snapshot extension SHALL be registered through `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension()`

#### Scenario: Extension Is Not Directly Initialized During Module Startup

- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` executes
- **THEN** the system SHALL NOT directly call `FAngelscriptCrashSnapshot::Startup()`

#### Scenario: Extension Is Not Directly Shutdown During Module Unload

- **WHEN** `FAngelscriptRuntimeModule::ShutdownModule()` executes
- **THEN** the system SHALL NOT directly call `FAngelscriptCrashSnapshot::Shutdown()`

#### Scenario: Extension Shutdown Clears Handler State

- **WHEN** `FAngelscriptRuntimeModule::ShutdownModule()` unregisters the crash snapshot extension
- **THEN** the extension SHALL clear any tracked engine attachments and unregister the crash handler even though `FAngelscriptEngineExtensionRegistry::UnregisterExtension()` does not detach currently attached engines

### Requirement: Engine Instance Awareness

The crash snapshot system SHALL respond to creation and destruction events for each `FAngelscriptEngine` instance.

#### Scenario: First Engine Instance Attached

- **WHEN** the first `FAngelscriptEngine` instance attaches to the extension through `OnEngineAttached`
- **THEN** the extension SHALL call `FAngelscriptCrashSnapshot::Startup()` to register the global crash handler

#### Scenario: Middle Engine Instance Attached

- **WHEN** the second or later `FAngelscriptEngine` instance attaches through `OnEngineAttached`
- **THEN** the extension SHALL increment the reference count but SHALL NOT register the crash handler again

#### Scenario: Duplicate Engine Attach

- **WHEN** the same `FAngelscriptEngine` instance is attached more than once
- **THEN** the extension SHALL ignore the duplicate attach and SHALL NOT increment the reference count again

#### Scenario: Middle Engine Instance Detached

- **WHEN** a non-final `FAngelscriptEngine` instance detaches through `OnEngineDetached`
- **THEN** the extension SHALL decrement the reference count but SHALL NOT unregister the crash handler

#### Scenario: Unknown Engine Detach

- **WHEN** an engine instance that was not tracked by the extension detaches
- **THEN** the extension SHALL ignore the detach and SHALL NOT decrement the reference count

#### Scenario: Last Engine Instance Detached

- **WHEN** the last `FAngelscriptEngine` instance detaches through `OnEngineDetached`
- **THEN** the extension SHALL call `FAngelscriptCrashSnapshot::Shutdown()` to unregister the global crash handler

### Requirement: Reference Counting Thread Safety

Engine instance reference counting SHALL be thread-safe and support engine creation/destruction in multithreaded environments.

#### Scenario: Concurrent Engine Instance Creation

- **WHEN** multiple threads create `FAngelscriptEngine` instances and trigger `OnEngineAttached` concurrently
- **THEN** reference count increments SHALL be atomic and free of race conditions

#### Scenario: Concurrent Engine Instance Destruction

- **WHEN** multiple threads destroy `FAngelscriptEngine` instances and trigger `OnEngineDetached` concurrently
- **THEN** reference count decrements SHALL be atomic and free of race conditions

#### Scenario: Concurrent Creation And Destruction

- **WHEN** one thread is attaching an engine instance while another thread is detaching an engine instance
- **THEN** reference count operations SHALL remain consistent and crash handler registration state SHALL be correct

### Requirement: Crash Handler Behavior Preservation

Crash handler behavior and output format SHALL remain identical to pre-extension behavior.

#### Scenario: Crash Snapshot Content Unchanged

- **WHEN** a system crash triggers the `OnHandleSystemError` callback
- **THEN** the generated crash snapshot JSON SHALL contain the same fields and data structure as before

#### Scenario: Crash Snapshot File Path Unchanged

- **WHEN** a system crash occurs with no custom output path configured
- **THEN** the crash snapshot SHALL be written to `<ProjectSaved>/Angelscript/CrashSnapshots/<timestamp>/AngelscriptCrashSnapshot.json`

#### Scenario: Crash Handler Atomic Execution

- **WHEN** a system crash triggers the crash handler
- **THEN** the crash handler SHALL use the `GHandlingCrash` atomic variable to ensure it executes only once

#### Scenario: Current Engine Resolution

- **WHEN** the crash handler executes and needs an engine instance
- **THEN** the system SHALL get the current engine context through `FAngelscriptEngine::TryGetCurrentEngine()`

### Requirement: Testing Interface Compatibility

Testing interfaces SHALL remain backward compatible and unaffected by the extension refactor.

#### Scenario: WriteSnapshotForTesting Remains Functional

- **WHEN** test code calls `FAngelscriptCrashSnapshot::WriteSnapshotForTesting(OutputDir, Marker)`
- **THEN** the system SHALL generate a crash snapshot in the specified directory with the same format used for real crashes

#### Scenario: ConfigureForTesting Remains Functional

- **WHEN** test code calls `FAngelscriptCrashSnapshot::ConfigureForTesting(OutputDir, Marker)`
- **THEN** global crash snapshot configuration SHALL update and subsequent crashes SHALL use that configuration

#### Scenario: Console Command Remains Functional

- **WHEN** a test executes `as.Test.ConfigureCrashSnapshot <dir> <marker>` through the console
- **THEN** the system SHALL call `ConfigureForTesting` and output confirmation logging

### Requirement: Multiple Engine Instance Support

The crash snapshot system SHALL support multiple `FAngelscriptEngine` instances in the process.

#### Scenario: Sequential Engine Creation And Destruction

- **WHEN** engine A is created, A is destroyed, engine B is created, and B is destroyed
- **THEN** the crash handler SHALL register when A is created, unregister when A is destroyed, register again when B is created, and unregister again when B is destroyed

#### Scenario: Overlapping Engine Lifetimes

- **WHEN** engine A is created, engine B is created, A is destroyed, and B is destroyed
- **THEN** the crash handler SHALL register when A is created and unregister only when B is destroyed

#### Scenario: Crash With Multiple Active Engines

- **WHEN** a crash occurs while multiple `FAngelscriptEngine` instances are active
- **THEN** the crash snapshot SHALL be generated from the current engine returned by `FAngelscriptEngine::TryGetCurrentEngine()`

### Requirement: No Memory Leaks

The extension system SHALL NOT introduce memory leaks or resource leaks.

#### Scenario: Extension Object Lifecycle

- **WHEN** the extension is registered through `RegisterExtension` and the module eventually unloads
- **THEN** the extension object SHALL be managed correctly through `TSharedRef` and SHALL NOT leak memory

#### Scenario: Repeated Engine Creation And Destruction

- **WHEN** `FAngelscriptEngine` instances are repeatedly created and destroyed, such as in tests
- **THEN** the system SHALL NOT leak crash handler handles or other resources

#### Scenario: Crash Handler Delegate Handle Management

- **WHEN** the crash handler registers an `FCoreDelegates::OnHandleSystemError` callback in `Startup()`
- **THEN** the callback handle SHALL be removed correctly in `Shutdown()` and SHALL NOT leave a dangling reference

### Requirement: Graceful Degradation

The crash snapshot system SHALL degrade gracefully under error conditions and SHALL NOT block engine initialization.

#### Scenario: Extension Registration Failure

- **WHEN** extension registration fails for any reason, although this should not happen in normal conditions
- **THEN** the system SHALL log an error and SHALL NOT block module startup

#### Scenario: Crash Handler Registration Failure

- **WHEN** `FCoreDelegates::OnHandleSystemError.Add` fails
- **THEN** the system SHALL log an error and SHALL NOT crash or block engine initialization

#### Scenario: Crash Snapshot Write Failure

- **WHEN** the crash snapshot system cannot create the output directory or write the JSON file during a crash
- **THEN** the system SHALL log the error and SHALL NOT trigger a secondary crash

### Requirement: Logging And Diagnostics

The extension system SHALL provide sufficient logging to diagnose crash snapshot lifecycle behavior.

#### Scenario: Engine Attachment Logging

- **WHEN** a `FAngelscriptEngine` instance attaches to the extension
- **THEN** the system SHALL log the engine attachment event and current reference count

#### Scenario: Engine Detachment Logging

- **WHEN** a `FAngelscriptEngine` instance detaches from the extension
- **THEN** the system SHALL log the engine detachment event and current reference count

#### Scenario: Crash Handler Registration Logging

- **WHEN** first engine attachment causes crash handler registration
- **THEN** the system SHALL log "Angelscript crash snapshot handler registered" or similar

#### Scenario: Crash Handler Unregistration Logging

- **WHEN** last engine detachment causes crash handler unregistration
- **THEN** the system SHALL log "Angelscript crash snapshot handler unregistered" or similar
