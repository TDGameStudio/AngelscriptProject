---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-git-commit-isolation
captured_at: 2026-09-04T11:30:38.3434215+08:00
---

# Workflow Evaluation

## Lifecycle exercised

The repair began from an independently reproduced hook expansion, recorded a strict Change, added a real executable-hook RED, implemented candidate-index isolation, synchronized the durable Git contract, and prepared exact terminal and post-archive verification.

## Findings and corrections

- The original implementation staged into the live index and validated only after `git commit`; the RED proved HEAD had already advanced with `outside.txt` despite a reported failure.
- Exact commits now build an isolated index from the old HEAD, stage literal scopes, run `pre-commit`, `prepare-commit-msg`, and `commit-msg` once, and inspect staged paths, dynamic intent-to-add, unmerged entries, and rename/copy boundaries between hook phases.
- Final commit creation disables automatic second hook execution, uses the validated candidate, then aligns only scoped live-index entries. `post-commit` runs with the isolated index.
- A failed hook or unsafe postcondition restores the attempted ref through compare-and-swap and writes back the complete original index bytes. A temporary empty `GIT_INDEX_FILE` restoration bug was exposed by the fixture and corrected by removing the environment entry rather than setting an empty value.

## Evidence

- New fixtures prove successful and failing outside staging cannot advance HEAD or change live-index bytes; dynamic intent-to-add is rejected; `commit-msg` cannot pollute the live index; and scope-local formatting/message edits are retained.
- The complete existing Git operations suite passes, including literal scopes, outside preservation, linked worktrees, child-before-parent commits, integration, conflict recovery, and publication fixtures.
- Strict spec/change validation, Git Skill validation, Quick Harness, terminal evolution, archived validation, and a post-archive Git suite are the closure gates.

## Outcome

The scoped commit route now enforces its authorization before accepting a ref while retaining standard hook behavior. Its rollback claim is deliberately limited to the repository ref/index state Harness owns, so it does not destroy potentially valuable worktree output from arbitrary hooks.
