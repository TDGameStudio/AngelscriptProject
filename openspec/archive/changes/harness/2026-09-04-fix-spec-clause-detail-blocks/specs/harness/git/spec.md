## MODIFIED Requirements

### Requirement: Exact-path commit safety

Primary-checkout scoped commits SHALL use an isolated candidate index and literal exact paths so unrelated staged content never enters the commit. By default, any staged path outside the requested scope MUST reject the operation before mutation. When and only when `PreserveOutsideStaged = true` is explicitly selected with exact `RepositoryScopes`, Harness MAY proceed after proving the preserved index state is safe and MUST prove after commit that every outside entry is byte-for-byte and metadata-for-metadata equivalent to its pre-attempt snapshot. The preservation snapshot SHALL include path identity, index metadata, and binary staged patch content and MUST reject unmerged entries, intent-to-add entries, and staged rename/copy pairs crossing the requested boundary before mutation. `PreserveOutsideStaged` MUST reject `AllChanges`. A scope-local pre-commit formatter and commit-message hook MAY change candidate content or the final message; any hook attempt to add outside paths, unmerged entries, intent-to-add entries, or a cross-boundary rename/copy MUST fail before the commit is accepted. If a candidate hook or Git commit fails, or if a postcondition exposes ref movement or scope expansion, Harness MUST restore that repository's live ref only through compare-and-swap when still owned and restore its complete pre-attempt index, MUST report any worktree or external hook side effects it cannot safely undo, and MUST NOT claim a stronger rollback. Already successful earlier repository commits remain explicit resumable partial work.

#### Scenario: Report resumable partial completion
- **WHEN** all static preflight passed but a later repository commit or hook fails after an earlier submodule committed
  > Context: Failure occurs after at least one repository has already produced a valid commit.
- **THEN** the failing repository restores its own ref and index, the operation accurately reports earlier completed repositories and pending work, and no completed earlier commit is destructively rolled back
  > Details:

  1. Earlier successful repository commits remain completed and are reported with their resulting heads.
  2. The failing repository returns to its pre-attempt ref and complete index when the compare-and-swap boundary is still owned.
  3. Unattempted repositories remain pending, so retry can resume without duplicating earlier commits.
