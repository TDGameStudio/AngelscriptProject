# Wiki Comprehensive Markdown Showcase Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the Wiki's small Markdown sample into a comprehensive rendered-only visual regression baseline, add a separate rendered Markdown extension page, and keep Markdown More and WikiText isolated.

**Architecture:** Keep every syntax family in its own directly addressable tiddler. `MarkdownBasicShowcase.tid` contains common Markdown surfaces that are useful for theme review; the new `MarkdownExtendedShowcase.tid` isolates parser-supported extensions. `SyntaxShowcaseIndex.tid` remains a links-only directory, while Playwright asserts rendered DOM semantics and the absence of source tutorial panels.

**Tech Stack:** TiddlyWiki 5.4 tiddlers (`text/markdown`, `text/vnd.tiddlywiki`), the official TiddlyWiki Markdown renderer, the source-managed Markdown More plugin, Playwright, TypeScript, OpenSpec.

## Global Constraints

- The Wiki is the primary deliverable; source plugins are internal Wiki composition, not separately packaged artifacts.
- Do not run `build`, `build:library`, `build:examples`, `publish`, `publish:offline`, or any package-release command.
- All showcase pages render final content only: no Markdown source panel, no source/result split layout, and no authoring tutorial UI.
- `Markdown 基础示例`, `Markdown 扩展语法示例`, `Markdown More 示例`, and `TiddlyWiki 语法示例` remain separate tiddlers; `语法展示范式` only links to them.
- Use local/data-URI images rather than a network image so layout regression tests remain offline and deterministic.
- Do not touch user-owned screenshot files or `comparison-artifacts/` in `Wiki/`.

---

## File map

| Path | Responsibility |
| --- | --- |
| `Wiki/tests/playwright/product/syntax-showcase.spec.ts` | Browser regression contract for the four linked showcase pages and their rendered-only semantic surfaces. |
| `Wiki/wiki/tiddlers/examples/MarkdownBasicShowcase.tid` | Comprehensive rendered-only common Markdown visual baseline. |
| `Wiki/wiki/tiddlers/examples/MarkdownExtendedShowcase.tid` | New rendered-only parser-extension baseline. |
| `Wiki/wiki/tiddlers/examples/SyntaxShowcaseIndex.tid` | Markdown directory link to the new extension page, without transclusion. |
| `openspec/changes/feature-wiki-syntax-showcase/tasks.md` | Tracks the reopened comprehensive-baseline iteration. |
| `openspec/changes/feature-wiki-syntax-showcase/verification.md` | Keeps command results and preview evidence for this iteration. |
| `Wiki/tests/playwright/` | Browser test source kept outside the runtime TiddlyWiki tiddler tree. |

### Task 1: Define the browser regression contract (TDD RED)

**Files:**
- Modify: `Wiki/tests/playwright/product/syntax-showcase.spec.ts`
- Modify: `openspec/changes/feature-wiki-syntax-showcase/tasks.md`

**Interfaces:**
- Consumes: existing `openShowcase(page, title)` helper and a running preview at `http://127.0.0.1:8080`.
- Produces: failing tests for the new `Markdown 扩展语法示例` route, the additional directory link, and the expanded basic/extension rendered surfaces.

- [ ] **Step 1: Add the directory and basic-baseline expectations before editing tiddlers.**

  Add these expectations to the existing directory and official Markdown tests:

  ```ts
  await expect(frame.getByRole('link', { name: 'Markdown 扩展语法示例' })).toHaveCount(1);

  await expect(frame.locator('.tc-tiddler-body h4')).toBeVisible();
  await expect(frame.locator('.tc-tiddler-body h6')).toBeVisible();
  await expect(frame.locator('details')).toHaveCount(2);
  await expect(frame.locator('kbd')).toHaveCount(2);
  await expect(frame.locator('table')).toHaveCount(2);
  await expect(frame.locator('pre code')).toHaveCount(3);
  await expect(frame.locator('img')).toHaveCount(1);
  await expect(frame.locator('.tc-tiddler-body')).not.toContainText('Markdown 源码');
  ```

