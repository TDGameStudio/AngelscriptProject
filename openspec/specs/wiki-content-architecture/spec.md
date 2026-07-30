# wiki-content-architecture Specification

## Purpose
TBD - created by archiving change docs-wiki-content-foundation. Update Purpose after archive.
## Requirements
### Requirement: Wiki documentation uses an ordered topic architecture

The Wiki SHALL organize Angelscript documentation under the following ordered topic keys: `start`, `language`, `unreal-language`, `type-object-reflection`, `unreal-core`, `compile-module-preprocessor`, `hot-reload`, `editor-ide-debugging`, `testing-diagnostics-release`, `runtime-jit-vm`, `bindings-uht-extensions`, `architecture-maintenance`, `topics-integrations`, `reference-differences-version`, and `showcase-lab`. The order SHALL be stored as content metadata rather than inferred from filesystem enumeration or localized captions.

#### Scenario: Reader opens the documentation directory

- **WHEN** the Wiki renders its top-level documentation directory
- **THEN** the fifteen topics SHALL appear in the specified order
- **AND** localized captions SHALL NOT change their logical keys or order

#### Scenario: Maintainer reorganizes source files

- **WHEN** documentation tiddler files move within the source tree without changing their topic metadata
- **THEN** the rendered topic directory SHALL retain the same order and logical relationships

### Requirement: Topic chapters use a shared progressive-depth vocabulary

Documentation SHALL use `L0`, `L1`, `L2`, `L3`, `L4`, and `L5` to mean orientation, first working path, complete use, boundaries and failures, implementation mechanisms, and source-level maintenance respectively. A topic SHALL expose the depths it actually provides and SHALL NOT create empty articles solely to fill every level.

#### Scenario: Beginner enters a deep technical topic

- **WHEN** a topic includes both introductory and maintainer material
- **THEN** its landing page SHALL present lower depths before implementation and maintenance depths
- **AND** the reader SHALL be able to stop after the practical material without traversing source-level content

#### Scenario: Small subject does not need every depth

- **WHEN** a subject can be explained without a distinct article at one or more intermediate depths
- **THEN** the topic SHALL omit the redundant articles
- **AND** its landing page SHALL still label the depth of each provided article

### Requirement: Unreal AngelScript language features are a first-level topic

The `unreal-language` topic SHALL independently cover the fork/Unreal-facing language surface from use through maintenance. Its content plan SHALL include `UPROPERTY`, `UFUNCTION`, default statements, default components and attachment specifiers, delegate/event declarations, access specifications, mixins, formatted strings, FName literals, RPC specifiers, Unreal containers and wrapper types, editor/cooked conditions, and removed or divergent language behavior.

#### Scenario: Reader looks for a fork-specific language feature

- **WHEN** the reader searches or navigates for `default`, `delegate`, `access`, `mixin`, f-string, or an Unreal declaration specifier
- **THEN** the feature SHALL be discoverable through the `unreal-language` topic
- **AND** its practical and implementation-depth pages SHALL remain distinguishable

#### Scenario: Maintainer traces a language feature implementation

- **WHEN** a language-feature page has parser, preprocessor, generator, binding, or runtime implications
- **THEN** its deeper content SHALL link to the relevant implementation and regression evidence
- **AND** the beginner-facing page SHALL NOT require reading that implementation detail

### Requirement: Selected chapters expose a source-backed implementation-principle track

The documentation SHALL provide a cross-topic “实现原理” track for subjects whose mechanisms are important to advanced users and maintainers. An implementation-principle document SHALL use `as-doc-kind: internals`, SHALL normally use depth `L4` or `L5`, and SHALL remain attached to its owning topic rather than being moved into Showcase.

The initial planned mechanism families SHALL include preprocessing and dependency analysis, parser/AST, compilation and bytecode, VM/context execution, language-feature lowering or generation, object/type lifetime and garbage collection, Unreal reflection and class/struct generation, bindings/UHT/calling conventions/marshalling/fallback, and the complete hot-reload pipeline.

