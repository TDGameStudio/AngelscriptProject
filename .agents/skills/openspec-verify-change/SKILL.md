---
name: openspec-verify-change
description: Verify an OpenSpec change for completion or evaluate an explicitly requested immutable-snapshot Review. Verification does not edit implementation.
---

# Verify a Change

Use the portable CLI through Harness as defined by the `openspec` skill.

## Completion verification

- Read proposal, relevant delta/current specs, design, tasks, and `attachments/INDEX.md`; open only linked evidence.
- When durable specs changed, load the [Specification and Scenario Card contract](../openspec/references/specs.md). Confirm every ordinary scenario has a clear `WHEN` and `THEN`; every clause-owned detail block is indented beneath the exact behavior item it qualifies; its prose, lists, examples, or tables support observable behavior rather than implementation steps; and synchronization preserved each intended complete Scenario Card plus all unnamed current behavior. A `Verification` detail names a stable oracle or test family; it never substitutes for executed evidence.
- Run `doctor`, strict change validation, Task DAG validation, and the exact task verification commands appropriate to the completed scope.
- Compare observable implementation and tests to requirements, including correctness, maintainability, architecture, security, performance, and bounded side effects where relevant.
- Preserve exact commands, results, scope, exclusions, and content identity as completion evidence.

```text
verified scope
  -> local defect -> repair and verify inside the task
  -> planning-invalidating evidence -> Harness Replan
  -> otherwise -> direct closure and archive
```

Harness never auto-starts an Incident or Final Review. A completed Change does not need a Review file, impact classification, or not-required Review placeholder.

## Explicit Review

Enter Review only after an explicit user or external-agent request. Fix the reviewed state with an immutable `snapshot_ref` that remains readable independently of the live workspace; a digest of a moving dirty diff is not enough. Classify findings as Critical, Required, or Advisory, and include exact evidence, affected requirements/tasks, and a concrete resolution condition.

The Review may run inline or asynchronously. Async is optional. A reviewer may create or complete only its unique assigned Review file against the immutable snapshot; it must not edit code, planning artifacts, INDEX, implementation records, Replans, or existing Reviews. The main thread may continue disjoint work while an asynchronous Review runs.

A finding never directly triggers Replan. Harness validates the snapshot and evidence, fixes local defects, and Replans only when accepted requirements, design, Task DAG, verification contract, or another planning truth is invalid. Before archive, every existing Review is closed or superseded, with no open or deferred Critical or Required finding and with required resolution evidence retained.
