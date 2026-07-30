# AngelscriptWiki Content Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the placeholder-only documentation foundation into a dual-axis, capability-discoverable Wiki with rich project-owned language drafts, a reviewed initial learning path, and a complete non-destructive migration ledger.

**Architecture:** Formal document tiddlers remain the single runtime source of navigation identity. Every Chinese formal document is assigned to one of seven reader groups, producing an exact two-level group → direct-tiddler navigation in both `AS/Docs` and `AS/Navigation`; `as-nav-parent` is metadata only and never renders a third level. Existing topic tags and L0-L5 fields provide the preserved secondary knowledge-system view. A deterministic offline generator materializes only the twenty-nine `Syntax_*` and `AS_*` host knowledge sources as draft Markdown tiddlers, while hand-authored WikiText pages provide concise practical guidance.

**Tech Stack:** TiddlyWiki 5.4.1 WikiText and filters, Markdown More, Node.js 24 ESM scripts and `node:test`, Playwright 1.61, pnpm 11, OpenSpec.

## Global Constraints

- Work in the current main checkout; do not create or switch worktrees.
- Do not delete or rename the existing forty-two foundation formal documents.
- Do not edit or delete `Documents/Knowledges/ZH` source articles.
- Do not copy Hazelight prose or media; public URLs are crosswalk metadata only.
- Preserve the exact fifteen topic keys, L0-L5 meanings, logical document keys, compatibility routes, locale lifecycle, source-corpus isolation, and Showcase system.
- Chinese authoring guidance changes before English.
- Generated knowledge pages remain `draft` until a separate current-fork review satisfies the reviewed-content contract.
- The generator is explicit, offline, path-contained, deterministic, and never invoked by normal dev/test/verify/build commands.
- The offline artifact remains at or below 5.8 MB.
- Do not commit, push, clean, or include unrelated dirty workspace state.
- Execute inline in this session because the user requested implementation and did not request agent delegation.

## File Map

