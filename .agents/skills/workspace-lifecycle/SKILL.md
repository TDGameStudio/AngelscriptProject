---
name: workspace-lifecycle
description: Manage Git-registered AngelscriptProject workspaces, exact submodule bootstrap, Hardness-owned AgentConfig.ini, process-local workspace selection, verification, listing, and explicit safe removal. Do not use for commits, branch integration, push, or publication.
---

# Workspace Lifecycle

Hardness derives workspace identity from Git and dispatches every operation. Import Hardness once; use `workspace.list/status/new/bootstrap/verify/remove`, `workspace.activate`, and `workspace.config.status/get/set`.

Load only the relevant reference:

- [worktrees.md](references/worktrees.md) for creation, bootstrap, verification, and removal.
- [agent-config.md](references/agent-config.md) for local configuration, workspace identity, activation, and execution guards.

Safety invariants:

- Resolve the canonical primary checkout and registered Git worktrees before mutation.
- Accept existing registered worktrees in place, regardless of their path or branch naming convention.
- Create new worktrees beneath ignored `.worktrees/`; the default branch is exactly the requested name.
- Restore each top-level submodule at the exact parent gitlink; preserve dirty or payload-bearing paths.
- Reject reparse-backed workspace paths and unsafe module-store redirection.
- Treat ignored files as user data; removal needs explicit discard intent.
- Never create OpenSpec records, commits, merges, pushes, builds, or tests as a workspace lifecycle side effect.

Git change inspection, commits, and local integration belong to `git-operations`.
