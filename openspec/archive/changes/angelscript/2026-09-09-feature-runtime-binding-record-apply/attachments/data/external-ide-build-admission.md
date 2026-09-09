# External IDE build admission evidence — 2026-09-08

Issue owner: [external IDE build admission](../implementation/issue-20260908-180555-external-ide-build-admission.md).

## Managed failure

Run `619df032b389447490a0db70ee26ccf2`, `ue.build`, target `AngelscriptProjectEditor Win64 Development`, default `Auto` concurrency, `NoWait=true`, timeout 900000 ms. Harness selected shared Installed Engine lane with `-NoMutex -NoEngineChanges`; execution drive `Y:` resolves to the selected physical workspace `D:\Workspace\AngelscriptProject`.

Terminal `State=Failed`, `ExitCode=6`. Native UBT elapsed 0.81 seconds. The retained log reports:

```text
Compiling Y:\Intermediate\Build\BuildRules\AngelscriptProjectModuleRules.dll
Unhandled exception: IOException: The process cannot access the file 'Y:\Intermediate\Build\BuildRules\AngelscriptProjectModuleRules.dll' because it is being used by another process.
```

## Public process observation

This compact transcription preserves the relevant fields returned by `Invoke-Harness -Command ue.process.list -Context $context` at `2026-09-08T09:59:48.5931701Z`. It is an observed aggregate, not a later reconstructed process scan.

| Field | Observed value |
|---|---|
| Id / Name / Kind | 26984 / dotnet / Ubt |
| StartedAtUtc | 2026-09-08T09:56:17.1481728Z |
| UBT target | AngelscriptProjectEditor Win64 Development |
| Project argument | D:\Workspace\AngelscriptProject\AngelscriptProject.uproject |
| Other arguments | -WaitMutex -FromMsBuild -architecture=x64 |
| WorkspaceMatch / EngineMatch | true / true |
| RecognizedBuild | false |
| RunId / structured ProjectFile / Target | empty |
| ProgressKnown | false |

The command uses the installed Engine's .NET host and `UnrealBuildTool.dll`. No `-Log` or Harness session correlation exists. Later observations showed this UBT absent and a same-workspace Editor present. No process was terminated by this task.

## Artifact identity

Paths are relative to the selected workspace. Raw managed-run files remain under ignored `Saved/`; these hashes and the aggregate above are durable evidence.

| Path | SHA-256 |
|---|---|
| Saved/Harness/Unreal/Runs/619df032b389447490a0db70ee26ccf2/UBT.log | 9271FFE73A093C44288667CA9A8C8B66F39745ED79B2DD7C63061850A8BE097C |
| Saved/Harness/Unreal/Runs/619df032b389447490a0db70ee26ccf2/Request.json | 8E2B9CF528F75D941F349AAE85D88DB7A2A2FE3F66ED5A87CA43D32F5AC06B53 |
| Saved/Harness/Unreal/Runs/619df032b389447490a0db70ee26ccf2/RunMetadata.json | 55E5426BE71DD7DD1EBCE14AF073FBBE7761ABE745C37EFBFB045D31FA8471BC |
| .agents/skills/unreal-engine-develop/scripts/Private/Concurrency.ps1 | 856C73348141412AB2401D5E4292970008344C1719FA70F4BB7F666483BE7CE9 |
| .agents/skills/unreal-engine-develop/scripts/Private/Run.ps1 | 99D01C8712D95BAF54BA553B55EEE41B18DA90589F29B7D39D718F49EF3C97E2 |
| .agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1 | DBF074F26AFFB6FC47D0D6972C8CD0C98930DDDDA48062EC89C67CDA133CDE50 |

This records real contention and a code-level admission gap. It does not identify an OS handle owner or prove a fix.
