# TestCode source contract

## Purpose

Define one reusable source interface for authored, inline and generated AS test
inputs, with explicit identities. Checked-in AngelScript originals use structured
mirrored registrations; this Change must not emit a second shard or aggregate
carrier for that corpus.

## ADDED Requirements

### Requirement: TestCode is the public source authority

The system SHALL expose source lookup, enumeration and query through
`FAngelscriptTestCode` while keeping case execution and expectations outside the
source registry.

#### Scenario: Consumers reuse one source
- **GIVEN** an admitted source with an explicit SourceId and VersionTag
- **WHEN** multiple test consumers resolve that reference
- **THEN** each receives the same immutable payload and content identity

    > Observables: The payload retains its logical compiler path and authoring origin.
- **AND** lookup requires neither a case catalog row nor an active AS engine

#### Scenario: A reference does not resolve
- **WHEN** a consumer requests an unknown SourceId or VersionTag
- **THEN** lookup returns a structured source error
- **BUT** an empty successful source is not substituted for the missing reference

    > Boundaries: A deliberately empty payload remains a valid, distinct test input.

### Requirement: Source identity is separate from location and content

The system SHALL distinguish semantic SourceId, tree-local VersionTag, logical
path, authoring origin and payload ContentHash.

#### Scenario: A source moves without changing payload
- **WHEN** an admitted source moves to another authoring file while its explicit identity and materialized payload remain unchanged
- **THEN** its SourceId, VersionTag and ContentHash remain unchanged
- **AND** its authoring origin reflects the new location

#### Scenario: A tag receives edited content
- **WHEN** the payload behind a VersionTag changes
- **THEN** the tag remains addressable with its new ContentHash
- **AND** prior run evidence remains historical rather than proving the edited payload

#### Scenario: Legacy aliases collide
- **WHEN** two admitted sources claim the same lookup identity or legacy alias
- **THEN** catalog validation reports the ambiguity and refuses publication

### Requirement: Source input owns its bytes

The system SHALL expose an immutable source value that keeps its payload alive
and supports exact byte inputs independently of normalized text authoring.

#### Scenario: Exact bytes are malformed text
- **WHEN** a test supplies bytes containing invalid UTF-8, NUL, BOM or mixed newline sequences
- **THEN** the byte input preserves every byte and its explicit length
- **BUT** loading does not repair, truncate or validate the input as an AS program

#### Scenario: An anonymous inline source joins a case bundle
- **WHEN** a case adds an inline source under a unique logical filename
- **THEN** it receives a case-local source identity and the default root tag
- **AND** its lifetime is retained by the case's source bundle
- **BUT** this does not create a permanent global registration

#### Scenario: A bundle has conflicting logical files
- **WHEN** a bundle contains two payloads for the same logical module slot
- **THEN** construction reports the conflict instead of concatenating or silently replacing source

### Requirement: Embedded source delivery is deterministic and self-contained

The system SHALL make admitted TestCode originals available to plugin tests
without requiring parent authoring inputs at test runtime, using the structured
mirrored registrations owned by the checked-in TestCode delivery Change.

    This Change MUST NOT emit byte-array shards, per-byte origin arrays,
    parent-to-child generated diffs, or a generated aggregate as a second
    carrier for `AngelscriptTestCode` or `TestCode/Generated`.

#### Scenario: The plugin consumes structured registrations independently
- **GIVEN** checked-in structured TestCode registrations in the plugin
- **WHEN** the plugin's replacement tests build and resolve admitted sources without the parent authoring directory
- **THEN** they obtain the declared source bytes and metadata
- **AND** source consumption requires neither Python nor a filesystem search for TestSource or `AngelscriptTestCode`

#### Scenario: A competing shard or aggregate carrier is requested
- **WHEN** a catalog or generation tool is asked to emit `NewVersion/Generated/TestCode` shards or an aggregate registrar for the same corpus
- **THEN** it refuses and leaves existing structured registrations unchanged

    > Boundaries: Machine paths, timestamps and parent commit IDs are not generation inputs.

#### Scenario: Catalog validation fails
- **WHEN** case/row catalog validation fails before admission is accepted
- **THEN** existing structured TestCode registrations remain unchanged

#### Scenario: Structured registrations drift from authored fixtures
- **WHEN** the structured-registration `check` differs from authored `.as` files
- **THEN** that Change's consistency check fails with the differing logical entries
- **BUT** this Change does not silently rewrite `TestCode/Generated` during a build

### Requirement: Admission and source inventory remain distinct

The system SHALL keep unconverted corpus inventory separate from executable
admission and validate only explicitly selected entries for a release.

#### Scenario: A small domain is admitted during reconstruction
- **GIVEN** unconverted source files elsewhere in TestSource
- **WHEN** a complete selected domain passes strict source and metadata validation
- **THEN** that domain can be exported without admitting unrelated files
- **AND** the global inventory still reports the other files as unverified or invalid
- **BUT** source presence or export success does not claim compilation or runtime coverage
