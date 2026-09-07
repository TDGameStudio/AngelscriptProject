---
replan_id: replan-20260905-110535-windows-archive-watch
status: applied
source: implementation
source_ref: implementation/issue-20260905-110535-windows-archive-watch.md
scope: Windows listener compatibility with external archive moves
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 3249c169b99708e5a83b836b838255f39cabf912e0c26e869c46a1fb8be57f5c
result_tasks_sha256: 633d4f7f4183512a10c44c25e60372759b549cb35e7ae8e768574308290ea5f0
created_at: 2026-09-05T11:07:09.4197974+08:00
resume_task: "3.4"
---
## Trigger and Evidence

The indexed Windows archive-watch issue proves the selected listener prevents a required external record move while the app is alive. Prior application tests did not include that boundary.

## Decision

Use a per-instance bounded polling watcher on Windows and verify rename plus continued invalidation. Preserve the existing native watcher on other platforms and all file-scope restrictions.

## Impact

Design and the Workspace access delta gain external archive compatibility. Add independent task 3.4 after completed 3.2 so the backend repair can run alongside the user's task 3.3 visual refinement.

## Old Task Disposition

The seven original tasks remain complete with their own earlier proof. Task 3.3 remains pending and unchanged. Closure waits for both follow-ups and the issue resolution.

## Diff Snapshot

- Affected new untracked source: Tools/harness-web and this active Change.
- Task +3.4 and DAG edge +3.2 -> 3.4; no existing task or edge removed.
- Design, delta spec, tasks and INDEX updated; one v2 implementation issue and this applied replan added.
- Existing tracked integration diff remains OpenSpec Skill 1 line replacement and reference registry 22 added lines; unrelated dirty content is preserved.

## Preserved Work

Native records, document protection, UI semantics, previous tests and the selected workspace remain unchanged in scope. No arbitrary workflow command endpoint is introduced.

## References and Result

The candidate DAG was validated before application: nine unique nodes and no cycles. Resume 3.4 in parallel with 3.3; final evidence must cite the focused adapter regression and actual archive result.