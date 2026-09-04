---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-171616-ubt-session-uba-executor
status: rejected
source: dogfooding
source_ref: 237c0c9ef9984fdfbd1ecb29ec49e91f
affected_tasks: ["2.2"]
created_at: 2026-09-04T17:16:16+08:00
resolved_at: 2026-09-04T17:55:27+08:00
resolution_ref: task 2.2 build 268038d31f8b4eb68d612852b4485685
---

# UE 5.8 Session-tagged UBT selects an unusable UBA executor for small builds

## Symptom

Two consecutive Harness `ue.build` runs failed before executing any compile action. UBT selected its local UBA executor for a 16-action incremental build and raised `UBA executor is not expected to be invoked from a recursive UBT call.` The immediately preceding 89-action Harness build succeeded because UBT selected XGE.

## Investigation Log

1. Build `95f9c56f781b4ef0b01f04ee36e0dade` compiled 89 actions successfully through XGE with Harness `BuildConcurrency = Auto`.
2. After the Task `2.2` module edits, build `237c0c9ef9984fdfbd1ecb29ec49e91f` had 16 actions, selected UBA, and failed during `UBAExecutor.Init`.
3. A second unchanged retry, build `012f47764e614d8fb4dc243329e19eb2`, reproduced the same failure.
4. UE 5.8 source inspection showed `UnrealBuildTool.cs` deliberately creates no global UBA trace whenever any `-Session=` argument is present, while `UBAExecutor.Init` requires that trace and labels its absence a recursive UBT call.
5. Harness intentionally appends `-Session=<RunId>` for owned build observation. `ExecutorFactory` selects XGE only when the action count reaches the calculated remote threshold; smaller action sets fall through to UBA.
6. A bounded retry kept both executors enabled and passed `-MaxParallelActions=8`, lowering the existing remote threshold so XGE remained eligible. Managed build `268038d31f8b4eb68d612852b4485685` selected XGE and succeeded.

## Root Cause

The Harness run-ownership argument and UE 5.8 executor-selection rules are individually valid but incompatible on the low-action path: `-Session` suppresses the UBA global trace, then `ExecutorFactory` can still select UBA and `UBAExecutor.Init` rejects the trace-less invocation.

## Disposition

The current product Change will not modify Harness APIs or executor policy. It will use the smallest evidence-backed per-run workaround that preserves Harness ownership and does not disable UBA or XGE: retain `BuildConcurrency = Auto` and pass `-MaxParallelActions=8` only when the demonstrated low-action failure occurs. A durable Harness fix remains to be explicitly scoped after this issue is evaluated.

## Evidence

### Failure Evidence (RED)

- Command: `Invoke-Harness -Command ue.build ... -Parameters @{ BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto' }`
- Runs: `237c0c9ef9984fdfbd1ecb29ec49e91f`, `012f47764e614d8fb4dc243329e19eb2`
- Artifacts: `Saved/Harness/Unreal/Runs/<RunId>/UBT.log`
- Engine source: `Engine/Source/Programs/UnrealBuildTool/UnrealBuildTool.cs` and `Executors/UnrealBuildAccelerator/UBAExecutor.cs`

### Resolution Evidence (GREEN)

The product build completed successfully as managed run `268038d31f8b4eb68d612852b4485685` with `BuildConcurrency = Auto` and `-MaxParallelActions=8`. This proves the bounded workaround can preserve Harness ownership and both configured executors while avoiding the demonstrated low-action UBA selection.

### Rejected Evidence

Changing the Harness `-Session` ownership model or UE executor policy is rejected from this product-isolation Change because neither is part of its accepted files or public behavior. The underlying Harness/UE compatibility defect remains valid durable evidence here; a later Harness Change must select and verify a general fix rather than turning this task-local threshold workaround into universal policy.

### What This Proves

The same low-action Harness request reproduces a deterministic UE 5.8 executor failure before compilation, and the failure depends on the interaction between `-Session` trace suppression and UBA selection rather than the edited AngelScript C++ code.

### What This Does Not Prove

It does not prove that UBA itself is generally broken, that XGE should always be forced, or that changing/removing Harness `-Session` is safe. It also does not validate the current C++ edits until a build executor completes them.

## Links

- `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`
- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/UnrealBuildTool.cs`
- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/Executors/ExecutorFactory.cs`
- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/Executors/UnrealBuildAccelerator/UBAExecutor.cs`
