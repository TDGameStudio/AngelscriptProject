## ADDED Requirements

### Requirement: Debug MCP is a local stdio server for one UE target

`AngelscriptDebugMCP` SHALL expose MCP over stdio, connect to one configured AngelScript DebugServer target, write protocol output only to stdout, and write diagnostics only to stderr.

#### Scenario: Default target

- **WHEN** the process starts without target overrides
- **THEN** it SHALL target `127.0.0.1:27099`
- **AND** it SHALL not scan for or multiplex multiple editors

#### Scenario: Multiple editors

- **WHEN** a user needs to debug two UE Editor instances
- **THEN** the user SHALL run two separately named/configured MCP processes

### Requirement: Debug MCP exposes the complete bounded debug tool set

The server SHALL expose session, source-breakpoint, exception-filter, data-breakpoint, execution-control, stack, scope, variable, and evaluate tools defined by the design.

#### Scenario: Tool enumeration

- **WHEN** an MCP host lists tools
- **THEN** it SHALL receive exactly `get_debug_status`, `start_debugging`, `stop_debugging`, `set_breakpoints`, `list_breakpoints`, `list_exception_filters`, `set_exception_filters`, `set_data_breakpoints`, `list_data_breakpoints`, `clear_data_breakpoints`, `pause_execution`, `continue_execution`, `step_over`, `step_into`, `step_out`, `wait_for_stop`, `get_call_stack`, `get_scopes`, `get_variables`, and `evaluate`
- **AND** it SHALL not receive source-edit, set-variable, arbitrary-call, snippet, reload, coverage, asset, Blueprint, native-break, StopPIE, or definition tools

### Requirement: Source breakpoint paths are explicit

Source breakpoints SHALL normally use an absolute local `.as` path; virtual or mapped paths SHALL require `module_name`.

#### Scenario: Absolute path breakpoint

- **WHEN** `set_breakpoints` receives an absolute `.as` path and valid lines
- **THEN** it SHALL replace the MCP session's breakpoints for that path
- **AND** return each requested id with verified final line and condition

#### Scenario: Virtual path without module

- **WHEN** a non-absolute or virtual path is provided without `module_name`
- **THEN** the tool SHALL fail with `InvalidArgument`

### Requirement: Execution tools have deterministic waiting semantics

Pause and step tools SHALL wait for a newer stopped event, continue SHALL return after entering running state, and `wait_for_stop` SHALL only observe.

#### Scenario: Pause reaches script line

- **WHEN** `pause_execution` is called while a controller is running and AngelScript next executes a debuggable line
- **THEN** the tool SHALL return the new stop generation, reason, and top source location

#### Scenario: Step reaches next stop

- **WHEN** a step tool is called while paused
- **THEN** it SHALL invalidate old references
- **AND** wait for and return a newer stopped generation and location

#### Scenario: Continue resumes

- **WHEN** `continue_execution` is called while paused
- **THEN** it SHALL return after the session is running
- **AND** all old frame, scope, variable, and data-breakpoint candidate references SHALL be stale

#### Scenario: Wait timeout

- **WHEN** `wait_for_stop` reaches its timeout
- **THEN** it SHALL return `Timeout`
- **AND** it SHALL not pause, continue, or otherwise change target state

#### Scenario: Pause or step timeout

- **WHEN** pause or step reaches its timeout before a newer stop
- **THEN** the client SHALL send Continue to cancel outstanding pause/break-next state
- **AND** the tool SHALL return `Timeout`

### Requirement: Inspection uses opaque generation-scoped references

Frames, scopes, variables, and data-breakpoint candidates SHALL be represented by opaque references tied to a stop generation, and raw addresses SHALL never appear in MCP results.

#### Scenario: Variable expansion

- **WHEN** `get_variables` expands a valid scope or variable reference while paused
- **THEN** it SHALL return name, display value, type, member flag, and optional opaque child/data-breakpoint references
- **AND** it SHALL not return `ValueAddress` or `ValueSize`

#### Scenario: Stale reference

- **WHEN** a caller uses a reference created before resume or a later stop
- **THEN** the tool SHALL fail with `StaleReference`

### Requirement: Data breakpoints are bounded and address-free

The MCP session SHALL support at most four data breakpoints sourced from valid paused variable candidates and SHALL keep monitored addresses only in process memory.

#### Scenario: Four data breakpoints

- **WHEN** up to four valid candidates are submitted
- **THEN** the server SHALL configure and list them by opaque id, name, hit count, and logical status
- **AND** no address SHALL be returned

#### Scenario: Fifth data breakpoint

- **WHEN** a request would configure more than four data breakpoints
- **THEN** it SHALL fail with `InvalidArgument`

### Requirement: Evaluate keeps existing debugger path semantics

`evaluate` SHALL resolve the same member, subscript, local, member, and global paths as the current VS Code debugger and SHALL reject assignment or arbitrary statement syntax.

#### Scenario: Getter-backed expression

- **WHEN** a valid path resolves through a property or global getter
- **THEN** the debugger MAY execute that getter as part of existing debugger semantics
- **AND** the tool description SHALL warn that getter evaluation can execute script code

#### Scenario: Assignment expression

- **WHEN** an expression contains assignment or arbitrary statement syntax
- **THEN** the tool SHALL fail with `InvalidArgument`

### Requirement: Errors and disconnects are stable

Busy, invalid state, invalid argument, timeout, disconnect, protocol failure, and stale references SHALL map to stable MCP error codes and reject all affected pending operations.

#### Scenario: Controller busy

- **WHEN** `start_debugging` is called while another controller owns the UE target
- **THEN** it SHALL fail with `Busy` without forced takeover

#### Scenario: TCP disconnect

- **WHEN** the DebugServer connection closes with requests pending
- **THEN** every pending operation SHALL fail with `Disconnected`
- **AND** `get_debug_status` SHALL report disconnected state
