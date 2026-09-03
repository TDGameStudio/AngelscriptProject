## Why

Hardness currently treats Codex Goal execution and Git checkout topology as one repository mode. That contract requires `Goal` workspaces to live under `.worktrees/<goal>` on `goal/<goal>`, even though the repository currently has registered worktrees in several locations and none of their branches use that prefix. The model leaks into PowerShell APIs, AgentConfig, Git operations, Skills, and durable specifications, and it prevents the primary checkout from reliably managing existing worktrees.

The workflow also has dogfooding, Review, Replan, and archive protocols, but no cheap status or observation path makes their results visible during ordinary work. Expensive repository and submodule scans are hidden behind common status routes, task cards often lack local execution context, and Codex-specific context restoration is not connected to the cross-client Hardness contract.

## What Changes

- Replace `Goal`/`Current` repository modes with one Git-derived workspace context. Codex `/goal` remains an external continuation facility and never affects workspace identity, branch naming, or repository authority.
- Treat every registered worktree in the same Git common directory as a valid workspace. New worktrees use `.worktrees/<name>` and default the branch directly to `<name>`.
- Separate the checkout that supplies the Hardness implementation from the checkout targeted by a command.
- Introduce AgentConfig schema v2 without `WorkspaceKind` or `GoalName`, preserve user configuration during explicit bootstrap, rebind the selected project file, and remove the obsolete configured Hazelight reference path.
- Split fast workspace/status queries from explicit detailed dirty/submodule inspection, with bounded session-local caching of stable facts.
- Replace Goal-specific Git commit/integration APIs with exact workspace-root and source-HEAD contracts while preserving explicit push, integration, and removal authority.
- Add compact Hardness status, observation, evolution, and lifecycle-timing surfaces. Raw events remain ignored; self-hosting Changes retain one trimmed workflow evaluation before completed closure and archive.
- Remove automatic Incident/Final Review scheduling. Diagnose discovered problems directly, replan only when planning truth becomes invalid, and archive verified work without Review ceremony unless the user or an external agent explicitly requested Review.
- Keep the machine-readable Task DAG unchanged while allowing task cards to carry concise optional `Context`, `Constraints`, `Inputs`, `Produces`, `Watch`, `Notes`, or `Evidence` details when useful.
- Make pre-Change exploration and visual explanation triggers explicit without invoking them for routine work.
- Add optional low-cost Codex `SessionStart` and `SubagentStart` hooks that consume the same Hardness status contract without becoming required by Cursor or Grok.
- Add an OpenSpec maintenance status and self-upgrade path while keeping `Tools/openspec` as the source submodule and avoiding an executable release in this Change.

## Capabilities

### New Capabilities

- None. The work strengthens the existing Hardness domain rather than introducing a separate product domain.

### Modified Capabilities

- `hardness/core`: Replace repository modes with a single workspace-aware router; add visible evolution, timing, authoring, Explore/visual, hook, and OpenSpec-maintenance contracts.
- `hardness/workspace`: Accept every registered workspace, introduce fast and detailed status, default new branch names directly from workspace names, and migrate AgentConfig to schema v2.
- `hardness/git`: Replace Goal-specific commit and integration inputs with exact workspace roots, branches, repository scopes, and reviewed source heads.

## Impact

- Parent repository only; no Unreal plugin submodule implementation changes.
- Public PowerShell contracts in `hardness`, `workspace-lifecycle`, and `git-operations` change intentionally and do not retain a second Goal/Current compatibility model.
- Live Skills, workflow configuration, AGENTS guidance, and Hardness specifications move to workspace terminology. Archived Changes remain immutable historical records.
- Existing registered worktrees are not moved, renamed, integrated, pushed, removed, or bulk-reconfigured.
- Current unrelated main-workspace modifications are preserved and excluded from scoped commits.
- The bundled OpenSpec executable is not rebuilt or committed.
