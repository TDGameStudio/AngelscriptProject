## ADDED Requirements

### Requirement: Private Hazelight source remains restricted metadata

The Wiki SHALL represent an authorized private Hazelight source observation only as revisioned repository identity, logical path, capture date, purpose, and other non-body metadata together with a paraphrased finding. It SHALL NOT store or publish private source bodies, excerpts, patch bodies, body-derived hash payloads, fabricated public source links, or private mirrors. Normal Wiki development, tests, builds, publication, and page rendering SHALL NOT access a private repository.

#### Scenario: Comparison records an authorized private observation

- **WHEN** a Hazelight comparison uses an authorized private source observation
- **THEN** the evidence SHALL contain only revisioned metadata and a paraphrased finding
- **AND** it SHALL identify the evidence as restricted
- **AND** it SHALL NOT expose private source content or an inaccessible reader-facing link

#### Scenario: Normal Wiki command executes

- **WHEN** a contributor runs development, test, verification, build, publication, or page-rendering commands
- **THEN** the command SHALL use only committed public content and permitted restricted metadata
- **AND** it SHALL NOT clone, fetch, query, or otherwise access a private Hazelight repository

#### Scenario: Public source-corpus capability is absent

- **WHEN** the Wiki no longer contains a public plugin source-corpus subsystem
- **THEN** the private-source restrictions SHALL remain enforceable through the content architecture and contributor guidance
- **AND** removal of corpus tooling SHALL NOT authorize a replacement private-source copy or excerpt path
