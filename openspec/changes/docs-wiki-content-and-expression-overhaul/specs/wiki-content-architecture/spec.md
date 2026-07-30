## ADDED Requirements

### Requirement: Formal document status progresses against a single tracked source of truth

Formal Chinese document completion SHALL be driven from a single status matrix that lists every formal `zh-Hans` document with its `as-doc-key`, current `as-content-status`, `as-depth`, `as-doc-kind`, `as-nav-group`, target status, and outstanding work. Status progression SHALL move through `placeholder → draft → reviewed → published`, and a document SHALL NOT be advanced to a higher status without the evidence the content contract requires for that status.

#### Scenario: A document status is advanced

- **WHEN** a maintainer advances a document from one status to the next
- **THEN** the status matrix SHALL be updated to reflect the new current status
- **AND** the document SHALL satisfy the content-contract evidence for the target status before the advance is recorded
- **AND** planning prose SHALL NOT be marked `reviewed`

#### Scenario: A placeholder is completed

- **WHEN** a `placeholder` document is filled
- **THEN** it SHALL contain the required non-empty sections (reader outcome, planned outline, known sources, source entry points, dependencies/related pages, and review status) before being counted as `draft` or higher

#### Scenario: Completion is reported from the matrix

- **WHEN** documentation completeness is calculated
- **THEN** counts SHALL be derived from the status matrix
- **AND** `placeholder` and unreviewed pages SHALL NOT count as reviewed or published content

### Requirement: Content batches advance without adding a navigation level

Batch content work organized by `nav-group` or topic SHALL preserve the existing two-level primary navigation (seven task/learning groups then concrete formal documents) and the fifteen-topic/L0–L5 system as the secondary knowledge-system view. A batch SHALL NOT introduce a third navigation level, restore a retired tag, or duplicate a document body or logical key.

#### Scenario: A content batch reorganizes topic or depth ownership

- **WHEN** a batch adjusts a document's `nav-group`, topic, or `as-depth`
- **THEN** each formal Chinese document SHALL still appear exactly once in the primary two-level path
- **AND** the secondary fifteen-topic/depth view SHALL remain the ownership system
- **AND** no third navigation level or retired tag SHALL be introduced
