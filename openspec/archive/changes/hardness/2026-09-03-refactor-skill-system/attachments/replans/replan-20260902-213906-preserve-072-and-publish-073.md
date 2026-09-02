---
replan_id: replan-20260902-213906-preserve-072-and-publish-073
status: applied
source: review
source_ref: "attachments/reviews/review-20260902-openspec-072-rereview.md"
scope: openspec-release-root-containment-language-and-publisher-gates
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 128a40a686eaeb49300dfa820d6882ab0c5f466032d1fb9640e0f04d38ec3f7b
result_tasks_sha256: af807448d314b909aa45b7be1aeb61f6819dc63736e7eed957aa6ceae6fb791d
created_at: 2026-09-02T21:39:06.3743189+08:00
resume_task: "1.5"
---

# Replan — Preserve 0.7.2 and publish 0.7.3

## Trigger and Evidence

The independent 0.7.2 fixed-snapshot review is `open/request_changes` with one Critical and two Required findings. The packaged executable followed a Windows junction at the project `openspec` root and successfully created a domain manifest outside the logical project; workflow `list`/`which` exposed an external workflow while `validate` refused the same root. The English gate omitted the project Skill index and broad Unicode/text classes, and the publisher began staging below an unchecked Skill root.

A Review finding does not trigger Replan by severity. These findings trigger it because immutable `v0.7.2` failed the release Review Gate, making the planned 0.7.2 acceptance target and the `1.4 -> 1.3` dependency false. Repair requires a new source commit, version, annotated tag, package identity, and fixed-snapshot review.

## Decision

- Preserve the 0.7.2 commit, annotated tag, EXE, manifest, command docs, performance evidence, and REQUEST_CHANGES review without moving or rewriting them.
- Add Task `1.5` for TDD fixes and a new immutable 0.7.3 publication.
- Make Task `1.3` review 0.7.3 after `1.5`; advance Task `3.1` packaging truth to 0.7.3.
- Centralize physical repository/publisher containment, propagate project workflow security failures, and broaden the English gate to Unicode-category and complete maintained-surface behavior.
- Preserve all completed task states and unrelated Harness/Workspace/UE work.

## Impact

Proposal, design, delta spec, Task DAG, and INDEX advance the current release truth to 0.7.3. Task `1.5` is added; Task `1.3` changes target and predecessor; Task `3.1` changes only package version evidence. No completed task is reopened. Resume from `1.5`, while independent Task `2.4` may continue in parallel.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2, 1.4, 2.1, 2.2, 2.3 | done | preserved unchanged | Their implementation and fixed-snapshot evidence remain valid |
| 1.5 | absent | added | A new immutable release is required after 0.7.2 failed review |
| 1.3 | pending/Ready | modified and blocked by 1.5 | Review must target repaired 0.7.3 |
| 3.1 | pending | version evidence modified | Distributed package must bind 0.7.3 |
| 2.4, 3.2, 4.1, 4.2 | pending | preserved unchanged | Their boundaries and dependencies remain valid |

## Diff Snapshot

```text
affected path/status: M Tools/openspec; M .agents/skills/openspec/bin/openspec.exe; M .agents/skills/README.md; ?? openspec/ (review/current records); 91 total worktree status entries at trigger
tasks: +1.5; ~1.3 ~3.1; six completed checkboxes preserved
edges: +1.4->1.5 +1.5->1.3 -1.4->1.3
artifacts: ~proposal ~design ~delta-spec ~tasks ~INDEX +0.7.2-rereview +replan
```

## Preserved Work

Immutable releases 0.7.0–0.7.2, prior Review/Replan history, 145 passing Rust tests, byte-identical 0.7.2 rebuild evidence, both PowerShell package passes, command docs, current change identity, six completed tasks, and all Workspace/Hardness/UE fixes are preserved. The external reproduction fixtures were already safely removed by the reviewer. No patch sidecar is needed.

## References and Result

- `attachments/reviews/review-20260902-openspec-072-rereview.md` (SHA-256 `ff98b75768ab55bfb73adc2ad9c19b78d7b2efe0533418751637a7e86c9f03e4`)
- `attachments/replans/replan-20260902-204741-enforce-english-and-integrate-after-verification.md`
- `attachments/replans/replan-20260902-212534-repair-stale-doctor-gate.md`
- Before the change, the DAG was 12/6/6 with Ready `1.3`/`2.4`, zero issues, and tasks hash `128a40a686eaeb49300dfa820d6882ab0c5f466032d1fb9640e0f04d38ec3f7b`.
- Result: the candidate DAG is 13/6/7 with Ready `1.5`/`2.4`, zero issues, strict validation `1/1`, and tasks hash `af807448d314b909aa45b7be1aeb61f6819dc63736e7eed957aa6ceae6fb791d`.
