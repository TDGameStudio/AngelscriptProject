---
name: workspace-lifecycle
description: Manage minimal AngelscriptProject replicas, selected plugin worktrees and snapshots, Harness-owned configuration, workspace identity, verification and explicit safe removal. Preserve existing parent Git worktrees in place; route commits and integration to git-operations.
---

# Workspace Lifecycle

- Use the current workspace unless the user explicitly requests creation or selection. The primary workspace is both control center and a full execution workspace.
- Import Harness once; use `workspace.list/status/new/prepare/bootstrap/verify/remove`, `workspace.activate`, and `workspace.config.status/get/set`.
- Load [worktrees](references/worktrees.md) for creation, plugin preparation, verification or removal; [agent config](references/agent-config.md) for local settings and execution guards.
- New `.workspaces/<name>/` roots contain minimal engineering files and no parent Git worktree. Edited plugins use their own worktrees; needed unmodified plugins use pinned committed file snapshots; omit unrelated plugins.
- Snapshot current allowlisted host files and record hashes. Pin plugin primary-directory HEADs at creation; exclude uncommitted plugin edits. Prepare later approved dependencies from those pinned baselines, never silently refresh source files.
- Validate the local descriptor against the primary registry. Resolve nested plugin directories to the containing execution workspace; canonical OpenSpec and shared Skills stay in the primary workspace.
- Preserve existing parent Git worktrees, paths and branches. They remain inspectable/bootstrap-compatible but are parked outside the new queue workflow.
- Reject reparse-backed paths and identity mismatches. Preserve dirty source, unknown payload and ignored runtime data; removal requires explicit intent, clean source and explicit discard of local outputs.
- Creation/bootstrap never creates a Change, configures a queue, commits, integrates, pushes, builds or tests. Exact Git operations belong to `git-operations`.
