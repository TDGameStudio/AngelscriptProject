---
replan_id: replan-20260908-012319-compiled-sdk-consumers
status: applied
source: implementation
source_ref: task-2.1-callable-sdk-red-and-direct-consumer-search
scope: task-2.1-and-2.2-compiled-SDK-consumers
base_commit: 62d15e1ab9721fd12ad85fec55a2fc5569dd6059
base_tasks_sha256: dbaf462fac3143fc8a42d1f744571a144c4c4ca04b5941cff73342b133842fcb
result_tasks_sha256: 1f29b7f64ea9cc7e3d4f23fed19579b89de620086db18507652ce904de514081
created_at: 2026-09-08T01:23:19.179679+08:00
resume_task: 2.1
---

## Trigger and Evidence

Task 2.1 RED `3306b8a9ddac478683ef59604a21427d` confirms three old-API absence failures while five runtime controls pass. Direct source inspection found missing compile consumers outside the SDK Files package: Dump/AngelscriptStateDump.cpp:973 calls GetFuncdefCount; Dump/AngelscriptOfflineSymbolExporter.cpp:65 and :86 reads asOBJ_FUNCDEF; Cache/AngelscriptCacheEnvironment.cpp:41/:224/:228 uses CastToFuncdefType and GetFuncdefSignature; StaticJIT/PrecompiledData.cpp:852/:949/:1252 and StaticJIT/BytecodeJIT/AngelscriptBytecodes.cpp:935 use IsFuncdef. Their dedicated type/enum consumers extend into the same packages and Core/Artifacts/AngelscriptArtifactIdentity.h.

The same compiled packages directly consume task 2.2 interfaces: Dump/AngelscriptStateDump.cpp:951/:954 uses engine module enumeration; Dump/AngelscriptOfflineSymbolExporter.cpp:119/:1281 uses asOBJ_SHARED and TypeInfo.GetModule; StaticJIT/PrecompiledData.cpp:888/:967/:1086 and StaticJIT/StaticJITHeader.cpp:144 use mutable legacy module provenance. Runtime Build.cs compiles these source packages; dormant startup does not exclude their C++ type checking.

## Decision

Expand only pending task 2.1/2.2 Files ownership to these direct SDK consumers, with explicit feature and startup exclusions. Preserve requirements, retained behavior, proving selections, task IDs and edges. No user decision or new feature authority is needed for a compiled consumer of the already authorized breaking SDK change.

## Impact

No product behavior changes in this update. The planned coordinated API migration now owns the full compile boundary. Persisted numeric identities and existing witness bytes remain stable; old public forwarding aliases remain prohibited.

## Old Task Disposition

Tasks 1.1/1.2 remain complete with their existing evidence. Tasks 2.1/2.2 remain pending under their permanent IDs. No task is added, removed or unchecked.

## Diff Snapshot

- Task ~: 2.1 and 2.2 Files and bounded-consumer prose.
- Task +/-: none; edge +/-: none.
- Artifact ~: design.md, tasks.md, attachments/INDEX.md.
- Base affected status: M openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/INDEX.md;  M openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md
- Base diff stat: .../attachments/INDEX.md                                     |  2 +-;  .../refactor-language-surface-ue-focused/tasks.md            | 12 +++++++++---;  2 files changed, 10 insertions(+), 4 deletions(-)

## Preserved Work

NativeEngine GREEN `0c8a40863bc44ca88dbde5ee33131ad6` (937/937) remains the 1.2 snapshot. CallableSDK RED and baseline controls remain valid; no implementation was changed during this update. Unrelated workspace changes remain untouched.

## References and Result

Candidate validation before current-file writes proved identical frontmatter DAG, checkbox identity/history and exact proving commands, with 8 permanent nodes. Resume task 2.1 after strict validation. The small reverse patch preserves the uncommitted pre-update text identified by base_tasks_sha256.

- [Current tasks](../../tasks.md)
- [Reverse planning patch](../data/replans/replan-20260908-012319-compiled-sdk-consumers-before.patch)
