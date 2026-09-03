# Question Rounds

Use question rounds only during interactive pre-change work when at least three dependent decisions genuinely belong to the user. Never use them for unattended Codex `/goal` continuation or task-local implementation uncertainty; `/goal` is not a repository mode.

## Before a round

- Investigate repository facts first.
- Separate user-owned product choices from engineering choices the agent can settle.
- Present a heavyweight or unfamiliar option before asking the user to choose it.
- Ask only questions whose answers can materially change the design or scope.

## Round shape

Ask a small numbered set. Questions in the same round must be independent; a dependent question waits for the next round after its prerequisite is settled. For each question, provide the recommended answer and its consequence. Accept numbered, partial, out-of-order, or "all recommendations" replies without forcing the user to restate settled answers.

Load the [marker vocabulary](markers.md) and use its stable plain-text labels. A compact round may look like:

```text
Round <N> — <topic>

✅ Settled: Q<i> — <accepted decision>.
❌ Dropped: Q<j> — <rejected path and reason>.
🔁 Reopened: Q<k> as Q<m> — <new evidence invalidated which premise>.
⏳ Held: <decision> — <research or prerequisite still pending>.
📌 Pinned fact: <fact investigated by the agent>. 🔗 Source: <source>.

❔ Open decision: Q<m> — <title>   ⭐ Heavyweight: <why comparison matters>
    A. <option and tradeoff>
    B. <option and tradeoff>
👉 Recommendation: <letter> — <reason>.
❗ Flip condition: <evidence that would reverse the recommendation>.

❔ Open decision: Q<n> — <title>   ✨ New: <what just unblocked it>
💡 Knowledge candidate: <insight worth carrying if the decision settles>.
```

The template is a visual aid, not a required form. Prefer one leading marker per line; when two concepts share a line, both stable labels must remain explicit. Do not use the historical red/green circles: `🔁 Reopened:` avoids the risk-color conflict, and a completed wait becomes a `📌 Pinned fact:`, an `✨ New:` branch, or a `✅ Settled:` decision.

Keep temporary round state in the conversation or Plan output. When a decision settles, incorporate it into the decision-complete handoff. Classify accepted rationale, diagrams, and reusable insights under `Exploration Carryover`; materialize them only after the target Change is created. Proposal/spec/design/tasks remain durable current truth, while talks/knowledge retain only selected rationale or reuse value.

Stop asking when the remaining choices are non-blocking assumptions, safely inferable engineering details, or explicitly out of scope.
