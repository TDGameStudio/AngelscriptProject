## Purpose

This capability provides workspace-safe, PS7-only Unreal Engine discovery, UBT/build/test/commandlet execution, suite planning, concurrency control, and reproducible local run evidence through Hardness.

## ADDED Requirements

### Requirement: Hardness-owned Unreal command surface

Hardness SHALL expose Unreal discovery and execution through one `unreal-engine-develop` leaf module using `ue.status`, `ue.engine.list`, `ue.target.list`, `ue.process.list`, `ue.ubt.capabilities`, `ue.ubt.invoke`, `ue.build`, `ue.test`, `ue.suite.list`, `ue.suite.plan`, `ue.suite.run`, `ue.commandlet`, `ue.run.status`, and `ue.run.cancel`. The leaf MUST require PowerShell 7 Core and MUST NOT invoke or depend on root `Tools` PowerShell entry points.

#### Scenario: Load one Unreal route
- **WHEN** a caller invokes one `ue.*` command through Hardness
- **THEN** only the Unreal leaf is loaded, the common Hardness result envelope is returned, and unrelated workflow authority is not acquired

#### Scenario: Use a retired root script name
- **WHEN** a caller searches the maintained Unreal Skill for an operational dependency on a root `Tools` PowerShell entry
- **THEN** no such dependency exists and the migration reference identifies root scripts as deletion candidates

### Requirement: Exact workspace execution identity

Every Unreal process launch MUST validate the exact registered WorkspaceRoot, Git common directory, managed AgentConfig identity, root `.uproject`, optional process-local selection, and caller workspace before writing a request or starting a process. Read-only engine enumeration MAY span machine registrations, but an operation MUST use the selected workspace's configuration. One route SHALL perform one fresh workspace status or execution guard and MAY then consume one bounded exact-key configuration projection; it MUST NOT cache the safety decision between routes.

#### Scenario: Reject a main/worktree mismatch
- **WHEN** Hardness is selected for a linked worktree but a build request targets the primary checkout
- **THEN** the request fails before a run directory, mutex, UBT, or editor process is created

### Requirement: Dynamic engine and UBT discovery

The configured EngineRoot SHALL be authoritative for execution. The leaf SHALL classify installed, source, or unknown layout; resolve UBT and UnrealEditor-Cmd from that root; and discover a compatible engine-bundled `dotnet.exe` without a fixed SDK version. Engine enumeration and UBT capability inspection MUST be read-only and machine-readable.

#### Scenario: Resolve the UE 5.8 bundled host
- **WHEN** an engine contains a supported architecture under `Engine/Binaries/ThirdParty/DotNet`
- **THEN** the leaf selects an existing bundled `dotnet.exe`, reports its source and version directory, and does not mutate the parent process environment

### Requirement: Planned and bounded execution

Build, test, commandlet, generic UBT, and suite requests SHALL accept an explicit or configured positive timeout. Every request SHALL support a no-launch plan that returns normalized executable, argument array, working directory, workspace, engine, output paths, and concurrency decision. Native execution MUST preserve argument boundaries through `ProcessStartInfo.ArgumentList`.

#### Scenario: Inspect a build without launching
- **WHEN** a caller invokes `ue.build` with PlanOnly
- **THEN** the returned plan contains the exact target/configuration/project and selected UBT guards while no external process or run state is created

### Requirement: Per-run lifecycle and evidence

Real operations SHALL use a unique contained directory under `Saved/Hardness/Unreal/Runs/<run-id>` with `Request.json`, `RunMetadata.json`, and `Command.log`, plus operation-specific reports. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingEngine`, `Running`, and one terminal state from `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`; status MAY report `Orphaned` when a non-terminal recorded process no longer exists. A synchronous call SHALL wait for its worker, while NoWait SHALL return the run identity for later status or explicit cancellation.

#### Scenario: Time out a process
- **WHEN** a native child exceeds the request's total timeout
- **THEN** the worker stops the child tree, records `TimedOut`, preserves bounded evidence, releases every lease, and returns a non-zero result

#### Scenario: Cancel an asynchronous run
- **WHEN** the user explicitly cancels a contained run whose recorded worker identity still matches
- **THEN** descendants and the worker are stopped, state becomes `Cancelled`, and no unrelated process is targeted

### Requirement: Active build discovery and progress

`ue.process.list` SHALL identify active UBT and editor processes machine-wide with recognizable engine, workspace, target, configuration, and concurrency identity. `ue.run.status` SHALL return a bounded structured progress snapshot for a recognized Hardness build by reading only its contained run logs. Progress SHALL include whether it is known, completed and total actions when available, percentage, current action or phase, evidence path, and observation time. Missing or uncorrelated evidence MUST report unknown progress rather than inventing a value.

#### Scenario: Inspect builds from multiple worktrees
- **WHEN** a caller lists Unreal processes while two recognized project builds are active
- **THEN** both builds are returned independently with their workspace identities and each available progress snapshot

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

`ue.build` SHALL normalize target, platform, configuration, and architecture from explicit input or workspace configuration and SHALL prohibit UniqueBuildEnvironment. `ue.ubt.invoke` SHALL support deliberate argument arrays but MUST classify generic, QueryTargets, clean-like, and engine-write-capable requests conservatively; destructive clean mode is outside this Change. `ue.target.list` SHALL provide a fast source scan and an explicit serialized UBT query path.

#### Scenario: Reject unsafe build isolation
- **WHEN** a caller supplies `-UniqueBuildEnvironment` directly or through extra arguments
- **THEN** the plan fails before process launch and recommends an explicit engine/workspace isolation strategy

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
