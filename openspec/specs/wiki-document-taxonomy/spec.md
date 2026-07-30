# wiki-document-taxonomy Specification

## Purpose
TBD - created by archiving change docs-wiki-content-foundation. Update Purpose after archive.
## Requirements
### Requirement: Formal documents use a validated metadata contract

Every formal documentation tiddler SHALL define `caption`, `description`, `as-sdk-document`, `as-doc-key`, `as-locale`, `as-depth`, `as-doc-kind`, `as-content-status`, `as-order`, `as-content-revision`, and `as-sources`. English pages SHALL additionally define `as-translation-of`, `as-translation-revision`, and `as-translation-status`.

`as-locale` SHALL be `zh-Hans` or `en-GB`; `as-depth` SHALL be `L0` through `L5`; `as-doc-kind` SHALL be `tutorial`, `guide`, `reference`, `explanation`, `internals`, or `showcase`; `as-content-status` SHALL be `placeholder`, `draft`, `reviewed`, or `published`; and `as-translation-status` SHALL be `draft`, `reviewed`, or `stale`. `as-content-revision` SHALL be a nonnegative integer; it SHALL be positive for reviewed or published content, while placeholder content SHALL use `0`.

Hazelight source-comparison pages SHALL additionally define `as-hazelight-revision`, `as-local-revision`, and `as-comparison-date`. Source-level revisions SHALL be full 40-hex commits; a configured reference without a Git identity SHALL use an explicit evidence object rather than a fabricated commit.

#### Scenario: Formal document has valid fields

- **WHEN** content-contract validation inspects a formal document
- **THEN** all required fields SHALL be present
- **AND** enum fields SHALL use only supported values
- **AND** `as-content-revision` SHALL be a positive integer for reviewed or published content

#### Scenario: Field value is unsupported

- **WHEN** a formal document uses an unknown locale, depth, kind, lifecycle, or translation value
- **THEN** validation SHALL fail with the tiddler title, field name, and invalid value

#### Scenario: Hazelight comparison has an ambiguous baseline

- **WHEN** a Hazelight source-comparison page omits either revision/date or uses a floating branch as its source-level revision
- **THEN** validation SHALL fail with the page and invalid baseline field
- **AND** the page SHALL NOT be treated as reviewed comparison guidance

### Requirement: Topic navigation uses a native TiddlyWiki tag hierarchy

The documentation tag root SHALL be `ASWiki/Docs`. Each first-level topic SHALL use `ASWiki/Docs/<topic-key>` and SHALL be tagged with `ASWiki/Docs`. A formal document SHALL have one primary topic tag and MAY have a bounded set of secondary topic tags.

#### Scenario: Topic directory is generated

- **WHEN** the Wiki queries tiddlers tagged with `ASWiki/Docs`
- **THEN** it SHALL discover the fifteen first-level topic tags
- **AND** their `as-order` values SHALL determine presentation order

#### Scenario: Document has no primary topic

- **WHEN** a formal document is not assigned to a first-level or nested documentation topic
- **THEN** content-contract validation SHALL fail

### Requirement: Orthogonal document state remains in fields

Locale, depth, document kind, content lifecycle, order, provenance, integration kind, and translation lifecycle SHALL be represented by fields rather than mirrored as ordinary tags. Tags SHALL remain focused on topic hierarchy and Showcase tier membership.

#### Scenario: Maintainer filters by depth or status

- **WHEN** the Wiki needs to list L0 documents, placeholders, reviewed Chinese pages, or stale English pages
- **THEN** the filter SHALL use the corresponding fields
- **AND** the Wiki SHALL NOT require tags such as `L0`, `placeholder`, `zh-Hans`, or `stale`

#### Scenario: Reader filters implementation-principle documents

- **WHEN** the Wiki renders a cross-topic “实现原理” directory
- **THEN** the filter SHALL select `as-doc-kind: internals`
- **AND** it SHALL preserve each document's topic tag rather than introducing a duplicate internals tag tree

### Requirement: Legacy ASWiki classification tags are retired

The content foundation SHALL retire `ASWiki/Home`, `ASWiki/Workflow`, `ASWiki/Maintainer`, `ASWiki/Status`, `ASWiki/Theme`, and `ASWiki/Navigation`. Home and navigation SHALL be page roles rather than content categories. Existing workflow, maintainer, and status documents SHALL be assigned to their real `ASWiki/Docs/<topic-key>` topic or explicitly classified as non-reader project metadata. Genuine authoring examples SHALL use the `ASWiki/Showcase` hierarchy.

