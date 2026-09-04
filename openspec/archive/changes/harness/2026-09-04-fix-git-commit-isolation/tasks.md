---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

## 1. Make each scoped repository commit transactional

- [x] 1.1 Add failing Git-hook isolation fixtures — verify: `& ./.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
  > Files: `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`

  > Produces: RED evidence for hook-expanded commits, hook failure index pollution, commit-message behavior, dynamic intent-to-add, and exact ref/index restoration.

  1. Use independent temporary repositories and real executable hooks.
  2. Capture HEAD and complete index bytes before each attempt.
  3. Observe the existing implementation advance HEAD or alter the live index.

- [x] 1.2 Implement repository ref/index isolation and update commit guidance — verify: `& ./.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
  > Files: `.agents/skills/git-operations/scripts/GitOperations.psm1`, `.agents/skills/git-operations/SKILL.md`, `.agents/skills/git-operations/references/commits.md`

  > Constraints: Keep normal hooks enabled and preserve scope-local hook output. Do not claim arbitrary hook worktree/external effects can be rolled back. Earlier successful submodule commits remain resumable partial work.

  1. Snapshot the affected live index before staging and use path-only commit semantics for exact scopes.
  2. On failure or unsafe postcondition, restore the owned ref with compare-and-swap and restore the exact index.
  3. Validate outside staged/ITA and exact commit paths before accepting and recording a commit.

## 2. Synchronize and close

- [x] 2.1 Synchronize the Git contract and complete self-hosted verification — verify: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `openspec/specs/harness/git/spec.md`, `openspec/changes/harness/fix-git-commit-isolation/specs/harness/git/spec.md`, `openspec/changes/harness/fix-git-commit-isolation/attachments/INDEX.md`, `openspec/changes/harness/fix-git-commit-isolation/attachments/data/workflow-evaluation.md`

  1. Replace the current scoped-commit Requirement with the complete modified contract.
  2. Run focused Git tests, strict validations, Skill validation, and Quick Harness.
  3. Record terminal evaluation, archive completed, rerun focused/post-archive gates, and commit exact paths.
