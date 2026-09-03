# Explicit Review Intake and Direct Closure

## Rule

Hardness never starts Review automatically from incident severity, impact, task count, diff size, or ordinary verification. Review is an explicit user or external-agent request.

```text
local defect -----------------------> repair in current task -> verify
planning truth invalid ------------> replan -> implement -> verify
verified work, no explicit Review -> completed closure -> archive
user / external-agent Review ------> register -> triage -> resolve -> archive
```

## Direct closure

When tasks, verification, durable-spec sync, attachments, and closure evidence are complete and no explicit Review exists, archive directly. Do not create a placeholder Review, an impact classification, or a not-required Review record.

Evidence that invalidates a requirement, design boundary, verification contract, required artifact, or DAG edge triggers replan. Otherwise repair the local defect inside the current task and verify again.

## Explicit Review

When the user or an external agent explicitly requests Review, register one unique file and bind it to a materializable immutable snapshot. It may run asynchronously, but delegation is optional rather than a default workflow phase. Any registered Review must be closed or superseded before archive, with no open or deferred Critical or Required finding.

Review files have no line cap. Preserve specific findings, evidence, impact, resolution conditions, disposition, repair evidence, and re-review history. A finding is evidence to triage; only invalid planning truth triggers replan.

## Source

- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/knowledges/review-gate-scheduling.md`
- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/talks/talk-20260903-122738-review-gate-scheduling.md`
- User-directed Replan `remove-automatic-final-review` in `hardness/refactor-unified-workspace-core`.
