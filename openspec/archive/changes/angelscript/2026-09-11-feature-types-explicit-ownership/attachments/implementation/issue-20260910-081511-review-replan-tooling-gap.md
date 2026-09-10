---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260910-081511-review-replan-tooling-gap
status: rejected
source: user
source_ref: "User: record the Review/Replan tooling concerns for later; do not change Harness now"
affected_tasks: ["7.10"]
created_at: 2026-09-10T08:15:11+00:00
resolved_at: 2026-09-11T12:00:00+00:00
resolution_ref: attachments/data/verification-final.md
---

# Review and Replan mechanical tooling gap

## Symptom

The current SDK plan review required one-off Python scripts and inline commands to materialize snapshots, preserve candidate task invariants, apply records, update indexes and check final lifecycle evidence. Some operations duplicate existing Harness checks. The process is expensive and depends on agent-specific sequencing.

## Investigation Log

Read Saved/TypePlanReview/run.py and prepare.py, the Harness route registry and Review snapshot validation, plus the current review/replan protocols. No Harness mutation or runtime experiment was performed for this diagnosis.

- run.py hardcodes the workspace, Change scope and source ranges; it captures document content, manifests and before-state hashes.
- prepare.py first appends the initial review links to the canonical INDEX, then builds/asserts candidate text. A repeated call may append duplicate links before a later replacement assertion fails. This is an auxiliary-script defect; it is not a reproduced Harness failure.
- Helper reuse extracts and execs part of run.py. Apply, report, closure and checks also used inline commands, so the two scripts do not form a complete replayable transaction.
- Existing Harness task.status and strict validation succeeded. The unsupported -ChangeId invocation and a PowerShell foreach pipeline syntax error were agent invocation mistakes, subsequently corrected.
- The reviewed Harness route registry has no dedicated snapshot creation/verification or candidate-application route. Review checks at Harness.psm1:1403-1406 validate reference text and SHA-256 format; they do not resolve the referenced snapshot and recompute its content digest.

A subsequent read-only `harness.evolution.status` call (run `8d62132ef8264ded8278b51e3ac4f190`) returned exitCode 0 but reported StructuralErrors: zero INDEX occurrences for the new issue and three existing reviews, despite Markdown links present in INDEX, plus three open Required findings in the older superseded process-TypeId review. This is diagnostic evidence requiring follow-up; it does not yet establish whether INDEX syntax support, record authoring or historical finding disposition is the cause. The new issue is recognized as open. Strict Change validation separately passed (run `d4ba025e692441448eea0699bb2c540b`). Do not interpret successful route execution or strict record validation as a clean evolution report. No repair was attempted under the user's record-only instruction.

## Root Cause

Review/Replan policy requires reproducible fixed content and validated candidate application, while reusable mechanical support does not cover that whole path. Agents therefore implement part of the protocol ad hoc. Current Review snapshot validation establishes well-formed metadata, not independently verified content identity. The auxiliary script's non-idempotent write order compounds this gap but remains the agent's responsibility.

## Disposition

Rejected from this SDK Change. The user recorded the Review/Replan tooling gap and forbade Harness mutation here. Task 7.10 completed spec sync and the binding handoff without implementing snapshot tooling. This is not an Angelscript product defect and is not a successor-issue transfer; a later Harness Change may own reusable snapshot verification if authorized.

## Evidence

### Failure Evidence (RED)

Static source inspection only; no failing automated Harness test is claimed. The concrete observations are the early INDEX write and subsequent replacement assertions in prepare.py, and the reference/string checks in Harness.psm1. Ignored scratch files are not the durable evidence owner; this compact description and hashes preserve the observed input identity.

| Inspected file | SHA-256 |
| --- | --- |
| `Saved/TypePlanReview/run.py` | `ee518c46e8ba63f1909dadc94a92e8bd96d2b50d28acaf09fd7ea2d7ec249964` |
| `Saved/TypePlanReview/prepare.py` | `5c5d39a5c685c133c84b02e79855d98c1f9bb40057665bde060d5f7886e2bb4c` |
| `.agents/skills/harness/scripts/Harness.psm1` | `24c42e791e744b9a2446bc0db62336c25e5c5778a3987a589abe5e8888b467f1` |
| `.agents/skills/harness/references/review.md` | `8e589de6561a160769db24486744a58b89d5004752d944e48c85eb9adfe1e2e1` |
| `.agents/skills/harness/references/replan.md` | `03bb4592794670eb07ff9297d351e7adfb4968a7df0c93aa09af9b41366c0def` |

### Resolution Evidence (GREEN)

Not applicable. No Harness snapshot-tooling repair was authorized or implemented.

### Rejected Evidence

7.10 delivered synchronized specs and `external-types-handoff-v1` without changing Harness Review/Replan routes. The DAG is complete. Auxiliary TypePlanReview scripts remain ignored scratch, not a required producer of this Change.

### What This Proves

The inspected workflow requires some agent-authored mechanical orchestration; the specific scratch scripts are not safely replayable; the inspected snapshot check validates metadata format without verifying referenced content.

### What This Does Not Prove

No evidence of failed Harness command dispatch, invalid task parsing, corrupted final planning artifacts, product-code failure, or failure of every possible snapshot mechanism. The prior fixed snapshots were checked separately during the review. Candidate tooling scope remains a future design decision, not an approved implementation plan.

## Links

- [Initial review](../reviews/review-20260910-080251-type-plan-inline.md)
- [Final plan review](../reviews/review-20260910-080251-type-plan-rereview-inline.md)
- [Plan correction validation](../data/replan-20260910-080251-type-plan-review-validation.md)
