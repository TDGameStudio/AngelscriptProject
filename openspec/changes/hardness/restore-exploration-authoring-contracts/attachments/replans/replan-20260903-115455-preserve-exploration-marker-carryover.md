---
replan_id: replan-20260903-115455-preserve-exploration-marker-carryover
status: applied
source: user
source_ref: "conversation: restore and review the earlier openspec-explore emoji markers and preserve valuable exploration visuals/knowledge in talks and change-local knowledge"
scope: marker vocabulary, exploration handoff carryover, attachment routing, verification, expanded Review, knowledge promotion, and closure
base_commit: 7f4e8667cf7a987111d8b3fc47da10401540ee90
base_tasks_sha256: 5a3483b5d112b6018a1d891ca160061f543bcecb855d1eac4f7661ee8faaadc3
result_tasks_sha256: 87db5bc08e5b718942d04dcb6290cecafc8a868bb0e34fda27f835fb0dfb7023
created_at: 2026-09-03T11:54:55+08:00
resume_task: "4.4"
---

# Preserve Exploration Marker Carryover

## Trigger and Evidence

After Task 4.3 and the first independent Review, but before closure, the user requested restoration and review of the earlier `openspec-explore` emoji markers. The user also required valuable exploration knowledge and visualizations to survive Change creation in talks and change-local knowledge. Git history proves that commit `4129487f63fab930800a896ae7f932d7bd4e6e70` carried a 15-marker vocabulary and structured question-round template; the current `question-rounds.md` explicitly prohibited an emoji protocol. The accepted requirements and remaining closure task therefore became incomplete.

## Decision

Preserve the strict pre-Change, read-only Explore boundary. Restore a rationalized marker vocabulary as presentation metadata, classify durable carryover in the decision-complete handoff, and materialize selected talks/knowledge only after the target Change exists. Dogfood one talk and one change-local knowledge record, add regression assertions, obtain a new expanded fixed-snapshot Review, then promote the reusable rule and close. Do not copy transcripts or use emoji as machine state.

## Impact

- The completed recovery, protocol work, first Review, issue resolution, and active-Change knowledge remain valid.
- The first closed Review remains immutable evidence for its 29-entry snapshot but is no longer the final expanded gate.
- The pending closure Task 5.1 is superseded before execution.
- New permanent tasks own marker contracts, dogfood evidence/tests, expanded Review, post-Review promotion, and closure.

## Old Task Disposition

- `1.1`, `2.1`, `2.2`, `3.1`, `3.2`, `3.4`, `4.1`, `4.3`: preserved complete with their original IDs and evidence.
- `5.1`: superseded before execution by `4.4`, `4.5`, `4.6`, `4.7`, and final closure `5.2` because the user expanded the accepted behavior before archive.

## Diff Snapshot

```text
base commit: 7f4e8667cf7a987111d8b3fc47da10401540ee90
affected status: prior task-owned Skill/OpenSpec paths staged; unrelated workspace and mixed README user hunks preserved; new marker expansion not yet staged
historical source: 4129487f:.agents/skills/openspec-explore/markers.md and SKILL.md question-round template

Task -: 5.1
Task +: 4.4, 4.5, 4.6, 4.7, 5.2

Edge -: 4.3 -> 5.1
Edge +: 4.3 -> 4.4, 4.4 -> 4.5, 4.5 -> 4.6, 4.6 -> 4.7, 4.7 -> 5.2

Artifact +: references/markers.md, one talk, one change-local knowledge, expanded Review, capability exploration-carryover knowledge, this Replan
Artifact ~: proposal.md, design.md, delta/current hardness spec, tasks.md, attachments/INDEX.md, Explore/Continue/attachment/knowledge contracts, OpenSpec Skill tests
```

## Preserved Work

- The strict pre-target-Change Explore boundary and active Change checkpoint.
- All completed task evidence, resolved registration issue, and promoted registration knowledge.
- The first independent Review and its exact fixed-snapshot fingerprint.
- Passing PS7 Skill-only gates and all unrelated user workspace changes.

## References and Result

- User source: current conversation request for emoji marker preservation and talk/change-knowledge capture.
- Historical evidence: `4129487f63fab930800a896ae7f932d7bd4e6e70:.agents/skills/openspec-explore/markers.md`.
- Current plan: `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`.
- Result Task DAG SHA-256: `87db5bc08e5b718942d04dcb6290cecafc8a868bb0e34fda27f835fb0dfb7023`.
- Resume at Task `4.4`; strict validation follows the applied artifact update.