The foundation MAY retain the `AngelscriptWikiHome` tiddler title as a compatibility/default route, but it SHALL NOT retain `ASWiki/Home` merely to identify that page. Core TiddlyWiki `$:/tags/*` integration tags are outside this retirement.

Non-document entry shells MAY use `as-page-role` with the values `home`, `navigation`, `project-status`, `project-meta`, or `compatibility`. This field does not make the page a formal document and SHALL NOT be used to recreate a navigation hierarchy. `compatibility` is limited to the pre-foundation canonical titles inventoried by this change; new documentation SHALL NOT use it.

#### Scenario: Home remains the default route

- **WHEN** the migrated Wiki opens `AngelscriptWikiHome`
- **THEN** the page SHALL remain reachable and MAY remain the configured default tiddler
- **AND** it SHALL declare `as-page-role: home`
- **AND** it SHALL NOT carry `ASWiki/Home`

#### Scenario: Existing workflow page is migrated

- **WHEN** a current page tagged `ASWiki/Workflow` or `ASWiki/Maintainer` remains available as a compatibility page
- **THEN** it SHALL carry the primary topic tag matching its actual subject
- **AND** it SHALL NOT keep the legacy audience-bucket tag

#### Scenario: Existing mixed-locale page cannot be rewritten in the foundation tranche

- **WHEN** a pre-foundation canonical page is retained only to protect an existing title or link
- **THEN** it MAY use `as-page-role: compatibility`
- **AND** it SHALL link to the mapped topic or reviewed Chinese replacement
- **AND** it SHALL be excluded from reviewed/published documentation counts
- **AND** content-contract validation SHALL reject that role on any title outside the recorded compatibility allowlist

#### Scenario: Contract validation scans content

- **WHEN** the foundation migration is complete
- **THEN** validation SHALL fail for any ordinary content tiddler using one of the six retired tags
- **AND** the diagnostic SHALL identify the file, tiddler title, and retired tag

### Requirement: Topic color has one restrained ownership boundary

Only first-level topic-tag tiddlers SHALL be eligible for prominent semantic `color` fields. Nested topics, document lifecycle, translation state, and provenance SHALL use neutral presentation unless a later reviewed capability changes that boundary. Exact topic colors SHALL require real-page visual and contrast review.

#### Scenario: First-level topic receives a reviewed color

- **WHEN** a later visual change assigns a color to a first-level topic tag
- **THEN** the existing tag-color component MAY render its restrained variant
- **AND** the selected value SHALL pass the reviewed light-theme contrast and interaction checks

#### Scenario: Foundation is implemented before palette review

- **WHEN** taxonomy and navigation are created without an approved topic palette
- **THEN** topic tags SHALL use the neutral existing tag style
- **AND** the implementer SHALL NOT invent final hex colors

### Requirement: Provenance uses stable source keys and revisioned inventory

`as-sources` SHALL contain a TiddlyWiki list of stable source keys whose repository, path, revision, purpose, and reuse constraints are recorded in the documentation source inventory or future source registry. A source key SHALL NOT encode a machine-specific absolute path.

#### Scenario: Article cites local Hazelight documentation

- **WHEN** a document uses Hazelight documentation as a source
- **THEN** its source key SHALL resolve to the pinned local repository revision and upstream URL
- **AND** the article SHALL treat prose as reference-to-rewrite and media as reuse-prohibited until reviewed

#### Scenario: Article cites project source

- **WHEN** a document derives a behavioral claim from plugin code or a project example
- **THEN** its source key SHALL identify the relevant repository boundary and revision
- **AND** the article body or research crosswalk SHALL identify the relevant source area

### Requirement: Integration topics expose packaging semantics

Special-topic landing pages SHALL define `as-integration-kind` as `optional-plugin` or `engine-domain`. Optional-plugin pages SHALL identify their plugin and dependencies; engine-domain pages SHALL identify the Unreal system or module they integrate with.

#### Scenario: GameplayTags and GAS are classified

- **WHEN** taxonomy validation inspects GameplayTags and GAS topic landings
- **THEN** both SHALL be `optional-plugin`
- **AND** GAS SHALL declare its GameplayTags dependency

#### Scenario: Enhanced Input or Networking is classified

- **WHEN** taxonomy validation inspects Enhanced Input or Networking/RPC
- **THEN** each SHALL be `engine-domain`
- **AND** neither SHALL claim to be a separately packaged optional AngelScript plugin
