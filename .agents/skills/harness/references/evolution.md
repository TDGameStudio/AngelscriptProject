# Feedback, improvement and update visibility

## Collect evidence automatically

- Use `harness.observe` for a concrete workflow defect, recurring friction, routing mistake, missing explanation, or tool contract gap. Include `Category`, bounded `Summary`, actual `SourceRef`; optionally `DedupKey`, `OwnerDraftId`, Change, stage, correlation and duration.
- Raw versioned JSON remains under ignored `Saved/Harness/Observations/`; old `Saved/Hardness/Observations/` stays readable. Group repeats with a stable problem-oriented key while preserving every occurrence. Do not turn every compile error, expected RED or user cancellation into a Harness issue.
- Mutation regenerates `INBOX.md` from raw observations plus immutable triage records. The Markdown is a readable projection, never an approval authority. `harness.evolution.status` with `InboxOnly=$true` and optional Limit is read-only; its Issues and Truncated fields disclose incomplete views.
- Collecting an observation grants no authority to edit unrelated Skills, introduce a new gate or create a successor Change. Continue the current in-scope task unless the finding blocks its actual contract.

## Present a batch and apply the user's scope

- At an appropriate discussion point, group related problems, show a concrete example, impact, likely owning Skill/tool, proposed bounded repair and proving check. Explain what the candidate changes in future behavior before asking.
- Offer selected now, deferred or dismissed choices for the actual batch. Use `harness.evolution.triage` with exact `ObservationIds`, `Disposition=selected|deferred|dismissed`, actual `DecisionSource` and bounded `Scope`. Never infer selection from mere observation or repeated occurrence.
- Route the selected work by intent: authorized direct maintenance can be implemented directly; a substantial unresolved design enters the normal draft loop and user-led handoff Gates. Selection of the repair scope is not automatic approval of a new formal Change.
- Preserve raw evidence. After implementing the selected scope, record `Disposition=resolved`, `Result` and exact `Evidence`; this retains the original decision source and scope without asking again. A new recurrence is pending, even if earlier occurrences were resolved.
- Corrupt records and unknown IDs are explicit errors. Triage is serialized and validated before publication; do not silently classify a partial batch.

## Publish a small update notice

- Update `harness/updates.json` after a verified workflow release: `revision`, `published_at`, human-readable `summary`, `affected_skills`. Describe changed user-visible behavior, not implementation trivia.
- `harness.status` reads only this file for update visibility. Missing/invalid metadata appears in `UpdatesIssue` without failing unrelated status. Show the relevant summary at entry/resume and when its revision changes, once per conversation version.
- No daemon, persistent seen registry, directory hashing or background notification framework is needed. Do not claim an external application was notified unless a real authorized integration sent it.

## Durable closure remains separate

- Exact Change `harness.evolution.status -RequireTerminal` still checks its accepted TaskPlan, indexed issues/reviews, current evaluation digest and closure disposition; use [closure](closure.md).
- Raw observations are non-blocking until explicitly admitted as an issue owned by the authorized work. A post-archive discovery preserves the archive, enters the inbox/linked draft and awaits the normal user scope and handoff decisions. Never create a successor automatically.
