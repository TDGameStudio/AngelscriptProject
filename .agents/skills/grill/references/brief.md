## Explain the situation visibly

- Before asking, identify the current topic/scope and what the user needs to understand to make this decision.
- Explain what was inspected and the conclusion it supports, with useful source paths. Do not list searches as a substitute for explaining findings.
- State the valid decisions the round builds on, what new evidence reopened and which questions remain dependent on this answer.
- Explain why this question is relevant now and what each answer would change.
- Give an overall recommendation when options combine, without treating it as a user answer.

## Show how it works today

- For technical and system decisions, use [explaining-work](../../explaining-work/SKILL.md) rather than a status-only summary.
- Explain purpose and architectural roles, relevant input/output, caller and callee chains, important logic, ownership/lifecycle, data formats and applicable controls.
- Put specific functional explanations beside faithful source code or simplified code that retains real structure. Use an annotated tree or other relevant view to make relationships legible.
- Keep the complete relevant architecture and terms visible in the conversation. A technically informed reader should see which part changes; a reader new to the system should understand why it exists.
- Explain an unfamiliar or costly option before asking the user to select it. Each option should point to a concrete boundary, relationship, phase, data shape or behavior in the explanation.
- Use details that bear on the decision. A naming choice for an already-understood role can be short; an ownership or lifecycle change needs enough context to make its consequences understandable.
- Do not impose paragraph, word, diagram or depth quotas. Brief state notes may be short while the actual mechanism explanation needs more space.

## Compare options in the same frame

- Compare viable alternatives with the same meaningful criteria. Show benefits and costs, including compatibility or failure consequences when relevant.
- Do not manufacture weak alternatives to pad a form. If evidence rules out a path, explain why it is ruled out.
- Give the recommendation and its reason separately from the option label. Include a flip condition when real evidence or a preference would change the choice.
- Keep comparisons in chat before the form; longer research may live in the draft, but decision-critical content stays visible.

## Re-explain after the answer

- Acknowledge actual answers, including free-text corrections, without assigning an option the user did not choose.
- Show the resulting relevant architecture and current names again. Explain changed relationships/behavior, what remains valid and what is still open.
- Do not merely announce that a context/design file was updated. Do not show only a tiny diff if the user would need to reconstruct the rest of the relevant mechanism.
- Reuse known background without needlessly restarting the whole project explanation. The goal is a self-contained view of the affected system, not a transcript replay.
- Preserve key conclusions and provenance in the caller's records; no mandatory chat-to-file double writing.
