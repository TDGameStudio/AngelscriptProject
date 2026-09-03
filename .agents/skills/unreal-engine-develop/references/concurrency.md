# Unreal Concurrency and Progress

Load this reference only when choosing build concurrency, deciding what to do with a busy lane, or interpreting active-process progress.

## Two independent choices

`BuildConcurrency` controls how a typed `ue.build` shares one Engine installation. `ConcurrencyPolicy` controls what the caller does when a required Harness lease is already busy.

| Parameter | Value | Result |
|---|---|---|
| `BuildConcurrency` | `Auto` | Use `Parallel` for an ordinary Installed Engine project build; otherwise use `Serialize`. |
| `BuildConcurrency` | `Parallel` | Request the eligible shared Engine lane across distinct workspace leases. Reject source or unknown engines. |
| `BuildConcurrency` | `Serialize` | Use the exclusive Engine lane and UBT mutex waiting. |
| `ConcurrencyPolicy` | `Auto` | Wait within the operation timeout under the current policy. |
| `ConcurrencyPolicy` | `Wait` | Explicitly wait within the operation timeout. |
| `ConcurrencyPolicy` | `Fail` | Return immediately when a required lease is busy. |

`BuildConcurrency` applies only to the typed `ue.build` route. Generic UBT, target queries, source/unknown-engine builds, and explicitly serialized builds use the exclusive Engine lane.

## Lease model

```text
exact WorkspaceRoot -> exclusive workspace lease
                    -> typed Installed Engine build -> shared Engine lane
                    -> other UBT work               -> exclusive Engine lane
```

The same workspace never runs two UE operations concurrently. Distinct worktrees may overlap only when each operation is eligible for its lane.

For controlled parallel Installed Engine builds, Harness supplies the paired UBT flags `-NoMutex -NoEngineChanges` and isolates run-local temporary and log paths. `-NoMutex` is not inherently unsafe; the safe boundary is the whole owned combination. For serialized UBT work, Harness supplies `-WaitMutex` and coordinates with external UBT processes that use the same assembly mutex. Callers cannot inject `-NoMutex`, `-WaitMutex`, or `-NoEngineChanges` through extra arguments.

Before committing resources, use `PlanOnly` to inspect the selected lane and owned arguments. Use `NoWait` to launch and decide later whether to wait, start eligible work in another workspace, or cancel explicitly. `PlanOnly` and `NoWait` cannot be combined.

## Active processes and progress

`ue.process.list` performs a bounded machine process scan and reports recognizable UE/UBT identity, workspace and Engine matches, elapsed activity, concurrency guards, and progress when evidence is trusted. `ue.run.status -RunId <id>` is authoritative for one managed run, including lease-wait states that have no native process yet.

Progress is known only when Harness can correlate all of the following:

- a valid managed `RunId` carried as the UBT session;
- contained Harness run metadata;
- the matching native process identity; and
- a private run-local log beneath that run directory.

The parser uses the latest bounded `@progress ... N%` or `[current/total] action` record. It never trusts an arbitrary command-line `-Log` path. An external or otherwise uncorrelated UBT process may still expose basic identity, but returns `ProgressKnown = false` rather than an invented percentage.

## Known shared-engine conflict

Installed Engine project outputs are largely workspace-private, but UHT can still contend on a shared Engine-side `UHT/Timestamp`. Harness scans bounded private evidence for that signature. Detection changes an otherwise successful native result to failure and recommends either:

- rerun with `BuildConcurrency = 'Serialize'`; or
- use a dedicated `EngineRoot` for genuinely isolated parallel work.

Do not automatically retry, cancel another process, or change lanes without recording the caller's chosen action.
