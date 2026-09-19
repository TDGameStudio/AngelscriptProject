---
name: unreal-engine-develop
description: Use after project Skills are enabled when Unreal Engine 5.8 targets, Automation tests, suites, commandlets, UBT capabilities, active processes, run progress, or cancellation must be handled through Harness in an exact AngelscriptProject workspace.
---

# Unreal Engine Develop

- This leaf provides the PowerShell 7 Unreal surface behind Harness.
- Enter through `Invoke-Harness`; do not call UE executables, private module functions, Skill-local scripts, or legacy root `Tools` wrappers directly.

- Project Skills are enabled by `AGENTS.md`; this leaf still acquires only the authority of the exact selected Harness route and workspace.

## Start once

- Keep one PowerShell 7 process, import Harness once, and bind one exact workspace context.
- The ordinary route dispatch stays in the caller process; a real UE operation starts a bounded Harness-managed worker only after planning and validation:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command workspace.activate -Context $context
Invoke-Harness -Command ue.status -Context $context
```

- The selected workspace must have a Harness-managed `AgentConfig.ini` with `Paths.EngineRoot`, a workspace-owned `Paths.ProjectFile`, and a matching process-local activation.
- Repair it with `workspace.bootstrap`; never reuse another worktree's project path.

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

- Use `Get-HarnessCommand <route>` for live route metadata and its owning entrypoint. Use this leaf and its focused references for typed parameters; the registry does not return parameter schemas.

## Plan, launch, observe

Inspect a deterministic plan without launching UE:

```powershell
$plan = Invoke-Harness -Command ue.build -Context $context -Parameters @{
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    PlanOnly = $true
}
```

Launch asynchronously, keep the returned `RunId`, and query the same selected workspace:

```powershell
$run = Invoke-Harness -Command ue.build -Context $context -Parameters @{
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    NoWait = $true
    TimeoutMs = 900000
}

Invoke-Harness -Command ue.run.status -Context $context -Parameters @{ RunId = $run.Data.RunId }
Invoke-Harness -Command ue.process.list -Context $context
```

Cancellation is a separate explicit action and retains PowerShell confirmation semantics:

```powershell
Invoke-Harness -Command ue.run.cancel -Context $context -Parameters @{ RunId = $run.Data.RunId }
```

- `PlanOnly` and `NoWait` are mutually exclusive.
- Synchronous invocation waits for the terminal result.
- Asynchronous states include `Queued`, `WaitingWorkspace`, `WaitingEngine`, `WaitingExternalBuild`, `Running`, `Succeeded`, `Failed`, `TimedOut`, `Cancelled`, and effective `Orphaned` detection. `WaitingExternalBuild` means a same-workspace external UBT process is delaying admission; it does not claim a trusted build percentage.

- Read [concurrency.md](references/concurrency.md) before overriding either concurrency axis or interpreting process progress.

## Test and suite selection

Run exactly one Automation prefix or configured group:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.TestModule.Bindings.'
    TimeoutMs = 600000
}

Invoke-Harness -Command ue.test -Context $context -Parameters @{
    Group = 'AngelscriptSmoke'
    NoWait = $true
    TimeoutMs = 600000
}
```

- Tests are headless by default.
- `Render` selects the render profile; `Fast` selects the reduced headless profile, and the two cannot be combined.
- Automation report validation is required unless `NoReport` is explicitly selected.
- Crash-only tests must use an exact `Angelscript.CrashOnly...` selection and run alone.

- The tracked suite catalog contains `Smoke`, `NativeCore`, `RuntimeCpp`, `Bindings`, `HotReload`, `Cache`, `Debugger`, `FunctionalSamples`, and `All`.
- `All` is UE Automation only.
- Query `ue.suite.list`, inspect `ue.suite.plan`, then use `ue.suite.run`; suite entries execute sequentially under one workspace lease.

- Standalone, package, coverage, release, CachePackage, and full StaticJIT pipelines are not silently mapped to a root `Tools` fallback.
- See [migration.md](references/migration.md) for the exact deferred boundary.

## Execution rules

- PowerShell 7.0 or later (`Core`) is the only supported host; there is no Windows PowerShell 5.1 path.
- Every executable operation requires a positive bounded timeout.
  - The maximum accepted timeout is one hour.
- Harness owns workspace identity, engine selection, leases, UBT concurrency flags, private logs, temporary directories, report paths, and run metadata.
  - Reserved raw arguments that would override those fields are rejected.
- Harness-managed execution in the same workspace is always exclusive. UBT admission also checks observed external same-project builds; this is not an atomic lock shared with an IDE that starts after the check.
  - Eligible ordinary Installed Engine project builds may run concurrently across distinct worktrees; source/unknown engines and conservative UBT operations serialize.
- A zero UE process exit is not sufficient when an enforced Automation report is missing, malformed, empty, incomplete, or failing.
- A detected shared-engine UHT `Timestamp` contention is promoted to failure with serialize-or-isolate guidance, even if the native process returned zero.
- Managed artifacts live under ignored `Saved/Harness/Unreal/Runs/<RunId>/`.
  - Do not share logs or temporary paths between workspaces.

- Legacy entrypoint mappings and removed files are documented in [migration.md](references/migration.md).
