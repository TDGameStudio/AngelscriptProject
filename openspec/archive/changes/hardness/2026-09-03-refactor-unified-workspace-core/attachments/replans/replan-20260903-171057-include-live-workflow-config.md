---
replan_id: replan-20260903-171057-include-live-workflow-config
status: applied
source: verification
source_ref: "Task 1.3 live prompt audit: rg Goal mode|Current mode openspec/config.yaml"
scope: live OpenSpec workflow prompt alignment in Task 2.1
base_commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
base_tasks_sha256: 789eec7643e7f2157c0f606fe6ce47144edef99fcc6e57414437d69a81e648e0
result_tasks_sha256: 66a5b16601eb1a4c18c3d755a72a7671916268c1c9db3224cda0f6bc6f192bf6
created_at: 2026-09-03T17:10:57+08:00
resume_task: "2.1"
---

# Include the Live Workflow Configuration

## Trigger and Evidence

After the mode-free context passed its focused gate, a live prompt audit found that `openspec/config.yaml` still instructed agents to act "In Goal mode" and to route builds through root `Tools`. Task 2.1 already owned authoring and routing alignment but omitted this active prompt source from its declared Files. Leaving it out would make the accepted no-mode contract false at runtime.

## Decision

Add `openspec/config.yaml` to Task 2.1. Align its operations guidance with exact WorkspaceRoot selection, autonomous in-scope repair, Hardness routing after the temporary Skill restriction is lifted, and the retained `Tools/openspec` exception. Do not change the Task DAG, OpenSpec parser, source submodule, or packaged executable.

## Impact

- Tasks 1.1, 1.2, and 1.3 remain complete with their focused verification evidence.
- Task 2.1 gains one live configuration file before implementation begins.
- Its acceptance command and all dependency edges remain valid.
- No plugin, Unreal leaf implementation, integration, push, worktree removal, or binary update enters this Change.

## Old Task Disposition

- `1.1`: preserved complete.
- `1.2`: preserved complete.
- `1.3`: preserved complete.
- `2.1`: preserved pending; file boundary corrected before execution.
- `3.1`, `3.2`, `3.3`, `4.1`: preserved pending.

## Diff Snapshot

```text
base commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
affected status: workspace-lifecycle, git-operations, hardness, and this active Change only; openspec/config.yaml was unchanged when evidence was captured
affected implementation diff stat: 17 files, 1259 insertions, 749 deletions before this Replan

Task ~: 2.1 Files adds openspec/config.yaml
Task state ~: 1.2 and 1.3 record their completed focused gates
Edge +/-: none
Artifact +: this Replan
Artifact ~: tasks.md, attachments/INDEX.md
```

## Preserved Work

- The Git-derived workspace lifecycle and AgentConfig v2 migration.
- Exact-root Git commit/integration/push contracts and resumable integration repair.
- The mode-free Hardness context, routes, observations, maintenance status, and focused passing gates.
- All unrelated main-workspace edits and every deferred Unreal, plugin, binary, integration, push, and cleanup boundary.

## References and Result

- Accepted design: `design.md`, sections 1 through 8.
- Live prompt source: `openspec/config.yaml`.
- Result Task DAG SHA-256: `66a5b16601eb1a4c18c3d755a72a7671916268c1c9db3224cda0f6bc6f192bf6`.
- Resume at Task `2.1`.
