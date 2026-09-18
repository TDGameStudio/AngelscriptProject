## Prepare after user convergence

- Load only when the user asks to converge a selected scope into creation or Replan. Do not offer this step merely because discussion appears complete.
- Explicit direct work needs no draft handoff. A direct creation/Replan still presents concrete reviewable handoff text and consumes the operation's explicit Gate.
- Write `designs/<scope>/handoff.md` in the draft language. Explain the problem/outcome, success criteria, evidence, boundaries, selected approach, relevant architecture, confirmed names, meaningful trade-offs and necessary proof.
- Resolve blocking design choices before the Gate. Keep accepted assumptions and excluded work explicit.
- Read [the handoff Gate explanation](../../harness/references/handoff-gate.md) when preparing the concrete Gate. Present the full background, current and proposed system, roles/terms/call paths, concrete changes, reasons, proof and handoff boundary in conversation for a reader unfamiliar with this system. A short summary or link to the handoff is not presentation.

## OpenSpec Handoff

- Use these exact identity labels for the selected scope and receiving Change:

```markdown
## OpenSpec Handoff

- Scope: <scope>
- Target Change: <domain>/<type>-<scope>-<outcome>
```

- For Replan, identify the existing target and what changes versus valid accepted work. Retain its execution return position.
- In new layouts, the scope's `design.md` owns metadata and vocabulary. A separate scope README or glossary is not required.
- Existing legacy layouts remain accepted inputs without migration; do not manufacture approval that their historical record does not contain.

## Exploration Carryover

- Identify the necessary design, handoff, research, decision rationale and reusable insight the target must retain. Explain what is carried and why while presenting the concrete handoff.
- Use exact Source / Target / Reason rows. Sources are relative to the selected design; targets are Change-relative.
- The required new-layout copies are design and handoff. Include a glossary only when one exists and is useful; vocabulary may remain in design.

```markdown
## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Selected scoped design and vocabulary |
| handoff.md | attachments/drafts/handoff.md | Scope and accepted handoff |
| ../../research/example.md | attachments/drafts/research/example.md | Required implementation evidence |
| ../../CONTEXT.md#decision-example | attachments/talks/talk-YYYYMMDD-HHmmss-example.md | Relevant confirmed decision rationale |
```

- Omit unused example rows. Include transitive source dependencies needed to understand the selected outcome; leave unrelated work and the conversation transcript local.
- Export current summaries in English with provenance, preserve identifiers and retain original local wording.
- Creation freezes the expected export list; `harness.change.seed.verify` checks copies, indexing and local link closure before planning.

## Explicit handoff Gate

- Prepare a read-only `PlanOnly` preview for creation or Replan after the selected material is concrete. Use the current `HandoffRevision`; do not reuse a decision for changed material.
- Collect the user's actual choice for this prepared operation. Offer creation/application, explanation of the current architecture with continued discussion, and other meaningful continuation only when it applies.
- A prior request to converge is the `ConvergenceSource`. The answer to this concrete Gate is the distinct `DecisionSource`.
- The operation consumes `Gate` with `ConvergenceSource`, `DecisionSource`, `Decision=create|replan`, exact `TargetChange` and current `HandoffRevision`.
- Returning to discussion leaves the target unchanged. Missing answers, silence, cancellation, an empty frontier or a recommendation never pass the Gate.
- Follow actual host permissions for collecting required choices; a clarification-only tool cannot be used as an approval tool.

## Follow-up after success

- After successful creation or application, the required `handoff-followup` asks draft disposition and execution timing.
- Draft disposition is `archive|retain`; use `not-applicable` only when no draft exists. Explain remaining scopes/open questions before a whole-topic archive choice.
- Execution disposition is `now|queue|later`. Record the actual schedule/continuation result before closing the follow-up.
- Retaining the draft is valid even after its selected scope is handed off. Archiving is a move with provenance, not a claim that all research was resolved.
- Do not begin implementation because creation/application succeeded while the required follow-up remains unsettled.
