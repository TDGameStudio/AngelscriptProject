## Why

The desktop command palette currently inherits an 80%-viewport Algolia presentation that conflicts with AngelscriptWiki's restrained light document theme, while the right sidebar exposes a second search surface. The unused preview-glass integration also creates intrusive hover popups and remains in the runtime despite having no documentation value.

## What Changes

- Restyle the imported command-palette plugin source as a compact, centered, theme-aligned search surface; this repository intentionally owns its audited source snapshot and regression coverage.
- Hide the redundant Vanilla sidebar search through the command-palette configuration contract while retaining keyboard access to search.
- Keep narrow-screen behavior usable and overflow-free, with desktop polish remaining the priority.
- Remove preview glass from the external runtime manifest, generated-source bridge, product baseline, and documentation while retaining its imported upstream source for audit/reference purposes.
- Make product development watch the real local/imported plugin sources and incrementally mirror their file changes into the flat generated bridge so command-palette edits hot-reload without a manual prepare/restart cycle.
- Expand `AngelscriptCodeExamples` into a grouped SDK-oriented syntax gallery covering representative AngelScript language constructs and Unreal-specific reflection, delegate, asset, and networking extensions.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `wiki-document-experience-integration`: define the selected runtime plugin set without preview glass and require one compact, accessible, theme-aligned desktop search surface.
- `tw-angelscript-tools`: make directly opened `text/x-angelscript` source tiddlers render through the same Highlight.js grammar and Tomorrow Light surface as authored code blocks, and provide a representative syntax gallery for maintainers and SDK authors.

## Impact

- Wiki submodule: `external-plugins.json`, imported command-palette styles, local Wiki configuration, the development source watcher, product Playwright tests, external-source tests, and bilingual maintainer documentation.
- Runtime: preview-glass is no longer compiled or loaded; command palette and autocomplete remain imported at their audited source baseline.
- Author content and public WikiText APIs are unchanged.
