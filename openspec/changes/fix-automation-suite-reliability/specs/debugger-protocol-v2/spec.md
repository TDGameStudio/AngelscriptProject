## MODIFIED Requirements

### Requirement: Debugger transport framing remains compatible

The debugger server SHALL preserve the existing binary envelope format for V2
clients and SHALL treat TCP input as an incremental byte stream per client.

#### Scenario: Single envelope round trip
- **WHEN** a V2 debugger message is serialized into the debugger transport
envelope and then deserialized
- **THEN** the message type and body bytes are preserved

#### Scenario: Truncated envelope waits for more data
- **WHEN** the debugger transport receives fewer bytes than the envelope length
declares
- **THEN** deserialization waits for more bytes without producing a complete
message or discarding buffered data

#### Scenario: Header and payload arrive in separate socket reads
- **WHEN** a client sends a valid envelope length or body across two or more TCP
socket reads
- **THEN** the server buffers each fragment until the complete envelope is
available
- **AND** it dispatches exactly one message after the final fragment arrives

#### Scenario: Invalid envelope length is rejected
- **WHEN** the debugger transport receives an envelope length that is zero,
negative, or larger than the maximum debugger envelope size
- **THEN** deserialization reports a protocol failure and does not produce a
debugger message
