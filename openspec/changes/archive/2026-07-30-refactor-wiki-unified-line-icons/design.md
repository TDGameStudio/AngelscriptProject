## Context

The Wiki contains 35 hand-maintained sidebar SVG tiddlers, a JSON sidebar map, core and enabled external-plugin image tiddlers, and several inline SVG path definitions in browser TypeScript. These sources have distinct ownership and visual conventions. User-facing controls can therefore surface a mixture of lightweight local line icons, TiddlyWiki system imagery, vendor artwork, and copied inline glyphs.

The agreed visual baseline is the existing lightweight local sidebar icon family: `24 x 24` viewBox, no fill, `currentColor`, rounded `1.5`-width strokes, and a compact control-friendly silhouette. `Reference/tw-icons` is a research source only. It contains full upstream libraries rather than a project dependency and does not grant a blanket repository-level license; an individual external icon must carry its upstream attribution and license in the catalog before use.

## Goals / Non-Goals

**Goals:**

- Create one auditable canonical source for all user-visible operational icon geometry and provenance.
- Preserve the current sidebar’s light line-icon language while making the complete operational-control surface consistent.
- Generate image tiddlers and ordinary Wiki shadow overrides deterministically, so a fresh build never relies on hand-copied core/vendor edits.
- Support TypeScript/browser controls such as the `as-code` copy action without embedding independent SVG paths.
- Give tests and reviewers a complete, classified inventory of each candidate icon title.

**Non-Goals:**

- Replacing page emoji, tiddler/Notion cover selection, favicon assets, or the AngelScript loading/brand mark.
- Bulk-importing TW Icons, Feather, Heroicons, or another third-party library.
- Modifying TiddlyWiki core, `Wiki/vendor/`, `node_modules/`, or the source checkout of an enabled external plugin.
- Redesigning icon color, hover behavior, sidebar layout, or unrelated theme work.

## Decisions

### 1. A catalog and generator are the source of truth

`src/angelscript-tools/icons/line/` will hold a reviewed catalog, asset SVGs, and the generated plugin tiddlers. Each catalog record has a semantic identifier, SVG asset name, canonical image-tiddler title, optional shadow target titles, source kind (`self`, `adapted`, or `adopted`), and source/license metadata. The generator validates the catalog and produces all generated tiddlers in stable order.

The catalog replaces a map-plus-independent-tiddlers model because it makes geometry, meaning, target ownership, and license review visible together. A manual collection of replacement `.tid` files was rejected because it can silently drift from the map and cannot be completely audited.

### 2. Generated output stays inside project-owned locations

Canonical image tiddlers are generated inside the `angelscript-tools` plugin and are used by project-owned WikiText and browser code. Same-title image replacements are generated under `Wiki/wiki/tiddlers/system/line-icons/`, allowing ordinary tiddlers to override a core or enabled-plugin shadow tiddler at runtime.

This follows TiddlyWiki’s shadow-tiddler precedence without editing an upstream source. A generator target receives an explicit kind: `canonical` is a project-owned title; `override` is a reviewed shadow title. The generator rejects an override with a non-image title or no associated catalog icon.

### 3. Preserve the established geometry and runtime parameter contract

Generated icon tiddlers expose the existing `size` parameter and render SVG with the local `24 x 24`, `fill="none"`, `stroke="currentColor"`, round-cap/round-join, and `stroke-width="1.5"` baseline. Existing sidebar and compact-rail transclusions can therefore retain their current `size` calls while moving their targets to generated titles.

Browser code will render a canonical icon tiddler through the TiddlyWiki rendering API rather than duplicating SVG path data. Its helper accepts only catalog semantic IDs and returns a rendered icon element suitable for controls. This is preferable to importing raw file data into the browser bundle and ensures the browser and WikiText surface use exactly the same generated artifact.

### 4. Inventory governs scope and exclusions

The generator input includes a tracked inventory of candidate core and enabled-product-plugin image titles. Each entry is classified as `override`, `canonical`, or `excluded`; exclusions need a specific reason. Tests compare the inventory with generated targets and reject missing classifications, duplicate target titles, system-image fallbacks, or generated artwork outside the approved line contract.

This guards against an ambiguous “replace every icon” interpretation while keeping non-operational media, branding, and content emoji deliberately out of scope.

### 5. External icon adoption is exceptional and recorded

New icon geometry is created or adapted from the local family by default. If no appropriate glyph exists, an individual icon can be adopted or adapted from a reviewed upstream source (for example a TW Icons-contained library) only with its exact source title/URL and compatible license in the catalog. The implementation contains no dependency on the `Reference/tw-icons` checkout and does not copy whole icon sets.

### 6. Versioned catalog records prevent semantic fallback

The catalog uses a v2 record model: each canonical icon carries an ID, category, asset key, and source profile; a Feather record additionally names its precise upstream icon. Inventory entries are explicit objects when they declare a semantic alias, naming the primary image target and the reason for sharing. The generator rejects unmapped non-excluded targets, duplicate geometry, invalid source profiles, and a sidebar mapping to an unknown icon.

