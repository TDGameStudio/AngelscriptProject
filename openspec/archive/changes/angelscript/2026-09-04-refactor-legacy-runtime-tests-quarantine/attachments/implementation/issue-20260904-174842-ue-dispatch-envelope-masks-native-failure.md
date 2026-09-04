---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-174842-ue-dispatch-envelope-masks-native-failure
status: rejected
source: dogfooding
source_ref: af2fd14ba73c4f4994a65d805b7846a3
affected_tasks: ["3.2"]
created_at: 2026-09-04T17:48:42+08:00
resolved_at: 2026-09-04T17:55:27+08:00
resolution_ref: .agents/skills/angelscript-test-guide/references/legacy-source-isolation.md#transition-and-verification
---

# `ue.build` dispatch envelope masks a terminal native failure

## Symptom

Multiple synchronous Harness `ue.build` calls returned an outer `status: Succeeded`, `exitCode: 0`, and `error: null` even though the returned managed operation reported `Data.State: Failed`, `Data.RecordedState: Failed`, and `Data.ExitCode: 6`. A caller checking only the common Harness envelope would incorrectly record a failed UBT build as successful.

## Investigation Log

1. Managed build `af2fd14ba73c4f4994a65d805b7846a3` failed with reflection-related `LNK1120`; its enclosing Harness result `709d52a46974433fbf76bec2d451d9da` reported success and exit code zero.
2. Managed builds `c1417a7ff9f44eb4977934e616d11806`, `fecbd75868d4471eba4d36302a7eb396`, `fc74b516f56c4516b69be7e1256041c2`, and `ac445e3032bd4252a2c53fb3398d03ac` reproduced the mismatch for UHT or compiler failures.
3. `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1` shows that synchronous `Invoke-HarnessUnrealBuild` returns the terminal object from `Start-UnrealRunRequest` without throwing when `State` is `Failed`.
4. `.agents/skills/harness/scripts/Harness.psm1` shows that `Invoke-Harness` wraps every non-throwing PowerShell route return in `New-HarnessResult -Status 'Succeeded' -ExitCode 0`; it does not propagate a returned managed operation's terminal failure state.
5. Successful managed build `8cbf894039494de5ad132e5ab00ee870` returned success at both layers, confirming that the mismatch is specific to native failure propagation rather than all synchronous UE results.

## Root Cause

The generic dispatcher interprets successful route invocation as successful route outcome, while the synchronous UE leaf models native completion as returned data. No adapter maps terminal `Data.State` and `Data.ExitCode` back into the common envelope, and the leaf does not throw on a failed native operation.

## Disposition

This product isolation Change will inspect the authoritative managed operation fields and artifacts, and will not change the public Harness result contract. A dedicated Harness Change should decide whether synchronous `ue.build`, `ue.test`, and `ue.commandlet` routes throw, propagate terminal state into the outer envelope, or explicitly distinguish dispatch success from operation success.

## Evidence

### Failure Evidence (RED)

- Outer/inner mismatch: Harness result `709d52a46974433fbf76bec2d451d9da`, managed run `af2fd14ba73c4f4994a65d805b7846a3`.
- Additional managed failures: `c1417a7ff9f44eb4977934e616d11806`, `fecbd75868d4471eba4d36302a7eb396`, `fc74b516f56c4516b69be7e1256041c2`, `ac445e3032bd4252a2c53fb3398d03ac`.
- Dispatcher: `.agents/skills/harness/scripts/Harness.psm1`, `Invoke-Harness` success return.
- UE leaf: `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `Invoke-HarnessUnrealBuild`.

### Resolution Evidence (GREEN)

The product task avoided false-positive evidence by reading `Data.State`, `Data.ExitCode`, `UBT.log`, and `Summary.json` directly. Successful source-topology build `8cbf894039494de5ad132e5ab00ee870` returned `Data.State: Succeeded`, `Data.ExitCode: 0`, and completed all 15 actions. The focused legacy-source isolation reference now preserves this required interpretation for future work touching this boundary.

### Rejected Evidence

Changing the common Harness result envelope is rejected from this product-isolation Change because it is a public cross-route contract outside the accepted scope. The finding itself is not rejected: the mismatch is demonstrated and retained here. A dedicated Harness Change must decide whether synchronous UE routes throw on native failure, propagate terminal state into the outer envelope, or explicitly model dispatch success separately from operation success.

### What This Proves

A failed synchronous UE native operation can be represented as a successful common Harness envelope, creating a false-positive hazard for callers that follow only the outer fields.

### What This Does Not Prove

It does not establish the correct future API shape or prove that asynchronous `-NoWait` dispatch should treat a later native failure as an immediate dispatch failure.

## Links

- `.agents/skills/harness/scripts/Harness.psm1`
- `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`
- `Saved/Harness/Unreal/Runs/af2fd14ba73c4f4994a65d805b7846a3/RunMetadata.json`
