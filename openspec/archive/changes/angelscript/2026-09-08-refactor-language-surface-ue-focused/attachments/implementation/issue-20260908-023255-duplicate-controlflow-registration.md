---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260908-023255-duplicate-controlflow-registration
status: resolved
source: verification
source_ref: d8a6408a76894173b17110dbfa9bddd4
affected_tasks: ["5.1", "5.3", "5.4"]
resolved_at: 2026-09-08T02:38:52.252541+08:00
resolution_ref: "7aed02a253bb44e58de9630011901219; ee999f8fc1804143afd027ef98f43a3a"
created_at: 2026-09-08T02:32:55.518311+08:00
---

## Symptom

NativeEngine reported 960/960 Success but eight existing retained control-flow methods were absent from discovery.

## Investigation Log

Baseline startup inspection found the BodiesControlFlow duplicate-registration warning. Exact source inspection found that class name in two C++ namespaces: BodySemanticTests.cpp:506 and BodyControlFlowTests.cpp:24. The report contains the latter twelve methods and none of the former eight. Original Syntax RED run 762f7a5565c34fa0aef0ba119b5b4ffd already emits the same warning, proving it predates this implementation.

## Root Cause

CQTest registers the unqualified class identity globally. C++ namespaces do not distinguish that registration. The second class is suppressed before test discovery, so aggregate success cannot report it as skipped or failed.

## Disposition

Resolved in 5.3/5.4 by renaming only the suppressed class to BodiesStructuredControlFlow, preserving every fixture/assertion, and refreshing both final selectors on the unchanged binary.

## Evidence

### Failure Evidence (RED)

`Invoke-Harness -Command ue.test -Context $context -Parameters @{TestPrefix='Angelscript.UnitTest.NativeEngine';Fast=$true;TimeoutMs=600000}`, run d8a6408a76894173b17110dbfa9bddd4: all eight task 5.3 method names absent from AutomationReport/index.json; Unreal.log contains duplicate BodiesControlFlow registration. Prior report hash and complete discovered identities are retained in implementation-verification.md.

### Resolution Evidence (GREEN)

Build c876f6a9bb6f459abbf07188970df08b succeeded. Exact NativeEngine selector run 7aed02a253bb44e58de9630011901219 executes 968/968 Success, including the eight restored and twelve original control-flow cases, with zero test warnings and no startup duplicate registration. The same explicit eight-method check now reports zero missing executions. Baseline ee999f8fc1804143afd027ef98f43a3a passes all three cases on the identical source/seven-DLL snapshot; its 2,436 MetaSound warnings are preserved in implementation-verification.md.

### What This Proves

The missing coverage has a demonstrated registration cause independent of compiler behavior; prior 960 passing cases remain valid individually.

### What This Does Not Prove

The restored eight fixtures now execute, but this repair does not add language/runtime behavior, restore removed features or certify omitted Standalone/JIT/cooked suites.

## Links

- [Tasks](../../tasks.md)
- [Current implementation evidence](../data/implementation-verification.md)
- [Applied discovery replan](../replans/replan-20260908-023255-complete-controlflow-discovery.md)
