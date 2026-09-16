# Host prefix baseline (2026-09-16)

User asked to run TArray / basic-type tests and inspect bind logs before replanning.

## Command

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.Bindings.Host'
    Fast = $true
    TimeoutMs = 600000
}
```

## Result

| Field | Value |
|---|---|
| RunId | `c359689768d04f8abb85ad11f0918f37` |
| State | Succeeded |
| Process exit | 0 |
| DurationMs | 25624 |
| Total / Succeeded / Failed / NotRun | 30 / 30 / 0 / 0 |
| Report | `Saved/Harness/Unreal/Runs/c359689768d04f8abb85ad11f0918f37/AutomationReport/index.json` |
| Unreal.log | `Saved/Harness/Unreal/Runs/c359689768d04f8abb85ad11f0918f37/Unreal.log` |

Named basic-type cases that ran: `HostContainers.ContainersBoundBehavior`, `HostCore.CoreBoundBehavior`, `HostMath.MathBoundBehavior`.

## Log facts kept

From Unreal.log line 1551:

```text
Angelscript: Display: [RuntimeStartup] Legacy runtime is disabled; module remains dormant.
```

Grep of that Unreal.log found no `AS_BIND_CALLBACK_SUMMARY`, `AS_BIND_PHASE_TOTAL`, or `AS_BIND_CALLBACK_TOP`.

## Trim

Raw Unreal.log is large and was not copied. Only the startup dormant line and the absence of bind-execution markers are durable here. Case names come from the Automation report `tests` array.
