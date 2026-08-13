## ADDED Requirements

### Requirement: Rich diagnostics require per-client capability negotiation
The DebugServer SHALL expose a versioned Rich Diagnostics message only to clients that explicitly negotiate that capability. Negotiated diagnostic capability SHALL be stored per connection and SHALL NOT be inferred from global mutable debugger-adapter state.

#### Scenario: Rich client requests diagnostics
- **WHEN** a connected client advertises the supported Rich Diagnostics version
- **THEN** the server SHALL send that client versioned rich diagnostic snapshots
- **AND** serialization SHALL use that client's negotiated version

#### Scenario: Legacy and rich clients coexist
- **WHEN** one legacy client and one rich client are connected simultaneously
- **THEN** each SHALL receive the payload shape it supports regardless of connection order
- **AND** neither client's negotiation SHALL alter the other's payload

### Requirement: Legacy diagnostics wire layout remains unchanged
The existing `Diagnostics` message type and field order SHALL remain decodable by current clients. New rule IDs, ranges, tags, related information, fatality, versions, and rule-set identity SHALL NOT be appended to the legacy structure.

#### Scenario: Existing decoder consumes a message
- **WHEN** a client that knows only filename, message, line, character, error, and info fields reads legacy diagnostics
- **THEN** it SHALL consume the complete payload without buffer over-read or trailing-field assumptions

#### Scenario: Client does not negotiate rich diagnostics
- **WHEN** diagnostics are emitted to a non-negotiating client
- **THEN** the server SHALL use the legacy message type
- **AND** it SHALL not send an unknown rich message to that client

### Requirement: Rich diagnostics preserve editor and rule semantics
Rich diagnostic entries SHALL carry source and rule ID, four-level presentation severity, explicit non-fatal classification, zero-based UTF-16 start/end range, tags, related information, document version, profile identity, and rule-set version/hash.

#### Scenario: Non-fatal static Error is serialized
- **WHEN** a shared static rule returns Error severity with `nonFatal: true`
- **THEN** the rich payload SHALL preserve both values independently
- **AND** the client SHALL not need to infer fatality from severity

#### Scenario: Unicode source range is serialized
- **WHEN** a rich diagnostic follows non-BMP source text
- **THEN** its full start/end range SHALL use zero-based UTF-16 positions expected by the editor client

### Requirement: Diagnostic snapshots are versioned and replaceable
Rich diagnostics SHALL identify the document version and SHALL support deterministic complete-snapshot replacement, including an empty snapshot when diagnostics clear or a document closes.

#### Scenario: New compilation clears diagnostics
- **WHEN** the current document version has no diagnostics after a prior version had diagnostics
- **THEN** the server SHALL publish an empty rich snapshot for the new version

#### Scenario: Older snapshot is delayed
- **WHEN** a client receives a diagnostic snapshot older than its current document version
- **THEN** the version metadata SHALL permit the client to discard it without clearing current diagnostics
