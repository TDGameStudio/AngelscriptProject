## Why

Harness dogfooding exposed two coupled correctness failures at the Unreal execution boundary. UE 5.8 suppresses the global UBA trace for a `-Session` build while still allowing low-action executor selection to choose UBA, so an ordinary incremental build can fail before compilation unless the caller manipulates unrelated parallel-action thresholds. Separately, synchronous Unreal routes return terminal operation data without throwing, and the dispatcher currently wraps that failed operation in a successful common envelope.

## What Changes

- Stop sending UBT's recursive-invocation `-Session` option from top-level Harness requests. Correlate active builds through the run ID already embedded in the contained `-Log` path plus exact native PID, project, request, metadata, and path validation.
- Preserve configured UBA/XGE selection instead of forcing an executor. Expose the verified local environment and capacity boundaries in retained Change evidence.
- Map failed, timed-out, cancelled, or orphaned terminal data returned by synchronous Unreal execution routes to a failed common Harness envelope with the operation exit code, data, and artifacts preserved.
- Keep asynchronous dispatch and observation/cancellation route semantics unchanged.
- Add focused regression fixtures and validate one real low-action editor build without a caller-supplied executor workaround.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/unreal`: Session-correlated build executor compatibility and truthful synchronous operation outcomes.

## Impact

This parent-repository Change modifies `.agents/skills/unreal-engine-develop`, `.agents/skills/harness`, and the current `harness/unreal` specification. It repairs one immediately preceding archive index entry exposed by protocol validation, but does not rewrite its substantive historical records. It does not modify Unreal, plugin, Standalone, or product test code; public route names, input parameters, record schemas, and `Test-Harness.ps1` profiles remain compatible.

The accepted evidence comes from archived dogfooding issues `issue-20260904-171616-ubt-session-uba-executor` and `issue-20260904-174842-ue-dispatch-envelope-masks-native-failure`. Existing unrelated worktree changes are outside this Change.
