# Harness Git delta

## MODIFIED Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the exact selected repositories: primary parent/top-level submodules, or only editable plugin worktrees in replicas. Every commit MUST receive exact repository/path scopes, unless the caller explicitly authorizes all non-ignored changes in that same workspace. By default, unrelated staged content MUST be rejected. Every exact-scope commit MUST use path-only semantics, MUST run normal Git hooks against the candidate commit, MUST include only effective-scope paths, and MUST preserve scope-external index entries. A true staged rename whose source deletion and target addition cross the effective scope MUST be rejected, but a target-only addition MUST remain valid when Git classifies it as copied from an unchanged out-of-scope tracked path. The affected repository's ref and complete live index MUST be restored to their pre-attempt state when a hook, commit, or postcondition fails and the attempted ref still owns the compare-and-swap boundary. For exact scoped intent only, the caller MAY explicitly select `PreserveOutsideStaged`; that option additionally exposes the before/after outside-index proof and MUST be rejected for all-change intent. Ignored configuration MUST NOT be force-added, dirty scoped submodules MUST commit before an authorized parent commit records their gitlinks; PluginsOnly MUST omit that parent commit, and repository mode or Goal-name inputs MUST NOT exist.

#### Scenario: Reject outside staged content by default
- **WHEN** a scoped commit finds a staged path outside its effective scopes and preservation was not explicitly selected
- **THEN** the operation fails before mutation and leaves HEAD, index, and worktree unchanged

#### Scenario: Isolate a hook-expanded candidate
- **GIVEN** a normal Git hook stages an outside path, creates an outside intent-to-add entry, or creates a true rename whose source and target cross the requested scope
    > Inputs: Candidate safety uses actual staged mutations, unmerged entries, intent-to-add state, and rename endpoints.
- **WHEN** Harness attempts an exact scoped commit
    > Details: Hook output is evaluated against the same effective literal scopes used to construct the candidate index.
- **THEN** no affected repository ref retains the unsafe candidate, the complete live index is restored byte-for-byte, and the failure names the hook isolation boundary and outside path when Git exposes it
    > Observables: The pre-attempt and final HEAD, complete index bytes and semantic entries, commit path set, hook result, and exact residual worktree paths.
- **BUT** an advisory copy-similarity classification does not create a source-side mutation or widen the commit
    > Boundaries: Hooks remain arbitrary programs; Harness restores repository refs and indexes that it owns and reports but never overwrites worktree, process, network, or repository-external hook side effects.

#### Scenario: Accept scope-local hook changes
- **GIVEN** an explicitly authorized legacy scoped call without an expected content revision
- **WHEN** a pre-commit hook formats and stages only an effective-scope path and a commit-message hook edits the message
- **THEN** the exact scoped commit succeeds with the hook-produced scoped content and message while outside index state remains equivalent
- **BUT** a lifecycle call bound to an expected candidate rejects selected-content rewriting rather than silently changing the approved bytes

#### Scenario: Preserve outside staged content explicitly
- **GIVEN** the exact selected workspace contains intentionally staged work outside the requested repository/path scopes
- **WHEN** a caller supplies exact repository/path scopes and explicitly selects outside-staged preservation in a dirty primary checkout
- **THEN** preview separates selected and preserved staged paths, the path-only commit contains only effective-scope content, and the outside index fingerprint remains equivalent
- **AND** an executed result reports the outside snapshot as `Preserved`, marks the requested scope complete, and does not claim the aggregate Git state is complete
- **BUT** no scope-external path is committed, unstaged, or otherwise rewritten

    > Context: This mode allows one independently staged change to remain intact while an unrelated exact scope is committed.
    >
    > Inputs: One exact `WorkspaceRoot`, explicit `RepositoryScopes`, `PreserveOutsideStaged = true`, and a commit message.
    >
    > Observables: `IncludedChanges`, `PreservedStaged`, before/after SHA-256 values, the new commit path list, and the post-operation index.
    >
    > Boundaries: Preservation applies only to exact scoped intent; it does not authorize `AllChanges` or broaden any pathspec.
    >
    > Verification: The scoped-primary fixture in `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` checks preview immutability, literal path selection, exact commit contents, outside-index equivalence, and scoped versus aggregate completion.

#### Scenario: Preserve staged content across parent and submodule commits
- **GIVEN** the parent and at least one initialized top-level submodule each contain selected changes and independently staged paths outside their effective scopes
- **WHEN** exact scoped changes span submodules and the parent while either repository has staged content outside its effective scope
- **THEN** all repositories pass static preflight, each scoped submodule commits before the parent, each commit is path-only, and every repository's outside index entries remain equivalent
- **AND** the parent commit records the newly committed submodule head while each repository reports its own preserved outside-index proof
- **BUT** staged content outside either repository's effective scope is neither included nor unstaged

    > Inputs: Exact per-repository scopes, submodule commit messages where needed, and explicit target branches for detached repositories.
    >
    > Observables: Ordered `Commits`, per-repository `PreservedStaged` entries, exact index records, and the parent commit's resulting gitlinks.
    >
    > Boundaries: Only initialized top-level submodules in the selected workspace participate; preservation does not infer branches or expand scope.
    >
    > Verification: The multi-repository scoped-preservation fixture in `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` proves child-before-parent ordering, exact outside index retention in both repositories, and the final parent gitlink.

