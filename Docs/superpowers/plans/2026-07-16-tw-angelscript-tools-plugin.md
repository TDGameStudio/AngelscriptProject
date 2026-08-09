# TiddlyWiki Angelscript Tools Plugin Implementation Plan

> **For agentic workers:** This plan is executed inline in the current workspace. The Wiki source is a git submodule; OpenSpec records stay in the parent repository.

**Goal:** Add a browser-only TiddlyWiki plugin that renders AngelScript examples as accessible, copyable, semantically highlighted documentation cards.

**Architecture:** `highlighter.ts` performs conservative lexical tokenization and HTML escaping. `index.ts` exposes an `AsCodeWidget` that consumes plain text children, builds the card DOM, and owns copy state. `index.css` provides the paper-and-graphite visual system without modifying TiddlyWiki core code blocks.

**Tech Stack:** TiddlyWiki 5.4, TypeScript, Modern.TiddlyDev, DOM APIs, Playwright.

## Global Constraints

- Keep the plugin under `Wiki/src/angelscript-tools/` and content/tests under `Wiki/wiki/tiddlers/`.
- Do not require Unreal Editor, port `27099`, Node filesystem APIs, or the VS Code LSP.
- Preserve source text exactly and HTML-escape all source before inserting it into the DOM.
- Follow TiddlyWiki widget lifecycle methods and add `.meta` metadata for the entry module.
- Validate with `pnpm run check`, `pnpm run lint`, `pnpm run build`, and `pnpm run test:playwright` from `Wiki/`.

---

### Task 1: Establish the failing widget contract

**Files:**
- Create: `Wiki/wiki/tiddlers/tests/playwright/AngelscriptCodeWidget.tid`
- Create: `Wiki/wiki/tiddlers/tests/playwright/angelscript-code.spec.ts`

**Interfaces:**
- Consumes: the future `$:/plugins/TDGameStudio/angelscript-tools` `as-code` widget.
- Produces: stable selectors `.as-code-card`, `.as-code-token--keyword`, `.as-code-line-number`, and `[data-copy-state]`.

- [x] Write the tiddler with a class, `UFUNCTION`, type, string, number, comment, and function call.
- [x] Write Playwright assertions for title, token class, line count, and copied state.
- [x] Run `pnpm exec playwright test wiki/tiddlers/tests/playwright/angelscript-code.spec.ts` and confirm the test fails because the widget is undefined.

### Task 2: Implement the tokenizer

**Files:**
- Create: `Wiki/src/angelscript-tools/highlighter.ts`

**Interfaces:**
- Produces: `highlightAngelScript(source: string): string`.
- Token classes: `as-code-token--keyword`, `as-code-token--type`, `as-code-token--macro`, `as-code-token--string`, `as-code-token--number`, `as-code-token--comment`, `as-code-token--function`, and `as-code-token--operator`.

- [x] Implement a left-to-right scanner that handles comments and strings before identifiers.
- [x] Escape `&`, `<`, `>`, `"`, and `'` in all emitted text.
- [x] Wrap only recognized tokens and leave unknown source unchanged.
- [x] Run the focused Playwright test after the widget is connected and verify semantic spans appear.

### Task 3: Implement the TiddlyWiki widget

**Files:**
- Create: `Wiki/src/angelscript-tools/plugin.info`
- Create: `Wiki/src/angelscript-tools/index.ts.meta`
- Create: `Wiki/src/angelscript-tools/index.ts`
- Create: `Wiki/src/angelscript-tools/index.css`

**Interfaces:**
- Widget invocation: `<$as-code language="angelscript" title="..." lineNumbers="yes" copy="yes">source</$as-code>`.
- Widget output: a `.as-code-card` with `.as-code-title`, `.as-code-line-number`, `.as-code-source`, and a labeled copy button.

- [x] Read `text` attribute first, otherwise flatten plain text child parse nodes.
- [x] Render title, toolbar, line numbers, and highlighted code using DOM APIs.
- [x] Copy the raw source and set `data-copy-state` to `copied` or `error` with an accessible status.
- [x] Implement `refresh` for changed attributes and `removeChildDomNodes` through standard widget cleanup.

### Task 4: Document and verify

**Files:**
- Create: `Wiki/src/angelscript-tools/readme.tid`
- Create: `Wiki/src/angelscript-tools/tree.tid`

- [x] Document the widget syntax and browser-only boundary in TiddlyWiki WikiText.
- [x] Run `pnpm run check`.
- [x] Run `pnpm run lint`.
- [x] Run `pnpm run build`.
- [x] Run `pnpm run test:playwright`.
