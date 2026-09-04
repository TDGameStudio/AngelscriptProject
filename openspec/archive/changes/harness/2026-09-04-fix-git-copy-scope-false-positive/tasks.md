---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

## 1. Candidate scope classification

- [x] 1.1 Allow content-similar target-only additions while preserving rename rejection — verify: `& ./.agents/skills/git-operations/tests/GitOperations.Tests.ps1`
  > Files: `.agents/skills/git-operations/scripts/GitOperations.psm1`, `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`, `openspec/changes/harness/fix-git-copy-scope-false-positive/attachments/implementation/issue-20260904-220329-copy-scope-false-positive.md`, `openspec/changes/harness/fix-git-copy-scope-false-positive/attachments/data/git-copy-scope-red.md`

  1. Convert the copied-target rejection fixture into exact commit acceptance and observe the expected RED.
  2. Restrict the crossing check to true rename endpoints while retaining all actual staged-path checks.
  3. Rerun the direct Git operations fixture and resolve the issue with exact GREEN evidence.

  Evidence: The converted fixture first failed with `rename-source.txt -> copy-target.txt` from the existing copy-similarity check. After the helper stopped requesting or rejecting `C` records and continued validating `R` endpoints, the complete `GitOperations.Tests.ps1` suite passed. The copied-content commit contained only `copy-target.txt`, the source remained byte-equivalent, and the existing true cross-scope rename fixture still passed by observing rejection.

## 2. Durable contract and closure

- [x] 2.1 Synchronize the exact-copy boundary and complete focused Harness verification — verify: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`
  > Files: `.agents/skills/git-operations/references/commits.md`, `openspec/specs/harness/git/spec.md`, `openspec/changes/harness/fix-git-copy-scope-false-positive/specs/harness/git/spec.md`, `openspec/changes/harness/fix-git-copy-scope-false-positive/tasks.md`, `openspec/changes/harness/fix-git-copy-scope-false-positive/attachments/INDEX.md`, `openspec/changes/harness/fix-git-copy-scope-false-positive/attachments/data/workflow-evaluation.md`

  1. Merge the complete modified Requirement and Scenario Cards into current `harness/git` behavior.
  2. Run direct Git tests, Protocol tests, strict Change/current-spec validation, and terminal evolution checks.
  3. Record focused evidence and justified exclusions, then archive with completed closure.

  Evidence: The modified `Structured scoped Git status and commit` Requirement and its three replacement Scenario Cards were synchronized into current `harness/git` behavior. `GitOperations.Tests.ps1` and `Protocol.Tests.ps1` passed, Skill Creator validation accepted `git-operations`, and strict exact-Change plus `harness/git` validation passed. Broader Harness Quick, Performance, Integration, Unreal operations, plugin tests, and Standalone tests were omitted because the direct isolated Git fixture covers the changed candidate classification and retained boundaries without executable product or cross-component runtime impact.
