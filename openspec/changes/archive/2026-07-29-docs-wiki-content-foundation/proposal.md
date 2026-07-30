## Why

AngelscriptWiki already has a mature browser shell, code presentation, bilingual UI primitives, and a small set of workflow pages, but it does not yet have a durable content architecture for the full Unreal AngelScript knowledge surface. The current Wiki has only a shallow reader/maintainer outline and five syntax-showcase entry pages, while the host repository already contains 73 Chinese knowledge articles, 36 AngelScript examples, the complete local Hazelight documentation source, and substantial plugin-specific implementation knowledge that needs to be reviewed and migrated without mixing beginner guidance, core language behavior, optional integrations, and maintainer internals.

This change records the documentation foundation before bulk authoring starts: Chinese-first paired documents, topic chapters that progress from introductory use to source-level maintenance, explicit separation of core material from domain integrations, stable placeholder semantics, and a much broader Base/Pattern/Lab showcase system.

## What Changes

- Establish a 15-topic Wiki information architecture with a shared `L0` through `L5` depth model inside each topic.
- Define an explicit cross-topic “实现原理” track for source-backed internals pages covering the parser/compiler/bytecode/VM path, language-feature lowering, object and reflection models, bindings/UHT, and hot reload.
- Give Unreal AngelScript language features and hot reload/live iteration independent first-level topics with complete beginner-to-maintainer coverage expectations.
- Give `AngelscriptUHTTool` an explicit subchapter sequence covering configuration, generation artifacts, C# implementation, native binding layout contracts, failures, and tests.
- Give Hazelight comparison an explicit evidence-matrix sequence covering public documentation, current private source, the dated engine-file report, fork/version/capability/architecture differences, selective backports, removals, rewrites, and audit maintenance. Seed detailed function-binding, UHT, class-generation, struct-generation, and engine-patch findings without proposing code adoption.
- Separate core documentation from optional-plugin and engine-domain topics such as GameplayTags, GAS, Enhanced Input, Networking/RPC, UI/UMG, and AI/BehaviorTree.
- Define paired `zh-Hans` / `en-GB` document metadata and lifecycle: Chinese is authored and reviewed first; English is created afterward, tracks the Chinese content revision, and can become stale.
- Define a native TiddlyWiki topic-tag hierarchy while keeping locale, depth, document kind, lifecycle, ordering, provenance, and translation state in fields rather than proliferating tags.
- Retire the legacy `ASWiki/Home`, `ASWiki/Workflow`, `ASWiki/Maintainer`, `ASWiki/Status`, `ASWiki/Theme`, and `ASWiki/Navigation` classification tags. Home remains an entry route, while reader content moves to the new topic/Showcase roots and non-content roles move to fields.
- Define non-empty placeholder pages that expose planned outcomes, outline, evidence sources, dependencies, and unverified status.
- Define a future source-reference corpus that keeps a commit-pinned copy of the published AngelScript plugin source outside the initial Wiki runtime, updates it only through an explicit GitHub synchronization workflow, and gives documents stable source-reference keys.
- Expand the documentation showcase contract from the current small set to a 42-entry catalog: 15 Base surfaces, 16 reusable documentation Patterns, and 11 experimental Lab surfaces. The added cases explicitly cover TiddlyWiki procedures/functions/legacy macros, trusted WikiText HTML, local/external page embedding, reusable native components, static embed fallbacks, and embed-security experiments.
- Record local/remote source provenance, current Wiki behavior, a complete source-to-topic crosswalk, showcase gaps, and overlaps with existing Wiki OpenSpecs.
- Produce a ready-to-execute implementation plan and clean task checklist, then stop without changing Wiki product source or migrating article bodies.

## Capabilities

### New Capabilities

- `wiki-content-architecture`: Defines topic chapters, progressive depth, core-versus-special-topic boundaries, landing pages, placeholders, ordering, and migration-safe navigation.
- `wiki-bilingual-document-lifecycle`: Defines paired Chinese/English document identity, Chinese-first review, locale resolution, fallback, translation revision tracking, and stale translation behavior.
- `wiki-document-taxonomy`: Defines the TiddlyWiki tag hierarchy and the stable document metadata fields used for navigation, filtering, provenance, lifecycle, and validation.
- `wiki-showcase-system`: Defines Base, Pattern, and Lab showcase tiers, their minimum catalogs, stability promises, discoverability, and verification levels.
- `wiki-source-reference-corpus`: Defines the pinned plugin-source mirror, explicit GitHub update workflow, license/provenance boundary, stable source references, excerpt generation, and stale-reference validation used by implementation-principle pages.

### Modified Capabilities

None. Existing Wiki theme, document-experience, publishing, and in-progress multilingual-toolchain requirements remain owned by their current changes. This change records the reconciliation required between the in-progress UI-language fallback and the Chinese-first article fallback without rewriting another active change.

## Impact

- Parent repository: adds this OpenSpec record and research material under `openspec/changes/docs-wiki-content-foundation/`.
- Future Wiki implementation: will affect content tiddlers, topic/tag tiddlers, locale-aware navigation procedures, content-contract tests, source-corpus scripts/data, and Playwright coverage under the `Wiki/` submodule.
- Source material: inventories `Reference/Docs-UnrealEngine-Angelscript`, `Documents/Knowledges/ZH`, `Documents/Guides`, `Documents/Hazelight`, `Script/`, pinned Hazelight/private and local plugin source observations, plugin module layouts, and existing Wiki/OpenSpec content without modifying those sources.
- Compatibility: existing canonical Wiki titles remain reachable until a later migration implements locale-aware links and compatibility aliases; this record does not rename or delete current tiddlers.
- Licensing: Hazelight documentation text is treated as reference material to be rewritten and attributed; media is not imported without a separate provenance and license review.
- Hazelight source boundary: the private Hazelight engine/plugin source is comparison evidence only and SHALL NOT be copied into the public Wiki or its plugin-source corpus by this change.
- Source mirror: the current published plugin remote is `https://github.com/TDGameStudio/UnrealAngelscriptPlugin`; the local plugin worktree is dirty and SHALL NOT be copied as a synchronization source. The captured committed revision and license boundaries are recorded in `research/source-mirror-design.md`.
- Current session: no Wiki source, Unreal plugin source, generated output, deployment, commit, push, or archive action is included.
