# Task 2 report

## Changed production paths

- `Wiki/vendor/tiddlyseq/src/sidebar-resizer/style.css`: changed only the idle `div#gk0wk-sidebar-resize-area::before` opacity from `0.14` to `0`; hover and active declarations are unchanged.
- `Wiki/src/angelscript-theme/desktop-refinement.tid`: added the narrow More-sidebar `border-right: none` override outside the desktop media query, plus SDK-frame-scoped description/tag spacing overrides.

## Focused verification

Command attempted from `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts
```

Result: **not green; the Playwright config web server failed before the nine-test spec executed.** Recorded at 2026-07-23 13:52:57 +08:00. The error was:

```text
Error: Process from config.webServer was not able to start. Exit code: 1

[WebServer] node:fs:1205
[WebServer]   return binding.rmSync(getValidatedPath(path), opts.maxRetries, opts.recursive, opts.retryDelay);
[WebServer]                  ^
[WebServer]
[WebServer] Error: ENOTEMPTY, Directory not empty: \\?\D:\Workspace\AngelscriptProject\Wiki\.generated\plugin-sources '\\?\D:\Workspace\AngelscriptProject\Wiki\.generated\plugin-sources'
[WebServer]     at rmSync (node:fs:1205:18)
[WebServer]     at prepareExternalPluginSources (file:///D:/Workspace/AngelscriptProject/Wiki/scripts/prepare-external-plugin-sources.mjs:177:3)
[WebServer]     at file:///D:/Workspace/AngelscriptProject/Wiki/scripts/dev-external-plugin-sources.mjs:32:17
[WebServer]     at ModuleJob.run (node:internal/modules/esm/module_job:430:25)
[WebServer]     at async onImport.tracePromise.__proto__ (node:internal/modules/esm/loader:655:26)
[WebServer]     at async asyncRunEntryPointWithESMLoader (node:internal/modules/run_main:101:5) {
[WebServer]   errno: 41,
[WebServer]   code: 'ENOTEMPTY',
[WebServer]   path: '\\\\?\\D:\\Workspace\\AngelscriptProject\\Wiki\\.generated\\plugin-sources',
[WebServer]   syscall: 'rm'
[WebServer] }
[WebServer]
[WebServer] Node.js v25.5.0
```

## Concern

This is a shared generated-directory cleanup race, not a test assertion result. At the recorded time, 24 `node` processes were active; recently-started instances included PIDs `56844`, `67160`, `72636`, `79460`, `89640`, `96216`, and `96788` (13:52 local time). Per coordination, no `.generated` files were cleaned or otherwise modified, and the retry was stopped before it ran.

## Follow-up verification (current-theme temporary server)

At 13:59 local time, the controller verified that the existing watcher had already mirrored both changed files into `.generated/plugin-sources`, then started a separate, read-only `tiddlywiki-plugin-dev dev --src .generated/plugin-sources` process on the currently free port `8080`. This avoids calling `prepareExternalPluginSources()` and therefore does not replace or clean the shared generated bridge; the user-owned watcher remained on port `8081`.

The focused command then completed successfully from `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts
```

Result: **9 passed (8.1s)**. This includes the new idle resize-rail, More-sidebar border, and SDK description/tag-spacing assertions.
