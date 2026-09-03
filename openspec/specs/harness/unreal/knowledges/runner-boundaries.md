# Unreal Runner Ownership and Evidence

## Ownership chain

Keep each fact in one layer:

```text
Harness context
  -> exact WorkspaceRoot
  -> workspace-lifecycle identity and live execution guard
  -> unreal-engine-develop typed plan and concurrency decision
  -> contained worker, leases, and native process
  -> run-local logs, reports, status, and progress
```

Harness selects and wraps. Workspace lifecycle validates Git and `AgentConfig.ini`. The Unreal leaf owns engine discovery, planning, leases, process lifetime, reports, and evidence. Root `Tools` PowerShell files are not a runtime fallback.

## Configuration projection

Each public Unreal route starts with one fresh workspace status or execution guard. A trusted leaf may then batch only its exact required keys through workspace lifecycle. Do not cache identity, configuration bytes, authorization, or mutation preconditions between routes.

## Concurrency boundary

Every operation owns its exact workspace lease. Eligible Installed Engine project builds may share the same Engine lane across distinct workspaces with Harness-owned `-NoMutex -NoEngineChanges` and isolated temporary/log paths. Source or unknown engines, QueryTargets, generic UBT, and explicit `Serialize` work use the exclusive Engine lane and `-WaitMutex`.

Treat `-NoEngineChanges` as defense in depth, not proof of complete Engine immutability. A shared-Engine UHT `Timestamp` conflict fails the run and directs the next attempt to `Serialize` or a dedicated `EngineRoot`.

## Evidence boundary

Request identity is immutable; mutable run state is atomic and bounded. Progress is trusted only when a valid session, contained request/metadata, matching native PID, and run-local evidence correlate. Otherwise report unknown progress. Never follow an arbitrary command-line log path or scan historical `Saved` trees to guess run ownership.
