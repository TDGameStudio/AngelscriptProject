## Why

AngelscriptWiki currently has no durable, discoverable set of Markdown and WikiText examples that can be used to inspect theme changes against representative rendered content. Markdown More configuration tiddlers are retained from a reference wiki, but the runtime plugin itself is not source-managed or enabled.

## What Changes

- Import the current upstream `tw-markdown-more` source into the Wiki vendor boundary and enable it through the existing external-plugin source bridge.
- Keep the Markdown More table of contents disabled while retaining the extension's other rendered surfaces.
- Expand the rendered-only Markdown baseline from a small sample into comprehensive basic and extension showcase tiddlers, while retaining a separately focused Markdown More page and WikiText page. Keep a separate syntax-showcase directory tiddler that links to rather than mixes those syntax families.
- Add regression coverage for the imported source, runtime configuration, showcase rendering, and narrow-screen containment.
- Move browser test source outside the runtime tiddler tree so development coverage does not pollute reader-facing Wiki lists. The visibility classification of existing `.tid` code examples and fixtures remains a separate future decision.
- Move the fluid-fixed desktop sidebar to the left, retain a compact left-top show/hide control, and provide a local left-edge resize rail without changing the source-managed vendor resizer.
- Record source provenance, maintenance rules, and the no-publish constraint in Wiki documentation.

## Capabilities

### New Capabilities

- `wiki-syntax-showcase`: Persistent rendered Markdown and WikiText showcase tiddlers for visual and syntax regression checks.
- `wiki-markdown-more-source-integration`: Source-managed Markdown More runtime integration through the Wiki external-plugin manifest.
- `wiki-left-sidebar-layout`: Left-side fluid-fixed Wiki navigation, accessible compact sidebar toggle, and unconstrained local desktop resize behavior.

### Modified Capabilities

- `wiki-document-experience-integration`: Markdown More becomes an enabled runtime document-experience plugin while its in-page table of contents remains disabled.

## Impact

- Affects `Wiki/vendor/`, `Wiki/external-plugins.json`, the generated plugin-source bridge, wiki configuration tiddlers, example content tiddlers, Playwright coverage, and Wiki maintenance documentation.
- Adds the MIT-licensed `cdruan/tw-markdown-more` source snapshot at the current upstream `main` commit.
- Does not add public APIs, does not add a homepage entry, does not publish any plugin package, and does not add Markdown source panels or source/render comparison layouts to the Wiki pages.
