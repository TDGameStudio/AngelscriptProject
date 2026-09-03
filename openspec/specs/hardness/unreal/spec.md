# Hardness Unreal Development

## Purpose

This capability provides workspace-safe, PS7-only Unreal Engine discovery, UBT/build/test/commandlet execution, suite planning, concurrency control, and reproducible local run evidence through Hardness.

## Requirements

### Requirement: Hardness-owned Unreal command surface

Hardness SHALL expose Unreal discovery and execution through one `unreal-engine-develop` leaf module using `ue.status`, `ue.engine.list`, `ue.target.list`, `ue.process.list`, `ue.ubt.capabilities`, `ue.ubt.invoke`, `ue.build`, `ue.test`, `ue.suite.list`, `ue.suite.plan`, `ue.suite.run`, `ue.commandlet`, `ue.run.status`, and `ue.run.cancel`. The leaf MUST require PowerShell 7 Core and MUST NOT invoke or depend on root `Tools` PowerShell entry points. Root `Tools` UE wrappers MUST NOT be used as fallback; broad wrapper deletion and live-reference cleanup SHALL remain a separate focused migration rather than a side effect of short-path execution.

#### Scenario: Load one Unreal route
- **WHEN** a caller invokes one `ue.*` command through Hardness
- **THEN** only the Unreal leaf is loaded, the common Hardness result envelope is returned, and unrelated workflow authority is not acquired

#### Scenario: Use a retired root script name
- **WHEN** a caller searches the maintained Unreal Skill for an operational dependency on a root `Tools` PowerShell entry
- **THEN** no such dependency exists and the migration reference identifies root scripts as deletion candidates

#### Scenario: Reject a legacy fallback
- **WHEN** a maintained `ue.*` route is unavailable or fails
- **THEN** the operation reports that failure without invoking a root `Tools` wrapper

### Requirement: Exact workspace execution identity

Every Unreal process launch MUST validate the exact registered physical WorkspaceRoot, Git common directory, managed AgentConfig identity, physical root `.uproject`, optional process-local selection, and caller workspace before writing a request or starting a process. The managed `AgentConfig.ini` and workspace/engine lease keys MUST retain physical paths. On Windows, the leaf SHALL derive a transient short execution view without changing the configured identity; non-Windows execution SHALL use the physical paths directly. Read-only engine enumeration MAY span machine registrations, but an operation MUST use the selected workspace's configuration. One route SHALL perform one fresh workspace status or execution guard and MAY then consume one bounded exact-key configuration projection; it MUST NOT cache the safety decision between routes.

#### Scenario: Reject a main/worktree mismatch
- **WHEN** Hardness is selected for a linked worktree but a build request targets the primary checkout
- **THEN** the request fails before a run directory, mutex, UBT, or editor process is created

#### Scenario: Execute a long registered worktree
- **WHEN** a Windows Unreal operation targets an exact registered workspace whose physical path is long
- **THEN** validation and evidence use the physical workspace while every workspace-local native child path uses the verified transient execution drive

#### Scenario: Reject an identity alias as configuration
- **WHEN** a caller attempts to make a mapped drive the configured WorkspaceRoot or ProjectFile
- **THEN** the exact workspace guard rejects it because the managed configuration must match the Git-registered physical identity

### Requirement: Dynamic engine and UBT discovery

The configured EngineRoot SHALL be authoritative for execution. The leaf SHALL classify installed, source, or unknown layout; resolve UBT and UnrealEditor-Cmd from that root; and discover a compatible engine-bundled `dotnet.exe` without a fixed SDK version. Engine enumeration and UBT capability inspection MUST be read-only and machine-readable.

#### Scenario: Resolve the UE 5.8 bundled host
- **WHEN** an engine contains a supported architecture under `Engine/Binaries/ThirdParty/DotNet`
- **THEN** the leaf selects an existing bundled `dotnet.exe`, reports its source and version directory, and does not mutate the parent process environment

### Requirement: Planned and bounded execution