Each reviewed or published internals page SHALL identify the observable behavior and boundary it explains, its pipeline or state model, important data structures, stable source entry points, failure modes, and regression evidence. It SHALL include a minimal trace or experiment when that can be kept deterministic. A diagram or interactive presentation MAY support the explanation but SHALL NOT replace source and test evidence.

#### Scenario: Advanced reader follows a mechanism from behavior to source

- **WHEN** the reader opens an internals page for a language feature, compiler stage, VM behavior, binding path, or hot-reload operation
- **THEN** the page SHALL connect observable behavior to the relevant stages, data structures, source entry points, and tests
- **AND** it SHALL distinguish verified behavior from inference or planned investigation

#### Scenario: Reader browses implementation principles across topics

- **WHEN** the Wiki renders the “实现原理” directory
- **THEN** it SHALL discover documents through `as-doc-kind: internals`
- **AND** each result SHALL retain its owning topic and depth
- **AND** the directory SHALL NOT require a duplicate internals tag hierarchy

#### Scenario: Internals visualization is experimental

- **WHEN** an internals page embeds or links an experimental AST, bytecode, VM, reflection, binding, or reload visualization
- **THEN** the authoritative explanation and evidence SHALL remain usable without the experiment
- **AND** the experiment SHALL be classified under the appropriate Showcase tier

### Requirement: Hot reload and live iteration are a first-level topic

The `hot-reload` topic SHALL cover the daily edit/save workflow and the internal reload pipeline. Its content plan SHALL include file observation and coalescing, preprocessing and dependency analysis, soft/full reload classification, PIE and restart requirements, compilation events, ClassGenerator, ClassReloadHelper, CDO/default-component behavior, instance migration, Blueprint descendants and BlueprintImpact, failure recovery, diagnostics, cleanup, and regression coverage.

#### Scenario: Script author changes a file

- **WHEN** a reader needs to know whether a function-body, property, component, inheritance, interface, or other structural change can reload safely
- **THEN** the hot-reload topic SHALL provide a practical classification and recovery path
- **AND** it SHALL distinguish soft reload, full reload, PIE exit, and editor restart requirements

#### Scenario: Maintainer investigates reload behavior

- **WHEN** a maintainer follows the reload implementation
- **THEN** the hot-reload topic SHALL connect file watching, dependency decisions, compilation, class generation, reinstancing, Blueprint impact, diagnostics, and relevant tests

### Requirement: Core documentation is separate from special topics and integrations

The core topic spine SHALL keep optional plugins and domain-specific integrations under `topics-integrations`. The initial special topics SHALL be GameplayTags, GAS, Enhanced Input, Networking/RPC, UI/UMG, and AI/BehaviorTree. Each landing SHALL classify itself as `optional-plugin` or `engine-domain`.

#### Scenario: Reader browses core AngelScript material

- **WHEN** the reader follows the ordered core path
- **THEN** optional-plugin and domain-specific articles SHALL NOT interrupt the basic language, object, compilation, hot-reload, runtime, binding, or maintenance sequence
- **AND** the special-topic directory SHALL remain directly discoverable

#### Scenario: Reader opens an integration topic

- **WHEN** the reader opens GameplayTags, GAS, Enhanced Input, Networking/RPC, UI/UMG, or AI/BehaviorTree
- **THEN** the page SHALL state whether it is an optional plugin or an engine-domain integration
- **AND** GAS SHALL state its dependency on GameplayTags
- **AND** Networking/RPC SHALL NOT be described as a separately packaged optional plugin

### Requirement: AngelscriptUHTTool has a dedicated core subchapter sequence

The `bindings-uht-extensions` topic SHALL include dedicated Chinese pages for UHT-plugin overview, generation workflow, internals, and maintenance at logical keys `bindings-uht-extensions/uht-plugin-overview`, `bindings-uht-extensions/uht-generation-workflow`, `bindings-uht-extensions/uht-plugin-internals`, and `bindings-uht-extensions/uht-plugin-maintenance`.

