---
replan_id: replan-20260904-172453-isolate-legacy-test-framework
status: applied
source: user
source_ref: conversation:2026-09-04-isolate-old-test-framework
scope: legacy AngelscriptTest module framework and generated TestJIT link boundary
base_commit: 47d38dffc062a79e8f9e7c319981406ea79772c3
base_tasks_sha256: 68d29c34eb4a19019cfe065129aa85012504bcb4f92925ff3b2dd6c792d04d84
result_tasks_sha256: 68d29c34eb4a19019cfe065129aa85012504bcb4f92925ff3b2dd6c792d04d84
created_at: 2026-09-04T17:24:53+08:00
resume_task: "3.2"
---

# Isolate the old test-module framework

## Trigger and Evidence

The user directed that the old test framework be isolated because a replacement framework may be built. The preceding mechanical task had already wrapped every old `AngelscriptTest` implementation file, but its module shell still unconditionally included legacy framework headers and its build rules still force-included CQTest and declared legacy-only dependencies.

Build `3982bdaac5344c92b3aa382581703c9f` also proved that `AngelscriptTestJITProbes.cpp` cannot be treated as an ordinary old test: retained generated TestJIT objects statically reference six families of registration symbols implemented there, producing `LNK2019`/`LNK2001` and final `LNK1120` when the file was empty.

## Decision

Reduce the default `AngelscriptTest` module to a loadable shell plus `NewVersion`. Gate legacy headers, engine-pool startup, CQTest force inclusion, and legacy-only dependencies with `WITH_ANGELSCRIPT_UNITTESTS`.

Remove the outer guard from `AngelscriptTestJITProbes.cpp` and classify it as passive generated-ABI support, not an active test. The already-implemented TestJIT module gate ensures it publishes no provider in the reconstruction baseline. Do not rewrite the 74 generated artifacts or hand-maintain duplicate no-op stubs for their registration ABI.

The runtime-owned `AngelscriptRuntime/Testing` implementation is not part of the `AngelscriptTest` UE module and is deeply referenced by retained legacy Runtime code and reflected types. It remains source-compiled but unreachable behind the hard Runtime startup gate; extracting it is a later architecture Change rather than hidden scope growth here.

## Impact

- Ready Task `3.2` now owns the module-shell/build-rule isolation and the link-evidence correction.
- The quarantine audit excludes the TestJIT probe implementation and continues to reject changes to generated artifacts.
- Proposal, design, and testing delta spec define active isolation separately from passive link compatibility.
- No completed task is unchecked; Task `3.1` remains the initial mechanical/audit evidence and Task `3.2` owns the evidence-driven correction.

## Old Task Disposition

The Task `3.1` classification of `AngelscriptTestJITProbes.cpp` as a guard target is superseded. Its remaining 1084 guarded files are preserved. The failed link is retained as RED evidence for Task `3.2`.

## Diff Snapshot

- Affected implementation: `AngelscriptTest.Build.cs`, `AngelscriptTestModule.cpp`, `AngelscriptTestJITProbes.cpp`, quarantine audit.
- Affected planning: proposal, design, testing delta spec, Task `3.2`, attachment index.
- DAG edges: unchanged.

## Preserved Work

Hard Runtime/Editor/JIT/extension dormancy, separate macros, replacement tests, old-source preservation, and fast-headless verification remain unchanged.

## References and Result

- Build RED run `3982bdaac5344c92b3aa382581703c9f`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp`
- `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.cpp`
- `tasks.md`

The updated Task DAG resumes at Task `3.2`.
