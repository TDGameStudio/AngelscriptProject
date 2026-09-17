---
name: code-review
description: Fixed-snapshot senior review only when the user or an external agent explicitly requests an Incident, Final, or External Review. Owns the reviewer's stance; the coordinator's intake and triage live in harness/references/review.md. Never review routine task cadence.
---

# Code Review

- Review the explicitly assigned immutable snapshot against its requirements and verification evidence.
- Harness never starts this Skill solely because work is broad, high impact, or complete; only the user or an external agent explicitly requests a Review.
- Never follow a moving live workspace.
- Write only the newly assigned Review file; do not edit code, planning artifacts, task state, attachment indexes, Replans, implementation records, or earlier Reviews.
- Lifecycle, record schema, and triage belong to [review.md](../harness/references/review.md).

## Input contract

- The assignment must identify the requesting user or external agent, `review_kind: incident | final | external`, an immutable `snapshot_ref`, its digest, review scope, exclusions, the requirements or task cards under review, and the verification evidence already run.
- When any of these is missing, report the limitation in the Review and review what can be reviewed; do not guess the missing part.
- Existing records with `requested_by: hardness` remain historical input, but a new assignment cannot originate from Harness.
- If an External Review was started without a reproducible snapshot, say so explicitly; its findings remain input rather than a closed gate until Harness binds and reproduces them.

## How to read

- Read the tests and the task cards first, then the code.
  - Decide whether the tests prove the promised behavior before judging style.
- Stay read-only.
  - Inspect other revisions with `git show`, `git diff`, or a temporary worktree; never move `HEAD`, touch the index, or change branch state on the checkout you were given.
- Never dispatch another reviewer for part of the assignment or for a second opinion.
  - Splitting a snapshot by area is the coordinator's decision, made before assignment.
  - If one pass is too large, review in passes yourself and say so.
- Do not rerun broad gates already supplied as coordinator evidence unless the assignment requires it or a focused reproduction needs it.

## What to evaluate

- Correctness and edge/error behavior.
- Readability and maintainability.
- Architecture and project boundaries.
- Security and destructive/external effects.
- Performance and bounded resource use.
- Whether tests prove the promised behavior.
- Plan alignment: deviations from the requirement or task card, and whether they are improvements or departures.

## Findings

Use `Critical`, `Required`, or `Advisory` with fixed meaning:

- `Critical` — wrong behavior, data or safety loss, or a broken contract.
  - Blocks; must be resolved.
- `Required` — must be fixed before this Change closes but does not endanger the snapshot's correctness claim: architecture problems, a missing case, a test gap.
- `Advisory` — optional improvement.
  - May be deferred only with a named follow-up.

- Every finding includes file/line (or record/section for planning material), the original observation, impact, reproduction or evidence, and a concrete resolution condition, with status `open` initially.
- When the defect is in the requirement, design, or task card rather than the code, label it a planning finding so the coordinator can evaluate it separately.
- Do not prescribe Replan; the coordinator alone decides whether verified evidence invalidates the plan boundary.
- Not everything is Critical: categorize by actual effect, not by how much it annoyed you.

## Verified sound

- List what you checked and found acceptable — files, behaviors, test families — so a re-review can bound itself to the open findings and nobody re-reads what was already covered.
- This is a coverage statement, not praise.

## Verdict

- Be as detailed as the evidence requires; there is no report line limit.
- Record the actual `reviewed_at` completion time and close with a clear verdict and verification story.
- `APPROVE` requires no open Critical or Required finding.
- The Review may be performed inline or asynchronously; async is optional and never changes the immutable snapshot contract.
- Leave lifecycle closure to the coordinator; preserve finding text so later resolution and re-review can be appended under it according to [review.md](../harness/references/review.md).
