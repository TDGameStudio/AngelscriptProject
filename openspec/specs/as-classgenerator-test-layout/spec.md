# as-classgenerator-test-layout Specification

## Purpose
TBD - created by archiving change refactor-classgenerator-test-layout-and-reload-planner. Update Purpose after archive.
## Requirements
### Requirement: Generator tests have semantic layout

Generator automation tests SHALL be grouped by the generated AngelScript surface or generator capability they primarily exercise.

#### Scenario: Generated type behavior test placement

- **WHEN** a test verifies generated `UASClass`, `UASFunction`, `UASStruct`, or script class behavior
- **THEN** the test resides in the corresponding `ASClass`, `ASFunction`, `ASStruct`, or `ScriptClass` Generator subdirectory

#### Scenario: Generator capability test placement

- **WHEN** a test verifies `FAngelscriptClassGenerator` classification, reload planning, validation, or scaffolding behavior
- **THEN** the test resides in the corresponding `ReloadPlanning`, `ComponentValidation`, or `Core` Generator subdirectory

#### Scenario: Test-facing prefix reflects the broad generator theme

- **WHEN** a Generator test registers an Automation test
- **THEN** the test uses an `Angelscript.TestModule.Generator.*` prefix

### Requirement: Reload planner seam is directly testable

The reload requirement propagation algorithm SHALL be exposed as an internal runtime seam that can be tested without compiling AngelScript source.

#### Scenario: Dependency propagation without script compilation

- **WHEN** a direct test constructs reload planner nodes and dependencies
- **THEN** propagation converges to the highest provider requirement visible through each dependency chain

#### Scenario: Existing integration coverage remains stable

- **WHEN** Generator tests move into semantic subdirectories
- **THEN** their production runtime includes and `FAngelscriptClassGenerator` API usage remain unchanged

