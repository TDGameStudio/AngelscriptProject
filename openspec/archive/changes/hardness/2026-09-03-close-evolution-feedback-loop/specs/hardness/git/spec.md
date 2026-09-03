## MODIFIED Requirements

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
