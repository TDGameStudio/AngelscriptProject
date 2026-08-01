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

### Requirement: Product tags use UE-style registered names

All non-system product tags SHALL be either a registered UE-style PascalCase topic tag, a documented child of one of those topics, or a `Showcase` classification. The registered top-level topic tags SHALL be exactly `Start`, `Language`, `UnrealLanguage`, `TypeObjectReflection`, `UnrealCore`, `CompileModulePreprocessor`, `HotReload`, `EditorIdeDebugging`, `TestingDiagnosticsRelease`, `RuntimeJitVm`, `BindingsUhtExtensions`, `ArchitectureMaintenance`, `TopicsIntegrations`, `ReferenceDifferencesVersion`, and `ShowcaseLab`. Stable topic and reader-navigation keys SHALL remain in `as-topic-key` and `as-nav-key`; definition discovery SHALL use those fields instead of `Docs` or `ReaderNav` root tags. Product tags SHALL NOT use legacy `ASWiki/*`, `Docs/*`, `ReaderNav`, or a compatibility alias. Every referenced product tag SHALL have a same-title tiddler definition with non-empty `caption` and `description`; each hierarchical parent SHALL exist, and tag-definition relationships SHALL remain acyclic. System tiddlers under `$:/ASWiki/**` and content titles under `AS/Docs/**` or `AS/Showcase/**` SHALL remain outside this tag migration.

#### Scenario: A product tag is added or renamed

- **WHEN** a tiddler, filter, generator, or test introduces a non-system product tag
- **THEN** it SHALL be a registered UE-style topic tag, a documented child of one, or a `Showcase` classification
- **AND** it SHALL NOT use `ASWiki/*`, `Docs/*`, `ReaderNav`, or a legacy alias
- **AND** topic/navigation definitions SHALL be discovered through `as-topic-key` / `as-nav-key`
- **AND** a documented same-title definition and every hierarchical parent SHALL exist
- **AND** the resulting tag-definition graph SHALL contain no cycle

#### Scenario: Showcase supplemental classifications are defined

- **WHEN** `Showcase/Detail` or `Showcase/LayoutExperiment` is used
- **THEN** it SHALL have its own documented definition
- **AND** it SHALL NOT be tagged as a `Showcase` stability-tier child
- **AND** Base, Pattern, and Lab SHALL remain the only Showcase stability tiers
