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
- dogfooding exposes a material Harness/OpenSpec workflow gap that otherwise exists only in conversation, ignored observations, or a final handoff.

Do not record a normal TDD RED, the first expected failure, a typo, formatting repair, obvious immediate correction, ordinary final success, or another symptom already covered by the same root cause. One root cause and its repair lifecycle produce one issue even when several tests or Review findings expose it.

## File and frontmatter

Use `implementation/issue-YYYYMMDD-HHmmss-<theme>.md` and update `attachments/INDEX.md` in the same edit.

```yaml
---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260903-143000-example
status: open | resolved | rejected | superseded
source: dogfooding | implementation | verification | review | dependency | user
source_ref: task 2.1 | "reviews/review-...md#finding-1" | run-id
affected_tasks: ["2.1"]
created_at: 2026-09-03T14:30:00+08:00
resolved_at: 2026-09-03T15:20:00+08:00
resolution_ref: commit-or-evidence-reference
superseded_by: harness/successor-change#issue-20260903-160000-successor
---
```

New active records use `issue_schema: openspec-material-issue-v2`; historical records without `issue_schema` remain readable only as immutable archive evidence and are not rewritten. `issue_id` matches the filename stem. `source_ref`, `affected_tasks`, and `created_at` are always required. Each active `affected_tasks` value resolves to an exact task in the current portable TaskPlan, and terminal timestamps cannot precede creation.

- `open` is the only non-terminal v2 state and omits every status-specific closure field.
- `resolved` means the issue was repaired; it requires `resolved_at` and an exact `resolution_ref`.
- `rejected` means an evidence-backed decision deliberately did not implement the finding; it also requires `resolved_at` and an exact decision/evidence `resolution_ref`.
- `superseded` requires `resolved_at` and `superseded_by`. The latter names one active, indexed, non-superseded v2 owner as `<domain>/<change>#<issue-id>`; it cannot self-reference or form a direct cycle. The target's `source_ref` reciprocally names the source as `issue:<domain>/<change>#<issue-id>`, and its task references resolve in the target TaskPlan.

During active work, an open v2 issue is structurally valid. Before any archive closure kind, `harness.evolution.status` with the exact active Change, explicit `ClosureKind`, and `RequireTerminal = $true` must pass. It discovers `attachments/implementation/**/issue-*.md` recursively and rejects schema-less active records, open or malformed v2 records, unknown TaskPlan IDs, invalid timestamp order, incomplete required body sections, invalid successor ownership, invalid INDEX membership, and missing, stale, invalid, or failed canonical workflow evaluation. It transiently scans bounded section structure without retaining or returning raw bodies, and it never turns raw observations into issues automatically.

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

Admission does not start Review or Replan. Review remains user/external-agent requested. Replan occurs only when evidence invalidates accepted requirements, design, task boundaries, dependency edges, or completion evidence; otherwise resolve, reject, or supersede the issue inside the current plan.
