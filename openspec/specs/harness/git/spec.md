# Harness Git Operations

## Purpose

This capability defines exact-workspace Git inspection and commits, reviewed local integration from a registered linked worktree into the primary workspace, and explicitly requested ordered non-force publication.

## Requirements

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
- **WHEN** a pre-commit hook formats and stages only an effective-scope path and a commit-message hook edits the message
- **THEN** the exact scoped commit succeeds with the hook-produced scoped content and message while outside index state remains equivalent

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

### Requirement: Explicit previewable local integration

Local integration SHALL require the canonical primary target, an exact registered linked source WorkspaceRoot, the reviewed expected source HEAD, and explicit parent/submodule target branches. Preview SHALL report every planned repository, source root, source/target commit, and fast-forward/merge action without changing either workspace or remote state. Integration SHALL preserve source commits, branches, worktree, unrelated target changes, and remote state.

#### Scenario: Integrate disjoint local work
- **GIVEN** the canonical primary target and exact registered linked source share one Git common directory, and the source HEAD and target branch map match the reviewed plan
- **WHEN** the primary target has only unstaged or untracked changes disjoint from the reviewed source patch
- **THEN** affected submodules integrate before the parent and the unrelated local bytes/status remain unchanged
- **AND** the source HEAD, source worktree, and remote refs remain unchanged after local integration
- **BUT** the operation performs no push, branch deletion, or worktree cleanup

    > Context: Local integration is a separate authority from committing, publication, and workspace removal.
    >
    > Inputs: Exact source `WorkspaceRoot`, reviewed `ExpectedSourceHead`, explicit parent/submodule target branches, and an optional merge message.
    >
    > Observables: Preview repository plans, source and target heads, resulting merge lineage, final parent gitlinks, unrelated local status, and remote refs.
    >
    > Boundaries: Target staged content or any local/incoming path overlap is unsafe and must be rejected before the affected repository changes.
    >
    > Verification: The linked-worktree integration fixture in `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` proves preview immutability, submodule-before-parent integration, preserved merge lineage, disjoint local work retention, source preservation, and unchanged remotes.

#### Scenario: Refuse a stale or unsafe source
- **WHEN** target staged content exists, local payload overlaps incoming paths, the source is not a registered linked worktree in the same common directory, source HEAD differs from the reviewed snapshot, or a target branch is ambiguous
- **THEN** integration fails before changing the affected repository

### Requirement: Merge-based resumable multi-repository integration

Each affected repository SHALL fast-forward when possible and otherwise create a non-fast-forward merge that retains the reviewed source commits. The parent merge SHALL record the final integrated submodule heads. Only a gitlink conflict whose selected commit contains both sides MAY be resolved automatically. Ordinary conflicts SHALL abort the current repository merge and report a resumable partial result without destructive rollback.

#### Scenario: Resume after a later repository conflict
- **GIVEN** an earlier attempt integrated one or more submodules, then aborted a later ordinary conflict without leaving that repository in a merge-in-progress state
- **WHEN** earlier submodules integrated successfully but a later repository reports an ordinary conflict
- **THEN** a repeated integration recognizes completed submodules, does not duplicate their merges, and continues only after the conflicting repository is resolved or the plan changes
- **AND** preview marks each previously completed repository as `AlreadyIntegrated` and `Resumed`
- **BUT** retry performs no destructive rollback of completed repositories and does not rewrite the preserved source workspace

    > Context: Multi-repository integration is preflighted and resumable, but it is not physically atomic across Git repositories.
    >
    > Inputs: The same exact source workspace, reviewed source HEAD, and explicit target branch map used by the interrupted integration.
    >
    > Observables: The aborted repository's unchanged HEAD and absent `MERGE_HEAD`, retained earlier submodule head, and resumed preview actions.
    >
    > Boundaries: A changed source snapshot or branch plan requires a new reviewed integration plan instead of being treated as a retry.
    >
    > Verification: The later-parent-conflict fixture in `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` proves current-repository merge abort, preservation of the already integrated submodule, and idempotent `AlreadyIntegrated`/`Resumed` planning.

#### Scenario: Keep delivery authority separate
- **WHEN** local integration completes
- **THEN** no push, publication, branch deletion, or worktree removal has occurred

### Requirement: Explicit ordered non-force push

`git.push` SHALL run only after an explicit user push or publication request and SHALL require an exact repository-to-local-branch map and remote for the selected workspace. Preview MUST perform no remote mutation. A real multi-repository push MUST publish required submodule commits before the parent branch, MUST reject a parent gitlink that is neither known remote-reachable nor included in the push plan, and MUST NOT expose implicit force, deletion, integration, or worktree cleanup.

#### Scenario: Publish an exact branch map
- **GIVEN** an explicit user publication request names the selected remote and the parent references a new submodule commit that is not yet known reachable there
- **WHEN** the user explicitly requests push and the parent branch references new submodule commits
- **THEN** the caller names those actual local branches, the route pushes submodules before the parent, and every push is a normal non-force ref update
- **AND** preview shows the same child-before-parent plan without changing any remote ref
- **BUT** omitting a required submodule branch fails before publication, and neither preview nor execution exposes force or deletion semantics

    > Inputs: One exact repository-to-local-branch map and an explicit remote for the selected workspace.
    >
    > Observables: Ordered push plans, local branch heads, remote refs before and after execution, and `Forced = false`.
    >
    > Boundaries: Push does not integrate branches, remove source worktrees, delete branches, or infer a branch for an unpublished gitlink.
    >
    > Verification: The publication fixture in `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` proves missing-submodule rejection, non-mutating preview, submodule-before-parent publication, normal non-force updates, and source-worktree retention.

#### Scenario: Keep cleanup separate after push
- **WHEN** push completes
- **THEN** source branches and worktrees still exist until the user separately requests cleanup

### Requirement: Harness Git API identity

The Git operations module SHALL expose only Harness-named context, result, and helper symbols where the shared framework identity appears, while the stable `git.status`, `git.commit`, `git.integrate`, and `git.push` routes retain their existing semantics and authority boundaries. Generated default commit messages and maintained examples SHALL use `[Harness]`; no `[Hardness]` default or old PowerShell alias SHALL remain.

#### Scenario: Invoke Git through Harness
- **WHEN** a caller uses a stable `git.*` route in a Harness context
- **THEN** results and diagnostics use Harness-named types/helpers without changing exact-scope, preservation, integration, or push behavior

#### Scenario: Reject old Git helper names
- **WHEN** a caller attempts to invoke an exported `*-Hardness*` Git helper after cutover
- **THEN** the helper is absent instead of forwarding to its Harness replacement

### Requirement: Plugin-only queue commits

Queue closure SHALL use exact owned plugin scopes with PluginsOnly and PreserveOutsideStaged. In primary workspaces PluginsOnly MUST leave the parent HEAD and unrelated staged entries unchanged; in replicas the root and fixed snapshots MUST NOT become Git commit or publication targets. Per-plugin baseline/result commits SHALL identify executed source instead of a fabricated replica root HEAD. Legacy linked-worktree integration remains a separate explicitly authorized operation with its existing expected-source-HEAD contract.

#### Scenario: Commit an edited replica plugin
- **WHEN** verified owned paths in a registered editable plugin are committed
- **THEN** the commit belongs only to that plugin repository, other staged paths remain intact and the parent HEAD does not change

#### Scenario: Reject root publication from a replica
- **WHEN** a replica caller supplies the root repository key for git.push
- **THEN** Harness rejects that target before Git can fall back to the primary repository