## Context

The archived `docs-wiki-content-foundation` change deliberately completed only the first content-batch milestone: taxonomy, Chinese placeholder landings, locale/lifecycle fields, logical links, source evidence, and catalog contracts. Its proposal says the foundation precedes bulk authoring, and its tests currently require the fifteen L0 landings to remain placeholders. Consequently:

- `AS/Docs` lists only the fifteen first-level topic tags and links each one to its `index` page;
- it never enumerates concrete formal documents;
- all forty-two formal Chinese documents are `placeholder` revision `0`;
- the Unreal feature catalog is a short handwritten planning list;
- `Documents/Knowledges/ZH` contains seventy-three source articles (about 2.3 million characters), including seventeen `Syntax_*` feature articles, but none is represented as a concrete reader-navigation node;
- the forty-two-entry Showcase is a separate authoring capability and remains intact.

Hazelight's public site is useful as an information-architecture reference: it exposes a shallow Getting Started path, fifteen direct Script Features entries, three C++ binding entries, and development/reference entries. Its introduction is a runnable Actor-to-Blueprint path and its feature pages lead with code and task-oriented rules. The local Wiki cannot copy that structure or prose verbatim because the current repository is a UE 5.7 standalone-plugin fork with different installation, subsystem, binding, optional-plugin, debugging, test, and maintenance boundaries.

The implementation runs in the current main checkout as required by repository guidance. The parent repository and Wiki submodule contain unrelated dirty work; this change touches only its OpenSpec directory and scoped Wiki files, performs no broad cleanup, and does not commit or push unrelated state.

## Goals / Non-Goals

**Goals:**

- Preserve the fifteen-topic ownership taxonomy and L0-L5 progressive-depth vocabulary.
- Make concrete reader capabilities directly discoverable without requiring readers to infer them from abstract topic landings.
- Provide a primary task/capability directory and a secondary topic/depth directory from the same formal-document records.
- Materialize the existing seventeen `Syntax_*` and twelve `AS_*` knowledge sources as rich draft Wiki pages with deterministic source hashes.
- Add concise Chinese-first practical pages for missing high-frequency reader concepts.
- Fill the `bindings-extensions` reader group with concrete C++ Usage and Bindings pages instead of exposing only UHT maintainer internals.
- Give every one of the seventy-three knowledge sources an explicit migration action and destination.
- Upgrade an initial high-value path to reviewed content only where current-fork examples, source, and tests support the claims.
- Preserve offline single-file behavior, current theme, current logical keys, source-corpus isolation, and the existing artifact-size budget.

**Non-Goals:**

- Delete or rename the existing forty-two foundation documents.
- Delete, truncate, or rewrite the host `Documents/Knowledges/ZH` corpus.
- Copy Hazelight prose, images, branding, or navigation implementation.
- Translate unreviewed Chinese material to English.
- Turn all seventy-three host articles into boot-time Wiki bodies in this tranche.
- Redesign the accepted Wiki palette, typography, page chrome, sidebar, or tiddler card.
- Claim that mechanically migrated draft content has received current-fork technical review.
- Change plugin runtime behavior, Unreal bindings, examples, tests, or source-corpus network policy.

## Decisions

### 1. Use two navigation axes instead of replacing the existing taxonomy

The primary directory answers “what do I want to learn or do?” and uses seven ordered reader groups:

1. `getting-started`
2. `language-basics`
3. `script-features`
4. `unreal-development`
5. `bindings-extensions`
6. `workflow-validation`
7. `internals-reference`

The secondary directory answers “where is this knowledge owned?” and retains the exact fifteen topic keys and L0-L5 depths from `wiki-content-architecture`.

Alternative considered: replace the fifteen topics with Hazelight's four sidebar groups. Rejected because it would discard local internals, maintenance, fork, lifecycle, translation, source, and Showcase architecture.

Alternative considered: render only a recursively expanded fifteen-topic tree. Rejected as the sole reader path because it exposes implementation ownership before common tasks and repeats the discoverability problem at a deeper level.

### 2. Keep reader navigation orthogonal to topic tags

Reader-visible formal documents may define:

```text
as-nav-group: <one of seven keys>
as-nav-order: <positive integer within the group>
as-nav-parent: <optional logical document key>
as-feature-key: <optional stable capability identity>
```

Topic ownership remains in `ASWiki/Docs/<topic-key>` tags. Locale, depth, kind, lifecycle, provenance, and translation remain in their existing fields. Reader groups are represented by neutral navigation-data tiddlers tagged `ASWiki/ReaderNav`, not by a second documentation topic hierarchy.

`as-feature-key` is stable across locale and page-title changes. It is required for concrete language/Unreal capability pages and unique within the formal document set.

