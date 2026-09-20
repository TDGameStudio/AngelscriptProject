---
name: brainstorming
description: "Explore user intent, evidence, alternatives and consequential design choices in a continuing local draft. Open drafts automatically for substantive exploration, explain before asking and after answers, and prepare a creation or Replan handoff only when the user requests convergence. Respect direct authorized work."
---

## Open or resume the discussion

- Open or resume one topic under `openspec/drafts/<domain>/<topic>/` through `harness.draft.create` / `harness.draft.status`. Draft creation is automatic discussion support, not approval to implement.
- Read [the draft contract](references/drafts.md) for the minimal README and CONTEXT, optional research/attachments and scoped design metadata.
- A substantive proposal, trade-off or continuing design exploration belongs in a draft. A factual query, standalone explanation or clear directly authorized edit does not require a draft merely to satisfy a workflow.
- Announce the draft path once. Preserve the selected workspace and the caller's objective and return position.
- Keep one outcome together by default. Create `designs/<scope>/design.md` when a bounded outcome can be described; split only independently deliverable outcomes, not competing alternatives for one outcome.
- Topic mode follows current work: `research` investigates, `proposal` develops a candidate and `design` resolves choices. Modes are not authorization or a compulsory one-way ladder.
- “Harness upgrade” is a topic/subject, not a fourth mode or a separate Skill. Execution feedback and explanation-improvement questions can live in these same drafts without ever creating a Change. A sourced unresolved question may be captured automatically; capture is not a diagnosis or repair authorization.

## Explore and make the design understandable

- Call independent [grill](../grill/SKILL.md) with this draft/design, accepted choices and the return position.
- Use [explaining-work](../explaining-work/SKILL.md) to show the complete relevant architecture, responsibilities, current terms, important code, callers/callees, lifecycle and data before questions.
- Compare meaningful viable approaches with consequences and a recommendation; do not manufacture weak alternatives. Grill's [round method](../grill/references/rounds.md) owns the question frontier and answer handling.
- After each answer, show the resulting relevant architecture and terminology again in conversation. Explain changed relationships/behavior and remaining uncertainty; a saved-file update is insufficient.
- Keep the same draft and discussion active across answers. Let Grill actually issue the next ready question after that explanation; do not wrap each round in a completion reply or require the user to request continuation. A pending question resumes from its answer, including after a host-required text fallback.
- Side questions and partial answers stay with the active Grill. Use its single [continuation loop](../grill/references/rounds.md), including coverage inspection when no question appears ready; do not maintain a second competing turn-ending rule here.
- Update CONTEXT with key decisions, rationale, unresolved points and sources. Update the owning design's current truth at the same time; preserve important superseded decisions without requiring verbatim chat duplication.
- Confirm public names using [naming](references/naming.md). A naming round always offers more candidates in a draft Markdown file, and a name the user already chose is not re-asked.
- Draft prose follows the conversation language. Identifiers remain exact; final Change planning and exported current summaries use English.

## Wait for user-driven convergence

- Do not prepare handoff or offer creation/Replan just because the agent believes the design is ready, the frontier is empty or a round has finished.
- Continue the user's research and discussion until they ask to converge, create a Change or apply a Replan.
- After that request, prepare the concrete selected design and [scoped handoff](references/deep-exploration.md), including target, important decisions/names and necessary carryover.
- Explain the prepared result in the conversation, then collect the explicit handoff Gate for the exact revision. The user can choose creation/application or return to architecture explanation and discussion.
- A request to converge permits preparation; it is not a fabricated answer to the later Gate. A stale or changed handoff requires the changed result to be shown and its actual choice recorded.
- Creation and Replan use the same discussion and Gate principle. For an existing Change, preserve valid work and the execution return point while exploring the proposed revision in a linked draft.
- Once the creation/application succeeds, the caller handles the required follow-up choices for draft disposition and execution timing. One handed-off scope does not automatically archive its topic.

## Respect direct work and historical records

- Honor a specific authorized direct edit or no-Change request without inventing a generic approval ceremony. State material assumptions and carry out the authorized route.
- A draft may remain active, be parked with a resumption condition or be archived on an explicit disposition. Moving it into the archive does not imply that open questions were solved.
- Read existing log/findings/scoped-README layouts in place. Do not bulk-migrate or rewrite old records to match the new layout.
- Optional transcript recording remains available through [legacy recording](references/recording.md); it is not required for discussion, questions, handoff or final responses.
- Unattended execution does not invent user choices. Save the relevant finding and return position, and wait for required actual input through Harness.
