# Hardness Git Operations

## Purpose

This capability defines exact-workspace Git inspection and commits, reviewed local integration from a registered linked worktree into the primary workspace, and explicitly requested ordered non-force publication.

## Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the exact selected WorkspaceRoot's parent repository and top-level submodules. Every commit MUST receive exact repository/path scopes, unless the caller explicitly authorizes all non-ignored changes in that same workspace. By default, unrelated staged content MUST be rejected. For exact scoped intent only, the caller MAY explicitly select `PreserveOutsideStaged`; that mode MUST use path-only dry-run and commit semantics, MUST include only effective-scope paths in each new commit, and MUST prove that scope-external index entries remain equivalent before and after the operation. The preservation option MUST be rejected for all-change intent. Ignored configuration MUST NOT be force-added, dirty scoped submodules MUST commit before the parent records their gitlinks, and repository mode or Goal-name inputs MUST NOT exist.

#### Scenario: Reject outside staged content by default
- **WHEN** a scoped commit finds a staged path outside its effective scopes and preservation was not explicitly selected
- **THEN** the operation fails before mutation and leaves HEAD, index, and worktree unchanged

#### Scenario: Preserve outside staged content explicitly
- **WHEN** a caller supplies exact repository/path scopes and explicitly selects outside-staged preservation in a dirty primary checkout
- **THEN** preview separates selected and preserved staged paths, the path-only commit contains only effective-scope content, and the outside index fingerprint remains equivalent

#### Scenario: Preserve staged content across parent and submodule commits
- **WHEN** exact scoped changes span submodules and the parent while either repository has staged content outside its effective scope
- **THEN** all repositories pass static preflight, each scoped submodule commits before the parent, each commit is path-only, and every repository's outside index entries remain equivalent

#### Scenario: Refuse ambiguous preservation intent
- **WHEN** a caller combines `PreserveOutsideStaged` with all-change intent, an ambiguous pathspec, an unmerged index, or an unverifiable index state
- **THEN** the operation fails before the first repository commit and reports the exact rejected precondition

#### Scenario: Report resumable partial completion
- **WHEN** all static preflight passed but a later repository commit or hook fails after an earlier submodule committed
- **THEN** the operation preserves outside staged state, reports completed and pending repositories, and performs no destructive rollback

#### Scenario: Commit exact linked-worktree paths
- **WHEN** a caller targets a registered linked WorkspaceRoot with a dirty top-level submodule and parent gitlink
- **THEN** the submodule commits on its actual branch before the parent commits the resulting gitlink, without requiring a branch prefix

#### Scenario: Authorize all changes explicitly
- **WHEN** a caller selects all-change intent for one exact WorkspaceRoot
- **THEN** the preview lists every included non-ignored repository/path before commit, rejects unrelated pre-staged content, and does not expose outside-staged preservation

### Requirement: Explicit previewable local integration

Local integration SHALL require the canonical primary target, an exact registered linked source WorkspaceRoot, the reviewed expected source HEAD, and explicit parent/submodule target branches. Preview SHALL report every planned repository, source root, source/target commit, and fast-forward/merge action without changing either workspace or remote state. Integration SHALL preserve source commits, branches, worktree, unrelated target changes, and remote state.

#### Scenario: Integrate disjoint local work
- **WHEN** the primary target has only unstaged or untracked changes disjoint from the reviewed source patch
- **THEN** affected submodules integrate before the parent and the unrelated local bytes/status remain unchanged

#### Scenario: Refuse a stale or unsafe source
- **WHEN** target staged content exists, local payload overlaps incoming paths, the source is not a registered linked worktree in the same common directory, source HEAD differs from the reviewed snapshot, or a target branch is ambiguous
- **THEN** integration fails before changing the affected repository

### Requirement: Merge-based resumable multi-repository integration

Each affected repository SHALL fast-forward when possible and otherwise create a non-fast-forward merge that retains the reviewed source commits. The parent merge SHALL record the final integrated submodule heads. Only a gitlink conflict whose selected commit contains both sides MAY be resolved automatically. Ordinary conflicts SHALL abort the current repository merge and report a resumable partial result without destructive rollback.

#### Scenario: Resume after a later repository conflict
- **WHEN** earlier submodules integrated successfully but a later repository reports an ordinary conflict
- **THEN** a repeated integration recognizes completed submodules, does not duplicate their merges, and continues only after the conflicting repository is resolved or the plan changes

#### Scenario: Keep delivery authority separate
- **WHEN** local integration completes
- **THEN** no push, publication, branch deletion, or worktree removal has occurred

### Requirement: Explicit ordered non-force push

`git.push` SHALL run only after an explicit user push or publication request and SHALL require an exact repository-to-local-branch map and remote for the selected workspace. Preview MUST perform no remote mutation. A real multi-repository push MUST publish required submodule commits before the parent branch, MUST reject a parent gitlink that is neither known remote-reachable nor included in the push plan, and MUST NOT expose implicit force, deletion, integration, or worktree cleanup.

#### Scenario: Publish an exact branch map
- **WHEN** the user explicitly requests push and the parent branch references new submodule commits
- **THEN** the caller names those actual local branches, the route pushes submodules before the parent, and every push is a normal non-force ref update

#### Scenario: Keep cleanup separate after push
- **WHEN** push completes
- **THEN** source branches and worktrees still exist until the user separately requests cleanup
