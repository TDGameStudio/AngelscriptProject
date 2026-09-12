---
name: brainstorming
description: "Use before creative or design work, proposals, trade-offs, or unconfirmed user-owned decisions. Keep a continuing openspec/drafts/ topic with recorded grill rounds and independent scoped design directories. Confirm names and scoped handoffs before selected OpenSpec work; respect explicitly authorized direct work without a Change. Never reopen design mode for a Change that already exists."
---

# Brainstorming: Explore and Record into a Draft

Explore ideas with the user through recorded dialogue under `openspec/drafts/`. One topic owns shared research and an append-only conversation; independently deliverable designs live in `designs/<scope>/`. A topic can keep exploring while individual designs become ready or handed off. This Skill owns the Brainstorm Gate; exploration writes stay in the draft and implementation follows the user's selected route.

<HARD-GATE>
For unresolved design work, present the relevant design and obtain its approval before implementation or Change creation. A mode, directory, sibling design's approval or unanswered form is not approval. Respect existing authorization: if the user explicitly directs implementation of the discussed approach without a Change, record that route and proceed with authorized work; do not create a Change or repeat an already settled approval. Only OpenSpec-selected work requires the named Change and carryover handoff below. Once a Change exists, never reopen `design` mode for that Change's scope; corrections belong to `openspec-update-change`, task-local uncertainty to `openspec-apply-change`. Other scopes can continue in the topic. A research finding invalidating an active Change's plan goes to update-change, not straight into implementation.
</HARD-GATE>

## Conversation before questions

Before every questioning round, including the first or resumed round, send a situation brief in the conversation. Identify the current topic/design, settled and open decisions, relevant facts and uncertainty, what each answer changes, and recommendations with consequences. Explain why these decisions are next. For technical decisions, explain the system for someone unfamiliar with it: purpose, lifecycle, caller and callee chains, data formats, and simplified code with comments at the relevant lines. Cover what establishes the decisions; do not impose a paragraph limit or move necessary explanation out of chat to keep it short.

