## ADDED Requirements

### Requirement: Documentation exposes an ordered reader-capability path

The Wiki SHALL provide a primary reader-navigation path with the exact ordered group keys `getting-started`, `language-basics`, `script-features`, `unreal-development`, `bindings-extensions`, `workflow-validation`, and `internals-reference`. Each group SHALL have a Chinese caption, a reader-outcome description, and an explicit numeric order stored as content data.

The primary navigation SHALL have exactly two visible levels: reader group, then direct formal-document links. Every current Chinese formal document SHALL belong to one reader group. `as-nav-parent` MAY record a suggested reading relationship but SHALL NOT create a third visible level or an intermediate navigation destination.

#### Scenario: Reader opens the documentation directory

- **WHEN** `AS/Docs` renders
- **THEN** the seven reader groups SHALL appear in the specified order before the secondary knowledge-system view
- **AND** each group SHALL flat-list its concrete formal documents in `as-nav-order`
- **AND** the union of the seven groups SHALL contain every current Chinese formal document exactly once
- **AND** each listed document SHALL link directly to its concrete locale-resolved tiddler
- **AND** no document SHALL require a third navigation level

#### Scenario: Navigation labels are localized

- **WHEN** a group caption or document caption changes for a locale
- **THEN** its group key, feature key, logical document key, and numeric order SHALL remain stable

### Requirement: Reader navigation and knowledge ownership remain separate axes

A reader-navigation document SHALL retain its existing formal-document identity, primary `ASWiki/Docs/<topic-key>` ownership tag, locale, depth, kind, lifecycle, revision, and sources. Reader grouping SHALL NOT replace topic ownership or create a second documentation topic tag hierarchy.

#### Scenario: Concrete feature appears in the reader path

- **WHEN** a document defines `as-nav-group`
- **THEN** it SHALL still have a valid primary documentation topic
- **AND** the secondary knowledge-system directory SHALL discover it through that topic
- **AND** the primary directory SHALL discover it through the reader-navigation field

#### Scenario: Document is intentionally maintainer-only

- **WHEN** a formal document has no reader-navigation group
- **THEN** it MAY remain discoverable through its topic/depth and search
- **AND** validation SHALL NOT fabricate a primary reader path for it

### Requirement: Concrete feature identity is stable and unique

Concrete language, Unreal script, integration, binding, workflow, and internals capability pages exposed in the primary directory SHALL define a stable `as-feature-key`. Feature keys SHALL be locale-neutral, SHALL NOT depend on a physical filename, and SHALL be unique among logical formal documents.

#### Scenario: Feature page is translated or moved

- **WHEN** a feature page gains an English translation or its source file moves
- **THEN** `as-feature-key` SHALL remain unchanged
- **AND** locale resolution SHALL continue to select the appropriate logical document

#### Scenario: Duplicate feature identity is introduced

- **WHEN** two unrelated logical documents declare the same `as-feature-key`
- **THEN** content-contract validation SHALL fail with both tiddler titles and the duplicated key

### Requirement: Directory entries expose lifecycle and depth without misleading completion

Every concrete directory entry SHALL display its caption, description, depth, and a textual Chinese lifecycle label. The supported labels SHALL distinguish `规划中`, `草稿`, `已审阅`, and `已发布`. Placeholder and draft pages SHALL NOT count toward the reviewed/published completion summary.

#### Scenario: Reader encounters migrated but unreviewed content

- **WHEN** a materialized knowledge page has `as-content-status: draft`
- **THEN** the directory and page SHALL visibly identify it as `草稿`
- **AND** the completion summary SHALL exclude it
- **AND** the reader SHALL still be able to open and search its substantive body

#### Scenario: Status color is unavailable

- **WHEN** styles are disabled, high-contrast presentation overrides colors, or a screen reader reads the entry
- **THEN** the lifecycle meaning SHALL remain available as text

### Requirement: Secondary knowledge-system navigation preserves the foundation

The documentation directory SHALL retain an explicit secondary view of all fifteen existing topics and their actual formal documents. Documents SHALL remain ordered by depth and `as-order`; the view SHALL not require empty L0-L5 pages and SHALL preserve the existing topic keys, compatibility routes, Internals directory, and Showcase system.

#### Scenario: Maintainer audits a topic

- **WHEN** the maintainer expands the knowledge-system view for `unreal-language`
- **THEN** the view SHALL include its landing, practical feature pages, boundaries, internals, and maintenance documents
- **AND** each result SHALL expose its actual depth and lifecycle

#### Scenario: Existing foundation link is followed

- **WHEN** a reader opens any existing foundation logical key or compatibility title
- **THEN** it SHALL remain reachable
- **AND** the dual-axis directory SHALL not require a rename or deletion

### Requirement: The directory is accessible and responsive

The dual-axis directory SHALL use semantic headings, lists or sections, native links, and keyboard-operable disclosure. It SHALL preserve visible focus, SHALL not rely on hover or color alone, SHALL not create nested scrolling, and SHALL fit a 375-pixel viewport without horizontal page overflow. Reduced-motion settings SHALL not remove information or block interaction.

#### Scenario: Keyboard user browses capabilities

- **WHEN** the user navigates the directory with the keyboard
- **THEN** focus order SHALL match visual order
- **AND** each document link and disclosure control SHALL have visible focus
- **AND** opening the secondary view SHALL not trap focus

#### Scenario: Reader uses the left documentation navigation

- **WHEN** the reader expands one of the seven documentation groups in `AS/Navigation`
- **THEN** the second level SHALL contain direct links to the same formal tiddlers shown by `AS/Docs`
- **AND** there SHALL be no enclosing “documentation entry” level between the group and document
- **AND** active-page indication SHALL be applied to the direct tiddler link

#### Scenario: Reader opens the directory on a narrow screen

- **WHEN** the viewport width is 375 pixels
- **THEN** reader groups and entries SHALL render in one readable column
- **AND** no document title, lifecycle label, or directory container SHALL cause horizontal page overflow
