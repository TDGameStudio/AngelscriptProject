# Exploration Marker Carryover

## Question and Context

The user asked to restore the visually scannable emoji markers from the earlier `openspec-explore`, review whether each marker still makes sense, and preserve valuable exploration knowledge and visualizations in talks and change-local knowledge after Change creation.

## Evidence

- 📌 Pinned fact: Commit `4129487f63fab930800a896ae7f932d7bd4e6e70` contained a 15-marker vocabulary and structured question-round template.
- 📌 Pinned fact: The compressed current `question-rounds.md` explicitly prohibited a marker file, so the previous visual affordance had been removed rather than relocated.
- 📌 Pinned fact: The visual-explanation annotation contract uses red, yellow, and green circles for risk, cost, or heat; historical `🔴 Reopened` and `🟢 Landed` would conflict outside Explore.
- 🔗 Source: `4129487f63fab930800a896ae7f932d7bd4e6e70:.agents/skills/openspec-explore/markers.md` and `.agents/skills/visual-explain/ascii/marking-annotation.md`.

## Options

1. Restore all 15 markers with their historical global meanings. This preserves familiarity but retains ambiguous `✅`, an unexplained green dot, and cross-skill red/green conflicts.
2. Keep plain labels only. This is unambiguous but loses the fast visual scanning the user explicitly values.
3. Restore a rationalized, Explore-scoped vocabulary with required plain labels, separate durable markers from round-only navigation, and selectively carry accepted material into Change attachments.

## Settled Decision

- ✅ Settled: Use option 3 with 14 markers: ten core decision/evidence markers and four round-only navigation markers.
- ✅ Settled: Narrow `✅ Settled:` to accepted decisions; verification remains explicit plain text.
- ✅ Settled: Replace historical `🔴 Reopened` with `🔁 Reopened`.
- ❌ Dropped: Remove historical `🟢 Landed`; when a wait ends, use the resulting `📌 Pinned fact:`, an unlocked `✨ New:` branch, or the final `✅ Settled:` decision.
- 🚫 Out of scope: A repository-wide universal emoji state machine or any parser that derives workflow state from glyphs.

## Marker Review

| Marker | Disposition | Reason |
|---|---|---|
| 📌 `Pinned fact:` | Core | Separates investigated evidence from user preference. |
| ❔ `Open decision:` | Core, mostly conversational | Makes the decision frontier visible. |
| 👉 `Recommendation:` | Core | Keeps one opinionated answer and its reason easy to locate. |
| ❗ `Risk:` / `Flip condition:` | Core | Exposes the assumption that can reverse the choice. |
| ✅ `Settled:` | Core, narrowed | Means accepted decision only, never test status. |
| ❌ `Dropped:` | Core | Preserves a rejected path and why not to retry it. |
| 🚫 `Out of scope:` | Core | Distinguishes exclusion from rejection on merit. |
| 💡 `Knowledge candidate:` | Core | Identifies possible reuse without auto-promotion. |
| 🔗 `Source:` | Core | Keeps provenance adjacent to the claim. |
| 📁 `Affected paths:` | Optional core | Useful only when an exact file map changes the decision. |
| ⭐ `Heavyweight:` | Round-only | Signals that full comparison is required. |
| ✨ `New:` | Round-only | Marks a newly entered or unblocked branch. |
| ⏳ `Held:` | Round-only | Shows research or prerequisite waiting without durable state. |
| 🔁 `Reopened:` | Round-only | Avoids the visual-risk meaning of a red circle. |
| 🟢 historical `Landed` | Removed | A small green dot is ambiguous and overlaps settled/unblocked meanings. |

## Visual

```text
pre-Change Explore (read-only)
  -> marker-assisted questions, comparison, and small visuals
  -> accepted decision-complete handoff
  -> create target Change
       |-> proposal/spec/design/tasks: current settled truth
       |-> talks/: non-obvious decision rationale + decision-critical visual
       `-> knowledges/: reusable evidence-backed candidate + reusable visual
  -> verification + independent Review
  -> explicit capability knowledge promotion when reusable
```

## Consequences and Flip Condition

- ❗ Risk: Excessive markers become visual noise, so use at most one leading marker per line and keep every plain-text label.
- ❗ Flip condition: Revisit the scoped vocabulary only if a repository-wide marker contract is deliberately designed with visual-explanation legends and accessibility requirements together.
- 💡 Knowledge candidate: The handoff should classify carryover, but Explore must remain read-only and the full transcript must not become a second source of truth.

## Sources

- `.agents/skills/openspec-explore/references/markers.md`
- `.agents/skills/openspec-explore/references/deep-exploration.md`
- `.agents/skills/openspec/references/attachments.md`
- `.agents/skills/openspec/references/knowledge.md`
- `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/replans/replan-20260903-115455-preserve-exploration-marker-carryover.md`
