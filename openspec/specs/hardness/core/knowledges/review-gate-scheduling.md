# Review Gate Scheduling

## Rule

Review is triggered by demonstrated incident severity, broad final impact, or explicit external intent—not by task count, diff size, or small-change cadence.

```text
demonstrated major incident --------> Incident Review
scope freeze + broad impact --------> Final Review
scope freeze + verified low impact -> Final Review: not required
user / other agent request ---------> External Review
```

## Final Ordering

Final Review is the last semantic gate. Before assignment, complete every implementation, document, specification, test, script, planned capability-knowledge output, proving verification result, accepted Replan, queued user change, and closure input. After assignment, only the assigned Review lifecycle, Task/attachment-INDEX bookkeeping, and deterministic closure/archive metadata or move may follow without re-freeze.

If any deliverable content changes, retain the report as evidence for its immutable snapshot, batch all late changes, and run one incremental Final Review after the next scope freeze.

## Asynchronous Review

Give the reviewer subagent an immutable `snapshot_ref`, digest, scope, exclusions, requirements, and existing verification evidence. The reviewer reads that snapshot rather than a moving workspace and writes only its unique Review file. The coordinator may continue disjoint work but cannot claim completion, integrate, or archive before the applicable gate closes.

Review files have no line cap. Preserve specific findings, evidence, impact, resolution conditions, disposition, repair evidence, and re-review history. Reduce elapsed time by avoiding premature dispatch and duplicate broad scans, not by deleting useful detail.

## Source

- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/knowledges/review-gate-scheduling.md`
- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/talks/talk-20260903-122738-review-gate-scheduling.md`
