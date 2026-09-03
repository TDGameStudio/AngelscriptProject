## Context

Hardness currently validates a physical workspace exactly and launches UBT or UnrealEditor with that same path. On Windows this exposes long linked-worktree paths to UBT, generated response files, toolchain intermediates, Automation reports, and child temporary directories. UE's managed path wrappers normalize lexically with `Path.GetFullPath`; they do not automatically replace the path with an extended-length physical identity.

## Goals

- Keep security, Git registration, configuration, locks, status, and evidence anchored to the physical workspace.
- Give all Unreal child processes a short, stable workspace view without asking users to manage drive letters.
- Make ownership and cleanup race-safe, bounded, observable, and conservative around pre-existing mappings.
- Preserve existing public route names and caller parameters.

## Non-goals

- Do not move or rename registered worktrees.
- Do not add an alias to `AgentConfig.ini`, map EngineRoot, or use a junction as canonical identity.
- Do not disable UBA or XGE to manufacture a passing result.
- Do not repair unrelated plugin or generated-code compilation failures discovered by the real build attempt.
- Do not delete root Tools wrappers before the replacement passes its real UE gates.
- Do not migrate content from `Documents/` during the project-wide documentation refactor.

## Decision 1: Split physical identity from execution identity

The stable Request schema retains physical `workspaceRoot`, `projectFile`, `paths`, and `physicalWorkingDirectory`. Its `execution` object records `strategy`, assignment key, drive, mapped workspace/project, physical workspace/project, raw DOS target, assignment state, and mapping state. `executionPaths` mirrors every workspace-local run path. Run metadata copies both identities while all Hardness reads and writes remain physical.

```text
Git / AgentConfig / leases / evidence
        physical D:\...\.worktrees\...
                     |
                     | exact contained projection
                     v
UBT / Editor / TEMP / reports
        transient R:\...
```

Non-Windows hosts use `Direct`. Windows hosts use `DosDevice`, including the primary checkout, so path behavior is consistent across workspace topology.

## Decision 2: Stable machine-local allocation with no PlanOnly writes

The assignment key is SHA-256 of the canonical Git common directory plus physical workspace root. The stable registry schema is bounded to 256 unique key/drive records and is written atomically beneath LocalAppData under a named registry mutex. Allocation examines `Z:` down through `G:`, skips live registered assignments and occupied devices, reuses an exact existing target, and reallocates a stable letter when it is occupied by a different target.

`PlanOnly` may read the registry and query DOS devices. It never writes the registry, creates a mapping, reserves an owner, or creates a run directory. A new candidate is `Proposed`; a retained record is `Assigned`.

## Decision 3: Native DOS-device ownership and file-identity validation

The private Windows layer uses `QueryDosDeviceW` and `DefineDosDeviceW`. Creation uses raw-target/no-broadcast flags. Removal additionally uses exact-match/remove flags and the exact stored raw target. A matching mapping that is not marked Hardness-owned is `Foreign`, is reused, and is never removed. A Hardness intent record is persisted before creating a new mapping so abrupt cancellation can still identify and clean it.

Before launch, the physical and mapped `.uproject` are opened and compared by volume serial and file index. A wrong target or identity mismatch fails before the native child starts.

## Decision 4: Lease order and lifecycle

The worker acquires resources in this order:

```text
workspace lease -> drive lease -> optional engine lane -> mapping -> native child
```

It releases them in reverse order. The state machine adds `WaitingExecutionDrive` between `WaitingWorkspace` and `WaitingEngine`/`Running`. Cancellation kills the recorded worker tree, removes only an exactly owned mapping, clears its owner record, and then writes `Cancelled`. Abandoned owned records are recognized as stale and reclaimed by a later real assignment.

## Decision 5: Map only workspace-local child surfaces

The mapped projection covers project and workspace working directories, UBT project/output/log/session-adjacent paths, editor ABSLOG/report paths, `TEMP`, `TMP`, `UnrealBuildTool_TMP`, and suite entry paths. Executables, UBT DLLs, bundled dotnet, and EngineRoot stay physical. The existing UBA/XGE selection is unchanged and remains part of real acceptance.

## Decision 6: Keep destructive cleanup separate

This focused Change proves the replacement with isolated long-path contract tests, one real default-executor build attempt, and one successful real Smoke run from the configured workspace. The build attempt must prove mapped-path launch and preserve default executor behavior, but a demonstrated product compilation error is recorded for later work and does not block the path/startup acceptance requested by the user. This Change does not bundle broad root Tools deletion, consumer-reference cleanup, or unrelated migration work. A later focused cleanup may remove those files only after confirming their replacement owners; it must not weaken the executor or use the old wrappers as fallback.
