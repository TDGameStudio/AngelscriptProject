## Context

The current Wiki composes a local itonnote-derived theme with TiddlyWiki core UI and several tracked external plugins. The visual baseline is intentionally light and already accepted; this work must harmonize behavior rather than redesign it. PC is the primary target, while existing mobile behavior must remain usable. TiddlyWiki plugin sources remain ordinary tracked files and standard builds must stay offline and reproducible. TDGameStudio-owned source and imported upstream repositories require an explicit filesystem and lint boundary so routine validation does not type-analyze prebuilt vendor bundles.

## Goals / Non-Goals

**Goals:**

- Establish one small interaction-token set for controls, links, tabs, focus, and selected states.
- Use TiddlyWiki tags, cascades, configuration tiddlers, fields, and WikiText transclusion as the primary extension points.
- Make SDK documents easier to scan with friendly titles, breadcrumbs, restrained descriptions, bounded prose, and full-width code/tables while keeping the original localized core sidebar layout.
- Keep command-palette help discoverable while making its initial state useful for navigation.
- Remove the blog-oriented cover/icon runtime surface without affecting shared TiddlyWiki icons or draw.io diagrams.
- Let authors show a long selected AngelScript source range in a bounded, internally scrollable code-card viewport.
- Keep imported plugin repositories editable and hot-reloadable under a dedicated `vendor/` boundary while making complete lint fast and deterministic.
- Verify both semantic behavior and rendered interaction states with Playwright screenshots at a desktop viewport.

**Non-Goals:**

- Replacing the accepted light palette, typography, AngelScript tokenizer, or Highlight.js-compatible token colors.
- Building a new Markdown authoring syntax or prioritizing a mobile redesign.
- Adding a custom documentation sidebar tab or an in-page TOC surface.
- Removing or replacing the separate draw.io diagram plugin.
- Importing a third-party documentation framework or fetching new runtime dependencies.

## Decisions

1. **Fix the desktop media query at the WikiText boundary.** The desktop refinement stylesheet will import the sidebar breakpoint variable before emitting its media query. This preserves the configured TiddlyWiki breakpoint and avoids hard-coding a second responsive threshold.

2. **Keep the core sidebar structure and localization while restoring the reference geometry.** Do not add a custom `$:/tags/SideBar` documentation tab or override `$:/config/DefaultSidebarTab`; the sidebar continues to use the core Open / Recent / Tools / More tiddlers, whose visible captions come from the active `$:/language`. The reference Wiki stores a `31.36482939632546vw` sidebar metric, while the migrated Wiki fixed it at `320px`; use `clamp(320px, 31vw, 600px)` so large PC viewports recover the original approximate proportion without letting medium desktop layouts collapse. Keep the accepted light interaction colors and stable hit targets, but do not impose the generic 32px minimum width on sidebar tab labels: restore compact, content-sized tabs and dense open-tiddler rhythm. `AS/Navigation` remains an ordinary bilingual documentation tiddler rather than a sidebar-specific tree.

3. **Use explicit document metadata for presentation.** SDK tiddlers may provide `caption` and `description`. The title cascade displays the caption as the heading and the canonical title as a breadcrumb. The optional description remains limited to `as-sdk-document: yes` tiddlers, uses regular weight and a quiet but legible blue-grey text color, aligns to the same 54rem content measure, and uses stable positive spacing instead of depending on a large negative margin. Authors keep it to one sentence; the layout permits natural wrapping when needed. Prose width is constrained by theme selectors while code cards, preformatted blocks, and tables can occupy the available document width. Do not add a generated or author-maintained TOC card at this stage.

4. **Make command-palette idle mode a navigation mode.** Empty input activates recent searches and story/document history, with a small help affordance; `?` remains the only route to the full help source. The source router remains the single source of truth.

5. **Remove the Notion cover/icon package at the source boundary.** Delete only `vendor/tiddlyseq/src/notionpage-covericon/`, remove its `external-plugins.json` entry, bridge/offline assertions, browser fixture/spec, theme selector override, and author documentation. Do not delete `vendor/tiddlyseq`, because sidebar-resizer, focused-tiddler, and draw.io share that imported repository root. The package does not provide a shared icon library: its author buttons consume `$:/core/images/*`, so settings, search, command-palette, copy, and other core icons remain available. Existing `icon` or `page-cover` fields become inert metadata rather than triggering a ViewTemplate.

6. **Use line count, not arbitrary CSS, to bound long code examples.** `$angelscript-code` accepts an optional `maxVisibleLines` integer. `fromLine` and `toLine` continue to select the rendered/copied source; `startLine` continues to control displayed numbering; `highlightLines` continues to select displayed emphasis; `maxVisibleLines` affects only viewport height. Valid values are clamped to 3–80 lines, omission preserves the existing unconstrained card, and overflow scrolls vertically inside the code surface while horizontal code scrolling remains available. Copying returns the complete selected source range, including lines outside the current viewport.

7. **Keep every code scrollbar subordinate to code.** All `.angelscript-code-scroll` surfaces use the platform thin-scrollbar declaration plus an approximately 6px WebKit scrollbar, not only cards with `maxVisibleLines`. The track remains transparent, the default thumb uses a very light neutral, and hover raises contrast only slightly without increasing geometry. Only bounded viewports gain vertical overflow behavior; unconstrained cards do not receive a forced height.

8. **Use icon-only copy controls with core localization.** The visible copy control uses inline SVG states for copy, success, and failure, so no language-specific word occupies the compact code-card action. `title`, `aria-label`, and the hidden live status resolve `$:/language/Buttons/CopyToClipboard/Hint` and the core copied-to-clipboard notification tiddlers from the active language pack. The state returns to the copy icon after the existing short feedback interval.

