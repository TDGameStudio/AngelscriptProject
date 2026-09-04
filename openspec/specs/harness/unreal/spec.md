# Harness Unreal Development

## Purpose

This capability provides workspace-safe, PS7-only Unreal Engine discovery, UBT/build/test/commandlet execution, suite planning, concurrency control, and reproducible local run evidence through Harness.

## Requirements

### Requirement: Harness-owned Unreal command surface

Harness SHALL expose Unreal discovery and execution through one `unreal-engine-develop` leaf module using `ue.status`, `ue.engine.list`, `ue.target.list`, `ue.process.list`, `ue.ubt.capabilities`, `ue.ubt.invoke`, `ue.build`, `ue.test`, `ue.suite.list`, `ue.suite.plan`, `ue.suite.run`, `ue.commandlet`, `ue.run.status`, and `ue.run.cancel`. The leaf MUST require PowerShell 7 Core and MUST NOT invoke or depend on root `Tools` PowerShell entry points. Root `Tools` UE wrappers MUST NOT be used as fallback; broad wrapper deletion and live-reference cleanup SHALL remain a separate focused migration rather than a side effect of short-path execution. Synchronous Unreal execution routes MUST expose a truthful common envelope: a terminal failed operation fails the envelope while preserving its operation data, artifacts, and non-zero exit code. Asynchronous dispatch and successful observation or cancellation commands remain successful envelopes independently of the state they queue, observe, or produce.

#### Scenario: Load one Unreal route
- **WHEN** a caller invokes one `ue.*` command through Harness
- **THEN** only the Unreal leaf is loaded, the common Harness result envelope is returned, and unrelated workflow authority is not acquired

#### Scenario: Use a retired root script name
- **WHEN** a caller searches the maintained Unreal Skill for an operational dependency on a root `Tools` PowerShell entry
- **THEN** no such dependency exists and the migration reference identifies root scripts as deletion candidates

#### Scenario: Reject a legacy fallback
- **WHEN** a maintained `ue.*` route is unavailable or fails
- **THEN** the operation reports that failure without invoking a root `Tools` wrapper

#### Scenario: Report a synchronous Unreal operation failure
- **WHEN** `ue.build`, `ue.ubt.invoke`, `ue.test`, `ue.commandlet`, or `ue.suite.run` synchronously returns `Failed`, `TimedOut`, `Cancelled`, or `Orphaned`
- **THEN** the common envelope reports `Failed`, preserves the operation's non-zero exit code when present, and retains the returned data and artifacts
- **BUT** a non-terminal `NoWait` dispatch, a successful `ue.run.status` observation, or a successful `ue.run.cancel` command is not reclassified from the state described by its data

### Requirement: Exact workspace execution identity

Every Unreal process launch MUST validate the exact registered physical WorkspaceRoot, Git common directory, managed AgentConfig identity, physical root `.uproject`, optional process-local selection, and caller workspace before writing a request or starting a process. The managed `AgentConfig.ini` and workspace/engine lease keys MUST retain physical paths. On Windows, the leaf SHALL derive a transient short execution view without changing the configured identity; non-Windows execution SHALL use the physical paths directly. Read-only engine enumeration MAY span machine registrations, but an operation MUST use the selected workspace's configuration. One route SHALL perform one fresh workspace status or execution guard and MAY then consume one bounded exact-key configuration projection; it MUST NOT cache the safety decision between routes.

#### Scenario: Reject a main/worktree mismatch
- **WHEN** Harness is selected for a linked worktree but a build request targets the primary checkout
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
- **GIVEN** an exact registered and configured Windows workspace has no active execution-drive assignment
- **WHEN** a caller invokes an Unreal route with PlanOnly and the workspace has no assignment
- **THEN** the plan reports a `Proposed` drive and mapped child arguments while the drive, registry, and run directory remain absent
- **AND** the normalized plan exposes both physical and proposed execution paths, owned arguments, engine identity, and the selected concurrency decision
- **BUT** planning creates no mapping, assignment, run evidence, external process, or parent-process environment mutation

