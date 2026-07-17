## 1. OpenSpec and theme structure

- [x] 1.1 Create the `$:/themes/angelscript` plugin metadata under `Wiki/src/angelscript-theme/plugin.info`.
- [x] 1.2 Add the Vanilla-derived stylesheet, palette, metrics, settings, and compatibility configuration under `Wiki/src/angelscript-theme/`.

## 2. Wiki integration

- [x] 2.1 Set the development Wiki's `$:/theme` default to `$:/themes/angelscript`.
- [x] 2.2 Update the Wiki startup palette selection to use the packaged Angelscript palette for light and dark mode.
- [x] 2.3 Remove the duplicate Vanilla sidebar layout system tiddler from `Wiki/wiki/tiddlers/system/`.
- [x] 2.4 Add `$:/plugins/TDGameStudio/angelscript-wiki-config` with stable Wiki defaults and a guarded browser startup action as shadow tiddlers.
- [x] 2.5 Remove the Wiki-local theme, startup, site identity, default-tiddler, and CPL startup configuration files after the packaged shadow defaults pass runtime verification.
- [x] 2.6 Document the theme/configuration plugin boundary and the allowed contents of `wiki/tiddlers/system/`.

## 3. Verification

- [x] 3.1 Run the available `npm run check` and `npm run build` equivalents in `Wiki/` and verify the theme JSON metadata.
- [x] 3.2 Run the Angelscript theme Playwright regression and verify light/dark runtime theme and palette selection.
- [x] 3.3 Run `npm run publish:offline` and verify a non-empty generated Wiki includes the theme and default selection.
- [x] 3.4 Run `git diff --check` in the parent and Wiki repositories and inspect status to identify unrelated files.
