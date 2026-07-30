## Why

The migrated Wiki theme is close to the desired Notion-like document experience, but generic code and the custom `as-code` widget still use separate highlighting paths and incompatible visual chrome. The Wiki also needs repository-maintained UE AngelScript syntax support, author-controlled line presentation, and a small PC-first accessibility and spacing pass to reach a professional SDK-document baseline.

## What Changes

- Register a repository-maintained UE AngelScript language definition in the bundled TiddlyWiki Highlight.js pipeline.
- Apply the classic Tomorrow light token palette used by the reviewed RefWiki to all highlighted languages.
- **BREAKING** remove the private `as-code` widget, tokenizer, and `as-code-token--*` class contract; repository content has no production callers to migrate.
- Add an AngelScript-specific `angelscript-code` widget that follows the core `code` attribute convention and adds source-range, displayed-line-number, and highlighted-line controls.
- Add the same accessible copy action to ordinary core code blocks and enhanced examples.
- Refine the existing fixed-light theme on desktop without replacing its right sidebar, zoomed story view, or Notion-like document structure.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript-wiki-theme`: make classic Tomorrow the unified code palette and require visible focus, readable muted UI text, and consistent PC code surfaces while preserving the migrated layout.
- `tw-angelscript-tools`: replace the private AngelScript renderer with an official Highlight.js language module, an `angelscript-code` presentation widget, author-controlled line presentation, and shared copy behavior.

## Impact

- Wiki submodule: `src/angelscript-theme`, `src/angelscript-tools`, Playwright fixtures/tests, and author documentation.
- Public WikiText: `$as-code` is removed and `$angelscript-code code=...>` is introduced.
- Runtime dependencies remain unchanged: the implementation uses the bundled TiddlyWiki Highlight plugin and remains browser-only and offline-capable.
