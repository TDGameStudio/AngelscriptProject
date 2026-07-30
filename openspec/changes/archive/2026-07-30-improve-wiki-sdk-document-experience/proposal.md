## Why

The Wiki theme is visually close to the desired light direction, but desktop controls, navigation, long-form reading, command-palette defaults, and code-example ergonomics still behave like separate features rather than one professional SDK documentation surface. The current desktop breakpoint is also emitted as an unexpanded WikiText macro, so intended control hit targets are silently discarded by the browser, while the Notion cover/icon surface adds blog-oriented author chrome that is not useful for this SDK Wiki.

## What Changes

- Make desktop hover, pressed, selected, and keyboard-focus states consistent, accessible, and visually distinct without darkening the existing light palette.
- Preserve the original localized TiddlyWiki Open / Recent / Tools / More sidebar layout, add a separate language-aware AS documentation-outline tab without making it the default or restoring an in-page TOC, restore the reference Wiki's wide compact desktop geometry through a bounded responsive width, and add friendly document titles, breadcrumbs, a restrained one-sentence description line, and readable prose width.
- Restore the RefWiki page-control toolbar's natural compact icon geometry and canonical visibility configuration while keeping only the documentation-relevant Home, More actions, control panel, and language controls.
- Replace the low-contrast dark “untagged” control in the core More sidebar with a restrained light blue-grey semantic treatment.
- Keep the desktop sidebar resize affordance full-height while Tools content scrolls, and separate its forgiving pointer hit area from a restrained one-pixel visual rail.
- Make an empty command palette show useful document/history choices; reserve the full syntax guide for explicit `?` help mode.
- Remove the `notionpage-covericon` plugin, its author controls, source bridge, documentation, and regression fixtures while preserving TiddlyWiki core icons and the separate draw.io plugin.
- Add an author-controlled `maxVisibleLines` AngelScript code-card viewport for long selected source ranges, with internal scrolling and a thin low-contrast scrollbar.
- Give AngelScript code-copy actions visible success feedback while preserving the original source and highlighting behavior.
- Fix stale or missing home-page links and document the resulting author-facing conventions.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript-wiki-theme`: Add testable desktop interaction states and professional long-form document presentation.
- `wiki-document-experience-integration`: Preserve the localized core sidebar layout plus a dedicated AS documentation outline, add a command-palette navigation state, strengthen SDK title/description hierarchy, omit an in-page TOC, and remove the cover/icon runtime surface.
- `tw-angelscript-tools`: Strengthen visible copy feedback and add an author-controlled bounded viewport for long AngelScript source ranges.

## Impact

The change affects the Wiki configuration and theme plugins, the tracked command-palette and sidebar-resizer sources, AngelScript code-card widget/styles, selected WikiText documentation tiddlers, the external-plugin manifest and bridge assertions, Playwright coverage, generated plugin artifacts, and the Wiki authoring guide. It removes one runtime plugin, introduces no network dependency, preserves draw.io, and does not change the AngelScript runtime plugin or Unreal Engine modules.
