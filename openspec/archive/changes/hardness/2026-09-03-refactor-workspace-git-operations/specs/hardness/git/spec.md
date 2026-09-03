## ADDED Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the parent repository and its top-level submodules. Current mode MUST require exact repository/path scopes. Goal mode MAY include every non-ignored change only with explicit all-change intent. Unrelated staged content MUST be rejected, ignored configuration MUST NOT be force-added, and dirty submodules MUST commit before the parent records their gitlinks.

#### Scenario: Commit in Current mode
- **WHEN** a caller supplies exact repository/path scopes in a dirty primary workspace
- **THEN** only those paths commit and unrelated staged, unstaged, untracked, ignored, and submodule content remains unchanged

#### Scenario: Commit a Goal with submodule changes
- **WHEN** a Goal scope includes a dirty top-level submodule and parent paths
- **THEN** the submodule commits on its dedicated Goal branch before the parent commits the resulting gitlink

### Requirement: Explicit previewable local integration

Local integration SHALL require the canonical primary workspace, a registered clean/exact Goal source, the reviewed expected source HEAD, and explicit parent/submodule target branches. Preview SHALL report every planned repository, path, source/target commit, and fast-forward/merge action without mutation. Integration SHALL preserve Goal commits, source branches, source worktree, unrelated target changes, and remote state.

#### Scenario: Integrate disjoint local work
- **WHEN** the primary workspace has only unstaged or untracked changes disjoint from the reviewed Goal patch
- **THEN** affected submodules integrate before the parent and the unrelated local bytes/status remain unchanged

#### Scenario: Refuse unsafe target state
- **WHEN** target staged content exists, local payload overlaps incoming paths, the source HEAD differs from the reviewed snapshot, or a target branch is ambiguous
- **THEN** integration fails before changing the affected repository

### Requirement: Merge-based resumable multi-repository integration

Each affected repository SHALL fast-forward when possible and otherwise create a non-fast-forward merge that retains the Goal commits. The parent merge SHALL record the final integrated submodule heads. Only a gitlink conflict whose selected commit contains both sides MAY be resolved automatically. Ordinary conflicts SHALL abort the current repository merge and report a resumable partial result without destructive rollback.

#### Scenario: Resume after a later repository conflict
- **WHEN** earlier submodules integrated successfully but a later repository reports an ordinary conflict
- **THEN** a repeated integration recognizes the completed submodules, does not duplicate their merges, and continues only after the conflicting repository is resolved or the plan changes

#### Scenario: Keep delivery authority separate
- **WHEN** local integration completes
- **THEN** no push, publication, branch deletion, or worktree removal has occurred

### Requirement: Explicit ordered non-force push

`git.push` SHALL run only after an explicit user push/publication request and SHALL require an exact repository-to-local-branch map and remote. Preview MUST perform no remote mutation. A real multi-repository push MUST publish required submodule commits before the parent branch, MUST reject a parent gitlink that is neither known remote-reachable nor included in the push plan, and MUST NOT expose an implicit force, deletion, or worktree-cleanup behavior.

#### Scenario: Publish an integrated multi-repository change
- **WHEN** the user explicitly requests push and the parent branch references new submodule commits
- **THEN** the caller names those submodule branches, the route pushes them before the parent, and every push is a normal non-force ref update

#### Scenario: Keep cleanup separate after push
- **WHEN** push completes
- **THEN** source branches and worktrees still exist until the user separately requests their cleanup
