---
replan_id: replan-20260905-023915-source-manager-query-ownership
status: applied
source: implementation
source_ref: run-da205e15ecdf48cabbc10dd23d7ff3cc
scope: Task 1.2 source-manager query ownership
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: a369593e7d53d0d86e02412ad1a6c919d27aa2f5a263905a721dac1060d8e2e4
result_tasks_sha256: 79ef86ef46875fe1ec776de2be76f1e74cfbf7743f1958f525eaee311a2aa036
created_at: 2026-09-05T02:39:15+08:00
resume_task: 1.2
---

# Replan: let Task 1.2 own the SourceManager query facade

## Trigger and Evidence

The Task `1.2` RED introduced the required lazy line and provenance behavior through `asCSourceManager`, then build `da205e15ecdf48cabbc10dd23d7ff3cc` stopped at the intentionally missing provenance API. Reviewing the accepted design against the Task file list showed that snapshot/provenance storage alone cannot publish the required compilation-session query facade: the manager header and its uniquely named implementation must also change.

## Decision

Add `as_source_manager.h` and `as_frontend_source_manager.cpp` to Task `1.2` ownership. Keep storage and lazy publication in the snapshot, with manager methods providing owner-validated read-only queries.

## Impact

Only Task `1.2`'s declared file surface changes. Its behavior, verification command, dependency edges, public requirements, and production-isolation boundary remain unchanged.

## Old Task Disposition

Task `1.1` remains complete with valid build and four-scenario evidence. Task `1.2` remains incomplete and resumes from the expected missing-provenance RED.

## Diff Snapshot

- Task changes: two manager files added to Task `1.2`, plus one Replan context block.
- Edge changes: none.
- Requirements/design changes: none; the edit restores consistency with the already accepted SourceManager-facade decision.
- Implementation preservation: all Task `1.1` source and evidence remain valid.

## Preserved Work

The immutable source model, stable anchor API, applied unique-basename Replan, and existing four GREEN scenarios are retained. The five newly added RED scenarios define the next behavior without altering current production code.

## References and Result

- Expected RED: `Saved/Harness/Unreal/Runs/da205e15ecdf48cabbc10dd23d7ff3cc/Command.log`.
- Result: resume Task `1.2`, implementing snapshot-owned caches/graph and manager-owned query forwarding.

