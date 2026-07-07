# debugger-protocol-v2 Specification

## Purpose
TBD - created by archiving change refactor-debugger-protocol-v2. Update Purpose after archive.
## Requirements
### Requirement: V2 debugger adapter negotiation

The debugger server SHALL require clients to negotiate debugger adapter protocol V2 or newer before entering an active debugging session.

#### Scenario: V2 client starts debugging
- **WHEN** a connected debugger client sends `StartDebugging` with `DebugAdapterVersion` equal to `2`
- **THEN** the debugger server enters debugging mode for that client and sends a `DebugServerVersion` response containing the current server protocol version

#### Scenario: Legacy client is rejected
- **WHEN** a connected debugger client sends `StartDebugging` with `DebugAdapterVersion` lower than `2`
- **THEN** the debugger server does not enter active debugging mode for that client and exposes a deterministic failure behavior that tests can assert

### Requirement: V2 variable payloads

The debugger server SHALL serialize debugger variables and evaluate results using the V2 variable payload shape, including name, display value, type, member flag, value address, and value size.

#### Scenario: Variables include address metadata
- **WHEN** a V2 debugger client requests variables for a valid debugger scope
- **THEN** each returned variable payload includes `ValueAddress` and `ValueSize` fields after the member flag

#### Scenario: Evaluate includes address metadata
- **WHEN** a V2 debugger client evaluates a debugger expression that resolves to a value
- **THEN** the returned evaluate payload includes `ValueAddress` and `ValueSize` fields after the member flag

### Requirement: Debugger protocol state isolation

The debugger server SHALL avoid using global mutable adapter-version state to decide how protocol payloads are serialized for debugger clients.

#### Scenario: Reconnect does not inherit stale adapter state
- **WHEN** a V2 debugger client disconnects and a new V2 debugger client connects
- **THEN** the new client receives V2 payloads based on its own successful negotiation rather than stale global state from the previous client

#### Scenario: Multiple V2 clients receive deterministic payloads
- **WHEN** two V2 debugger clients are connected during the same debugger server lifetime
- **THEN** both clients receive debugger payloads in the V2 format regardless of connection order

### Requirement: Debugger transport framing remains compatible

The debugger server SHALL preserve the existing binary envelope format for V2 clients.

#### Scenario: Single envelope round trip
- **WHEN** a V2 debugger message is serialized into the debugger transport envelope and then deserialized
- **THEN** the message type and body bytes are preserved

#### Scenario: Truncated envelope waits for more data
- **WHEN** the debugger transport receives fewer bytes than the envelope length declares
- **THEN** deserialization waits for more bytes without producing a complete message or discarding buffered data

#### Scenario: Invalid envelope length is rejected
- **WHEN** the debugger transport receives an envelope length that is zero, negative, or larger than the maximum debugger envelope size
- **THEN** deserialization reports a protocol failure and does not produce a debugger message

### Requirement: Debugger protocol tests live in the Debugger layer

Debugger protocol and transport contract tests SHALL live under the Debugger test layer rather than the temporary C++ migration test directory.

#### Scenario: Protocol tests use Debugger prefixes
- **WHEN** debugger protocol contract tests are added or moved
- **THEN** their automation names use the `Angelscript.TestModule.Debugger.Protocol.*` or `Angelscript.TestModule.Debugger.Transport.*` prefix

#### Scenario: Temporary protocol tests are removed
- **WHEN** the V2 protocol contract tests exist in the Debugger test layer
- **THEN** equivalent protocol and transport tests no longer remain under `Plugins/Angelscript/Source/AngelscriptTest/Temp/`

