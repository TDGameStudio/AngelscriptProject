---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-git-copy-scope-false-positive
closure_kind: completed
input_sha256: 56167afa1fc1e7479abe51415a4ca97f9708e6bb4aa676e97b20c4dcfa232be4
captured_at: 2026-09-04T22:11:23+08:00
---

# Workflow evaluation

## Lifecycle

- Post-archive dogfooding exposed a material exact-commit false positive, so an immediate focused successor Change recorded the issue instead of mutating the completed Scenario authoring archive.
- Proposal, durable delta, design, two-node Ready Task DAG, INDEX, compact RED evidence, and an open v2 issue were created and strictly validated before implementation.
- Task 1.1 converted the old copy-rejection fixture into an acceptance fixture, observed the expected RED, applied the mutation-based repair, passed the complete direct suite, and resolved the issue.
- Task 2.1 synchronized the durable `harness/git` contract and completed focused verification.

## Material friction and corrective action

Issue `issue-20260904-220329-copy-scope-false-positive` records the failed real commit, safe ref/index restoration, root cause, one-time workaround, focused RED, repair, and GREEN evidence. No Review or Replan was needed because the implementation matched the accepted plan.

## Verification

- `GitOperations.Tests.ps1`: passed after proving target-only copied content commits exactly one target path, leaves the unchanged source byte-equivalent, and retains true cross-scope rename rejection plus the full existing Git fixture set.
- `Protocol.Tests.ps1`: passed with the resolved v2 issue and maintained lifecycle contracts.
- Skill Creator `quick_validate.py .agents/skills/git-operations`: passed.
- Semantic synchronization identity: one modified Requirement body and three complete Scenario Cards matched the delta and current `harness/git` spec.
- OpenSpec doctor: valid with zero errors.
- Strict exact Change validation: passed with a complete 2/2 Task DAG.
- Strict `harness/git` and all-current-spec validation: passed; all seven current specs are valid.

## Synchronization and ownership

The crossing helper now requests rename detection and validates only `R` endpoint pairs. Existing staged-path enumeration still rejects every actual path outside scope. The current `harness/git` contract and exact-commit reference distinguish true renames from advisory copy similarity. No public Git route parameter, commit ordering, hook invocation, ref restoration, index restoration, integration, push, submodule, or product-code contract changed.

## Exclusions

Harness Quick, Performance, Integration, Unreal operations, plugin tests, and Standalone tests were intentionally omitted. The isolated direct Git fixture exercises the changed candidate-index behavior and adjacent safety boundaries; no Unreal, product, performance, or cross-component integration behavior changed.

## Raw-data provenance

The real failed-commit diagnostic is retained in `attachments/data/git-copy-scope-red.md`. Direct fixture output was observed in the current PowerShell 7 session; temporary fixture repositories were not promoted.
