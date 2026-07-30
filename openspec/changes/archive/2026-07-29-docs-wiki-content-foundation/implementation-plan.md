# AngelscriptWiki Content Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. The repository forbids creating or switching to a worktree unless the user explicitly asks, so execute in the current checkout and preserve unrelated dirty work. Do not dispatch subagents unless the user explicitly asks for delegation.

**Goal:** Build a Chinese-first, topic-based AngelscriptWiki documentation foundation with source-backed internals pages, a new tag architecture, locale-aware document links, honest placeholders, a 42-entry Showcase catalog, a revisioned Hazelight comparison topic, an explicit UHT sequence, and a separately reviewable pinned plugin-source corpus.

**Architecture:** Formal articles are paired locale tiddlers identified by one logical key. Native TiddlyWiki tags represent only the `ASWiki/Docs` topic tree and `ASWiki/Showcase` stability tree; depth, kind, lifecycle, provenance, translation state, and page roles are fields. Node source-contract tests validate content at repository level, while small Wiki procedures/macros resolve logical links and Playwright verifies rendered behavior. The complete plugin source corpus remains raw data outside the TiddlyWiki boot path; documents consume only registered, generated excerpts and commit-pinned links.

**Tech Stack:** TiddlyWiki 5.4.1, WikiText, Node.js 24, ECMAScript modules, `node:test`, `tiddlywiki-plugin-dev`, TypeScript/ESLint, Playwright, pnpm 11.8.0, Git submodules.

## Global Constraints

- Chinese (`zh-Hans`) is authored and reviewed before English (`en-GB`); missing English falls back visibly to Chinese.
- Do not create English placeholder articles merely to mirror Chinese structure.
- Do not rename or delete an existing canonical tiddler until its compatibility path and consumers are covered.
- Retire `ASWiki/Home`, `ASWiki/Workflow`, `ASWiki/Maintainer`, `ASWiki/Status`, `ASWiki/Theme`, and `ASWiki/Navigation`.
- Keep reader classification under `ASWiki/Docs` and `ASWiki/Showcase`; keep orthogonal state in fields.
- Keep `AngelscriptWikiHome` as the default/compatibility title during this foundation unless a separately reviewed route change updates every consumer.
- `internals` pages are source-backed L4/L5 explanations attached to their owning topic, not Showcase pages.
- GameplayTags and GAS are optional-plugin topics; Enhanced Input, Networking/RPC, UI/UMG, and AI/BehaviorTree are engine-domain topics.
- Exact topic-tag colors remain unset until a later page-based contrast review.
- The source corpus is pinned to a full Git commit and updated only by an explicit command; ordinary Wiki commands stay network-free.
- Hazelight private engine/plugin source is restricted comparison evidence only; never copy it into Wiki source, generated excerpts, the public source corpus, or reader-facing output.
- Treat the 2026-03-12 Hazelight engine report as non-exhaustive path evidence, not a current semantic diff.
- Raw HTML examples are trusted repository content; do not execute live inline scripts/handlers. External embeds are optional, sandboxed, and nonessential to offline verification.
- Never copy the dirty parent `Plugins/Angelscript` worktree into the Wiki source corpus.
- Keep raw source outside `wiki/tiddlers/`, `src/`, `.generated/`, and the TiddlyWiki boot store.
- Preserve all unrelated parent, Wiki, and plugin worktree changes.
- Build and test only the Wiki for Wiki-only implementation; Unreal compilation and automation are not required.
- Commit or push only when the user explicitly requests it. If commits are requested, commit the Wiki repository first and the parent gitlink/OpenSpec second.

---

## File Map

### Foundation contract and runtime

| Path | Action | Responsibility |
|---|---|---|
| `Wiki/scripts/document-content-contract.mjs` | Create | Parse source `.tid` files and validate document, translation, topic, legacy-tag, placeholder, Showcase, and source-key contracts. |
| `Wiki/scripts/document-content-contract.test.mjs` | Create | Unit fixtures plus full-repository validation. |
| `Wiki/package.json` | Modify carefully | Add `test:document-content`, include it in `verify`, and later add source-corpus commands. This file is already dirty; merge around current toolchain work. |
| `Wiki/src/angelscript-tools/documentation/as-doc-target.js` | Create | TiddlyWiki macro that resolves a logical document key by current locale, Chinese fallback, then missing state. |
| `Wiki/src/angelscript-tools/documentation/document-link.tid` | Create | Global `as-doc-link` authoring procedure using the resolver. |
| `Wiki/src/angelscript-tools/documentation/locale-notice.tid` | Create | ViewTemplate notice for Chinese fallback and stale English pages. |
| `Wiki/wiki/tiddlers/as/navigation.tid` | Modify carefully | Replace hard-coded content groups with the documentation directory and compatibility links. This file is already dirty. |

### Taxonomy and directories

