## ADDED Requirements

### Requirement: Reader capability navigation complements the ordered topic architecture

The top-level documentation surface SHALL present a primary reader capability path in addition to the existing ordered fifteen-topic architecture. The capability path SHALL organize direct document links by task and concept; the topic architecture SHALL remain available as a secondary knowledge-system view and SHALL continue to own document topic/depth relationships.

#### Scenario: Reader chooses a navigation mode

- **WHEN** a reader opens `AS/Docs`
- **THEN** the reader SHALL first encounter direct task/capability groups
- **AND** the reader SHALL be able to inspect the preserved fifteen-topic/depth system on the same page
- **AND** neither view SHALL require duplicate document bodies or logical keys

#### Scenario: Existing topic sequence is maintained

- **WHEN** the reader expands the secondary knowledge-system view
- **THEN** the exact existing fifteen topics SHALL appear in their specified order
- **AND** the documents within a topic SHALL retain their actual L0-L5 depths and lifecycle states

### Requirement: Feature catalogs derive from formal document records

A topic-level capability catalog SHALL derive its entries from formal-document metadata rather than a separately handwritten feature checklist when concrete feature pages exist. Catalog entries SHALL link directly to the logical document and expose caption, description, depth, and lifecycle.

#### Scenario: Unreal feature page is added

- **WHEN** a new formal `unreal-language` feature document with a valid feature identity and navigation order is added
- **THEN** the Unreal feature catalog SHALL include it without a second manual catalog edit
- **AND** validation SHALL detect duplicate feature identity or order ambiguity

#### Scenario: Feature remains planned

- **WHEN** a required capability has only a placeholder destination
- **THEN** the generated catalog SHALL display its planned lifecycle
- **AND** the entry SHALL not count as reviewed content
