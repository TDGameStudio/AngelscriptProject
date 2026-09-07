# Harness Web completion evidence

## Delivered behavior

`Tools/harness-web` provides a local React/Vite and Fastify workbench for overview, active Changes, current Specs, tasks, project documents and archives. The fixed native adapter consumes actual portable OpenSpec records and TaskPlan JSON. Milkdown Crepe edits supported body segments; the shared envelope preserves frontmatter, machine task definitions, Files lines and opaque source. Recharts, React Flow/Dagre, Mermaid, Radix, TanStack, MiniSearch, Chokidar, IndexedDB and resizable panels supply established UI and infrastructure behavior.

The final source identity is captured in the adjacent source-identity.json. Package-lock.json fixes the resolved dependencies. The tested environment was Windows, Node v25.5.0, npm 11.10.1 and Chromium from Playwright 1.63.0. Node 24 LTS is the recommended runtime baseline.

## Original accepted implementation

Commands below run from the repository root unless a package working directory is stated.

| Command | Final result | Scope |
| --- | --- | --- |
| `npm --prefix Tools/harness-web run check` | Passed | One batch: TypeScript, all unit tests, production build and browser acceptance. |
| Nested `npm run typecheck` | Passed | Complete browser/server/shared TypeScript contracts. |
| Nested `npm test` | 55/55 passed across 6 files; 6.85 seconds | 15 adapter, 27 document and 13 UI tests. |
| Nested `npm run build` through pretest:e2e | Passed; Vite 11.47 seconds plus server TypeScript emission | Compiled client assets and runnable Node server. |
| Nested `npm run test:e2e` | 9/9 passed; 24.6 seconds | Actual Chromium, native CLI and isolated Git fixture service. |
| `npm --prefix Tools/harness-web run format:check` | Passed on the final delivered source | Maintained package source, tests, configuration and README. |
| `Tools/PullReference/PullReference.bat list` | Passed | Two new pinned registry entries listed. |
| Reference Git HEAD, origin, status and LICENSE inspection | Passed | Both clones match their recorded commits, SSH origins and MIT licenses; working trees clean. |
| Harness `openspec.validate --specs --strict --json` | 15/15 passed | Current capability synchronization, including the new harness/web spec. |
| Harness `openspec.doctor --json` and strict exact Change validation | Passed | OpenSpec record structure and accepted task graph. |

Final raw application output remains at ignored `Tools/harness-web/.cache/acceptance.log`; Playwright HTML results and screenshots remain under the package's ignored playwright-report/ and test-results/ directories. No raw report is a required reusable fixture. Test servers bind temporary workspaces and never reuse the user's running service.

Browser acceptance covers search and Mermaid rendering; task selection across board/list/DAG and source-line navigation; real WYSIWYG saves preserving CRLF/frontmatter; task prose edits preserving native readiness and machine fields; external revisions preserving drafts across navigation; explicit manual conflict merges without implicit writes; keyboard resizing and persistence across cold reload; archive immutability and local spec links; light/dark persistence and narrow-screen navigation without horizontal overflow.

## Failure-driven corrections retained in the final proof

The first browser pass exposed an ambiguous nested source-line test selector. Later integrated passes found a real cold-start layout restoration error and a source-highlight class lost during React rerenders. The layout now mounts after workspace identity is available; source highlighting is declarative with stable Markdown renderers. Both have focused regression coverage and passed final browser acceptance.

Editor integration reads live ProseMirror state before saving, unmounting or deciding whether an incoming disk revision may replace the session. Explicit rebasing preserves body drafts and adopts the current disk revision only when protected content remains compatible. Changed protected metadata is rejected safely.

Node 25 exposes a pre-existing global localStorage that Vitest retained instead of JSDOM Storage. The preference tests now bind the real JSDOM Storage for their own environment; the product storage behavior is also verified independently in Chromium.

The watcher originally traversed wholly Git-ignored trees before becoming ready. Git returned 89 collapsed ignored entries in roughly 118-124 ms in the real workspace. The final watcher prunes those directories before recursion while retaining forced tracked documents inside otherwise ignored paths. The focused regression first observed an invalidation from an ignored nested document, then passed after the correction. A single read-only source-level watcher initialization measured 1,490 ms. The final compiled service started at port 4310, with 2,307 ms between its recorded process-start time and listening-log modification time; startup metadata and logs remain under the ignored package .cache directory. These are diagnostic observations, not accepted benchmarks or performance contracts.

## Repository-wide check outside this Change

`& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1` did not pass its repository-wide English-language scan. It identified existing, unrelated untracked records at:

- `openspec/changes/angelscript/refactor-testing-unified-framework/tasks.md:75`.
- `openspec/specs/angelscript/language/frontend/preprocessing/knowledges/clang-directive-and-source-backquery.md:18`.

