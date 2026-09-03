---
replan_id: replan-20260903-182347-serialize-same-engine-ubt
status: applied
source: external-agent
source_ref: "Read-only local UE 5.8 UBT audit during Task 1.1"
scope: same-EngineRoot UBT concurrency, child temp/log isolation, and installed-build guards
base_commit: 3c8de4611ba7e3dcfa91b766aeb358db4ed54982
base_tasks_sha256: 616eaabc2adc165e2a5c668f4771fdbe21e382fd532e4a495da2d67496564116
result_tasks_sha256: 89182fb71ce3049b99cad51a4165b3361881917fbdc9a82d9bfba96027ce2e6a
created_at: 2026-09-03T18:23:47+08:00
resume_task: "1.1"
---

# Serialize Same-Engine UBT Work

## Trigger and Evidence

The initial design allowed an installed-engine project build to overlap across distinct worktrees with `-NoMutex -NoEngineChanges`. A read-only audit of the configured UE 5.8 source invalidated that safety assumption:

- UBT's main mutex is keyed by the executing UBT assembly, not by project or workspace. `-NoMutex` bypasses it and takes precedence over `-WaitMutex`.
- UBT normally redirects TMP/TEMP to a directory derived from the UBT DLL, so same-engine processes share it unless a child-only override is supplied.
- Installed builds still use shared user-level C++ dependency and file-hash caches whose writers do not merge cross-process state.
- Installed UBT defaults to a shared user log location unless each invocation supplies its own log.
- `-NoEngineChanges` rejects modification of existing engine produced files but explicitly permits new engine-side files.
- `Build.bat` adds another engine-wide lock loop, so guarded execution must call bundled `dotnet.exe` and UBT directly.

These are shared mutable resources outside the two worktree roots. Distinct project directories alone therefore do not prove a safe UBT parallel lane.

## Decision

Every build, QueryTargets request, and generic UBT invocation uses a Hardness engine lease keyed by canonical EngineRoot and passes `-WaitMutex`. Installed project builds additionally pass `-NoEngineChanges` as a defense, never as permission for `-NoMutex`. Each run receives child-only temp paths and an explicit UBT log.

Non-UBT Editor tests and commandlets may overlap across distinct workspaces because their project and run outputs are isolated; same-workspace operations remain serialized. Distinct EngineRoots use distinct engine leases. No public override can force same-engine UBT parallelism in this Change.

## Impact

- Update proposal, design, the new `hardness/unreal` delta, and task implementation detail before code is written.
- Keep the public `Auto | Wait | Fail` lease behavior, but interpret Auto as safe waiting for every same-engine UBT request.
- Remove the planned installed-build `-NoMutex` test case and replace it with installed/source serialized cases plus installed-only `-NoEngineChanges`.
- Preserve all other scope, route, state, suite, report, PS7, and workspace decisions.

## Diff Snapshot

```text
Task ~: 2.1 now requires serialization for every same-engine UBT path
Task ~: 3.1 verifies installed/source serialization and installed-only NoEngineChanges
Edge +/-: none; the Task DAG and ready node remain unchanged
Artifact +: this Replan
Artifact ~: proposal.md, design.md, specs/hardness/unreal/spec.md, tasks.md
Implementation: none existed when the evidence arrived
```

## References and Result

- Initial Task DAG SHA-256: `616eaabc2adc165e2a5c668f4771fdbe21e382fd532e4a495da2d67496564116`.
- Result Task DAG SHA-256: `89182fb71ce3049b99cad51a4165b3361881917fbdc9a82d9bfba96027ce2e6a`.
- Resume at Task `1.1`; no completed task was reopened and no Review was created.
