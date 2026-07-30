## ADDED Requirements

### Requirement: Reader-navigation metadata is validated and orthogonal

A formal document MAY define `as-nav-group`, `as-nav-order`, `as-nav-parent`, and `as-feature-key`. When `as-nav-group` is present it SHALL use a registered reader-group key and `as-nav-order` SHALL be a positive integer. `as-nav-parent`, when present, SHALL name an existing logical document key. `as-feature-key`, when present, SHALL be a locale-neutral stable identifier and unique among logical documents.

These fields SHALL supplement rather than replace the required formal-document fields and primary topic tag.

#### Scenario: Valid reader-navigation document is inspected

- **WHEN** validation inspects a formal document with reader-navigation metadata
- **THEN** its group SHALL resolve to a registered group
- **AND** its order SHALL be positive
- **AND** its feature key and parent relationship SHALL be valid
- **AND** its existing topic, locale, depth, lifecycle, revision, and source rules SHALL still apply

#### Scenario: Navigation metadata is invalid

- **WHEN** a document uses an unknown group, nonpositive order, missing parent, duplicate feature key, or reader metadata without formal-document identity
- **THEN** validation SHALL fail with the file, tiddler title, field, and invalid relationship

### Requirement: Reader groups use neutral navigation data

Reader group definitions SHALL be tagged `ASWiki/ReaderNav`, SHALL define stable `as-nav-key` and positive `as-order` fields, and SHALL remain separate from `ASWiki/Docs` topic tags. Group definitions SHALL not declare formal-document lifecycle, depth, locale, or provenance fields.

#### Scenario: Reader group directory is generated

- **WHEN** the Wiki queries `ASWiki/ReaderNav`
- **THEN** it SHALL discover the exact registered reader groups in numeric order
- **AND** it SHALL not treat those group tiddlers as reviewed documentation or topic ownership

#### Scenario: Reader group is incorrectly used as a topic

- **WHEN** a formal document is tagged only with a reader group or a reader group is tagged into the documentation topic hierarchy
- **THEN** validation SHALL fail
- **AND** the document SHALL still require its primary `ASWiki/Docs/<topic-key>` tag
