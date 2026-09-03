---
issue_id: issue-20260903-git-commit-scope-preview
status: resolved
source: coordinator
source_ref: "pre-final-review commit safety audit after c41a82c5"
affected_tasks: ["3.1"]
created_at: 2026-09-03T15:35:18+08:00
resolved_at: 2026-09-03T15:35:18+08:00
resolution_ref: ".agents/skills/git-operations/scripts/GitOperations.psm1; .agents/skills/git-operations/tests/GitOperations.Tests.ps1"
---

# Git Commit Scope and Preview Guards

## Symptom

The pre-final-review audit found that generic leading-character trimming could treat `.hidden` as `hidden`, a detached submodule could create or check out its Goal branch during `-WhatIf`, the Goal parent branch was not enforced explicitly, and preview results always claimed scoped completion.

## Root Cause

Scope normalization removed a character set instead of only the exact `./` prefix, while detached-branch preparation occurred before `ShouldProcess`. Parent and preview result invariants were implicit rather than checked.

## Disposition

Normalization now removes only an exact `./` prefix. Goal parent and scoped repository target branches are explicit. Detached submodule checkout/creation occurs only inside `ShouldProcess`, and result state reports preview plus the actual remaining scoped dirtiness.

## Evidence

- `GitOperations.Tests.ps1` rejects a staged `.hidden-scope.txt` when only `hidden-scope.txt` is in scope.
- Its Goal preview leaves the detached submodule HEAD and branch set unchanged, creates no commit, and reports incomplete dirty scope.
- The actual Goal commit still records submodules before the parent and closes the scoped state.

## Links

- `.agents/skills/git-operations/scripts/GitOperations.psm1`
- `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
