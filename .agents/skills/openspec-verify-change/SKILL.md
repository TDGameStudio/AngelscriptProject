---
name: openspec-verify-change
description: Verify an OpenSpec change against a fixed implementation snapshot for completeness, correctness, coherence, evidence, and close readiness. Use at planned high-risk gates, final review, or explicit user review; verification does not edit implementation.
---

# Verify a Change

Use the portable CLI through Hardness as defined by the `openspec` skill.

- Fix the reviewed state first: commit SHA plus dirty diff/hash when applicable.
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

Automatic reviews occur only at planned high-risk slice gates and the final gate, plus explicit user requests. A report arriving does not complete the Review Gate.

When Hardness assigns an external reviewer an output path, that reviewer may create only that new review file. It must not edit code, planning artifacts, INDEX, implementation records, replans, or existing reviews. Otherwise return the report without repository writes.

A finding never directly triggers Replan. Hardness validates the snapshot/evidence and decides whether the current plan is actually invalid. Finish is blocked while any review is open or any Critical/Required finding lacks a resolution, evidence, re-review, and closure.
