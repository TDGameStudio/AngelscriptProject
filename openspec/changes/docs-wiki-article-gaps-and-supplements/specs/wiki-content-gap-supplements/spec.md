## ADDED Requirements

### Requirement: Content-gap deficiency summary is quantified and traceable

The change SHALL record a deficiency summary of the formal Simplified-Chinese wiki documents that is quantified and traceable rather than a status count alone. The summary SHALL categorize deficiencies across completeness, runnable examples, presentation expressiveness, structure/navigation, internals evidence chain, English-parity (i18n), and cross-references. Each category SHALL cite concrete evidence (counts and example `as-doc-key`s), roll up findings per navigation group, and list a coverage-gap inventory of missing or landing-only pages.

#### Scenario: A maintainer reviews the deficiency summary

- **WHEN** a maintainer opens `deficiency-summary.md`
- **THEN** each deficiency category SHALL cite concrete counts and example `as-doc-key`s
- **AND** findings SHALL be rolled up per navigation group
- **AND** a coverage-gap inventory of missing or landing-only pages SHALL be listed
- **AND** the summary SHALL state its relationship to the existing content-and-expression umbrella change rather than duplicating its status board as the source of truth

### Requirement: Candidate supplement drafts are staged as OpenSpec attachments until adopted

The change SHALL stage exactly 200 candidate supplement articles as TiddlyWiki `.tid` drafts under the change's `supplements/` directory and SHALL NOT write them into the `Wiki/` submodule. The 200 drafts SHALL include the eleven named anchor documents and SHALL cover every one of the fifteen registered documentation topics according to the quota recorded in `design.md`. Every staged draft SHALL carry `as-content-status: draft` and SHALL NOT claim `reviewed` or `published`. Adoption into `Wiki/wiki/tiddlers/docs/zh-Hans/**` SHALL be a subsequent, separate submodule commit performed under the host/submodule workflow, not part of this change.

#### Scenario: A supplement draft is produced

- **WHEN** a supplement article is produced by this change
- **THEN** it SHALL be written as a `.tid` file under `supplements/<topic>/<slug>.tid`
- **AND** it SHALL declare `as-content-status: draft`
- **AND** no file under the `Wiki/` submodule SHALL be created or modified by this change

#### Scenario: The supplement set is declared complete
- **WHEN** a maintainer audits the completed attachment set
- **THEN** exactly 200 unique supplement `.tid` files SHALL be present
- **AND** the per-topic counts SHALL match the quota recorded in `design.md`
- **AND** all eleven anchor `as-doc-key` values SHALL be present

#### Scenario: A maintainer decides to adopt a draft

- **WHEN** a maintainer adopts a staged draft
- **THEN** the adoption SHALL be a separate `Wiki/` submodule commit following the host/submodule workflow
- **AND** the adoption SHALL register the draft's navigation entry (`as-nav-group`, `as-nav-order`, and `as-nav-parent` for sub-pages) so it appears exactly once in the two-level primary navigation

### Requirement: Supplement drafts are source-verifiable and contract-compliant

Each staged draft SHALL conform to the current wiki documentation content contract: required frontmatter fields, exactly one registered UE-style PascalCase topic Tag, membership in exactly one of the seven navigation groups, and `as-sources` drawn only from keys registered by the source registry. Legacy `ASWiki/*`, `Docs/*`, and `ReaderNav` product Tag roots SHALL NOT appear. Draft bodies SHALL state only APIs, type names, signatures, and behaviors verified against the cited grounding files. Any unverified claim SHALL be marked with an `as-callout` note requesting source verification, and fabricated example scripts or signatures SHALL NOT be introduced.

The `as-depth` field SHALL also be a body-depth contract rather than descriptive metadata. L0/L1 drafts SHALL contain a complete reader route or source-grounded workflow; L2 drafts SHALL add a concept or lifecycle model, constraints, failure diagnosis, and concrete evidence entry points; L3 drafts SHALL add ownership and cross-environment state flow; L4 drafts SHALL include symbol-level pipelines, key structures, invariants, failure behavior, and old/new state relationships; L5 drafts SHALL additionally provide a maintenance map, compatibility/impact analysis, cleanup ordering, and layered evidence. Article count, frontmatter validity, and file size SHALL NOT by themselves satisfy this requirement.