| Path | Action | Responsibility |
|---|---|---|
| `Wiki/wiki/tiddlers/docs/DocumentationDirectory.tid` | Create | Localized root directory generated from topic metadata. |
| `Wiki/wiki/tiddlers/docs/InternalsDirectory.tid` | Create | Cross-topic “实现原理” directory filtering `as-doc-kind: internals`. |
| `Wiki/wiki/tiddlers/docs/taxonomy/root.tid` | Create | `ASWiki/Docs` tag-root metadata. |
| `Wiki/wiki/tiddlers/docs/taxonomy/topic-01-start.tid` through `topic-15-showcase-lab.tid` | Create | The fifteen ordered first-level topic tag tiddlers. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/<topic>/index.tid` | Create, fifteen files | Chinese L0 landing for every first-level topic. |
| Existing files listed under Task 3 | Modify | Remove retired tags and assign topic/page-role migration metadata without deleting canonical titles. |

### Initial content skeleton

| Path | Action | Responsibility |
|---|---|---|
| `Wiki/wiki/tiddlers/docs/zh-Hans/unreal-language/*.tid` | Create five additional files | L1–L5 Unreal AngelScript language-feature skeletons; L4/L5 are internals. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/hot-reload/*.tid` | Create five additional files | L1–L5 hot-reload skeletons; L4/L5 are internals. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/bindings-uht-extensions/uht-*.tid` | Create four files | UHT overview, generation workflow, internals, and maintenance sequence. |
| `Wiki/wiki/tiddlers/docs/taxonomy/hazelight-comparison.tid` | Create | Nested `ASWiki/Docs/reference-differences-version/hazelight` tag metadata. |
| `Wiki/wiki/tiddlers/docs/data/HazelightComparisonCatalog.tid` | Create | Machine-readable revisioned Hazelight comparison rows consumed by matrix/detail views. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/reference-differences-version/hazelight-*.tid` | Create seven files | Revisioned Hazelight overview, capability matrix, binding, class, struct, architecture, and audit-maintenance pages/placeholders. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/topics-integrations/*.tid` | Create six files | GameplayTags, GAS, Enhanced Input, Networking/RPC, UI/UMG, and AI/BehaviorTree landings. |

### Showcase

| Path | Action | Responsibility |
|---|---|---|
| `Wiki/wiki/tiddlers/showcase/taxonomy/*.tid` | Create four files | `ASWiki/Showcase` root and Base/Pattern/Lab tier tags. |
| `Wiki/wiki/tiddlers/showcase/ShowcaseIndex.tid` | Create | Root Showcase directory and tier explanation. |
| `Wiki/wiki/tiddlers/showcase/BaseIndex.tid` | Create | Stable-surface index. |
| `Wiki/wiki/tiddlers/showcase/PatternIndex.tid` | Create | Reusable-composition index. |
| `Wiki/wiki/tiddlers/showcase/LabIndex.tid` | Create | Experimental-surface index and warning. |
| `Wiki/wiki/tiddlers/showcase/ShowcaseCatalog.tid` | Create | Machine-readable 42-entry catalog: B01–B15, P01–P16, L01–L11. |
| `Wiki/wiki/tiddlers/examples/*.tid` | Modify selected files | Add Showcase IDs, tier, purpose, formal metadata, and compatibility mapping. |
| `Wiki/wiki/tiddlers/tests/playwright/AngelscriptCodeExamples.tid` | Move | Move the reader-facing page to `wiki/tiddlers/examples/AngelscriptCodeShowcase.tid` while retaining its canonical tiddler title. |
| `Wiki/scripts/source-boundaries.test.mjs` | Modify carefully | Remove the exception that permits a public-title tiddler in the hidden test directory. This file is already dirty. |

### Browser verification and author guidance

| Path | Action | Responsibility |
|---|---|---|
| `Wiki/tests/playwright/product/document-content-foundation.spec.ts` | Create | Topic order, retired tags, locale fallback, stale translation, placeholders, internals, and Showcase behavior. |
| `Wiki/wiki/tiddlers/tests/document-content/*.tid` | Create only as needed | Hidden `$:/tests/TDGameStudio/AngelscriptWiki/...` browser fixtures for missing/stale translation states. |
| `Wiki/AGENTS_ZH.md` | Modify first | Chinese authoring contract and source paths. |
| `Wiki/AGENTS.md` | Modify after Chinese review | English mirror of the reviewed authoring contract. |

### Source corpus, separate execution batch

| Path | Action | Responsibility |
|---|---|---|
| `Wiki/source-corpus.json` | Create | Pinned repository, tree hash, path policy, schema, and license inventory. |
| `Wiki/source-corpus/angelscript/` | Create through synchronizer | Raw published plugin snapshot; never loaded as tiddlers. |
| `Wiki/source-references/angelscript.json` | Create | Stable source keys, symbols/anchors, ranges, hashes, licenses, and consumers. |
| `Wiki/scripts/source-corpus.mjs` | Create | Offline manifest, license, tree, registry, and excerpt validation. |
| `Wiki/scripts/source-corpus.test.mjs` | Create | Deterministic validation and network-boundary tests. |
| `Wiki/scripts/sync-source-corpus.mjs` | Create | Explicit networked synchronization into a temporary checkout and transactional replacement. |
| `Wiki/scripts/generate-source-excerpts.mjs` | Create | Generate only registered excerpt tiddlers and commit-pinned links. |
| `Wiki/wiki/tiddlers/generated/source/` | Generate | Selected bounded excerpts used by reviewed pages. |

---

### Task 1: Preserve the dirty baseline and resolve overlapping ownership

**Files:**

- Inspect only: parent repository, `Wiki/`, and `Plugins/Angelscript/`
- Record during execution: the implementing session's OpenSpec notes or task log

**Interfaces:**

- Consumes: current working trees.
- Produces: exact baseline hashes/status and an overlap list that later tasks must preserve.

- [ ] **Step 1: Capture repository identities and dirty state**

  Run from the parent root:

  ```powershell
  git branch --show-current
  git rev-parse HEAD
  git status --short
  git -C Wiki branch --show-current
  git -C Wiki rev-parse HEAD
  git -C Wiki status --short
  git -C Plugins/Angelscript branch --show-current
  git -C Plugins/Angelscript rev-parse HEAD
  git -C Plugins/Angelscript status --short
  ```

  Expected: all three repositories are identifiable; existing changes are recorded, not cleaned.

- [ ] **Step 2: Mark overlapping files**

  Treat at least these known dirty Wiki files as merge-sensitive:

  ```text
  package.json
  scripts/source-boundaries.test.mjs
  wiki/tiddlers/as/navigation.tid
  tests/playwright/product/*
  src/angelscript-tools/*
  src/angelscript-theme/*
  ```

  Re-read each file immediately before patching it. If a concurrent edit changes the same block, stop that task and integrate the current version deliberately; do not restore an earlier copy.

- [ ] **Step 3: Verify toolchain without changing dependencies**

  Run:

  ```powershell
  Set-Location Wiki
  node --version
  pnpm --version
  pnpm run toolchain:check
  ```

  Expected: Node is in the repository-supported 24.x range, pnpm is 11.8.0, and the toolchain check passes. Do not run `pnpm install` unless the existing checkout lacks dependencies.

### Task 2: Build the source-level document contract with fixture-first TDD

**Files:**

- Create: `Wiki/scripts/document-content-contract.mjs`
- Create: `Wiki/scripts/document-content-contract.test.mjs`
- Modify: `Wiki/package.json`

**Interfaces:**

- Produces `parseTidSource(source, sourcePath)`.
- Produces `collectDocumentSources({ wikiRoot })`.
- Produces `validateDocumentContent({ wikiRoot, records?, catalogs? })`.
- Produces `formatDocumentErrors(errors)`.
- `validateDocumentContent` returns `{ records, errors, warnings, statistics }`; each error contains `code`, `sourcePath`, `title`, `field`, and `message` where applicable.

- [ ] **Step 1: Write parser and isolated validator tests**

  Add `node:test` cases that construct temporary `.tid` sources and assert:

  ```javascript
  assert.deepEqual(parseTidSource('title: Example\\ntags: [[ASWiki/Docs/start]]\\n\\nBody', 'Example.tid'), {
    sourcePath: 'Example.tid',
    fields: { title: 'Example', tags: '[[ASWiki/Docs/start]]' },
    body: 'Body',
  });
  ```

  Include fixtures for:

  - a valid reviewed Chinese document;
  - a valid English pair;
  - missing required field;
  - invalid locale/depth/kind/status;
  - duplicate `(as-doc-key, as-locale)`;
  - stale translation revision;
  - unsupported English-without-reviewed-Chinese;
  - missing primary topic;
  - retired legacy tag;
  - allowed compatibility title and rejected unknown compatibility title;
  - empty placeholder section;
  - Showcase tier/tag mismatch and duplicate ID;
  - Hazelight catalog duplicate ID, invalid relationship/confidence, missing revisions/date/evidence/consequences, performance claim without benchmark evidence, and restricted-source excerpt leakage;
  - unknown `as-sources` key.

- [ ] **Step 2: Run the tests and observe the intended failure**

  Run:

  ```powershell
  Set-Location Wiki
  node --test scripts/document-content-contract.test.mjs
  ```

  Expected: failure because `document-content-contract.mjs` does not exist or does not export the four interfaces.

- [ ] **Step 3: Implement the parser and validator**

  Implement these exact enum sets:

  ```javascript
  const locales = new Set(['zh-Hans', 'en-GB']);
  const depths = new Set(['L0', 'L1', 'L2', 'L3', 'L4', 'L5']);
  const documentKinds = new Set([
    'tutorial',
    'guide',
    'reference',
    'explanation',
    'internals',
    'showcase',
  ]);
  const contentStatuses = new Set(['placeholder', 'draft', 'reviewed', 'published']);
  const translationStatuses = new Set(['draft', 'reviewed', 'stale']);
  const comparisonRelationships = new Set([
    'same',
    'diverged',
    'selective-backport',
    'reimplemented',
    'removed',
    'local-only',
    'future-candidate',
  ]);
  const comparisonConfidence = new Set(['verified', 'supported', 'provisional']);
  const pageRoles = new Set([
    'home',
    'navigation',
    'project-status',
    'project-meta',
    'compatibility',
  ]);
  const retiredTags = new Set([
    'ASWiki/Home',
    'ASWiki/Workflow',
    'ASWiki/Maintainer',
    'ASWiki/Status',
    'ASWiki/Theme',
    'ASWiki/Navigation',
  ]);
  ```

  Use an explicit allowlist for existing compatibility titles:

  ```javascript
  const compatibilityTitles = new Set([
    'AS/Status',
    'AS/Workflow/GettingStarted',
    'AS/Workflow/AuthoringAndHotReload',
    'AS/Workflow/Debugging',
    'AS/Workflow/TestingAndRelease',
    'AS/Maintainer/Bindings',
    'AS/Maintainer/BuildAndDiagnostics',
  ]);
  ```

  Parse `.tid` headers up to the first blank line; preserve the body exactly except newline normalization used by the test. Emit deterministic sorted errors. Validate positive integer revisions for reviewed/published content. Validate required placeholder headings by content markers rather than prose length alone.

- [ ] **Step 4: Make fixture tests pass**

  Run:

  ```powershell
  node --test scripts/document-content-contract.test.mjs
  ```

  Expected: all isolated parser/validator tests pass. The full-repository test is added only after the next task creates compliant source.

- [ ] **Step 5: Add the package entry without losing concurrent scripts**

  Merge these entries into the current `scripts` object:

  ```json
  {
    "pretest:document-content": "pnpm run toolchain:check",
    "test:document-content": "node --test scripts/document-content-contract.test.mjs"
  }
  ```

  Do not replace the current `verify` command yet; the full-repository test must first pass.

### Task 3: Create the new taxonomy and retire legacy ASWiki tags

**Files:**

- Create: `Wiki/wiki/tiddlers/docs/taxonomy/root.tid`
- Create: fifteen `Wiki/wiki/tiddlers/docs/taxonomy/topic-*.tid` files
- Create: `Wiki/wiki/tiddlers/docs/DocumentationDirectory.tid`
- Create: fifteen `Wiki/wiki/tiddlers/docs/zh-Hans/<topic>/index.tid` files
- Modify: `Wiki/wiki/tiddlers/AngelscriptWikiHome.tid`
- Modify: `Wiki/wiki/tiddlers/as/navigation.tid`
- Modify: `Wiki/wiki/tiddlers/as/status.tid`
- Modify: `Wiki/wiki/tiddlers/as/theme-roadmap.tid`
- Modify: all four files under `Wiki/wiki/tiddlers/as/workflow/`
- Modify: both files under `Wiki/wiki/tiddlers/as/maintainer/`
- Test: `Wiki/scripts/document-content-contract.test.mjs`

**Interfaces:**

- Produces the tag root `ASWiki/Docs`.
- Produces fifteen child tags `ASWiki/Docs/<topic-key>` ordered by integer `as-order`.
- Produces formal Chinese landing titles `AS/Docs/zh-Hans/<topic-key>/index`.
- Produces `AS/Docs` as the metadata-driven directory title.

- [ ] **Step 1: Add a failing full-repository contract test**

  Append a test equivalent to:

  ```javascript
  test('repository documentation satisfies the content contract', () => {
    const result = validateDocumentContent({ wikiRoot });
    assert.deepEqual(result.errors, [], formatDocumentErrors(result.errors));
  });
  ```

  Run `pnpm run test:document-content`.

  Expected: failure listing missing taxonomy, existing legacy tags, and absent required landing metadata.

- [ ] **Step 2: Create the tag root and fifteen topic tags**

  Every first-level tag tiddler uses:

  ```text
  title: ASWiki/Docs/<topic-key>
  type: text/vnd.tiddlywiki
  tags: ASWiki/Docs
  caption: <Chinese caption>
  description: <one-sentence scope>
  as-order: <1 through 15>
  ```

  Create keys in this exact order:

  ```text
  start
  language
  unreal-language
  type-object-reflection
  unreal-core
  compile-module-preprocessor
  hot-reload
  editor-ide-debugging
  testing-diagnostics-release
  runtime-jit-vm
  bindings-uht-extensions
  architecture-maintenance
  topics-integrations
  reference-differences-version
  showcase-lab
  ```

  Do not add a `color` field.

- [ ] **Step 3: Create the fifteen Chinese L0 landings**

  Use `title: AS/Docs/zh-Hans/<topic-key>/index`, `as-doc-key: <topic-key>/index`, `as-locale: zh-Hans`, `as-depth: L0`, and topic-appropriate `as-doc-kind`. Use `as-content-status: placeholder` except where content has actually been reviewed in that implementation session.

  Every placeholder body must contain:

  ```text
  ! 本章要解决什么
  ! 计划内容
  ! 已知资料
  ! 源码入口
  ! 依赖与相关页面
  ! 审阅状态
  ```

  Each section must contain concrete topic-specific text and stable source keys/areas from this OpenSpec; “规划中” alone is invalid.

- [ ] **Step 4: Create the metadata-driven directory**

  `DocumentationDirectory.tid` has `title: AS/Docs`, `as-page-role: navigation`, and lists `[tag[ASWiki/Docs]sortan[as-order]]`. Render each topic's caption, description, and link to its Chinese landing. Use native `<$list>`, `<$link>`, and `<$view>` widgets for dynamic targets; do not interpolate variables into shortcut link syntax.

- [ ] **Step 5: Migrate every legacy tag**

  Apply this exact mapping:

  | Existing title | New classification |
  |---|---|
  | `AngelscriptWikiHome` | no content tag; `as-page-role: home` |
  | `AS/Navigation` | no content tag; `as-page-role: navigation` |
  | `AS/Status` | `ASWiki/Docs/reference-differences-version`; compatibility role until body migration |
  | `AS/Workflow/GettingStarted` | `ASWiki/Docs/start`; compatibility role |
  | `AS/Workflow/AuthoringAndHotReload` | `ASWiki/Docs/hot-reload`; compatibility role |
  | `AS/Workflow/Debugging` | `ASWiki/Docs/editor-ide-debugging`; compatibility role |
  | `AS/Workflow/TestingAndRelease` | `ASWiki/Docs/testing-diagnostics-release`; compatibility role |
  | `AS/Maintainer/Bindings` | `ASWiki/Docs/bindings-uht-extensions`; compatibility role |
  | `AS/Maintainer/BuildAndDiagnostics` | `ASWiki/Docs/testing-diagnostics-release`; compatibility role |
  | `AS/ThemeRoadmap` | no reader tag; `as-page-role: project-meta` |

  Preserve every canonical title and body. Add a visible link from each compatibility page to its new topic landing. Remove all six retired tags.

- [ ] **Step 6: Make the repository contract pass**

  Run:

  ```powershell
  pnpm run test:document-content
  pnpm run test:source-boundaries
  ```

  Expected: both commands pass; a recursive content scan reports zero use of the six retired tags outside test strings that assert rejection.

### Task 4: Add locale-aware logical links and visible fallback state

**Files:**

- Create: `Wiki/src/angelscript-tools/documentation/as-doc-target.js`
- Create: `Wiki/src/angelscript-tools/documentation/document-link.tid`
- Create: `Wiki/src/angelscript-tools/documentation/locale-notice.tid`
- Modify: `Wiki/wiki/tiddlers/as/navigation.tid`
- Test: `Wiki/scripts/document-content-contract.test.mjs`
- Test: `Wiki/tests/playwright/product/document-content-foundation.spec.ts`

**Interfaces:**

- `<<as-doc-target "unreal-language/default-statement">>` returns an existing target title or the explicit missing-document title.
- `<<as-doc-link "unreal-language/default-statement" "default 语句">>` renders a native TiddlyWiki link.
- Resolution order: active supported locale, `zh-Hans`, explicit missing page.

- [ ] **Step 1: Write resolver tests**

  Load a minimal TiddlyWiki instance and assert:

  - `zh-Hans` resolves to the Chinese tiddler;
  - `en-GB` resolves to English when the pair exists;
  - `en-GB` falls back to Chinese when English is absent;
  - missing both locales resolves to a stable missing-document presentation;
  - a stale English document remains reachable but exposes its mismatch.

  Run the focused test and confirm it fails before the macro exists.

- [ ] **Step 2: Implement the resolver macro**

  Use a TiddlyWiki `module-type: macro` JavaScript module. Normalize `$:/language` by removing `$:/languages/`; accept only `zh-Hans` and `en-GB`, defaulting the UI lookup to `en-GB` without changing article fallback order. Construct titles only as:

  ```text
  AS/Docs/<locale>/<doc-key>
  ```

  Reject document keys containing `..`, a leading slash, a trailing slash, backslashes, or an unsupported character. Return the explicit missing-document title for invalid/missing input.

- [ ] **Step 3: Implement the global author procedure and notices**

  `document-link.tid` uses `tags: $:/tags/Global` and renders the dynamic target with `<$link>`.

  `locale-notice.tid` uses `tags: $:/tags/ViewTemplate` and renders only when:

  - the UI is not Chinese and the current formal page has `as-locale: zh-Hans`; or
  - the current English page has `as-translation-status: stale`.

  The notice states the current language/revision condition and links to the reviewed Chinese source when applicable.

- [ ] **Step 4: Replace hard-coded primary navigation with directory links**

  Keep the AS sidebar tab, but point its primary reader entry to `AS/Docs`, plus direct links to `AS/Docs/Internals` and `AS/Showcase`. Keep the inventoried compatibility links in a collapsed migration group until their bodies move.

- [ ] **Step 5: Verify source and browser behavior**

  Run:

  ```powershell
  pnpm run test:document-content
  pnpm run test:multilingual
  pnpm run test:playwright -- --grep "document content foundation"
  ```

  Expected: locale resolution, Chinese fallback notice, stale revision notice, and preserved legacy titles pass.

### Task 5: Add language-feature, hot-reload, UHT, Hazelight, internals, and integration skeletons

**Files:**

- Create under `Wiki/wiki/tiddlers/docs/zh-Hans/unreal-language/`:
  - `first-feature-path.tid`
  - `feature-catalog.tid`
  - `boundaries-and-differences.tid`
  - `feature-implementation-principles.tid`
  - `source-tests-maintenance.tid`
- Create under `Wiki/wiki/tiddlers/docs/zh-Hans/hot-reload/`:
  - `daily-workflow.tid`
  - `change-classification.tid`
  - `failures-and-recovery.tid`
  - `reload-pipeline-internals.tid`
  - `source-tests-maintenance.tid`
- Create under `Wiki/wiki/tiddlers/docs/zh-Hans/bindings-uht-extensions/`:
  - `uht-plugin-overview.tid`
  - `uht-generation-workflow.tid`
  - `uht-plugin-internals.tid`
  - `uht-plugin-maintenance.tid`
- Create: `Wiki/wiki/tiddlers/docs/taxonomy/hazelight-comparison.tid`
- Create: `Wiki/wiki/tiddlers/docs/data/HazelightComparisonCatalog.tid`
- Create under `Wiki/wiki/tiddlers/docs/zh-Hans/reference-differences-version/`:
  - `hazelight-comparison-overview.tid`
  - `hazelight-capability-matrix.tid`
  - `hazelight-function-binding.tid`
  - `hazelight-class-generation.tid`
  - `hazelight-struct-generation.tid`
  - `hazelight-architecture-differences.tid`
  - `hazelight-audit-maintenance.tid`
- Create: `Wiki/wiki/tiddlers/docs/InternalsDirectory.tid`
- Create six `Wiki/wiki/tiddlers/docs/zh-Hans/topics-integrations/*.tid` files
- Test: `Wiki/scripts/document-content-contract.test.mjs`

**Interfaces:**

- Produces complete L0–L5 skeleton coverage for the two emphasized topics.
- Produces `as-doc-kind: internals` discovery across topics.
- Produces the exact four-page UHT sequence and its three-path binding model.
- Produces the revisioned Hazelight nested topic and seven initial Chinese pages/catalog.
- Produces six correctly classified integration landings.

- [ ] **Step 1: Add failing contract expectations**

  Assert exact logical keys/depths and integration classifications:

  ```text
  unreal-language/index                                  L0
  unreal-language/first-feature-path                     L1
  unreal-language/feature-catalog                        L2
  unreal-language/boundaries-and-differences             L3
  unreal-language/feature-implementation-principles      L4 internals
  unreal-language/source-tests-maintenance               L5 internals
  hot-reload/index                                       L0
  hot-reload/daily-workflow                              L1
  hot-reload/change-classification                       L2
  hot-reload/failures-and-recovery                       L3
  hot-reload/reload-pipeline-internals                   L4 internals
  hot-reload/source-tests-maintenance                    L5 internals
  bindings-uht-extensions/uht-plugin-overview            L1
  bindings-uht-extensions/uht-generation-workflow        L2
  bindings-uht-extensions/uht-plugin-internals           L4 internals
  bindings-uht-extensions/uht-plugin-maintenance         L5 internals
  reference-differences-version/hazelight-comparison-overview       L0
  reference-differences-version/hazelight-capability-matrix         L2
  reference-differences-version/hazelight-function-binding          L4 internals
  reference-differences-version/hazelight-class-generation          L4 internals
  reference-differences-version/hazelight-struct-generation         L4 internals
  reference-differences-version/hazelight-architecture-differences  L4 internals
  reference-differences-version/hazelight-audit-maintenance         L5 internals
  ```

  Run the focused contract and confirm these records are missing.

- [ ] **Step 2: Write topic-specific placeholder bodies**

  Language L2 must enumerate UPROPERTY, UFUNCTION, default/default components, delegate/event, access, mixin, f-string, FName literals, RPC, wrappers/containers, editor/cooked conditions, and divergent behavior.

  Hot-reload L2–L4 must enumerate file observation/coalescing, preprocessing/dependencies, soft/full classification, PIE/restart, compilation events, ClassGenerator, ClassReloadHelper, CDO/default components, instance migration, Blueprint descendants/BlueprintImpact, diagnostics, cleanup, and tests.

  Each internals placeholder additionally records: observable behavior, pipeline/state model, important data structures, source entry points, minimal trace/experiment, failure modes, and regression evidence.

- [ ] **Step 3: Create the Internals directory**

  Use a field filter for `as-doc-kind[internals]`, sort by topic order and document order, and display topic plus depth. Do not introduce an `ASWiki/Internals` tag.

- [ ] **Step 4: Create the four-page UHT sequence**

  The pages must distinguish the independent C# UBT/UHT tool from the Runtime UE module and trace:

  ```text
  C++ headers/metadata
    -> module/config selection
    -> eligibility and signature policy
    -> NativeRuntimeLinked | NativeModuleFunctionAddress | ReflectiveFallback
    -> shards/aggregators/ModularFeatures payload
    -> Runtime registration
    -> statistics/diagnostics/cleanup/tests
  ```

  The L5 page records the native-module layout-version file and the rule that payload, view, generator, bridge, and tests change together. It also states that RPC/Net UFunctions remain reflective fallback and that `NativeModuleFunctionAddress` requires a source engine.

- [ ] **Step 5: Create the Hazelight nested topic and initial comparison pages**

  Add the nested tag `ASWiki/Docs/reference-differences-version/hazelight`. Seed the pages from `research/hazelight-comparison-audit.md` and `research/hazelight-engine-change-inventory.md`:

  - pin the initial Hazelight and local revisions plus comparison date;
  - define relationship/confidence/evidence fields;
  - mark the 2026-03-12 thirteen-file report as non-exhaustive and revisionless;
  - compare Hazelight engine-UHT erased pointers/function map with local generated/fallback paths;
  - describe Hazelight class generation as hybrid engine hooks plus `UASClass`;
  - keep struct claims UE-version-specific;
  - record `f459e632...` editor-only class/struct propagation as `future-candidate`, not adopted behavior;
  - prohibit private-source excerpts/public mirroring and unbenchmarked performance conclusions.

  Create `AS/Docs/Data/HazelightComparisonCatalog` as an `application/json` tiddler. Validate unique row IDs and the exact schema from the design. The rendered capability matrix and detailed pages consume this shared data so the relationship and revisions have one source of truth.

  Use informative placeholders where the final Chinese article is not yet reviewed. The capability matrix may contain catalog rows without creating more empty tiddlers.

- [ ] **Step 6: Create six special-topic landings**

  Use slugs:

  ```text
  gameplay-tags
  gas
  enhanced-input
  networking-rpc
  ui-umg
  ai-behavior-tree
  ```

  GameplayTags and GAS use `as-integration-kind: optional-plugin`; GAS identifies `AngelscriptGameplayTags` as a dependency. The other four use `as-integration-kind: engine-domain`.

- [ ] **Step 7: Run contract verification**

  Run `pnpm run test:document-content`.

  Expected: exact depths, internals fields, UHT path distinctions, Hazelight revision/evidence/private-source boundaries, topic ownership, and integration classifications pass; no English placeholder pages exist.

### Task 6: Establish the 42-entry Showcase system and Base tag

**Files:**

- Create taxonomy/index/catalog files from the File Map.
- Modify the five current reader-facing Showcase pages.
- Move `AngelscriptCodeExamples.tid` as described.
- Modify: `Wiki/scripts/source-boundaries.test.mjs`
- Test: `Wiki/scripts/document-content-contract.test.mjs`
- Test: `Wiki/tests/playwright/product/document-content-foundation.spec.ts`

**Interfaces:**

- Produces tier tags `ASWiki/Showcase/Base`, `ASWiki/Showcase/Pattern`, and `ASWiki/Showcase/Lab`.
- Produces unique catalog IDs B01–B15, P01–P16, and L01–L11.
- Implemented pages expose `as-showcase-id`, `as-showcase-tier`, and `as-showcase-purpose`.

- [ ] **Step 1: Add catalog and source-boundary failures**

  Assert:

  - the three tiers exist;
  - 42 IDs are present and unique;
  - every implemented page has exactly one matching tier tag;
  - no ordinary-title `.tid` remains under `wiki/tiddlers/tests`;
  - no empty page is required for a catalog-only entry.
  - B13–B15, P15–P16, and L11 carry the exact purpose/security/offline boundaries from `research/tiddlywiki-expression-showcase.md`.

  Confirm focused tests fail before the files move.

- [ ] **Step 2: Create the tier taxonomy and indexes**

  Do not assign final colors. Each tier index explains stability, author use, and verification strength.

- [ ] **Step 3: Create the catalog**

  Encode every row from `research/showcase-gap-matrix.md` with:

  ```text
  id
  tier
  name
  purpose
  state
  current-source
  planned-verification
  ```

  Use `state` values `mapped`, `gap`, or `experiment`. The catalog is the complete inventory; it must not imply that all 42 pages exist.

  The added rows are:

  ```text
  B13 TiddlyWiki variables/procedures/functions/legacy macros
  B14 trusted WikiText HTML and widget composition
  B15 embedded local/external web content
  P15 parameterized WikiText documentation component
  P16 embedded interactive companion with static fallback
  L11 web-embed security and packaging policy
  ```

  B13–B15 remain `gap` until focused pages and deterministic browser behavior are ready; cataloging them is not a claim that iframe/network/security behavior is already implemented.

- [ ] **Step 4: Classify current Showcase pages**

  Map Markdown basic to B01, Markdown extended to B02, Markdown More to B03, and WikiText to B04 with B05/B06 coverage noted in the catalog. Keep the existing `语法展示范式` title as a compatibility index that links to the new Showcase root.

- [ ] **Step 5: Separate the AngelScript reader page from hidden fixtures**

  Move only `AngelscriptCodeExamples.tid` to `wiki/tiddlers/examples/AngelscriptCodeShowcase.tid`, preserving `title: AngelscriptCodeExamples`. Keep `$:/tests/TDGameStudio/AngelscriptWiki/Code/*` source fixtures under the tests directory. Remove the filename exception from `source-boundaries.test.mjs`.

- [ ] **Step 6: Verify tier behavior**

  Run:

  ```powershell
  pnpm run test:document-content
  pnpm run test:source-boundaries
  pnpm run test:playwright -- --grep "Showcase"
  ```

  Expected: Base/Pattern/Lab are discoverable, the catalog has 42 unique entries, current pages are mapped, native WikiText/HTML/embed gaps are explicit, and Lab is visibly experimental.

### Task 7: Implement the pinned source-reference corpus as a separate reviewed batch

**Files:**

- Create every source-corpus file listed in the File Map.
- Modify: `Wiki/package.json`
- Modify: `Wiki/.gitignore` only if temporary checkout/staging directories need an explicit ignored path.

**Interfaces:**

- `validateSourceCorpus({ wikiRoot })` returns deterministic errors/statistics.
- `generateSourceExcerpts({ wikiRoot })` writes only registered excerpts.
- `sync-source-corpus.mjs --repository <https-url> --revision <40-hex>` is the only networked update entry.
- Normal Wiki commands call validation/generation but never synchronization.

- [ ] **Step 1: Write offline manifest and registry tests**

  Cover exact-commit validation, repository identity, tree hash, path containment, notice/license classification, source-key uniqueness, anchor/range resolution, excerpt hash, consumer lookup, boot-path exclusion, restricted metadata-only Hazelight keys, and rejection of private Hazelight source as a corpus input.

  Add a test that replaces network functions with throwing stubs and confirms `validateSourceCorpus` and `generateSourceExcerpts` do not call them.

- [ ] **Step 2: Implement the offline validator and excerpt generator**

  Reject:

  - a revision that is not 40 hexadecimal characters;
  - an absolute path, `..`, or path outside the corpus root;
  - an unclassified third-party path;
  - ambiguous/missing anchors;
  - excerpt-hash drift without registry review;
  - raw snapshot files inside Wiki boot/product-source roots.
  - a private/restricted Hazelight source key that contains an excerpt body or public-link payload;
  - a corpus repository identity other than the explicitly allowed published TDGameStudio plugin repository.

  Generate excerpt tiddlers deterministically with source key, repository, revision, path, symbol/anchor, range, hash, license, and a commit-pinned GitHub URL.

- [ ] **Step 3: Write synchronization tests around a local fixture repository**

  Use a temporary local Git repository, not GitHub, to verify:

  - exact revision checkout;
  - wrong repository/revision rejection;
  - changed/moved/ambiguous/missing reference reporting;
  - unknown license-path rejection;
  - transactional replacement;
  - no automatic commit or push.

- [ ] **Step 4: Implement explicit synchronization**

  The command clones/fetches into a new temporary directory, validates the exact commit, constructs a staged snapshot, runs offline validation, writes a human-readable and JSON diff report, and swaps the staged tree only after success. On failure it leaves the prior corpus untouched.

  Windows path deletion/move must use native Node filesystem APIs or one validated PowerShell path end-to-end; never construct a cross-shell recursive deletion.

- [ ] **Step 5: Perform the first real import only with explicit network authorization**

  Use:

  ```powershell
  pnpm run sync:source-corpus -- --repository https://github.com/TDGameStudio/UnrealAngelscriptPlugin --revision <reviewed-40-hex-commit>
  ```

  Review the repository, revision, tree hash, notices, third-party classifications, raw bytes, generated bytes, and changed-reference summary before accepting the snapshot.

- [ ] **Step 6: Integrate only offline checks into normal verification**

  Add:

  ```json
  {
    "test:source-corpus": "node --test scripts/source-corpus.test.mjs",
    "sync:source-corpus": "node scripts/sync-source-corpus.mjs"
  }
  ```

  Add `pnpm run test:source-corpus` to `verify`; never add `sync:source-corpus` to `prepare`, `dev`, `test`, `verify`, or `build:wiki`.

### Task 8: Complete browser coverage and Chinese-first author guidance

**Files:**

- Create/complete: `Wiki/tests/playwright/product/document-content-foundation.spec.ts`
- Create hidden test fixtures only where required.
- Modify first: `Wiki/AGENTS_ZH.md`
- Modify after review: `Wiki/AGENTS.md`

**Interfaces:**

- Produces a stable author workflow for new Chinese, English, internals, placeholder, source-reference, and Showcase pages.

- [ ] **Step 1: Cover the product-level acceptance matrix**

  Add resilient browser cases for:

  - ordered topic directory;
  - Home default title preserved without `ASWiki/Home`;
  - zero visible retired classification tags;
  - lower-depth articles shown before L4/L5;
  - Internals directory shows owning topic/depth;
  - English UI falls back to Chinese with a notice;
  - stale English shows revision mismatch and Chinese link;
  - placeholder displays planned/unreviewed state and required sections;
  - special-topic packaging labels;
  - UHT sequence exposes direct/generated/fallback boundaries;
  - Hazelight topic shows pinned baselines, report limitations, evidence confidence, restricted-source status, and a `future-candidate`;
  - Base/Pattern/Lab discoverability and Lab warning;
  - B13–B15/P15–P16/L11 catalog records show native WikiText, HTML, embedding, fallback, and security scope;
  - reader-facing AngelScript example moved out of hidden fixture directory.

- [ ] **Step 2: Write the Chinese author guide**

  Document:

  - exact source/title/logical-key convention;
  - required metadata and enums;
  - topic-tag and retired-tag rules;
  - Chinese review before English creation;
  - revision/stale workflow;
  - `internals` evidence shape;
  - placeholder required sections;
  - source-key and corpus update boundary;
  - Hazelight comparison row schema, evidence priority, private-source prohibition, and benchmark requirement;
  - Showcase tier selection;
  - TiddlyWiki procedure/function/legacy-macro guidance plus trusted HTML and iframe/offline/security boundaries;
  - focused and full verification commands.

- [ ] **Step 3: Review Chinese instructions before writing English**

  Check Chinese guidance against actual fields, paths, procedures, and test names. Only then update `Wiki/AGENTS.md` with the equivalent English contract.

- [ ] **Step 4: Add foundation checks to full verification**

  Merge, without dropping current commands:

  ```text
  pnpm run test:document-content
  pnpm run test:source-corpus
  ```

  into `pnpm run verify` after source-boundary/product-source checks and before build/browser completion.

### Task 9: Final verification and dual-repository handoff

**Files:**

- Verify all intended Wiki files.
- Update the parent OpenSpec task states only after implementation evidence exists.

**Interfaces:**

- Produces a reviewable Wiki change and an unchanged unrelated dirty baseline.

- [ ] **Step 1: Run focused gates**

  From `Wiki/`:

  ```powershell
  pnpm run test:document-content
  pnpm run test:source-corpus
  pnpm run test:multilingual
  pnpm run test:source-boundaries
  pnpm run test:product-sources
  pnpm run test:playwright -- --grep "document content foundation|Showcase"
  ```

  Expected: all pass.

- [ ] **Step 2: Run complete Wiki verification**

  ```powershell
  pnpm run check
  pnpm run lint:all
  pnpm run build:wiki
  pnpm run verify
  ```

  Expected: all pass. `verify` may repeat earlier commands; the final result is the evidence of repository integration.

- [ ] **Step 3: Inspect the integrated artifact**

  Open the generated offline Wiki and manually inspect at least:

  - `AngelscriptWikiHome`;
  - `AS/Docs`;
  - Unreal language L0 and L4;
  - hot reload L0 and L4;
  - UHT overview, internals, and one generated-versus-fallback trace;
  - Hazelight overview/matrix, engine-report limitation notice, and one class/struct/binding detail;
  - one special-topic landing;
  - `AS/Docs/Internals`;
  - `AS/Showcase`;
  - one Base page, the B13–B15 catalog rows, and the Lab index/L11 warning;
  - English UI fallback to a Chinese-only document.

  Confirm no raw source corpus is embedded in the boot tiddlers and selected excerpts work offline.

- [ ] **Step 4: Compare dirty boundaries**

  Run:

  ```powershell
  git -C Wiki status --short
  git -C Wiki diff --check
  git status --short
  git -C Plugins/Angelscript status --short
  ```

  Expected: intended Wiki changes are identifiable; pre-existing Wiki/plugin/parent changes are still present; plugin worktree content is unchanged by corpus synchronization.

- [ ] **Step 5: Commit only on explicit request**

  If requested, stage exact paths in `Wiki/`, review the staged diff, commit Wiki first, then return to the parent and stage only the `Wiki` gitlink plus `openspec/changes/docs-wiki-content-foundation/`. Do not use `git add .`, do not force-push, and do not archive this OpenSpec until implementation scope is actually closed or deliberately rewritten.
