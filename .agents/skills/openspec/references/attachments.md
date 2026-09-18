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
| Change created from a selected approved brainstorming design by `openspec-create-change` | `drafts/` | English exports of selected scoped `design.md` and `handoff.md`, optional terminology exports, and required `drafts/research/` or `drafts/attachments/` evidence closure (legacy findings retain compatibility mapping), each indexed once; the same step materializes the user-confirmed talks and knowledge candidates. The draft is local and git-ignored, so a Change never links into `openspec/drafts/`; all local originals remain there. |
| Explicit user- or external-agent-requested fixed-snapshot Review | `reviews/` | Reviewer writes only its unique file; coordinator owns registration, triage, and lifecycle state. |
| Material investigated technical or workflow problem | `implementation/` | One shared root cause and disposition lifecycle, including admitted dogfooding findings; never a final summary or second task list. |
| Interactive questioning or non-obvious technical decision | `talks/grill-*.md` or `talks/talk-*.md` | One planning record with current decisions/provenance; candidate design may live in a linked draft. Optional original recording is separate; approved exact truth enters through Replan. |
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
- Create Review records only after an explicit request from the user or an external agent. Harness never auto-starts Incident or Final Review based on risk, impact, diff size, or completion state.
- Incident, Final, and External remain `review-v2` report kinds selected by the requester; they are classifications, not automatic lifecycle gates.
- Bind every Review to an immutable, reproducible snapshot. An unbound external report remains open input until its snapshot is reproduced or it is superseded with rationale.
- A Review may run inline or asynchronously. Async is optional. The main thread may continue disjoint work, but cannot close or archive the reviewed work before its Review lifecycle resolves.
- A reviewer may edit only its unique Review file. It may not edit code, tasks, design, INDEX, implementation, replans, or existing Reviews.
- Review files have no line limit. Retain a detailed report with findings, evidence, impact, resolution conditions, disposition, repair evidence, and re-review history; a per-file manifest is optional rather than mandatory.
- A delivered report alone does not resolve its lifecycle. Triage each finding, fix local defects, and Replan only when evidence invalidates accepted planning truth.
- Verified work may close and archive directly with no Review record or not-required classification. If Review files exist, every one is closed or superseded and no Critical or Required finding is open or deferred. Advisory findings may defer with an explicit follow-up.

## Change discussions

- Use [discussion operations](../../harness/references/discussions.md) for `harness-talk-v1`, key decision questions, pending state, handoff arrangements and return position. Prefixes distinguish record form, not lifecycle.
- Change planning impact and return state stay in the Change; candidate design and key decisions may use a linked local draft before creation or during Replan, with no transcript dual-writing. Do not automatically duplicate a Grill as another Talk. Recognized original source frames retain their language; current summaries remain English.
- An open or settled current-scope discussion blocks implementation and closure. Only successful `harness.replan.apply` links and closes an applied decision. If recording was explicitly enabled, synchronize and unbind its sink before terminal evaluation/archive. A purpose-specific handoff-followup talk requires actual draft/execution arrangements, not a Replan or generic closure shortcut.

## Implementation issues and talks

- Use [implementation-issues.md](implementation-issues.md) only after a technical problem crosses its material threshold. `implementation/` is issue-only; final integration evidence, routine TDD cycles, closure preparation, and progress summaries belong in their owning task evidence, `data/`, Review, INDEX, or closure record.
- Ignored `Saved/Harness/Observations` records are inexpensive evidence, not durable owners. Automatically collect dogfooding evidence, then present a batch and obtain the user-selected repair scope before changing unrelated workflow policy. If it belongs to the authorized active scope and crosses the material threshold, admit it to one indexed `openspec-material-issue-v2` owner. Never create a successor automatically. Once admitted, it must become `resolved`, `rejected`, or `superseded`; free-floating deferral is not a terminal state.
- Non-obvious major decisions go to `talks/talk-YYYYMMDD-HHmmss-<theme>.md`, then lift the settled truth into proposal/spec/design before replan.

## Exploration carryover

Pre-Change brainstorming writes only to its draft under `openspec/drafts/<domain>/<topic>/`. The selected designs/<scope>/ handoff has the user confirm which decision rationale, useful visuals, and reusable evidence-backed insights the Change keeps; `openspec-create-change` materializes exactly that list once the target Change exists:

