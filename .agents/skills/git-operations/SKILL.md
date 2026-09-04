---
name: git-operations
description: Inspect and commit exact AngelscriptProject workspace changes across the parent repository and top-level submodules, integrate a reviewed linked workspace, or perform a user-requested non-force push. Do not use for worktree lifecycle or branch/worktree deletion.
---

# Git Operations

Harness selects the workspace and authority. Use `git.status`, `git.commit`, `git.integrate`, or explicitly authorized `git.push`; never bypass the selected context with an implicit repository root.

Load only the relevant reference:

- [commits.md](references/commits.md) for exact scoped workspace commits.
- [integration.md](references/integration.md) for reviewed linked-workspace-to-primary integration.

Safety invariants:

- Commits require an exact `WorkspaceRoot` and exact repository/path scopes.
- Exact scoped commits run normal hooks against an isolated candidate index. A hook cannot widen the accepted commit or pollute the live index; a failed candidate restores the affected repository ref/index boundary when its compare-and-swap still owns the attempted ref.
- Hooks are arbitrary programs: report exact residual worktree paths and external effects, but never overwrite them while claiming rollback.
- `AllChanges` requires explicit intent, an exact registered linked worktree, and a preview of included non-ignored paths.
- Reject unrelated pre-staged content and never force-add ignored local configuration.
- Use actual checked-out branches; detached repositories require explicit `TargetBranches` entries.
- Commit dirty submodules before the parent records their gitlinks.
- Integrate only an exact registered `SourceWorkspaceRoot` and reviewed source HEAD, with explicit target branches and a complete preview.
- Commit and integration preserve source commits, branches/worktree, unrelated target changes, and all remote state.
- Push only through an explicit user-requested `git.push`; never force push, delete branches, or remove worktrees as a Git operation side effect.

Workspace creation, bootstrap, configuration, verification, activation, and removal belong to `workspace-lifecycle`.