Alternative considered: maintain a second JSON catalog containing every page title and order. Rejected because it duplicates document identity and lifecycle state. A small external mapping is retained only for source migration and Hazelight crosswalk evidence, not runtime navigation.

### 3. Render a two-level, direct-to-tiddler documentation navigation inside the accepted Wiki theme

`AS/Docs` and the left `AS/Navigation` documentation surface use exactly two reader-visible levels:

```text
AngelScript 文档目录
├── 当前完成度 summary (reviewed/published vs draft/planned)
├── seven reader groups
│   └── direct links to formal `.tid` documents with title, description, depth, and text status
└── 按知识体系
    └── fifteen topic details with their actual documents
```

Every current Chinese formal document is assigned to one reader group, so the primary directory is the complete day-to-day navigation rather than a curated subset. Group-to-document is the only hierarchy: `as-nav-parent` may preserve a reading relationship but SHALL NOT create a third visible nesting level or an intermediate redirect. Each second-level link targets the concrete tiddler directly.

The visual signature is a compact left “route rail” on each group, encoding the reading sequence with a restrained existing blue accent. It is structural rather than decorative: the line and ordered markers show the route order. Existing theme tokens and TiddlyWiki palette colors are reused; no new font or global color system is introduced.

The implementation uses semantic headings, lists, links, and native `<details>/<summary>` for progressive disclosure. Status always has Chinese text (`规划中`, `草稿`, `已审阅`, `已发布`) and never relies on color alone. Links retain visible keyboard focus. At 375 px, the directory collapses to one column with no horizontal scrolling. Motion is limited to existing/native state transitions and respects reduced-motion behavior.

The generic UI design-system recommendation for oversized marketing typography is intentionally rejected because this is a dense technical reference inside an established document product.

### 4. Generate the Unreal feature catalog from document metadata

`unreal-language/feature-catalog` stops maintaining a handwritten feature list. It queries formal documents with the `unreal-language` topic and `as-feature-key`, sorts by `as-nav-order`, and displays caption, description, depth, and lifecycle status. The page keeps its logical key and becomes a reviewed navigation/reference page once the required feature entries exist and its rendering is verified.

### 5. Materialize the highest-value local source corpus without exceeding the boot budget

The first materialized migration set consists of:

- seventeen `Documents/Knowledges/ZH/Syntax_*.md` articles;
- twelve `Documents/Knowledges/ZH/AS_*.md` articles.

These become committed `.tid` pages with `type: text/markdown`, formal metadata, reader-navigation metadata, `as-migration-source`, and `as-migration-sha256`. Their bodies retain the project-owned Chinese Markdown, prefixed with a visible migration notice. They use `as-content-status: draft`: presence and richness do not imply current-fork review.

A deterministic generator consumes `Wiki/content-migration.json`, validates paths under `Documents/Knowledges/ZH`, normalizes newlines, computes SHA-256, and replaces only generator-owned files under `Wiki/wiki/tiddlers/docs/zh-Hans/generated-knowledge/`. It never deletes hand-authored pages, never accesses the network, and never runs implicitly during ordinary Wiki development or build.

The document-content contract verifies that generated bodies and hashes match their source records. This keeps the host corpus and Wiki snapshot synchronized without deleting the original material.

Alternative considered: copy all seventy-three articles into the boot payload. Rejected for this tranche because it would exceed the current evidence-backed artifact budget and mix user guidance with internal notes before navigation and review decisions are made.

### 6. Add practical, hand-authored reader pages for gaps that raw source articles do not solve

The implementation adds concise Chinese pages for:

- basic types and variables;
- functions and control flow;
- classes, inheritance, interfaces, and override;
- handles, references, casts, and object-reference semantics;
- containers and enums at the language level;
- first Actor and Blueprint path;
- Actors, Components, and defaults;
- FName literals;
- Function Libraries;
- Editor-only/cooked script;
- Subsystems;
- Script tests;
- Unreal C++/Blueprint differences.
- automatic C++ reflection bindings and script exposure metadata;
- C++ function libraries / `ScriptMixin`, manual `Bind_*.cpp`, call paths, limits, and diagnostics.

Each hand-authored page uses current project examples and evidence, contains copyable AngelScript code where appropriate, and links to deeper migrated drafts instead of reproducing their internals. A page becomes `reviewed` only if its behavior and commands are checked against current source/examples/tests during this change; otherwise it remains `draft`.

The C++ binding path follows the public Hazelight information architecture only at the task-name level. Local behavior is derived from `Bind_BlueprintType.cpp`, `Helper_PropertyBind.h`, `AngelscriptBinds.*`, function-library headers, `BlueprintCallableReflectiveFallback.*`, the UHTTool policy/emitters, and current tests. It must explicitly distinguish “visible to script” from “eligible for a native generated call”: RPC/Net UFunctions and unsupported marshalling remain on their required fallback routes.

