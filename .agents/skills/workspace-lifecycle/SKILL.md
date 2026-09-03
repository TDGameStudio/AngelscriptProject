---
name: workspace-lifecycle
description: Manage canonical AngelscriptProject Current and Goal workspaces, exact submodule bootstrap, Hardness-owned AgentConfig.ini, session workspace selection, verification, and explicit safe removal. Do not use for commits, branch integration, push, or publication.
---

# Workspace Lifecycle

Hardness selects `Current` or `Goal` mode and dispatches every operation. Import Hardness once; use `workspace.status/new/bootstrap/verify/remove`, `workspace.activate`, and `workspace.config.status/get/set`.

Load only the relevant reference:

- [worktrees.md](references/worktrees.md) for creation, bootstrap, verification, and removal.
- [agent-config.md](references/agent-config.md) for local configuration, workspace identity, activation, and execution guards.

Safety invariants:

- Resolve the canonical primary checkout and registered Git worktrees before mutation.
- Goal worktrees are direct children of ignored `.worktrees/` and use `goal/<goal>`.
- Restore each top-level submodule at the exact parent gitlink; preserve dirty or payload-bearing paths.
- Reject reparse-backed workspace paths and unsafe module-store redirection.
- Treat ignored files as user data; removal needs explicit discard intent.
- Never create OpenSpec records, commits, merges, pushes, builds, or tests as a workspace lifecycle side effect.

Git change inspection, commits, and local integration belong to `git-operations`.