Those lines reference paths containing non-English characters. Neither file belongs to this Change or was edited by Harness Web implementation. This broad scan failure is retained explicitly; it is not reported as a passed check. The exact Change, all current specifications and the document adapter's fixed native command behavior passed their own relevant proofs.

## User-directed layout refinement and Windows archive repair

The user subsequently identified horizontal Change file selection and excess whitespace, then requested a layout/style inspection. A read-only 16-screenshot inspection covered Changes, documents, tasks and overview at 1600, 1440, 1280 and 375px. It confirmed a competing record rail, centered body cap, large outer gutters, overflowing horizontal file tabs and fixed outline space compressing narrow document panes. The applied record-layout replan preserves the original seven completed tasks and adds task 3.3.

Selected records now use a vertical searchable file explorer beside the full-width reading pane, with compact back/record-switch controls preserving prior filters. Shared desktop gutters are 24px; filenames wrap, active files expose aria-current, and body text is 14px on desktop. Narrow document panes fold the outline; mobile file selectors collapse without unmounting an edited document. The actual installed UI passed a subsequent read-only visual check as well as browser geometry and interaction proofs.

An independent external archive attempt revealed a Windows native watcher directory lock. The indexed implementation issue and its applied replan add task 3.4. Windows now uses a per-instance polling watcher with a default 500 ms interval, retaining Git ignored pruning and atomic-write handling. An effective environment override disabling polling is rejected before obtaining handles, without modifying process.env. A real packaged CLI archive completes while the fixture service remains running, and later edits to moved files still refresh searches.

| Final refinement command | Result |
| --- | --- |
| `npm --prefix Tools/harness-web run check` | TypeScript passed; 59/59 unit tests across 7 files passed in 9.84 seconds; production client/server build passed (Vite 11.33 seconds). The initial browser run passed 10/11; its one failure measured geometry before the sidebar transition settled. |
| `npm.cmd --ignore-scripts run test:e2e` from Tools/harness-web | 11/11 Chromium workflows passed in 27.1 seconds using the same verified build, after correcting only the test's asynchronous layout wait. No implementation change or rebuild was needed for that correction. |
| Focused `npm.cmd --prefix Tools/harness-web run test:adapter` | 17/17 passed, including live native archival and post-move refresh. |
| Focused `npm --prefix Tools/harness-web run test:ui` | 15/15 passed, including vertical file navigation, duplicate nested names, filters and editor preservation. |
| Strict current-spec validation through Harness | 15/15 passed after both new observable scenarios were synchronized. |

The final 59 unit tests comprise 17 adapter, 27 document and 15 UI cases. Raw refinement output remains at ignored .cache/layout-acceptance.log and .cache/layout-browser-final.log; the package test-results directory contains desktop/mobile record explorer captures. The final delivered source identity supersedes the earlier baseline identity without rewriting its executed history. Unreal checks remain outside the demonstrated impact.

Final real-workspace layout measurements, using the same record/document and settled responsive transitions:

| Viewport and page | Before body x / y / width | After body x / y / width |
| --- | --- | --- |
| Changes at 1600px | 688 / 508 / 780 | 493 / 324 / 1058 |
| Changes at 375px | 42 / 769 / 291 | 34 / 405 / 307 |
| Documents at 1280px | 540 / 310 / 479 | 527 / 267 / 706 |
| Documents at 375px | 37 / 607 / 301 | 37 / 331 / 301 |

The desktop record gutter changed from 48px to 24px. The active record file explorer is 220px wide, and its mobile file rows have 44px hit areas. Dark-theme inspection retained the same geometry and consistent selected/code surfaces. No inspected page had horizontal page overflow or browser page errors. Before/after screenshots remain under the ignored package .cache/layout-audit and .cache/layout-after-* paths.

## Scope, omissions and limitations

No Unreal build, Automation test, Quick, Integration or Performance Harness aggregate was selected: there is no Unreal/plugin implementation or shared Harness dispatcher change, and the new web package has a bounded owner and browser integration proof. The OpenSpec Skill edit only documents the fixed read-only product adapter exception.

Build output warns about large lazy editor and Mermaid chunks; the rich libraries are intentionally loaded on demand. The workbench is local-only, one selected workspace per server, with UTF-8 Markdown up to 2 MiB and constrained raster images up to 8 MiB. Protected source is read-only in the editor; edited ordinary body formatting may normalize. External merges are manual and explicit. Restart after Git ignore rule changes to refresh watcher pruning.

Current behavior was promoted into the new harness/web specification; operational and library details live in the package README. No separate capability knowledge record was necessary. Research used spekhq/spek at 71f109a032e2a29ccecc69b2d2ca0852522dd2d6 and ToruAI/openspec-ui at 6fd5997b6ea1aea3e61cd87cd79172df4d246be0; no source was copied from either reference checkout.