This replaces the former string-only map plus `generic-tool` default. A generic fallback was rejected because it hides both missing implementation work and semantic mismatch from reviewers. Likewise, action/state variants such as lock/unlock and preview open/closed remain separate assets even when they are visually related.

### 7. Imported artwork is reviewed once and committed as local geometry

`scripts/import-reviewed-feather-icons.mjs --write` is a deliberate maintenance helper. It reads only the pinned offline `Reference/tw-icons` Feather 4.28 tiddlers, extracts the exact catalog-selected SVG children, strips incompatible style attributes, and writes reviewed geometry to `assets.json`. The normal generator, development server, publish flow, and runtime read only committed project assets and never touch `Reference/`.

This keeps individual adoption auditable without giving a local research checkout runtime or build dependency. It also preserves the existing sidebar family as the visual parent: local geometry is retained whenever it already has an appropriate lightweight silhouette.

### 8. CSS enforces the line contract at the cascade boundary

Generated SVG attributes alone are insufficient because compact-rail and tree rules can apply `fill: currentColor` at a later or more specific cascade layer. A shared `svg.as-line-icon, svg.as-line-icon *` rule therefore sets `fill: none !important` while retaining `currentColor` stroke inheritance. Selectors that intentionally style legacy SVG fills are narrowed to exclude generated line icons.

The sidebar visibility glyph is a special migration case. Its original 20-by-20 geometry is explicitly scaled by 1.2 when placed in the shared 24-by-24 canvas (`M15 6 9 12 l6 6`), rather than preserving the old coordinates and rendering it undersized.

### 9. Gallery is a review surface, not navigation content

The generator derives a single non-default review tiddler from the catalog. Each row shows a rendered glyph, semantic ID, category, source/license, actual overrides/sidebar/runtime usage, and declared aliases. Source tests validate the catalog and generated files; browser tests validate computed fill values across the gallery and sidebar hover/hide/show interaction states.

### 10. More-action controls share semantics, not a generic down-arrow

The sidebar PageControl and the tiddler ViewToolbar both represent a menu of additional actions. The sidebar continues to render its generated `more` icon through the compact-rail map. The tiddler toolbar receives a project-owned ordinary tiddler override for `$:/core/ui/Buttons/more-tiddler-actions`, retaining the core popup and action-list behavior while transcluding `$:/core/images/menu-button`. The global `$:/core/images/down-arrow` remains the `arrow-down` glyph because it is also used by genuine dropdown controls.

Both popup surfaces use a shared two-column grid: a fixed 16px icon column and a flexible text column, aligned on the vertical centre with a 12px / 30px menu rhythm. The Markdown page-control image is included in the generated product-image inventory so its core menu rendering cannot escape the line-icon contract. The `save-wiki` button's `tc-dirty-indicator` wrapper participates through `display: contents`, preventing that one item from falling back to inline baseline alignment.

## Risks / Trade-offs

- [Core/plugin updates add new image titles] → The tracked inventory test detects uncategorized candidates; release review updates the catalog or explicit exclusion.
- [A shadow title is no longer present upstream] → The source test resolves candidate titles from the selected product sources and rejects stale override targets.
- [Different icon semantics need a missing glyph] → Add one local asset first; permit a reviewed individual external glyph only with license/source metadata.
- [Generated files are edited manually] → The generator writes a marker and a validation test compares output with generated content.
- [Widget rendering changes the copy control DOM] → Browser tests assert the control’s accessible state and the rendered SVG’s line contract rather than brittle inner markup.
- [A state icon is accidentally collapsed into a similar-looking glyph] → Catalog tests reject duplicate geometry and require aliases to identify one primary target; browser/gallery review makes the remaining semantic decision visible.
- [Future CSS reintroduces dark icon bodies] → Shared selector plus computed-style Playwright assertions cover normal, hover, and sidebar visibility transitions.
- [A More-menu item has a nonstandard wrapper] → Grid layout tests measure each item's icon/text columns in both popup contexts, including the dirty-save wrapper.

## Migration Plan

1. Add failing contract tests for v2 catalog integrity, explicit target mapping, corrected toggle geometry, no-fill CSS, and copy-control rendering.
2. Record every canonical icon and source profile, retain fit-for-purpose local geometry, and import only reviewed Feather 4.28 single icons into committed project assets.
3. Generate canonical tiddlers, all ordinary overrides, sidebar map, registry, and review gallery; remove legacy sidebar files and generic fallback usage.
4. Verify the compact rail at desktop size, including hover and hide/show sidebar state, then correct the shared cascade boundary if generated icons receive a fill.
5. Run TypeScript, source-boundary, generator freshness, offline artifact, product-browser verification, and visual review; document the contribution and license workflow.

Rollback is a normal source revert: generated files and catalog are committed together, so reverting their commit restores the former tiddlers without touching core or vendor sources.

## Open Questions

- None for the initial migration. Icon candidates uncovered by future enabled plugins follow the inventory process rather than expanding this implementation’s scope implicitly.
