## MODIFIED Requirements

### Requirement: Standard Wiki commands compile selected external sources reproducibly

The Wiki SHALL provide a generated product-source bridge that validates local and vendor source paths, expected plugin titles, profiles, and provenance against the tracked manifest. The bridge SHALL expose only product entries to normal development, verification, and offline build commands and SHALL NOT fetch, update, reset, or change vendor sources. Development source changes SHALL be reconciled per manifest entry into a complete generated plugin snapshot so file creation, deletion, and rename batches cannot leave stale generated content.

#### Scenario: Valid product sources are prepared

- **WHEN** a maintainer runs a standard Wiki product command
- **THEN** the generated source root SHALL contain only manifest entries with the product profile
- **AND** plugin-dev SHALL compile from that source root without a network request

#### Scenario: Source changes are reconciled during development

- **WHEN** a maintainer creates, deletes, renames, or rapidly saves files under one declared local or vendor product source
- **THEN** the bridge SHALL coalesce the related events for that manifest entry
- **AND** its generated plugin directory SHALL converge to a complete copy of the current source directory without stale files
- **AND** generated directories for unrelated manifest entries SHALL remain unchanged

#### Scenario: Declared source is invalid

- **WHEN** a declared source is absent, has an unexpected title, or has an unrecorded vendor delta
- **THEN** preparation or verification SHALL fail with a diagnostic identifying the manifest entry
- **AND** it SHALL NOT modify the source repository
