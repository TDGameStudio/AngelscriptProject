---
name: openspec-update-change
description: Revise existing OpenSpec planning artifacts when scope, requirements, design, evidence, or the Task DAG changes. Use for an explicit plan update or an evidence-gated Harness replan; do not implement code in this skill.
---

# Update a Change

Use the portable CLI through Harness as defined by the `openspec` skill.

1. Select the explicit Change or resolve the canonical active Change in the selected workspace, then read `status --json`, the existing proposal/specs/design/tasks, and `attachments/INDEX.md`.
2. Load only the attachment or finding that triggered the update. Verify its snapshot and evidence before changing current truth.
3. Decide which artifacts are actually invalid. Revise in semantic order: proposal/scope, durable specs, design, then tasks. When Requirement or Scenario behavior changes, load the [Specification and Scenario Card contract](../openspec/references/specs.md), actively evaluate every modified behavior clause, and retain the useful information in its clause-owned detail block, including useful prose, lists, examples, or tables. A same-name Scenario delta supplies the complete Scenario Card so synchronization cannot silently lose or detach still-valid detail; omit a form when it adds no durable information. Adding useful Scenario detail alone does not trigger Replan unless evidence also invalidates accepted planning truth.
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

Make in-scope technical updates autonomously, attended or unattended. When the replan finding is a user-owned decision (product scope, behavior the design never settled, a public name the user would want to choose), record it in the replan record as an open decision with the agent's recommendation and stop there; the user answers it through a `brainstorming` grill round in the next attended session, and only then does the plan advance. Otherwise stop only when the update needs new authority or contradicts an explicit user decision. Task IDs remain permanent; completed tasks remain checked; follow-up work receives a new ID.

Rich Markdown ownership is part of the authoring contract: direct Task and behavior-clause detail uses four spaces, nested blocks keep their own container, and useful information may be extensive. Preserve complete clauses with their headings, code, tables, lists, quotes, links and images; never flatten a card to its main sentence. Judge literal cases, actual interfaces and observable acceptance decisions, not section presence or word count.
