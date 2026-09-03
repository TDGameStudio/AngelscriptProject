# Exploration Marker Carryover

## Reusable Insight

- 💡 Knowledge candidate: Visual markers improve collaborative exploration when they annotate plain-language facts, decisions, recommendations, risks, and boundaries instead of acting as workflow state.
- 💡 Knowledge candidate: A decision-complete handoff can retain valuable exploration without retaining the transcript by classifying canonical truth, decision rationale, reusable insight, and discardable navigation separately.

## Evidence

- 📌 Pinned fact: The earlier marker vocabulary made structured question rounds visually scannable, but it was removed during Skill compression rather than replaced by an equivalent affordance.
- 📌 Pinned fact: Historical red/green status markers conflict with the repository's visual-risk legend and do not remain self-explanatory across contexts.
- 🔗 Source: `attachments/talks/talk-20260903-115455-exploration-marker-carryover.md` contains the option review and settled rationale.

## Boundaries

- Markers are optional presentation. Stable English labels, headings, schema fields, Task DAG state, and INDEX entries remain authoritative.
- Pre-Change Explore stays read-only. Talks and change-local knowledge are created only after the target Change exists.
- Canonical requirements, scope, architecture, and work remain in proposal/spec/design/tasks.
- Temporary questions, held/reopened navigation, redundant prose, and one-off visuals are discarded.
- Capability promotion requires verification and independent Review; archive never promotes automatically.

## Application

```text
accepted exploration item
  |-> changes current truth?       -> proposal/spec/design/tasks
  |-> prevents likely re-decision? -> indexed talk
  |-> reusable across work?        -> indexed change-local knowledge candidate
  `-> neither?                      -> discard
```

Preserve a table or text diagram only when it carries decision rationale or a reusable mental model. Prefer embedding it in the owning Markdown record so the attachment index and future context stay small.

## Sources

- `.agents/skills/openspec-explore/references/markers.md`
- `.agents/skills/openspec-explore/references/deep-exploration.md`
- `.agents/skills/openspec/references/attachments.md`
- `.agents/skills/openspec/references/knowledge.md`
