# Replan Protocol

## Establish the invalidated boundary

- Replan only when verified evidence makes the current plan false: a requirement or design boundary changed, a task dependency became invalid, a verification contract is wrong, or a required artifact no longer represents current truth. A user-owned decision that the accepted plan never settled also returns through Update. A user idea, agent discovery, subagent report, or review finding is evidence to triage, not an automatic Replan.
- A pending task whose concrete scope now contains independently acceptable products, hidden prerequisite interfaces or a proving command that cannot cover its outcome has an invalid task boundary. Repeated independently verified partial deliveries under one permanently pending node are evidence to inspect that boundary, not a numeric trigger.
- Split the remaining outcomes, preserve completed work and map existing evidence without claiming it proves newer code. Shared files constrain scheduling; do not invent dependency edges solely to order writers. Ordinary failed assertions and routine RED/GREEN remain task-local.

- Expand the affected decision tree in a linked local draft before revising accepted truth. Independent `grill` explains the current architecture after every user answer and asks the next frontier; the Change talk retains impact/provenance/return state. Necessary unanswered choices pause the whole Change.
- Only user-led convergence enters candidate preparation and the exact-revision Replan Gate. Keep accepted planning files intact while discussing; see [Update](../../openspec-update-change/SKILL.md) for the owning lifecycle.

## Prepare the candidate without changing accepted planning

- Capture `base_commit`, the current `tasks.md` SHA-256, affected `git status`, and diff stat.
  - `base_commit` identifies the canonical record repository at `Context.OpenSpecRoot`. A replica has no root Git HEAD: also cite its indexed execution checkpoint, which captures each plugin baseline/current HEAD and host file hashes. Record affected plugin status/diff separately; never substitute one arbitrary plugin HEAD for the canonical record commit.
- Verify the source evidence and classify the impact. Preserve valid work. Resolve non-obvious major decisions in `attachments/talks/`; record material implementation problems in `attachments/implementation/`.
- Build complete candidate text in semantic order: proposal/scope, specs, design, then tasks. These are candidate contents for the map, not edits to the accepted files. Preserve permanent task IDs and completed work; assign new IDs to new work.
- Supply `Candidates` as Change-relative planning paths to complete UTF-8 text. Supply `ExpectedHashes` for the existing candidate targets and current `tasks.md`, using null for a new file. Compute and validate the candidate DAG without publishing accepted planning writes.
- Preview through `harness.replan.apply` with `PlanOnly=$true` and the exact Change/TalkId/SessionId/ExpectedRevision/ReplanId, candidate/hash maps, return task, draft scope or direct handoff, and `GitPlan`. GitPlan supplies the canonical Change-directory scope and concrete CommitMessage; the actual selected commit contains changed candidates and generated provenance only. Baseline/branch and this Git intent are part of the explained revision.
- Present the full [handoff Gate explanation](handoff-gate.md), including accepted plan, actual implementation and proposed revision. Ask the exact-revision Gate through the permitted host mechanism; see [discussion operations](discussions.md). The preview and user convergence do not themselves approve application.

## Apply, persist the approved map and arrange the return

- Submit the same candidate/baseline map and ReplanId to `harness.replan.apply` with the actual approved Gate provenance. A changed material candidate or baseline requires a fresh preview and decision.
- Let the transaction stage and validate candidates, check baselines, journal and write accepted artifacts, verify the resulting DAG, and create one immutable applied record and its follow-up talk. Do not separately overwrite proposal/spec/design/tasks or hand-write a second applied record.
- Persist those formal changes through the exact normal-hook Git candidate before the arrangement Gate. A failed commit leaves planning-applied/commit-pending; status blocks implementation even if arrangement answers exist. Retry the same ReplanId, map and actual Gate without another applied receipt or duplicate commit. Existing implementation remains uncommitted for continued work; Replan does not checkpoint or withdraw it.
- Use the same ReplanId on retry; status is read-only and does not replay an interrupted transaction. Investigate an external conflict rather than overwriting it.
- Successful application opens the mandatory draft/execution arrangement Gate before any resume at `resume_task`. Record and apply that arrangement, preserving the authorized return position. No settled discussion or old execution request bypasses either Gate.

## Keep the applied evidence

- Store records flat under `attachments/replans/`:

```text
replan-YYYYMMDD-HHmmss-<theme>.md
```

- Required frontmatter:

```yaml
---
replan_id: replan-YYYYMMDD-HHmmss-theme
status: applied
source: user | agent | subagent | implementation | verification | review | dependency
source_ref: <record, task, command, or message reference>
scope: <short affected boundary>
base_commit: <git sha>
base_tasks_sha256: <sha256>
result_tasks_sha256: <sha256>
created_at: <ISO-8601 timestamp>
resume_task: <X.Y>
---
```

- Use these short sections: Trigger and Evidence; Decision; Impact; Old Task Disposition; Diff Snapshot; Preserved Work; References and Result. The Diff Snapshot contains affected path status, diff stat, Task `+/-/~`, edge `+/-`, and artifact `~` changes. It does not embed a full unified diff.

- Keep the applied record focused on the actual decision and evidence; preserve useful detail without a fixed line quota. Put detailed analysis in implementation or talk attachments.
- A sidecar patch is allowed only at `attachments/data/replans/<id>-before.patch` when uncommitted local text cannot be recovered from Git; never store binary, generated, large, or otherwise recoverable patches. Applied records are immutable.