| Carryover | Destination | Admission boundary |
|---|---|---|
| Approved draft `design.md` and `handoff.md` | `drafts/design.md`, `drafts/handoff.md` | English exports indexed once, together with actually needed optional terminology, `drafts/research/` and `drafts/attachments/` dependencies. Copy English originals or faithfully translate other languages, including diagram explanations, preserving identifiers and source/approval provenance. The selected design metadata records `target_change`; all originals remain local. Change links resolve inside the Change; local draft/round provenance is plain text, never a dependency on an `openspec/drafts/` path. |
| Settled requirement, scope, architecture, or executable boundary | proposal/spec/design/tasks | Canonical current truth; do not leave it only in an attachment. |
| Non-obvious decision, dropped alternative, flip condition, or decision-critical visualization | `talks/talk-YYYYMMDD-HHmmss-<theme>.md` | Preserve only when the rationale prevents likely re-decision. |
| Evidence-backed insight or visualization reusable across tasks or later work | `knowledges/<theme>.md` | Change-local candidate; promotion still requires evidence, verification, and an explicit disposition. |
| Temporary question-round state, transcript prose, or one-off visual | discard from the Change | No durable decision or reuse value inside the Change; only key decisions need local CONTEXT; full original recording is optional. |

A carryover talk uses concise plain headings such as Context, Evidence, Options, Settled Decision, Consequences and Flip Condition, Visual, and Sources. A change-local knowledge candidate uses Reusable Insight, Evidence, Boundaries, Application, and Sources. Embed the smallest useful Markdown table or text diagram in the owning file; a separate visual file is allowed only when it is itself indexed exactly once.

Create the talk/knowledge file and update `attachments/INDEX.md` in the same edit; the INDEX summary states whether a knowledge candidate is `candidate`, `promoted`, `superseded`, or `retired`.

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
- A finding triggers Replan only after Harness proves a requirement, design, acceptance condition, task boundary, dependency edge, or completion evidence became invalid. Severity alone never triggers it.

## Other attachment types

- `knowledges/`: change-local reusable knowledge candidates, including accepted exploration insights that meet the carryover boundary. Apply the [knowledge promotion contract](knowledge.md) explicitly; archive never promotes them as a side effect.
- `scripts/`: one reusable purpose per script, with usage and dependencies in its header.
- `data/`: trimmed text-first evidence. Files over 100 KB or 1000 lines must be reduced with source run ID, trim rationale, and original line ranges.

Every Harness or OpenSpec self-hosting Change keeps one indexed canonical `data/workflow-evaluation.md` before completed closure. Its machine-readable header is:

```yaml
---
record: harness-workflow-evaluation-v1
result: passed | failed
change: harness/exact-change-id
closure_kind: completed | abandoned | superseded
input_sha256: <lowercase SHA-256 of all active Change inputs except this evaluation>
captured_at: 2026-09-03T18:00:00+08:00
---
```

The compact body records elapsed lifecycle stages, material friction, corrective actions, transferred/superseded owners, and raw-data provenance. The digest is derived from ordinal forward-slash relative paths plus raw bytes, length-framed for every ordinary file beneath the active Change except this evaluation. Obtain `CurrentInputSha256` from ordinary exact evolution status, then write the evaluation last. A later Change input edit makes it stale. Its `captured_at` cannot precede the latest terminal issue or Review event.

`harness.evolution.status` reads evaluation frontmatter, material-issue/Review frontmatter, and bounded active issue/Review section structure. It does not retain or return raw attachment bodies and does not replay ignored observation bodies. A parseable `failed` result remains inspectable but cannot pass terminal closure.

Before archive, trim data, decide knowledge promotion, close every existing active Review and v2 issue state, record spec-sync disposition, and provide the requested closure manifest. Active issues and Reviews are discovered recursively, require exact INDEX membership, and cannot use schema-less historical compatibility. Run `harness.evolution.status` for the exact active Change with its explicit `ClosureKind` and `RequireTerminal = $true`; ordinary status remains inspectable while evidence is incomplete, but the terminal call fails closed. After archive, use strict archived OpenSpec validation rather than rerunning active terminal policy. The portable CLI validates structural closure; the applicable Harness evolution/protocol checks supply attachment semantics.
