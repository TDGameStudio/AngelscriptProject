## ADDED Requirements

### Requirement: Native LSP is a thin stdio adapter over the Language Service
The Native Language Server SHALL use stdio JSON-RPC/LSP framing and SHALL delegate document compilation and shared diagnostics to the resident C++ Language Service. Its first offline milestone SHALL support initialize, shutdown, exit, didOpen, full-text didChange, didClose, and diagnostic publication.

#### Scenario: Client opens and edits a document
- **WHEN** an LSP client sends didOpen followed by a newer full-text didChange
- **THEN** the adapter SHALL update the matching Language Service URI/version
- **AND** it SHALL publish diagnostics only for the current version

#### Scenario: Client closes a document
- **WHEN** didClose is received
- **THEN** the adapter SHALL close the Language Service document and publish an empty diagnostic set for that URI

### Requirement: Offline backend selection is explicit
The VS Code extension SHALL expose an explicit `unreal` or `standalone` Language Server backend setting. `unreal` SHALL remain the default. Changing the backend SHALL restart the Language Server rather than switching semantic authorities inside an active session.

#### Scenario: Existing user upgrades
- **WHEN** no backend setting is configured
- **THEN** the extension SHALL start the existing UE-connected backend behavior

#### Scenario: User selects standalone
- **WHEN** the user selects the offline backend and configuration is valid
- **THEN** the extension SHALL launch the Native stdio Language Server
- **AND** it SHALL not require Unreal Editor or DebugServer for its supported diagnostics milestone

### Requirement: Offline inputs are explicit and fail closed
The offline backend SHALL require explicit Native Language Server executable and compatible profile or complete bundle configuration. It SHALL NOT search implicit caches, merge profiles, guess project roots, or fall back to the UE backend after an invalid explicit selection.

#### Scenario: Configured executable is missing
- **WHEN** the offline backend executable path does not identify a supported server
- **THEN** startup SHALL fail with a concise configuration diagnostic
- **AND** no alternate binary SHALL be launched

#### Scenario: Configured profile is incompatible
- **WHEN** profile schema, hash, rule set, or adapter identity is incompatible
- **THEN** initialization SHALL fail before accepting documents
- **AND** no cached/default profile SHALL replace it

### Requirement: First offline milestone does not replace complete online IDE features
The offline backend SHALL initially advertise only implemented document synchronization and diagnostics capabilities. Existing UE-connected completion, hover, signature help, definition, references, rename, asset database, source navigation, and debugging SHALL remain in the online backend and SHALL not be claimed by the offline server.

#### Scenario: Offline server initializes
- **WHEN** the first milestone responds to initialize
- **THEN** its capabilities SHALL omit unsupported full IDE and debugging features

#### Scenario: UE backend initializes
- **WHEN** the default online backend is selected
- **THEN** its existing supported completion/navigation/debug feature set SHALL remain available

### Requirement: LSP diagnostics preserve shared identity and do not duplicate
The adapter SHALL map authoritative compiler/shared diagnostics to LSP ranges, severities, codes, sources, tags, related information, and document versions. It SHALL not run a second implementation of migrated shared rules.

#### Scenario: Shared diagnostic is published offline
- **WHEN** the Language Service returns an `ASLINT` diagnostic
- **THEN** the LSP diagnostic SHALL retain its rule ID as code, source, severity, range, tags, and related information
- **AND** exactly one corresponding diagnostic SHALL be published

#### Scenario: Stale analysis completes
- **WHEN** analysis for an older document version finishes after a newer didChange
- **THEN** no stale diagnostic publication SHALL replace the current version

### Requirement: Server lifecycle and protocol errors are bounded
The Native server SHALL use bounded message sizes, structured logging separate from stdout protocol bytes, deterministic shutdown, and non-zero process exit for unrecoverable initialization/protocol failures.

#### Scenario: Oversized or malformed message arrives
- **WHEN** Content-Length or JSON-RPC payload violates configured bounds or syntax
- **THEN** the server SHALL reject the message without treating payload bytes as commands or filesystem paths
- **AND** protocol output SHALL remain well framed until deterministic termination

#### Scenario: Shutdown completes
- **WHEN** a valid shutdown and exit sequence is received
- **THEN** documents and Language Service state SHALL be disposed
- **AND** the process SHALL exit without a leaked background worker or open output handle
