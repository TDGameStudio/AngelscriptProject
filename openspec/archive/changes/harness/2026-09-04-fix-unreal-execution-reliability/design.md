## Context

Harness appends `-Session=<RunId>` to UBT so machine-wide process discovery can correlate a native command line with contained run metadata and progress. In UE 5.8, any `-Session` suppresses the global UBA trace, but low-action executor selection can still choose UBA and then reject the invocation as recursive. Removing the session would fix executor initialization by weakening ownership and observation guarantees.

Unreal execution leaf functions intentionally return a managed terminal status object. That is useful data, but the generic dispatcher currently interprets every non-throwing PowerShell call as a successful operation. Observation routes also return objects whose `State` describes another operation, so state propagation cannot apply indiscriminately to every `ue.*` result.

## Goals / Non-Goals

**Goals:**

- Make typed and vetted generic UBT builds reliable for small action sets without caller threshold workarounds.
- Preserve Session-based correlation, XGE availability, local fallback, and Harness concurrency ownership.
- Make the common envelope truthful for synchronous build, UBT, test, commandlet, and suite execution.
- Preserve native data and artifact paths when the outer envelope reports failure.

**Non-Goals:**

- Redesign UE 5.8 UBA, remove Session correlation, or provide a caller-owned raw executor override.
- Reclassify asynchronous queueing, status observation, or cancellation-command success.
- Change route names, parameters, run schemas, aggregate profiles, or product behavior.

## Decisions

### Top-level UBT requests do not impersonate recursive sessions

Harness removes `-Session` from every top-level UBT request. The run ID remains in the owned execution `-Log` path. Process discovery accepts a build only after extracting a syntactically valid run ID from that exact contained path and matching the mapped project, native PID, Request/metadata schemas and identities, operation, execution mapping, normalized arguments, and physical run paths. An arbitrary external log, malformed run path, stale PID, or mismatched record stays unrecognized.

This keeps the ownership proof without triggering UE's explicit recursive-invocation behavior. `-NoUBA` was investigated and rejected: UE 5.8's `ExecutorFactory` still falls back to `GetUBAExecutor()` when no remote executor is selected, while `bAllowUBAExecutor=false` only disables detouring on that fallback. It therefore still reaches the trace-dependent initialization and cannot repair a Session-tagged low-action build. Forcing XGE and changing `MaxParallelActions` were also rejected because XGE may be unavailable or capacity-limited and action thresholds are unrelated to ownership.

### Executor availability is observed, not promised by Harness

The local machine has Incredibuild/XGE 10.32.2, a running Agent, active Fixed Initiator licensing, 24 floating helper cores, and the licensed Multiple Builds feature. UE 5.8 also contains its bundled UBA binaries, while the project UBT XML sets `bAllowUBAExecutor=false`. These signals establish installation and current service/license health, not guaranteed launch capacity.

Incredibuild concurrent initiations depend on edition, the Multiple Builds setting, licensed cores, minimum cores per build, and current executions. UE's XGE availability check can optionally treat an in-use initiator as unavailable, but the default is not to do so; an XGE launch can wait behind another build. Harness therefore preserves UBT/XGE policy and reports actual run evidence instead of forcing XGE or claiming capacity from executable discovery alone.

### Only execution-route terminal data controls the outer envelope

The dispatcher recognizes terminal failure states only for `ue.build`, `ue.ubt.invoke`, `ue.test`, `ue.commandlet`, and `ue.suite.run`. `Failed`, `TimedOut`, `Cancelled`, and `Orphaned` become an outer `Failed`; a non-zero returned exit code is preserved, otherwise the envelope uses `1`. Returned data and `Artifacts` remain attached, and the error code identifies an Unreal terminal-operation failure.

Non-terminal asynchronous states remain successful dispatch results. `ue.run.status` may successfully observe a failed run, and `ue.run.cancel` may successfully return a cancelled run; neither result is reclassified because the command itself succeeded.

## Risks / Trade-offs

- Removing the recursive Session marker changes active-process correlation. The replacement remains fail-closed through contained log identity and exact native PID/request validation, with negative fixtures for forged paths and mismatches.
- The dispatcher contains a route allowlist because a generic `State` convention would conflate operation outcome with observation outcome. Focused route tests protect the list and its negative boundaries.
- A real editor build is still required because fixture plans prove argument ownership but cannot prove UE 5.8 executor initialization.
