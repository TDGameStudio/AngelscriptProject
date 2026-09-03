# Unreal Workflow Evaluation

## Scope

- Date: 2026-09-03
- Host: PowerShell 7.6.0 Core on Win32NT
- Measurement entry: `.agents/skills/unreal-engine-develop/tests/Measure-UnrealEngineDevelop.ps1`
- Method: one untimed warmup followed by three retained samples per operation; nearest-rank percentiles; 30-second fail-closed bound per invocation; process results limited to 16.
- Post-fix formal measurement wall time: 17.595 seconds.
- Isolation: performance samples used a transient Git workspace and a non-executable UE 5.8 fixture. The actual main workspace was exercised only through status, source scan, process observation, suite planning, and typed build `PlanOnly`.
- No Unreal Editor, UBT, native worker, root `Tools` script, build, or Automation run was started by this measurement.

## Retained Performance Results

| Operation | Samples | Min (ms) | P50 (ms) | P95 (ms) | Max (ms) |
|---|---:|---:|---:|---:|---:|
| Module import | 3 | 38.601 | 42.037 | 46.016 | 46.016 |
| Fixture `ue.status` | 3 | 296.484 | 356.625 | 423.657 | 423.657 |
| Source-only target scan | 3 | 326.362 | 375.159 | 518.030 | 518.030 |
| Bounded process scan | 3 | 1190.434 | 1233.599 | 1286.762 | 1286.762 |
| Deterministic Smoke suite plan | 3 | 361.257 | 366.714 | 386.274 | 386.274 |
| Typed build `PlanOnly` | 3 | 715.193 | 780.791 | 808.410 | 808.410 |
| Contained run-progress parsing | 3 | 1.383 | 1.735 | 14.417 | 14.417 |

The post-fix public-route medians are below 0.8 seconds except for machine-wide process observation, whose remaining 1.23-second median includes operating-system process and command-line discovery. The bounded parser remains effectively immediate; its 14 ms maximum is timer/runtime noise at this scale rather than a changed code path.

## Before and After

The pre-fix run used the same script, warmup count, three-sample policy, fixture, actual-workspace checks, and process limit.

| Operation | Pre-fix P50 (ms) | Post-fix P50 (ms) | Reduction | Speedup |
|---|---:|---:|---:|---:|
| Fixture `ue.status` | 2521.013 | 356.625 | 85.9% | 7.07x |
| Source-only target scan | 2309.207 | 375.159 | 83.8% | 6.16x |
| Bounded process scan | 3145.666 | 1233.599 | 60.8% | 2.55x |
| Deterministic Smoke suite plan | 2455.741 | 366.714 | 85.1% | 6.70x |
| Typed build `PlanOnly` | 4816.513 | 780.791 | 83.8% | 6.17x |
| Complete formal collection | 81967 ms | 17595 ms | 78.5% | 4.66x |

The root cause was repeated public single-key configuration reads: each requested Unreal setting re-entered workspace status and repeated Git-derived identity validation. The fix exports one bounded batch-read operation and makes Unreal configuration resolution request all exact keys through it. Each public Unreal route still performs a fresh workspace status evaluation and execution routes still perform a fresh execution guard; no identity, configuration value, or safety decision is cached. The optimization removes duplicate checks within one configuration projection without weakening the workspace boundary between calls.

## Actual Main Workspace Read-only Check

All five checks succeeded after process-local activation of the exact main workspace:

| Check | Result | Non-sensitive evidence |
|---|---|---|
| Unreal status | PASS | Ready installed UE 5.8.0; zero reported configuration errors. |
| Source-only target scan | PASS | Two source targets: `AngelscriptProject` and `AngelscriptProjectEditor`. No UBT query was used. |
| Bounded process scan | PASS | Zero related processes at the observation point; therefore zero correlated builds and zero known-progress records. |
| Smoke suite plan | PASS | Schema `hardness-unreal-suite-plan-v1`; 6 sequential entries; tracked data hash retained below. |
| Typed build plan | PASS | `PlanOnly=true`; Editor/Win64/Development; Installed Engine; controlled `Parallel` lane; 13 planned arguments. |

These results are a point-in-time observation. A zero process count does not assert that future or uncorrelated external activity cannot occur.

## Reproducibility and Source Identity

