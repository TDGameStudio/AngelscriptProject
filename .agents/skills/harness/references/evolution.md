# Feedback, improvement and update visibility

## Collect evidence automatically

- Use `harness.observe` for a concrete workflow defect, recurring friction, routing mistake, missing explanation, or tool contract gap. Include `Category`, bounded `Summary`, actual `SourceRef`; optionally `DedupKey`, `OwnerDraftId`, Change, stage, correlation and duration.
- Raw versioned JSON remains under ignored `Saved/Harness/Observations/`; old `Saved/Hardness/Observations/` stays readable. Group repeats with a stable problem-oriented key while preserving every occurrence. Do not turn every compile error, expected RED or user cancellation into a Harness issue.
- Mutation regenerates `INBOX.md` from raw observations plus immutable triage records. The Markdown is a readable projection, never an approval authority. `harness.evolution.status` with `InboxOnly=$true` and optional Limit is read-only; its Issues and Truncated fields disclose incomplete views.
- Collecting an observation grants no authority to edit unrelated Skills, introduce a new gate or create a successor Change. Continue the current in-scope task unless the finding blocks its actual contract.

## Keep capture local and conclusions durable

- `Saved/Harness/Observations/` owns raw occurrences, triage events and the derived inbox in the selected workspace. They survive a conversation ending, but are Git-ignored local files: a Git commit, another clone or a different workspace does not back them up or aggregate them. Do not delete or migrate earlier observations as routine cleanup.
- Keep synthetic observation-write measurements in an isolated fixture workspace, including when performance queries target an explicit real Change. Measure the real route there and retain benchmark results with the performance artifacts; a timing sample is not a user problem. Do not contaminate the real inbox and then try to clean up after the test.
- A draft owns unresolved design and key decisions, but drafts are also ignored. An admitted active-Change issue needs its indexed implementation attachment; completed direct maintenance belongs in the actual Skill/tool/test and any justified durable specification or capability knowledge. Promote the useful conclusion and evidence boundary, not the raw conversation or measurement stream.
- There is no Git-tracked global backlog for unowned feedback. Say so when the user needs cross-machine retention of pending items; do not promise that moving them to a draft or updating `updates.json` provides it. Choosing such a backlog is a separate storage decision, not a reason to invent a Change for every observation.

## Present a batch and apply the user's scope

- At an appropriate discussion point, group related problems, show a concrete example, impact, likely owning Skill/tool, proposed bounded repair and proving check. Explain what the candidate changes in future behavior before asking.
- Before describing a pending count as unresolved defects, read each candidate's category and exact source. Separate actual findings, synthetic probes and historical planning corrections. For an old linked issue, compare its exact observation/source identity with the final issue disposition, task and closure evidence; matching words or an archived directory alone do not prove resolution.
- Offer selected now, deferred or dismissed choices for the actual batch. Use `harness.evolution.triage` with exact `ObservationIds`, `Disposition=selected|deferred|dismissed`, actual `DecisionSource` and bounded `Scope`. Never infer selection from mere observation or repeated occurrence.
- Route the selected work by intent: authorized direct maintenance can be implemented directly; a substantial unresolved design enters the normal draft loop and user-led handoff Gates. Selection of the repair scope is not automatic approval of a new formal Change.
- Preserve raw evidence. After implementing the selected scope, record `Disposition=resolved`, `Result` and exact `Evidence`; this retains the original decision source and scope without asking again. A new recurrence is pending, even if earlier occurrences were resolved.
- Reconcile an authorized historical batch through the same selected-to-resolved record, naming the existing completion evidence and that this is state reconciliation, not a new repair or test run. Dismiss proven synthetic samples with their reason and preserve their raw files. Do not treat rejection from another Change's scope as proof the underlying problem was fixed.
- When a selected repair finishes, reconcile its exact observation IDs as part of the same closure. Report what was repaired, historically reconciled, excluded or left open; do not rely on a Change archive to update the inbox automatically.
- Corrupt records and unknown IDs are explicit errors. Triage is serialized and validated before publication; do not silently classify a partial batch.

## Publish a small update notice

- Update `harness/updates.json` after a verified workflow release: `revision`, `published_at`, human-readable `summary`, `affected_skills`. Describe changed user-visible behavior, not implementation trivia.
- `harness.status` reads only this file for update visibility. Missing/invalid metadata appears in `UpdatesIssue` without failing unrelated status. Show the relevant summary at entry/resume and when its revision changes, once per conversation version.
- No daemon, persistent seen registry, directory hashing or background notification framework is needed. Do not claim an external application was notified unless a real authorized integration sent it.

## Durable closure remains separate

- Exact Change `harness.evolution.status -RequireTerminal` checks its accepted TaskPlan, every attachment's exact INDEX membership and the 120-line limit, indexed issue/review lifecycles, current evaluation digest and closure disposition; use [closure](closure.md). The public archive operation enforces this same automatic check before moving the directory; it adds no user confirmation or global inbox scan.
- Raw observations are non-blocking until explicitly admitted as an issue owned by the authorized work. A post-archive discovery preserves the archive, enters the inbox/linked draft and awaits the normal user scope and handoff decisions. Never create a successor automatically.
