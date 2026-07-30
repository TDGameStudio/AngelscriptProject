## Why

The exported Wiki currently carries several independently maintained icon sources: a small local sidebar set, core and vendor image tiddlers, and hard-coded SVG paths in browser code. The result is visually inconsistent, difficult to audit, and makes a complete replacement of system operational icons unreliable.

This change makes the established lightweight sidebar line style the product-wide operational-icon language, while retaining a controlled path to use individual, reviewed TW Icons-derived artwork only when the local set has no suitable glyph.

## What Changes

- Add a TDGameStudio-owned line-icon catalog containing semantic identifiers, source metadata, licensing provenance, and approved SVG assets.
- Add a deterministic generator that derives reusable plugin image tiddlers and ordinary-Wiki same-title overrides from the catalog without modifying core, `vendor/`, or `node_modules/` sources.
- Migrate the existing sidebar icon set and maps to the generated catalog output, preserving their current lightweight line appearance and 24-by-24 coordinate system.
- Replace user-visible operational icons supplied by core and enabled product plugins with catalog-backed overrides, and record a classified inventory for every candidate title.
- Replace the hard-coded `as-code` copy-state icon shapes with catalog-backed rendering.
- Add source, generated-artifact, and browser-level regression coverage for icon consistency, override completeness, and interaction state.
- Document the icon contribution, licensing, generation, and review workflow in the Wiki documentation (Chinese first).

## Capabilities

### New Capabilities

- `wiki-unified-line-icons`: A governed, generated line-icon system for all user-visible Wiki operational controls.

### Modified Capabilities

<!-- No existing capability requirement changes; the existing code-widget behavior is retained while its artwork source is consolidated. -->

## Impact

- Wiki submodule: `Wiki/src/angelscript-tools/`, `Wiki/wiki/tiddlers/system/`, build/test scripts, product Playwright tests, and Chinese/English Wiki documentation.
- The published Wiki will receive ordinary tiddlers that shadow selected core and enabled external-plugin image tiddlers. Core, fetched vendor sources, and external package artifacts remain untouched.
- `Reference/tw-icons` remains offline research material only. Any adopted artwork requires recorded upstream source and license review; no bulk TW Icons import is introduced.
