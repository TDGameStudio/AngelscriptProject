## MODIFIED Requirements

### Requirement: Progressive skill routing

Hardness SHALL remain the single short entry for project Skills and SHALL route workspace lifecycle and Git mutation to separate leaf modules. Workspace lifecycle routes SHALL NOT create commits or integrate branches. Git operation routes SHALL NOT create, bootstrap, remove, or globally select worktrees.

#### Scenario: Route workspace lifecycle
- **WHEN** an agent requests `workspace.*`
- **THEN** Hardness loads only `workspace-lifecycle` and the operation cannot commit, merge, push, or delete a branch

#### Scenario: Route Git operations
- **WHEN** an agent requests `git.*`
- **THEN** Hardness loads only `git-operations` plus its read-only workspace identity dependency and the operation cannot create or remove a worktree

### Requirement: Ready-to-integrate finish state

A successful Goal SHALL reach committed, verified, reviewed, and ready-to-integrate while preserving its branch and worktree. `git.commit` MAY establish the scoped Git commit fact. `git.integrate` MAY run only after explicit user authorization against the exact reviewed source HEAD and SHALL NOT push, delete branches, or remove worktrees. `git.push` and `workspace.remove` SHALL remain distinct later operations that each require an explicit user request.

#### Scenario: Commit a successful Goal
- **WHEN** approved Goal paths are ready for Git closure
- **THEN** `git.commit` commits dirty submodules before the parent gitlinks and reports Git state without claiming verification or Review completion

#### Scenario: Integrate after explicit authorization
- **WHEN** the user explicitly requests local integration of the reviewed Goal
- **THEN** `git.integrate` audits primary-workspace overlap, preserves unrelated local changes, integrates affected submodules before the parent, and leaves remote state and the source workspace unchanged
