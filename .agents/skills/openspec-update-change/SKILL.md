---
name: openspec-update-change
description: Revise existing OpenSpec planning artifacts when scope, requirements, design, evidence, or the Task DAG changes. Use for an explicit plan update or an evidence-gated Harness replan; do not implement code in this skill.
---

# Update a Change

Use the portable CLI through Harness as defined by the `openspec` skill.

1. Select the explicit Change or resolve the canonical active Change in the selected workspace, then read `status --json`, the existing proposal/specs/design/tasks, and `attachments/INDEX.md`.
2. Inspect the triggering evidence and expand every affected decision: scope, behavior, interfaces, dependencies, failures and acceptance. Retain valid prior decisions with reasons. Record the current discussion through `harness.talk.create/update`; interactive rounds use a `grill-` prefix.
3. Resolve the decision frontier with [grill](../grill/SKILL.md) when user-owned choices remain. Necessary unanswered questions pause the whole Change; read-only investigation may continue. Once settled, decide which artifacts are actually invalid. Revise in semantic order: proposal/scope, durable specs, design, then tasks. When Requirement or Scenario behavior changes, load the [Specification and Scenario Card contract](../openspec/references/specs.md), actively evaluate every modified behavior clause, and retain the useful information in its clause-owned detail block, including useful prose, lists, examples, or tables. A same-name Scenario delta supplies the complete Scenario Card so synchronization cannot silently lose or detach still-valid detail; omit a form when it adds no durable information. Adding useful Scenario detail alone does not trigger Replan unless evidence also invalidates accepted planning truth.
4. Build complete candidate artifacts and capture baseline hashes, then call `harness.replan.apply` with the settled talk revision. The route validates the staged plan and journals the applied update; see [discussion operations](../harness/references/discussions.md). Design/spec-only changes also receive an applied record.
5. Return the validated resume task to Apply or verification and continue the authorized execution request. Do not edit implementation code inside Update.

```text
finding or user intervention
  -> evidence and impact analysis
  -> preserve valid work
  -> update current artifacts
  -> record the actually applied planning change
  -> resume apply or verify
```

An ordinary implementation defect stays in the current task/implementation issue. Use replan only when a requirement, design, acceptance condition, task boundary, dependency edge, or completion evidence is invalid.

- Make evidence-backed in-scope decisions autonomously. Attended user-owned choices use Grill in the current session; unattended choices remain open in the talk, never in an applied Replan.
- A settled discussion is not yet an applied plan. Resume after successful application; no extra generic approval or next-session ceremony is required.
- Task IDs remain permanent, completed tasks remain checked, and follow-up work receives a new ID.

Rich Markdown ownership is part of the authoring contract: direct Task and behavior-clause detail uses four spaces, nested blocks keep their own container, and useful information may be extensive. Preserve complete clauses with their headings, code, tables, lists, quotes, links and images; never flatten a card to its main sentence. Judge literal cases, actual interfaces and observable acceptance decisions, not section presence or word count.