| Path | Change | Responsibility |
|---|---|---|
| `Wiki/scripts/document-content-contract.mjs` | Modify | Validate reader groups, navigation fields, feature keys, logical parents, lifecycle statistics, migration ledger, crosswalk, and materialized-page drift. |
| `Wiki/scripts/document-content-contract.test.mjs` | Modify | Repository and fixture RED/GREEN tests for exact groups, feature surface, dual-axis directory source, lifecycle counts, and catalog generation. |
| `Wiki/scripts/knowledge-content-migration.test.mjs` | Create | Isolated tests for ledger inventory, path containment, deterministic generation, hashes, stale detection, and crosswalk targets. |
| `Wiki/scripts/generate-knowledge-pages.mjs` | Create | Explicit generator for project-owned Markdown draft tiddlers. |
| `Wiki/content-migration.json` | Create | Exactly one non-destructive action for each of the seventy-three host knowledge sources. |
| `Wiki/hazelight-public-doc-crosswalk.json` | Create | Exact fifteen public Script Features to local logical keys. |
| `Wiki/package.json` | Modify | Add `generate:knowledge-pages` and include migration tests in `test:document-content`. |
| `Wiki/wiki/tiddlers/docs/navigation/*.tid` | Create | Seven neutral reader-group definitions. |
| `Wiki/wiki/tiddlers/docs/DocumentationDirectory.tid` | Modify | Primary reader-capability atlas and secondary topic/depth directory. |
| `Wiki/wiki/tiddlers/as/navigation.tid` | Modify | Two-level sidebar group → direct formal-tiddler navigation. |
| `Wiki/wiki/tiddlers/docs/ReaderDirectoryStyles.tid` | Create | Scoped route-rail, status, responsive, focus, and print styling using existing theme tokens. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/generated-knowledge/*.tid` | Generate | Twenty-nine generator-owned rich draft pages from `Syntax_*` and `AS_*`. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/language/*.tid` | Create/modify | Reviewed beginner fundamentals plus preserved language landing. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/unreal-core/*.tid` | Create/modify | Reviewed first Actor/Blueprint path and practical Actor/components/functions/subsystems pages. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/unreal-language/*.tid` | Create/modify | FName and C++/Blueprint differences plus metadata-driven feature catalog and route links. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/bindings-uht-extensions/*.tid` | Create/modify | C++ Usage and Bindings task pages plus the preserved UHT implementation sequence. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/compile-module-preprocessor/editor-only-script.tid` | Create | Practical editor/cooked conditions page. |
| `Wiki/wiki/tiddlers/docs/zh-Hans/testing-diagnostics-release/script-tests.tid` | Create | Practical script-test entry page. |
| `Wiki/tests/playwright/product/document/reader-capability-directory.spec.ts` | Create | Browser coverage for groups, direct feature links, statuses, secondary topics, keyboard, and mobile containment. |
| `Wiki/tests/playwright/product/document/document-content-foundation.spec.ts` | Modify | Update the old topics-only directory expectation without weakening preserved foundation coverage. |
| `Wiki/Agents_ZH.md` | Modify first | Author contract for reader navigation, migrations, reviewed content, and Hazelight reference boundaries. |
| `Wiki/Agents.md` | Modify second | English mirror of the reviewed Chinese author contract. |
| `openspec/changes/docs-wiki-content-expansion/migration-evidence.md` | Create | Human-readable seventy-three-source action summary, artifact metrics, and reviewed-page evidence. |

---

### Task 1: Extend the source contract for dual-axis navigation

**Files:**
- Modify: `Wiki/scripts/document-content-contract.test.mjs`
- Modify: `Wiki/scripts/document-content-contract.mjs`

**Interfaces:**
- Consumes: existing `parseTidSource`, `collectDocumentSources`, and `validateDocumentContent`.
- Produces: registered reader groups, validated `as-nav-group`, `as-nav-order`, `as-nav-parent`, `as-feature-key`, and lifecycle statistics.

- [ ] **Step 1: Add failing fixture tests**

Add fixture tests that assert diagnostics for unknown group, nonpositive reader order, duplicate feature key, missing logical parent, and reader metadata on a non-formal record. Add a valid fixture with:

```text
as-nav-group: script-features
as-nav-order: 10
as-nav-parent: unreal-language/index
as-feature-key: uproperty
```

- [ ] **Step 2: Add failing repository tests**

Require the exact seven `ASWiki/ReaderNav` group tiddlers, their numeric order, unique feature identities, separate lifecycle counts, and direct concrete pages for the six ordinary-language keys and eighteen Unreal feature keys listed in the spec.

- [ ] **Step 3: Run RED**

Run:

```powershell
pnpm run test:document-content
```

Expected: FAIL with missing reader groups/navigation fields/required feature documents, not a parser or fixture error.

- [ ] **Step 4: Implement minimum validation**

Add:

```js
const readerNavigationGroups = new Set([
  'getting-started',
  'language-basics',
  'script-features',
  'unreal-development',
  'bindings-extensions',
  'workflow-validation',
  'internals-reference',
]);
```

Validate positive `as-nav-order`, existing `as-nav-parent` against logical keys, unique `as-feature-key`, reader-group tiddler separation, and statistics:

```js
contentStatuses: {
  placeholder,
  draft,
  reviewed,
  published,
  completed: reviewed + published,
}
```

- [ ] **Step 5: Run focused GREEN**

Run `pnpm run test:document-content`.

Expected: fixture validation tests pass; repository tests remain RED only for missing product tiddlers/data introduced in later tasks.

### Task 2: Add the complete knowledge ledger and Hazelight public crosswalk

**Files:**
- Create: `Wiki/content-migration.json`
- Create: `Wiki/hazelight-public-doc-crosswalk.json`
- Create: `Wiki/scripts/knowledge-content-migration.test.mjs`
- Modify: `Wiki/package.json`

**Interfaces:**
- Consumes: `Documents/Knowledges/ZH/*.md` and local formal document keys.
- Produces: a one-record-per-source ledger and exact fifteen-entry public crosswalk.

- [ ] **Step 1: Write ledger/crosswalk tests**

Tests enumerate the live host directory and require exact set equality with ledger `source` values. They validate actions against:

```js
new Set(['materialize', 'merge', 'retain', 'defer'])
```

They require nonempty `destinationKeys` and `reason`, exactly seventeen `Syntax_*` plus twelve `AS_*` materialized records, and the exact fifteen public feature names from the spec.

- [ ] **Step 2: Run RED**

Run:

```powershell
node --test scripts/knowledge-content-migration.test.mjs
```

Expected: FAIL because both JSON inputs are absent.

- [ ] **Step 3: Write all seventy-three migration decisions**

Map:

- every `Syntax_*` and `AS_*` file to `materialize`;
- `Guide_*` to practical merged destinations;
- `Type_*`, `RT_*`, `Arch_*`, and `Test_*` to merged/deferred topic destinations;
- `Diff_*` to comparison destinations;
- `Note_*`, `Index.md`, and `Rule.md` to retained/merged destinations with explicit reasons.

No record may use `TBD`, `TODO`, or an empty destination.

- [ ] **Step 4: Write the fifteen-entry public crosswalk**

Store upstream name, URL, and local destination keys. Validate only public `https://angelscript.hazelight.se/` URLs and logical keys; copy no body/media.

- [ ] **Step 5: Add the test to the product command**

Set:

```json
"test:document-content": "node --test scripts/document-content-contract.test.mjs scripts/document-resolution.test.mjs scripts/knowledge-content-migration.test.mjs"
```

- [ ] **Step 6: Run GREEN**

Run `pnpm run test:document-content`.

Expected: ledger/crosswalk tests pass; repository feature/page tests remain RED pending materialization.

### Task 3: Implement deterministic knowledge-page generation

**Files:**
- Create: `Wiki/scripts/generate-knowledge-pages.mjs`
- Modify: `Wiki/scripts/knowledge-content-migration.test.mjs`
- Modify: `Wiki/package.json`
- Generate: `Wiki/wiki/tiddlers/docs/zh-Hans/generated-knowledge/*.tid`

**Interfaces:**
- Consumes: materialize records from `content-migration.json`.
- Produces: deterministic `.tid` text, source/hash metadata, and `generateKnowledgePages({ projectRoot, wikiRoot, write })`.

- [ ] **Step 1: Add failing generator tests**

Use a temporary fixture root to assert:

- traversal such as `../secret.md` is rejected;
- non-`Syntax_*`/`AS_*` materialization without explicit allowed metadata is rejected;
- CRLF/LF normalize to identical output;
- SHA-256 changes with body content;
- only the generator-owned output directory is replaced;
- dry-run returns deterministic file objects and performs no writes.

- [ ] **Step 2: Run RED**

Run `node --test scripts/knowledge-content-migration.test.mjs`.

Expected: FAIL because `generateKnowledgePages` does not exist.

- [ ] **Step 3: Implement the generator**

Use only Node standard-library `fs`, `path`, `crypto`, and `url`. Export the callable function and gate CLI execution with `import.meta.url`. Generate headers containing formal fields, navigation fields, `as-migration-source`, and `as-migration-sha256`, followed by:

```markdown
> [!NOTE]
> 本页由项目自有知识文档迁移为草稿。内容丰富不代表已经按当前 UE 5.7 fork 完成技术审阅；请以页面状态、当前源码和测试证据为准。
```

- [ ] **Step 4: Add explicit package command**

Add:

```json
"generate:knowledge-pages": "node scripts/generate-knowledge-pages.mjs"
```

Do not add it to any predev, pretest, preverify, or prebuild hook.

- [ ] **Step 5: Verify RED/GREEN and generate**

Run:

```powershell
node --test scripts/knowledge-content-migration.test.mjs
pnpm run generate:knowledge-pages
pnpm run test:document-content
```

Expected: generator tests and materialized-page contract pass; remaining RED failures identify only missing reader groups/hand-authored pages/directory.

### Task 4: Add reader groups and required hand-authored pages

**Files:**
- Create: `Wiki/wiki/tiddlers/docs/navigation/*.tid`
- Create/modify the practical Chinese pages in the File Map.
- Modify: `Wiki/scripts/document-content-contract.test.mjs`

**Interfaces:**
- Consumes: exact nav-group keys and logical feature keys from specs.
- Produces: all direct primary-directory targets, including four reviewed initial-path pages.

- [ ] **Step 1: Add repository assertions for reviewed shape**

Require `start/index`, `language/basic-types-variables`, `language/functions-control-flow`, and `unreal-core/first-actor-blueprint` to be Chinese `reviewed`, have positive revisions, contain code/procedure markers where applicable, and cite registered local sources.

- [ ] **Step 2: Run RED**

Run `pnpm run test:document-content`.

Expected: missing group/page and placeholder-lifecycle failures.

- [ ] **Step 3: Add the seven neutral reader-group tiddlers**

Each tiddler uses:

```text
tags: ASWiki/ReaderNav
as-nav-key: <key>
as-order: <1-7>
caption: <Chinese caption>
description: <reader outcome>
```

It must not contain formal-document lifecycle/depth fields.

- [ ] **Step 4: Write the five ordinary-language pages**

Create separate WikiText pages for types/variables, functions/control flow, classes/inheritance/interfaces, handles/references/casts, and containers/enums. Use runnable code blocks and direct links to generated syntax/compiler/runtime drafts. Mark only the first two reviewed after local evidence checks; keep the other three draft.

- [ ] **Step 5: Rewrite the Getting Started landing and add first Actor path**

Replace the placeholder skeleton with current-fork setup boundaries, the exact `Script/` location, one minimal `AActor`, expected Editor/save behavior, Blueprint child interaction, verification steps, and links. Promote both pages to reviewed revision `1` only after browser/source checks.

- [ ] **Step 6: Add the remaining practical pages**

Add Actors/Components/defaults, Function Libraries, FName literals, editor-only/cooked script, Subsystems, Script Tests, and C++/Blueprint differences. Use `draft` unless the page meets every reviewed requirement.

Add automatic binding, exposure metadata, C++ `ScriptMixin`, manual Bind, call-path/limit, and binding-diagnostics pages. Keep them as direct second-level entries in `bindings-extensions`; the UHT sequence follows them rather than replacing them.

- [ ] **Step 7: Add reader metadata to every existing foundation page**

Add group/order metadata to every Chinese formal document, including Hot Reload, integration, UHT, debugging/testing, runtime, architecture, reference, and Showcase landings, without changing logical keys or falsely promoting lifecycle. Validation requires exact set equality between Chinese formal documents and primary-navigation entries.

- [ ] **Step 8: Run source GREEN**

Run `pnpm run test:document-content`.

Expected: exact group/feature/initial-reviewed-path contracts pass.

### Task 5: Implement the dual-axis directory and generated feature catalog

**Files:**
- Modify: `Wiki/tests/playwright/product/document/document-content-foundation.spec.ts`
- Create: `Wiki/tests/playwright/product/document/reader-capability-directory.spec.ts`
- Modify: `Wiki/wiki/tiddlers/docs/DocumentationDirectory.tid`
- Create: `Wiki/wiki/tiddlers/docs/ReaderDirectoryStyles.tid`
- Modify: `Wiki/wiki/tiddlers/docs/zh-Hans/unreal-language/feature-catalog.tid`
- Modify: `Wiki/wiki/tiddlers/as/navigation.tid`

**Interfaces:**
- Consumes: reader group tiddlers and formal-document metadata.
- Produces: `.as-doc-reader-directory`, `.as-doc-system-directory`, direct feature links, text status chips, and metadata-driven catalog.

- [ ] **Step 1: Write failing browser tests**

Test exact seven group captions, all current Chinese formal documents represented exactly once as second-level direct links, visible `UPROPERTY`, `TArray`, `函数与控制流`, and `第一个 Actor` links, textual lifecycle labels, reviewed/total summary, preserved fifteen-topic secondary view, direct link targets, 375 px containment, and visible keyboard focus in both the page directory and left navigation.

- [ ] **Step 2: Update the old directory expectation**

Replace the old assertion that `.as-doc-directory-entry` has exactly fifteen primary entries with two assertions:

- seven primary reader groups;
- fifteen secondary topic entries in original order.

Keep all locale, compatibility, Internals, Hazelight, integration, Showcase, and source-excerpt assertions unchanged.

- [ ] **Step 3: Run browser RED**

Run:

```powershell
pnpm run test:feature document
```

Expected: new dual-axis selectors/content fail while unrelated document tests remain green.

- [ ] **Step 4: Implement semantic WikiText**

Render group headings and direct document lists with nested `$list` filters using `as-nav-group` and `as-nav-order`. Render the secondary topic view with native `<details>/<summary>`, actual documents, depth, and lifecycle text. Do not use raw script, inline event handlers, or persisted tiddler writes.

- [ ] **Step 5: Add scoped responsive styles**

Use existing `--as-*` tokens and TiddlyWiki palette values. Implement the route rail with borders/order markers, 44 px minimum link block height, visible `:focus-visible`, one-column mobile behavior, print-safe disclosure, and `prefers-reduced-motion` containment.

- [ ] **Step 6: Replace the handwritten feature list**

Make `feature-catalog.tid` query `ASWiki/Docs/unreal-language` formal documents with `as-feature-key`; display title/description/depth/status and preserve its existing logical key.

- [ ] **Step 7: Run browser GREEN**

Run `pnpm run test:feature document`.

Expected: both directory specs and all existing document-domain tests pass.

### Task 6: Update author guidance and migration evidence

**Files:**
- Modify first: `Wiki/Agents_ZH.md`
- Modify second: `Wiki/Agents.md`
- Create: `openspec/changes/docs-wiki-content-expansion/migration-evidence.md`
- Modify: `openspec/changes/docs-wiki-content-expansion/tasks.md`

**Interfaces:**
- Consumes: implemented fields, generator, ledger, review criteria, and commands.
- Produces: reproducible author/maintainer workflow and evidence.

- [ ] **Step 1: Update Chinese guidance**

Document the two navigation axes, exact reader fields/groups, feature-key uniqueness, reviewed-content minimum, generated-draft boundary, explicit generator command, ledger actions, Hazelight public/reference boundary, and verification commands.

- [ ] **Step 2: Update English guidance**

Mirror the reviewed Chinese contract without inventing English article bodies.

- [ ] **Step 3: Write migration evidence**

Record exact source/action counts, materialized file count/bytes/hashes, reviewed/draft/placeholder/published counts, Hazelight crosswalk coverage, artifact size, test commands, and known unrelated baseline failures. Do not describe a draft as reviewed.

- [ ] **Step 4: Mark tasks truthfully**

Check only work actually implemented and verified. Leave any incomplete content/verification item unchecked and keep the change active.

### Task 7: Run complete scoped verification

**Files:**
- Verify all changed files and OpenSpec artifacts.

**Interfaces:**
- Consumes: completed implementation.
- Produces: fresh evidence for completion or an explicit list of remaining failures.

- [ ] **Step 1: Run source and type checks**

```powershell
pnpm run test:document-content
pnpm run test:multilingual
pnpm run test:source-boundaries
pnpm run check
pnpm run lint
pnpm run lint:vendors
```

- [ ] **Step 2: Run browser/runtime checks**

```powershell
pnpm run test:feature document
pnpm run test:feature sidebar
pnpm run test:runtime
pnpm run test:artifact-server
```

- [ ] **Step 3: Build and verify the offline artifact**

```powershell
pnpm run build:wiki
pnpm run test:artifact
```

Measure `Wiki/dist/index.html`; require at most `5,800,000` bytes. Confirm raw plugin corpus and non-materialized host knowledge are absent.

- [ ] **Step 4: Validate OpenSpec and diffs**

```powershell
openspec validate docs-wiki-content-expansion --strict
git -C Wiki diff --check
git diff --check
git -C Wiki status --short
git status --short
```

- [ ] **Step 5: Reconcile requirements**

Read every requirement/scenario in all four delta specs and point to a passing test, rendered page, ledger entry, or recorded limitation. Do not archive while a required scenario or checklist item remains incomplete.
