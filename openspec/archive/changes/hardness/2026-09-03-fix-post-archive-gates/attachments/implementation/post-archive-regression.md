---
record_id: post-archive-regression
status: resolved
source: post-archive-verification
created_at: 2026-09-03T07:28:04+08:00
resolving_tasks: ["1.1", "1.2", "1.3"]
---

# Post-archive Gate Regression

## Reproduction

After `hardness/refactor-skill-system` moved to `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system`, the dual-host Quick profile reported `6 passed, 4 failed`:

- `HardnessGateContract.PS5` and `HardnessGateContract.PS7` called the performance leaf with its default `hardness/refactor-skill-system` TaskChange. The real `task.status` route correctly rejected that ID because operation instructions resolve active changes only.
- `Protocol.PS5` and `Protocol.PS7` read Review/Replan evidence from the former active directory, which no longer existed after the deterministic move.

The remaining Hardness, Workspace, and OpenSpec package checks passed. This classified the incident as test-fixture lifecycle coupling, not a Hardness route or OpenSpec CLI defect.

## Repair

- Default TaskStatus performance sampling creates a random system-temp OpenSpec project, copies the already accepted packaged EXE, creates one active Task Graph, and performs setup outside the timed interval.
- Timed samples still invoke the real `Invoke-Hardness -Command task.status` route. Explicit `-TaskChange` still measures the selected active project change.
- Fixture cleanup verifies both the normalized system-temp prefix and the `hardness-performance-task-` basename before recursive deletion.
- Protocol audit points to the exact immutable dogfood archive. It does not add a second change resolver or make `task.status` read historical tasks.
- Closure guidance now requires archive-stable reusable fixtures, durable aggregate registration before archive, and an applicable post-move non-destructive gate.

## Verification

- Targeted `Test-Hardness.Tests.ps1`: PASS in Windows PowerShell 5.1 and PowerShell 7.
- Targeted `Protocol.Tests.ps1`: PASS in Windows PowerShell 5.1 and PowerShell 7.
- Full Quick profile: `10/10 PASS`.
- Performance profile with three warmups and fifteen measurements: `2/2 PASS`.
- No `hardness-performance-task-*` fixture remained in the system temp directory.
- `.agents/skills/openspec/bin/openspec.exe` and `Tools/openspec` remain unchanged.

The previous aggregate remains valid for the original committed snapshot. Its TaskStatus values used the real active dogfood change and are not directly comparable with the new minimal hermetic fixture. FreshProcess and PersistentApi retain the same measurement definitions.
