## MODIFIED Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the exact selected WorkspaceRoot's parent repository and top-level submodules. Every commit MUST receive exact repository/path scopes, unless the caller explicitly authorizes all non-ignored changes in that same workspace. By default, unrelated staged content MUST be rejected. Every exact-scope commit MUST use path-only semantics, MUST run normal Git hooks against the candidate commit, MUST include only effective-scope paths, and MUST preserve scope-external index entries. The affected repository's ref and complete live index MUST be restored to their pre-attempt state when a hook, commit, or postcondition fails and the attempted ref still owns the compare-and-swap boundary. For exact scoped intent only, the caller MAY explicitly select `PreserveOutsideStaged`; that option additionally exposes the before/after outside-index proof and MUST be rejected for all-change intent. Ignored configuration MUST NOT be force-added, dirty scoped submodules MUST commit before the parent records their gitlinks, and repository mode or Goal-name inputs MUST NOT exist.

#### Scenario: Reject outside staged content by default
- **WHEN** a scoped commit finds a staged path outside its effective scopes and preservation was not explicitly selected
- **THEN** the operation fails before mutation and leaves HEAD, index, and worktree unchanged

#### Scenario: Isolate a hook-expanded candidate
- **GIVEN** a normal Git hook stages an outside path, creates an outside intent-to-add entry, or crosses a rename/copy scope boundary
- **WHEN** Harness attempts an exact scoped commit
- **THEN** no affected repository ref retains the candidate, the complete live index is restored byte-for-byte, and the failure names the hook isolation boundary and outside path when Git exposes it

> Observables: The pre-attempt and final HEAD, complete index bytes and semantic entries, commit path set, hook result, and exact residual worktree paths.
> Boundaries: Hooks remain arbitrary programs. Harness restores repository refs and indexes that it owns; it reports but never overwrites worktree, process, network, or repository-external hook side effects.
> Verification: Hook fixtures cover successful and failing outside staging, dynamic intent-to-add, and unchanged caller index state; candidate scope fixtures retain rename/copy boundary coverage.

#### Scenario: Accept scope-local hook changes
- **WHEN** a pre-commit hook formats and stages only an effective-scope path and a commit-message hook edits the message
- **THEN** the exact scoped commit succeeds with the hook-produced scoped content and message while outside index state remains equivalent

#### Scenario: Preserve outside staged content explicitly
- **GIVEN** the exact selected workspace contains intentionally staged work outside the requested repository/path scopes
- **WHEN** a caller supplies exact repository/path scopes and explicitly selects outside-staged preservation in a dirty primary checkout
- **THEN** preview separates selected and preserved staged paths, the path-only commit contains only effective-scope content, and the outside index fingerprint remains equivalent
- **AND** an executed result reports the outside snapshot as `Preserved`, marks the requested scope complete, and does not claim the aggregate Git state is complete
- **BUT** no scope-external path is committed, unstaged, or otherwise rewritten

> Context: This mode allows one independently staged change to remain intact while an unrelated exact scope is committed.
> Inputs: One exact `WorkspaceRoot`, explicit `RepositoryScopes`, `PreserveOutsideStaged = true`, and a commit message.
> Observables: `IncludedChanges`, `PreservedStaged`, before/after SHA-256 values, the new commit path list, and the post-operation index.
> Boundaries: Preservation applies only to exact scoped intent; it does not authorize `AllChanges` or broaden any pathspec.
> Verification: The scoped-primary fixture checks preview immutability, literal path selection, exact commit contents, outside-index equivalence, and scoped versus aggregate completion.

#### Scenario: Preserve staged content across parent and submodule commits
- **GIVEN** the parent and at least one initialized top-level submodule each contain selected changes and independently staged paths outside their effective scopes
- **WHEN** exact scoped changes span submodules and the parent while either repository has staged content outside its effective scope
- **THEN** all repositories pass static preflight, each scoped submodule commits before the parent, each commit is path-only, and every repository's outside index entries remain equivalent
- **AND** the parent commit records the newly committed submodule head while each repository reports its own preserved outside-index proof
- **BUT** staged content outside either repository's effective scope is neither included nor unstaged

#### Scenario: Refuse ambiguous preservation intent
- **GIVEN** no repository in the proposed multi-repository commit has begun mutation
- **WHEN** a caller combines `PreserveOutsideStaged` with all-change intent, an ambiguous pathspec, an unmerged index, or an unverifiable index state
- **THEN** the operation fails before the first repository commit and reports the exact rejected precondition
- **AND** diagnostics identify the conflicting option or affected index/path boundary
- **BUT** no planned repository changes HEAD, index, or worktree state

#### Scenario: Report resumable partial completion
- **WHEN** all static preflight passed but a later repository commit or hook fails after an earlier submodule committed
- **THEN** the failing repository restores its own ref and index, the operation accurately reports earlier completed repositories and pending work, and no completed earlier commit is destructively rolled back

#### Scenario: Commit exact linked-worktree paths
- **WHEN** a caller targets a registered linked WorkspaceRoot with a dirty top-level submodule and parent gitlink
- **THEN** the submodule commits on its actual branch before the parent commits the resulting gitlink, without requiring a branch prefix

#### Scenario: Authorize all changes explicitly
- **WHEN** a caller selects all-change intent for one exact WorkspaceRoot
- **THEN** the preview lists every included non-ignored repository/path before commit, rejects unrelated pre-staged content, and does not expose outside-staged preservation
