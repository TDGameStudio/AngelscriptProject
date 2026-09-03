---
replan_id: replan-20260903-122738-gate-review-by-incident-and-impact
status: applied
source: user
source_ref: "conversation: review only demonstrated major problems or broad-impact final scope, accept external agent Reviews, run reviewer subagents asynchronously, and retain detailed Review files"
scope: Review triggers, impact classification, asynchronous immutable snapshots, external intake, lifecycle metadata, verification, knowledge promotion, and closure
base_commit: 7f4e8667cf7a987111d8b3fc47da10401540ee90
base_tasks_sha256: 8a7d2a395f21b07ce5e6453198bae9159fd23f7675a0e8b1d887937d2a61abaf
result_tasks_sha256: eb7b304391bff63505f4554fe4ee7fb01c4aae4ab8ee0903c4e57586ddbf523d
created_at: 2026-09-03T12:27:38+08:00
resume_task: "4.8"
---

# Gate Review by Incident and Impact

## Trigger and Evidence

After Task 4.6 closed the marker/carryover Review, the elapsed-time retrospective showed that implementation and focused tests were short while immediate broad Review and subagent waiting dominated the small increment. The user required Review only for a demonstrated major problem, broad-impact final scope, or an explicitly user/agent-started Review; verified small low-impact changes must not create Review work. The user also required asynchronous reviewer subagents and retained detailed Review evidence. The pending promotion and closure tasks therefore no longer represented the accepted gate policy.

## Decision

Keep exactly three Review kinds: Incident, Final, and External. Incident Review is exceptional and evidence-gated. Final Review runs once after scope freeze only when actual impact crosses a public, cross-boundary, safety, compatibility/release, production-performance, or architectural boundary; low-impact work records `not required`. External Review is accepted input but never an automatic Replan. Reviewer subagents consume immutable snapshots asynchronously while the coordinator continues disjoint work. Review files have no line limit.

## Impact

- Completed Tasks `1.1` through `4.6`, both closed Reviews, the resolved recovery issue, and the promoted registration checkpoint remain valid.
- Pending Tasks `4.7` and `5.2` are superseded before execution.
- New tasks define and test Review policy, establish scope freeze, run one asynchronous Final Review for this broad-impact protocol change, promote reviewed knowledge, and close.
- The current Change is broad impact because it alters cross-capability Review, archive, and Goal completion behavior.

## Old Task Disposition

- `1.1`, `2.1`, `2.2`, `3.1`, `3.2`, `3.4`, `4.1`, `4.3`, `4.4`, `4.5`, `4.6`: preserved complete with original evidence.
- `4.7`: superseded before execution by `4.12`, which promotes marker/carryover and Review scheduling knowledge only after the new Final Review.
- `5.2`: superseded before execution by `4.8` through `4.12` and final closure `5.3`.

## Diff Snapshot

```text
base commit: 7f4e8667cf7a987111d8b3fc47da10401540ee90
affected status: task-owned Skill/OpenSpec paths are mixed staged/worktree; unrelated dirty paths and root README user hunks remain excluded
observed timing: marker implementation about 4-5 minutes; focused tests about 6 seconds; second reviewer dispatch/wait about 10-11 minutes

Task -: 4.7, 5.2
Task +: 4.8, 4.9, 4.10, 4.11, 4.12, 5.3

Edge -: 4.6 -> 4.7, 4.7 -> 5.2
Edge +: 4.6 -> 4.8, 4.8 -> 4.9, 4.9 -> 4.10, 4.10 -> 4.11, 4.11 -> 4.12, 4.12 -> 5.3

Artifact +: this Replan, one Review-scheduling talk, one change-local knowledge candidate, one future review-v2 Final Review, one future capability knowledge file
Artifact ~: Hardness Review/routing/closure contracts, reviewer and Verify/Archive Skills, attachment routing, proposal/design/specs, protocol tests, tasks.md, attachments/INDEX.md
```

## Preserved Work

- Strict pre-Change Explore and selective marker/carryover behavior.
- Both immutable approved Reviews and all prior verification evidence.
- Honest recovery chronology, resolved material issue, and promoted active-Change checkpoint.
- Unrelated user workspace changes, plugin/submodule state, `Tools/openspec`, binaries, UE work, and excluded README hunks.

## References and Result

- User source: current conversation decisions on major-problem Review, impact-gated Final Review, External Review, asynchronous subagents, and detailed Review records.
- Decision record: `attachments/talks/talk-20260903-122738-review-gate-scheduling.md`.
- Current plan: `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`.
- Result Task DAG SHA-256: `eb7b304391bff63505f4554fe4ee7fb01c4aae4ab8ee0903c4e57586ddbf523d`.
- Resume at Task `4.8`; stop at Final Review readiness before dispatching another reviewer.
