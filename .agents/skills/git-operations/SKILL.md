---
name: git-operations
description: Inspect and commit exact AngelscriptProject workspace changes across the parent repository and top-level submodules, integrate a reviewed linked workspace, or perform a user-requested non-force push. Do not use for worktree lifecycle or branch/worktree deletion.
---

# Git Operations

- Harness selects the workspace and authority.
- Use `git.status`, `git.commit`, `git.integrate`, or explicitly authorized `git.push`; never bypass the selected context with an implicit repository root.

Load only the relevant reference:

- [commits.md](references/commits.md) for exact scoped workspace commits.
- [integration.md](references/integration.md) for reviewed linked-workspace-to-primary integration.

Safety invariants:

- Commits require an exact `WorkspaceRoot` and exact repository/path scopes.
- Replicas expose only their editable plugin repositories; snapshots and the project root are not Git commit targets.
- Lifecycle Create/Replan commits accepted formal planning under their exact Gates. Final `harness.change.close` composes plugin and canonical parent commits from its explained selection, preserving outside staging. Replica plugin results and primary canonical records retain their separate roots; parent paths/gitlinks are selected explicitly, never inferred from queue authority.
- Exact scoped commits run normal hooks against an isolated candidate index.
  - Lifecycle selections use the WhatIf `PlanRevision` as `ExpectedPlanRevision`; explicit `RepositoryPatches` select attributable hunks inside mixed files. Changed baseline/content/intent or a hook rewriting approved bytes rejects that exact candidate and requires a fresh preview.
  - A hook cannot widen the accepted commit or pollute the live index; a failed candidate restores the affected repository ref/index boundary when its compare-and-swap still owns the attempted ref.
- Hooks are arbitrary programs: report exact residual worktree paths and external effects, but never overwrite them while claiming rollback.
- `AllChanges` requires explicit intent, an exact registered linked worktree, and a preview of included non-ignored paths.
- Reject unrelated pre-staged content and never force-add ignored local configuration.
- Use actual checked-out branches; detached repositories require explicit `TargetBranches` entries.
- Generic parent commits record selected submodule gitlinks after plugin commits.
  - `PluginsOnly` never adds parent scopes or changes the parent HEAD.
- Integrate only an exact registered `SourceWorkspaceRoot` and reviewed source HEAD, with explicit target branches and a complete preview.
- Commit and integration preserve source commits, branches/worktree, unrelated target changes, and all remote state.
- Push only through an explicit user-requested `git.push`; never force push, delete branches, or remove worktrees as a Git operation side effect.

- Workspace creation, bootstrap, configuration, verification, activation, and removal belong to `workspace-lifecycle`.
