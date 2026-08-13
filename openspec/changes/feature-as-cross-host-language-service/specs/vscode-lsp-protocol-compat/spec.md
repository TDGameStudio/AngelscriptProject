## ADDED Requirements

### Requirement: VS Code consumes authoritative shared diagnostics
The VS Code Language Server bridge SHALL decode authoritative compiler/shared diagnostics from the selected UE or Standalone backend and map their code, source, severity, non-fatal data, UTF-16 range, tags, related information, document version, and rule-set identity into editor-visible results.

#### Scenario: Rich UE diagnostic arrives
- **WHEN** the connected UE DebugServer publishes a negotiated rich diagnostic
- **THEN** VS Code SHALL preserve its rule code, source, severity, full range, tags, and related information
- **AND** it SHALL reject or ignore a snapshot older than the current document version

#### Scenario: Legacy UE diagnostic arrives
- **WHEN** the connected server supports only the legacy diagnostics payload
- **THEN** VS Code SHALL continue to map its positional compiler diagnostics using the established compatibility behavior
- **AND** it SHALL not attempt to decode rich trailing fields

### Requirement: Migrated TypeScript rules do not duplicate shared rules
Once an `ASLINT` rule is provided by the shared C++ evaluator, the TypeScript Language Server SHALL NOT independently emit the equivalent rule. Presentation filtering and future code actions MAY consume the rule result but MUST NOT recompute whether the rule matches.

#### Scenario: UE backend emits missing override
- **WHEN** the shared evaluator publishes `ASLINT1003`
- **THEN** VS Code SHALL display exactly one missing-override diagnostic
- **AND** no TypeScript parser diagnostic SHALL duplicate it

#### Scenario: Offline backend emits unused local
- **WHEN** Native Standalone publishes `ASLINT1001`
- **THEN** VS Code SHALL display the returned diagnostic and Unnecessary tag exactly once

### Requirement: Existing UE-connected behavior remains the default
The extension SHALL default to the current UE-connected Language Server backend when no explicit backend setting is present. Migrating diagnostics SHALL NOT remove existing online completion, hover, signature help, definition, references, rename, asset database, source navigation, or debugging behavior.

#### Scenario: Existing configuration starts
- **WHEN** a user upgrades without selecting the offline backend
- **THEN** the extension SHALL connect to the UE DebugServer using the established database and debugging protocols
- **AND** current non-diagnostic online features SHALL remain registered

#### Scenario: Offline backend is explicitly selected
- **WHEN** a user selects the Standalone backend
- **THEN** the extension SHALL advertise only the capabilities actually provided by that backend
- **AND** the absence of UE-only features SHALL not be represented as an online UE failure

### Requirement: Backend and rule-set changes clear incompatible state
Changing the configured backend SHALL restart the Language Server and clear diagnostic state owned by the previous backend. A rule-set identity change SHALL replace, rather than merge with, prior shared diagnostics.

#### Scenario: User switches from UE to Standalone
- **WHEN** the backend setting changes
- **THEN** the existing server session SHALL shut down and clear its diagnostics before the new server starts
- **AND** semantic authorities SHALL not be mixed inside one active session

#### Scenario: New rule set publishes a snapshot
- **WHEN** a diagnostic snapshot has a different supported rule-set identity
- **THEN** VS Code SHALL replace matching prior shared diagnostics rather than retaining obsolete copies

### Requirement: Protocol compatibility has decoder and duplicate-emission regression coverage
The extension and plugin test suites SHALL cover legacy diagnostics, rich diagnostics, current UE database settings, explicit offline selection, stale versions, Unicode ranges, simultaneous old/new clients, and absence of duplicate shared-rule emissions.

#### Scenario: Legacy fixture is decoded
- **WHEN** the established legacy binary fixture is consumed by the updated extension decoder
- **THEN** decoding SHALL succeed without reading rich fields

#### Scenario: Shared parity fixture is presented through both backends
- **WHEN** equivalent UE and Standalone snapshots are mapped to LSP diagnostics
- **THEN** their normalized editor-visible tuples SHALL match
- **AND** each backend SHALL publish one result per authoritative diagnostic
