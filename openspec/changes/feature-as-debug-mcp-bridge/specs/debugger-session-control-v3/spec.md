## ADDED Requirements

### Requirement: DebugServer V3 preserves V2 wire compatibility

The server SHALL advertise protocol version 3 while preserving the V2 binary envelope and all existing V2 message ordinals.

#### Scenario: V3 negotiation

- **WHEN** a client sends `StartDebugging` with adapter version 3
- **THEN** the server SHALL reply with `DebugServerVersion=3`
- **AND** subsequent versioned payloads SHALL use that connection's negotiated version

#### Scenario: Reserved StopPIE ordinal

- **WHEN** V3 message ordinals are inspected
- **THEN** ordinal 44 SHALL remain reserved for the historical TypeScript-only `StopPIE`
- **AND** `DebugSessionResult` and `DebugCommandError` SHALL use later ordinals

### Requirement: Debug protocol version is isolated per connection

The server SHALL store negotiated protocol version per socket and SHALL not use process-global mutable adapter-version state for serialization.

#### Scenario: Mixed V2 and V3 passive connections

- **WHEN** V2 and V3 sockets coexist
- **THEN** each outgoing call-stack and variable payload SHALL be serialized according to its destination socket
- **AND** disconnecting either socket SHALL not change the other's payload format

### Requirement: A target has one active debug controller

The first successfully started debugger SHALL own an exclusive controller lease until it stops or disconnects, and no forced takeover SHALL be supported.

#### Scenario: First V3 controller starts

- **WHEN** no controller exists and a V3 client sends `StartDebugging`
- **THEN** that socket SHALL become controller
- **AND** it SHALL receive an accepted `DebugSessionResult`

#### Scenario: Second V3 controller is busy

- **WHEN** another V3 socket sends `StartDebugging` while a controller exists
- **THEN** it SHALL receive `DebugCommandError` code `Busy`
- **AND** the existing controller SHALL remain unchanged
- **AND** the second socket SHALL remain connected as a passive client

#### Scenario: Second V2 controller is disconnected

- **WHEN** a V2 socket attempts `StartDebugging` while a controller exists
- **THEN** the server SHALL close that socket without changing the existing controller

#### Scenario: Owner disconnects while paused

- **WHEN** the controller socket disconnects while script execution is paused
- **THEN** the server SHALL resume execution
- **AND** it SHALL clear controller-owned breakpoints, filters, data breakpoints, and pending break-next state
- **AND** the lease SHALL become available

### Requirement: Control commands are owner and state checked

The server SHALL accept execution, inspection, breakpoint, exception-filter, and data-breakpoint control commands only from the controller and in a valid execution state.

#### Scenario: Passive client sends control command

- **WHEN** a V3 passive client sends a control command
- **THEN** the server SHALL reply with code `NotController`
- **AND** target state SHALL not change

#### Scenario: Step while running

- **WHEN** the controller sends StepIn, StepOver, or StepOut while not paused
- **THEN** the server SHALL reply with code `InvalidState`
- **AND** it SHALL not arm break-next

#### Scenario: Inspect while running

- **WHEN** the controller requests stack, variables, or evaluate while running
- **THEN** the server SHALL return a deterministic `InvalidState` failure

### Requirement: V3 mutation commands have deterministic acknowledgement

Every accepted or rejected V3 mutation command SHALL produce one matching result or structured error.

#### Scenario: Breakpoint accepted at requested line

- **WHEN** a valid V3 controller sets a source breakpoint that does not move
- **THEN** the server SHALL return its final breakpoint payload
- **AND** it SHALL send an accepted `DebugSessionResult` for `SetBreakpoint`

#### Scenario: Command rejected

- **WHEN** a V3 command is rejected because of ownership, state, argument, or protocol rules
- **THEN** the server SHALL send `DebugCommandError` with the original command type and stable error code
- **AND** no accepted result SHALL be sent for that command

### Requirement: V2 debugging remains supported

A sole V2 controller SHALL retain the established V2 breakpoint, pause, step, stack, variable, evaluate, filter, and data-breakpoint behavior without receiving V3-only result messages.

#### Scenario: Sole V2 client

- **WHEN** one V2 client negotiates and debugs without a competing controller
- **THEN** existing V2 message payloads and events SHALL remain wire compatible
- **AND** `DebugSessionResult` and `DebugCommandError` SHALL not be sent to it
