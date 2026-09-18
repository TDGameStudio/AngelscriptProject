## Prepare the frontier

- Model decisions and their prerequisites. Ask only choices whose prerequisites are settled; a running investigation remains an unsettled prerequisite.
- Group related independent questions when helpful, following actual host limits and the user's pace. Do not enforce one question per round or fill the form to capacity.
- Keep stable decision identifiers across partial answers. If new evidence reopens a settled choice, state the changed premise and link the prior decision.
- Resolve repository facts through investigation. Ask consequential preferences and user-owned choices; do not outsource symbol lookup or source reading.
- Explain the actual situation using [the brief method](brief.md) before asking.

## Shape a question

- Give each question one clear decision, meaningful alternatives, concrete consequences and a recommendation.
- Explain shared background once, then show how each option changes that background.
- Include relevant conditions that would reverse the recommendation; do not attach a generic risk checklist.
- Naming rounds include “Provide more names” and follow the draft research flow in [naming](../../brainstorming/references/naming.md).
- Keep option labels short enough for the host but leave the full comparison in the visible explanation.

```text
Q<n> — <one decision>

Current situation: <verified behavior and accepted architecture relevant to this choice>.
Why now: <what this unlocks; what remains dependent>.

A. <option> — <actual consequence and trade-off>.
B. <option> — <corresponding consequence and trade-off>.
Recommendation: A, because <reason tied to the user's objective>.
Change the recommendation if <material evidence or preference>.
```

- This is a content guide, not a compulsory literal template or marker vocabulary. Use the user's conversation language.

## Process answers

- Accept numbered, partial, out-of-order, “all recommendations” and free-text answers. Preserve what the user actually accepted and the source of that answer.
- Clarify a materially ambiguous answer with the unresolved choice; do not repeat settled questions.
- Separate confirmed decisions, recommendations and provisional engineering assumptions. A preselected default, silence, cancellation or acknowledgement is not an answer.
- After every answer, re-explain the relevant updated architecture, current terminology, behavior and remaining questions as specified in [brief.md](brief.md).
- Recompute the frontier, including new choices exposed by the answer. Investigate any newly discoverable facts before asking dependent questions.
- If a consequential question is now ready, deliver the updated architecture and actually ask it in this turn through the permitted host mechanism. "I will ask the next question", a round-complete summary or "say continue" does not perform this step.
- Store key decisions/reasons and unresolved points in CONTEXT and the owning design. Preserve important superseded decisions with their reason; full verbatim conversation recording is optional.

## Finish the turn at a real continuation point

- Before yielding, distinguish the actual state: a concrete question was submitted and awaits its answer; a specific investigation or prerequisite still blocks the next question; the user explicitly paused; or the user requested convergence and the caller is preparing its Gate. None is implied by completing one round.
- Do not say the next question is available unless the tool call actually submitted it or the full text fallback was sent. Tool acceptance alone does not prove that a selectable window rendered; if the user reports it missing, follow [host fallback](hosts.md).
- Reuse a still-pending question instead of creating duplicates. On an answer, match its meaning to the pending decision, preserve partial answers and continue automatically. Keep only the needed pending question and next step in the existing context; no transcript mirror or new persistent state machine is required.
- A specific answer such as "that name is fine" settles that choice; interpret convergence from the user's contextual intent, not the mere presence of an affirmative word.

## Keep discussion separate from handoff

- An empty frontier means the current explanation has no known unanswered design choice; it does not grant permission to create or Replan.
- If useful in-scope investigation remains, perform it. If no substantive question remains, show the current understanding and explicitly leave the topic open for the user's feedback or convergence. Do not manufacture questions, repeat settled choices or send a generic permission-to-continue question merely to keep a form active.
- Continue responding to the user's exploration. Do not repeatedly ask whether they want to create a Change or advertise a handoff option.
- Only user-driven convergence starts handoff preparation and its Gate. The user can still choose to view the current architecture and continue discussion after reviewing the prepared result.
- Carryover, archival and execution decisions belong to that concrete handoff/follow-up, not an omnibus approval question hidden inside ordinary design choices.
