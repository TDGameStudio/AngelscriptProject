## MODIFIED Requirements

### Requirement: Selected external document plugins have auditable source provenance

The Wiki SHALL retain selected external integration sources as ordinary tracked files beneath `Wiki/vendor/`. The product manifest SHALL record each source's repository, audited baseline commit, plugin path, expected title, product profile, runtime policy, and allowed external behavior. The runtime set SHALL include focused-tiddler, Draw.io, autocomplete, command palette, and Markdown More; the superseded vendor sidebar resizer, CPL, prevent-edit, preview glass, upstream itonnote theme, and third-party CodeMirror 6 SHALL NOT be active runtime dependencies.

#### Scenario: Source provenance is inspected

- **WHEN** a maintainer inspects the product manifest and vendor delta ledger
- **THEN** each selected integration SHALL identify its upstream baseline and any reviewed local differences
- **AND** every active runtime plugin SHALL belong to the product allowlist

### Requirement: Standard Wiki commands compile selected external sources reproducibly

The Wiki SHALL provide a generated product-source bridge that validates local and vendor source paths, expected plugin titles, profiles, and provenance against the tracked manifest. The bridge SHALL expose only product entries to normal development, verification, and offline build commands and SHALL NOT fetch, update, reset, or change vendor sources.

#### Scenario: Valid product sources are prepared

- **WHEN** a maintainer runs a standard Wiki product command
- **THEN** the generated source root SHALL contain only manifest entries with the product profile
- **AND** plugin-dev SHALL compile from that source root without a network request

#### Scenario: Declared source is invalid

- **WHEN** a declared source is absent, has an unexpected title, or has an unrecorded vendor delta
- **THEN** preparation or verification SHALL fail with a diagnostic identifying the manifest entry
- **AND** it SHALL NOT modify the source repository

### Requirement: Legacy document preferences are retained without importing personal workspace features

The Wiki configuration SHALL retain Chinese language, zoom view, zero animation duration, a 280px initial Vanilla sidebar width, hidden advanced-search, command-palette, layout, refresh, and save-wiki toolbar controls, plus reviewed Markdown More preferences. It SHALL retain mobile close-after-navigation and opt-in page controls without importing journal, graph, synchronization, telemetry, authentication, or personal workspace behavior.

#### Scenario: Reader uses the document experience

- **WHEN** a desktop or narrow-screen reader navigates the Wiki
- **THEN** the accepted left-sidebar and mobile navigation behavior SHALL remain available
- **AND** no personal-workspace service SHALL start implicitly

