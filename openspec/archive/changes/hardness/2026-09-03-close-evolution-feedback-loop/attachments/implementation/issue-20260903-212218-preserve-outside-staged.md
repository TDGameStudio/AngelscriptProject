---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260903-212218-preserve-outside-staged
status: resolved
source: user
source_ref: "conversation after delivery of hardness/integrate-unreal-development; archived record hardness/2026-09-03-integrate-unreal-development; closure commit e183e17d2fdac4a8975dd93b9324fe552ad8231b"
affected_tasks: ["1.2", "1.3", "2.1", "2.2", "3.1"]
created_at: 2026-09-03T21:22:18+08:00
resolved_at: 2026-09-04T01:45:00+08:00
resolution_ref: ".agents/skills/git-operations/tests/GitOperations.Tests.ps1 (PASS 2026-09-04T01:42+08:00)"
---

# Preserve Outside-Staged Content During an Exact Scoped Commit

## Symptom

The main checkout contained unrelated staged work when the completed `hardness/integrate-unreal-development` paths needed an exact commit. Hardness `git.commit` rejected the operation because its ordinary whole-index commit cannot safely exclude scope-external staged entries. Delivery therefore used Git's native path-only commit behavior. The user correctly identified that reporting the capability gap only in the final handoff did not enter the Hardness self-evolution lifecycle.

## Investigation Log

1. The current `hardness/git` contract and Git implementation intentionally reject staged paths outside effective scopes.
2. Removing that guard alone would be unsafe because the implementation stages selected paths and then performs an ordinary commit without a pathspec.
3. Git's native path-only dry-run and commit completed the selected parent paths while unrelated staged entries remained staged.
4. The final handoff described a possible `PreserveOutsideStaged` option, but no tracked issue, task owner, or disposition existed before the user requested a durable lifecycle.
5. This successor Change now owns both the Git repair and the missing self-evolution checkpoint without modifying the completed archive.

## Root Cause

The scoped-commit route equated safety with an empty scope-external index because it always committed the ordinary index. That default was conservative, but the route lacked an explicit path-only mode that could prove both the new commit scope and equivalence of preserved outside index entries. Separately, the dogfooding process had only ignored observations and a workflow evaluation, so a material discovery made during exact delivery had no required tracked disposition.

## Disposition

Resolved. Tasks `1.3` and `2.2` added and implemented explicit `PreserveOutsideStaged` path-only commit behavior while retaining default fail-closed semantics. Tasks `2.1` and `3.1` added the material-issue terminal gate and synchronized the durable Git/core contracts. The focused Git fixture passed on 2026-09-04.

## Evidence

### Failure Evidence (RED)

- Command: `pwsh.exe -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`
- Commit: `e183e17d2fdac4a8975dd93b9324fe552ad8231b`; the delivered Change required a native path-only commit after the maintained Hardness route rejected scope-external staged content.
- Contract: `openspec/specs/hardness/git/spec.md` requires rejection of unrelated staged content.
- Guard: `.agents/skills/git-operations/scripts/GitOperations.psm1` rejects staged paths outside effective child and parent scopes before commit.
- Regression: `.agents/skills/git-operations/tests/GitOperations.Tests.ps1` asserts the default rejection.
- Delivered commit: `e183e17d2fdac4a8975dd93b9324fe552ad8231b` was created with Git path-only commit behavior after the Hardness route could not own the exact delivery.
- Later outcome: commit `4614ff3568427f3374742dc30cea3b5efd1524bf` is consistent with the previously staged TestSource work remaining separate, but it is outcome evidence only. The transient dry-run output and staged-patch hash were not retained and are not claimed as replayable proof.

### Resolution Evidence (GREEN)

- Command: `pwsh.exe -NoLogo -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`
- Result: `GitOperations.Tests.ps1: PASS` on 2026-09-04 at approximately 01:42 +08:00.
- Coverage: the passing fixture covers default rejection, explicit primary/submodule preservation, preview separation, exact commit paths, outside-index equivalence, parent gitlinks, invalid preservation combinations, path edge cases, hook failure, and resumable partial completion.
- Integrated gate: `pwsh.exe -NoLogo -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick` completed `7 passed, 0 failed`.

### Rejected Evidence

- Removing the outside-staged guard without changing commit semantics is rejected because an ordinary commit would consume the whole index.
- The final conversational summary is rejected as a durable owner or terminal disposition.

### What This Proves

The original public route gap was reproduced, repaired with explicit path-only semantics, and retained in the tracked material-issue lifecycle with focused passing evidence.

### What This Does Not Prove

The fixture proves the maintained Git route and its hermetic repositories; it does not prove every third-party hook, filesystem, Git version, or concurrent external index mutation. Runtime fingerprint checks remain the protection for those environments.

## Links

- `openspec/archive/changes/hardness/2026-09-03-integrate-unreal-development/`
- `openspec/changes/hardness/close-evolution-feedback-loop/tasks.md`
- `openspec/changes/hardness/close-evolution-feedback-loop/specs/hardness/git/spec.md`
- `.agents/skills/git-operations/scripts/GitOperations.psm1`
- `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
