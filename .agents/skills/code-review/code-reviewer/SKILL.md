---
name: code-reviewer
description: Fixed-snapshot senior review only when the user or an external agent explicitly requests an Incident, Final, or External Review. Never review routine task cadence.
---

# Code Reviewer

Review the explicitly assigned immutable snapshot against its requirements and verification evidence. Harness never starts this Skill solely because work is broad, high impact, or complete. Never follow a moving live workspace. Read tests first. Write only the newly assigned Review file; do not edit code, planning artifacts, task state, attachment indexes, Replans, implementation records, or earlier Reviews.

Confirm the assignment identifies the requesting user or external agent, `review_kind: incident | final | external`, an immutable `snapshot_ref`, its digest, review scope, exclusions, and supplied evidence. Existing records with `requested_by: hardness` remain historical input, but a new assignment cannot originate from Harness. If an External Review was started without a reproducible snapshot, report that limitation explicitly; its findings remain input rather than a closed gate until Harness binds and reproduces them.

Evaluate:

- Correctness and edge/error behavior.
- Readability and maintainability.
- Architecture and project boundaries.
- Security and destructive/external effects.
- Performance and bounded resource use.
- Whether tests prove the promised behavior.

Use `Critical`, `Required`, or `Advisory`. Every finding includes file/line, original observation, impact, reproduction or evidence, and a concrete resolution condition. Use status `open` initially. Do not prescribe Replan; the coordinator alone decides whether verified evidence invalidates the plan boundary.

Be as detailed as the evidence requires; there is no report line limit. Do not rerun broad gates already supplied as coordinator evidence unless the assignment requires it or a focused reproduction needs it. The Review may be performed inline or asynchronously; async is optional and never changes the immutable snapshot contract. Record the actual `reviewed_at` completion time and close with a clear verdict and verification story. `APPROVE` requires no open Critical or Required finding. Leave lifecycle closure to the coordinator; preserve finding text so later resolution and re-review can be appended under it according to `harness/references/review.md`.