### 7. Treat Hazelight as a public crosswalk, not local truth

`Wiki/hazelight-public-doc-crosswalk.json` records the fifteen public Script Features names/URLs and their local logical destination keys. Every upstream feature must map to an existing local document; several upstream entries may map to a local landing plus more specific pages.

Local pages may describe:

- behavior verified to be the same;
- local divergence or extension;
- current version/plugin applicability;
- current local evidence.

The crosswalk does not copy upstream prose or media, does not enter the restricted Hazelight source registry, and does not replace the revisioned Hazelight comparison catalog.

### 8. Account for every host knowledge source before declaring migration complete

`Wiki/content-migration.json` has one record per current `Documents/Knowledges/ZH/*.md` file with:

```json
{
  "source": "Syntax_UPROPERTY.md",
  "action": "materialize | merge | retain | defer",
  "destinationKeys": ["unreal-language/uproperty"],
  "reason": "...",
  "materialize": { "...generator metadata..." }
}
```

Validation fails for missing, duplicate, or unknown source files and for a materialized destination that is absent. `merge` identifies the reviewed/draft destination that absorbs useful content; `retain` records why the host document remains maintainer-only; `defer` records the future topic and reason. No action deletes a source file.

### 9. Use TDD at behavior boundaries

The implementation proceeds through red-green cycles:

1. source-contract tests for navigation fields, exact groups, feature identities, knowledge ledger, materialized pages, and Hazelight crosswalk;
2. runtime/browser tests for the primary and secondary directory, direct feature discovery, text lifecycle status, keyboard focus, mobile containment, and link targets;
3. implementation of the minimum fields, generator, tiddlers, procedures, and styles needed to pass each boundary.

Content prose itself is reviewed through source/evidence checklists and browser rendering rather than unit-testing sentences.

## Risks / Trade-offs

- [Generated draft pages make the Wiki look more complete than it is] → Render `草稿` in every directory entry and in the page notice; exclude draft and placeholder pages from completed counts.
- [Copied Markdown drifts from host knowledge] → Store source path/hash and fail the document contract on drift.
- [Large Markdown bodies breach the single-file budget] → Materialize only the twenty-nine high-value Syntax/AS sources, measure the artifact, and leave the remaining sources mapped but non-materialized.
- [Hazelight behavior is mistaken for local behavior] → Treat the public site only as navigation/crosswalk input; require local evidence for reviewed claims.
- [Two navigation axes confuse readers] → Make the task/capability path primary and the topic/depth view explicitly secondary under progressive disclosure.
- [Navigation metadata duplicates topic ownership] → Keep `as-nav-*` strictly reader-facing; source validation rejects using it as a replacement for the required topic tag.
- [Long directory harms keyboard/mobile users] → Use semantic sections, native disclosure for the secondary view, visible focus, one-column mobile layout, and no nested scroll region.
- [Existing dirty workspace changes are accidentally included] → Restrict edits and status reporting to the new OpenSpec and Wiki paths; do not commit, clean, or rewrite unrelated files.

## Migration Plan

1. Record and validate this OpenSpec without altering the archived foundation.
2. Add failing source-contract tests for the navigation and migration data model.
3. Add navigation groups, metadata validation, migration ledger, crosswalk, and deterministic generator.
4. Materialize the twenty-nine project-owned draft pages and verify drift/hash behavior.
5. Add failing browser tests for the dual-axis directory and direct feature paths.
6. Implement the directory, generated feature catalog, scoped styles, and practical hand-authored pages.
7. Update Chinese author guidance first, then English.
8. Run source tests, focused browser domains, full Wiki checks/build/artifact checks, artifact-size measurement, and OpenSpec validation.
9. Keep the change active if any recorded content or verification task remains incomplete; archive only after the implemented tranche and all required evidence are truthful.

Rollback removes only the new navigation-group data, new generated-knowledge directory, new hand-authored feature pages, crosswalk/ledger/generator, scoped directory style/procedure, and their tests. Existing forty-two documents and the archived foundation remain valid.

## Open Questions

None for the approved implementation tranche. Later topic-sized changes may promote migrated drafts to reviewed/published status, translate reviewed Chinese pages, or materialize additional host knowledge after artifact-budget review.

A future small content change may add a direct “在 AngelScript 中编写 Unreal 相关单元测试” document (or a compact set of direct documents) under `workflow-validation`. It should reuse the same two-level navigation metadata and practical examples, without expanding this change's test infrastructure or introducing another directory layer.