- The measurement script passed PowerShell AST parsing with zero errors after its final edit.
- Two independently generated Smoke suite plans from identical fixture inputs produced byte-identical compressed JSON.
- Fixture invariants remained exact: one source target and parsed progress `7/10 = 70%`.
- Measurement script: `sha256:a5eb845a771393396babbc856e35b1ab890e79ad8ed79c6aa2aa8764b929994a`
- Unreal PowerShell source tree: `sha256:a1daa25fda4d459f43981c73b4235d2aec7e5dab6de56261cc035f429bc99790`
- Unreal tracked data tree: `sha256:d36d4a8eaa0f5d16df9e9c909e1b9e014f8b86f58ca56ca5094048b8f4868f3c`
- Workspace lifecycle dependency tree: `sha256:c55ce06d27d42503b5695b41a3dc6aaa6c2f5e75e1b364fd00451ab79d55d31c`
- Smoke suite data: `sha256:911d0e17953efe71cf0bc2c8702054852acd9600e16f853fae04ee5f968152bc`
- Retained canonical raw measurement JSON: `sha256:e876f69d59951da228326ec5a327ab515a8165ccfc4cf538fac99b12427e115e`

The raw hash is SHA-256 over the UTF-8 bytes of the single-line JSON below, with no BOM or trailing newline.

```json
{"SchemaVersion":"hardness-unreal-workflow-measurement-v1","Environment":{"PSEdition":"Core","PSVersion":"7.6.0","Platform":"Win32NT","WarmupCount":1,"SampleCount":3,"OperationLimitSeconds":30,"ProcessLimit":16},"Hashes":{"MeasurementScript":"sha256:a5eb845a771393396babbc856e35b1ab890e79ad8ed79c6aa2aa8764b929994a","UnrealSourceTree":"sha256:a1daa25fda4d459f43981c73b4235d2aec7e5dab6de56261cc035f429bc99790","UnrealDataTree":"sha256:d36d4a8eaa0f5d16df9e9c909e1b9e014f8b86f58ca56ca5094048b8f4868f3c","WorkspaceDependencyTree":"sha256:c55ce06d27d42503b5695b41a3dc6aaa6c2f5e75e1b364fd00451ab79d55d31c"},"Reproducibility":{"SuitePlanByteIdentical":true,"FixtureTargetCount":1,"FixtureProgressPercent":70},"Measurements":[{"Id":"module-import","Operation":"Import-Module <unreal-manifest> -Force","Unit":"ms","SampleCount":3,"Samples":[42.037,46.016,38.601],"Min":38.601,"P50":42.037,"P95":46.016,"Max":46.016},{"Id":"fixture-status","Operation":"Get-HardnessUnrealStatus -WorkspaceRoot <fixture>","Unit":"ms","SampleCount":3,"Samples":[423.657,296.484,356.625],"Min":296.484,"P50":356.625,"P95":423.657,"Max":423.657},{"Id":"source-target-scan","Operation":"Get-HardnessUnrealTargetList -WorkspaceRoot <fixture>","Unit":"ms","SampleCount":3,"Samples":[326.362,518.03,375.159],"Min":326.362,"P50":375.159,"P95":518.03,"Max":518.03},{"Id":"bounded-process-scan","Operation":"Get-HardnessUnrealProcessList -WorkspaceRoot <fixture> -Limit 16","Unit":"ms","SampleCount":3,"Samples":[1286.762,1190.434,1233.599],"Min":1190.434,"P50":1233.599,"P95":1286.762,"Max":1286.762},{"Id":"suite-plan","Operation":"New-HardnessUnrealSuitePlan -WorkspaceRoot <fixture> -Suite Smoke","Unit":"ms","SampleCount":3,"Samples":[366.714,361.257,386.274],"Min":361.257,"P50":366.714,"P95":386.274,"Max":386.274},{"Id":"typed-build-plan","Operation":"Invoke-HardnessUnrealBuild -WorkspaceRoot <fixture> -PlanOnly","Unit":"ms","SampleCount":3,"Samples":[780.791,808.41,715.193],"Min":715.193,"P50":780.791,"P95":808.41,"Max":808.41},{"Id":"contained-progress-parse","Operation":"Get-UnrealBuildProgressSnapshot(<contained fixture run paths>)","Unit":"ms","SampleCount":3,"Samples":[1.735,1.383,14.417],"Min":1.383,"P50":1.735,"P95":14.417,"Max":14.417}],"ActualWorkspace":{"Requested":true,"Activated":true,"Mode":"ReadOnlyAndPlanOnly","Checks":[{"Id":"status","Operation":"Get-HardnessUnrealStatus -WorkspaceRoot <actual-workspace>","Success":true,"Reason":"Completed without launching Unreal Engine, UBT, or a native worker.","Details":{"Ready":true,"EngineKind":"Installed","Version":"5.8.0","ErrorCount":0}},{"Id":"source-target-scan","Operation":"Get-HardnessUnrealTargetList -WorkspaceRoot <actual-workspace>","Success":true,"Reason":"Completed without launching Unreal Engine, UBT, or a native worker.","Details":{"Count":2,"Names":["AngelscriptProject","AngelscriptProjectEditor"]}},{"Id":"bounded-process-scan","Operation":"Get-HardnessUnrealProcessList -WorkspaceRoot <actual-workspace> -Limit 16","Success":true,"Reason":"Completed without launching Unreal Engine, UBT, or a native worker.","Details":{"Count":0,"RecognizedBuild":0,"ProgressKnown":0}},{"Id":"suite-plan","Operation":"New-HardnessUnrealSuitePlan -WorkspaceRoot <actual-workspace> -Suite Smoke","Success":true,"Reason":"Completed without launching Unreal Engine, UBT, or a native worker.","Details":{"SchemaVersion":"hardness-unreal-suite-plan-v1","Suite":"Smoke","EntryCount":6,"DataHash":"sha256:911d0e17953efe71cf0bc2c8702054852acd9600e16f853fae04ee5f968152bc","Execution":"SequentialSingleWorkspaceLease"}},{"Id":"typed-build-plan","Operation":"Invoke-HardnessUnrealBuild -WorkspaceRoot <actual-workspace> -PlanOnly","Success":true,"Reason":"Completed without launching Unreal Engine, UBT, or a native worker.","Details":{"PlanOnly":true,"Operation":"Build","Target":"AngelscriptProjectEditor","Platform":"Win64","Configuration":"Development","EngineKind":"Installed","BuildConcurrency":"Parallel","ArgumentCount":13}}]}}
```