- [ ] **Step 2: Add a focused extension-page test before creating the tiddler.**

  Add a new test whose title is `renders Markdown extension surfaces without Markdown More containers` and use this body:

  ```ts
  const frame = await openShowcase(page, 'Markdown 扩展语法示例');

  await expect(frame.locator('.tc-tiddler-body h1')).toContainText('Markdown 扩展语法示例');
  await expect(frame.locator('mark')).toBeVisible();
  await expect(frame.locator('sup')).toBeVisible();
  await expect(frame.locator('sub')).toBeVisible();
  await expect(frame.locator('dl')).toBeVisible();
  await expect(frame.locator('abbr[title]')).toBeVisible();
  await expect(frame.locator('a.footnote-ref, sup.footnote-ref')).toBeVisible();
  await expect(frame.locator('img')).toHaveCount(1);
  await expect(frame.locator('li.checklist-item')).toHaveCount(0);
  await expect(frame.locator('div.admonition, details.admonition')).toHaveCount(0);
  await expect(frame.locator('.tc-tiddler-body')).not.toContainText('Markdown 源码');
  ```

- [ ] **Step 3: Run the focused regression test and capture the intentional RED result.**

  Run:

  ```powershell
  $env:PLAYWRIGHT_BASE_URL='http://127.0.0.1:8080'
  npm exec --yes pnpm@11.8.0 -- run test:playwright -- syntax-showcase.spec.ts
  ```

  Expected: FAIL because the new directory link and `Markdown 扩展语法示例` route do not exist and the basic page does not contain the comprehensive semantic surfaces yet.

### Task 2: Replace the basic sample with the rendered common-Markdown baseline (TDD GREEN)

**Files:**
- Modify: `Wiki/wiki/tiddlers/examples/MarkdownBasicShowcase.tid`
- Test: `Wiki/tests/playwright/product/syntax-showcase.spec.ts`

**Interfaces:**
- Consumes: the failing assertions from Task 1 and the local data-URI image already used by the current basic showcase.
- Produces: a deterministic `text/markdown` tiddler with common syntax only and no embedded source examples.

- [ ] **Step 1: Retain the tiddler header and replace its body with the common rendered baseline.**

  Preserve:

  ```tid
  title: Markdown 基础示例
  type: text/markdown
  ```

  The replacement body must include the following rendered-only sections, with Chinese explanatory copy rather than repeated `Markup:` source blocks:

  ```markdown
  # Markdown 基础示例

  ## 标题与文本层级
  ### 三级标题
  #### 四级标题
  ##### 五级标题
  ###### 六级标题

  ## 文本、链接与锚点
  这是 **粗体**、__另一种粗体__、*斜体*、_另一种斜体_、~~删除线~~ 与 `inline_code()`。
  [外部链接](https://tiddlywiki.com/) 与 [跳到表格](#table-check)。

  ## 引用与列表
  > 第一层引用。
  >
  > > 第二层引用。

  - 无序条目
    - 嵌套条目
  1. 有序步骤
     1. 嵌套步骤
  - [ ] 未完成检查项
  - [x] 已完成检查项
  ```

  Continue with three fenced blocks (`angelscript`, `cpp`, `html`), one indented code block, two tables (one standard and one left/center/right-aligned table carrying `<a id="table-check"></a>`), a separator, the existing local data-URI image, two plain HTML `details` blocks, two `<kbd>` keys, and an emoji line. Do not include literals such as `Markup:`, `Markdown 源码`, or source/result labels.

- [ ] **Step 2: Re-run the focused basic-page test.**

  Run the Task 1 command again. Expected: the basic-page assertions pass; the extension-page test remains red because its tiddler is not yet present.

### Task 3: Add the isolated rendered extension baseline and directory route (TDD GREEN)