#### Scenario: A draft cites plugin or example source

- **WHEN** a draft describes a plugin binding, engine domain, or example behavior
- **THEN** its statements SHALL be verifiable against the grounding files it cites
- **AND** every unverified claim SHALL be marked with an `as-callout` note requesting source verification
- **AND** `as-sources` SHALL contain only registered source keys

#### Scenario: A draft claims a documentation depth

- **WHEN** a supplement declares an `as-depth` from L0 through L5
- **THEN** its body SHALL satisfy the corresponding depth contract recorded above and in `design.md`
- **AND** an outline, link collection, or policy summary without the required workflow, model, trace, failure behavior, and evidence SHALL NOT be accepted merely because its frontmatter and source keys are valid
- **AND** file length MAY identify candidates for review but SHALL NOT replace semantic review

#### Scenario: A draft rewrites an existing placeholder

- **WHEN** a draft supersedes an existing placeholder or draft document
- **THEN** it SHALL preserve that document's stable identity, ordering, navigation, integration, and feature fields
- **AND** it SHALL change `as-content-status` to `draft` and increment `as-content-revision`
- **AND** it MAY add registered `as-sources` keys required to ground the new body

#### Scenario: A draft uses the current topic taxonomy
- **WHEN** a supplement declares its topic ownership
- **THEN** its `tags` field SHALL name exactly one current PascalCase topic Tag defined under `Wiki/wiki/tiddlers/docs/taxonomy/`
- **AND** the draft SHALL NOT contain an `ASWiki/`, `Docs/`, or `ReaderNav` product Tag root

### Requirement: Supplement adoption catalog is complete
The change SHALL provide `supplements/README.md` as a bidirectional adoption catalog. Every supplement row SHALL record the `as-doc-key`, topic, lifecycle (`new` or `rewrite`), navigation placement, registered source keys, and concrete grounding paths. Every declared grounding path SHALL exist in the current parent repository. The completed catalog SHALL contain no missing rows, orphan rows, duplicate document identities, invalid current-contract fields, unregistered source keys, legacy product Tags, rewrite frontmatter drift, invalid topic quotas, or a total other than 200.

#### Scenario: A maintainer audits the attachment catalog
- **WHEN** a maintainer opens `supplements/README.md`
- **THEN** every staged `.tid` file SHALL have exactly one catalog row
- **AND** every catalog row SHALL identify existing grounding paths and adoption navigation metadata
- **AND** the README SHALL clearly state that all rows are draft attachments and have not been migrated


### Requirement: Integration evidence boundaries are presented honestly

An engine-domain integration that has no dedicated plugin SHALL be presented as an evidence-boundary page rather than as a fabricated optional plugin. When a repository example exists, the page SHALL cite that example and limit its workflow claims to the demonstrated and source-verified surface. When no example fixture exists, the page SHALL state that absence and rely only on plugin/source/validation evidence. Every boundary page SHALL declare packaging semantics and SHALL NOT present invented scripts or APIs as working.

#### Scenario: An engine-domain topic has examples but no dedicated plugin

- **WHEN** a topic such as UI/UMG, networking/RPC, or AI/behavior-tree has a repository example but no dedicated integration plugin
- **THEN** its draft SHALL cite the real example and state the absence of a dedicated plugin
- **AND** it SHALL declare packaging semantics and how the reader can verify further
- **AND** it SHALL NOT present invented example scripts or APIs as working

#### Scenario: An optional-plugin topic has no script example

- **WHEN** a topic has plugin/source or validation evidence but no current script example fixture
- **THEN** its draft SHALL state that example gap instead of implying an example exists
- **AND** it SHALL limit claims to the cited plugin/source or validation evidence
