## Verification — 2026-07-22

All commands were run from `Wiki/` unless stated otherwise.

| Check | Result |
|---|---|
| `npm run lint` | PASS in 3.08 seconds; checks maintained AngelScript JS/TS and the local TiddlyWiki declaration |
| `npm run check` | PASS |
| `npm test` | PASS, 1 Jasmine spec |
| `npm run test:external-plugins` | PASS, 5/5 |
| `npm run build` | PASS, 10 plugin sources compiled and minimized |
| `npm run test:publish:offline` | PASS, 1/1; offline HTML and plugin library generated |
| `npm run test:playwright` | PASS, 16/16 Chromium product tests |
| `npm run test:examples` | PASS, 2/2 Chromium tutorial-fixture tests |
| `git diff --check` | PASS in the Wiki repository and for the parent OpenSpec paths |
| Old widget export/invocation scan | PASS; no `$as-code` or `$code-example` export or invocation remains |

The first tutorial-fixture run reused an already-running product development server on port 8080. That server deliberately excluded `$:/plugins/your-name/plugin-name`, so the page reported `Undefined widget 'RandomNumber'`. After verifying and stopping that exact Wiki server process, Playwright started `dev:examples` itself and both fixture tests passed. No fixture source change was required.

Desktop visual review used a running product-mode Wiki at 1440x1000 with a dark OS preference. The fixed-light document theme, sidebar, focused search control, ordinary UE AngelScript block, ranged line-number block, highlighted rows, copy actions, and Notion cover/icon fixture rendered without visible overlap or layout regression.

TiddlyWiki core supports packaged plugins beneath `wiki/plugins/`, beside `tiddlywiki.info`. This repository intentionally keeps imported source beneath `src/`: `prepare-external-plugin-sources.mjs` validates and copies selected local/external plugins into `.generated/plugin-sources`, and Modern.TiddlyDev compiles that root for dev, test, build, library, and publish. Moving source plugins directly to `wiki/plugins/` would bypass the current TypeScript/esbuild, minimization, hashing, and library path; it is not used as a lint optimization.

## Palette visual-review correction

The desktop review rejected the intermediate flattening of six LinOnetwo palette roles to `#666666`. A Playwright assertion was first changed to require the original values and failed with all six received values equal to `#666666`. The palette then restored `#bbb`, `#aaaaaa`, `#c0c0c0`, `#999999`, `#cccccc`, and `#c0c0c0` for the corresponding muted/control roles.

The first GREEN run still received the old values because the running product server watches `.generated/plugin-sources`, while the edited source lives under `src`. Inspection confirmed the source held the restored values and the generated copy still held `#666666`. After `npm run prepare:external-plugins` refreshed the existing source bridge, the focused theme suite passed 3/3 and the full product Playwright suite passed 16/16.

The 1440×1000 Control Panel screenshot at `.generated/palette-rollback-desktop-review.png` confirmed that the lighter LinOnetwo hierarchy returned while the focus outline and Tomorrow code treatment remained. It also documented two intentionally deferred issues: the Notion cover/icon ViewTemplate enlarges the core `$:/ControlPanel` icon, and the vanilla sidebar search segment remains visible. Those are not part of the palette rollback.
