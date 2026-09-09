---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260908-180555-external-ide-build-admission
status: rejected
source: user
source_ref: run-619df032b389447490a0db70ee26ccf2
affected_tasks: ["2.5"]
created_at: 2026-09-08T18:05:55+08:00
resolved_at: 2026-09-09T13:50:00+08:00
resolution_ref: attachments/data/external-ide-build-admission.md
---

# Harness admits a build while an external IDE build uses the same workspace

## Symptom

Task 2.5's implementation build failed before C++ compilation. UBT could not open `Intermediate/Build/BuildRules/AngelscriptProjectModuleRules.dll` because another process was using it. An external IDE UBT process for this exact workspace was running concurrently. The user explicitly requested that this Harness problem be recorded.

## Investigation Log

1. Managed RED setup build `5f84b4f2dae746438a94e4832468837b` succeeded, and test run `6a31a39a884140f9958f39f7d3b83bea` produced the expected task 2.5 RED. These are separate from the infrastructure failure.
2. External `dotnet` PID 26984 started at `2026-09-08T09:56:17.1481728Z`, with `UnrealBuildTool.dll AngelscriptProjectEditor Win64 Development -Project="D:\Workspace\AngelscriptProject\AngelscriptProject.uproject" -WaitMutex -FromMsBuild -architecture=x64`.
3. Harness admitted build `619df032b389447490a0db70ee26ccf2` using the default Installed Engine decision `ParallelInstalledProjectBuild`, shared Engine lane and `-NoMutex -NoEngineChanges`. Its native UBT failed in 0.81 seconds while compiling the rules assembly. `ue.run.status` reported `Failed`, exit 6.
4. At `2026-09-08T09:59:48.5931701Z`, `ue.process.list` returned the external PID with `Kind=Ubt`, `WorkspaceMatch=true`, `EngineMatch=true`, `RecognizedBuild=false`, empty `RunId` and `ProgressKnown=false`. The exact observed aggregate is retained in the linked data attachment.
5. `Concurrency.ps1` selects the shared Installed Engine lane. The worker in `Run.ps1` acquires Harness workspace/drive/Engine leases and launches the native process; that admission path has no external same-workspace process guard. The IDE does not participate in Harness's workspace mutex, and the admitted build bypasses UBT's mutex with `-NoMutex`.
6. `Engine.ps1` deliberately requires a managed run, native PID, contained metadata and a trusted run-local UBT log before exposing build details/progress. The IDE command has no such log argument. `ProgressKnown=false` is therefore current policy, not evidence that process discovery failed.
7. The external UBT later exited. At the next process scan, a same-workspace Editor was present instead. Managed retry `c97f43ac1b224eb6b60da4e0ca598b67` passed the rules-assembly boundary and entered C++ compilation. This observation does not prove the coordination defect is repaired.

## Root Cause

The demonstrated Harness design gap is incomplete same-workspace admission across managed and unmanaged builds. Harness's private workspace lease only coordinates participating Harness workers. The default Installed Engine lane bypasses UBT's mutex without checking the external same-workspace activity that `ue.process.list` can already identify.

The DLL sharing violation and concurrent IDE build are demonstrated. No OS file-handle owner capture was taken, so PID 26984 is a strongly correlated contender, not a directly proven owner of that exact DLL handle. The progress limitation is intentional trust policy and must be distinguished from the admission defect.

## Disposition

Rejected from this Runtime binding Change because the demonstrated admission defect belongs to Harness concurrency policy and does not invalidate task 2.5's binding requirements, design boundary, or completed verification. This disposition deliberately leaves the Harness defect unfixed; it does not reject the observation or claim that coordination is correct. Preserve task 2.5's native implementation scope and the evidence-backed follow-up requirements below.

The follow-up should give known external activity in the exact workspace an explicit admission outcome (wait with reason, or fail under `ConcurrencyPolicy=Fail`), preserve eligible parallel work across distinct workspaces, and close the launch-race boundary as far as the chosen coordination mechanism permits. Basic external target/project identity should remain useful even when trusted progress is unavailable. Required proof should include external same-workspace UBT, different-workspace UBT, physical/execution-drive aliases, timeout/fail behavior, and unknown progress. No Harness implementation change or fixed claim is made by this issue.

## Evidence

### Failure Evidence (RED)

- Command: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`, selected workspace `D:\Workspace\AngelscriptProject`.
- Managed run: `619df032b389447490a0db70ee26ccf2`; terminal failure, exit 6.
- Exact error, source identities and process aggregate: [external IDE build evidence](../data/external-ide-build-admission.md).

### Resolution Evidence (GREEN)

No repair was made in this Change. A subsequent build reaching C++ compilation after the external UBT exited established that binding verification could resume; it is a workaround observation, not a regression test or repair of external-build admission.

### Rejected Evidence

- The earlier archived `issue-20260905-020702-ubt-rules-assembly-lock` had no observable live contender and rejected a speculative Harness change. This recurrence has a same-workspace external process and an identified coordination gap; the archived record is preserved unchanged.
- Missing external build percentage does not prove that Harness cannot discover or match the process.
- The finding was deliberately not implemented here because its owner is Harness concurrency policy and the complete binding verification does not depend on changing that policy.

### What This Proves

- A Harness build and external IDE UBT can overlap in one workspace under the default shared Engine lane.
- The managed build encountered a rules-assembly sharing violation during that overlap.
- External workspace matching and trusted managed progress are separate capabilities.

### What This Does Not Prove

- No direct OS handle trace identifies the exact process holding the rules DLL.
- This is not evidence of an AngelScript ABI failure, a broken native test, a need to disable UBA, or a reason to delete intermediates.
- The retry does not prove the external admission defect repaired and does not authorize terminating the user's Editor.

## Links

- [Evidence aggregate](../data/external-ide-build-admission.md).
- [Task 2.5](../../tasks.md).
- `.agents/skills/unreal-engine-develop/references/concurrency.md`.
- `.agents/skills/unreal-engine-develop/scripts/Private/Concurrency.ps1`.
- `.agents/skills/unreal-engine-develop/scripts/Private/Run.ps1`.
- `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`.
- `openspec/archive/changes/angelscript/2026-09-05-refactor-native-engine-test-foundation/attachments/implementation/issue-20260905-020702-ubt-rules-assembly-lock.md`.
