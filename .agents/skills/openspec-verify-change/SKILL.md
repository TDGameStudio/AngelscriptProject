---
name: openspec-verify-change
description: Verify an OpenSpec change against a fixed implementation snapshot for an Incident Review, scope-frozen Final Review, or External Review. Verification does not edit implementation.
---

# Verify a Change

Use the portable CLI through Hardness as defined by the `openspec` skill.

- Fix the reviewed state first with an immutable `snapshot_ref` that remains readable while the main thread continues; a digest of a moving dirty diff is not enough for asynchronous Review.
- Read proposal, relevant delta/current specs, design, tasks, and `attachments/INDEX.md`; open only linked evidence.
- Run `doctor`, strict change validation, task DAG validation, and the exact task verification commands appropriate to the gate.
- Compare observable implementation and tests to requirements. Review correctness, readability, architecture, security, and performance.
- Classify findings as Critical, Required, or Advisory. Include exact evidence, affected requirements/tasks, and a concrete resolution path.

```text
fixed snapshot
  -> artifact and DAG validation
  -> implementation/evidence comparison
  -> findings
  -> Hardness triage and resolution
  -> re-review
  -> close or supersede review
```

Automatic Review occurs only for a demonstrated major Incident Review and one Final Review after scope freeze when the completed Change has broad public, cross-boundary, security/destructive, compatibility/release, production-performance, or architectural impact. A verified small low-impact Change records `Final Review: not required` with rationale and creates no placeholder Review. The user or another agent may start an External Review at any time. Incident and External Reviews do not replace a required Final Review unless the assignment itself satisfies the frozen final scope and is recorded as `review_kind: final`. A report arriving does not complete the Review Gate.

Hardness should dispatch a reviewer subagent asynchronously when available. The reviewer may create or complete only its unique assigned Review file against the immutable snapshot; it must not edit code, planning artifacts, INDEX, implementation records, replans, or existing Reviews. The main thread may continue disjoint work, but knowledge promotion, closure, archive, and integration wait for the applicable gate.

A finding never directly triggers Replan. Hardness validates the snapshot/evidence and decides whether the current plan is actually invalid. Finish is blocked while any review is open or any Critical/Required finding lacks a resolution, evidence, re-review, and closure.
