## Context

`Wiki/` is a TiddlyWiki 5 submodule with local source plugins compiled by `tiddlywiki-plugin-dev`. The reference Wiki contains an itonnote-based document experience, but some referenced plugins only exist as compiled plugin tiddlers and several settings are distributed across theme, startup, and system tiddlers. The new repository must retain a reproducible source path without repeatedly fetching GitHub during ordinary development.

## Goals / Non-Goals

**Goals:**

- Make the local Angelscript theme, migrated from itonnote source, plus the Notion light palette the normal Wiki experience.
- Import selected external plugin source into the Wiki repository, retain an explicit audited upstream baseline record, and make it discoverable by standard build, dev, test, and publish commands.
- Preserve the TDGameStudio AngelScript code widget's behavior while visually aligning it to official Highlight output.
- Keep durable product defaults in TDGameStudio-owned configuration and browser-only behavior in TDGameStudio-owned tools.

**Non-Goals:**

- Enabling or vendoring `itonnote-plugin`, Kookma packages, graph/knowledge-management layouts, journals, calendar, whiteboard, sync, or other undecided legacy plugins.
- Porting personal data, old site identity, or the legacy `Mei` home page.
- Automatically updating upstream plugin commits.

## Decisions

### Import external plugin sources into the Wiki repository and compile from a generated source bridge

Each selected upstream repository is cloned through SSH at the reviewed baseline, then its source is imported beneath `Wiki/src/` alongside TDGameStudio-owned plugin sources and tracked as ordinary Wiki files. A tracked manifest records its repository URL, initial audited `baselineCommit`, repository path, plugin source directory, and expected plugin title. `scripts/prepare-external-plugin-sources.mjs` validates the imported source directory and title, then creates ignored copies beneath `.generated/plugin-sources/`; plugin-dev sees one flat source root containing local and selected external plugins.

This retains upstream source provenance through the manifest and Reference checkout, permits offline normal builds after the sources are imported, and makes local plugin changes ordinary Wiki Git changes. The bridge never fetches, resets, or changes an imported source. Copying into the disposable generated root avoids plugin-dev's directory-link TypeScript limitation while preserving the editable source.

### Migrate itonnote theme source into the local Angelscript theme

The reviewed itonnote source is copied into `src/angelscript-theme/` with internal theme titles rewritten to `$:/themes/angelscript`; the required Fira Code stylesheet is also bundled under that local theme. `angelscript-wiki-config` selects `$:/themes/angelscript` and `$:/palettes/Notion`, retains Chinese language, zoom view, disabled animation, and a 320px Vanilla sidebar width. The previous browser startup script is removed so dark OS preferences cannot select an alternate palette. The former dark Angelscript styling is replaced in place rather than retaining an upstream competing theme.

### Port only required itonnote-plugin behavior

`angelscript-wiki-config` owns stable page-control and preference tiddlers. `angelscript-tools` owns the small browser startup module that closes `$:/state/sidebar` after mobile navigation and the bottom page-control rendering/style behavior. The port intentionally does not reference notebook sidebar state or Kookma/TOC APIs, avoiding the deprecated `itonnote-plugin` dependency.

### Combine official Highlight with the custom AngelScript renderer

The bundled `tiddlywiki/highlight` plugin handles generic code blocks. `as-code` remains the specialized AngelScript renderer because Highlight.js lacks AngelScript syntax support and the widget already provides line numbers and copy UI. Its semantic token CSS maps to a Notion-compatible Highlight.js palette instead of replacing the tokenizer.

## Risks / Trade-offs

- [Clone availability and Windows path length] → Document SSH cloning with `core.longpaths=true`; validate source paths before building.
- [Upstream plugin changes] → `baselineCommit` preserves the initially reviewed reference while local clone changes remain deliberate, visible Git changes; the bridge performs no fetch or update.
- [Plugin title or source-layout changes] → The bridge validates `plugin.info` title and source directory before copying.
- [Mobile control overlap with itonnote markup] → TDGameStudio CSS scopes the port to its opt-in configuration and adds story-bottom safe-area padding.
- [Theme removal breaks old user overrides] → The change only alters defaults; users can still manually choose an installed theme, and reverting the Wiki commit restores the old package.

## Migration Plan

1. Add the OpenSpec, root reference index entries, and pull-helper support for reviewed sources.
2. Clone selected repositories at reviewed baselines, add the manifest and bridge script, and integrate normal product commands.
3. Rebase the local Angelscript theme/config startup on itonnote/Notion defaults; add official Markdown and Highlight, retain selected Markdown More defaults without enabling that extension, and port selected mobile behavior.
4. Restyle `as-code`, add regression coverage, run build/publish/UI tests, and keep all external commits fixed.

Rollback is a normal `Wiki` commit revert: remove the manifest/bridge integration and imported `src/` sources as desired, then restore the former Angelscript theme source and config defaults. No user tiddler data is migrated or destructively transformed.

## Open Questions

None for the first batch. The remaining legacy plugins will be evaluated individually in later changes.
