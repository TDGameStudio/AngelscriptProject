## MODIFIED Requirements

### Requirement: Planned and bounded execution

Build, test, commandlet, generic UBT, and suite requests SHALL accept an explicit or configured positive timeout. Every request SHALL support a no-launch plan that returns normalized executable, argument array, working directory, physical workspace/output paths, execution workspace/output paths, assignment/mapping state, engine, and concurrency decision. `PlanOnly` MUST NOT create or change a DOS mapping, assignment registry, run directory, or external process. Native execution MUST preserve argument boundaries through `ProcessStartInfo.ArgumentList`.

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

Real operations SHALL use stable Request and Run schema names in a unique physical directory under `Saved/Harness/Unreal/Runs/<run-id>` with `Request.json`, `RunMetadata.json`, and `Command.log`, plus operation-specific reports. Records MUST distinguish physical identity/paths from execution identity/paths. State transitions SHALL use `Queued`, `WaitingWorkspace`, `WaitingExecutionDrive`, optional `WaitingEngine`, `Running`, and one terminal state from `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`; status MAY report `Orphaned` when a non-terminal recorded process no longer exists. The worker SHALL acquire workspace, drive, and optional engine leases in that order, create and validate the mapping only after those leases, and release mapping and leases in reverse order. Cancellation and timeout MUST remove only an exact Harness-owned mapping. A synchronous call SHALL wait for its worker, while NoWait SHALL return the run identity for later status or explicit cancellation.

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

### Requirement: Active build discovery and progress

`ue.process.list` SHALL identify active UBT and editor processes machine-wide and correlate mapped UBT project arguments back to the physical Request workspace. It SHALL report recognizable engine, physical and execution project identity, target, configuration, and concurrency identity. `ue.run.status` SHALL return a bounded structured progress snapshot for a recognized Harness build by reading only its physical contained run evidence. Progress SHALL include whether it is known, completed and total actions when available, percentage, current action or phase, evidence path, and observation time. A session, native PID, schema, project, mapping, or containment mismatch MUST remain unrecognized, and missing or uncorrelated evidence MUST report unknown progress rather than inventing a value.

#### Scenario: Inspect a mapped worktree build
- **GIVEN** contained `Request.json` and `RunMetadata.json` identify the physical workspace and matching native PID for the supplied Harness session
- **WHEN** an active UBT command line contains a mapped `-Project` and a valid Harness session
- **THEN** process discovery returns the physical WorkspaceRoot and ProjectFile together with ExecutionPath and uses only that physical run's bounded progress evidence
- **AND** recognized output reports trusted target, configuration, build concurrency, current action counts, and the contained evidence path
- **BUT** an invalid session, mismatched native PID, or arbitrary command-line `-Log` path cannot make the process recognized or supply trusted progress

> Inputs: Machine process identity and command line, mapped project argument, Harness session ID, and the physical contained run records.
>
> Observables: `RecognizedBuild`, physical and execution identities, target/configuration/concurrency fields, and `ProgressKnown` with its bounded source.
>
> Boundaries: Uncorrelated processes may expose basic machine facts, but their progress remains unknown rather than inferred from untrusted logs.
>
> Verification: The `ConcurrencyProgress` fixture in `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1` correlates a mapped project and valid session to contained metadata, rejects wrong PID and invalid session variants, and proves an external `-Log` cannot override run-local progress.

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

### Requirement: Harness Unreal API and registry migration

The Unreal development module SHALL expose Harness-named PowerShell symbols and use `%LOCALAPPDATA%/TDGameStudio/Harness/Unreal/DriveAssignments.json` as the only current drive-assignment registry. `PlanOnly` operations MUST NOT create, move, or rewrite either current or legacy registry data. Before the first real registry-dependent Unreal operation, the module SHALL migrate a lone legacy `%LOCALAPPDATA%/TDGameStudio/Hardness/Unreal/DriveAssignments.json` under the normal registry lock. It MUST preserve the file contents and fail without overwrite when old and new registries conflict.

The current registry filename SHALL remain the stable unsuffixed `DriveAssignments.json`; implementation or record schema revisions MUST NOT leak into `v1` or `v2` filenames.

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
