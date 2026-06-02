## ADDED Requirements

### Requirement: Standalone CommandFlow plugin

The project SHALL provide a standalone plugin named `CommandFlow` for reusable command registration and execution behavior.

#### Scenario: Plugin identity is inspected

- **WHEN** maintainers inspect the new plugin descriptor
- **THEN** the plugin identity is `CommandFlow`
- **AND** the plugin is not named `XConsole` or `GMPConsole`

### Requirement: Lightweight runtime command module

`CommandFlow` SHALL expose a runtime module that owns the reusable command SDK without depending on Angelscript, HTTPServer, or PythonScriptPlugin.

#### Scenario: Runtime dependencies are reviewed

- **WHEN** maintainers inspect the runtime module build dependencies
- **THEN** the module does not depend on `AngelscriptRuntime`
- **AND** the module does not depend on `HTTPServer`
- **AND** the module does not depend on `PythonScriptPlugin`

### Requirement: Typed command registration

The runtime command SDK SHALL allow C++ code to register named commands with help text, typed arguments, command metadata, execution context, and explicit command results.

#### Scenario: Command metadata is queried

- **WHEN** a command is registered with a name, help text, and typed parameter list
- **THEN** callers can query the registered command list
- **AND** callers can query the command's help text and parameter metadata

#### Scenario: Typed command executes successfully

- **WHEN** a registered command receives string arguments that can be converted to its declared parameter types
- **THEN** the command handler executes with typed values
- **AND** the command returns an explicit success result

#### Scenario: Typed command rejects invalid arguments

- **WHEN** a registered command receives arguments that cannot be converted to its declared parameter types
- **THEN** the command handler is not invoked
- **AND** the command returns an explicit failure result with a diagnostic message

### Requirement: Command execution context and result model

The runtime command SDK SHALL provide an execution context and result model suitable for editor, commandlet, and headless automation callers.

#### Scenario: Command writes output

- **WHEN** a command writes diagnostic output through its execution context
- **THEN** the caller receives that output through the configured output sink
- **AND** the command result records whether the command succeeded or failed

#### Scenario: Command reports machine-readable result

- **WHEN** a command sets an integer or string result value
- **THEN** automation callers can retrieve that value after execution
- **AND** the value is not tied to GMP `XConsole` global state names

### Requirement: GMP XConsole is reference material, not public API

`CommandFlow` SHALL use CommandFlow naming for public APIs and documentation while treating GMP `XConsole` as reference material only.

#### Scenario: Public API names are reviewed

- **WHEN** maintainers review public `CommandFlow` headers and plugin documentation
- **THEN** public names use `CommandFlow` terminology
- **AND** public names do not expose `XConsole` as the product or module identity

## Testing Requirements

- Target test layer: Runtime Integration or Runtime C++ tests for command registry and parser behavior, depending on whether the implementation needs UObject/world context.
- Expected Automation prefix: `CommandFlow.TestModule.Runtime.*` if the new plugin gets its own test module; otherwise use the host project's established automation prefix for the new module when defined.
- Recommended helper/harness: small native automation tests without world for registry/parser/result behavior; world-aware helper only for context tests requiring `UWorld`.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow." -Label commandflow-runtime -TimeoutMs 600000` after the test prefix is registered; use `Tools\RunBuild.ps1` for compile-only plugin scaffolding tasks.