9. **Verify screenshots deterministically.** Playwright tests create any required state, wait for stable rendering, capture named screenshots for the restored localized core sidebar, normal, hover, pressed, focus, selected, command-palette, SDK title/description hierarchy, and code-viewport scroll states, and assert key computed styles and geometry before visual inspection.

10. **Separate owned source from editable vendor source.** Move the four imported repositories from `src/<repository>` to tracked `vendor/<repository>` directories and update `external-plugins.json`; active runtime sources remain typechecked and watched, so editing a registered vendor plugin still hot-reloads. `lint` applies the full TDGameStudio rules to local source, scripts, and Playwright tests. `lint:vendors` parses all four tracked repositories with a bounded serious-correctness ruleset while excluding `files/lib/**`, `*.min.js`, and generated output. `lint:all` runs both scopes instead of type-aware scanning a prebuilt megabyte-scale bundle. Ignored `.submodule-backup-*` and `.retired-*` directories remain non-product migration backups.

11. **Restore the reference page-control geometry and order without restoring personal-Wiki plugins.** RefWiki page controls resolve to approximately 21×25px with `min-width`/`min-height: auto`; the migrated desktop refinement incorrectly forces them to 32×32px. Keep 32px targets for isolated title/sidebar controls, but explicitly restore natural sizing inside `.tc-page-controls`. TiddlyWiki reads `$:/config/PageControlButtons/Visibility/<full-button-title>`; replace the migrated short-path configuration with canonical entries. Use the native `$:/tags/PageControls` list field to keep the approved visible controls in the reference order: core Home, More actions, new tiddler, new Markdown, control panel, and draw.io. Hide save, Command Palette, new journal, refresh, layout, and advanced search. Do not import Batch, SCM, filter-builder, or journal-oriented plugins to reproduce icon count.

12. **Treat the untagged action as quiet secondary metadata.** The core More/Tags surface currently combines `#777` text with the theme's dark `rgba(92,112,128,.9)` tag background. Set the semantic `untagged-background` token to `#eef2f7`, scope the More-sidebar untagged control to `#5d6b7b` text and a `#d8dee6` border, and reuse the existing light blue hover/pressed tokens. Do not change ordinary tag colors.

## Risks / Trade-offs

- **Theme selectors can accidentally affect editor/author UI.** → Scope prose and title rules to metadata-enabled view-mode tiddler frames and cover representative controls in Playwright.
- **TiddlyWiki state and history can make screenshots nondeterministic.** → Open canonical fixture tiddlers, clear or seed temporary state where needed, and use fixed 1536×960 viewport screenshots.
- **Deleting an imported package can accidentally remove sibling TiddlySeq capabilities.** → Delete only the validated `notionpage-covericon` package path and assert that draw.io, sidebar-resizer, and focused-tiddler remain in the external manifest and generated plugin library.
- **A bounded viewport can hide the existence of later code lines.** → Show a visible thin scrollbar when overflow exists, include a deliberately long canonical example, and test wheel scrolling plus a non-zero scroll position.
- **Line-height changes can make a line-count viewport inaccurate.** → Derive the viewport height from the code surface's owned line-height token and cover the rendered client-height/scroll-height relation in Playwright.
- **Moving imported repositories can break bridge or watcher paths.** → Treat `external-plugins.json` as the canonical path source, add source-boundary tests, and re-run preparation, build, typecheck, watcher, offline publish, and browser coverage after migration.
- **A percentage-based sidebar can consume too much room on medium desktops.** → Bound the reference `31vw` proportion with a 320px minimum and 600px maximum, and test the resolved width at both 1280px and 2048px desktop viewports.
- **Compact toolbar icons reduce nominal pointer area.** → Restrict natural sizing to the continuous `.tc-page-controls` toolbar, preserve visible focus and hover feedback, and retain 32px targets for isolated title and sidebar controls.
- **Mobile receives less visual attention.** → Preserve current responsive rules and run the existing mobile smoke tests even though screenshot acceptance is desktop-first.

## Migration Plan

1. Replace cover/icon expectations with absence assertions, then remove the isolated package registration, source, tests, theme override, and author documentation.
2. Add failing widget and browser tests for `maxVisibleLines`, complete-range copying, internal wheel scrolling, and thin scrollbar geometry before implementing the widget/style changes.
3. Remove the custom documentation sidebar/default-tab tiddlers and TOC style/script/content, restore `AS/Navigation` to its ordinary language-aware document form, and retain the core localized sidebar controls.
4. Expand the Focused source range example so it contains more lines than its viewport and documents how source selection differs from viewport sizing.
5. Normalize the SDK description spacing and capture representative core-sidebar and title/description screenshots at the desktop acceptance viewport.
6. Move tracked imported repositories to `vendor/`, split local and vendor lint policy, and verify source-boundary, bridge, watcher, typecheck, and build contracts.
7. Restore the reference sidebar's bounded responsive proportion and compact tab/list density without changing colors, localization, plugin inventory, or mobile rules.
8. Correct canonical page-control visibility tiddlers, restore natural toolbar geometry, and harmonize the untagged control.
9. Rebuild all generated sources and verify retained external plugins, runtime plugin absence, interaction behavior, screenshots, lint, build, offline publish, and the full Playwright suite.

Rollback restores the isolated manifest entry/source/tests and removes the optional code-card viewport attribute/style; no persisted content migration or network state is required.

## Open Questions

None. The user selected complete removal of `notionpage-covericon`, retention of draw.io and core icons, restoration of the original localized core sidebar with `clamp(320px, 31vw, 600px)` desktop geometry and compact density, retention of the accepted light palette, omission of an in-page TOC, a line-count-based code viewport, and the existing optional SDK description surface.
