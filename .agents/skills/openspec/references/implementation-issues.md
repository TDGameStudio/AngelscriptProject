# Material Implementation Issues

Load this reference only when implementation, verification, review repair, a dependency, or user evidence exposes a material technical problem. `attachments/implementation/` is issue-only; it is not an execution log or final-summary directory.

## Material threshold

Create or update an issue when any condition is true:

- work is blocked, or the failure repeats after a plausible correction;
- the non-obvious root cause requires investigation or an experiment;
- prior success evidence is invalid or was attributed to the wrong cause;
- the problem crosses a task, module, repository, or changes the implementation approach;
- a Critical or Required Review finding needs non-trivial repair;
- a deferred or superseded technical problem needs a durable handoff;
- a failed path is likely to recur unless its evidence is preserved.

Do not record a normal TDD RED, the first expected failure, a typo, formatting repair, obvious immediate correction, ordinary final success, or another symptom already covered by the same root cause. One root cause and its repair lifecycle produce one issue even when several tests or Review findings expose it.

## File and frontmatter

Use `implementation/issue-YYYYMMDD-HHmmss-<theme>.md` and update `attachments/INDEX.md` in the same edit.

```yaml
---
issue_id: issue-20260903-143000-example
status: open | resolved | superseded
source: implementation | verification | review | dependency | user
source_ref: task 2.1 | "reviews/review-...md#finding-1" | run-id
affected_tasks: ["2.1"]
created_at: 2026-09-03T14:30:00+08:00
resolved_at: 2026-09-03T15:20:00+08:00
resolution_ref: commit-or-evidence-reference
superseded_by: issue-or-change-reference
---
```

`issue_id` matches the filename stem. `source_ref`, `affected_tasks`, and `created_at` are always required. A resolved issue requires `resolved_at` and `resolution_ref`; a superseded issue requires `superseded_by`. Open issues omit status-specific closure fields.

## Body

```markdown
## Symptom
## Investigation Log
## Root Cause
## Disposition
## Evidence
### Failure Evidence (RED)
### Resolution Evidence (GREEN)
### Rejected Evidence
### What This Proves
### What This Does Not Prove
## Links
```

Keep observations chronological, then state one demonstrated root cause and disposition. `Rejected Evidence` is optional but records a short reason when evidence materially influenced and then lost the diagnosis. RED/GREEN entries cite the exact command plus a run ID, relative artifact, commit, or hash. For an unresolved or superseded issue, never invent GREEN evidence; state what remains pending and link the successor.

If closure-relevant raw output remains under ignored `Saved/`, retain a compact aggregate or hash in `data/` and link it from the issue. Evidence must say both what it proves and what it does not prove. Never add checkboxes; `tasks.md` remains the only execution state.
