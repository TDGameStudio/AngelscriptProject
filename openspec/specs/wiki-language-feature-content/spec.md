# wiki-language-feature-content Specification

## Purpose
TBD - created by archiving change docs-wiki-content-expansion. Update Purpose after archive.
## Requirements
### Requirement: Ordinary AngelScript fundamentals are directly discoverable

The primary reader path SHALL expose concrete Chinese documents for `language/basic-types-variables`, `language/functions-control-flow`, `language/classes-inheritance-interfaces`, `language/handles-references-casts`, `language/containers-enums`, and `language/syntax-reference`. These pages SHALL distinguish ordinary AngelScript behavior from Unreal-specific extensions and SHALL link to deeper parser/compiler/runtime material where applicable.

#### Scenario: Beginner looks for a basic language concept

- **WHEN** a reader looks for variables, functions, control flow, classes, interfaces, handles, references, casts, containers, or enums
- **THEN** the concept SHALL be directly visible in the `language-basics` reader group
- **AND** the reader SHALL NOT need to infer it from a single abstract language landing

#### Scenario: Core syntax detail becomes implementation-heavy

- **WHEN** the syntax reference discusses tokens, AST nodes, parser productions, or fork internals
- **THEN** the practical fundamentals pages SHALL link to that draft/reference material
- **AND** beginner guidance SHALL not require reading the internals first

### Requirement: Unreal-specific syntax families have concrete feature pages

The `script-features` reader group SHALL expose concrete documents with stable feature identities for `access-specifiers`, `default-component`, `default-statement`, `delegate-event`, `f-instanced-struct`, `formatted-strings`, `fname-literals`, `mixin`, `property-accessor`, `tarray`, `tmap`, `toptional`, `tset`, `tsoftobjectptr`, `tsubclassof`, `tweakobjectptr`, `ufunction`, and `uproperty`.

#### Scenario: Reader looks for a specific Unreal script feature

- **WHEN** a reader looks for any required feature by its common name or syntax spelling
- **THEN** the documentation directory and search SHALL provide a direct document destination
- **AND** the destination SHALL state its lifecycle rather than hiding the feature inside a planning bullet list

#### Scenario: Feature implementation has deeper evidence

- **WHEN** a feature has preprocessor, ClassGenerator, binding, reflection, runtime, or test implications
- **THEN** its document SHALL identify or link to the relevant deeper topic
- **AND** a reviewed claim SHALL cite current local evidence rather than only Hazelight behavior

### Requirement: High-frequency Unreal workflows have direct practical pages

The primary reader path SHALL include direct pages for first Actor/Blueprint use, Actors/Components/defaults, Function Libraries, editor-only/cooked script, Subsystems, Script Tests, and Unreal C++/Blueprint differences. Existing Networking/RPC and GameplayTags pages SHALL participate in the same capability path without changing their integration packaging semantics.

#### Scenario: Reader follows the initial working path

- **WHEN** the reader begins at Getting Started
- **THEN** the path SHALL lead through project preparation, first Actor, editor availability, properties/functions, components/defaults, Blueprint interaction, save/reload verification, and further feature links
- **AND** current-fork setup details SHALL replace Hazelight custom-engine assumptions

#### Scenario: Reader follows an integration link

- **WHEN** the reader opens Networking/RPC, GameplayTags, GAS, or another existing integration landing through the primary path
- **THEN** the existing optional-plugin or engine-domain classification SHALL remain visible and correct

### Requirement: C++ Usage and Bindings is a concrete reader path

The `bindings-extensions` reader group SHALL directly expose concrete Chinese documents for automatic reflection binding, script exposure metadata, C++ function libraries / `ScriptMixin`, manual `Bind_*.cpp`, binding call paths and limits, and binding diagnostics. The path SHALL preserve the existing UHT generation and internals documents but SHALL not require a C++ API user to begin with UHT implementation internals.

#### Scenario: C++ engineer chooses an exposure mechanism

- **WHEN** a C++ engineer wants to expose a class, struct, enum, property, function, helper method, operator, constructor, or non-reflected type to AngelScript
- **THEN** the primary two-level navigation SHALL provide a direct task-oriented document
- **AND** the guidance SHALL distinguish automatic reflection, script metadata, `ScriptMixin`, manual Bind, and UHT-generated paths

#### Scenario: Visible function is not eligible for a native generated call

- **WHEN** a function is callable from script but uses RPC routing, unsupported marshalling, source-engine-only features, or another generator exclusion
- **THEN** the documentation SHALL distinguish visibility from call backend
- **AND** it SHALL preserve the required reflective fallback and local safety boundary

#### Scenario: Binding is missing or takes an unexpected path

- **WHEN** a reader diagnoses a missing type/function, stale completion, skipped UHT record, duplicate registration, order problem, or fallback decision
- **THEN** the documentation SHALL lead to current completion/CodeGen, `as.DumpEngineState`, generated statistics/diagnostics, source entry points, and regression-test evidence

### Requirement: Project-owned knowledge migration is complete and non-destructive