The sequence SHALL distinguish the independent C# `AngelscriptUHTTool` UBT/UHT plugin from the Runtime UE module. It SHALL cover configuration, header/metadata inputs, eligibility and policy, generated shards and aggregators, statistics and cleanup, Runtime registration, `NativeRuntimeLinked`, `NativeModuleFunctionAddress`, reflective fallback, marshalling exclusions, RPC fallback, native binding layout versioning, diagnostics, and tests.

#### Scenario: Reader traces an automatically bound function

- **WHEN** a reader follows a supported Unreal function from C++ declaration to script call
- **THEN** the UHT sequence SHALL identify configuration, generator policy, emitted artifact, Runtime registration, and execution/fallback path
- **AND** it SHALL identify where unsupported signatures or RPC functions leave the direct path

#### Scenario: Maintainer changes the native binding payload layout

- **WHEN** a maintainer changes `FAngelscriptNativeModuleFunctionBinding` or its view layout
- **THEN** the maintenance page SHALL require the layout-version file, Runtime bridge, generator emission, and tests to remain synchronized

### Requirement: Hazelight comparison is a revisioned evidence-backed topic

The `reference-differences-version` topic SHALL contain a nested topic tag `ASWiki/Docs/reference-differences-version/hazelight`. Its initial Chinese pages SHALL use logical keys `reference-differences-version/hazelight-comparison-overview`, `reference-differences-version/hazelight-capability-matrix`, `reference-differences-version/hazelight-function-binding`, `reference-differences-version/hazelight-class-generation`, `reference-differences-version/hazelight-struct-generation`, `reference-differences-version/hazelight-architecture-differences`, and `reference-differences-version/hazelight-audit-maintenance`.

Comparison entries SHALL classify the current relationship as `same`, `diverged`, `selective-backport`, `reimplemented`, `removed`, `local-only`, or `future-candidate`. They SHALL record the compared repository/source revisions or configured reference identity and capture date, cite both sides when source evidence exists, distinguish Hazelight public documentation, the dated folder-comparison report, configured engine source, authorized private remote source, and local plugin source, and label inference explicitly. Each row SHALL also record confidence, user-visible consequence, maintenance consequence, and Unreal-version applicability.

The comparison catalog SHALL include language features, AngelScript kernel/fork version, preprocessing/parser/compiler, Runtime/Editor/module architecture, engine-fork versus standalone-plugin constraints, function bindings and calling paths, script class generation, script struct generation, hot reload/reinstancing/Blueprint impact, UHT/code generation, debugging/VS Code protocol, test framework/coverage/diagnostics, examples, optional plugins/domain integrations, removed Haze-specific behavior, and current local-only capabilities. Catalog entries SHALL NOT require empty article tiddlers.

The initial evidence SHALL record Hazelight `f459e6322f63deef8d345f1c1624734cc22747e3`, local plugin `4e2e23ca16ae9f1786258fb96b09b268259b1aad`, and the 2026-03-12 engine folder report as separate evidence objects. The report's thirteen visible changed `Engine/Source` leaf files SHALL be described as non-exhaustive path-level evidence because the compared Git revisions are absent and current private/editor/UHT changes exist outside that visible list. Private Hazelight source SHALL NOT be copied into the public Wiki or plugin-source corpus.

The capability matrix SHALL be backed by a machine-readable catalog whose rows contain a stable ID/family/title, relationship, confidence, Hazelight/local revisions, comparison date, Unreal-version applicability, evidence keys for both sides, user and maintenance consequences, disposition, optional benchmark evidence, and optional detailed-document key. All rendered matrix/detail views SHALL consume this shared record rather than duplicating relationship/baseline data.

#### Scenario: Reader asks whether a Hazelight feature exists locally

