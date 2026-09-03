---
name: openspec-update-change
description: Revise existing OpenSpec planning artifacts when scope, requirements, design, evidence, or the Task DAG changes. Use for an explicit plan update or an evidence-gated Harness replan; do not implement code in this skill.
---

# Update a Change

Use the portable CLI through Harness as defined by the `openspec` skill.

1. Select the explicit Change or resolve the canonical active Change in the selected workspace, then read `status --json`, the existing proposal/specs/design/tasks, and `attachments/INDEX.md`.
2. Load only the attachment or finding that triggered the update. Verify its snapshot and evidence before changing current truth.
3. Decide which artifacts are actually invalid. Revise in semantic order: proposal/scope, durable specs, design, then tasks.
4. For a replan, compute and validate the candidate artifacts and Task DAG before tracked writes. Then write one applied replan using the [attachment protocol](../openspec/references/attachments.md) and update INDEX.
5. Run strict change validation and report the new resume task. Do not edit implementation code here.

```text
finding or user intervention
  -> evidence and impact analysis
  -> preserve valid work
  -> update current artifacts
  -> record applied replan when the DAG changed
  -> resume apply or verify
```

An ordinary implementation defect stays in the current task/implementation issue. Use replan only when a requirement, design, acceptance condition, task boundary, dependency edge, or completion evidence is invalid.

Make in-scope technical updates autonomously, including during Codex `/goal` continuation. Codex `/goal` is external continuation, not a repository mode or workspace selector. Stop only when the update needs new authority or contradicts an explicit user decision. Task IDs remain permanent; completed tasks remain checked; follow-up work receives a new ID.
