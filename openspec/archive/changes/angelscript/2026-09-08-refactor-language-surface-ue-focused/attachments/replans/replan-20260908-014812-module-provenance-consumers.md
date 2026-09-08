---
replan_id: replan-20260908-014812-module-provenance-consumers
status: applied
source: implementation
source_ref: ue-build-2ec621c7d06148d0be524fd063f61f75
scope: task-2.2-direct-module-provenance-consumers
base_commit: 62d15e1ab9721fd12ad85fec55a2fc5569dd6059
base_tasks_sha256: 313ad5c298301dfb20c90b6e8260c708b51ef0913a816f2a9036b727182d3fc2
result_tasks_sha256: a16cee500da8166f72bfdae5b56c3a8a497cfa22a6bacd6646ef54409bd3b4b4
created_at: 2026-09-08T01:48:12.627591+08:00
resume_task: 2.2
---

## Trigger and Evidence

The coordinated SDK removal build `2ec621c7d06148d0be524fd063f61f75` type-checks additional direct GetModule/GetModuleName consumers outside task 2.2 Files: five ClassGenerator source files, Debugging/AngelscriptDebugServer.cpp and RuntimeJIT/AngelscriptRuntimeJITSnapshot.cpp. UBT reports C2039 at Analyze:120/147, Finalize:56, FullReload:351, ASClass_Metadata:113/126/139, ASFunction:191, DebugServer:2980/3273 and RuntimeJITSnapshot:607/881. Startup dormancy does not exempt these C++ consumers from compilation.

## Decision

Add only these seven concrete files to pending task 2.2, limited to removed SDK provenance calls and their existing compatibility boundary. Keep product requirements, exact proving command and all task edges. This extends the compiled-consumer correction with compiler evidence, not a new generator, debugger or JIT feature.

## Impact

The public metadata SDK loses mutable module provenance; private dormant consumers can inspect their existing internal carrier where still needed. Retained diagnostic identity uses stable keys. No source authoring, UE reflection policy, backend execution or startup activation changes in this planning update.

## Old Task Disposition

Tasks 1.1, 1.2 and 2.1 remain complete. Task 2.2 retains its ID and remains pending. No nodes are added, removed or unchecked.

## Diff Snapshot

- Task ~: 2.2 Files and bounded-consumer prose only.
- Task +/-: none; edge +/-: none.
- Artifact ~: design.md, tasks.md, attachments/INDEX.md.
- Base affected status: M openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/INDEX.md;  M openspec/changes/angelscript/refactor-language-surface-ue-focused/design.md;  M openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md; ?? openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/data/replans/; ?? openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/replans/
- Base diff stat: .../attachments/INDEX.md                           |  5 +++-;  .../refactor-language-surface-ue-focused/design.md |  2 +-;  .../refactor-language-surface-ue-focused/tasks.md  | 28 +++++++++++++++-------;  3 files changed, 25 insertions(+), 10 deletions(-)

## Preserved Work

NativeEngine run `950dec0ccd5a4bcab1cc25071bf290a0` remains the 945/945 task 2.1 snapshot. SDK RED `e712f55935d449f797769ef96616816f` observes four missing API-policy groups and three passing runtime controls. The current compile failure is not RED evidence. No implementation changes occur in this planning update.

## References and Result

Candidate validation before writes confirmed identical frontmatter, eight permanent nodes, checkbox history and exact proving commands. Resume task 2.2 after strict validation. The reverse planning patch preserves the uncommitted base text.

- [Current tasks](../../tasks.md)
- [Reverse planning patch](../data/replans/replan-20260908-014812-module-provenance-consumers-before.patch)
