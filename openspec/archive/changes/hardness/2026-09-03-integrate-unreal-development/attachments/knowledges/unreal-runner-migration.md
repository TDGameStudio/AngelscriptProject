---
record_id: unreal-runner-migration
status: accepted
source: ue58-ubt-evidence
created_at: 2026-09-03T18:26:00+08:00
supports_task: "1.1"
promotion: promoted
promoted_to: hardness/unreal/runner-boundaries
---

# Unreal Runner Migration Boundary

## Stable boundary

Hardness owns selection and common result wrapping; `workspace-lifecycle` owns Git/AgentConfig identity; `unreal-engine-develop` owns engine discovery, command planning, leases, process lifetime, reports, and run evidence. None of these layers copies another layer's parser or configuration store.

```text
Hardness context
  -> exact WorkspaceRoot
  -> workspace execution guard
  -> Unreal typed plan
  -> contained worker + leases
  -> native process
  -> run-local evidence
```

Root Tools PowerShell files are migration inputs and deletion candidates, not runtime dependencies. A feature that has not moved into the Unreal leaf remains explicitly unavailable; it never silently crosses back to Tools.

## Concurrency invariant

One top-level operation owns one whole-workspace lease. Ordinary installed-engine project builds may share a Hardness engine lane across distinct workspaces with the policy-owned `-NoMutex -NoEngineChanges` pair, run-local temp/log paths, and post-run UHT timestamp contention detection. Source/unknown builds, QueryTargets, generic UBT, and explicit `Serialize` requests own the exclusive engine lane and retain UBT `-WaitMutex`. Different EngineRoots progress independently.

`-NoEngineChanges` is defense-in-depth rather than proof of complete engine immutability. The parallel lane preserves deliberate multi-worktree throughput; uncertain or engine-writing work flips to serialization or a dedicated EngineRoot.

## Evidence invariant

Request identity is immutable. Mutable state is atomic and bounded. Logs, UBT output, Automation reports, and summaries belong to the exact run directory; no coordinator recursively searches historical `Saved` trees to guess which run completed.

## Progressive loading

Normal Hardness status and Codex hooks check only leaf/config readiness. Registry enumeration, process inventory, target QueryTargets, suite definitions, and historical run bodies load only for their explicit route. This keeps the common path fast while preserving deep diagnostics on demand.
