---
name: grill
description: "Explain and resolve consequential design choices through evidence, concrete current architecture, comparable options and user answers. Called by Brainstorming for new work or a Replan draft; keep exploring until the user requests convergence, then return the explained scope to its handoff Gate."
---

## Own the questioning method

- Run one continuing loop: inspect the active topic and input → explain the complete relevant current view → resolve discoverable facts → recompute the consequential decision frontier → submit its next eligible question → preserve the actual answer and repeat. Side explanations and tool returns rejoin this loop; they are not completion points.
- Take the objective, accepted decisions, owning draft or discussion and return position from the caller. Brainstorming owns the draft; Harness owns execution and handoff.
- Use [decision coverage](references/coverage.md) to expand affected choices and preserve still-valid decisions. Resolve discoverable facts and authorized engineering details yourself.
- Read [visible explanations](references/brief.md) before a substantive system/design round and [rounds and answers](references/rounds.md) when forming or processing questions.
- Use [host interaction](references/hosts.md) for the actual question mechanism and permitted fallback. A Skill cannot enable a tool or turn optional clarification into an approval mechanism.
- Do not turn every factual clarification into a ceremony. Questions must change scope, behavior, architecture, naming or another consequential user-owned choice.

## Explain before asking and after answers

- Use [explaining-work](../explaining-work/SKILL.md) to inspect and explain the whole architecture relevant to the question: roles, current terms, both sides of call relationships, important code, lifecycle, data and applicable controls.
- Present the current situation and evidence, settled/reopened/open choices, viable options with consequences, recommendation and material conditions that could change it.
- Send this explanation in the conversation before a form or question. A file link, recorded context or bare short-label form does not satisfy it.
- Ask the unblocked decision frontier. Related independent questions may share a round within actual host limits; dependent questions wait.
- If an explanation is inadequate, clarify the specific missing relationship only when necessary, follow [explaining-work](../explaining-work/SKILL.md)'s improvement loop, and return to the same frontier. Understanding feedback is not a comprehension exam, design approval or automatic evidence that the prompt is defective.
- Accept partial, out-of-order and free-text answers. Reflect what each answer settles, then show the updated relevant architecture, terminology and behavior in the conversation before the next question.
- Own continuation once this discussion is active: after that explanation, actually submit the next ready consequential question in the same turn. Do not require another user message saying "continue", or replace a question with a promise to ask later. Follow the delivery and waiting rules in [host interaction](references/hosts.md).
- Preserve key decisions, reasons, open points and answer provenance in the caller's context/design. Do not require a transcript duplicate or save prepared-but-unsent explanations as delivered.
- For naming questions, confirm public naming through [naming](../brainstorming/references/naming.md) and include a meaningful “Provide more names” path that writes a candidate comparison to the draft's research Markdown. Do not add naming alternatives to unrelated design questions.

## Let the user choose convergence

- Continue useful research and design discussion without steering toward creation or Replan merely because the model sees no open questions.
- Do not offer handoff, draft archive, Change creation or application as a routine closing option in ordinary Grill rounds.
- A user request to converge, create the Change or apply a Replan activates the caller's handoff preparation. The caller first makes the selected design concrete and reviewable, then asks its explicit Gate.
- Technical readiness, an empty frontier, “looks reasonable,” a recommendation or elapsed time is not the handoff decision.
- The same rule applies to a new Change and an existing Change's Replan. Preserve the existing Change and execution return point while a draft explores the revision.
- Direct authorization for a specific edit remains valid; do not manufacture a new draft or repeat already-settled permission.

## Continue rounds and return deliberately

- An ordinary answer continues this Grill in the same topic; completing a round does not return a completed discussion to the caller. Return the current design and exact continuation point when the user requests convergence or pause, or when input is required and cannot currently be obtained. Grill never edits implementation, applies a Replan or starts a queue.
- Necessary unanswered current-scope choices keep implementation paused; independent read-only investigation may continue.
- Waiting for a specific answer leaves the discussion open. On the answer's arrival, resume explanation and questioning without a separate restart request. A host-required end to the current reply does not complete the discussion.
- User silence or cancellation is not acceptance. Follow host policy for optional working assumptions, keeping them separate from confirmed decisions.
- Keep unrelated ideas as follow-up topics. Do not silently expand the current scope or enqueue work.
- A completed round is not permission to terminate an unfinished authorized task; the caller retains the exact next step, user pause or waiting condition.
