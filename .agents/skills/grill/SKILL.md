---
name: grill
description: Discover and resolve consequential decisions through explained frontier rounds. Called by Brainstorming or a Change Replan; return to the caller when the current scope is decision-complete.
---

# Grill

- Take the caller's objective, accepted decisions, record owner and return position. Brainstorming owns its draft; an existing Change owns one `attachments/talks/grill-<time>-<theme>.md`. Use Harness [discussion operations](../harness/references/discussions.md) for recording and state.
- Inspect evidence first. For every substantive requirement, design or plan change, expand the affected decisions: scope, behavior, interfaces, dependencies, failures and acceptance. Carry forward still-valid decisions with reasons; an explicit direction is not necessarily a complete design.
- Resolve discoverable facts and authorized implementation details yourself. Ask new consequential choices, invalidated decisions and unsettled user-owned behavior. Routine defects stay in the task.

## Explain and ask

1. Send a visible situation brief before the question tool: evidence, affected and settled decisions, what can be decided now, option consequences and recommendation. Later rounds explain the delta; a link or form alone is insufficient.
2. Ask the unblocked frontier. Related independent questions may share a round within host limits; dependent questions wait. Use stable question IDs, meaningful alternatives and relevant flip conditions.
3. Accept partial, out-of-order and free-text answers. Reflect what changed, preserve the actual answer source and recompute the frontier, including new questions revealed by the answer.
4. Preserve delivered explanations, forms, replies and useful diagrams through the caller's recorder. Update current conclusions without rewriting originals or superseded decisions.

- Use concise Markdown lists, numbered questions and useful comparison tables. Explain call chains with [visual-explain](../visual-explain/SKILL.md); no marker vocabulary is required.
- Use the actual permitted question tool. If it fails, is cancelled or invisible, ask one concise text question in the permitted channel; do not repeatedly probe the same form.
- Preselection, silence, cancellation and elapsed time are not answers. Required unanswered choices remain pending; recommendations remain recommendations.
- Confirm new public names through [naming](../brainstorming/references/naming.md). Existing authorization persists; do not ask another generic permission to continue approved work.

## Return to the caller

- Finish when the affected decision tree is covered, necessary choices and authority are settled, and the scope has an executable next step. Do not stop after a fixed round count or time budget.
- Waiting for a necessary answer pauses all implementation in the current Change. Continue read-only investigation, retain questions and the return position, and resume after actual answers. Unattended continuation records the question and waits without inventing an answer.
- Return decisions to Brainstorming's design/handoff or Update's Replan. The caller continues the authorized workflow; a Grill or Replan boundary alone is not a reason to send a final answer.
- Record unrelated ideas as follow-up topics unless the user changes the objective. Follow-ups do not silently expand the Change or enqueue another one.
