---
replan_id: replan-20260910-041848-external-type-prerequisite
status: applied
source: user
source_ref: angelscript/feature-types-external-ownership/proposal.md
scope: SDK external type ownership prerequisite and shared preparation handoff
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: 5d02f54cecca118489df2981a4583e5d016494c906c1714be99b749088db57cc
result_tasks_sha256: 2a5f651092987dad8db35ad0534d686ccfdb81022c3d982dceeee50533f5a976
created_at: 2026-09-10T04:18:48.9136724+00:00
resume_task: "0.1"
---

# External type SDK prerequisite

## Trigger and Evidence

The user accepted a new SDK Change distinguishing externally prebuilt C++ types from Engine-owned AS definitions, layered ID queries and a prerequisite handoff. Existing task 2.4 rejected reuse of a move-only preparation and assumed every image had one Engine. Those requirements conflict with the accepted shared TypeLibrary architecture. SDK source evidence includes universal BoundEngine maps, Context/VM owner lookup and installation pointers in TypeInfo user data; the new Change indexes the source hashes.

## Decision

The SDK Change owns external library publication, process IDs and scoped queries, private AS ownership, runtime sidecars/lifetime, reusable preparation and SDK storage accounting. This binding Change consumes that verified delivery, extends preparation for its new record model and retains its provider migration, template-member completion, adapter reconstruction and native/delegate repairs.

## Impact

Add task 0.1 to validate the producer UID, completed CLI state, source-bound handoff and current ExternalTypes integration. Task 1.1 now measures the post-SDK binding baseline. Task 1.2 consumes SDK GetMemoryStats. Tasks 2.1/2.4 move/extend shared const PreparedBindings rather than implementing a competing ownership system. External prebuilt template definitions may be shared; all mutable operations and newly materialized private definitions remain owner-scoped.

## Old Task Disposition

All original 23 task IDs remain pending and are preserved. Tasks 1.1, 1.2, 2.1 and 2.4 have the handoff/ownership refinements described above. No completed task is unchecked and no SDK product work is marked done. Task 0.1 is the only new node.

## Diff Snapshot

- Before path status: untracked planning directory, `?? openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/`; tracked diff stat was empty because the record is not yet committed.
- Task change: +0.1; ~1.1, ~1.2, ~2.1, ~2.4; no removals.
- DAG: +root 0.1; +edge 1.1 -> 0.1; original downstream edges unchanged.
- Artifacts: ~proposal, ~design, ~tasks, ~runtime/binding-engine delta, ~bindings/runtime delta, ~bindings/observability delta, ~INDEX; +this applied record.
- Candidate authoring validation: 24 unique nodes, all original IDs/states retained, acyclic expected graph from CLI-owned predecessor data, and 12 new/changed proving command bodies parsed with no PowerShell syntax errors before application.

## Preserved Work

Keep the existing 254-site source inventory, independent baseline-oracle policy, exact migration families, serial default, external lambda/native enrichment contract, adapter and four required binding repairs, previous applied replans and six named runtime Scenario formatting corrections. Extension spec, prior evidence and historical records are unchanged. Current product specifications and plugin source are not modified by this planning delivery.

## References and Result

Producer: `angelscript/feature-types-external-ownership`, UID `change_6f58d4ea-1ff3-48f6-8680-df1b32635270`. Read its design and INDEX for accepted API/ownership and query evidence. Result task hash is recorded above. Resume at 0.1 only after the producer completes its implementation; structural Ready state is not evidence that the external dependency is delivered.

