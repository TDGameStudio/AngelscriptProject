# Grilling Rounds

- Load when collecting user-owned design decisions. Each questioning round has a visible explanation, identified questions, actual replies and updated decisions.
- Inspect available facts first. Ask only decisions that affect scope, behavior, naming or acceptance; continue independent investigation while an answer is pending.

## Situation brief before every round

- Send the explanation in chat before the question tool. Saving text, showing shell output or linking a file does not present it to the user.
- Identify the current focus, settled/open decisions, relevant evidence, option consequences and recommendation. Explain why these questions can now be answered.
- For technical choices, show the purpose, ownership, lifecycle, caller/callee chain, data shape or commented code that the decision depends on. Use [visual-explain](../../visual-explain/SKILL.md); do not mechanically include every view for a small question.
- Shared background is explained once; later rounds explain the delta. Keep decision-critical explanation in chat even when findings hold supporting detail.

## Design tree and frontier

- The frontier contains decisions whose prerequisites are settled. Group related independent questions when useful, within actual host limits and the user's pace.
- Give each question an identity, meaningful alternatives and a recommended answer with consequences. State an evidence-based flip condition when one matters.
- Accept partial, out-of-order and free-text answers. Reflect what each settles and what remains open, update the draft, then recompute the frontier.
- A clarification narrows or corrects its owning decision; additional features need their own evidence and authorization.

## Collect the answers

- Follow the session's actual tool schema, mode restrictions and channel rules.
- Codex: send declarative commentary, then use `request_user_input` when available and permitted. Use `request_user_input_async` only when asynchronous clarification fits the task and host. Do not send final before a synchronous form call.
- Cursor: use `AskQuestion` when exposed and permitted.
- If a form fails, is cancelled or invisible, use one concise text question in the permitted channel. Do not repeatedly probe the same form. A preselection, acknowledgement, cancellation or elapsed time is not an answer.
- Collect approval only by a host-permitted mechanism; existing authorization persists. Keep required unanswered decisions pending and working assumptions distinguishable from confirmed choices.
- The recorder preserves delivered explanations, question payloads and returned answers. Manual fallback follows [recording checkpoints](drafts.md#recording-checkpoints); never save prepared text as delivered.

## Round record

```markdown
## R<n> — <topic>

- Evidence: <source and observation>
- Settled / superseded: <decision and source round>
- Open: Q<n> — <decision whose prerequisites are settled>
- Options: <consequences>; recommended <choice> because <reason>.
- Actual messages: <verbatim delivered explanation, questions and replies, with source boundaries>
- Outcome: <settled choices, remaining frontier and owning design>
```

- Adapt headings to the user's language. [Markers](markers.md) are optional navigation, not another state model.
- For OpenSpec handoff, confirm the source/target/reason carryover in [deep-exploration.md](deep-exploration.md). Direct work needs no Change carryover round.
- Never run rounds unattended or for ordinary task-local implementation uncertainty; use the Harness apply/replan boundary.
