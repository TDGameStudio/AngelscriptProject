---
replan_id: replan-20260903-112507-order-review-before-knowledge-promotion
status: applied
source: agent
source_ref: ".agents/skills/openspec/references/knowledge.md#Admission-and-promotion"
scope: order recovery evidence, independent Review, issue resolution, knowledge promotion, and closure
base_commit: 7f4e8667cf7a987111d8b3fc47da10401540ee90
base_tasks_sha256: 392b65a409e330211c14d3e491548ea263e6f80c661c9ad2114c757d6886cbd5
result_tasks_sha256: be6c80897f20f7388efce489480b5267673261e5b25a5de1ae67df7b8b74892f
created_at: 2026-09-03T11:25:07+08:00
resume_task: "3.4"
---

# Order Review Before Knowledge Promotion

## Trigger and Evidence

After PS7 Quick passed `5/5`, the coordinator prepared Task 3.3 and found that it would resolve the recovery issue and promote capability knowledge before the independent Review in Task 4.1. The accepted knowledge contract requires repair, verification, and required re-review before promotion. The existing dependency edge therefore made the plan false even though the implementation and verification remained valid.

## Decision

Keep the recovery issue open while registering current gate evidence, run independent Review next, then resolve the issue and promote the reusable checkpoint only after that Review closes. Move closure preparation behind promotion. No product or implementation scope changes.

## Impact

- The existing pending Task 3.3 is split into evidence registration and post-Review promotion.
- The existing pending closure Task 4.2 moves to a new permanent ID after promotion.
- Review remains the same independently owned fixed-snapshot gate.
- All completed work and passing evidence remain valid.

## Old Task Disposition

- `1.1`, `2.1`, `2.2`, `3.1`, `3.2`: preserved complete with their original IDs and evidence.
- `3.3`: superseded before execution by `3.4` for open-issue evidence and `4.3` for post-Review resolution/promotion.
- `4.1`: preserved pending; its prerequisite changes from old `3.3` to `3.4`.
- `4.2`: superseded before execution by `5.1`; its closure outcome remains unchanged but now follows `4.3`.

## Diff Snapshot

```text
base commit: 7f4e8667cf7a987111d8b3fc47da10401540ee90
affected status: parent Skill/OpenSpec/README paths modified; recovery Change and focused references untracked; unrelated workspace changes preserved
affected diff stat: 16 tracked files, 688 insertions, 76 deletions before new Change artifacts

Task -: 3.3, 4.2
Task +: 3.4, 4.3, 5.1
Task ~: 4.1 prerequisite only

Edge -: 3.2 -> 3.3, 3.3 -> 4.1, 4.1 -> 4.2
Edge +: 3.2 -> 3.4, 3.4 -> 4.1, 4.1 -> 4.3, 4.3 -> 5.1

Artifact +: attachments/replans/replan-20260903-112507-order-review-before-knowledge-promotion.md
Artifact ~: tasks.md, attachments/INDEX.md
```

## Preserved Work

- The strict pre-creation Explore and active Change checkpoint design.
- Focused task, issue, attachment, and knowledge references.
- OpenSpec Skill and Protocol test passes.
- PS7 Hardness Quick `5/5` result.
- The open recovery issue and all unrelated dirty workspace content.

## References and Result

- Source contract: `.agents/skills/openspec/references/knowledge.md`
- Current plan: `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`
- Result Task DAG SHA-256: `be6c80897f20f7388efce489480b5267673261e5b25a5de1ae67df7b8b74892f`
- Strict validation passed after application; resume at Task `3.4`.
