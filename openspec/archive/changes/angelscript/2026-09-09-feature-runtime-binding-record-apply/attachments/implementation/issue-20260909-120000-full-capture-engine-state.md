---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260909-120000-full-capture-engine-state
status: resolved
source: verification
source_ref: run-d068162096754c4d80a5125f1ee6dd99
affected_tasks: ["8.2"]
created_at: 2026-09-09T12:00:00+08:00
resolved_at: 2026-09-09T13:40:00+08:00
resolution_ref: attachments/data/verification-full-runtime.md
---

# Full Runtime capture entered legacy Engine-only provider branches

## Symptom

The first complete `CreateForBindings` capture reached providers together for the first time. Harness runs `d068162096754c4d80a5125f1ee6dd99`, `f50cfd61876f45a2a01a3ae5693bca1b`, `00b5b7ec09e44973ba3ad86cbc541515`, `a66942ef450b485496823ed9125f219b`, and `e4444352b4ca424eb005272780549942` exposed successive assertions at `FAngelscriptBinds::GetTargetEngine`, `GetTargetTypeDatabase`, or `GetTargetScriptEngine` while the detached recorder had no target Engine by design.

The first bad boundaries were the delegate declaration provider, infrastructure type-finder registration, primitive settings/documentation, and container infrastructure setup. Family fixtures had selected migrated member providers plus a separate declaration catalog, so they did not previously execute every infrastructure callback in one detached pass.

## Investigation Log

1. Runs `d068162096754c4d80a5125f1ee6dd99`, `f50cfd61876f45a2a01a3ae5693bca1b`, `00b5b7ec09e44973ba3ad86cbc541515`, `a66942ef450b485496823ed9125f219b`, and `e4444352b4ca424eb005272780549942` successively isolated the Engine-only access points.
2. The provider inventory and capture manifest showed that selected-family fixtures had never composed every declaration and infrastructure provider in one detached capture.
3. Repeated full-runtime runs after the repair exposed test-owned heap corruption; aligned raw storage replaced placement construction over an already constructed stack object.

## Root Cause

`FAngelscriptTypeBindInfoRecorder::Capture` originally executed TypeDeclarations in their ordinary mutable-engine mode and did not compose the established declaration-only catalog prepass. Several infrastructure callbacks also performed two different jobs in one body: record adapter identity for the snapshot and mutate a legacy per-Engine type database. Shared facade operations did not consistently make the second operation inert while recording.

## Disposition

Full capture now imports installable declarations through the declaration-only catalog and executes later phases against the same writable Store. Shared type-finder authoring is inert while recording. Primitive target settings are captured in `FAngelscriptBindRecordingPolicy`; primitive documentation and mutable adapter setup are engine-only. Array, map, set and optional infrastructure records adapter identities before returning from their recording branch, while their mutable Engine registration remains unchanged.

Every registered provider now reaches one explicit outcome under the captured policy. The factory publishes independently owned Engines from sealed validated Stores, and failure during finalization or native linking publishes no owner. The full-runtime fixture also corrected its placement-construction storage so repeated capture is free of test-induced heap corruption.

## Evidence

### Failure Evidence (RED)

- The five failing Harness runs above reached exact `GetTargetEngine`, `GetTargetTypeDatabase`, or `GetTargetScriptEngine` assertions while detached recording was active.
- The failing provider boundaries and subsequent heap corruption are retained in the task 8.2 lifecycle summarized by [full Runtime verification](../data/verification-full-runtime.md).

### Resolution Evidence (GREEN)

Exact runs `05205d5fade149d2addde33559ecf196` and `914625e880234063b4878417fba543cb` each passed all six full-runtime cases. Two 267-provider manifests passed independent expectation validation and are byte-identical across all nine artifacts. `attachments/data/verification-full-runtime.md` retains the complete commands, counts, hashes, policy, and broader RuntimeBindings result.

### What This Proves

- Every eligible Runtime provider reaches an explicit recorded outcome and a fresh Engine can publish and execute the representative full-runtime surface twice deterministically.
- Detached capture no longer enters the demonstrated legacy Engine-only branches.

### What This Does Not Prove

- It does not enable the dormant legacy startup path, JIT, debugger, cache, or optional integration services.
- It does not establish parallel recording or shared mutable Engine state.

## Links

- [Full Runtime verification](../data/verification-full-runtime.md).
- [Final verification](../data/final-verification.md).
- [Task 8.2](../../tasks.md).
