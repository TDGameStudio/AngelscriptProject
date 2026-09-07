# Tagged source history

## Purpose

Define source trees whose named versions can be materialized consistently by
tools and C++ consumers without conflating source ancestry with reload execution.

## ADDED Requirements

### Requirement: A source history has one root and named single-parent versions

The system SHALL represent one source history by one SourceId, a root payload and
tree-local VersionTags with a single parent for every non-root version.

#### Scenario: A history branches
- **GIVEN** root with children body-update and broken-type
- **WHEN** the history is validated and enumerated
- **THEN** both children retain root as their parent and are independently addressable
- **AND** enumeration is deterministic regardless of source declaration order

#### Scenario: A malformed tree is admitted
- **WHEN** a history contains duplicate tags, an unknown parent, a self-parent, a cycle or ambiguous snapshot markers
- **THEN** validation rejects it with the offending source location and relationship

#### Scenario: Different trees reuse a tag
- **WHEN** two SourceIds both define body-update
- **THEN** their references remain distinct because a VersionTag is resolved within its SourceId

### Requirement: Authored snapshots determine generated diffs

The system SHALL derive external parent-to-child diffs from full authored
snapshots and verify exact reconstruction before embedding them.

#### Scenario: A child snapshot is exported
- **WHEN** a non-root version is processed
- **THEN** applying its generated diff to the declared parent yields the materialized child bytes
- **AND** reversing the diff restores the declared parent
- **AND** the embedded representation carries parent and child content hashes

#### Scenario: An unchanged snapshot is declared as a new version
- **WHEN** a child snapshot is identical to its parent
- **THEN** validation reports a redundant source version
  > Details: A no-change observation or analysis references the existing tag; it does not require a fake diff edge.

#### Scenario: Empty source differs from module deletion
- **WHEN** a version intentionally contains empty source bytes
- **THEN** it remains a source payload subject to the consumer's compilation contract
- **BUT** materialization does not delete a runtime module

### Requirement: Version materialization follows source ancestry only

The system SHALL resolve a tagged source from its immutable root and parent
relationships, validating payload identity independently of consumer runtime state.

#### Scenario: A consumer currently uses another branch
- **GIVEN** the consumer previously used body-update
- **WHEN** it resolves broken-type whose parent is root
- **THEN** materialization uses root as the diff base
- **BUT** it does not patch the consumer's body-update payload or change its runtime state

#### Scenario: Embedded diff data is corrupted
- **WHEN** a diff context or parent/child hash fails validation
- **THEN** materialization returns an error before publishing a source value

#### Scenario: A repaired source descends from an invalid source
- **GIVEN** repaired has broken-type as its source parent
- **WHEN** repaired is materialized
- **THEN** its bytes are reconstructed through that source ancestry
- **BUT** this does not assert that broken-type compiled or became active

### Requirement: All source histories participate in public validation

The system SHALL route admitted SourceHistory files through actual tree and
payload validation rather than excluding them from ordinary source inventory.

#### Scenario: A history contains an unsupported marker
- **WHEN** the public strict validator processes the admitted file
- **THEN** it reports the unsupported marker with a location
- **BUT** it does not silently discard a path, dependency or oracle instruction

### Requirement: History provenance survives extraction

The system SHALL preserve a materialized version's SourceId, VersionTag, logical
file path and mapping into the authoring document.

#### Scenario: A diagnostic refers to a child snapshot
- **WHEN** a frontend diagnostic selects bytes extracted from a child's comment-contained snapshot
- **THEN** the test report identifies that version and maps the diagnostic to its authored snapshot
- **AND** the logical diagnostic continues to use the bytes actually compiled

### Requirement: Local and external histories share a source contract

The system SHALL accept locally assembled immutable snapshots and external
embedded root/diff data through the same checked version lookup contract.

#### Scenario: A C++ case assembles a local history
- **WHEN** it supplies root and named child source objects with explicit parents
- **THEN** the same tree constraints and tag lookup behavior apply
- **BUT** it need not generate runtime diffs or parse annotation instructions
