## Context

AngelscriptWiki uses the imported `linonetwo/commandpalette` and its Algolia Autocomplete dependency. The imported stylesheet fixes the desktop palette at five ems from the top, defaults its width to 80%, applies a strong blurred mask, and brings its own purple-blue control tokens. The local Angelscript theme then adds a global blue focus outline, producing the oversized and visually mixed search surface shown in the desktop review. The command-palette plugin already exposes `HideDefaultSearchBar`, so the second Vanilla sidebar search can be retired through configuration rather than DOM surgery.

Preview glass is independently imported from the retained `tiddlywiki-plugins` source tree, but is selected for runtime only by `external-plugins.json`. Removing that manifest entry is sufficient to keep its source auditable while excluding it from generated product sources.

The Wiki repository tracks the imported plugin source as ordinary files specifically so selected integrations can be reviewed and adapted locally. The user has explicitly chosen direct command-palette source ownership for this refinement, instead of treating the imported snapshot as an immutable vendor artifact.

## Goals / Non-Goals

**Goals:**

- Present one compact, centered, keyboard-accessible desktop search experience aligned with the accepted fixed-light document theme.
- Keep the visual behavior owned in command palette itself, with the local delta made explicit and protected by browser regression tests.
- Remove preview-glass runtime behavior and assert its absence in source and browser contracts.
- Preserve narrow-screen usability without expanding this pass into a mobile redesign.

**Non-Goals:**

- Replacing command palette, changing its search providers, shortcut semantics, or result ranking.
- Rebuilding the right sidebar, changing the accepted Notion-like layout, or introducing a dark palette.
- Deleting the imported `tiddlywiki-plugins` reference source tree.

## Decisions

### Correct the command-palette source at its ownership boundary

Revise the imported `DefaultCommandPalette.css.tid`, because it already owns the container, Algolia form, result panel, selected rows, and backdrop. On desktop the container uses `min(720px, calc(100vw - 48px))`, a 72px top offset, a 44px input, restrained gray borders, an 8px radius, and a low-elevation neutral shadow. The result panel follows the same width and visual tokens, uses a bounded internal scroller, and selects rows with the low-saturation Tomorrow blue already used for code-line emphasis.

The backdrop is a quiet neutral veil with approximately three pixels of blur. Mobile receives fit-to-viewport bounds and overflow protection only. A separate Angelscript-theme override was rejected after the ownership boundary was clarified: it would duplicate selectors and force theme precedence to compensate for defaults that belong to the plugin. Changing only `DesktopWidth` was also rejected because it would leave the input, panel, focus, selected rows, and mask visually inconsistent.

### Use the plugin's supported preference to remove duplicate search

Ship `$:/plugins/linonetwo/commandpalette/configs/HideDefaultSearchBar` as a local shadow configuration tiddler with `yes`. This activates the imported plugin's existing stylesheet and preserves a user-overridable configuration path. The command palette remains reachable from `Ctrl/Cmd+P`; its intentionally hidden page-control button remains unchanged.

### Retire preview glass at the manifest boundary

Remove the `preview-glass` entry from `external-plugins.json` and change browser/source tests from presence to absence. Do not delete the upstream source snapshot, because it is part of a broader imported reference repository and can still support provenance or later comparison.

### Mirror real source changes incrementally during development

The reproducible bridge remains a disposable ordinary-file copy because plugin-dev does not compile TypeScript modules reached through directory junctions. Product `dev` commands will run a thin repository script that prepares the bridge once, watches every validated real plugin source directory, and maps individual add/change/delete events into its named generated plugin directory. The existing plugin-dev watcher then performs compilation, server restart, and browser refresh exactly as designed.

Build, test, and publish commands continue to recreate the bridge once and do not start a watcher. Symlink/junction bridges were rejected because they would violate the existing isolation contract and have cross-platform/TypeScript compilation limitations; repeatedly rebuilding the entire generated root was rejected because it loses precise change paths and can leave a long-running server with stale plugin tiddlers.

## Risks / Trade-offs

- [The local source delta must be reconciled during a later upstream refresh] → Document direct source ownership, keep the manifest baseline auditable, and cover dimensions, focus, panel alignment, and mobile overflow in Playwright.
- [A hidden sidebar search reduces visible discovery] → Preserve the standard `Ctrl/Cmd+P` entry and command-palette help/result behavior; no search capability is removed.
- [Fixed panel positioning can drift from the input] → Give the container and panel the same responsive width and centered horizontal positioning, then assert their browser bounding boxes.
- [Removing preview glass changes hover behavior for existing readers] → This is the intended retirement; no tiddler data or author syntax depends on it.
- [Filesystem watchers can emit duplicate or transient events] → Make synchronization idempotent, constrain every destination to its declared generated plugin directory, and let plugin-dev's existing write-stability queue batch refresh work.

## Migration Plan

1. Establish failing source and browser tests for preview-glass absence, hidden duplicate search, and compact palette geometry.
2. Remove the manifest entry, add the supported configuration tiddler, and refine the command-palette source stylesheet.
3. Regenerate external plugin sources, update maintainer documentation, and run the complete product verification suite.
4. Roll back with a normal Wiki commit revert if needed; no stored user data migration is involved.

## Open Questions

None. The user approved the compact centered desktop direction, duplicate sidebar-search removal, and preview-glass retirement.