> Context: A proposed drive is a deterministic execution view for inspection; it is not a reservation or ownership claim.
>
> Inputs: The exact selected `WorkspaceRoot`, typed Unreal route arguments, and `PlanOnly = true`.
>
> Observables: `AssignmentState = Proposed`, physical and execution paths, normalized argument order, absence of the run directory and DOS mapping, and unchanged environment and registry state.
>
> Boundaries: If a lone legacy registry exists, planning leaves it byte-for-byte in place; migration remains a first-real-operation concern.
>
> Verification: The `Discovery` and `Build` fixtures in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` verify the proposed drive, mapped arguments, absent mapping/run directory/current registry, unchanged legacy bytes, and unchanged parent environment.

### Requirement: Per-run lifecycle and evidence

Real operations SHALL use stable Request and Run schema names in a unique physical directory under `Saved/Harness/Unreal/Runs/<run-id>` with `Request.json`, `RunMetadata.json`, and `Command.log`, plus operation-specific reports. Build, generic UBT, test, and commandlet requests SHALL accept an optional semantic display label, derive the existing route-specific default when it is omitted or blank, and expose the effective label in plans, status, and recognized process observations. Labels MUST be bounded and free of control characters. Records MUST distinguish physical identity/paths from execution identity/paths. The label MUST NOT participate in RunId generation, filesystem paths, process correlation, locks, executor arguments, or ownership decisions. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingExecutionDrive`, optional `WaitingEngine`, `Running`, and one terminal state from `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`; status MAY report `Orphaned` when a non-terminal recorded process no longer exists. The worker SHALL acquire workspace, drive, and optional engine leases in that order, create and validate the mapping only after those leases, and release mapping and leases in reverse order. Cancellation and timeout MUST remove only an exact Harness-owned mapping. A synchronous call SHALL wait for its worker, while NoWait SHALL return the run identity for later status or explicit cancellation.

#### Scenario: Time out a process
- **WHEN** a native child exceeds the request's total timeout
  > Inputs: The total timeout covers queueing, lease waits, and native execution rather than restarting for each phase.
- **THEN** the worker stops the child tree, records `TimedOut`, preserves bounded evidence, releases every lease, and returns a non-zero result
  > Details:

  1. The contained native process tree is no longer live before the run is reported terminal.
  2. `RunMetadata.json` and bounded command evidence identify the timeout and final `TimedOut` state.
  3. Only an ownership-verified execution mapping is removed, and all acquired leases become available again.

#### Scenario: Cancel an asynchronous run
- **GIVEN** a `NoWait` run has reached `Running` and its contained metadata records matching live worker and native-process identities
- **WHEN** the user explicitly cancels a contained run whose recorded worker identity still matches
- **THEN** descendants and the worker are stopped, state becomes `Cancelled`, and no unrelated process is targeted
- **AND** the terminal result is non-zero and releases the run's exact workspace, drive, and applicable engine ownership
- **BUT** a live PID that does not match the contained run identity is refused rather than terminated

> Inputs: The exact selected workspace, the returned `RunId`, and an explicit `ue.run.cancel` action.
>
> Observables: Pre-cancel `Running` status, terminal `Cancelled` metadata, worker/native PID absence, released leases, and mapping cleanup subject to ownership.
>
> Boundaries: Cancellation targets one contained Harness run; it is not a machine-wide process-kill or an inferred cleanup of orphaned foreign processes.
>
> Verification: The `RunLifecycle` fixture in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` launches a bounded asynchronous native process, cancels it, verifies both PIDs exit and the workspace lease is reacquirable, and rejects an unrelated live PID.

#### Scenario: Preserve a foreign matching mapping
- **GIVEN** a third party created a DOS mapping to the exact physical workspace and the Harness assignment registry contains no ownership claim for it
- **WHEN** the selected drive already maps to the exact physical workspace but the assignment registry does not mark it Harness-owned
- **THEN** the worker validates and reuses it as `Foreign` and leaves it present after the run
- **AND** terminal metadata records `MappingState = Foreign` so reuse never becomes an implicit ownership transfer
- **BUT** Harness cleanup does not remove or rewrite the matching foreign mapping

> Inputs: The selected execution drive, its raw DOS target, and the exact physical workspace identity.
>
> Observables: Successful execution, `Foreign` mapping state in terminal metadata, and the same mapping still present after worker completion.
>
> Boundaries: Exact physical-target equality is required; a drive pointing elsewhere is not reusable and must be preserved while another free drive is selected.
>
> Verification: The foreign-mapping fixture in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` creates a matching external mapping, runs through it, verifies explicit foreign state, and proves terminal cleanup leaves it present.

