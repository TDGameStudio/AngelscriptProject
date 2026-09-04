## MODIFIED Requirements

### Requirement: Structured scoped Git status and commit

`git-operations` SHALL own Git change inspection and commit creation across the exact selected WorkspaceRoot's parent repository and top-level submodules. Every commit MUST receive exact repository/path scopes, unless the caller explicitly authorizes all non-ignored changes in that same workspace. By default, unrelated staged content MUST be rejected. Every exact-scope commit MUST use path-only semantics, MUST run normal Git hooks against the candidate commit, MUST include only effective-scope paths, and MUST preserve scope-external index entries. The affected repository's ref and complete live index MUST be restored to their pre-attempt state when a hook, commit, or postcondition fails and the attempted ref still owns the compare-and-swap boundary. For exact scoped intent only, the caller MAY explicitly select `PreserveOutsideStaged`; that option additionally exposes the before/after outside-index proof and MUST be rejected for all-change intent. Ignored configuration MUST NOT be force-added, dirty scoped submodules MUST commit before the parent records their gitlinks, and repository mode or Goal-name inputs MUST NOT exist.

#### Scenario: Report resumable partial completion

- **WHEN** all static preflight passed but a later repository commit or hook fails after an earlier submodule committed
- **THEN** the failing repository restores its own ref and index, the operation accurately reports earlier completed repositories and pending work, and no completed earlier commit is destructively rolled back

> Details:
>
> 1. Earlier successful repository commits remain completed and are reported with their resulting heads.
> 2. The failing repository returns to its pre-attempt ref and complete index when the compare-and-swap boundary is still owned.
> 3. Unattempted repositories remain pending, so retry can resume without duplicating earlier commits.
