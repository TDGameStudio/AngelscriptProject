---
name: openspec-continue-change
description: Create the next missing planning artifact for an active project OpenSpec change. Use for proposal, optional specs/design, or required tasks; use openspec-update-change when an existing artifact must be revised.
---

# Continue a Change

1. Use the explicit Change or resolve the canonical active Change in the selected workspace. A new feature, architecture refactor, or major behavior change consumes the decision-complete exploration handoff accepted before this Change was created. Never invoke [`openspec-explore`](../openspec-explore/SKILL.md) after target Change creation; route corrections to existing planning truth through `openspec-update-change`. Clear fixes and mechanical documentation work may have skipped the pre-creation gate.
2. Call `openspec.status --change <id> --json` and select one missing artifact. Proposal and tasks are required; specs exist only for durable behavior; design exists only for non-obvious decisions.
3. Call `openspec.instructions <artifact> --change <id> --json`. Re-read its concrete context files. Apply context/rules as constraints, never copied prose.
4. Write one artifact to `writePath`; for a glob choose a concrete path permitted by `outputPattern`. Use the matching record/task reference from the `openspec` skill. When the selected artifact is `specs`, load the [Specification and Scenario Card contract](../openspec/references/specs.md), create deltas only for durable behavior, supply complete cards for named behavior, and keep simple scenarios free of unused optional detail.
5. If the accepted handoff contains `Exploration Carryover`, process it once only after the Change exists. Load the [attachment contract](../openspec/references/attachments.md) and [knowledge contract](../openspec/references/knowledge.md) only for qualifying candidates: index non-obvious decision rationale/visuals in `attachments/talks/`, index reusable evidence-backed insights/visuals in `attachments/knowledges/`, and discard temporary round state or transcript prose. This does not relax the one-workflow-artifact step.
6. Run strict change validation and report the next ready artifact.

```text
status -> instructions -> one concrete artifact -> strict validate
```

Fast-forward through all missing planning artifacts only when implementation was requested or a Codex `/goal` continuation already carries an approved objective and decision-complete handoff. During unattended continuation, settle in-scope technical choices autonomously. Codex `/goal` is not a repository mode or workspace selector. Do not hand-create manifest files, write implementation code, or replace existing artifacts in this skill.