## Closure Gate Evidence

- Initial complete `UnrealEngineDevelop.Tests.ps1` run: approximately 155 seconds, failed in a Suites assertion because the `All` tag intentionally reuses one fixture and earlier fake runs had already created the run tree. The production `PlanOnly` route did not write. The assertion was corrected to compare the run-tree snapshot before and after planning instead of assuming the shared fixture directory had never existed.
- Focused Suites rerun: PASS in approximately 30 seconds. The fake two-entry suite completed in 6438 ms; queued cancellation completed in 3370 ms.
- Pre-optimization complete `UnrealEngineDevelop.Tests.ps1` rerun: PASS in approximately 187.1 seconds. Retained fake RunLifecycle durations were 5827 ms, 5822 ms, and 3420 ms; retained Suites durations were 6999 ms and 3359 ms.
- Configuration batching TDD RED: the workspace module did not yet export `Get-HardnessWorkspaceConfigValues`. After implementation, the exact WorkspaceLifecycle test passed in 22.436 seconds, Unreal Foundation passed in 1.586 seconds, and Unreal Integration passed in 3.085 seconds.
- Final post-optimization complete Unreal gate: PASS in 57.484 seconds. Fake RunLifecycle success, timeout, and cancellation took 2603 ms, 2020 ms, and 1603 ms; the two-entry Suite and cancellation took 3277 ms and 1609 ms.
- Final Hardness Quick gate, run concurrently with that complete Unreal gate: 7/7 PASS in 98.928 seconds. Its checks were Hardness 18.989 s, gate contract 9.152 s, protocol 2.435 s, workspace 21.236 s, Git operations 39.049 s, OpenSpec Skill 5.217 s, and Unreal Integration 2.737 s.
- These gates used fake native processes and fixture workspaces. They did not run a real UE build or Automation suite.

## Interpretation

The retained post-fix baseline confirms that the public surface is bounded, functionally safe, and substantially faster without caching safety state. Configuration projection now pays for one live workspace status or execution guard and one bounded exact-key batch instead of repeating that work for every key. Future work may profile the remaining operating-system process-discovery cost, but must not infer progress without trusted correlation or weaken the fresh per-route workspace boundary.