#### Scenario: Recover an abandoned owned mapping
- **GIVEN** the registry marks an exact workspace mapping as Harness-owned but the recorded owner run and process are no longer live
- **WHEN** a prior owner is no longer live and its exact Harness-owned mapping remains
- **THEN** a later real assignment identifies it as stale, removes or adopts it under the registry/drive leases, and never removes a different target
- **AND** `PlanOnly` can report `StaleOwned` without mutation, while the later real run completes and leaves no abandoned owned mapping behind
- **BUT** a mismatched or foreign target is preserved instead of being treated as stale Harness ownership

> Inputs: The assignment key, owned drive and raw target, dead owner identity, and exact selected workspace.
>
> Observables: Non-mutating `StaleOwned` planning state, successful real execution, updated ownership evidence, and an absent owned mapping after terminal cleanup.
>
> Boundaries: Recovery occurs only while holding the normal registry and drive leases and only after liveness and exact-target checks.
>
> Verification: The stale-owned fixture in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` injects a dead owner record, observes `StaleOwned` during planning, executes a recovery run, and proves the exact owned mapping is removed afterward.

#### Scenario: Complete a real Smoke run through the execution view
- **WHEN** the configured `AngelscriptSmoke` group is launched through `ue.test` on Windows
- **THEN** Unreal initializes and the run reaches `Succeeded` using mapped child paths, while terminal cleanup returns the owned mapping to `Absent`

#### Scenario: Label one Unreal operation

- **WHEN** a caller supplies a valid `Label` to `ue.build`, `ue.ubt.invoke`, `ue.test`, or `ue.commandlet`
  > Inputs: A display label containing at most 128 UTF-16 code units, no control characters, and any route-specific execution inputs.
- **THEN** the effective trimmed label is returned by PlanOnly, stored in the run request, and returned by `ue.run.status`
  > Observables: `Label` has one identical value in the plan, `Request.json`, new run metadata, and the status projection.
- **AND** a recognized managed build returned by `ue.process.list` reports the same label
  > Verification: The focused RunLabels fixture exercises all four public routes and a contained recognized-build process view.
- **BUT** changing the label does not change the generated RunId, run directory, lease identity, native argument array, or process-correlation evidence
  > Boundaries: Labels are repeatable display metadata rather than identity or authority.

#### Scenario: Derive a default run label

- **WHEN** a caller omits `Label` or supplies only whitespace to a single-operation Unreal route
  > Inputs: The normalized build target, UBT capability, test prefix or group, or commandlet name that already identifies the operation.
- **THEN** the route derives its existing stable label from the build target, UBT capability, test selection, or commandlet name and exposes it through the same observation surfaces
  > Observables: Callers receive a non-empty effective label without having to provide new input, preserving current route behavior.

#### Scenario: Reject an unsafe run label

- **WHEN** a caller supplies a label longer than the supported bound or containing a control character
  > Inputs: A label longer than 128 UTF-16 code units or containing characters such as a newline, carriage return, tab, or NUL.
- **THEN** planning fails before a run directory, mapping, lease, or native process is created
  > Observables: The diagnostic identifies the label boundary and the workspace run root remains unchanged.

### Requirement: Active build discovery and progress

`ue.process.list` SHALL identify active UBT and editor processes machine-wide and correlate mapped UBT project arguments back to the physical Request workspace. It SHALL report recognizable engine, physical and execution project identity, target, configuration, and concurrency identity. `ue.run.status` SHALL return a bounded structured progress snapshot for a recognized Harness build by reading only its physical contained run evidence. Progress SHALL include whether it is known, completed and total actions when available, percentage, current action or phase, evidence path, and observation time. A contained log identity, native PID, schema, project, mapping, request argument, or path mismatch MUST remain unrecognized, and missing or uncorrelated evidence MUST report unknown progress rather than inventing a value.

#### Scenario: Inspect builds from multiple worktrees
- **WHEN** a caller lists Unreal processes while two recognized project builds are active
- **THEN** both builds are returned independently with their workspace identities and each available progress snapshot

#### Scenario: Inspect a mapped worktree build
- **GIVEN** contained `Request.json` and `RunMetadata.json` identify the physical workspace and matching native PID for the run ID embedded in the owned UBT log path
- **WHEN** an active UBT command line contains a mapped `-Project` and the exact contained `-Log` path
- **THEN** process discovery returns the physical WorkspaceRoot and ProjectFile together with ExecutionPath and uses only that physical run's bounded progress evidence
- **AND** recognized output reports trusted target, configuration, build concurrency, current action counts, and the contained evidence path
- **BUT** a malformed or external log path, mismatched native PID, or mismatched request argument cannot make the process recognized or supply trusted progress

> Inputs: Machine process identity and command line, mapped project argument, contained run-local log path, and the physical contained run records.
>
> Observables: `RecognizedBuild`, physical and execution identities, target/configuration/concurrency fields, and `ProgressKnown` with its bounded source.
>
> Boundaries: Uncorrelated processes may expose basic machine facts, but their progress remains unknown rather than inferred from untrusted logs.
>
> Verification: The `ConcurrencyProgress` fixture correlates an exact contained log and mapped project to matching metadata, rejects wrong PID and external-log variants, and proves progress comes only from physical run evidence.

### Requirement: Managed multi-worktree concurrency

One operation SHALL hold one workspace lease for its whole lifetime. Auto and Wait SHALL wait within the total deadline, while Fail SHALL reject an occupied workspace. The leaf MUST NOT provide same-workspace execution slots. Ordinary installed-engine project builds SHALL support a Harness-owned controlled parallel lane across distinct workspaces using `-NoMutex -NoEngineChanges`, isolated temp/log paths, and a shared engine lane. Build mode `Auto` SHALL select that lane for eligible installed-project builds; `Parallel` SHALL request it explicitly; `Serialize` SHALL request the exclusive lane. Source/unknown-engine builds, QueryTargets, and generic UBT SHALL use the exclusive engine lane keyed by canonical EngineRoot and `-WaitMutex`. Raw mutex/engine-guard arguments MUST remain reserved to the policy layer without classifying `-NoMutex` as inherently unsafe. Non-UBT tests and commandlets MAY overlap only across distinct workspaces, and distinct EngineRoots MAY execute independently. The selected mode, policy, guards, and reasons MUST be recorded. A detected shared-engine UHT timestamp conflict MUST fail the build even when the native exit code is zero.

#### Scenario: Build two installed-engine worktrees
- **GIVEN** two exact, distinct registered workspaces each request an eligible ordinary typed project build against the same canonical installed EngineRoot
- **WHEN** two distinct registered worktrees issue ordinary project-target builds against one installed engine without output overrides
- **THEN** each keeps its own workspace lease, both may occupy the shared engine lane concurrently, and Harness supplies `-NoMutex -NoEngineChanges` plus isolated logs and temp paths
- **AND** planning records `ParallelInstalledProjectBuild`, the shared engine lane, owned UBT guards, and run-local execution paths
- **BUT** the same workspace remains exclusive, while source/unknown-engine builds and generic UBT work remain on the exclusive engine lane

> Inputs: Two distinct physical `WorkspaceRoot` identities, one installed `EngineRoot`, typed build requests, and no caller-owned output or mutex overrides.
>
> Observables: Per-request workspace identity, `BuildConcurrency = Parallel`, `EngineLane = Shared`, exact UBT arguments, and isolated temporary/log paths.
>
> Boundaries: Current automated acceptance is fixture-level evidence for policy selection, shared-lane overlap, argument ownership, and path isolation. It does **not** claim that two real UBT/Unreal builds were executed concurrently end to end.
>
> Verification: The `ConcurrencyProgress` fixtures in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` verify the parallel plan and owned arguments, allow two shared lane holders to overlap while an exclusive holder waits, and validate run-local temp/log routing without launching two real UBT builds.

