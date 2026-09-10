# Harness Web

A local workbench for reading OpenSpec, exploring task dependencies, and editing project Markdown. The interface is Chinese-first, with light and dark themes and workspace-specific navigation preferences.

The selected Git workspace remains the source of truth. OpenSpec records, task state, and Markdown stay in their existing files; Harness Web keeps disposable indexes in memory and unsaved drafts in the browser.

## Run locally

Requirements:

- Node.js 24 or newer and npm.
- Git available on `PATH`.
- An existing Git workspace with `openspec/project.yaml`.
- For active OpenSpec views, the workspace's packaged `.agents/skills/openspec/bin/openspec.exe`. The current native adapter targets the repository's Windows executable.

On Windows, double-click the launchers in `Tools/harness-web`:

| File | Action |
| --- | --- |
| `Start.bat` | Start the workbench in the background if it is not running. Already running is success. |
| `Open.bat` | Start if needed, wait until ready, then open **http://127.0.0.1:4310** in the default browser. |
| `Stop.bat` | Stop this workbench on port 4310. Does not kill unrelated Node processes. |
| `Status.bat` | Print `running`, `starting`, `stopped`, or a port conflict, plus PID, URL, and workspace. |

`Open.bat` waits if a start is already in progress. `Start.bat`, `Stop.bat`, and `Status.bat` pause so a double-clicked window can be read; `Open.bat` closes after the browser opens, and pauses only on failure. Logs and the tracked process id stay under ignored `.cache/`. PowerShell 7 (`pwsh.exe`) is required.

The same actions can be invoked without the pause:

```powershell
pwsh.exe -NoProfile -File Tools/harness-web/scripts/HarnessWeb.ps1 -Action Start
pwsh.exe -NoProfile -File Tools/harness-web/scripts/HarnessWeb.ps1 -Action Open
pwsh.exe -NoProfile -File Tools/harness-web/scripts/HarnessWeb.ps1 -Action Status
pwsh.exe -NoProfile -File Tools/harness-web/scripts/HarnessWeb.ps1 -Action Stop
```

To start from a shell instead of the launchers, run these commands from the repository root. On Windows PowerShell, use **`npm.cmd`** so forwarded script arguments reach the application unchanged. On other shells, use `npm` instead.

```powershell
npm.cmd --prefix Tools/harness-web ci
npm.cmd --prefix Tools/harness-web run dev
```

Open **http://127.0.0.1:4310**. Development runs Fastify and Vite middleware together on that port. The terminal prints the selected workspace; `Ctrl+C` stops the server.

To select a different existing workspace or another port:

```powershell
npm.cmd --prefix Tools/harness-web run dev -- --workspace "D:\Workspace\AngelscriptProject" --port 4311
```

Without `--workspace`, the launcher discovers the Git/OpenSpec root containing this tool. The workspace selector in the interface opens navigation/search; selecting a different server workspace requires restarting with `--workspace`.

For the compiled application:

```powershell
npm.cmd --prefix Tools/harness-web run build
npm.cmd --prefix Tools/harness-web run start -- --workspace "D:\Workspace\AngelscriptProject" --port 4310
```

`build` writes the client and server to ignored `dist/` output. `start` serves that built client without Vite. Dependencies and fonts are bundled locally; no reference checkout is required to run or build the workbench.

## Working in the interface

| View      | Available actions                                                                                                                             |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Overview  | Inspect active Change/spec/archive counts, task-state distribution, domains, record creation/archive events, and recently modified documents. |
| Changes   | Filter active records, read planning artifacts and evidence, and inspect artifact availability alongside actual task progress.                |
| Specs     | Navigate current capabilities and their Markdown documents.                                                                                   |
| Tasks     | Switch between list, board, and dependency graph; select a task to see prerequisites, affected files, and its recorded verification command.  |
| Documents | Filter the file tree, follow local Markdown links, read tables/code/Mermaid, and edit supported body sections.                                |
| Skills    | Browse Markdown under `.agents/skills/`, including `SKILL.md` prompts and reference notes.                                                    |
| Archives  | Browse historical records and closure kinds with immutable document access.                                                                   |

Use `Ctrl+K` to search document titles, paths, and body content. Search supports Chinese substring matching. Arrow keys select a result and Enter opens the matching document. Selections and filters are represented in URLs; the browser Back/Forward buttons work across views.

The sidebar can collapse, document panels can resize, and focus mode expands the reading area. Theme, navigation selections, and layout preferences are stored locally for the selected workspace. On narrow screens the navigation becomes a drawer.

Opening a Change or archive gives its documents the available workspace width. Use the vertical file explorer to switch between proposal, design, tasks, nested specs and evidence; its filter expands matching folders and the selected file stays highlighted. **返回记录** restores the previous record filters, while **切换记录** changes the selected record directly. Desktop gutters and reading headers are compact, and the chapter outline folds when its document pane is narrow. On phones, **选择文档** and **选择工作区文档** expand the appropriate file picker without remounting the current editor.