The brief must be an actual assistant message visible before the question tool is called. Writing it to log.md, displaying file contents through a tool, linking design.md or putting it only in the form does not satisfy this step. In Codex, send declarative commentary, then use `request_user_input` when its current declaration and host rules permit. Do not send final before that call. Follow [answer collection](references/grilling.md#collect-the-answers) for host restrictions and fallback.

Each question settles one clear decision; a round may group related, independent questions whose prerequisites are settled. Choose the count for the user's pace, explanation complexity and actual host limits, rather than mechanically forcing one question. Dependent questions wait. After answers, acknowledge what each settles and what remains open, then recompute the frontier. Append actual conversation, diagrams and tool questions/answers to log.md; corrections are new entries, never rewritten history. Never end with only a file link or "the draft has been updated".

Use [visual-explain](../visual-explain/SKILL.md) for useful structure, workflow, call-chain, lifecycle or data-format explanations. Show the diagram in chat, explain important relationships, and preserve it in the draft. Use inline trees, flow diagrams and annotated code sketches; no interactive diagram tool is part of this workflow. A trivial question need not have a diagram. Headings and new draft content default to the user's conversation language unless the user specifies another draft language; Change output is English.

## Entry modes

The topic README records mode for its current focus: what the agent is doing now, not the maturity of every design. Keep a current-focus link and continuation note. Scoped designs record their own approval/handoff status, with no separate mode. Recording rules are identical.

| Mode | Work | Stop or continue |
| --- | --- | --- |
| `research` | Investigate and write shared `findings/<topic>.md`; ask only for missing user-owned information | Findings may be enough; keep exploring or park |
| `proposal` | Once a bounded outcome is identifiable, write `designs/<scope>/design.md` as a candidate, then grill around its affected sections | Revise, park, or switch to design to converge |
| `design` | Resolve the decisions needed for an accepted scoped design | For OpenSpec-selected work: `designed` → `openspec-create-change`; otherwise follow the authorized direct route |

Open a draft when output contains a proposal, trade-off or more than one diagram. An isolated factual answer outside continuing exploration need not open one. Say `Draft opened: <path> (mode: <mode>)` once. Within an existing draft, append all discussion, including factual clarifications. Switch mode when activity changes and record why; returning to research does not revoke scoped approval. Create a design directory when its independent outcome can be described, before approval, with only needed files. Pure investigation stays in findings. Do not force a one-way mode ladder.

## Pass the gate with the actual scope

A clear defect repair, mechanical documentation change or accepted implementation may skip unresolved-design exploration when no user-owned decision remains: state the assumption. Do not use apparent simplicity to skip a real design choice. Explicit user authorization takes precedence over an inferred approval ceremony or mandatory Change creation.

## Checklist for a scoped design

Research uses shared findings; proposal may start with a candidate before grilling. Complete relevant design work for the selected `designs/<scope>/`, not for every subject in the topic at once.

1. **Explore project context** — inspect code, tests, current specs and relevant existing Changes. Facts available in the repository are the agent's job.
2. **Open or resume the draft** — use [drafts.md](references/drafts.md). Read the current-focus entry and selected material before the relevant log rounds; preserve older records.
3. **Grill in frontier rounds** — per [grilling.md](references/grilling.md), present the situation brief, number each independent decision, give a recommended answer for each, collect replies and recompute. Paste the round into log.md exactly as sent and replies exactly as written. Include [naming](references/naming.md); distinguish shared glossary.md vocabulary from the selected design's names.
4. **Compare approaches** — explain viable alternatives and recommend one with trade-offs. Do not manufacture alternatives when the evidence forces a choice.
5. **Maintain design.md** — scope, architecture, data flow, names, errors, edge cases and verification. Label it as a candidate until accepted. Separate independently deliverable outcomes into sibling designs; A/B alternatives for the same outcome normally remain sections in one design.
6. **Present and review** — explain the written design and meaningful revisions in the conversation, linked to its file. Obtain only missing approval for this scope using the host-permitted mechanism; a file link alone is not presentation. A material change to an accepted decision needs the affected decision revisited, not unrelated approvals repeated.
7. **Select the work route** — respect explicit direct implementation without a Change. The remaining handoff steps apply only when OpenSpec owns the work; do not create a Change by inference from a design directory.
8. **Carryover round** — list this design's talk/knowledge candidates with source, target and reason; the user confirms what enters the Change. Recommend relevant material, not the whole transcript or sibling research.
9. **Write handoff.md** — in the selected design directory per [deep-exploration.md](references/deep-exploration.md): decision-complete handoff, settled OpenSpec Handoff identity and confirmed Exploration Carryover.
10. **Transition** — set only the selected design README to status: designed and pass its exact directory to openspec-create-change. A design or topic may instead be parked with a resumption condition, or abandoned with why. Handing off one design does not close the topic.

```text
topic draft                         // Shared log, findings and current activity remain resumable.
├─ research                         // Investigation needs no delivery directory.
└─ designs/<scope>/                 // Created when a bounded outcome can be described.
   ├─ proposal/design discussion    // Explain, grill, revise and confirm this scope.
   ├─ authorized direct work        // Follow the user's route without a Change.
   ├─ designed -> create-change     // OpenSpec route with confirmed carryover.
   │  └─ apply (Ensure plan)        // English seeded attachments feed the Change plan.
   └─ parked / abandoned            // Other designs and research can continue.
```

## Grilling in short

- Every question to the user is a grill round: one decision or several independent decisions share the required context and recording discipline. Do not ask ad-hoc questions outside that structure.
- Every round starts with the visible situation brief, detailed enough to answer without opening files or reconstructing history.
- Model a design tree. The frontier contains decisions whose prerequisites are settled; dependent questions wait. Group independent questions when useful, respecting the host's actual limits and the user's pace.
- Give a recommended answer and consequences for each question. Accept partial, out-of-order and free-text replies; do not interpret silence or a selected default as confirmation.
- Use the compact [round format](references/grilling.md) and [markers](references/markers.md) when helpful. Adapt language and headings; preserve scope, sources, explanation, alternatives, recommendation and material flip conditions. Short form labels alone cannot explain a decision.
- After the brief, prefer Codex request_user_input or Cursor AskQuestion when actually exposed and permitted. A form does not replace the brief. A required text fallback retains the same explanation and decision boundary.
- After replies, reflect what each answer settles, record it, and choose the next unblocked work. Do not substitute an omnibus design-approval question for unresolved frontier decisions.

## Naming

New public types, modules, files and key functions are decisions. Inspect neighbours, explain the name and alternatives, and record settled names in glossary.md and the design's Vocabulary and Naming section per [naming.md](references/naming.md). Independent names may share a round. Apply never asks: it derives an unlisted public name from convention and records Naming assumed in task Evidence.

## Records and handoff

- Write new draft material in the user's conversation language by default, inferred from the conversation; honor an explicit draft-language preference. Do not choose an arbitrary language. Preserve historical records rather than translating them automatically. Preserve original-language conversation verbatim in append-only log.md, including visible diagrams and actual form payloads/answers.
- Final Change output, including design/handoff/glossary copies, findings, talks, knowledge and diagram explanations, is English. Copy English originals or faithfully translate other languages with provenance; keep local originals.
- openspec-create-change consumes one selected approved handoff, seeds attachments/drafts/, and materializes confirmed rationale into indexed talks and reusable insights into indexed change-local knowledge. Ensure plan writes proposal/specs/design/tasks. Never copy the exploration transcript into the Change.
- Resolve required approval before `change create`, never after; existing authorization need not be requested again. One scoped handoff produces one Change; a topic can produce several. A decision-complete handoff is not an active Change or Ready Task DAG.
- Preserve legacy flat drafts per [drafts.md](references/drafts.md). Do not bulk-migrate logs or approved records. A parked topic resumes in the same directory.

## Brainstorming needs a present user

Unattended continuation (including Codex `/goal`, defined by Harness) never opens brainstorming or a new draft. It continues approved Ready tasks of an existing Change; a new user-owned decision is planning-invalidating evidence for `openspec-update-change` replan, which parks it with a recommendation until an attended round can answer. Ordinary task uncertainty stays inside apply.
