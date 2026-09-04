## MODIFIED Requirements

### Requirement: Harness-owned Unreal command surface

Harness SHALL expose Unreal discovery and execution through one `unreal-engine-develop` leaf module using `ue.status`, `ue.engine.list`, `ue.target.list`, `ue.process.list`, `ue.ubt.capabilities`, `ue.ubt.invoke`, `ue.build`, `ue.test`, `ue.suite.list`, `ue.suite.plan`, `ue.suite.run`, `ue.commandlet`, `ue.run.status`, and `ue.run.cancel`. The leaf MUST require PowerShell 7 Core and MUST NOT invoke or depend on root `Tools` PowerShell entry points. Root `Tools` UE wrappers MUST NOT be used as fallback; broad wrapper deletion and live-reference cleanup SHALL remain a separate focused migration rather than a side effect of short-path execution. Synchronous Unreal execution routes MUST expose a truthful common envelope: a terminal failed operation fails the envelope while preserving its operation data, artifacts, and non-zero exit code. Asynchronous dispatch and successful observation or cancellation commands remain successful envelopes independently of the state they queue, observe, or produce.

#### Scenario: Load one Unreal route
- **WHEN** a caller invokes one `ue.*` command through Harness
  > Inputs: The selected workspace context and the named public route bound the authority of the call.
- **THEN** only the Unreal leaf is loaded, the common Harness result envelope is returned, and unrelated workflow authority is not acquired
  > Observables: The envelope identifies the invoked route, status, exit code, data, and artifacts without loading unrelated lifecycle policy.

#### Scenario: Report a synchronous Unreal operation failure
- **WHEN** `ue.build`, `ue.ubt.invoke`, `ue.test`, `ue.commandlet`, or `ue.suite.run` synchronously returns `Failed`, `TimedOut`, `Cancelled`, or `Orphaned`
  > Inputs: A completed synchronous operation supplies its terminal state, operation exit code, retained data, and artifacts.
- **THEN** the common envelope reports `Failed`, preserves the operation's non-zero exit code when present, and retains the returned data and artifacts
  > Observables: Callers can see both transport-level failure and the operation evidence needed for diagnosis.
- **BUT** a non-terminal `NoWait` dispatch, a successful `ue.run.status` observation, or a successful `ue.run.cancel` command is not reclassified from the state described by its data
  > Boundaries: Command success and the observed or queued run state remain distinct contracts.

### Requirement: Unreal build and UBT operations

`ue.build` SHALL normalize target, platform, configuration, and architecture from explicit input or workspace configuration and SHALL prohibit UniqueBuildEnvironment. `ue.build` and vetted `ue.ubt.invoke` requests SHALL pass mapped workspace-local project, output, log, and temporary paths to UBT while retaining physical EngineRoot and executable paths. Top-level Harness UBT requests MUST NOT pass UE's recursive-invocation `-Session` option. Configured UBA and XGE behavior MUST remain unchanged unless the caller uses an already supported explicit option; Harness MUST NOT force XGE or manipulate action thresholds as an ownership workaround. `ue.ubt.invoke` SHALL support deliberate argument arrays but MUST classify generic, QueryTargets, clean-like, and engine-write-capable requests conservatively; destructive clean mode is outside this Change. `ue.target.list` SHALL provide a fast source scan and an explicit serialized UBT query path.

#### Scenario: Launch a top-level Harness build
- **WHEN** Harness plans or launches a typed `ue.build` or vetted generic UBT `build`
  > Inputs: Normalized target identity, workspace-local mapped paths, and configured executor policy form the native plan.
- **THEN** the UBT argument array contains one contained run-local `-Log` path and no `-Session`
  > Observables: The native arguments expose exactly one owned log destination and no recursive-session marker.
- **AND** configured UBA/XGE selection remains available without a forced executor or caller action-threshold workaround
  > Boundaries: Harness preserves supported executor configuration and does not invent capacity policy.

#### Scenario: Reject a caller executor override
- **WHEN** a caller supplies raw `-NoUBA` or `-NoXGE` through extra UBT arguments
  > Inputs: Raw extra arguments attempt to override executor policy outside the maintained typed surface.
- **THEN** the planner rejects the policy ownership conflict and directs the caller to the maintained typed route behavior
  > Observables: No native UBT process is launched from the rejected plan.

  Examples of rejected raw overrides:

  - `-NoUBA`
  - `-NoXGE`

### Requirement: Active build discovery and progress

`ue.process.list` SHALL identify active UBT and editor processes machine-wide and correlate mapped UBT project arguments back to the physical Request workspace. It SHALL report recognizable engine, physical and execution project identity, target, configuration, and concurrency identity. `ue.run.status` SHALL return a bounded structured progress snapshot for a recognized Harness build by reading only its physical contained run evidence. Progress SHALL include whether it is known, completed and total actions when available, percentage, current action or phase, evidence path, and observation time. A contained log identity, native PID, schema, project, mapping, request argument, or path mismatch MUST remain unrecognized, and missing or uncorrelated evidence MUST report unknown progress rather than inventing a value.

#### Scenario: Inspect a mapped worktree build
- **GIVEN** contained `Request.json` and `RunMetadata.json` identify the physical workspace and matching native PID for the run ID embedded in the owned UBT log path
  > Context: Correlation begins from physical Harness evidence even when the child process uses a transient mapped execution view.
- **WHEN** an active UBT command line contains a mapped `-Project` and the exact contained `-Log` path
  > Inputs: Machine process identity and command line, mapped project argument, contained run-local log path, and the physical contained run records.
- **THEN** process discovery returns the physical WorkspaceRoot and ProjectFile together with ExecutionPath and uses only that physical run's bounded progress evidence
  > Observables: `RecognizedBuild`, physical and execution identities, target/configuration/concurrency fields, and `ProgressKnown` with its bounded source.
- **AND** recognized output reports trusted target, configuration, build concurrency, current action counts, and the contained evidence path
  > Verification: The `ConcurrencyProgress` fixture correlates an exact contained log and mapped project to matching metadata and proves progress comes only from physical run evidence.
- **BUT** a malformed or external log path, mismatched native PID, or mismatched request argument cannot make the process recognized or supply trusted progress
  > Boundaries: Uncorrelated processes may expose basic machine facts, but their progress remains unknown rather than inferred from untrusted logs.
