---
issue_id: issue-20260903-153518-git-commit-scope-preview
status: resolved
source: implementation
source_ref: "pre-final-review commit safety audit after c41a82c5"
affected_tasks: ["3.1"]
created_at: 2026-09-03T15:35:18+08:00
resolved_at: 2026-09-03T15:35:18+08:00
resolution_ref: ".agents/skills/git-operations/scripts/GitOperations.psm1; .agents/skills/git-operations/tests/GitOperations.Tests.ps1"
---

# Git Commit Scope and Preview Guards

## Symptom

The pre-final-review audit found that generic leading-character trimming could treat `.hidden` as `hidden`, a detached submodule could create or check out its Goal branch during `-WhatIf`, the Goal parent branch was not enforced explicitly, and preview results always claimed scoped completion.

## Investigation Log

1. The coordinator inspected the committed scoped-commit implementation before assigning Final Review.
2. The path-normalization expression and detached-branch control flow demonstrated the unsafe boundaries without requiring a destructive reproduction.
3. The repair moved every branch mutation under `ShouldProcess`, made branch identity explicit, and calculated remaining scoped state after the attempted operation.
4. Focused fixtures then proved leading-dot isolation and a non-mutating detached-submodule preview before the repaired snapshot was committed.

## Root Cause

Scope normalization removed a character set instead of only the exact `./` prefix, while detached-branch preparation occurred before `ShouldProcess`. Parent and preview result invariants were implicit rather than checked.

## Disposition

Normalization now removes only an exact `./` prefix. Goal parent and scoped repository target branches are explicit. Detached submodule checkout/creation occurs only inside `ShouldProcess`, and result state reports preview plus the actual remaining scoped dirtiness.

## Evidence

### Failure Evidence (RED)

- Command: `git show c41a82c5:.agents/skills/git-operations/scripts/GitOperations.psm1`
- Commit: `c41a82c5`; inspection shows character-set trimming, pre-`ShouldProcess` detached checkout/creation, and unconditional scoped completion.

### Resolution Evidence (GREEN)

- Command: `pwsh.exe -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`
- Commit: `404eb306`; the focused PowerShell 7 integration test passed.

### What This Proves

The test rejects a staged `.hidden-scope.txt` when only `hidden-scope.txt` is in scope. Goal preview leaves the detached submodule HEAD and branch set unchanged, creates no commit, and reports incomplete dirty scope. The actual Goal commit still records submodules before the parent and closes the scoped state.

### What This Does Not Prove

This issue does not prove UE build or runtime behavior, remote publication, or real workspace removal. Those operations are outside the scoped-commit repair and were not executed.

## Links

- `.agents/skills/git-operations/scripts/GitOperations.psm1`
- `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
