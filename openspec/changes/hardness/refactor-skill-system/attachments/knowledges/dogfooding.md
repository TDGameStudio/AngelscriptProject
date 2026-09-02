# Dogfooding the Harness

## Purpose

Use Hardness and the portable OpenSpec package to implement, verify, review, and close changes to Hardness and OpenSpec themselves. Self-hosting is an acceptance technique: the same public routes, records, and gates used by plugin work must survive their own evolution.

## Evidence flow

```text
real harness run
  -> reproducible observation
  -> classify the boundary
  -> regression test or fixed-snapshot review
  -> repair or Replan
  -> re-review
  -> promote only the reusable invariant
```

- A defect inside an existing requirement stays in the current task or a material implementation issue.
- A Review finding is triaged; severity never triggers Replan by itself.
- Evidence that invalidates a requirement, acceptance command, task boundary, dependency edge, or required artifact triggers one applied Replan.
- A problem that requires new authority stops; an in-scope technical problem is resolved autonomously.

## What dogfooding must pressure

- Canonical change identity and discoverability.
- Task DAG parsing, readiness, completed-task preservation, and closure ordering.
- Workflow template and prompt-language behavior.
- Review resolution, independent re-review, and immutable release snapshots.
- PowerShell 5.1/7 module reuse and structured failure envelopes.
- Workspace physical containment, submodule exactness, and destructive-operation refusal.

Do not turn one incident into a universal rule. Preserve incident detail in its Review or implementation attachment; capability knowledge keeps only the generalized behavior that remains true after repair.
