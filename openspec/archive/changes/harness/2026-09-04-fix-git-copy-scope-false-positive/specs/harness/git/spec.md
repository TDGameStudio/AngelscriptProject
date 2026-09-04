## MODIFIED Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the exact selected WorkspaceRoot's parent repository and top-level submodules. Every commit MUST receive exact repository/path scopes, unless the caller explicitly authorizes all non-ignored changes in that same workspace. By default, unrelated staged content MUST be rejected. Every exact-scope commit MUST use path-only semantics, MUST run normal Git hooks against the candidate commit, MUST include only effective-scope paths, and MUST preserve scope-external index entries. A true staged rename whose source deletion and target addition cross the effective scope MUST be rejected, but a target-only addition MUST remain valid when Git classifies it as copied from an unchanged out-of-scope tracked path. The affected repository's ref and complete live index MUST be restored to their pre-attempt state when a hook, commit, or postcondition fails and the attempted ref still owns the compare-and-swap boundary. For exact scoped intent only, the caller MAY explicitly select `PreserveOutsideStaged`; that option additionally exposes the before/after outside-index proof and MUST be rejected for all-change intent. Ignored configuration MUST NOT be force-added, dirty scoped submodules MUST commit before the parent records their gitlinks, and repository mode or Goal-name inputs MUST NOT exist.

#### Scenario: Isolate a hook-expanded candidate
- **GIVEN** a normal Git hook stages an outside path, creates an outside intent-to-add entry, or creates a true rename whose source and target cross the requested scope
  > Inputs: Candidate safety uses actual staged mutations, unmerged entries, intent-to-add state, and rename endpoints.
- **WHEN** Harness attempts an exact scoped commit
  > Details: Hook output is evaluated against the same effective literal scopes used to construct the candidate index.
- **THEN** no affected repository ref retains the unsafe candidate, the complete live index is restored byte-for-byte, and the failure names the hook isolation boundary and outside path when Git exposes it
  > Observables: The pre-attempt and final HEAD, complete index bytes and semantic entries, commit path set, hook result, and exact residual worktree paths.
- **BUT** an advisory copy-similarity classification does not create a source-side mutation or widen the commit
  > Boundaries: Hooks remain arbitrary programs; Harness restores repository refs and indexes that it owns and reports but never overwrites worktree, process, network, or repository-external hook side effects.

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
