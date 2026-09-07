---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["1.2"]
    "2.3": ["1.2"]
    "3.1": ["2.1", "2.2", "2.3"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
    "3.4": ["3.2"]
---

## Accepted implementation

Use current workspace and preserve unrelated changes. Read attachments/INDEX.md first. Existing focused RED/GREEN evidence remains valid. At the user's explicit request during integration, implement coherent batches of related code and tests, then run consolidated verification; do not rerun after every small edit. Isolate verification only for a failure that blocks subsequent work. Root coordinates shared contracts, package operations, integration and closure; parallel owners have disjoint source paths. All npm commands below run from the repository root. Browser tests write only isolated fixtures.

- [x] 1.1 Record accepted behavior and execution boundaries — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('harness/feature-web-workbench', '--strict', '--json')`
  > Files: `openspec/changes/harness/feature-web-workbench/**`

- [x] 1.2 Establish package, shared interfaces and narrow native adapter guidance — verify: `npm --prefix Tools/harness-web run typecheck`
  > Files: `Tools/harness-web/package.json`, `Tools/harness-web/package-lock.json`, `Tools/harness-web/*.json`, `Tools/harness-web/*.ts`, `Tools/harness-web/index.html`, `Tools/harness-web/.gitignore`, `Tools/harness-web/src/shared/types.ts`, `.agents/skills/openspec/SKILL.md`

- [x] 2.1 Implement OpenSpec adapter, indexed records, scoped documents and API — verify: `npm --prefix Tools/harness-web run test:adapter`
  > Files: `Tools/harness-web/src/server/**`, `Tools/harness-web/tests/adapter/**`

  Cover actual native JSON, absent tasks, invalid plans, archives, excluded paths, conflicting saves, local HTTP boundaries and watcher invalidation. Document envelope enforcement is integrated after 2.2.

  Evidence: 14/14 adapter tests passed against isolated Git fixtures and the actual packaged CLI. Server TypeScript check passed. A read-only real-workspace smoke returned HTTP 200 for workspace, metrics and search; it found 3 active changes, 14 specs and 35 archives at capture time. No real-workspace documents were written.

- [x] 2.2 Implement protected document transforms and WYSIWYG editor — verify: `npm --prefix Tools/harness-web run test:documents`
  > Files: `Tools/harness-web/src/shared/documents.ts`, `Tools/harness-web/src/client/editor/**`, `Tools/harness-web/tests/documents/**`

  Cover unchanged bytes, frontmatter, task machine lines, nested Scenario blocks, opaque syntax, line endings, Mermaid and draft preservation. Export a DocumentEditor component for the client owner.

  Evidence: 23/23 document tests passed, including actual Crepe serialization and DOM, Scenario AST nesting, image alt/URL preservation, IndexedDB conflicts and immediate unmount draft flushing. The editor lane TypeScript check passed. An integration test will exercise the remaining live external-update timing boundary.

- [x] 2.3 Implement workbench navigation, reading, task views and factual charts — verify: `npm --prefix Tools/harness-web run test:ui`
  > Files: `Tools/harness-web/src/client/App.tsx`, `Tools/harness-web/src/client/main.tsx`, `Tools/harness-web/src/client/styles.css`, `Tools/harness-web/src/client/components/**`, `Tools/harness-web/src/client/pages/**`, `Tools/harness-web/src/client/lib/**`, `Tools/harness-web/tests/ui/**`

  Use the shared API and editor interface. Support URL selection, global search, accessible themes, factual charts and responsive details.

  Evidence: 9/9 UI tests and whole-package TypeScript check passed. Real-workspace read-only browser navigation, search, graph and archive smoke produced no page errors. Integration owns panel-width persistence and final browser interaction proof.

- [x] 3.1 Integrate and prove complete local browser workflows — verify: `npm --prefix Tools/harness-web run test:e2e`
  > Files: `Tools/harness-web/tests/e2e/**`, `Tools/harness-web/playwright.config.ts`, `Tools/harness-web/src/**`, `Tools/harness-web/package.json`, `Tools/harness-web/package-lock.json`

  Root integration owns combined source fixes after parallel owners finish. Capture light/dark/narrow screenshots. Typecheck and production build accompany this cross-boundary proof.

  Evidence: final `npm --prefix Tools/harness-web run check` passed TypeScript, all 55 unit tests (15 adapter, 27 documents, 13 UI), production build and 9/9 Chromium workflows. This final batch includes immediate editor saves, revision conflicts/manual merges, delayed-workspace width restoration, stable source highlights and Git-ignored watcher pruning. Browser writes stayed in isolated temporary Git fixtures. Production real-workspace browsing was read-only.

- [x] 3.2 Document operation, sources and verification evidence — verify: `npm --prefix Tools/harness-web run build`
  > Files: `Tools/harness-web/README.md`, `Tools/PullReference/PullReference.bat`, `Reference/README.md`, `openspec/specs/harness/web/**`, `openspec/changes/harness/feature-web-workbench/attachments/**`

  Register and pin the two research repositories; record actual test outcomes and omitted UE checks. Synchronize durable specs and archive only after all proofs pass.

  Evidence: production build passed in the final check batch; operation and batch-verification documentation is complete. Reference registry list, exact pinned SHAs, SSH origins, MIT licenses and clean reference checkouts passed. Current `harness/web` capability was created through the portable CLI and synchronized; strict current-spec validation passed 15/15. Attachment data records final content identity, executed checks, the unrelated repository-wide language-check failure and omitted Unreal gates.

- [x] 3.3 Improve record document navigation and workbench layout density — verify: `npm --prefix Tools/harness-web run test:e2e`
  > Files: `Tools/harness-web/src/client/pages/RecordsPage.tsx`, `Tools/harness-web/src/client/pages/DocumentsPage.tsx`, `Tools/harness-web/src/client/components/**`, `Tools/harness-web/src/client/styles.css`, `Tools/harness-web/tests/ui/**`, `Tools/harness-web/tests/e2e/**`, `Tools/harness-web/README.md`

  The user's visual feedback replaces horizontal record document tabs with a searchable vertical file explorer and reduces excessive page/body margins. Preserve file and record URLs, filters, drafts, readable filenames, active selection, archives and narrow-screen access. Use the existing file-tree and layout libraries. Capture representative desktop/narrow screenshots, then batch UI, type and browser/build verification after related edits are complete. Preserve earlier completed tasks and refresh closure identity only after this follow-up passes.

  Evidence: the final refinement batch passed all 59 unit tests, full TypeScript and production build. All 11 Chromium workflows then passed using the already built application (`npm.cmd --ignore-scripts run test:e2e` from the package, avoiding a redundant build after a test-only responsive-transition wait correction). New browser coverage proves vertical file selection, nested/long names, preserved record filters, desktop gutters/body geometry, narrow-pane reading and mobile picker interaction preserving a live editor. Desktop and mobile screenshots were captured from actual and isolated workspaces.

- [x] 3.4 Keep external archive moves compatible with Windows file watching — verify: `npm --prefix Tools/harness-web run test:adapter`
  > Files: `Tools/harness-web/src/server/workspace.ts`, `Tools/harness-web/tests/adapter/**`, `Tools/harness-web/README.md`

  Resolve issue-20260905-110535-windows-archive-watch. Use bounded Windows polling without mutating process-wide environment; retain Git ignored pruning and atomic-write events. Prove an active watched Change can move and subsequent file changes still invalidate the catalog. This backend repair can run alongside 3.3; close the issue and refresh terminal identity only after the relevant proof passes.

  Evidence: `npm.cmd --prefix Tools/harness-web run test:adapter` passed 17/17 in one repair batch, including actual packaged CLI archival while the fixture service remains running, removal/addition of catalog paths, and search invalidation after editing the moved fixture file. An environment override disabling polling is rejected before opening directory handles without modifying process.env. Server TypeScript passed.
