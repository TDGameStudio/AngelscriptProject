# Attachments and Closure

Read this reference only when a current task creates, resolves, or archives an attachment.

## INDEX

`attachments/INDEX.md` is overwrite-style navigation, at most 120 lines:

```markdown
# INDEX

## Current position
<short resume context; tasks.md remains the execution truth>

## Hard conclusions
- <settled decision>

## Forbidden
- <failed path that must not be retried>

## Attachment index
- reviews/<file> — <summary> — <when to read>
```

Index every attachment file exactly once. Update INDEX in the same edit as creation, material status change, supersession, or resolution. It does not duplicate task state. Do not add parallel session-state files such as `*-next.md` or `*-leftover.md`, and do not use Markdown checkboxes outside `tasks.md` to track execution.

If INDEX would exceed 120 lines, merge or trim low-value detail and improve summaries; never raise the limit or create a second index.

## Event routing

| Event | Record | Boundary |
|---|---|---|
| Explicit user- or external-agent-requested fixed-snapshot Review | `reviews/` | Reviewer writes only its unique file; coordinator owns registration, triage, and lifecycle state. |
| Material investigated technical problem | `implementation/` | One shared root cause and repair lifecycle; never a final summary or second task list. |
| Non-obvious major decision | `talks/` | Promote settled truth into proposal/spec/design before replan. |
| Evidence proves the current plan invalid | `replans/` | Persist only the accepted applied semantic diff. |
| Reusable learning candidate | `knowledges/` | Change-local evidence until verification establishes whether it should be promoted, superseded, or retired. |
| Reusable helper | `scripts/` | One purpose with usage and dependencies in the header. |
| Benchmark, matrix, or trimmed output | `data/` | Text-first aggregate with source/run provenance. |

## Reviews

- Filename: `reviews/review-YYYYMMDD-HHmmss-<theme>-<reviewer>.md`.
- New records declare `review_schema: review-v2`, `review_kind: incident | final | external`, `requested_by: user | external-agent`, actual `assigned_at` / `reviewed_at` / `closed_at` lifecycle times, immutable `snapshot_ref`, `snapshot_sha256`, and verdict. Historical `requested_by: hardness` remains readable but is not written for new Reviews.
- Review state: `open | closed | superseded`.
- Finding state: `open | resolved | rejected | deferred`.
- Each finding keeps its original text and records severity, fixed snapshot, evidence, affected requirement/tasks, disposition, appended resolution, and verification evidence.
- Create Review records only after an explicit request from the user or an external agent. Hardness never auto-starts Incident or Final Review based on risk, impact, diff size, or completion state.
- Incident, Final, and External remain `review-v2` report kinds selected by the requester; they are classifications, not automatic lifecycle gates.
- Bind every Review to an immutable, reproducible snapshot. An unbound external report remains open input until its snapshot is reproduced or it is superseded with rationale.
- A Review may run inline or asynchronously. Async is optional. The main thread may continue disjoint work, but cannot close or archive the reviewed work before its Review lifecycle resolves.
- A reviewer may edit only its unique Review file. It may not edit code, tasks, design, INDEX, implementation, replans, or existing Reviews.
- Review files have no line limit. Retain a detailed report with findings, evidence, impact, resolution conditions, disposition, repair evidence, and re-review history; a per-file manifest is optional rather than mandatory.
- A delivered report alone does not resolve its lifecycle. Triage each finding, fix local defects, and Replan only when evidence invalidates accepted planning truth.
- Verified work may close and archive directly with no Review record or not-required classification. If Review files exist, every one is closed or superseded and no Critical or Required finding is open or deferred. Advisory findings may defer with an explicit follow-up.

## Implementation issues and talks

- Use [implementation-issues.md](implementation-issues.md) only after a technical problem crosses its material threshold. `implementation/` is issue-only; final integration evidence, routine TDD cycles, closure preparation, and progress summaries belong in their owning task evidence, `data/`, Review, INDEX, or closure record.
- Non-obvious major decisions go to `talks/talk-YYYYMMDD-HHmmss-<theme>.md`, then lift the settled truth into proposal/spec/design before replan.

## Exploration carryover

Pre-Change Explore remains read-only. Its accepted handoff may classify decision rationale, useful visuals, and reusable evidence-backed insights, but records are created only after the target Change exists:

| Carryover | Destination | Admission boundary |
|---|---|---|
| Settled requirement, scope, architecture, or executable boundary | proposal/spec/design/tasks | Canonical current truth; do not leave it only in an attachment. |
| Non-obvious decision, dropped alternative, flip condition, or decision-critical visualization | `talks/talk-YYYYMMDD-HHmmss-<theme>.md` | Preserve only when the rationale prevents likely re-decision. |
| Evidence-backed insight or visualization reusable across tasks or later work | `knowledges/<theme>.md` | Change-local candidate; promotion still requires evidence, verification, and an explicit disposition. |
| Temporary question-round state, transcript prose, or one-off visual | discard | No durable decision or reuse value. |

A carryover talk uses concise plain headings such as Context, Evidence, Options, Settled Decision, Consequences and Flip Condition, Visual, and Sources. A change-local knowledge candidate uses Reusable Insight, Evidence, Boundaries, Application, and Sources. Embed the smallest useful Markdown table or text diagram in the owning file; a separate visual file is allowed only when it is itself indexed exactly once.

Markers may improve scanning, but each line keeps a stable plain-text label and complete meaning without emoji. Markers never replace frontmatter, Task DAG, Review, issue, or INDEX state. Create the talk/knowledge file and update `attachments/INDEX.md` in the same edit; the INDEX summary states whether a knowledge candidate is `candidate`, `promoted`, `superseded`, or `retired`.

Material lifecycle:

```text
review or verification evidence
  -> local defect -> implementation issue only when material -> repair and evidence
  -> non-obvious decision -> talk -> current proposal/spec/design truth
  -> invalid plan boundary -> applied replan -> tasks.md
```

## Replans

- Flat path: `replans/replan-YYYYMMDD-HHmmss-<theme>.md`.
- Persist only an accepted and applied Replan; `status: applied`; immutable afterwards.
- Required frontmatter: `replan_id`, `status`, `source`, `source_ref`, `scope`, `base_commit`, `base_tasks_sha256`, `result_tasks_sha256`, `created_at`, `resume_task`.
- Body: Trigger/Evidence, Decision, Impact, Old Task Disposition, Diff Snapshot, Preserved Work, References/Result.
- Diff Snapshot records affected-path `git status --short`, `git diff --stat`, task `+/-/~`, DAG edge `+/-`, and artifact changes. Do not embed a full unified diff.
- Optional `data/replans/<id>-before.patch` is allowed only for small uncommitted text work that Git cannot recover. Never include binary, generated, large, or already committed content.
- A finding triggers Replan only after Hardness proves a requirement, design, acceptance condition, task boundary, dependency edge, or completion evidence became invalid. Severity alone never triggers it.

## Other attachment types

- `knowledges/`: change-local reusable knowledge candidates, including accepted exploration insights that meet the carryover boundary. Apply the [knowledge promotion contract](knowledge.md) explicitly; archive never promotes them as a side effect.
- `scripts/`: one reusable purpose per script, with usage and dependencies in its header.
- `data/`: trimmed text-first evidence. Files over 100 KB or 1000 lines must be reduced with source run ID, trim rationale, and original line ranges.

Before archive, trim data, decide knowledge promotion, close any existing Review and issue state, record spec-sync disposition, and provide the requested closure manifest. The portable CLI validates structural closure, not attachment semantics; the applicable Hardness/OpenSpec protocol gate supplies that evidence.