Build, test, commandlet, generic UBT, and suite requests SHALL accept an explicit or configured positive timeout. Every request SHALL support a no-launch plan that returns normalized executable, argument array, working directory, physical workspace/output paths, execution workspace/output paths, assignment/mapping state, engine, and concurrency decision. `PlanOnly` MUST NOT create or change a DOS mapping, assignment registry, run directory, or external process. Native execution MUST preserve argument boundaries through `ProcessStartInfo.ArgumentList`.

#### Scenario: Inspect a build without launching
- **WHEN** a caller invokes `ue.build` with PlanOnly
- **THEN** the returned plan contains the exact target/configuration/project and selected UBT guards while no external process or run state is created

#### Scenario: Propose an execution path without mutation
- **WHEN** a caller invokes an Unreal route with PlanOnly and the workspace has no assignment
- **THEN** the plan reports a `Proposed` drive and mapped child arguments while the drive, registry, and run directory remain absent

### Requirement: Per-run lifecycle and evidence

Real operations SHALL use stable Request and Run schema names in a unique physical directory under `Saved/Hardness/Unreal/Runs/<run-id>` with `Request.json`, `RunMetadata.json`, and `Command.log`, plus operation-specific reports. Records MUST distinguish physical identity/paths from execution identity/paths. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingExecutionDrive`, optional `WaitingEngine`, `Running`, and one terminal state from `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`; status MAY report `Orphaned` when a non-terminal recorded process no longer exists. The worker SHALL acquire workspace, drive, and optional engine leases in that order, create and validate the mapping only after those leases, and release mapping and leases in reverse order. Cancellation and timeout MUST remove only an exact Hardness-owned mapping. A synchronous call SHALL wait for its worker, while NoWait SHALL return the run identity for later status or explicit cancellation.

#### Scenario: Time out a process
- **WHEN** a native child exceeds the request's total timeout
- **THEN** the worker stops the child tree, records `TimedOut`, preserves bounded evidence, releases every lease, and returns a non-zero result

#### Scenario: Cancel an asynchronous run
- **WHEN** the user explicitly cancels a contained run whose recorded worker identity still matches
- **THEN** descendants and the worker are stopped, state becomes `Cancelled`, and no unrelated process is targeted

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

`ue.process.list` SHALL identify active UBT and editor processes machine-wide and correlate mapped UBT project arguments back to the physical Request workspace. It SHALL report recognizable engine, physical and execution project identity, target, configuration, and concurrency identity. `ue.run.status` SHALL return a bounded structured progress snapshot for a recognized Hardness build by reading only its physical contained run evidence. Progress SHALL include whether it is known, completed and total actions when available, percentage, current action or phase, evidence path, and observation time. A session, native PID, schema, project, mapping, or containment mismatch MUST remain unrecognized, and missing or uncorrelated evidence MUST report unknown progress rather than inventing a value.

#### Scenario: Inspect builds from multiple worktrees
- **WHEN** a caller lists Unreal processes while two recognized project builds are active
- **THEN** both builds are returned independently with their workspace identities and each available progress snapshot

#### Scenario: Inspect a mapped worktree build
- **WHEN** an active UBT command line contains a mapped `-Project` and a valid Hardness session
- **THEN** process discovery returns the physical WorkspaceRoot and ProjectFile together with ExecutionPath and uses only that physical run's bounded progress evidence

### Requirement: Managed multi-worktree concurrency

One operation SHALL hold one workspace lease for its whole lifetime. Auto and Wait SHALL wait within the total deadline, while Fail SHALL reject an occupied workspace. The leaf MUST NOT provide same-workspace execution slots. Ordinary installed-engine project builds SHALL support a Hardness-owned controlled parallel lane across distinct workspaces using `-NoMutex -NoEngineChanges`, isolated temp/log paths, and a shared engine lane. Build mode `Auto` SHALL select that lane for eligible installed-project builds; `Parallel` SHALL request it explicitly; `Serialize` SHALL request the exclusive lane. Source/unknown-engine builds, QueryTargets, and generic UBT SHALL use the exclusive engine lane keyed by canonical EngineRoot and `-WaitMutex`. Raw mutex/engine-guard arguments MUST remain reserved to the policy layer without classifying `-NoMutex` as inherently unsafe. Non-UBT tests and commandlets MAY overlap only across distinct workspaces, and distinct EngineRoots MAY execute independently. The selected mode, policy, guards, and reasons MUST be recorded. A detected shared-engine UHT timestamp conflict MUST fail the build even when the native exit code is zero.

#### Scenario: Build two installed-engine worktrees
- **WHEN** two distinct registered worktrees issue ordinary project-target builds against one installed engine without output overrides
- **THEN** each keeps its own workspace lease, both may occupy the shared engine lane concurrently, and Hardness supplies `-NoMutex -NoEngineChanges` plus isolated logs and temp paths

#### Scenario: Use a source engine
- **WHEN** a request targets a source or unknown engine layout
- **THEN** the plan serializes by exact EngineRoot and uses UBT WaitMutex semantics

#### Scenario: Request a raw mutex override
- **WHEN** a caller passes `-NoMutex`, `-WaitMutex`, or `-NoEngineChanges` through extra arguments
- **THEN** the planner rejects the ownership conflict and directs the caller to the typed build-mode option

### Requirement: Unreal build and UBT operations

`ue.build` SHALL normalize target, platform, configuration, and architecture from explicit input or workspace configuration and SHALL prohibit UniqueBuildEnvironment. `ue.build` and vetted `ue.ubt.invoke` requests SHALL pass mapped workspace-local project, output, log, and temporary paths to UBT while retaining physical EngineRoot and executable paths. Default UBA and XGE behavior MUST remain unchanged unless the caller uses an already supported explicit option. `ue.ubt.invoke` SHALL support deliberate argument arrays but MUST classify generic, QueryTargets, clean-like, and engine-write-capable requests conservatively; destructive clean mode is outside this Change. `ue.target.list` SHALL provide a fast source scan and an explicit serialized UBT query path.

#### Scenario: Reject unsafe build isolation
- **WHEN** a caller supplies `-UniqueBuildEnvironment` directly or through extra arguments
- **THEN** the plan fails before process launch and recommends an explicit engine/workspace isolation strategy

#### Scenario: Preserve the default executor during real launch
- **WHEN** cutover acceptance attempts to build the configured workspace without an explicit executor override after isolated long-path coverage passes
- **THEN** UBT launches through the mapped execution view without Hardness adding `-NoUBA` or `-NoXGE`, independently of later product compilation success or failure

### Requirement: Unreal Automation and commandlet operations

`ue.test` SHALL support exact prefixes or defined groups, default to NullRHI, isolate crash-only tests, write a UE report directory, and parse structured Automation truth locally. `ue.commandlet` SHALL require one commandlet name and preserve each extra argument boundary. A zero process exit with missing or failing structured test evidence SHALL fail unless report enforcement was explicitly disabled.

#### Scenario: Run a crash-only prefix
- **WHEN** a requested prefix contains only `Angelscript.CrashOnly`
- **THEN** the plan adds the explicit crash-only enable flag and does not combine it with ordinary tests

### Requirement: Declarative suite planning

Suite and launch-profile definitions SHALL be tracked non-executable JSON. `ue.suite.list` SHALL identify available Unreal-only suites, `ue.suite.plan` SHALL return stable ordered entries and resource policy without launching UE, and `ue.suite.run` SHALL execute those entries sequentially within one workspace lease. Package, Standalone, Cache-package, StaticJIT, coverage, and release pipelines MUST NOT be silently represented as completed by this capability.

#### Scenario: Plan the All suite
- **WHEN** a caller plans the `All` suite
- **THEN** the result lists each Unreal Automation entry once in stable order and clearly excludes deferred non-Unreal pipelines
