# Replan Protocol

Replan only when verified evidence makes the current plan false: a requirement or design boundary changed, a task dependency became invalid, a verification contract is wrong, or a required artifact no longer represents current truth. A user idea, agent discovery, subagent report, or review finding is evidence to triage—not an automatic Replan.

## Apply atomically

1. Capture `base_commit`, the current `tasks.md` SHA-256, affected `git status`, and diff stat.
2. Verify the source evidence and classify the impact. Preserve valid work.
3. Resolve non-obvious major decisions in `attachments/talks/`; record material implementation problems in `attachments/implementation/`.
4. Update proposal/spec/design current truth before changing tasks.
5. Compute and validate the candidate DAG before tracked writes.
6. Write one immutable applied record, update `tasks.md`, verify the new DAG, then resume at `resume_task`.

Store records flat under `attachments/replans/`:

```text
replan-YYYYMMDD-HHmmss-<theme>.md
```

Required frontmatter:

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

Use these short sections: Trigger and Evidence; Decision; Impact; Old Task Disposition; Diff Snapshot; Preserved Work; References and Result. The Diff Snapshot contains affected path status, diff stat, Task `+/-/~`, edge `+/-`, and artifact `~` changes. It does not embed a full unified diff.

Keep a typical record within 120 lines. Put detailed analysis in implementation or talk attachments. A sidecar patch is allowed only at `attachments/data/replans/<id>-before.patch` when uncommitted local text cannot be recovered from Git; never store binary, generated, large, or otherwise recoverable patches. Applied records are immutable.
