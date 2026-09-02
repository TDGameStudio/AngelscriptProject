---
replan_id: replan-20260902-212534-repair-stale-doctor-gate
status: applied
source: subagent
source_ref: "Independent post-move Replan/identity audit reported that completed Task 1.1 still invoked the deleted .agents/skills/hardness/scripts/openspec.ps1 wrapper"
scope: completed-task-verification-replayability
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 3efa670b3382852f5246bc5494e17dc42c290dae440b6d426652f27f3b29464e
result_tasks_sha256: 128a40a686eaeb49300dfa820d6882ab0c5f466032d1fb9640e0f04d38ec3f7b
created_at: 2026-09-02T21:25:34.5026242+08:00
resume_task: "1.3"
---

# Replan — Repair the stale doctor gate

## Trigger and Evidence

Independent self-monitoring found that completed Task `1.1` still verified doctor through `.agents/skills/hardness/scripts/openspec.ps1`, a legacy wrapper deliberately removed by the current refactor. `tasks.md` is the current DAG and every node promises one exact verification, so retaining a command that can no longer execute makes the current acceptance contract false even though the original work completed successfully.

The packaged `.agents/skills/openspec/bin/openspec.exe doctor --json` entry exists and returned `valid: true`, zero errors, five domains, one current spec, one active change, and no archive before this record was finalized. The candidate DAG retained 12 nodes, six completed nodes, Ready nodes `1.3` and `2.4`, no task issues, and strict validation `1/1`.

## Decision

- Replace only Task `1.1`'s deleted-wrapper command with an exact portable-EXE doctor command.
- Preserve Task `1.1` as complete; this correction restores replayability and does not reopen validated work.
- Preserve every Task ID, dependency edge, file boundary, and current checkbox state.
- Record the preceding Replan's completed post-write evidence here rather than editing that immutable applied record.

## Impact

Only the verification text of completed Task `1.1` changes. No requirement, design boundary, task state, DAG edge, implementation file, release identity, or integration authority changes. Resume remains the currently Ready OpenSpec Review Gate at Task `1.3`; Task `2.4` may proceed independently.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1 | done | verification modified; completion preserved | The original wrapper was deleted, while packaged doctor is the maintained primitive |
| 1.2, 1.4, 2.1, 2.2, 2.3 | done | preserved unchanged | Their work and verification remain valid |
| 1.3, 2.4, 3.1, 3.2, 4.1, 4.2 | pending | preserved unchanged | Their boundaries, edges, and gates remain current |

## Diff Snapshot

```text
affected path/status: D .agents/skills/hardness/scripts/openspec.ps1 (stale target); M .agents/skills/openspec/bin/openspec.exe (maintained target); ?? openspec/ (current untracked record tree at base)
tasks: ~1.1 verification only; no task +/-; six completed checkboxes preserved
edges: no edge +/-
artifacts: ~tasks +replan ~INDEX; no proposal/design/spec change
```

## Preserved Work

All OpenSpec releases, prior Replans, Task `1.1` implementation evidence, identity aliases, current task progress, Workspace/Hardness/UE fixes, and review snapshots remain intact. The correction is textual and recoverable, so no patch sidecar was created.

## References and Result

- `attachments/replans/replan-20260902-204741-enforce-english-and-integrate-after-verification.md`
- The previous Replan's immediate post-write checks passed with result hash `37d8cac0d3ed5e10a57295963362d6bdb4815807473f036fd59ea22999ccabba`, 12 nodes, two completed nodes, Ready `1.4`/`2.1`, no issues, matching UID/alias, linked INDEX, English package gates in PowerShell 5.1/7, and strict validation `1/1`.
- Subsequent verified progress completed Tasks `1.4`, `2.1`, `2.2`, and `2.3` without changing that historical result.
- Result: current `tasks.md` SHA-256 is `128a40a686eaeb49300dfa820d6882ab0c5f466032d1fb9640e0f04d38ec3f7b`; the replacement doctor command passed, the DAG remained 12/6/6 with Ready `1.3` and `2.4`, and strict validation passed `1/1` before this applied record was finalized.
