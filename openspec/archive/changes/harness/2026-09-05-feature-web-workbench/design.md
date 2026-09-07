## Context

The accepted plan selects a local, Chinese-first engineering workbench with WYSIWYG body editing. Existing Task DAG parsing belongs to the packaged Rust CLI; archive listings require a separate read-only manifest index. Artifact isComplete is not task completion.

## Decisions

- One npm package, Node >=24, React/Vite client, Fastify server, shared TypeScript contracts. Development uses Vite middleware and production serves the built client. No database or workflow daemon is introduced.
- The native product adapter uses fixed packaged EXE, cwd, read-only argument arrays and bounded execution. It never spawns PowerShell or installs an upstream Node OpenSpec. This narrow exception is added to the OpenSpec entry skill.
- API resources are `/api/workspace`, `/api/records`, `/api/record`, `/api/tasks`, `/api/documents`, `/api/document`, `/api/search`, `/api/metrics`, `/api/events`, and constrained local images. Record IDs include kind/path so historical copies remain distinct. Document saves supply path, content and baseRevision.
- Files are scoped to owned Git content, including initialized TDGameStudio submodules; Reference, external/vendor/dependency, generated and ignored content are excluded. Archives and immutable workflow evidence are read-only. No create/delete/move endpoints.
- Milkdown Crepe edits ordinary body segments. A shared source-envelope layer retains frontmatter, machine task headers/Files lines and opaque syntax as protected blocks; segment boundaries cannot be deleted through rich-text commands. Supported segment content uses GFM and preserves Scenario nesting. No-edit export returns original text. Partial serialization preserves protected bytes and newline/BOM policy.
- Frontend pages are overview, changes, specs, tasks, documents and archives. React Flow/Dagre renders one Change DAG, Recharts renders actual counts/time events, Mermaid uses strict local rendering. Selection and filters are URL state. Drafts use IndexedDB, preferences localStorage.
- Saving is explicit, revision checked, per-path serialized and atomically replaced. Watcher invalidations use SSE; they never overwrite a dirty document. Local requests enforce Host, Origin and a session header on mutations. Rendering does not execute raw HTML.
- On Windows the workspace watcher uses bounded polling over the permitted tree, because native directory watch handles prevent external Change directory moves. Polling must preserve external archive operations while the service remains running and continue to invalidate moved documents.
- Theme uses slate surfaces, blue focus, teal completion and amber waiting. Two-column workbench plus optional detail rail; headers IBM Plex Sans, body Chinese system fonts, code JetBrains Mono. Assets are locally bundled.
- After visual feedback, selected records use a full-width detail workspace: a compact back/record-switch header, a vertical searchable document explorer and the reading pane. The unselected record list remains available through back navigation; existing URL filters and explicit document links remain authoritative. Shared page gutters and toolbar spacing favor available working area. Long file paths wrap, the active file is explicit, and narrow screens stack the explorer without horizontal page overflow.

## Verification and boundaries

Isolated fixtures exercise the native CLI adapter, safe file operations, semantic Markdown round trips and real browser navigation/editing. No production workspace writes during browser verification. Missing EXE makes OpenSpec views explicitly unavailable but permits safe document browsing. No task-history inference, terminal, workflow operations, account system, UE commands, or runtime plugin edits.

## References

Read-only research sources are spekhq/spek and ToruAI/openspec-ui. Record pinned commits and MIT licenses under Reference; use them for information architecture only. Our portable Task DAG semantics and protected editor remain independent.
