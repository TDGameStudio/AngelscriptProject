## Use the actual host contract

- Deliver the declarative explanation in the conversation first. A form alone does not provide the reasoning needed to answer.
- Inspect current tool declarations and mode restrictions. Do not assume that a tool name, an old prompt or another host's schema is available here.
- In Codex, use `request_user_input` only for the clarification its current declaration permits. For a required Create, Replan, arrangement or close Gate, prefer an available `request_user_input_async` when its declaration permits approval. Actually call it after the explanation; do not substitute a printed menu. In Cursor/Grok, inspect the exposed `AskQuestion`/`ask_user_question` contract rather than assuming equivalent approval support.
- For an active Grill round, invoke the eligible question tool after the visible explanation in the same turn. A declarative intention to ask, an unsent payload or a question saved only to a file is not a delivered question. Recheck the current host contract if one question tool cannot handle the needed clarification.
- Prefer an actually available selectable form for a required Gate when its declared contract permits that decision; an exposed asynchronous input tool may be used when it explicitly supports approval. Its pending question is not an answer, and only independent work may continue while it is pending.
- If one form is optional-only or approval-prohibited, first check whether another exposed selectable form supports the decision. Use that eligible form. Only if none does, present the concrete decision through the host-permitted text fallback. Never relabel approval as optional clarification to bypass a restriction.
- Keep commentary declarative when the host forbids questions there. Use the permitted text fallback, including final when required, without pretending a Gate was answered.
- Do not substitute an asynchronous tool merely because of the mode. Tool acknowledgement is not proof of a visible selectable form.

## Handle missing or failed forms

- If a form is unavailable, fails, is cancelled or reported invisible, explain briefly and use a concise text fallback when a required decision remains.
- Do not repeatedly probe the same failed form. Do not leave the only question in a file.
- Cancellation, elapsed time, silence and a preselected option do not approve a design or handoff.
- “Explain again / not enough detail” returns to the owning explanation and improvement loop; it is neither approval nor a request to abandon the work. Preserve any still-valid actual answers and the exact unapproved Gate revision.
- For optional clarification, follow the current host's continuation policy and label any working assumption. For a required handoff Gate, retain the unanswered decision and do not perform the dependent action.
- With asynchronous clarification, continue only independent work and process the actual answer when it arrives.
- A pending asynchronous question stays pending: do not announce completion while waiting or ask the user to send "continue" after answering it. Use host-supported waiting/yielding without duplicate forms or a busy loop, and resume the same round from the actual answer. Optional no-answer assumptions remain subject to the host's rules; they do not settle required design choices or close Grill.
- When a host only permits a final-channel text question, send the concrete question and choices there. End that reply in an awaiting-answer state; when the user answers, automatically re-explain and advance the discussion. Do not add a separate "continue" requirement.
- If a form fails or is reported missing, send the actual unresolved question through the permitted visible text fallback now. Do not repeat only the promise to ask, infer a pause from the failure, or claim that a Skill can keep the host process or network connection alive.

## Record the actual result

- Keep the decision's source and the exact meaning of the answer in the owning context/design or Gate record.
- Never record an unsent question as presented or a tool acknowledgement as a user answer.
- Existing explicit authorization persists for its actual scope. Do not add generic permission ceremonies to a direct authorized edit.
- Host constraints do not remove the need to explain before asking and to show the resulting architecture after an answer.
