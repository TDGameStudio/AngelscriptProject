---
replan_id: "replan-20260918-083500-retval-callptr"
status: "applied"
source: "user"
source_ref: "talks/grill-20260918-083234-retval-call-prerequisite-ca4146.md"
scope: "Q7=P add task 1.4 CallPtr-return prerequisite; 2.1 depends on 1.3 and 1.4."
base_commit: "38e1b7a4fe9bbc540106f28d7858ccd5d899868f"
base_tasks_sha256: "4eb0f27c027faa6d8e79d8a31fb7d6f64d9a31975936ae6de889b4c2b7af0f29"
result_tasks_sha256: "386a4ed2f5ff5b6017c3cd5fd3f4f0991ef1cd5dd6bd307f85f8ace7a2a4f0fd"
created_at: "2026-09-18T08:35:10.082681+00:00"
resume_task: "1.1"
request_sha256: "afbe95803ecfe87577dc4634a38d0114b03e295eadb3df8a6a62c55e06edfe14"
task_changes: {"added": ["1.4"], "removed": [], "modified": ["1.1", "1.2", "1.3", "2.1", "2.2", "2.3", "3.1", "3.2", "3.3", "4.1"]}
edge_changes: {"added": ["1.1 -> 1.4", "1.4 -> 2.1"], "removed": []}
---

## Trigger and Evidence

- Source: ../talks/grill-20260918-083234-retval-call-prerequisite-ca4146.md

## Decision

- Q7=P add task 1.4 CallPtr-return prerequisite; 2.1 depends on 1.3 and 1.4.

## Impact

- Artifact ~: specs/angelscript/runtime/delegates/spec.md
- Artifact ~: design.md
- Artifact ~: tasks.md

## Diff Snapshot

- Task +: 1.4
- Task -: none
- Task ~: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 4.1
- Edge +: 1.1 -> 1.4, 1.4 -> 2.1
- Edge -: none

```text
M openspec/changes/angelscript/feature-delegates-ue-interop/tasks.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/design.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/runtime/delegates/spec.md
.../feature-delegates-ue-interop/tasks.md          | 565 ++++++++++++++++-----
 1 file changed, 425 insertions(+), 140 deletions(-)
```

## Old Task Disposition

- Existing IDs and completed tasks retained.

## Preserved Work

- Valid prior work and evidence remain; changed behavior requires fresh proving evidence.

## References and Result

- Resume: 1.1
