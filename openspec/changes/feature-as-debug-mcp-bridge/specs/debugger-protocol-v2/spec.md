## MODIFIED Requirements

### Requirement: V2 debugger adapter negotiation

The debugger server SHALL require clients to negotiate debugger adapter protocol V2 or newer before entering an active debugging session, SHALL advertise server version 3, and SHALL preserve a sole V2 controller's legacy behavior.

#### Scenario: V2 client starts debugging

- **WHEN** no controller exists and a connected debugger client sends `StartDebugging` with `DebugAdapterVersion` equal to `2`
- **THEN** the debugger server enters debugging mode for that client and sends a `DebugServerVersion` response containing `3`
- **AND** it SHALL serialize V2 payloads for that socket

#### Scenario: V3 client starts debugging

- **WHEN** no controller exists and a connected debugger client sends `StartDebugging` with `DebugAdapterVersion` equal to `3`
- **THEN** the debugger server enters debugging mode for that client
- **AND** it SHALL send both server version negotiation and a V3 accepted session result

#### Scenario: Legacy client is rejected

- **WHEN** a connected debugger client sends `StartDebugging` with `DebugAdapterVersion` lower than `2`
- **THEN** the debugger server does not enter active debugging mode for that client and exposes a deterministic failure behavior that tests can assert

### Requirement: Debugger protocol state isolation

The debugger server SHALL avoid using global mutable adapter-version state to decide how protocol payloads are serialized and SHALL isolate negotiated version and role per debugger socket.

#### Scenario: Reconnect does not inherit stale adapter state

- **WHEN** a V2 or V3 debugger client disconnects and a new client connects
- **THEN** the new client receives payloads based on its own successful negotiation rather than stale state from the previous client

#### Scenario: Multiple passive clients receive deterministic payloads

- **WHEN** V2 and V3 clients are connected during the same debugger server lifetime
- **THEN** each client receives payloads in its own negotiated format regardless of connection order

#### Scenario: Controller role is isolated from passive clients

- **WHEN** passive database or diagnostics clients coexist with one controller
- **THEN** passive connections SHALL NOT acquire or mutate controller state without a successful `StartDebugging`
- **AND** removing a passive client SHALL NOT reset the active controller
