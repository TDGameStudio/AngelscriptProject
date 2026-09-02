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

Index every attachment file once. Update INDEX in the same change as a new attachment. It does not duplicate task state.

## Reviews

- Filename: `reviews/review-YYYYMMDD-HHmmss-<theme>-<reviewer>.md`.
- Review state: `open | closed | superseded`.
- Finding state: `open | resolved | rejected | deferred`.
- Each finding keeps its original text and records severity, fixed snapshot, evidence, affected requirement/tasks, disposition, appended resolution, and verification evidence.
- An external reviewer may create only its assigned review file against the fixed snapshot. It may not edit code, tasks, design, INDEX, implementation, replans, or existing reviews.
- A Review Gate is complete only after triage, resolution, re-review, and review closure. A delivered report is not a completed gate.
- Archive requires every review closed/superseded and no open/deferred Critical or Required finding. Advisory findings may defer with an explicit follow-up.

## Implementation issues and talks

- Filename: `implementation/issue-YYYYMMDD-HHmmss-<theme>.md`.
- State: `open | resolved | superseded`.
- Record symptom/source, chronological observations, root cause, disposition, RED/GREEN run evidence, and links. Do not add checkboxes.
- Non-obvious major decisions go to `talks/talk-YYYYMMDD-HHmmss-<theme>.md`, then lift the settled truth into design/spec before Replan.

Material lifecycle:

```text
review finding
  -> implementation issue
  -> talk (only for a non-obvious decision)
  -> current design/spec truth
  -> replan
  -> tasks.md
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

- `knowledges/`: currently valid reusable knowledge; promote explicitly, never as an archive side effect.
- `scripts/`: one reusable purpose per script, with usage and dependencies in its header.
- `data/`: trimmed text-first evidence. Files over 100 KB or 1000 lines must be reduced with source run ID, trim rationale, and original line ranges.

Before archive, trim data, decide knowledge promotion, close review/issue state, record spec-sync disposition, and provide the requested closure manifest.
