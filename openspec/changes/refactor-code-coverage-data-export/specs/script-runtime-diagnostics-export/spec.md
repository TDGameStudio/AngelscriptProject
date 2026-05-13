## ADDED Requirements

### Requirement: Export schema supports future diagnostics data

The exported data package SHALL include an explicit extension contract so script runtime diagnostics can be added without redesigning the coverage export format.

#### Scenario: Diagnostics extension fields are present

- **WHEN** the runtime writes the coverage data package
- **THEN** the package SHALL include a diagnostics extension location such as `extensions`
- **AND** absent diagnostics data SHALL be represented explicitly rather than implied by missing HTML sections

#### Scenario: Capture capability metadata is exported

- **WHEN** a consumer reads the data package
- **THEN** the consumer SHALL be able to identify which diagnostic channels are collected, not collected, or planned for exploration

### Requirement: Performance and function timing are tracked as exploration items

The change SHALL record performance and function timing as future diagnostics work, but it SHALL NOT require function timing to be implemented in the first coverage data export.

#### Scenario: Function timing is not collected in the first phase

- **WHEN** the first data-export implementation is complete
- **THEN** the exported package SHALL make clear that function timing is not collected yet
- **AND** tests SHALL NOT require function duration, call count, or inclusive/exclusive timing data to be present as collected metrics

#### Scenario: Potential timing sources are documented

- **WHEN** the design or implementation tasks are reviewed
- **THEN** they SHALL identify the likely timing collection points, including AS VM `Execute()`, script function call transitions, StaticJIT execution paths, and `UASFunction::RuntimeCall*` dispatch

#### Scenario: More runtime information can be evaluated later

- **WHEN** additional script runtime information is considered, such as module metadata, function ranges, compile diagnostics, call counts, or execution cost
- **THEN** the change SHALL provide an explicit exploration task before requiring those fields in the stable export schema

## Testing Requirements

- Target test layer: Runtime Integration for exported metadata; additional layers to be chosen for later diagnostics collectors.
- Expected Automation prefix: `Angelscript.TestModule.Core.CodeCoverage.*` for first-phase export metadata.
- Recommended helper/harness: JSON assertions against the exported `capture_capabilities` and `extensions` sections.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core.CodeCoverage" -Label code-coverage-data-export -TimeoutMs 600000`.