#### Scenario: Use a source engine
- **WHEN** a request targets a source or unknown engine layout
- **THEN** the plan serializes by exact EngineRoot and uses UBT WaitMutex semantics

#### Scenario: Request a raw mutex override
- **WHEN** a caller passes `-NoMutex`, `-WaitMutex`, or `-NoEngineChanges` through extra arguments
- **THEN** the planner rejects the ownership conflict and directs the caller to the typed build-mode option

### Requirement: Unreal build and UBT operations

`ue.build` SHALL normalize target, platform, configuration, and architecture from explicit input or workspace configuration and SHALL prohibit UniqueBuildEnvironment. `ue.build` and vetted `ue.ubt.invoke` requests SHALL pass mapped workspace-local project, output, log, and temporary paths to UBT while retaining physical EngineRoot and executable paths. Top-level Harness UBT requests MUST NOT pass UE's recursive-invocation `-Session` option. Configured UBA and XGE behavior MUST remain unchanged unless the caller uses an already supported explicit option; Harness MUST NOT force XGE or manipulate action thresholds as an ownership workaround. `ue.ubt.invoke` SHALL support deliberate argument arrays but MUST classify generic, QueryTargets, clean-like, and engine-write-capable requests conservatively; destructive clean mode is outside this Change. `ue.target.list` SHALL provide a fast source scan and an explicit serialized UBT query path.

