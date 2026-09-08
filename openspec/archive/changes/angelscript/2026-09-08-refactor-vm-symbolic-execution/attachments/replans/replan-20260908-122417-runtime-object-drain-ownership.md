---
replan_id: replan-20260908-122417-runtime-object-drain-ownership
status: applied
source: review
source_ref: review-20260908-121727-vm-runtime-acceptance-reviewer.md#Z01
scope: sdk-object-runtime-ownership-and-retirement-drain
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 83d34f8ef210f09d920fcb6a99cf898abac54c76b7322e5631e1e252b3dea217
result_tasks_sha256: 725959b1e1dfdca5f9e420c280d62b7777de46ec791673848a827abc725739c9
created_at: 2026-09-08T12:24:17.797714+08:00
resume_task: 8.7
---

## Trigger and Evidence

Immutable Review Z01 proves allocation stores unowned Type/Engine pointers and ordinary script destructor Prepare is rejected after shutdown, while retirement removes its executable binding. Existing shutdown fixtures use native destructors and extra Engine references. NativeEngine 1068/1068 and Baseline 3/3 are valid for their cases; they do not discharge this original F05 clause.

## Decision and Impact

Add 8.7 after 8.6/7.4; add 8.7 as final 11.4 prerequisite. Implement object/runtime ownership and ordered internal script cleanup/drain, preserving public shutdown rejection and current native generations. Accepted requirements already require this lifetime boundary; design now makes object/execution/GC ownership and cleanup authority explicit. No AST, source grammar, UE integration, Standalone or JIT expansion.

## Old Task Disposition and Preserved Work

All 53 checked nodes remain checked. 7.4 remains complete with its seven-generation/stomp and shared proof; 11.4 stays pending. The new Review stays open CHANGES_REQUIRED and all earlier text/evidence is retained. No historical failure is rewritten or reused as proof of the new cases.

## Diff Snapshot

Task +8.7, ~11.4 prerequisite; edges +8.7<-8.6, +8.7<-7.4, +11.4<-8.7; no removed tasks or edges. Artifacts ~design.md, tasks.md and INDEX plus this record. Exact pre-replan path status/stat:

```text
M Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp
 M Source/AngelscriptTest/NewVersion/NativeEngine/VM/NativeVMTestSupport.h
 M Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMShutdownDrainTests.cpp
.../ThirdParty/angelscript/source/as_scriptengine_metadata.cpp |  2 ++
 .../NewVersion/NativeEngine/VM/NativeVMTestSupport.h           | 10 ++++++++++
 .../NewVersion/NativeEngine/VM/VMShutdownDrainTests.cpp        |  6 +++++-
 3 files changed, 17 insertions(+), 1 deletion(-)
```

## Candidate Validation and Resume

Before tracked writes: 55 unique IDs, exact graph membership, valid dependencies, acyclic DAG and 53 preserved completed nodes. New 8.7 is Ready; strict Change validation and task.status follow before code writes. Resume 8.7.
