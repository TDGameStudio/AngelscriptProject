## Context

The Wiki already loads the official `tiddlywiki/markdown` plugin and keeps Markdown More configuration tiddlers for the former RefWiki package. The configured features remain inert because the runtime plugin is not loaded. Existing document plugins are source-managed in `Wiki/vendor/`, declared by `external-plugins.json`, validated, then copied to `.generated/plugin-sources/` for plugin-dev.

The user needs stable rendered examples to inspect style work, rather than a homepage navigation feature or source-and-render documentation tutorial.

## Goals / Non-Goals

**Goals:**

- Keep the current upstream Markdown More source auditable and editable under the existing vendor boundary.
- Preserve four independently searchable, rendered-only showcase pages: comprehensive basic Markdown, Markdown extension coverage, Markdown More, and WikiText, with a separate searchable `语法展示范式` directory tiddler.
- Establish DOM and responsive regression coverage for the surfaces most likely to reveal theme regressions.
- Retain the AngelscriptWiki local visual defaults: pastel admonitions and a disabled Markdown More table of contents.
- Prevent an accidental external file drop from opening the core Wiki importer during visual-review work.

**Non-Goals:**

- Do not add showcase links to the Wiki homepage or change existing SDK tiddler layout.
- Do not turn the rendered examples into a Markdown/WikiText authoring tutorial with duplicate source panels, side-by-side source/result comparisons, or embedded copyable Markdown source.
- Do not publish or package Markdown More externally.
- Do not automatically pull upstream updates during build, test, or normal development.

## Decisions

### Import the current upstream source as a fixed vendor snapshot

`Wiki/vendor/tw-markdown-more/` will contain the full upstream repository excluding Git metadata. `external-plugins.json` records the current `main` commit (`d95cd86d0b9646703d07185c4ec94a516d6466f6`) as its audited source baseline and exposes `plugins/cdr/markdown-more` through the existing source bridge. This keeps build inputs reproducible while making a future explicit upstream update straightforward.

The older RefWiki JSON export is not reused because it hides source provenance and is behind the current upstream implementation.

### Keep product defaults in the local configuration plugin

Upstream defaults remain upstream-owned. AngelscriptWiki overrides them in `src/angelscript-wiki-config`: pastel admonitions and `toc/enable = no`. This avoids editing vendor source for product policy while retaining a no-TOC document layout.

The user explicitly prefers an explicit import action over an importer that appears when a file is dropped during page inspection, but ordinary core drag-to-reorder behavior must remain available. The local configuration plugin therefore supplies a narrowly scoped `$:/core/ui/PageTemplate` override: it preserves the page container and all standard page-template content, but replaces the outer page-wide `$dropzone` with a plain layout container. `$:/config/DragAndDrop/Enable` remains unset, so core list and tag drag behavior retains its default enablement. Explicit import controls remain the supported import path.

### Separate rendered showcase pages by syntax family

The examples are separate tiddlers so a Markdown renderer issue, a Markdown More layout issue, and a WikiText/widget issue can be inspected independently. They are discoverable through stable titles and direct routes, not homepage navigation. `语法展示范式` is a directory-only tiddler: it groups stable links by syntax family but does not transclude content or put Markdown and WikiText inside one shared tabs/body layout. A single large tiddler would make visual regressions less attributable, while test-only content would not meet the user's discovery requirement.

### Use comprehensive rendered Markdown baselines, not source tutorials

The current `Markdown 基础示例` is a deliberately small surface check and does not offer enough coverage for theme and layout review. It will be expanded using the reference Wiki's `Markdown基础语法` and `TiddlyWiki-Markdown示例1` as a coverage baseline: heading forms and levels, emphasis variants, links and anchors, quotes, ordered/unordered/nested lists, tables and alignment, inline/indented/fenced code, images, task lists, separators, HTML `details`, keyboard keys, and emoji. A new `Markdown 扩展语法示例` will separately exercise parser-supported extended surfaces such as footnotes, definition lists, insertions, marks, subscripts, superscripts, and reference-style links/images, plus the inline-HTML abbreviation surface. The installed official Markdown parser does not load `markdown-it-abbr`, so `*[HTML]: ...` is deliberately not treated as a supported Markdown contract; the showcase uses `<abbr title="…">` to retain the relevant semantic styling check.

Both pages remain rendered-only. Their tiddler sources remain the authoritative implementation and may be inspected through normal Wiki editing or the repository, but the document view must not duplicate that source in panels or paired source/result sections. Markdown More remains a third, focused page for its own runtime widgets and containers; it is not used to inflate the basic Markdown baseline.

### Keep browser test source outside the runtime Wiki

The current `wiki/tiddlers/tests/playwright/` location causes every Playwright `.spec.ts` file to be loaded as an ordinary text tiddler with a filesystem-path title. The runtime's core `More → All` filter lists every non-system tiddler, so the test source becomes reader-visible. This is source-boundary leakage, not unfinished test output.

Browser test source will move to `Wiki/tests/playwright/`, and `playwright.config.ts` plus the local lint script will use that directory. Existing runtime `.tid` code examples and fixtures remain untouched in this iteration: some are current user-facing or homepage-linked content, and their visibility classification requires a separate user decision.

This avoids a global `AllTiddlers` filter override and fixes the underlying source-boundary leak without changing reader-facing list behavior or existing tiddler titles.

### Avoid automation writes from interactive checklist controls

Markdown More checklist widgets intentionally write back to the Markdown tiddler. Tests verify checked and unchecked initial states but do not toggle them. WikiText interaction uses `$:/temp` state so Playwright can verify it without mutating source content.

## Risks / Trade-offs

- [Upstream source changes after import] → The recorded commit and full vendor snapshot make the import reproducible; later updates require an explicit audit and manifest update.
- [Markdown More changes document layout] → The showcase browser tests assert that the extension surfaces render without an in-page TOC container, on both desktop and narrow viewports.
- [Vendor stylesheet conflicts with the local theme] → Preserve upstream first and add only narrowly scoped local overrides when a confirmed rendering conflict appears.
- [Interactive checklist dirtying a development wiki] → Regression tests never click it, and the showcase documents its intended interaction through its rendered state alone.
- [A syntax variant is accepted differently by the installed Markdown parser] → Add only surfaces verified by the rendered browser test; retain unsupported variants as source-level notes rather than displaying a misleading visual example.
- [Future test source is accidentally put beneath `wiki/tiddlers`] → Document the two-path convention in the Wiki contributor guidance and add a source-boundary regression test for the `tests/playwright/` location.
- [Core PageTemplate changes in a TiddlyWiki upgrade] → The local override mirrors the current v5.4 page-template structure and removes only the outer `$dropzone`; review that tiddler against the upstream template when upgrading the core runtime.

## Migration Plan

1. Add failing regression tests for the declared source, active plugin, configuration, and showcase routes.
2. Import and register the upstream source, then apply local configuration overrides.
3. Add content tiddlers and documentation, run tests in desktop and narrow viewports, and inspect the local development preview.
4. Roll back by removing the manifest entry and vendor directory, retaining the existing disabled TOC configuration, and deleting only the new showcase tiddlers and regression tests.

## Open Questions

None. The user selected latest upstream `main`, a disabled in-page TOC, rendered-only pages, no homepage entry, and no publication.
