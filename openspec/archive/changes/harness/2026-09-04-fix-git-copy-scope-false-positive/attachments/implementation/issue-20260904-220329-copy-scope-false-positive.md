---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-220329-copy-scope-false-positive
status: resolved
source: dogfooding
source_ref: "git.commit exact-scope failure while committing harness/fix-scenario-detail-authoring-priority"
affected_tasks: ["1.1"]
created_at: 2026-09-04T22:03:29+08:00
resolved_at: 2026-09-04T22:08:10+08:00
resolution_ref: "run:GitOperations.Tests.ps1-20260904T220810+0800"
---

# Copy Similarity Scope False Positive

## Symptom

An exact scoped commit containing a newly archived spec failed because Harness reported that it crossed scope from a similar spec in an older immutable archive. Adding the unchanged older file to the allowed scope made the same candidate succeed.

## Investigation Log

- The failed candidate contained the new archive and did not delete or modify the older archive.
- The error named the pair as a staged rename/copy crossing the requested scope.
- `Assert-GitNoCrossScopeRenameOrCopy` runs `git diff --cached --name-status --find-renames --find-copies-harder` and rejects either `R` or `C` when only one endpoint is covered.
- Git `C` classification identifies similarity for a target addition; it does not make the source an actual mutation.

## Root Cause

The candidate boundary check treats Git's heuristic copy classification as if it were a paired source/target mutation. `--find-copies-harder` permits any unchanged tracked file to become the inferred source, so safe target-only additions can be rejected based on repository history outside the requested scope.

## Disposition

The crossing helper now requests and validates only true rename records. Actual staged-path checks remain unchanged. The direct fixture commits a target-only copied addition, proves the commit path set contains only the target, and proves the source remains present and byte-equivalent; the existing true rename fixture remains rejected.

## Evidence

### Failure Evidence (RED)

- Command: exact Harness `git.commit` for `harness/fix-scenario-detail-authoring-priority` without the inferred source path.
- Artifact: `attachments/data/git-copy-scope-red.md`
- Result: failed with `staged rename/copy crossing the requested scope` from the older archived `harness/unreal/spec.md` to the newly archived one; Harness restored the affected ref and index and created no partial commit.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
- Run ID: `GitOperations.Tests.ps1-20260904T220810+0800`
- Result: `PASS` after the copy fixture succeeded and the full direct suite retained cross-scope rename, hook quarantine, outside-index preservation, multi-repository ordering, integration, and push-boundary coverage.

### Rejected Evidence

Adding the unchanged inferred source to `RepositoryScopes` was accepted only as a one-time safe workaround. It is not the correct contract because that path was not changed by the commit.

### What This Proves

Exact target-only additions no longer fail because of similarity to unchanged tracked history, while demonstrated true cross-scope renames and actual outside mutations remain rejected.

### What This Does Not Prove

It does not prove behavior for unrelated Git versions, repositories with pathological filters, remote publication, or worktree integration beyond the existing fixture coverage.

## Links

- `.agents/skills/git-operations/scripts/GitOperations.psm1`
- `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
- `.agents/skills/git-operations/references/commits.md`