**Files:**
- Create: `Wiki/wiki/tiddlers/examples/MarkdownExtendedShowcase.tid`
- Modify: `Wiki/wiki/tiddlers/examples/SyntaxShowcaseIndex.tid`
- Test: `Wiki/tests/playwright/product/syntax-showcase.spec.ts`

**Interfaces:**
- Consumes: Task 1's failing `Markdown 扩展语法示例` test and the existing official Markdown/Markdown More runtime configuration.
- Produces: a new `text/markdown` tiddler that verifies parser extensions but contains neither checklist nor Markdown More admonition syntax.

- [ ] **Step 1: Create the extension tiddler with the explicit title and supported extension syntax.**

  Start the file exactly as follows:

  ```tid
  title: Markdown 扩展语法示例
  type: text/markdown

  # Markdown 扩展语法示例
  ```

  Add rendered sections for `++插入文本++` / `==高亮文本==` / `H~2~O` / `19^th^`, two footnotes including one multi-paragraph definition, a definition list, inline `<abbr title="Hyper Text Markup Language">HTML</abbr>`, one reference-style link, and a reference-style image that points to the same deterministic data URI used by the basic page. The active Markdown parser does not register `markdown-it-abbr`, so do not present `*[HTML]: …` as a supported Markdown syntax contract. Do not include task-list syntax, `:::` admonitions, a source panel, or a second tiddler body.

- [ ] **Step 2: Add the extension link to the Markdown section of the directory tiddler.**

  Make the Markdown link group exactly:

  ```tid
  * [[Markdown 基础示例]]
  * [[Markdown 扩展语法示例]]
  * [[Markdown More 示例]]
  ```

- [ ] **Step 3: Run the focused showcase test to verify GREEN.**

  Run the Task 1 command. Expected: all tests in `syntax-showcase.spec.ts` pass, including the new extension page and the existing Markdown More/WikiText tests.

- [ ] **Step 4: If a required extension is not rendered by the installed parser, diagnose before changing content.**

  Inspect the generated DOM for the failing source syntax and the installed `tiddlywiki/markdown` plugin configuration. Keep the failure focused to one syntax at a time. Only replace a syntax form when the renderer demonstrably does not support it, and update the OpenSpec requirement/test to assert the verified semantic equivalent; do not add a new dependency or raw source panel to hide the unsupported form.

### Task 4: Verify the complete Wiki-only iteration and record it

**Files:**
- Modify: `openspec/changes/feature-wiki-syntax-showcase/tasks.md`
- Modify: `openspec/changes/feature-wiki-syntax-showcase/verification.md`
- Test: `Wiki/tests/playwright/product/syntax-showcase.spec.ts`

**Interfaces:**
- Consumes: the completed tiddlers and tests from Tasks 1–3.
- Produces: fresh verification evidence and a task record that remains active rather than archived.

- [ ] **Step 1: Run source/type/lint and browser verification without packaging.**

  Run from `Wiki/`:

  ```powershell
  npm exec --yes pnpm@11.8.0 -- run check
  npm exec --yes pnpm@11.8.0 -- run lint
  $env:PLAYWRIGHT_BASE_URL='http://127.0.0.1:8080'
  npm exec --yes pnpm@11.8.0 -- run test:playwright
  ```

  Expected: every command exits `0`; the Playwright report has zero failed tests. Do not run a package build, library build, examples build, or any publish command.

- [ ] **Step 2: Inspect the local preview at the four direct routes.**

  Check:

  ```text
  http://127.0.0.1:8080/#Markdown%20%E5%9F%BA%E7%A1%80%E7%A4%BA%E4%BE%8B
  http://127.0.0.1:8080/#Markdown%20%E6%89%A9%E5%B1%95%E8%AF%AD%E6%B3%95%E7%A4%BA%E4%BE%8B
  http://127.0.0.1:8080/#Markdown%20More%20%E7%A4%BA%E4%BE%8B
  http://127.0.0.1:8080/#TiddlyWiki%20%E8%AF%AD%E6%B3%95%E7%A4%BA%E4%BE%8B
  ```

  Verify visual hierarchy, table containment, code-block overflow, `details`, and footnote spacing. Do not make the pages homepage navigation.

