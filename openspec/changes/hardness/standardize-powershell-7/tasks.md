---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
---

## 1. Support boundary

- [x] 1.1 Make the executable contract PowerShell 7 only — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/tests/Test-Hardness.Tests.ps1`
  > Files: `.agents/skills/hardness/scripts/Test-Hardness.ps1`, `.agents/skills/hardness/scripts/Hardness.psd1`, `.agents/skills/git-workflow/scripts/Workspace.psd1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`, `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`

  1. Remove the dual-host selector and every PS5 process from the public runner.
  2. Require PowerShell 7.0/Core in both public module manifests.
  3. Keep only generic Windows process-tree cleanup fallback behavior.
  4. Assert five PS7 Quick checks, one PS7 Performance check, and ten PS7 Integration checks.

- [x] 1.2 Publish the PowerShell 7-only project contract — verify: `.agents/skills/openspec/bin/openspec.exe validate hardness/standardize-powershell-7 --strict --json`
  > Files: `.agents/skills/hardness/SKILL.md`, `.agents/skills/hardness/references/task-dag.md`, `.agents/skills/README.md`, `AGENTS.md`, `openspec/README.md`, `Documents/Guides/SubmoduleWorktreeWorkflow.md`, `openspec/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/knowledges/dogfooding.md`, `openspec/changes/hardness/standardize-powershell-7/specs/hardness/core/spec.md`

  1. Use `pwsh.exe` in every maintained Hardness entry and example.
  2. State the 7.0/Core minimum without broadening this change into deferred Unreal tooling.
  3. Synchronize the modified performance and reusable-session requirements into the current capability spec.

## 2. Evidence and closure

- [x] 2.1 Run and retain the PS7-only gates — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Integration`
  > Files: `openspec/changes/hardness/standardize-powershell-7/attachments/data/hardness-performance-powershell7-*.json`, `openspec/changes/hardness/standardize-powershell-7/attachments/INDEX.md`

  1. Run the complete Integration profile once; it includes the five Quick checks, one Performance check, and four route checks.
  2. Retain a privacy-trimmed aggregate with PS7 raw-artifact and source hashes while leaving raw samples ignored.
  3. Record actual per-check duration so later workflow review can distinguish policy simplification from runtime optimization.

- [ ] 2.2 Review and close the fixed snapshot — verify: `.agents/skills/openspec/bin/openspec.exe validate --archived --strict --json`
  > Files: `openspec/changes/hardness/standardize-powershell-7/attachments/reviews/review-*.md`, `openspec/changes/hardness/standardize-powershell-7/attachments/INDEX.md`, `openspec/changes/hardness/standardize-powershell-7/tasks.md`

  1. Independently verify that no executable PS5 route remains in the maintained Hardness gate surface.
  2. Close blocking findings, sync the durable delta, and archive through the CLI.
  3. Run strict archive validation and the PS7-only Quick gate after the move.
