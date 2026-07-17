# Verification

## Passed

- `npm run check` in `Wiki/`: exit code 0.
- `npm run build` in `Wiki/`: exit code 0; emitted `$:/themes/angelscript` at 13.73 KiB.
- Built theme metadata: `plugin-type=theme`, `version=0.1.0`, dependency `$:/themes/tiddlywiki/vanilla`.
- Built configuration metadata: `$:/plugins/TDGameStudio/angelscript-wiki-config`, `plugin-type=plugin`, dependency `$:/themes/angelscript`.
- Built payload includes `$:/themes/angelscript/base`, `$:/palettes/Angelscript`, `$:/palettes/AngelscriptLight`, and `$:/themes/tiddlywiki/vanilla/options/sidebarlayout=fluid-fixed`.
- Configuration plugin payload includes `$:/theme`, `$:/SiteTitle`, `$:/SiteSubtitle`, `$:/DefaultTiddlers`, the CPL startup default, and `$:/plugins/TDGameStudio/angelscript-wiki-config/startup`.
- `npx playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts --project=chromium`: 1/1 passed.
- Dark runtime: `$:/theme=$:/themes/angelscript`, `$:/palette=$:/palettes/Angelscript`, body background `rgb(15, 20, 27)`.
- Light runtime: `$:/theme=$:/themes/angelscript`, `$:/palette=$:/palettes/AngelscriptLight`, body background `rgb(244, 247, 250)`.
- The runtime test confirms `$:/theme`, `$:/SiteTitle`, and `$:/DefaultTiddlers` are shadow tiddlers; the legacy `$:/Modern.TiddlyDev/Startup` tiddler is absent.
- `git diff --check` passes in the Wiki submodule and parent repository.
- `npm run test:publish:offline` in `Wiki/`: 1/1 passed; `dist/index.html` is 3,616,790 bytes, ends with `</html>`, and contains `$:/themes/angelscript` plus `$:/theme`.

## Resolved Verification Item

The project-level `Wiki/scripts/publish-offline.mjs` wrapper now preloads the missing `tiddlywiki/tiddlyweb` offline template and waits for complete stable HTML before cleaning its temporary Wiki directory. The third-party `Wiki/node_modules/tiddlywiki-plugin-dev/` implementation remains unchanged.

## Workspace Notes

The Wiki submodule contained unrelated uncommitted `src/angelscript-tools/` and Angelscript code-widget Playwright files before this theme implementation. During verification, `package.json` and `pnpm-lock.yaml` also gained an unrelated `eslint` dependency change. These paths were not edited or reverted as part of `feature-tw-angelscript-theme`.

The remaining Wiki system files are intentionally retained: `$:/StoryList` is runtime navigation state, `$__plugins_*.json` files contain external plugin data, favicon files are binary assets, and `$:/config/FileSystemPaths` is needed during filesystem tiddler loading.
