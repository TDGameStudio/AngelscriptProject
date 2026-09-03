---
name: openspec-explore
description: Investigate an unclear idea or design before a new feature, architecture refactor, or major behavior-change OpenSpec Change is created. Produce a decision-complete handoff; never invoke it after Change creation or for task-local implementation uncertainty.
---

# Explore Before an OpenSpec Change

Use this leaf only for deep discovery before creating a new OpenSpec Change. It turns an unclear product or architecture direction into a decision-complete handoff that Change creation, proposal, specs, design, and tasks can consume.

## Pass the Explore Gate

- Run deep exploration before `change create` for a new feature, architecture refactor, or major behavior change when no accepted decision-complete handoff exists.
- Skip it for a clear defect repair, mechanical documentation change, or an approved plan that is already ready to execute.
- Never invoke it after the target Change exists. Existing Change corrections belong to `openspec-update-change`; task-local technical uncertainty belongs to `openspec-apply-change`, with replan only when evidence invalidates current truth.

## Explore Read-Only

1. Classify the opening as a vague idea, specific problem, or material pre-creation choice.
2. Inspect facts before asking questions: current code, tests, records, documentation, and recent commits only as needed.
3. Shape scope, map integration points and hidden complexity, and compare the smallest viable options.
4. Recommend one option, explain why, and name the assumption that would change the recommendation.
5. Converge on a handoff with no blocking engineering decision left for Change planning.

Load [deep-exploration.md](references/deep-exploration.md) for the full investigation and handoff contract. Load [question-rounds.md](references/question-rounds.md) only during interactive planning when at least three dependent user-owned decisions remain. Load the optional [marker vocabulary](references/markers.md) only when a round, comparison, visualization, or handoff benefits from visual scanning.

```text
unclear direction
  -> evidence and scope
  -> viable options
  -> recommendation and flip condition
  -> decision-complete handoff
  -> create Change -> proposal/spec/design/tasks
```

Stay read-only. Do not create an OpenSpec record merely because exploration occurred. Once accepted and after the target Change is created, route settled scope to proposal, durable behavior to specs, non-obvious architecture to design, and executable boundaries to tasks. Carry only decision-critical rationale/visuals into indexed talks and reusable evidence-backed insights into indexed change-local knowledge; never copy the exploration transcript.

A Codex `/goal` invocation means external unattended continuation, not a repository mode or workspace selector. During that continuation, investigate and choose the best in-scope technical direction autonomously. Stop only for a true authority boundary: a product-goal change, destructive or external action outside scope, unavailable credentials, merge/push/publication without authority, or irreconcilable explicit instructions.
