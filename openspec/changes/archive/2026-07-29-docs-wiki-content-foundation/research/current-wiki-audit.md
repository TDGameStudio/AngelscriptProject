# Current Wiki Content and Authoring Audit

Captured: 2026-07-25

## 1. Reader content

The current formal content is intentionally small:

- `AngelscriptWikiHome`
- `AS/Navigation`
- `AS/Status`
- `AS/ThemeRoadmap`
- four AS workflow pages
- two maintainer pages
- one Showcase index
- four primary Markdown/WikiText Showcase pages

The home and AS navigation currently divide links into “users” and “plugin maintainers”. This is a useful audience cue, but it is not a scalable information architecture for the full language, runtime, tooling, binding, optional-plugin, and maintainer surface.

The AS navigation is a hard-coded set of local procedures and links. A larger documentation system needs metadata-driven topic ordering and locale resolution while retaining the existing tab and compatibility links during migration.

## 2. Current bilingual behavior

Existing formal pages commonly keep Chinese and English in one tiddler and select a block from `$:/language`. This works for short pages and maintains one title, but it creates several problems for 500–1600-line source articles:

- both bodies must be reviewed together;
- translation status cannot be represented independently;
- English can appear current after Chinese changes;
- source files become very large;
- Chinese-first completion is difficult to express without a conditional placeholder.

The in-progress toolchain/multilingual change establishes:

- supported locales `zh-Hans` and `en-GB`;
- Chinese product default;
- bilingual UI/lingo authoring paths;
- en-GB fallback for missing product-specific UI values.

The documentation foundation keeps those UI rules and defines a separate article lifecycle: formal documents are paired, and missing English article bodies fall back to the reviewed Chinese page with an explicit notice.

## 3. Existing document identity

SDK-style pages use:

```text
caption
description
as-sdk-document: yes
```

The local theme presents `caption` as the reader-facing title, `description` before tags/body, and keeps the stable tiddler title as canonical identity. The new metadata contract extends this shape; it does not replace `caption`, `description`, or `as-sdk-document`.

## 4. Existing code and document presentation

Available product capabilities:

- official TiddlyWiki Highlight runtime;
- project-owned UE AngelScript grammar;
- ordinary `$codeblock` support;
- `$angelscript-code` line numbers, starting line, highlighted lines, selected ranges, and bounded visible-line viewport;
- code-copy feedback;
- Fira Code;
- Markdown and Markdown More rendering;
- WikiText procedures, filters, transclusion, widgets, and tables;
- Draw.io diagrams with offline saved-SVG viewing;
- responsive shell, keyboard focus, reduced-motion rules, and product Playwright tests.

These capabilities are enough for the first Base and Pattern catalogs. Heavy AST/VM/Canvas/WASM work belongs to Lab and must not be added to the initial page path.

## 5. Existing Showcase content

Reader-facing primary pages:

- `语法展示范式`
- `Markdown 基础示例`
- `Markdown 扩展语法示例`
- `Markdown More 示例`
- `TiddlyWiki 语法示例`

Additional AngelScript code examples exist under `wiki/tiddlers/tests/playwright`. Most use hidden `$:/tests/TDGameStudio/AngelscriptWiki/...` titles, but `AngelscriptCodeExamples` has an ordinary title and reader-facing caption/description even though it lives in the test-fixture directory. The future implementation must explicitly decide whether to:

1. move a reviewed reader-facing copy to `wiki/tiddlers/showcase/base/`;
2. keep only hidden `$:/tests/...` fixtures under the test directory; and
3. maintain one source of content for browser tests rather than duplicating the examples.

The completed `feature-wiki-syntax-showcase` change intentionally limited the first showcase to rendered examples and excluded source/render tutorials and homepage navigation. The new showcase capability expands that earlier scope without invalidating its existing pages.

The current WikiText page contains one procedure, one filtered list, one transclusion, and temporary widget state. It does not yet provide a dedicated procedure/function/legacy-macro contract, a trusted-HTML authoring baseline, or a deterministic iframe/local-external embed baseline. Those explicit gaps are B13–B15, with reusable P15/P16 patterns and the L11 security/packaging experiment recorded in `tiddlywiki-expression-showcase.md`.

## 6. Current tags and tag color behavior

Current content tags include:

- `ASWiki/Home`
- `ASWiki/Navigation`
- `ASWiki/Status`
- `ASWiki/Theme`
- `ASWiki/Workflow`
- `ASWiki/Maintainer`

These are flat audience/page-role buckets rather than a scalable subject taxonomy. The approved foundation decision is to retire all six:

- `ASWiki/Home` and `ASWiki/Navigation` become `as-page-role: home` and `as-page-role: navigation`;
- `ASWiki/Workflow`, `ASWiki/Maintainer`, and `ASWiki/Status` map per page to an actual `ASWiki/Docs/<topic-key>`;
- `ASWiki/Theme` becomes `as-page-role: project-meta` unless an individual page is rewritten as a genuine Showcase entry.

The `AngelscriptWikiHome` title remains referenced by `src/angelscript-wiki-config/config/default-tiddlers.tid`, theme CSS, and several Playwright tests. Removing its tag does not require renaming its title. A future route rename must preserve the default entry and update those explicit consumers in a separate compatibility step.

The current tag-color startup module:

- reads the native `color` field from the actual tag tiddler;
- validates CSS color support;
- applies a scoped CSS custom property to existing TiddlyWiki tag labels;
- leaves uncolored tags neutral;
- preserves TiddlyWiki tag ownership and popup behavior.

The documentation taxonomy can reuse this capability. It must not add a competing tag component or encode color in ordinary article metadata.

## 7. Content/source boundary findings

- Articles, examples, navigation, and site configuration belong under `Wiki/wiki/tiddlers`.
- Reusable runtime behavior belongs under a local plugin in `Wiki/src`.
- Test fixtures must use `$:/tests/TDGameStudio/AngelscriptWiki/...` titles and live separately from Playwright source.
- Playwright tests belong under `Wiki/tests/playwright/product`.
- Generated `.generated/`, `dist/`, reports, and comparison artifacts are not editable product sources.
- The Wiki does not execute AngelScript or load Unreal plugin modules in the browser. Any future live data must use an explicit offline data or service boundary.

## 8. Foundation gaps

The current Wiki does not yet provide:

- a complete topic hierarchy;
- stable per-document depth and lifecycle metadata;
- paired long-form translations;
- locale-aware logical document links;
- translation revision/stale detection;
- useful module-feature placeholders;
- a source inventory/registry;
- a complete source-to-topic migration crosswalk;
- a special-topic packaging classification;
- an extensive Base/Pattern/Lab showcase catalog;
- content-contract validation for the above.
- a validated migration away from the six legacy `ASWiki/*` audience/page-role tags.

These gaps belong to this foundation. Theme redesign, exact colors, new heavy visualization runtimes, publishing, and plugin-runtime changes do not.
