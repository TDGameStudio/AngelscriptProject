## Context

The Wiki is a TiddlyWiki 5 product hosted as the `Wiki/` submodule. Its accepted left-sidebar/document UI currently passes 42 Chromium tests, but product assembly still inherits Modern.TiddlyDev plugin-library scripts and workflows. Runtime state also includes serialized plugins outside the source manifest, ordinary test fixtures appear in reader-facing lists, the same sidebar capability spans theme/tools/config/vendor, and full core-title overrides are not checked against dependency upgrades.

## Goals / Non-Goals

**Goals:**

- Make the shipped runtime, product sources, network behavior, and offline artifact explicit and testable.
- Preserve the accepted desktop/mobile layout while reducing cross-plugin ownership and CSS specificity debt.
- Make test content invisible to readers without deleting useful fixtures.
- Establish safe TiddlyWiki and vendor upgrade boundaries.
- Keep volatile host status traceable to a source revision.

**Non-Goals:**

- Redesigning the home page, replacing command palette/autocomplete, or adding a fourth product plugin.
- Publishing standalone plugin packages, enabling automatic Pages deployment, or changing remotes.
- Archiving `feature-wiki-syntax-showcase` or unrelated active changes.

## Decisions

1. **One product manifest.** Replace the external-only manifest plus hard-coded local array with `product-sources.json`. Entries use `profile` (`product`, `example`, `reference`) and `origin` (`local`, `vendor`); vendor entries retain repository and baseline data. Product preparation is generated from this file.
2. **No implicit external runtime.** Remove CPL and prevent-edit serialized plugins. Draw.io is the only initial exception model: its external iframe is allowed only after explicit edit.
3. **System test namespace.** Product test targets move to `$:/tests/TDGameStudio/AngelscriptWiki/`; reader showcases remain ordinary tiddlers. The unused Modern.TiddlyDev `plugin-name` template and its dedicated fixture tests are removed instead of being carried as a second product surface.
4. **Three-plugin ownership.** Theme owns styles, tools owns code/navigation behavior, config owns defaults and narrow core policy. The local resizer moves from config to tools; the vendor resizer leaves the runtime.
5. **Low-refresh resizing.** Dragging updates a CSS property in `requestAnimationFrame`; only the terminal event persists a width clamped to 240px through `min(40vw, 520px)`.
6. **Core guard before upgrade.** A contract test validates the PageTemplate wrapper delta and lingo patch rationale before moving from TiddlyWiki 5.4.0 to 5.4.1.
7. **Product-only build.** The offline builder compiles source tiddlers directly into the preload set and emits only `dist/index.html`; no `buildLibrary` output survives.
8. **Gradual CSS decomposition.** Existing visual rules move into ordered semantic stylesheets; visual values remain stable during structural moves. Dead rules and global focus suppression are removed only with focused tests/screenshots.
9. **Generated host status.** A parent-side sync command writes a revision/date-stamped system data tiddler consumed by `AS/Status`; no runtime fetch is added.
10. **Auditable vendor deltas.** Current differences are recorded first. Converting vendor trees into immutable upstream plus patch overlays is deferred.

## Risks / Trade-offs

- **Core override drift** → Compare the installed core tiddler and fail on deltas outside the documented wrapper change.
- **Theme refactor causes subtle visual regressions** → Move rules by responsibility, keep current values first, and validate 1440/1280/390 viewports before cleanup.
- **Width clamping surprises existing users** → Preserve the standard sidebar metric but normalize only during desktop interaction; default remains 280px.
- **Product manifest migration breaks development** → Keep the generated flat source bridge and test product/reference selection before changing scripts.
- **Vendor lint includes non-product sources** → Derive product lint scope from the manifest and keep an explicit vendor audit command for all tracked vendor sources.
- **Artifact size varies after dependency upgrades** → Store a deterministic decoded-byte ceiling and report per-plugin sizes before changing the budget.

## Migration Plan

1. Add failing source/runtime/content/artifact tests and introduce the product manifest.
2. Remove unsafe runtime plugins, move fixtures, and consolidate product CI/build scripts.
3. Add core override guards and upgrade TiddlyWiki in an isolated change set.
4. Move navigation behavior to tools, remove the vendor resizer runtime entry, and split theme styles without changing the accepted layout.
5. Add localized metadata/status data, vendor ledger, budgets, and expanded browser/a11y checks.
6. Run full verification, commit the Wiki submodule first, then record the parent OpenSpec/gitlink separately.
