---
name: git-operations
description: Inspect and commit exact AngelscriptProject changes across the parent repository and top-level submodules, explicitly integrate a reviewed Goal, or perform a user-requested non-force push. Do not use for worktree lifecycle or branch/worktree deletion.
---

# Git Operations

Hardness selects the workspace and authority. Use `git.status`, `git.commit`, `git.integrate`, or explicitly authorized `git.push`; never bypass the selected context with an implicit repository root.

Load only the relevant reference:

- [commits.md](references/commits.md) for scoped Current/Goal commits.
- [integration.md](references/integration.md) for reviewed Goal-to-primary local integration.

Safety invariants:

- Current commits require exact repository/path scopes.
- Goal-wide staging requires explicit `AllChanges` intent.
- Reject unrelated pre-staged content and never force-add ignored local configuration.
- Commit dirty submodules before the parent records their gitlinks.
- Integrate only an exact reviewed source HEAD, with explicit target branches and a complete preview.
- Commit and integration preserve Goal commits, source branches/worktree, unrelated target changes, and all remote state.
- Push only through an explicit user-requested `git.push`; never force push, delete branches, or remove worktrees as a Git operation side effect.

Workspace creation, bootstrap, configuration, verification, activation, and removal belong to `workspace-lifecycle`.