- **WHEN** the reader opens a capability-matrix entry
- **THEN** the entry SHALL show one relationship label, both applicable baselines, evidence links, and the current local consequence
- **AND** absence from Hazelight public documentation SHALL NOT be treated as proof of source absence

#### Scenario: Maintainer compares function binding or generated types

- **WHEN** a reader opens the Hazelight function-binding, class-generation, or struct-generation page
- **THEN** the page SHALL compare both implementation pipelines, source ownership, engine dependencies, behavior differences, and regression evidence
- **AND** it SHALL explain the consequence for the standalone plugin rather than presenting only a feature checklist
- **AND** the function-binding page SHALL contrast Hazelight's engine UHT/type-erased function-pointer map with the local C# UHTTool's `NativeRuntimeLinked`, `NativeModuleFunctionAddress`, and reflective fallback paths
- **AND** the class-generation page SHALL describe Hazelight's hybrid engine hooks plus `UASClass`, rather than incorrectly reducing the comparison to `UClass` versus `UASClass`

#### Scenario: Reader opens the historical engine-change inventory

- **WHEN** the reader follows the 2026-03-12 Hazelight engine-change report
- **THEN** the Wiki SHALL show its capture date, compared folder identities, missing Git revisions, thirteen visible engine-source leaf paths, and non-exhaustive status
- **AND** semantic claims SHALL link to a pinned current source observation rather than treating file-size/timestamp differences as behavior proof

#### Scenario: Comparison contains a performance claim

- **WHEN** a comparison claims one class, struct, binding, reload, or dispatch path is faster or equivalent in cost
- **THEN** it SHALL cite a revisioned benchmark artifact and method
- **AND** an estimate from historical prose SHALL be labelled provisional or removed from reviewed content

#### Scenario: Upstream change is not yet adopted locally

- **WHEN** current Hazelight source contains a candidate behavior such as type-level editor-only class/struct propagation that is not verified locally
- **THEN** the comparison SHALL use `future-candidate`, state the evidence and local observation, and avoid presenting it as implementation work
- **AND** any adoption proposal SHALL be created as a separate code OpenSpec

#### Scenario: Hazelight or the local fork advances

- **WHEN** either compared revision changes
- **THEN** the audit-maintenance page SHALL identify affected comparison rows as requiring review
- **AND** it SHALL preserve the previous comparison as history rather than silently rewriting its baseline

### Requirement: Topic landing pages and placeholders are informative

Every topic landing SHALL state its purpose, available depths, current content state, and primary navigation. A placeholder document SHALL include a reader outcome, planned outline, known sources, relevant source areas, dependencies, related pages, and an explicit unreviewed-content notice.

#### Scenario: Planned module documentation is not written yet

- **WHEN** a topic or module page exists only as a placeholder
- **THEN** the directory SHALL identify it as planned
- **AND** the page SHALL expose its intended scope and evidence
- **AND** it SHALL NOT present unverified claims as reviewed documentation

#### Scenario: Documentation completeness is reported

- **WHEN** the Wiki or a maintainer calculates completed documentation
- **THEN** placeholder pages SHALL NOT count as reviewed or published content

### Requirement: Existing Wiki entry points remain migration-compatible

The content-architecture rollout SHALL retain existing canonical Wiki entry points until locale-aware links and compatibility routing are present. Existing workflow, maintainer, status, theme, and showcase pages SHALL be mapped before any rename or deletion.

#### Scenario: Reader follows an existing Wiki link during migration

- **WHEN** a stored link targets a pre-foundation tiddler title
- **THEN** the reader SHALL still reach the existing content or an explicit compatibility entry
- **AND** the migration SHALL NOT silently create a missing tiddler

#### Scenario: Maintainer proposes deleting a migrated source page

- **WHEN** a later content change replaces an existing Wiki or host knowledge page
- **THEN** that change SHALL record coverage, link migration, and retention/deprecation evidence before removal
