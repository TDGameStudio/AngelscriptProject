---
replan_id: "replan-20260918-083200-full-macro-system"
status: "applied"
source: "user"
source_ref: "talks/grill-20260918-082041-stale-host-join-86f515.md"
scope: "Keep Change. Drop delegate/event keywords. Full 60 DECLARE_* macros + Bind/Execute. Later payload/native/BP/cook nodes retained. NativeEngine identities."
base_commit: "38e1b7a4fe9bbc540106f28d7858ccd5d899868f"
base_tasks_sha256: "9803345bc6fa4823f2aff60e5563d913fd6b034340e0926fbafee00d2de08bdf"
result_tasks_sha256: "4eb0f27c027faa6d8e79d8a31fb7d6f64d9a31975936ae6de889b4c2b7af0f29"
created_at: "2026-09-18T08:30:18.887166+00:00"
resume_task: "1.1"
request_sha256: "4cd58b32b0143092a522186d38645f3d1c878f055e3c1d0a055ab4b62a0725f8"
task_changes: {"added": [], "removed": [], "modified": ["1.1", "1.2", "1.3", "2.1", "2.2", "2.3", "3.1", "3.2", "3.3", "4.1"]}
edge_changes: {"added": [], "removed": []}
---

## Trigger and Evidence

- Source: ../talks/grill-20260918-082041-stale-host-join-86f515.md

## Decision

- Keep Change. Drop delegate/event keywords. Full 60 DECLARE_* macros + Bind/Execute. Later payload/native/BP/cook nodes retained. NativeEngine identities.

## Impact

- Artifact ~: tasks.md
- Artifact ~: specs/angelscript/language/frontend/preprocessing/spec.md
- Artifact ~: specs/angelscript/testing/language-fixtures/spec.md
- Artifact ~: proposal.md
- Artifact ~: design.md
- Artifact ~: specs/angelscript/language/frontend/lexing/spec.md
- Artifact ~: specs/angelscript/runtime/delegates/spec.md
- Artifact ~: specs/angelscript/language/frontend/declarations/spec.md
- Artifact ~: specs/angelscript/bindings/delegates/spec.md

## Diff Snapshot

- Task +: none
- Task -: none
- Task ~: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 4.1
- Edge +: none
- Edge -: none

```text
M openspec/changes/angelscript/feature-delegates-ue-interop/proposal.md
 M openspec/changes/angelscript/feature-delegates-ue-interop/tasks.md
.../feature-delegates-ue-interop/proposal.md       |  2 +-
 .../feature-delegates-ue-interop/tasks.md          | 58 ++++++++++++----------
 2 files changed, 33 insertions(+), 27 deletions(-)
```

## Old Task Disposition

- Existing IDs and completed tasks retained.

## Preserved Work

- Valid prior work and evidence remain; changed behavior requires fresh proving evidence.

## References and Result

- Resume: 1.1
