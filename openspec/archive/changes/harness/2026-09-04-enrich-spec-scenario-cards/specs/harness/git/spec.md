## MODIFIED Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the exact selected WorkspaceRoot's parent repository and top-level submodules. Every commit MUST receive exact repository/path scopes, unless the caller explicitly authorizes all non-ignored changes in that same workspace. By default, unrelated staged content MUST be rejected. For exact scoped intent only, the caller MAY explicitly select `PreserveOutsideStaged`; that mode MUST use path-only dry-run and commit semantics, MUST include only effective-scope paths in each new commit, and MUST prove that scope-external index entries remain equivalent before and after the operation. The preservation option MUST be rejected for all-change intent. Ignored configuration MUST NOT be force-added, dirty scoped submodules MUST commit before the parent records their gitlinks, and repository mode or Goal-name inputs MUST NOT exist.

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
- **WHEN** a caller combines `PreserveOutsideStaged` with all-change intent, an ambiguous pathspec, an unmerged index, or an unverifiable index state
- **THEN** the operation fails before the first repository commit and reports the exact rejected precondition
- **AND** diagnostics identify the conflicting option or affected index/path boundary
- **BUT** no planned repository changes HEAD, index, or worktree state

> Context: Preservation is safe only when every selected and preserved index entry can be classified before the first commit.
>
> Inputs: The proposed commit intent, exact scopes when supplied, and the preflight index state of every participating repository.
>
> Observables: A non-success result naming the rejected precondition, with all repository heads and index entries unchanged.
>
> Boundaries: Rejected cases include `AllChanges`, outside intent-to-add entries, staged rename/copy pairs crossing a scope boundary, and unmerged index paths.
>
> Verification: The preservation-rejection fixtures in `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` cover all-change ambiguity, intent-to-add, cross-scope rename/copy, literal path boundaries, and an unmerged index.

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
