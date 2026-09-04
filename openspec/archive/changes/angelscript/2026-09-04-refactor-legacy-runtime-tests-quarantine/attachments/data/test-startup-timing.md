# Focused replacement-test startup timing

## Scope

This measurement compares the two supported Harness `ue.test` launch modes for the exact same replacement baseline:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.Baseline'
    TimeoutMs = 600000
}

Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.Baseline'
    Fast = $true
    TimeoutMs = 600000
}
```

Both were fresh Harness-managed `UnrealEditor-Cmd.exe` processes in the same warm Windows workspace with UE 5.8, `-NullRHI`, no sound, an enforced Automation report, and the same three-test exact prefix. “Fast” is the public Harness option. The internal launch-profile name `fast-headless` describes its command-line/no-render characteristics; it is not a separate test framework or project entry point.

## Results

| Harness mode | Run ID | Managed process | Test-body total | Result |
|---|---|---:|---:|---|
| Ordinary `ue.test` | `a3b3d43df3aa4cb992b438d406871cf4` | 27.011 s | 0.135000 s | 3/3 passed; 0 failed |
| `ue.test` with `Fast = $true` | `427f9ed3a4ac4588a79c3e55adf9f00d` | 26.838 s | 0.129320 s | 3/3 passed; 0 failed |

The observed Fast saving was 0.173 s, or about 0.64 percent. Test bodies occupied only about 0.13 s, so roughly 26.7 s was fresh UE process startup, project/module load, Automation discovery, report export, and shutdown. On this machine the Fast switches are directionally correct but the measured improvement is small enough to treat as environment noise rather than a portable performance guarantee.

The legacy-namespace discovery scenario passed but received 2,436 unrelated `LogMetaSound` warnings while `FAutomationTestFramework::GetValidTestNames` enumerated the global UE test registry. Both runs produced the same warning count and zero errors. This makes the Harness summary `PassedWithWarnings`; it does not indicate that a legacy AngelScript test was registered or failed.

## Launch differences

Both modes used the Harness-owned workspace mapping, exact Automation prefix, bounded timeout, `UnrealEditor-Cmd.exe`, unattended execution, `-NoSplash`, `-stdout`, UTF-8 output, no sound, `-NullRHI`, absolute log output, and an exported Automation report.

The Fast run additionally used:

- `-NoLoadStartupPackages`
- `-NoLiveCoding`
- `-NoScreenMessages`
- `-DisableAutomaticShaderCompilerLaunch`
- `-NoAssetRegistryCacheWrite`

The complete request and report sources are retained in the ignored run directories:

- `Saved/Harness/Unreal/Runs/427f9ed3a4ac4588a79c3e55adf9f00d/Request.json`
- `Saved/Harness/Unreal/Runs/427f9ed3a4ac4588a79c3e55adf9f00d/AutomationReport/index.json`
- `Saved/Harness/Unreal/Runs/a3b3d43df3aa4cb992b438d406871cf4/Request.json`
- `Saved/Harness/Unreal/Runs/a3b3d43df3aa4cb992b438d406871cf4/AutomationReport/index.json`

## Decision

Use Harness `ue.test` with `Fast = $true` and the narrowest exact `Angelscript.UnitTest...` prefix for focused logic-only replacement-test feedback. Keep ordinary `ue.test` for behavior that needs its broader startup surface, and use `Render = $true` only when rendering is part of the contract.

No custom commandlet or persistent editor process is introduced. Either could reduce repeated startup cost, but it would add a new lifecycle and state-isolation contract and would no longer prove a clean fresh-process baseline.

## Limitations

- The two samples were sequential single runs, not a performance benchmark.
- DDC, OS file cache, antivirus activity, engine installation, hardware, and other machine load can dominate a sub-second difference.
- These durations are evidence for launch selection in this Change, not a pass/fail budget for other machines.
- The retained reports live under ignored `Saved/Harness`; the compact measurements above are the durable evidence.