Task cards and dependency edges are inspection surfaces. Task completion and dependency changes remain part of the existing OpenSpec workflow. A recorded verification command is displayed as text and is never executed by the workbench.

## Editing and conflict recovery

Choose **编辑** in an editable document to open the Milkdown Crepe editor. Ordinary body content supports GFM headings, paragraphs, lists, quotes, tables, links, images, and fenced code. Save explicitly with **保存** or `Ctrl+S`; **查看差异** compares your current text with the saved version.

The shared document envelope protects YAML/TOML frontmatter, machine task headers, `Files` lines, and raw or unsupported syntax blocks. These appear as protected sections around editable body segments. Task checkboxes are not interactive workflow controls. Scenario Card details retain their nesting under the owning behavior clause.

An unchanged document retains its original bytes. Protected sections retain their original source, and the envelope preserves the document's BOM and newline policy. Edited body segments pass through Markdown serialization, so formatting within a changed segment can normalize. This is a body editor rather than a general-purpose source editor for every Markdown extension; edit protected structures through their owning project workflow.

Unsaved drafts use IndexedDB, keyed by workspace and path. They can recover after navigation or reopening the page in the same browser origin. Drafts are local browser data, not Git history or a backup service; changing browser profiles, ports, or clearing site data can make them unavailable.

If an external editor changes the file, live updates preserve a dirty draft. A save against an outdated revision returns the current disk version and opens the conflict panel:

1. Choose **比较版本** to inspect disk content against your draft.
2. If protected source remains compatible, choose **以磁盘版本为基准继续合并**. This adopts the current disk revision while retaining your body draft; it does **not** automatically merge competing edits.
3. Reconcile the body manually using the displayed difference, then save explicitly.
4. If protected sections have changed, download your draft, load the disk version, and transfer the body edits into that version. **放弃草稿并载入磁盘版** discards the local draft deliberately.

Server writes are serialized per path, checked against the original content hash, and replaced atomically. There are no create, delete, move, manifest-edit, or archive-operation endpoints.

## Scope and local access

The document index includes tracked and non-ignored untracked Markdown in the main repository and initialized Git submodules owned by `TDGameStudio`. Files in `Reference`, external/vendor/ThirdParty trees, dependency directories, and generated output are excluded. The application rechecks index membership and real filesystem paths when reading or saving; symlinks and directory junction aliases are not editable document paths.

Archives, applied Replans, fixed-snapshot Reviews, and hash-bound workflow evaluation documents are read-only. CLI-owned YAML manifests are never exposed through the Markdown write endpoint. The main OpenSpec views describe the selected root project's records; submodule Markdown remains discoverable through Documents.

The server binds only to `127.0.0.1`. Requests must use a loopback Host and a matching Origin when present; mutations also require the current session header. Cross-origin API access is not enabled. This is a local developer tool, with no account system or remote deployment mode.

Raw HTML is not executed in the reader, Mermaid uses strict rendering, and local images are served through an indexed raster-only endpoint. Supported local image extensions are PNG, JPEG, GIF, WebP, and AVIF; SVG is not served through that endpoint. Opening an external hyperlink remains a browser navigation.

The product adapter invokes only fixed read-only commands on the packaged OpenSpec executable, with an exact working directory, argument arrays, bounded output, and a timeout. This narrow adapter is documented in the OpenSpec Skill. It does not spawn PowerShell, install an upstream Node OpenSpec CLI, or expose arbitrary command execution. Normal agent workflow operations continue to use Harness.

## Architecture and libraries

| Layer               | Libraries and responsibility                                                                                                                                               |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Browser application | React 19, React Router, TanStack Query, Radix UI, Lucide, and react-resizable-panels provide pages, data fetching, accessible controls, and layout.                        |
| Document experience | Milkdown Crepe/ProseMirror, unified/remark/GFM, react-markdown, Mermaid, diff, and idb-keyval provide body editing, source protection, rendering, differences, and drafts. |
| Visualizations      | React Flow with Dagre renders the native Task DAG; Recharts renders factual counts and record events.                                                                      |
| Local service       | Fastify, Zod, YAML, Git, and the packaged OpenSpec CLI provide typed requests, document ownership, manifest reading, and authoritative task parsing.                       |
| Live indexes        | Chokidar publishes SSE invalidations; an in-memory document catalog and MiniSearch serve repeated browsing and search.                                                     |
| Tooling             | TypeScript, Vite, Vitest, Testing Library, Playwright, and Prettier provide compilation, focused verification, browser workflows, and formatting.                          |

`src/shared/types.ts` owns the browser/server contracts. `src/shared/documents.ts` owns protected document transformations. `src/server/` contains the native reader, workspace index, HTTP service, and launcher. `src/client/` contains the views and editor.

