## Context

Hardness already resolves Goal and Current contexts and checks canonical registered worktrees. The Workspace module already has substantial protections around reparse points, exact gitlinks, dirty submodules, ignored payload, and object-store fallback. Those protections must survive intact while commit behavior moves to a dedicated leaf.

The build/test layer already uses project-root-scoped mutexes, per-workspace `Saved/` output, execution slots, and a worktree-aware UBT process map. The new identity guard therefore validates launch intent only; it must not serialize unrelated worktrees or disable cross-worktree diagnostics.

## Decisions

### 1. Per-workspace identity, per-session selection

Each ignored root `AgentConfig.ini` records the workspace it belongs to. The `[Hardness]` section contains schema version, workspace kind, primary root, workspace root, common Git directory, and optional Goal name. Branch and HEAD remain live Git facts and are never persisted in the INI.

The selected workspace remains a Hardness Context fact. `workspace.activate` may project that selection into process-local environment variables for child commands. There is no shared active-workspace record, so separate agents and PowerShell sessions cannot overwrite each other's selection.

### 2. Configuration projection owns workspace-derived fields

The canonical primary checkout is the only default source for machine-shared configuration. New/bootstrap preserves user-controlled fields, but Hardness always repairs its reserved identity and binds `Paths.ProjectFile` to the target root's unique `.uproject`. A missing primary configuration produces a minimal target configuration with `NeedsConfiguration` status instead of copying from an arbitrary worktree.

`workspace.config.get` reads one exact key. `workspace.config.set` edits one non-reserved key with an atomic same-directory replacement and preserves unrelated lines/comments. Hardness identity and `Paths.ProjectFile` are read-only through this generic interface.

### 3. Execution guard composes with existing multi-worktree support

Workspace-sensitive command startup compares the requested project root, registered Git top level, managed AgentConfig identity, target `.uproject`, optional Hardness session binding, and the current shell's registered workspace when discoverable. A mismatch fails before UBT, Editor, or test work begins.

Read-only multi-worktree process discovery is exempt. Existing project-root/slot mutex keys and output paths remain unchanged.

### 4. Git operations use explicit repository scopes

Current mode requires a repository-to-path scope map. Goal mode also prefers exact scopes and permits all changes only through an explicit switch. Staging never uses an unqualified root `git add -A`, never force-adds ignored configuration, and refuses unrelated pre-staged content.

Dirty submodules commit before the parent records their gitlinks. Git operations report Git facts only; OpenSpec tasks, verification, Review, and closure remain coordinator gates.

### 5. Integration preserves reviewed commits

`git.integrate` operates only from the canonical primary checkout, requires an exact reviewed source HEAD and explicit target branch mapping, and offers `WhatIf`. It rejects staged target content and any overlap between the incoming changes and target local payload. Disjoint unstaged/untracked changes are inventoried and preserved.

Affected submodules integrate first by fast-forward when possible or `--no-ff` merge when histories diverge. The parent then performs a non-fast-forward merge and records the resulting submodule target heads. Only a gitlink conflict whose selected commit contains both histories may be resolved automatically. Ordinary conflicts abort the current repository merge and are reported; prior safe repository integrations remain resumable and idempotent.

### 6. Push and worktree cleanup remain explicit

Local integration never pushes or removes a worktree. `git.push` exists only for an explicit user push/publication request, requires an exact repository-to-branch map and remote, previews without network mutation under `WhatIf`, pushes required submodules before the parent, and never supplies a force option. `workspace.remove` remains the separate explicitly requested cleanup route and retains every ignored-data and exact-state guard.

## Risks / Trade-offs

- Cross-repository Git operations cannot be physically atomic. Preflight, strict ordering, compare-and-select behavior, and idempotent resume avoid destructive rollback.
- Process-local activation protects child commands but cannot identify intent after a caller deliberately clears or replaces the environment. The direct command fallback still catches the common case where the shell is in one registered worktree and invokes another worktree's script.
- Root guidance and shared PowerShell files already contain unrelated user changes. Implementation must stage only exact change hunks.
- Removing compatibility entry points is intentionally disruptive while Skills are disabled; every live non-historical reference must move in the same change.
