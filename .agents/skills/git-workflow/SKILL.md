---
name: using-git-worktrees
description: Safe workspace lifecycle for AngelscriptProject. Use when Goal mode needs an isolated worktree, when bootstrapping exact submodule gitlinks, inspecting or verifying workspace state, committing a finished goal, or explicitly removing a clean worktree.
---

# Git Workspace Lifecycle

Hardness chooses the mode. Goal mode defaults to `.worktrees/<goal>` on `goal/<goal>`; Current mode stays in the current checkout. Never create a worktree merely because implementation work exists.

Import the dispatcher once and use `workspace.status/new/bootstrap/verify/finish/remove`. Direct compatibility scripts live in `scripts/`; [git-worktree.md](git-worktree.md) contains examples.

Safety invariants:

- Resolve the repository from the installed script path unless an explicit root is supplied.
- `.worktrees/` must be ignored; target names cannot escape it.
- Initialize every top-level project submodule at the exact parent gitlink. Local object-store fallback is detached at that exact commit.
- Never delete, overwrite, or move a dirty submodule. Preserve failed worktrees for recovery.
- Copy `AgentConfig.ini` only when the destination ignores it.
- Worktree creation never scaffolds OpenSpec records or runs a build.
- Finish commits dirty submodules before staging their parent gitlinks, then verifies a clean exact state.
- Finish never runs on the primary checkout and never merges, pushes, or removes. Remove is a separate explicit operation; it refuses dirty, unregistered, or reparse-point targets and requires `-DiscardIgnoredFiles` before deleting ignored local data.

The plugin and `Tools/openspec` directories are submodules. Their source commits must exist before the parent records new gitlinks. Follow [git-commit.md](git-commit.md) for messages.
