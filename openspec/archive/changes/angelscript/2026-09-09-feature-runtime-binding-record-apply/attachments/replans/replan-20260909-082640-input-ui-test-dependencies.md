---
replan_id: replan-20260909-082640-input-ui-test-dependencies
status: applied
source: implementation
source_ref: task 7.4 Harness build run 6545c767512d439ca79815ee6e9f176b
scope: task 7.4 test-module dependency ownership
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 496d78408014df4463e9d948759a86cd53d9d39a7edeab1c98a6f6cb7c9db14f
result_tasks_sha256: b69fc3b1b61716c9c0e9be0d33b98a3bb575a88ed28b580e258b7bbc41fbb8bf
created_at: 2026-09-09T08:26:40+08:00
resume_task: 7.4
---

## Trigger and Evidence

Task 7.4's prepared Input/UI tests include Enhanced Input, InputCore, Slate and UMG headers. Harness build run `6545c767512d439ca79815ee6e9f176b` failed during setup because `EnhancedInputComponent.h` was unavailable to the replacement-test target. `AngelscriptTest.Build.cs` exposes those modules only inside the disabled legacy-test branch, while the enabled replacement-test branch owns only Json and CQTest.

## Decision

Add `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` to task 7.4's Files boundary. The task may add the existing input/UI module dependencies to the replacement-test branch before resuming its grouped behavioral RED run.

## Impact

The accepted Input/UI behavior, cases, proving command, task ID and dependency edges remain unchanged. Only the file boundary needed to compile the already-required fixtures changes.

## Old Task Disposition

Task 7.4 remains pending and resumes after this applied correction. All completed tasks and their evidence remain valid.

## Diff Snapshot

- Affected path status: `RuntimeBindingInputUITests.cpp` is an untracked task 7.4 fixture; `AngelscriptTest.Build.cs` was unchanged at the trigger snapshot.
- Affected implementation diff stat: no tracked implementation diff for these two paths; one untracked test fixture.
- Task changes: `~ 7.4` Files boundary; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.

## Preserved Work

The six prepared task 7.4 cases and all thirty-five completed task outcomes are preserved. The failed build is setup evidence and is not claimed as behavioral RED.

## References and Result

The candidate retained all 46 task cards, matched every DAG node to one card, remained acyclic, kept task 7.4 pending and owned `AngelscriptTest.Build.cs` exactly once. Strict OpenSpec validation succeeded after application. The resulting raw task document hash is `b69fc3b1b61716c9c0e9be0d33b98a3bb575a88ed28b580e258b7bbc41fbb8bf`; execution resumes at task 7.4.