#### Scenario: Refuse ambiguous preservation intent
- **GIVEN** no repository in the proposed multi-repository commit has begun mutation
    > Context: Preservation is safe only when every selected and preserved index entry can be classified before the first commit.
- **WHEN** a caller combines `PreserveOutsideStaged` with all-change intent, an ambiguous pathspec, an unmerged index, an unverifiable index state, or a true rename crossing the exact scope
    > Inputs: The proposed commit intent, exact scopes when supplied, and the preflight index state of every participating repository.
- **THEN** the operation fails before the first repository commit and reports the exact rejected precondition
    > Observables: A non-success result names the conflicting option or affected index/path boundary while all repository heads and index entries remain unchanged.
- **AND** diagnostics identify the conflicting option or affected index/path boundary
    > Verification: Direct fixtures cover all-change ambiguity, intent-to-add, cross-scope rename, literal path boundaries, and an unmerged index.
- **BUT** no planned repository changes HEAD, index, or worktree state
    > Boundaries: A target-only copied addition is not ambiguous because only its target is mutated.

#### Scenario: Commit a content-similar target-only addition
- **GIVEN** a tracked path outside the requested scope remains unchanged
    > Context: Its content may be identical or similar enough for Git to call a new target a copy.
- **WHEN** an exact scoped commit includes only the new target path
    > Inputs: The target is the only staged mutation selected for the candidate.
- **THEN** the commit succeeds and contains only the target path
    > Observables: The source remains tracked, present, byte-equivalent to its pre-commit state, and absent from the commit path set.
- **BUT** similarity detection does not require the unchanged source to be added to `RepositoryScopes`
    > Verification: The direct copy fixture commits the target-only addition while the true cross-scope rename fixture remains rejected.

#### Scenario: Report resumable partial completion
- **WHEN** all static preflight passed but a later repository commit or hook fails after an earlier submodule committed
    > Context: Failure occurs after at least one repository has already produced a valid commit.
- **THEN** the failing repository restores its own ref and index, the operation accurately reports earlier completed repositories and pending work, and no completed earlier commit is destructively rolled back
    > Details:

    1. Earlier successful repository commits remain completed and are reported with their resulting heads.
    2. The failing repository returns to its pre-attempt ref and complete index when the compare-and-swap boundary is still owned.
    3. Unattempted repositories remain pending, so retry can resume without duplicating earlier commits.

#### Scenario: Commit exact linked-worktree paths
- **WHEN** a caller targets a registered linked WorkspaceRoot with a dirty top-level submodule and parent gitlink
- **THEN** the submodule commits on its actual branch before the parent commits the resulting gitlink, without requiring a branch prefix

#### Scenario: Authorize all changes explicitly
- **WHEN** a caller selects all-change intent for one exact WorkspaceRoot
- **THEN** the preview lists every included non-ignored repository/path before commit, rejects unrelated pre-staged content, and does not expose outside-staged preservation

#### Scenario: Lifecycle commit consumes the displayed candidate

- **GIVEN** an exact lifecycle Git preview with selected content and relevant repository identity
- **WHEN** its commit executes
- **THEN** Git verifies the expected preview identity and commits only the approved selection through normal hooks
- **AND** changed selected bytes or relevant baseline reject mutation, while unrelated dirty paths and staged hunks are preserved

#### Scenario: Select one attributable edit in a shared file

- **GIVEN** a file containing owned and unrelated edits with a proven explicit patch for the owned change
- **WHEN** the shown patch selection commits
- **THEN** the commit contains only that patch and the other edit remains outside it
- **BUT** inability to prove or apply the separation blocks the operation rather than admitting the whole file


### Requirement: Plugin-only queue commits

The plugin stage of queue closure SHALL use exact owned editable-plugin scopes with PluginsOnly and PreserveOutsideStaged. In a primary workspace the plugin stage leaves parent HEAD and unrelated staged entries unchanged; a separately shown stage of the same close decision saves canonical records and authorized gitlinks in the primary repository. In replicas the root and fixed snapshots MUST NOT become Git commit or publication targets. Per-plugin baseline/result commits identify executed source. Integration and push remain separately authorized operations.

#### Scenario: Commit an edited replica plugin

- **WHEN** verified owned paths in a registered editable plugin are committed
- **THEN** the commit belongs only to that plugin repository and other staged paths remain intact
- **AND** canonical records are saved through their actual primary context rather than a fabricated replica root repository

#### Scenario: Reject root publication from a replica

- **WHEN** a replica caller supplies the root repository key for git.push
- **THEN** Harness rejects that target before Git can fall back to the primary repository

#### Scenario: Complete the canonical-record stage

- **GIVEN** an approved close plan with plugin and primary stages
- **WHEN** plugin results and archive evidence are ready
- **THEN** only the shown primary records and authorized gitlinks are committed, and partial primary failure remains visible and recoverable
