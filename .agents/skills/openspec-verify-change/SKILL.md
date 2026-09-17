---
name: openspec-verify-change
description: Verify an OpenSpec change for completion or evaluate an explicitly requested immutable-snapshot Review. Verification does not edit implementation.
---

# Verify a Change

Use the portable CLI through Harness as defined by the `openspec` skill.

## Completion verification

- Use the Harness [impact-scoped verification policy](../harness/references/verification.md) to begin with the smallest task and owner checks that prove the final content identity. Expand only for the policy's concrete shared-impact, failure-evidence, release, or user-request reasons.
- Read proposal, relevant delta/current specs, design, tasks, and `attachments/INDEX.md`; open only linked evidence.
- For a marked new Change, run `harness.change.plan.verify` and inspect the root `design.md` `## Call chains` for real caller/callee coverage, source revision and dirty-path accuracy, or a justified `none` for non-code work. The structural gate cannot establish factual accuracy.
- When durable specs changed, load the [Specification and Scenario Card contract](../openspec/references/specs.md). Confirm every ordinary scenario has a clear `WHEN` and `THEN`; actively evaluate every new or modified behavior clause for the useful information in its clause-owned detail block, including useful prose, lists, examples, or tables; and accept omission only when a form adds no durable information. Verify each retained block is indented beneath the exact behavior item it qualifies, supports observable behavior rather than implementation steps, and survives synchronization in the complete Scenario Card. A `Verification` detail names a stable oracle or test family; it never substitutes for executed evidence.
- Run `doctor`, strict change validation and Task DAG validation. Establish each exact task proof for the final content identity; a fresh documented shared run with complete task-to-case mapping may supply it without repeating every subset command. Rerun stale or missing evidence and never extend an earlier binary's passing counts to changed source.
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

Rich Markdown ownership is part of the authoring contract: direct Task and behavior-clause detail uses four spaces, nested blocks keep their own container, and useful information may be extensive. Preserve complete clauses with their headings, code, tables, lists, quotes, links and images; never flatten a card to its main sentence. Judge literal cases, actual interfaces and observable acceptance decisions, not section presence or word count.
