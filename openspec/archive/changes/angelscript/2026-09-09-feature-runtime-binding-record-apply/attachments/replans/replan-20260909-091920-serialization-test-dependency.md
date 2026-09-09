---
replan_id: replan-20260909-091920-serialization-test-dependency
status: applied
source: implementation
source_ref: task 7.6 Harness build run 5bb3eedd67694ca08a13c4d4353c0443
scope: task 7.6 test-module dependency ownership
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: d3b651823d634d1f7a2ccf5b26670e2c422f69939374830cfc173452bb8a0217
result_tasks_sha256: 602b75edfc2db1406ae787a3431929a60de6e5b0795575716b93d12432bc1604
created_at: 2026-09-09T09:19:20+08:00
resume_task: 7.6
---

## Trigger and Evidence

Task 7.6's prepared reflected-struct round-trip test uses the public `FJsonObjectConverter` API. Harness build run `5bb3eedd67694ca08a13c4d4353c0443` compiled that fixture and then failed to link its `JsonUtilities` symbols because the enabled replacement-test target did not depend on `JsonUtilities`. The same run also showed that directly calling private, non-exported JSON bind helpers from the test crosses the module boundary; that fixture call has been replaced with invocation through the installed public binding surface.

## Decision

Add `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` to task 7.6's Files boundary. The task may add `JsonUtilities` to the replacement-test dependencies. Keep behavioral assertions on installed binding calls or public engine/module APIs.

## Impact

The accepted serialization behavior, cases, proving command, task ID and dependency edges remain unchanged. Only the test-module file boundary required to compile and link the already-required reflected serialization fixture changes.

## Old Task Disposition

Task 7.6 remains pending and resumes after this applied correction. All thirty-seven completed tasks and their evidence remain valid.

## Diff Snapshot

- Affected path status: `RuntimeBindingSerializationTests.cpp` is an untracked task 7.6 fixture; `AngelscriptTest.Build.cs` already contains the task 7.4 replacement dependencies and gains one task 7.6 dependency.
- Affected implementation diff stat: one additive dependency line beyond the prior task 7.4 Build.cs state, plus the untracked serialization fixture.
- Task changes: `~ 7.6` Files boundary; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `~ attachments/INDEX.md`.

## Preserved Work

The six prepared task 7.6 cases, both failed setup builds and all completed task outcomes are preserved. Neither setup failure is claimed as behavioral RED.

## References and Result

The candidate retains all 46 task cards, leaves the DAG and task 7.6 outcome unchanged, and assigns the needed test dependency to the pending task. Strict OpenSpec validation follows this atomic application. The resulting raw task document hash is `602b75edfc2db1406ae787a3431929a60de6e5b0795575716b93d12432bc1604`; execution resumes at task 7.6.
