## Why

OpenSpec records currently require switching between raw files and command output. The accepted Harness Web plan calls for a local browser workbench that connects specifications, tasks, dependencies, evidence and safe Markdown authoring.

## What Changes

- Add a Node.js and TypeScript application under `Tools/harness-web`, with a React interface and Fastify local server.
- Read active OpenSpec records and authoritative task plans using a narrowly allowed packaged native CLI adapter. Index archives and project Markdown without creating a second task database.
- Add Chinese navigation, light/dark themes, search, rich Markdown editing, task lists/boards/DAG and factual charts.
- Provide a vertical, searchable Change document explorer and a desktop layout that gives available width to document work instead of excessive outer margins or competing record rails.
- Protect machine syntax, immutable evidence and external edits. Keep filesystem and process access scoped to the selected workspace.

## Capabilities

### New Capabilities

- `harness/web`: Local OpenSpec browsing, protected Markdown editing and factual task visualization.

### Modified Capabilities

None. The web adapter is a documented product-specific native read exception; ordinary agent and Unreal invocation boundaries remain unchanged.

## Impact

Parent repository only: new tool, focused OpenSpec adapter guidance, reference registry entries, and this change's records. No plugin or host runtime changes. No workflow execution, arbitrary terminal, remote access, accounts, automatic commits or worktree lifecycle actions. Reference clones are research-only and excluded from runtime dependencies.
