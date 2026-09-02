---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "2.1": ["1.3"]
    "2.2": ["2.1"]
---

## 1. Repair and evidence

- [x] 1.1 Reproduce and classify the post-archive gate regression — verify: `Quick reports only HardnessGateContract.PS5/PS7 and Protocol.PS5/PS7 failing because the active dogfood path no longer exists`
  > Files: `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`, `openspec/changes/hardness/fix-post-archive-gates/attachments/implementation/post-archive-regression.md`

  1. Run the non-UE Quick profile after the completed archive move.
  2. Trace both failures to active-change fixture coupling rather than a Hardness route or OpenSpec CLI defect.
  3. Keep `task.status` limited to active execution records and keep the completed archive immutable.

- [x] 1.2 Make reusable Hardness gates independent of active changes — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick -PowerShellHosts Both`
  > Files: `.agents/skills/hardness/scripts/Test-Hardness.ps1`, `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`

  1. Generate an isolated temporary Task Graph for default TaskStatus measurements outside the timed region.
  2. Preserve explicit active-project `-TaskChange` selection and the real `Invoke-Hardness task.status` route.
  3. Bound recursive cleanup to the normalized system temp root and a random fixture-name prefix.
  4. Audit the earlier dogfood Review/Replan records at their fixed completed archive path.

- [x] 1.3 Retain the new performance evidence and closure invariant — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Performance -PowerShellHosts Both -WarmupRuns 3 -MeasurementRuns 15`
  > Files: `.agents/skills/hardness/SKILL.md`, `.agents/skills/hardness/references/closure.md`, `.agents/skills/openspec-archive-change/SKILL.md`, `openspec/changes/hardness/fix-post-archive-gates/attachments/data/hardness-performance-post-archive-20260903-072834.json`, `openspec/changes/hardness/fix-post-archive-gates/attachments/INDEX.md`

  1. Run PS5 and PS7 performance profiles with three warmups and fifteen measurements per scenario.
  2. Retain raw JSON/CSV locally and index one privacy-trimmed aggregate with source and raw-artifact hashes.
  3. Mark TaskStatus values as a new hermetic-fixture series that cannot be directly compared with the old active-change series.
  4. Require archive-stable gate inputs and a targeted post-move lifecycle gate without rewriting completed archives.

## 2. Review and closure

- [ ] 2.1 Review the fixed committed snapshot — verify: `A closed independent review reports no open Critical or Required finding`
  > Files: `openspec/changes/hardness/fix-post-archive-gates/attachments/reviews/review-*.md`, `openspec/changes/hardness/fix-post-archive-gates/attachments/INDEX.md`

  1. Bind the review to the committed implementation and evidence hashes.
  2. Check PS5/PS7 behavior, timing boundaries, cleanup containment, archive immutability, and binary/gitlink history.
  3. Resolve every blocking finding before closure.

- [ ] 2.2 Synchronize the durable delta and archive the follow-up — verify: `openspec.exe validate --archived --strict --json`
  > Files: `openspec/specs/hardness/core/spec.md`, `openspec/changes/hardness/fix-post-archive-gates/**`

  1. Merge the archive-stable gate and retained-evidence requirements into `hardness/core`.
  2. Validate the completed active record and prepare completed closure metadata.
  3. Archive through the CLI, run strict historical validation, and rerun the applicable non-UE gate.
