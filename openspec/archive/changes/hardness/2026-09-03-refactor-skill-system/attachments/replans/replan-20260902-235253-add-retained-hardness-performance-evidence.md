---
replan_id: replan-20260902-235253-add-retained-hardness-performance-evidence
status: applied
source: user
source_ref: "User request to add Hardness test performance coverage and retain its test data"
scope: hardness-performance-measurement-and-evidence-retention
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 9750f95feb5146b1236748b34791022b03dab9e41a36863ee0e15c777ecb475b
result_tasks_sha256: 26ece9df203333eeb6a9255b3da4cf9d686a946ea3c4b82b07a2a1c2235af4d5
created_at: 2026-09-02T23:52:53.6823249+08:00
resume_task: "1.7"
---

# Replan — Add retained Hardness performance evidence

## Trigger and Evidence

The user explicitly added Hardness test-performance measurement and retained test data to the harness outcome. Read-only inspection confirmed that `Test-Hardness.ps1` already records per-check `DurationMs` in its transient result but has only `Quick` and `Integration` profiles, writes no durable artifact, and has no repeated persistent-session or real `task.status` measurement. Existing project performance guidance separates raw ignored run artifacts from a small committed human/audit summary.

## Decision

- Keep `Test-Hardness.ps1` as the single public test entry and add a `Performance` profile; do not add a parallel public measurement command or new Hardness export.
- Put the focused measurement implementation in `Hardness.Performance.Tests.ps1`. Measure fresh-process module/API cost, batched persistent-session API cost, and real `task.status` independently in Windows PowerShell 5.1 and PowerShell 7, validating behavior for every timed sample.
- Write unique `Summary.json` and `Samples.csv` artifacts under `Saved/Harness/Hardness/Performance/<RunId>/`. Never overwrite or automatically delete earlier runs.
- Use sample/schema/correctness checks and broad catastrophe caps as hard gates. Treat single-baseline deltas and high variance as warnings until representative same-class history supports a portable regression threshold; never compare PS5 and PS7 as competitors.
- Preserve one accepted privacy-trimmed aggregate below `attachments/data/` with source artifact hashes and a relative Saved path. Do not commit raw samples, usernames, machine names, or absolute paths.
- Add Task `2.7` after the final OpenSpec 0.8.1 package, reviewed Harness/UE repairs, and completed Task Graph route. Make it the immediate predecessor of the combined Harness/UE Review Gate so the fixed snapshot includes the runner, schemas, and evidence.

## Impact

The DAG grows from 17 to 18 nodes and retains nine completed tasks. Ready remains `1.7` and `2.5`; new `2.7` is blocked by `1.7`, `2.5`, and completed `2.6`. Task `2.4` now waits on `2.7`, which transitively proves its former implementation prerequisites and adds performance evidence. Final Integration expands to include the Performance profile without adding real All or StaticJIT All.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2, 1.4-1.6, 2.1-2.3, 2.6 | done | preserved unchanged | Existing completion and evidence remain valid |
| 1.7, 2.5 | pending/Ready | preserved Ready | Release repair and reviewed UE repair remain the active frontier |
| 2.7 | absent | added, blocked | Own performance behavior, persistent artifacts, and trimmed baseline evidence |
| 2.4 | pending after 2.2/2.5/2.6 | immediate predecessor replaced by 2.7 | The fixed review must include the final performance surface; 2.7 already depends on the relevant implementation frontier |
| 3.1, 3.2, 4.2 | pending | preserved unchanged | Their artifact and closure boundaries remain valid |
| 4.1 | pending | preserved edge; Integration meaning extended | Final verification now includes the Performance profile and retained artifacts |

## Diff Snapshot

```text
affected path/status: 95 worktree entries at trigger; focused future changes in Hardness test runner/tests and OpenSpec performance evidence
tasks: +2.7; ~2.4 ~4.1 acceptance meaning; 18 nodes and nine completed checkboxes
edges: +1.7->2.7 +2.5->2.7 +2.6->2.7 +2.7->2.4; -2.2->2.4 -2.5->2.4 -2.6->2.4
artifacts: ~proposal ~design ~delta-spec ~tasks ~INDEX +replan; future +Saved performance run +trimmed baseline data
```

## Preserved Work

All OpenSpec tags and review evidence, current frontmatter Task Graph semantics, Hardness routing, Quick 12/12 two-host result, Workspace/UE work, completed task states, historical Replans/reviews, and the no-All/no-StaticJIT-All acceptance boundary remain intact. Existing `Saved/*` ignore policy already contains raw performance artifacts; no ignore or cleanup mutation is needed.

## References and Result

- `Documents/Guides/TestPerformance.md`
- `.agents/skills/hardness/scripts/Test-Hardness.ps1`
- `attachments/replans/replan-20260902-233654-repair-openspec-081-review-boundaries.md`
- Candidate `task.status` validation reports 18 nodes, nine complete, Ready `1.7`/`2.5`, and no task issues.
- The tasks hash advances from `9750f95feb5146b1236748b34791022b03dab9e41a36863ee0e15c777ecb475b` to `26ece9df203333eeb6a9255b3da4cf9d686a946ea3c4b82b07a2a1c2235af4d5`.
