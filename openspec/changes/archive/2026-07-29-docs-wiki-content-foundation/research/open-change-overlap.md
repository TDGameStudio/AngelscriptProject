# OpenSpec and Workspace Overlap Record

Captured: 2026-07-25

This file prevents the documentation foundation from absorbing or overwriting adjacent Wiki work.

## 1. Direct dependencies and reuse

| Change or capability | State at capture | Reuse / dependency | Ownership boundary |
|---|---|---|---|
| `refactor-wiki-toolchain-reliability` | In progress | zh-Hans/en-GB product locale contract, lingo compatibility, fresh Playwright workflow, source-level multilingual checks | This foundation owns formal paired article lifecycle. Before archive, reconcile UI en-GB fallback wording with article zh-Hans fallback. |
| `refactor-wiki-architecture-hardening` | In progress | product source manifest, hidden test fixtures, modular theme/tools/config responsibilities, offline boundaries | This foundation must follow those boundaries and must not change product manifests or core overrides. |
| `feature-wiki-syntax-showcase` | Complete, unarchived | existing Markdown, Markdown More, WikiText showcase pages and tests | This foundation maps and expands the catalog; it does not duplicate those pages. |
| `improve-wiki-sdk-document-experience` | Complete, unarchived | `caption`, `description`, `as-sdk-document`, code presentation, responsive document identity | New formal metadata extends this existing identity. |
| `improve-wiki-code-copy-interaction` | Complete | stable code copy behavior | Base code surfaces reuse it. |
| `improve-wiki-search-experience` | Complete | existing search UI | This foundation does not replace search; it adds searchable locale pages and metadata. |
| `improve-wiki-visual-refinements` | Complete, with local evidence | current document/sidebars/tag visual refinements | Exact topic palette is deferred; no visual implementation is copied into this record. |
| `refactor-wiki-unified-line-icons` | Complete with dirty Wiki source pending | line-icon generation/import and sidebar use | Content implementation must preserve it and avoid icon-system changes. |
| `feature-wiki-home-concept-previews` | No tasks | ignored/local homepage concepts | Not a source of truth and not part of this change. |
| `improve-wiki-github-pages-publishing` | In progress | future repository publishing | Content foundation does not deploy or change publishing. |
| `feature-wiki-notion-cover-icon` | In progress | separate cover/icon experiment | Explicitly out of scope; architecture hardening may supersede/remove it. |
| `refactor-uht-plugin-hardening` | In progress and locally modified | Current UHT binding policy, generated artifacts, Runtime bridge, statistics, fallback, and layout contracts | The documentation sequence records intended coverage only. Re-read the completed implementation/specs before publishing UHT claims; do not alter its code from this change. |
| Hazelight update-audit state/log | Maintained outside this content change and locally modified | Previous review marker and adoption history | This research performs read-only comparison and records its own pinned baseline. It does not advance or rewrite the global audit marker/log. |

## 2. Main specs reused without modification

- `angelscript-wiki-theme`
- `wiki-document-experience-integration`
- `tw-angelscript-tools`
- `wiki-repository-publishing`
- `reliable-offline-publish`

The new capabilities refer to those behaviors but do not create delta specs for them. Historical main specs contain known stale text; reconciling all historical requirements is not part of this plan-only record.

## 3. Dirty workspace baseline

Before this OpenSpec was created:

- the parent repository had modifications and untracked work across host configuration, documents, plugins, tools, other changes, and the Wiki gitlink;
- the Wiki submodule had in-progress toolchain, multilingual, theme, navigation, icon, source-boundary, and Playwright changes;
- the target change directory did not exist.

Implementation rules:

- edit only `openspec/changes/docs-wiki-content-foundation/` in this recording session;
- do not normalize, stage, reset, or reformat unrelated paths;
- do not run a formatter over the parent repository;
- do not edit the Wiki submodule until a later explicit apply session;
- when Wiki implementation starts, capture its then-current status again and coordinate any overlap with `package.json`, `as/navigation.tid`, multilingual tests, and Playwright configuration;
- commit Wiki changes first and the parent gitlink/OpenSpec second only when the user requests integration.

## 4. Local visual brainstorm material

Temporary ignored visualization drafts created during early exploration were removed after the user deferred visualization. No visual mockup is an input or deliverable of this OpenSpec; an empty ignored parent directory, if present, has no product or planning significance.

## 5. Deferred change boundaries

Separate future changes are required for:

- final topic tag color selection and visual acceptance;
- a homepage/directory redesign beyond metadata-driven navigation;
- AST, bytecode, VM, coverage, or other heavy interactive visualizations;
- translation of reviewed Chinese articles;
- topic-by-topic content migration;
- deprecation/removal of host knowledge articles;
- any new browser-to-Unreal data/service bridge.
