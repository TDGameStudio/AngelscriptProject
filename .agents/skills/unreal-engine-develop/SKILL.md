---
name: unreal-engine-develop
description: Use after project Skills are enabled when Unreal Engine 5.8 targets, Automation tests, suites, commandlets, UBT capabilities, active processes, run progress, or cancellation must be handled through Hardness in an exact AngelscriptProject workspace.
---

# Unreal Engine Develop

This leaf provides the PowerShell 7 Unreal surface behind Hardness. Enter through `Invoke-Hardness`; do not call UE executables, private module functions, Skill-local scripts, or legacy root `Tools` wrappers directly.

The restriction at the top of `AGENTS.md` remains authoritative. This prepared Skill does not enable itself during the project-wide refactor.

## Start once

Keep one PowerShell 7 process, import Hardness once, and bind one exact workspace context:

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1
$context = New-HardnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Hardness -Command workspace.activate -Context $context
Invoke-Hardness -Command ue.status -Context $context
```

The selected workspace must have a Hardness-managed `AgentConfig.ini` with `Paths.EngineRoot`, a workspace-owned `Paths.ProjectFile`, and a matching process-local activation. Repair it with `workspace.bootstrap`; never reuse another worktree's project path.

## Route map

| Need | Route |
|---|---|
| Workspace and configured UE readiness | `ue.status` |
| Registered/configured engines | `ue.engine.list` |
| Project targets | `ue.target.list` |
| Relevant machine UE/UBT processes and trusted progress | `ue.process.list` |
| Supported generic UBT capabilities | `ue.ubt.capabilities` |
| Invoke an allowed generic UBT capability | `ue.ubt.invoke` |
| Build a typed project target | `ue.build` |
| Run an exact Automation prefix or configured group | `ue.test` |
| Run a commandlet | `ue.commandlet` |
| List, plan, or run declarative UE suites | `ue.suite.list`, `ue.suite.plan`, `ue.suite.run` |
| Inspect or explicitly cancel a managed run | `ue.run.status`, `ue.run.cancel` |

Use `Get-HardnessCommand <route>` for the live parameter contract.

## Plan, launch, observe

Inspect a deterministic plan without launching UE:

```powershell
$plan = Invoke-Hardness -Command ue.build -Context $context -Parameters @{
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    PlanOnly = $true
}
```

Launch asynchronously, keep the returned `RunId`, and query the same selected workspace:

```powershell
$run = Invoke-Hardness -Command ue.build -Context $context -Parameters @{
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    NoWait = $true
    TimeoutMs = 900000
}

Invoke-Hardness -Command ue.run.status -Context $context -Parameters @{ RunId = $run.Data.RunId }
Invoke-Hardness -Command ue.process.list -Context $context
```

Cancellation is a separate explicit action and retains PowerShell confirmation semantics:

```powershell
Invoke-Hardness -Command ue.run.cancel -Context $context -Parameters @{ RunId = $run.Data.RunId }
```

`PlanOnly` and `NoWait` are mutually exclusive. Synchronous invocation waits for the terminal result. Asynchronous states include `Queued`, `WaitingWorkspace`, `WaitingEngine`, `Running`, `Succeeded`, `Failed`, `TimedOut`, `Cancelled`, and effective `Orphaned` detection.

Read [concurrency.md](references/concurrency.md) before overriding either concurrency axis or interpreting process progress.

## Test and suite selection

Run exactly one Automation prefix or configured group:

```powershell
Invoke-Hardness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.TestModule.Bindings.'
    TimeoutMs = 600000
}

Invoke-Hardness -Command ue.test -Context $context -Parameters @{
    Group = 'AngelscriptSmoke'
    NoWait = $true
    TimeoutMs = 600000
}
```

Tests are headless by default. `Render` selects the render profile; `Fast` selects the reduced headless profile, and the two cannot be combined. Automation report validation is required unless `NoReport` is explicitly selected. Crash-only tests must use an exact `Angelscript.CrashOnly...` selection and run alone.

The tracked suite catalog contains `Smoke`, `NativeCore`, `RuntimeCpp`, `Bindings`, `HotReload`, `Cache`, `Debugger`, `FunctionalSamples`, and `All`. `All` is UE Automation only. Query `ue.suite.list`, inspect `ue.suite.plan`, then use `ue.suite.run`; suite entries execute sequentially under one workspace lease.

Standalone, package, coverage, release, CachePackage, and full StaticJIT pipelines are not silently mapped to a root `Tools` fallback. See [migration.md](references/migration.md) for the exact deferred boundary.

## Execution rules

- PowerShell 7.0 or later (`Core`) is the only supported host; there is no Windows PowerShell 5.1 path.
- Every executable operation requires a positive bounded timeout. The maximum accepted timeout is one hour.
- Hardness owns workspace identity, engine selection, leases, UBT concurrency flags, private logs, temporary directories, report paths, and run metadata. Reserved raw arguments that would override those fields are rejected.
- Same-workspace execution is always exclusive. Eligible ordinary Installed Engine project builds may run concurrently across distinct worktrees; source/unknown engines and conservative UBT operations serialize.
- A zero UE process exit is not sufficient when an enforced Automation report is missing, malformed, empty, incomplete, or failing.
- A detected shared-engine UHT `Timestamp` contention is promoted to failure with serialize-or-isolate guidance, even if the native process returned zero.
- Managed artifacts live under ignored `Saved/Hardness/Unreal/Runs/<RunId>/`. Do not share logs or temporary paths between workspaces.

Legacy entrypoint mappings and removed files are documented in [migration.md](references/migration.md).
