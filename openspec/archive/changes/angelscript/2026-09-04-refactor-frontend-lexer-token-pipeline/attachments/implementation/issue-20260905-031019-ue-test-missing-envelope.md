---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-031019-ue-test-missing-envelope
status: rejected
source: dogfooding
source_ref: run-d1de6aab2afd498d969ac8bc27b3176a
affected_tasks: ["2.1"]
created_at: 2026-09-05T03:10:19+08:00
resolved_at: 2026-09-05T03:13:36+08:00
resolution_ref: run-4e29fd17bd0a44c693f50d52268a7f21
---

# One synchronous ue.test invocation returned no envelope before its worker finished

## Symptom

The first `frontend-lexer-edge-test` invocation returned no serialized Harness envelope to its caller after roughly fifteen seconds, while managed run `d1de6aab2afd498d969ac8bc27b3176a` remained `Running`. The worker later reached a terminal test failure, wrote `RunMetadata.json`, `Summary.json`, logs, and an Automation report, and released the workspace normally.

## Investigation Log

1. `Invoke-Harness -Command ue.test` created run `d1de6aab2afd498d969ac8bc27b3176a` for the exact Lexer Fast prefix.
2. The invoking PowerShell process ended without producing the expected envelope while the run metadata still reported `Running` and no summary existed.
3. The run subsequently completed in 24,572 ms with one CQTest assertion-representation failure and complete artifacts.
4. The correct exact-run observation route is `ue.run.status`; `ue.status` is intentionally only workspace and Engine readiness. The attempted `ue.status -RunId` call is excluded from this issue.
5. Later exact-prefix invocations returned complete terminal envelopes normally, including failed run `6d30f313de324ed89c825e08acef71f3` and successful run `4e29fd17bd0a44c693f50d52268a7f21`.

## Root Cause

The root cause is not demonstrated. Evidence proves one synchronous caller observed an empty return before the managed worker completed, but does not identify whether the loss occurred in Harness result waiting/serialization or the surrounding PTY session boundary.

## Disposition

Reject a Harness implementation change from this single non-reproduced observation. The managed run itself retained complete authoritative evidence and two later calls returned normal envelopes. Reopen only if recurrence captures the caller transcript plus `ue.run.status` observations around the early return.

## Evidence

### Failure Evidence (RED)

- Managed run: `d1de6aab2afd498d969ac8bc27b3176a`.
- Terminal metadata: `Saved/Harness/Unreal/Runs/d1de6aab2afd498d969ac8bc27b3176a/RunMetadata.json`.
- Terminal summary: 11 total, 10 succeeded, 1 failed for a CQTest conversion ensure.
- The missing envelope did not hide or overwrite the terminal run artifacts.

### Resolution Evidence (GREEN)

- Failed run `6d30f313de324ed89c825e08acef71f3` returned a complete failed envelope.
- Successful run `4e29fd17bd0a44c693f50d52268a7f21` returned a complete success envelope and reported 11/11 with zero warnings and errors.

### What This Proves

- One synchronous caller returned without a Harness envelope before its managed run reached terminal state.
- Harness-owned run metadata, logs, Automation report, and summary remained authoritative and complete despite that caller-side symptom.
- The observation did not recur in the next two exact-prefix invocations.

### What This Does Not Prove

- It does not prove that `ue.test`, the Harness worker, PowerShell, or the PTY owns the defect.
- It does not justify retries, timeout-policy changes, or widening the Lexer verification scope.

## Links

- Task `2.1` in `tasks.md`.
- `.agents/skills/unreal-engine-develop/SKILL.md`, run observation routes.
- `.agents/skills/openspec/references/implementation-issues.md`.