The Wiki SHALL maintain a machine-readable migration ledger with exactly one record for each current `Documents/Knowledges/ZH/*.md` source. Each record SHALL use one action from `materialize`, `merge`, `retain`, or `defer`, SHALL identify one or more logical destination keys, and SHALL explain the decision. The migration SHALL NOT delete or edit the source article.

#### Scenario: Knowledge source inventory changes

- **WHEN** a source article is added, removed, duplicated, or renamed without updating the migration ledger
- **THEN** validation SHALL fail with the unmatched source or ledger record

#### Scenario: Source remains outside the boot artifact

- **WHEN** a record uses `merge`, `retain`, or `defer`
- **THEN** the source body SHALL not be copied into the Wiki solely to satisfy the inventory count
- **AND** its destination and reason SHALL remain inspectable in the ledger

### Requirement: Materialized knowledge drafts are deterministic and honest

The initial materialized set SHALL include every current `Syntax_*.md` and `AS_*.md` source. A generated Wiki draft SHALL record its source-relative path and SHA-256, use a formal logical document key, preserve the project-owned Chinese Markdown body, and display a notice that migration does not equal current-fork review.

Generation SHALL be an explicit offline maintainer command. It SHALL write only generator-owned files, SHALL not access the network, SHALL not run during ordinary `dev`, `test`, `verify`, or `build:wiki`, and SHALL fail rather than read outside the permitted host knowledge root.

#### Scenario: Maintainer materializes current knowledge

- **WHEN** the explicit generator runs against a valid ledger
- **THEN** all `Syntax_*` and `AS_*` materialized pages SHALL be regenerated deterministically
- **AND** source/hash metadata SHALL match their normalized bodies
- **AND** unrelated hand-authored Wiki files SHALL remain untouched

#### Scenario: Source changes after generation

- **WHEN** a materialized source body no longer matches the stored generated hash/body
- **THEN** document-content validation SHALL report the stale destination and source path
- **AND** normal validation SHALL not silently regenerate or conceal the drift

### Requirement: Hazelight public Script Features have a local crosswalk

The Wiki SHALL record a public-document crosswalk for Hazelight's fifteen Script Features: Functions and BlueprintEvents, Properties and Accessors, Actors and Components, Function Libraries, FName Literals, Formatted Strings, Structs and References, Networking Features, Delegates and Events, Mixin Methods, Gameplay Tags, Editor-Only Script, Subsystems, Script Tests, and Differences with Unreal C++. Each entry SHALL map to at least one existing local logical document key and preserve the public URL as reference metadata.

#### Scenario: Upstream feature is useful as a navigation reference

- **WHEN** validation inspects the public Hazelight crosswalk
- **THEN** all fifteen entries SHALL be present exactly once
- **AND** every local destination SHALL resolve to a formal document
- **AND** no upstream prose or media SHALL be required in the offline artifact

#### Scenario: Local behavior differs from the public article

- **WHEN** a reviewed local page describes a fork-specific difference
- **THEN** it SHALL cite current local evidence and state applicability
- **AND** the public page SHALL not be treated as the authoritative local behavior contract

### Requirement: Reviewed content has a minimum useful shape

A reviewed or published practical Chinese document added or upgraded by this change SHALL state reader outcome and prerequisites, contain at least one current example or deterministic procedure when applicable, explain important rules and boundaries, identify current-fork applicability, cite stable local sources or tests, and link to related practical and deeper pages. A mechanically materialized page SHALL remain `draft` until this review shape is met.

#### Scenario: Draft contains a large amount of prose

- **WHEN** a generated knowledge page has substantial content but has not received current-fork review
- **THEN** its lifecycle SHALL remain `draft`
- **AND** body length alone SHALL not permit `reviewed` or `published`

#### Scenario: Initial reviewed path is validated

- **WHEN** this change reports its initial content tranche complete
- **THEN** the Getting Started landing, basic types/variables, functions/control flow, and first Actor/Blueprint path SHALL be reviewed Chinese documents with positive revisions
- **AND** their examples and links SHALL pass source and browser verification

### Requirement: Content completion uses truthful accounting and a bounded artifact

The Wiki SHALL report placeholder, draft, reviewed, and published counts separately. Content expansion SHALL not count catalog rows, migration-ledger decisions, or mechanically generated drafts as reviewed content. The built offline artifact SHALL remain within the existing 5.8 MB budget and SHALL not include the raw plugin source corpus or non-materialized host knowledge bodies.

#### Scenario: Maintainer checks completion

- **WHEN** the content contract reports documentation state
- **THEN** it SHALL show separate counts for all four lifecycle states
- **AND** only reviewed and published pages SHALL contribute to completed documentation

#### Scenario: Materialized drafts exceed the budget

- **WHEN** the offline build exceeds 5.8 MB after deterministic materialization
- **THEN** the change SHALL reduce the materialized set or body packaging without deleting source mappings
- **AND** it SHALL not raise the budget without separate reviewed evidence