- [ ] **Step 3: Record results and complete the OpenSpec checklist.**

  Mark tasks 6.2–6.5 as completed only after their corresponding evidence exists. Append dated command results, pass counts, route inspection notes, and the explicit no-package-build statement to `verification.md`.

- [ ] **Step 4: Commit only the Wiki and current OpenSpec iteration paths.**

  Stage only:

  ```powershell
  git -C Wiki add -- wiki/tiddlers/examples/MarkdownBasicShowcase.tid wiki/tiddlers/examples/MarkdownExtendedShowcase.tid wiki/tiddlers/examples/SyntaxShowcaseIndex.tid tests/playwright/product/syntax-showcase.spec.ts
  git -C Wiki commit -m '[Wiki] Feat: expand Markdown syntax showcase'
  git add -- Wiki openspec/changes/feature-wiki-syntax-showcase
  git commit -m '[Wiki] Feat: expand Markdown showcase baseline'
  ```

  Before each commit, inspect `git diff --cached --check` and `git diff --cached --name-only`; do not stage unrelated parent changes, screenshot artifacts, or generated files.

### Task 5: Separate browser test source from runtime Wiki content (TDD)

**Files:**
- Move: `Wiki/wiki/tiddlers/tests/playwright/*.spec.ts` → `Wiki/tests/playwright/product/*.spec.ts`
- Move: `Wiki/wiki/tiddlers/examples/playwright/*.spec.ts` → `Wiki/tests/playwright/examples/*.spec.ts`
- Modify: `Wiki/playwright.config.ts`
- Modify: `Wiki/package.json`
- Modify: `Wiki/Agents.md`, `Wiki/Agents_ZH.md`, `Wiki/README.md`, `Wiki/src/doc/tutorials/en/012-about-debugging.tid`, `Wiki/src/doc/tutorials/zh/012-about-debugging.tid`

**Interfaces:**
- Consumes: the current browser tests and their existing direct tiddler-title references.
- Produces: a `tests/playwright/` source-only test boundary, while existing `.tid` pages remain unchanged until their user-facing status is decided.

- [ ] **Step 1: Add failing source-boundary and browser assertions before moving files.**

  Extend the test coverage to assert that no `*.spec.ts` file remains below `wiki/tiddlers`, the Playwright runner reads `tests/playwright`, and the `More → All` runtime filter has no source-path title ending in `.spec.ts`.

- [ ] **Step 2: Move source, rename fixture titles, and update runner references.**

  Move product Playwright `*.spec.ts` source files to `tests/playwright/product/` and fixture/example Playwright source files to `tests/playwright/examples/` without changing their test content. Change the two Playwright configs to their respective directories and change `package.json` lint paths to `./tests/playwright`. Do not move, rename, tag, or hide existing `.tid` code examples or fixtures.

- [ ] **Step 3: Run focused browser tests, then update contribution guidance.**

  Run the moved focused test files against the local preview before and after the move. Document: never place Playwright source under `wiki/tiddlers`; use `tests/playwright`; the visibility and naming of runtime `.tid` pages is a separate content-design decision.

## Plan self-review

- **Spec coverage:** Task 1 covers direct discoverability and the rendered-only constraint; Task 2 covers the common Markdown baseline; Task 3 covers the separate parser-extension page and directory boundary; Task 4 covers full verification, local preview, OpenSpec evidence, and scoped commits.
- **Scope:** The plan does not alter Markdown More defaults, WikiText content, page-template drag/drop behavior, package artifacts, or homepage navigation.
- **Consistency:** Every test title, tiddler title, and filename uses the same `Markdown 扩展语法示例` / `MarkdownExtendedShowcase.tid` naming. The plan treats the preview server as an existing dev process and avoids any package build command.
