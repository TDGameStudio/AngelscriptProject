## MODIFIED Requirements

### Requirement: Exact workspace execution identity

Every Unreal process launch MUST validate the exact registered physical WorkspaceRoot, Git common directory, managed AgentConfig identity, physical root `.uproject`, optional process-local selection, and caller workspace before writing a request or starting a process. The managed `AgentConfig.ini` and workspace/engine lease keys MUST retain physical paths. On Windows, the leaf SHALL derive a transient short execution view without changing the configured identity; non-Windows execution SHALL use the physical paths directly.

#### Scenario: Execute a long registered worktree
- **WHEN** a Windows Unreal operation targets an exact registered workspace whose physical path is long
- **THEN** validation and evidence use the physical workspace while every workspace-local native child path uses the verified transient execution drive

#### Scenario: Reject an identity alias as configuration
- **WHEN** a caller attempts to make a mapped drive the configured WorkspaceRoot or ProjectFile
- **THEN** the exact workspace guard rejects it because the managed configuration must match the Git-registered physical identity

### Requirement: Planned and bounded execution

Build, test, commandlet, generic UBT, and suite requests SHALL accept an explicit or configured positive timeout. Every request SHALL support a no-launch plan that returns normalized executable, argument array, working directory, physical workspace/output paths, execution workspace/output paths, assignment/mapping state, engine, and concurrency decision. `PlanOnly` MUST NOT create or change a DOS mapping, assignment registry, run directory, or external process. Native execution MUST preserve argument boundaries through `ProcessStartInfo.ArgumentList`.

#### Scenario: Propose an execution path without mutation
- **WHEN** a caller invokes an Unreal route with PlanOnly and the workspace has no assignment
- **THEN** the plan reports a `Proposed` drive and mapped child arguments while the drive, registry, and run directory remain absent

### Requirement: Per-run lifecycle and evidence

Real operations SHALL use stable Request and Run schema names in a unique physical directory under `Saved/Hardness/Unreal/Runs/<run-id>`. Records MUST distinguish physical identity/paths from execution identity/paths. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingExecutionDrive`, optional `WaitingEngine`, `Running`, and one terminal state. The worker SHALL acquire workspace, drive, and optional engine leases in that order, create/validate the mapping only after those leases, and release mapping and leases in reverse order. Cancellation and timeout MUST remove only an exact Hardness-owned mapping.

#### Scenario: Preserve a foreign matching mapping
- **WHEN** the selected drive already maps to the exact physical workspace but the assignment registry does not mark it Hardness-owned
- **THEN** the worker validates and reuses it as `Foreign` and leaves it present after the run

#### Scenario: Recover an abandoned owned mapping
- **WHEN** a prior owner is no longer live and its exact Hardness-owned mapping remains
- **THEN** a later real assignment identifies it as stale, removes or adopts it under the registry/drive leases, and never removes a different target

#### Scenario: Complete a real Smoke run through the execution view
- **WHEN** the configured `AngelscriptSmoke` group is launched through `ue.test` on Windows
- **THEN** Unreal initializes and the run reaches `Succeeded` using mapped child paths, while terminal cleanup returns the owned mapping to `Absent`

### Requirement: Active build discovery and progress

`ue.process.list` SHALL correlate mapped UBT project arguments back to the physical Request workspace, report both physical and execution project identity, and read progress only from the physical contained run evidence. A session, native PID, schema, project, mapping, or containment mismatch MUST remain unrecognized.

#### Scenario: Inspect a mapped worktree build
- **WHEN** an active UBT command line contains a mapped `-Project` and a valid Hardness session
- **THEN** process discovery returns the physical WorkspaceRoot and ProjectFile together with ExecutionPath and uses only that physical run's bounded progress evidence

### Requirement: Unreal build and UBT operations

`ue.build` and vetted `ue.ubt.invoke` requests SHALL pass mapped workspace-local project, output, log, and temporary paths to UBT while retaining physical EngineRoot/executable paths. Default UBA and XGE behavior MUST remain unchanged unless the caller uses an already supported explicit option.

#### Scenario: Preserve the default executor during real launch
- **WHEN** cutover acceptance attempts to build the configured workspace without an explicit executor override after isolated long-path coverage passes
- **THEN** UBT launches through the mapped execution view without Hardness adding `-NoUBA` or `-NoXGE`, independently of later product compilation success or failure

### Requirement: Hardness-owned Unreal command surface

Hardness SHALL remain the sole maintained UE build/test/commandlet/suite entry surface. Root `Tools` UE wrappers MUST NOT be used as fallback. Broad wrapper deletion and live-reference cleanup SHALL remain a separate focused migration rather than a side effect of the short-path repair.

#### Scenario: Reject a legacy fallback
- **WHEN** a maintained `ue.*` route is unavailable or fails
- **THEN** the operation reports that failure without invoking a root `Tools` wrapper