The API resources are `/api/workspace`, `/api/records`, `/api/record`, `/api/tasks`, `/api/documents`, `/api/document`, `/api/search`, `/api/metrics`, `/api/events`, and `/api/image`. Saves use `PUT /api/document` with `{ path, content, baseRevision }` and `X-Harness-Session`. A revision conflict is `409` with `current`; an attempted protected-source change is `422`.

## Verification

Run from the repository root. For an integrated change, prefer the single verification batch after related edits are complete:

```powershell
npm.cmd --prefix Tools/harness-web exec -- playwright install chromium
npm.cmd --prefix Tools/harness-web run check
```

The Chromium installation is needed once. `check` runs TypeScript checks, all Vitest suites, the production build, and Playwright workflows in sequence; the build comes from `pretest:e2e`. This gives one combined result without repeating the build or individual suites between small edits.

Launcher scripts are proven separately from the Node suites:

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File Tools/harness-web/tests/HarnessWeb.Launcher.Tests.ps1
```

For a bounded subsystem change, select its focused proof instead:

```powershell
npm.cmd --prefix Tools/harness-web run typecheck
npm.cmd --prefix Tools/harness-web run test:adapter
npm.cmd --prefix Tools/harness-web run test:documents
npm.cmd --prefix Tools/harness-web run test:ui
npm.cmd --prefix Tools/harness-web run build
```

To run browser verification on its own:

```powershell
npm.cmd --prefix Tools/harness-web run test:e2e
```

`test:e2e` builds automatically through its pretest script, then starts an isolated fixture service on **127.0.0.1:4320**. It does not reuse a developer server or edit production workspace documents. Test reports, failure traces, screenshots, and compiled output remain under ignored package directories. `npm.cmd --prefix Tools/harness-web test` runs the Vitest suites together; `run format:check` checks maintained formatting.

Adapter verification uses isolated Git repositories and the actual packaged executable. Document tests exercise protected-source round trips and Crepe behavior. Browser verification covers reading, navigation, real editing/saving, draft preservation, and conflicts. Unreal builds or Automation suites are outside this tool's verification scope.

## Current practical limits

- One selected Git workspace per running server; no browser-side workspace mutation or account collaboration.
- OpenSpec active-record and task parsing requires the packaged Windows executable. If it is absent, the service reports that state while preserving document and archive browsing.
- Markdown must be UTF-8 and at most 2 MiB; local images are limited to 8 MiB. Search returns at most 100 results.
- The initial catalog scan may take several seconds in a large workspace. Later queries use the cache; a file change invalidates that cache. At startup, Git identifies wholly ignored directory trees in the main repository and owned submodules so the watcher can skip them without traversing their contents. Tracked documents inside otherwise ignored directories remain watched. Generated trees, `Content`, `Config`, and `.vs` are also excluded from recursive watching. Restart the server after changing ignore rules to refresh that startup scope.
- On Windows, the workspace watcher uses polling with a default 500 ms interval so external OpenSpec archive moves can proceed while the workbench is open. This trades periodic filesystem checks and roughly one-second update latency for directory-move compatibility. Atomic writes remain normalized. If `CHOKIDAR_USEPOLLING=0` or `false` disables polling, startup reports an actionable configuration error before opening native watch handles; unset that override to start normally. The application does not change process-wide environment variables.
- `artifactComplete` means required artifact files exist. It does not mean implementation is done. Task readiness considers completed dependencies, not file/resource conflicts or scheduling leases.
- Timeline charts use recorded creation and archive timestamps. The repository has no authoritative task-completion event stream, so the workbench does not invent burn-down, velocity, or execution-duration history.
- Source files remain ordinary Git working-tree changes after a save. Committing, review, spec synchronization, UE operations, and closure remain separate project workflows.

## Research references

The information architecture was informed by two independently implemented MIT-licensed projects. No source code from these checkouts was copied into Harness Web, and neither is a build/runtime dependency.

| Reference                                                   | Pinned research commit                     | Use                                                             |
| ----------------------------------------------------------- | ------------------------------------------ | --------------------------------------------------------------- |
| [spekhq/spek](https://github.com/spekhq/spek)               | `71f109a032e2a29ccecc69b2d2ca0852522dd2d6` | OpenSpec workbench navigation and document/record organization. |
| [ToruAI/openspec-ui](https://github.com/ToruAI/openspec-ui) | `6fd5997b6ea1aea3e61cd87cd79172df4d246be0` | Change/spec browsing and task visualization patterns.           |

Their local research checkouts are `Reference/spek` and `Reference/openspec-ui`. To retrieve the registered pinned versions, use `Tools\PullReference\PullReference.bat spek` and `Tools\PullReference\PullReference.bat openspec-ui`. The central [Reference registry](../../Reference/README.md) records the sources and boundaries. Harness Web's native Task DAG semantics and protected document envelope remain project-specific.
