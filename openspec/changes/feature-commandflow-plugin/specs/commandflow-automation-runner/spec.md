## ADDED Requirements

### Requirement: Command file runner

`CommandFlow` SHALL provide an automation-facing runner that can execute a command file containing multiple ordered command invocations.

#### Scenario: Command file executes in order

- **WHEN** an automation caller runs a command file with multiple commands
- **THEN** commands execute in file order
- **AND** execution stops or records failure according to the runner's configured failure policy

#### Scenario: Command file reports parse errors

- **WHEN** a command file contains malformed command syntax
- **THEN** the runner reports the line or command that failed to parse
- **AND** no later command is executed unless the configured failure policy allows continuation

### Requirement: Pipeline pause and continue

The automation runner SHALL support pausing and continuing a command pipeline so asynchronous Unreal flows can resume command execution after a later condition.

#### Scenario: Command pauses pipeline

- **WHEN** a command requests pipeline pause
- **THEN** later commands in the active pipeline do not execute until the pipeline is continued

#### Scenario: Pipeline continue resumes execution

- **WHEN** a paused pipeline is continued
- **THEN** execution resumes with the next pending command
- **AND** the final pipeline result includes commands executed before and after the pause

#### Scenario: Mismatched continue is rejected

- **WHEN** a caller attempts to continue a pipeline that is not paused
- **THEN** the runner reports an explicit failure rather than silently corrupting pipeline state

### Requirement: Headless automation result output

The automation runner SHALL expose result output suitable for commandlets, CI, and headless editor runs.

#### Scenario: Runner completes successfully

- **WHEN** all commands in a run complete successfully
- **THEN** the runner returns a success status
- **AND** the runner can write a machine-readable summary of executed commands and result values

#### Scenario: Runner fails

- **WHEN** a command fails and the failure policy stops the run
- **THEN** the runner returns a failure status
- **AND** the runner summary identifies the failed command and diagnostic message

### Requirement: Remote execution is excluded from initial automation runner

The initial automation runner SHALL NOT expose HTTP, WebSocket, MCP, or Python remote execution surfaces.

#### Scenario: Automation dependencies are reviewed

- **WHEN** maintainers inspect the initial automation module dependencies and public entry points
- **THEN** the module does not expose an HTTP command endpoint
- **AND** the module does not expose a Python command bridge
- **AND** any future remote execution surface requires a separate OpenSpec change

### Requirement: Upstream GMP reference is recorded before extraction

Implementation SHALL inspect and record the upstream GenericMessagePlugin/GMP source revision used as the `XConsole` behavior reference before extracting or reimplementing behavior.

#### Scenario: Implementation begins

- **WHEN** implementation work starts for `CommandFlow`
- **THEN** the implementer records the upstream GMP repository source and revision used for `XConsole` reference
- **AND** the implementation does not rely solely on the local `Plugins/UnrealEvent` snapshot for behavior discovery

### Requirement: UnrealEvent GMP XConsole pruning remains a later step

The initial `CommandFlow` implementation SHALL NOT remove GMP `XConsole` from `Plugins/UnrealEvent`, but SHALL leave a clear migration path for later pruning.

#### Scenario: CommandFlow implementation is reviewed

- **WHEN** the `CommandFlow` plugin is implemented
- **THEN** GMP `XConsole` removal is not part of the same implementation scope
- **AND** follow-up work can migrate UnrealEvent diagnostics/tests to `CommandFlow` before removing GMP `XConsole`

## Testing Requirements

- Target test layer: Runtime Integration tests for command-file runner and pipeline behavior; commandlet tests only if the implementation adds a commandlet in v1.
- Expected Automation prefix: `CommandFlow.TestModule.Automation.*` if the new plugin gets its own test module; otherwise use the host project's registered automation prefix for CommandFlow runner tests.
- Recommended helper/harness: native automation test fixtures for file parsing and result output; world-aware helper only for wait commands that require `UWorld` or timers.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Automation." -Label commandflow-automation -TimeoutMs 600000` after the test prefix is registered; use `Tools\RunBuild.ps1` for compile-only module/commandlet scaffolding tasks.
