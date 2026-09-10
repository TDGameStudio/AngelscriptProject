---
replan_id: replan-20260910-182000-image-intermediate-no-shared-ptr
status: applied
source: user
source_ref: "User: asCMetadataImage is intermediate, holds no data, returns UE class info, assists delayed Engine TypeInfo; do not use shared_ptr; continue Image refactor"
scope: "Image lifetime, TypeInfo ownership, BindInfo publication, no std::shared_ptr"
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: 20f18b16b272c91f15c94e85bc0e677fbb3e9845f1af5ee9404c8e234af80e7b
result_tasks_sha256: d3e50067aab5535a50b856c8135627661672c8a28f4f8ef2d020da5cedcce4dd
created_at: 2026-09-10T18:20:00+08:00
resume_task: 7.1
---

# Applied Image-intermediate replan

## Trigger and Evidence

The user overturned Image-as-graph-owner. Image is a unique helper that returns class facts to UE and delays Engine TypeInfo. `std::shared_ptr` is forbidden for Image/TypeInfo ownership. Current source still uses shared_ptr Image graphs. Tasks 1.1 and 2.3 remain valid measurements/allocator work.

## Decision

BindInfoStore is durable pre-Engine class information. Image is `TUniquePtr`, discarded after use. Each Engine uniquely materializes TypeInfo. Registry only issues IDs. A and B share publication IDs, never TypeInfo pointers.

## Impact

Proposal, design, all five delta specs, query matrix, binding-pipeline shared-Image conclusion, and the Task DAG change. Abandoned 2.1 `Register(std::shared_ptr)` edits are reverted in 7.1.

## Old Task Disposition

| ID | Disposition |
| --- | --- |
| 1.1 | preserved (completed baseline of old contract) |
| 2.3 | preserved (completed numeric allocator) |
| 2.1, 2.2, 2.4 | superseded by 7.1-7.3 |
| 3.1, 3.2 | superseded by 7.4-7.6 |
| 4.1, 4.2 | superseded by 7.7 |
| 5.1, 5.2 | superseded by 7.8-7.9 |
| 6.1, 6.2 | superseded by 7.10 |

## Diff Snapshot

```text
?? openspec/changes/angelscript/feature-types-explicit-ownership/
Tasks +: 7.1-7.10
Tasks -: 2.1, 2.2, 2.4, 3.1-6.2 (removed from current DAG)
Edges: 7.1 after 2.3; 7.n after 7.(n-1)
Artifacts ~ proposal, design, five specs, INDEX, query-contract; + talk, this replan
```

## Preserved Work

1.1 Baseline 5/5 and 2.3 Allocation 4/4. Pointer-free reservation API remains. Bind_FName.cpp and unrelated worktrees remain untouched.

## References and Result

Resume 7.1 Image unique-intermediate refactor. See talk-20260910-182000-image-intermediate-no-shared-ptr.md.