#### Scenario: Reject unsafe build isolation
- **WHEN** a caller supplies `-UniqueBuildEnvironment` directly or through extra arguments
- **THEN** the plan fails before process launch and recommends an explicit engine/workspace isolation strategy

#### Scenario: Preserve the default executor during real launch
- **WHEN** cutover acceptance attempts to build the configured workspace without an explicit executor override after isolated long-path coverage passes
- **THEN** UBT launches through the mapped execution view without Harness adding `-NoUBA` or `-NoXGE`, independently of later product compilation success or failure

#### Scenario: Launch a top-level Harness build
- **WHEN** Harness plans or launches a typed `ue.build` or vetted generic UBT `build`
- **THEN** the UBT argument array contains one contained run-local `-Log` path and no `-Session`
- **AND** configured UBA/XGE selection remains available without a forced executor or caller action-threshold workaround

#### Scenario: Reject a caller executor override
- **WHEN** a caller supplies raw `-NoUBA` or `-NoXGE` through extra UBT arguments
- **THEN** the planner rejects the policy ownership conflict and directs the caller to the maintained typed route behavior

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

### Requirement: Harness Unreal API and registry migration

The Unreal development module SHALL expose Harness-named PowerShell symbols and use `%LOCALAPPDATA%/TDGameStudio/Harness/Unreal/DriveAssignments.json` as the only current drive-assignment registry. `PlanOnly` operations MUST NOT create, move, or rewrite either current or legacy registry data. Before the first real registry-dependent Unreal operation, the module SHALL migrate a lone legacy `%LOCALAPPDATA%/TDGameStudio/Hardness/Unreal/DriveAssignments.json` under the normal registry lock. It MUST preserve the file contents and fail without overwrite when old and new registries conflict.

The current registry filename SHALL remain the stable unsuffixed `DriveAssignments.json`; implementation or record schema revisions MUST NOT leak into `v1` or `v2` filenames.

#### Scenario: Keep planning side-effect free
- **WHEN** an Unreal route runs with `PlanOnly`
- **THEN** neither the legacy nor current LocalAppData registry is moved, created, or rewritten

#### Scenario: Migrate a lone legacy registry
- **WHEN** the first real Unreal operation finds only the legacy Hardness registry
- **THEN** it moves the preserved registry to the Harness root under lock before using it

#### Scenario: Refuse a registry conflict
- **GIVEN** both unsuffixed legacy Hardness and current Harness drive-assignment registries exist before a real registry-dependent operation
- **WHEN** both legacy and current registries exist with conflicting state
- **THEN** the real operation fails with both paths and does not overwrite or merge either file
- **AND** both registry byte sequences remain identical to their pre-operation values
- **BUT** no migration, schema rewrite, assignment, or mapping proceeds after the conflict is detected

> Context: Conflicting registries require an explicit human reconciliation decision; neither file has implicit precedence.
>
> Inputs: The exact legacy and current registry paths and their pre-operation payload bytes.
>
> Observables: A failure naming both paths, unchanged byte hashes for both files, and no resulting assignment or drive mutation.
>
> Boundaries: Conflict handling belongs to the first real registry-dependent operation; `PlanOnly` remains side-effect free and does not perform migration.
>
> Verification: The `Discovery` fixture in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` creates both registries, observes a fail-closed migration attempt, and compares both files byte-for-byte after failure.

#### Scenario: Keep the registry name stable
- **WHEN** registry payload or implementation schema revisions advance
- **THEN** the machine-local file remains `DriveAssignments.json` without a version suffix
