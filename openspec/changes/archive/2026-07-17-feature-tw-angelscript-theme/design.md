## Context

The Wiki is a `tiddlywiki-plugin-dev` project. Its current theme list loads `tiddlywiki/vanilla`, while the development Wiki stores the `fluid-fixed` sidebar layout in a project-local system tiddler. TiddlyWiki 5 Vanilla CSS and keyboard controls read several configuration titles hard-coded under `$:/themes/tiddlywiki/vanilla/`.

The Wiki submodule also contains unrelated uncommitted `angelscript-tools` files. The implementation must preserve those changes and touch only the new theme paths plus the existing default-theme/configuration paths.

## Goals / Non-Goals

**Goals:**

- Package Angelscript styles and theme settings as `$:/themes/angelscript`.
- Depend on Vanilla instead of copying its full page template and sidebar implementation.
- Keep Vanilla-compatible configuration titles where the current core requires them, while moving their source files into the theme folder.
- Store stable Wiki defaults and the theme-scoped browser startup action as shadow tiddlers in a regular Wiki configuration plugin instead of project-local `$__*.tid` files.
- Make the development Wiki select Angelscript by default.
- Verify plugin, online Wiki, and offline Wiki build paths.

**Non-Goals:**

- Rewriting all TiddlyWiki core references from the Vanilla namespace.
- Replacing `$:/core/ui/PageTemplate/sidebar` or the core sidebar segment list.
- Adding new navigation entries to the sidebar.
- Changing existing Angelscript tools plugin files or GitHub workflows.

## Decisions

### Use a Vanilla-derived theme plugin

`plugin.info` will identify `$:/themes/angelscript` as a `theme` and list `$:/themes/tiddlywiki/vanilla` in `dependents`. This follows the official Snow White/Tight pattern and keeps the existing responsive layout, editing behavior, and sidebar DOM.

An entirely standalone theme was rejected for this change because it would require copying the large Vanilla stylesheet and tracking every core selector and setting reference.

### Keep compatibility titles but move source ownership

The sidebar layout value will remain titled `$:/themes/tiddlywiki/vanilla/options/sidebarlayout` because current Vanilla CSS and keyboard actions read that exact title. Its `.tid` source will live under `Wiki/src/angelscript-theme/`, and the duplicate `Wiki/wiki/tiddlers/system/$__themes_tiddlywiki_vanilla_options_sidebarlayout.tid` will be removed.

New Angelscript-specific settings and palette values will use `$:/themes/angelscript/...` titles and be consumed by the Angelscript stylesheet.

### Keep theme and Wiki configuration plugins separate

The theme package remains independently selectable and does not try to select itself. TiddlyWiki only unpacks a theme plugin after `$:/theme` already points to it, so placing the default `$:/theme` shadow inside the theme plugin creates a circular bootstrap dependency.

A regular `$:/plugins/TDGameStudio/angelscript-wiki-config` plugin will therefore provide `$:/theme`, `$:/SiteTitle`, `$:/SiteSubtitle`, `$:/DefaultTiddlers`, the CPL startup default, and the guarded browser startup action as shadow tiddlers. Regular plugins are unpacked before the theme manager initializes, so the `$:/theme` default is available in time to load `$:/themes/angelscript`. Normal Wiki tiddlers can still override any shadow default.

### Use a dark editor-oriented visual baseline

The first visual pass will use a deep graphite background, cool blue interactive accents, amber code/highlight accents, high-contrast text, and restrained borders. The design prioritizes long-form documentation and code readability over decorative layout changes.

## Risks / Trade-offs

- [Core namespace coupling] Vanilla-compatible settings still use Vanilla titles. → Keep the compatibility tiddlers packaged with the theme and isolate any future namespace migration as a separate change.
- [Theme dependency availability] Installing the theme without Vanilla could fail. → Declare the Vanilla dependency explicitly and verify the built plugin metadata.
- [Palette startup override] The existing startup action chooses Vanilla/CupertinoDark palettes. → Update the Wiki startup action to select the packaged Angelscript palette while preserving dark-mode detection behavior.
- [Submodule working tree] Existing uncommitted Wiki files could be overwritten accidentally. → Restrict edits to explicitly listed theme/default-selection paths and inspect `git -C Wiki status` before and after changes.

## Migration Plan

1. Add the theme plugin source files and compatibility configuration.
2. Add the packaged Angelscript palettes.
3. Add the regular Angelscript Wiki configuration plugin with stable shadow defaults and a guarded startup action.
4. Remove the duplicate Vanilla sidebar layout system tiddler.
5. Remove Wiki-local files superseded by the configuration plugin, while preserving runtime state, external plugin data, favicon assets, and filesystem bootstrap configuration.
6. Run plugin build, TypeScript check, offline publish, and diff checks.
7. Commit the Wiki submodule changes separately when the user requests commits; then update the parent gitlink and OpenSpec task record.

Rollback is limited to removing the new theme source, restoring the deleted system tiddler, and restoring the previous `$:/theme`/palette startup values; no core or existing plugin files are modified.

## Open Questions

None for the first implementation. A future change may decide whether to migrate all Vanilla-compatible titles to an Angelscript namespace.
