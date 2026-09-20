---
replan_id: "replan-20260918-091500-verification-stages"
status: "applied"
source: "user"
source_ref: "talks/grill-20260918-083859-verification-stages-bee9f2.md"
scope: "Q8=S Q9=R Q10=T Q11 reject-now delete-later. Split 1.5/1.6/1.7; one DECLARE table plus 60-row matrix; keywords transitional reject only."
base_commit: "38e1b7a4fe9bbc540106f28d7858ccd5d899868f"
base_tasks_sha256: "386a4ed2f5ff5b6017c3cd5fd3f4f0991ef1cd5dd6bd307f85f8ace7a2a4f0fd"
result_tasks_sha256: "8973856553bcfedb14b73b8aae4d58dbb6684e86b815132eebca776955fb8e0f"
created_at: "2026-09-18T09:17:27.792242+00:00"
resume_task: "1.1"
request_sha256: "d89ffb83e9aa9c47cf3c525fbece2f4239b7ffc2fe489ae195edfc48b1c89133"
task_changes: {"added": ["1.5", "1.6", "1.7"], "removed": [], "modified": ["1.1", "1.2", "1.4", "2.1", "3.2"]}
edge_changes: {"added": ["1.1 -> 1.6", "1.2 -> 1.5", "1.2 -> 1.7", "1.7 -> 2.1", "1.7 -> 3.2"], "removed": ["1.2 -> 3.2"]}
---

## Trigger and Evidence

- Source: ../talks/grill-20260918-083859-verification-stages-bee9f2.md

## Decision

- Q8=S Q9=R Q10=T Q11 reject-now delete-later. Split 1.5/1.6/1.7; one DECLARE table plus 60-row matrix; keywords transitional reject only.

## Impact

- Artifact ~: proposal.md
- Artifact ~: design.md
- Artifact ~: tasks.md
- Artifact ~: specs/angelscript/language/frontend/lexing/spec.md
- Artifact ~: specs/angelscript/language/frontend/declarations/spec.md
- Artifact ~: specs/angelscript/language/frontend/preprocessing/spec.md
- Artifact ~: specs/angelscript/language/frontend/bodies/spec.md
- Artifact ~: specs/angelscript/language/frontend/reflection-dependencies/spec.md
- Artifact ~: specs/angelscript/testing/language-fixtures/spec.md
- Artifact ~: specs/angelscript/runtime/delegates/spec.md
- Artifact ~: specs/angelscript/bindings/delegates/spec.md

## Diff Snapshot

- Task +: 1.5, 1.6, 1.7
- Task -: none
- Task ~: 1.1, 1.2, 1.4, 2.1, 3.2
- Edge +: 1.1 -> 1.6, 1.2 -> 1.5, 1.2 -> 1.7, 1.7 -> 2.1, 1.7 -> 3.2
- Edge -: 1.2 -> 3.2

```text
M openspec/changes/angelscript/feature-delegates-ue-interop/proposal.md
 M openspec/changes/angelscript/feature-delegates-ue-interop/tasks.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/design.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/bindings/delegates/spec.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/declarations/spec.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/lexing/spec.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/language/frontend/preprocessing/spec.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/runtime/delegates/spec.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/specs/angelscript/testing/language-fixtures/spec.md
.../feature-delegates-ue-interop/proposal.md       | 104 ++--
 .../feature-delegates-ue-interop/tasks.md          | 625 ++++++++++++++++-----
 2 files changed, 522 insertions(+), 207 deletions(-)
```

## Old Task Disposition

- Existing IDs and completed tasks retained.

## Preserved Work

- Valid prior work and evidence remain; changed behavior requires fresh proving evidence.

## References and Result

- Resume: 1.1
