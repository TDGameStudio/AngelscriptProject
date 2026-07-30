## ADDED Requirements

### Requirement: Plugin source snapshots are immutable and reproducible

The Wiki source-reference corpus SHALL identify the AngelScript plugin repository by canonical HTTPS URL and SHALL pin every imported snapshot to a full 40-hex Git commit. The snapshot SHALL be produced from the published repository revision in an isolated temporary checkout and SHALL NOT be copied from the current `Plugins/Angelscript` worktree.

#### Scenario: Maintainer imports a source snapshot

- **WHEN** the maintainer requests synchronization to a published plugin revision
- **THEN** the synchronizer SHALL verify the canonical repository identity and exact commit
- **AND** the resulting manifest SHALL record that commit and the imported tree hash
- **AND** local uncommitted plugin files SHALL NOT enter the snapshot

#### Scenario: Requested revision is a floating branch

- **WHEN** the requested snapshot input does not resolve to an explicit full commit
- **THEN** synchronization SHALL stop before replacing corpus files
- **AND** the diagnostic SHALL explain that ordinary branch names are not reproducible snapshot identities

### Requirement: Source synchronization is explicit and absent from normal Wiki commands

Updating the corpus from GitHub SHALL require a dedicated maintainer command or reviewed automation job. `dev`, `dev:lan`, `dev:wiki`, `test`, `verify`, and `build:wiki` SHALL NOT fetch, pull, clone, or otherwise update the source corpus over the network.

#### Scenario: Contributor runs the normal Wiki verification

- **WHEN** `pnpm run verify` or `pnpm run build:wiki` executes
- **THEN** it SHALL consume only the committed source manifest, registry, and generated excerpts
- **AND** it SHALL make no source-corpus network request

#### Scenario: Maintainer deliberately updates the corpus

- **WHEN** the dedicated synchronization command runs with an exact revision
- **THEN** it MAY access the configured GitHub repository
- **AND** it SHALL produce a reviewable summary of revision, file, license, index, and source-reference changes
- **AND** it SHALL not commit or push the result automatically

#### Scenario: Scheduled automation proposes an update

- **WHEN** a later approved scheduled or manually dispatched workflow discovers a newer permitted source revision
- **THEN** it SHALL resolve and record the full immutable commit
- **AND** it MAY open or update a review branch or pull request
- **AND** it SHALL NOT push directly to the default branch, auto-merge, or publish stale generated excerpts

### Requirement: Private Hazelight source is restricted comparison metadata, not corpus content

The private `Hazelight/UnrealEngine-Angelscript` engine/plugin source SHALL NOT be imported into the public Wiki source corpus, serialized into the Wiki, or emitted as a generated excerpt. An authorized comparison MAY record a restricted evidence key containing repository identity, pinned commit, path, capture date, and purpose. That key SHALL resolve to metadata only and SHALL not fabricate a public URL for inaccessible source.

#### Scenario: Hazelight comparison cites private implementation

- **WHEN** a comparison row uses an authorized private Hazelight source observation
- **THEN** it SHALL store a restricted evidence key and paraphrased finding
- **AND** no private source body, line excerpt, patch body, or inaccessible reader-facing link SHALL be generated

#### Scenario: Corpus synchronizer receives the Hazelight repository

- **WHEN** the normal plugin-source synchronizer is given a private Hazelight repository identity or a path outside the allowed published TDGameStudio plugin repository
- **THEN** it SHALL reject the source before staging any corpus content
- **AND** it SHALL explain that private reference publication requires a separate authorization and license review

### Requirement: License and provenance boundaries are preserved

The corpus manifest SHALL record repository identity, snapshot revision, imported path policy, and license classifications. It SHALL preserve the plugin MIT license notice and SHALL separately classify `Source/AngelscriptRuntime/ThirdParty/angelscript/` under the AngelScript zlib license. Any additional third-party subtree SHALL require an explicit license record before import or excerpt publication.

#### Scenario: Snapshot contains a newly discovered third-party subtree

- **WHEN** synchronization discovers source under a path with no matching license classification
- **THEN** synchronization SHALL stop before accepting that subtree
- **AND** the report SHALL identify the unclassified path and candidate notice files

#### Scenario: Page renders a source excerpt

- **WHEN** a document displays code derived from the corpus
- **THEN** its source reference SHALL resolve to repository, revision, path, and license classification
- **AND** the page SHALL provide a commit-pinned source link

### Requirement: Documents cite stable source-reference keys

Documentation SHALL reference corpus source through stable keys rather than machine-specific paths, floating GitHub links, or line numbers alone. A registry entry SHALL record repository ID, pinned revision, path, purpose, license classification, optional symbol or textual anchor, optional reviewed line range, and excerpt hash.

#### Scenario: Internals page cites a class or function

- **WHEN** an implementation-principle page identifies a source entry point
- **THEN** its `as-sources` field or source component SHALL use a registered stable key
- **AND** the key SHALL resolve to a commit-pinned file and the selected symbol, anchor, or excerpt

#### Scenario: Two pages cite the same implementation entry point

- **WHEN** multiple documents use one registered source key
- **THEN** they SHALL share its revision and provenance metadata
- **AND** a later corpus update SHALL validate all consumers through that one key

### Requirement: Corpus updates detect stale and broken references

Synchronization SHALL regenerate the source path/symbol index, compare excerpt hashes, and validate every registered key. A moved or changed source MAY be matched by its explicit symbol or textual anchor; it SHALL NOT be silently rebound to an unrelated occurrence. Unresolved or materially changed references SHALL be reported as stale and SHALL block publication of newly generated reviewed excerpts.

#### Scenario: Referenced function moves without changing its anchored identity

- **WHEN** a corpus update finds the registered symbol or anchor at a new reviewed location in the same allowed repository
- **THEN** the update report SHALL propose the new path or range
- **AND** the reference SHALL require review before its excerpt revision advances

#### Scenario: Referenced implementation disappears

- **WHEN** no unambiguous match exists for a registered key
- **THEN** validation SHALL mark the key stale
- **AND** it SHALL list every consuming document
- **AND** it SHALL not substitute a guessed source location

### Requirement: Raw source stays outside the initial Wiki boot payload

The complete raw source snapshot SHALL remain outside normal TiddlyWiki tiddler loading. The Wiki SHALL package only selected generated excerpts and bounded index data needed by current documents. A full in-Wiki source browser, search engine, or runtime code loader SHALL require a separate measured capability.

#### Scenario: Offline Wiki is built with a corpus snapshot

- **WHEN** `build:wiki` produces the integrated offline artifact
- **THEN** the raw repository tree SHALL NOT be serialized into the TiddlyWiki boot store
- **AND** registered excerpts required by published pages SHALL remain readable offline

#### Scenario: A future page requests arbitrary source browsing

- **WHEN** the requested feature needs the entire corpus in the browser
- **THEN** it SHALL be designed and measured in a separate change
- **AND** it SHALL define payload, indexing, search, lazy-loading, and offline behavior before entering the product
