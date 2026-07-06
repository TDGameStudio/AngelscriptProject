# Spec: Code Coverage Extension

## ADDED Requirements

### Requirement: Extension Lifecycle Management

The code coverage system SHALL manage its lifecycle through the `IAngelscriptExtension` interface instead of being created directly during engine initialization.

#### Scenario: Extension Registration During Module Startup

- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` executes and `WITH_AS_COVERAGE` is defined
- **THEN** the code coverage extension SHALL be registered through `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension()`

#### Scenario: Extension Is Not Directly Initialized During Engine Creation

- **WHEN** `FAngelscriptEngine::Initialize_AnyThread()` executes
- **THEN** the system SHALL NOT directly create a `FAngelscriptCodeCoverage` object or assign a `CodeCoverage` member pointer

#### Scenario: Extension Does Not Use Delayed Callback For Initialization

- **WHEN** `FAngelscriptEngine::PostInitialize_GameThread()` executes
- **THEN** the system SHALL NOT register a `FCoreDelegates::OnPostEngineInit` lambda closure

### Requirement: Engine Instance Awareness

The code coverage system SHALL respond to creation and destruction events for each `FAngelscriptEngine` instance and support independent coverage tracking.

#### Scenario: Engine Instance Attached With Coverage Enabled

- **WHEN** a `FAngelscriptEngine` instance is attached to the extension through `OnEngineAttached` and `FAngelscriptCodeCoverage::CoverageEnabled()` returns true
- **THEN** the extension SHALL create a new `FAngelscriptCodeCoverage` object and own it through exclusive storage managed by the extension

#### Scenario: Engine Instance Attached With Coverage Disabled

- **WHEN** a `FAngelscriptEngine` instance is attached through `OnEngineAttached` but `CoverageEnabled()` returns false
- **THEN** the extension SHALL NOT create a `FAngelscriptCodeCoverage` object

#### Scenario: Engine Instance Detached

- **WHEN** a `FAngelscriptEngine` instance is detached from the extension through `OnEngineDetached`
- **THEN** the extension SHALL release the associated `FAngelscriptCodeCoverage` object

#### Scenario: Multiple Engine Instances With Independent Coverage

- **WHEN** two `FAngelscriptEngine` instances are created and both have code coverage enabled
- **THEN** each engine instance SHALL own an independent `FAngelscriptCodeCoverage` object, and coverage data SHALL NOT interfere across instances

### Requirement: Test Framework Hooks Integration

The code coverage extension SHALL integrate test framework hooks immediately when an engine attaches, without a delayed callback.

#### Scenario: Test Framework Hooks Registration In Editor

- **WHEN** an engine instance attaches to the extension and `WITH_EDITOR` is defined
- **THEN** the extension SHALL call `Coverage->AddTestFrameworkHooks()` to register test framework hooks

#### Scenario: Test Framework Hooks Not Registered Outside Editor

- **WHEN** an engine instance attaches to the extension but `WITH_EDITOR` is not defined
- **THEN** the extension SHALL NOT call `AddTestFrameworkHooks()`

#### Scenario: Graceful Handling Of Missing Automation Module

- **WHEN** `AddTestFrameworkHooks()` executes but `IAutomationControllerModule` is not loaded
- **THEN** the system SHALL log a warning and SHALL NOT crash or block engine initialization

### Requirement: Coverage Object Access Through Extension

Engine and external code SHALL access the code coverage object through the extension system instead of directly through an engine member pointer.

#### Scenario: Access Coverage For Specific Engine

- **WHEN** code calls `FAngelscriptCodeCoverageExtension::GetForEngine(Engine)`
- **THEN** the system SHALL find the associated extension instance through the extension registry and return its `Coverage` pointer

#### Scenario: Access Coverage When Not Enabled

- **WHEN** `GetForEngine(Engine)` is called but that engine instance does not have code coverage enabled
- **THEN** the system SHALL return `nullptr`

#### Scenario: Access Coverage When Extension Not Registered

- **WHEN** `GetForEngine(Engine)` is called but the extension is not registered because `WITH_AS_COVERAGE` is not defined
- **THEN** the system SHALL return `nullptr`

#### Scenario: No Engine Member Pointer For Coverage

- **WHEN** the `FAngelscriptEngine` class definition is inspected
- **THEN** the system SHALL NOT contain a `FAngelscriptCodeCoverage* CodeCoverage` member variable

### Requirement: Coverage Functionality Preservation

All code coverage functionality and APIs SHALL remain identical to behavior before extension refactoring.

#### Scenario: MapExecutableLines Still Works

- **WHEN** coverage calls `MapExecutableLines(Module)` after a module compiles
- **THEN** the system SHALL correctly map executable lines in the module to internal coverage tables

#### Scenario: HitLine Still Works

- **WHEN** script execution triggers a line callback and calls `HitLine(Module, Line)`
- **THEN** the system SHALL correctly record that line execution count

#### Scenario: StartRecording Still Works

- **WHEN** the test framework or user code calls `StartRecording()`
- **THEN** the system SHALL begin recording line hits, and subsequent `HitLine` calls SHALL take effect

#### Scenario: StopRecordingAndWriteReport Still Works

- **WHEN** `StopRecordingAndWriteReport(OutputDir)` is called after tests finish
- **THEN** the system SHALL stop recording and write `coverage_summary.json` to the specified directory

#### Scenario: Runtime HTML Report No Longer Required

- **WHEN** a coverage report is generated
- **THEN** runtime correctness SHALL be represented by `coverage_summary.json`
- **AND** the runtime SHALL NOT be required to write `index.html` or per-file `*.as.html` pages

### Requirement: Memory Management Correctness

Code coverage objects SHALL have correct lifecycle management with no memory leaks or dangling references.

#### Scenario: Coverage Object Properly Destroyed On Engine Detach

- **WHEN** an engine instance detaches from the extension
- **THEN** the associated `FAngelscriptCodeCoverage` object SHALL be automatically destroyed by extension-owned storage

#### Scenario: No Memory Leak In Repeated Engine Creation

- **WHEN** engine instances are repeatedly created and destroyed, such as in tests
- **THEN** the system SHALL NOT leak `FAngelscriptCodeCoverage` objects or their internal data structures

#### Scenario: Test Framework Delegate Handles Properly Removed

- **WHEN** the coverage object is destroyed
- **THEN** automation test delegates registered by `AddTestFrameworkHooks()` SHALL be correctly removed

#### Scenario: No Dangling Lambda Captures

- **WHEN** code no longer uses an `OnPostEngineInit` lambda
- **THEN** the system SHALL NOT contain lambda closures that could leave dangling references

### Requirement: Engine Internal Call Site Updates

All engine-internal code coverage call sites SHALL access coverage through the extension system.

#### Scenario: CompileModules Uses GetForEngine

- **WHEN** `FAngelscriptEngine::CompileModules` needs to call `MapExecutableLines`
- **THEN** the system SHALL get the coverage object through `FAngelscriptCodeCoverageExtension::GetForEngine(*this)`

#### Scenario: Line Callback Uses GetForEngine

- **WHEN** a script line callback needs to call `HitLine`
- **THEN** the system SHALL get the coverage object through `GetForEngine`

#### Scenario: GetOnScreenMessages Uses GetForEngine

- **WHEN** `GetOnScreenMessages` needs to display coverage status
- **THEN** the system SHALL get the coverage object through `GetForEngine`

#### Scenario: State Dump Uses GetForEngine

- **WHEN** `FAngelscriptStateDump` needs to export coverage information
- **THEN** the system SHALL get the coverage object through `GetForEngine(Engine)`

### Requirement: Conditional Compilation Preservation

The code coverage system SHALL preserve existing conditional compilation behavior.

#### Scenario: Extension Only Compiled With WITH_AS_COVERAGE

- **WHEN** `WITH_AS_COVERAGE` is not defined at compile time
- **THEN** `FAngelscriptCodeCoverageExtension` and related code SHALL NOT be compiled

#### Scenario: Extension Registered Only With WITH_AS_COVERAGE

- **WHEN** the module starts and `WITH_AS_COVERAGE` is not defined
- **THEN** the system SHALL NOT register the code coverage extension

#### Scenario: Test Framework Hooks Only In Editor

- **WHEN** an engine attaches to the extension but `WITH_EDITOR` is not defined
- **THEN** the system SHALL NOT attempt to call `AddTestFrameworkHooks()`

### Requirement: Multi-Engine Instance Support

The code coverage system SHALL correctly support multiple `FAngelscriptEngine` instances in the process.

#### Scenario: Sequential Engine Creation With Coverage

- **WHEN** engine A is created with coverage enabled, A is destroyed, engine B is created with coverage enabled, and B is destroyed
- **THEN** each engine instance SHALL own an independent coverage object and lifecycles SHALL NOT interfere

#### Scenario: Overlapping Engine Lifetimes With Coverage

- **WHEN** engines A and B are both created with coverage enabled and exist at the same time
- **THEN** both engine instances SHALL each own independent coverage data and SHALL NOT interfere

#### Scenario: Coverage Data Isolation

- **WHEN** engine A executes scripts and records coverage and engine B also executes scripts
- **THEN** engine A coverage data SHALL NOT contain execution records from engine B

#### Scenario: Independent Coverage Reports

- **WHEN** two engine instances generate coverage reports separately
- **THEN** each report SHALL contain only coverage data for the corresponding engine instance

### Requirement: CoverageEnabled Check Preservation

The static `FAngelscriptCodeCoverage::CoverageEnabled()` check SHALL preserve existing behavior.

#### Scenario: Coverage Enabled Based On Command Line Or Config

- **WHEN** code coverage is enabled through command line arguments or configuration
- **THEN** `CoverageEnabled()` SHALL return true and the extension SHALL create a coverage object

#### Scenario: Coverage Disabled By Default

- **WHEN** no coverage enable flag is set
- **THEN** `CoverageEnabled()` SHALL return false and the extension SHALL NOT create a coverage object

#### Scenario: Coverage Respects WITH_AS_COVERAGE Definition

- **WHEN** `WITH_AS_COVERAGE` is not defined at compile time
- **THEN** the system SHALL NOT provide `CoverageEnabled()` functionality or SHALL return false

### Requirement: Performance And Overhead

The code coverage extension SHALL NOT introduce significant performance overhead or initialization time.

#### Scenario: Extension Registration Minimal Overhead

- **WHEN** the module starts and registers the code coverage extension
- **THEN** registration SHALL complete in milliseconds and SHALL NOT affect module startup performance

#### Scenario: GetForEngine Lookup Efficient

- **WHEN** engine internals call `GetForEngine` to access the coverage object
- **THEN** lookup SHALL be O(1) or O(N), where N is the extension count and is normally less than 10, and SHALL NOT become a performance bottleneck

#### Scenario: Coverage Tracking Overhead Unchanged

- **WHEN** coverage is enabled and script execution triggers line callbacks
- **THEN** the additional overhead of accessing coverage through the extension SHALL be negligible relative to coverage tracking itself

### Requirement: Logging And Diagnostics

The extension system SHALL provide sufficient logging to diagnose code coverage lifecycle and failures.

#### Scenario: Engine Attachment With Coverage Logging

- **WHEN** an engine instance attaches to the extension and coverage is enabled
- **THEN** the system SHALL log "Code coverage enabled for engine instance" or similar

#### Scenario: Engine Detachment Logging

- **WHEN** an engine instance detaches from the extension
- **THEN** the system SHALL log engine detachment and coverage object cleanup

#### Scenario: Test Framework Hooks Registration Logging

- **WHEN** test framework hooks register successfully
- **THEN** the system SHALL log "Code coverage test framework hooks registered" or similar

#### Scenario: Test Framework Hooks Failure Logging

- **WHEN** test framework hook registration fails, such as when the module is not loaded
- **THEN** the system SHALL log a warning describing the failure reason

#### Scenario: Coverage Report Generation Logging

- **WHEN** coverage report generation completes
- **THEN** the system SHALL log the output directory and report file count
