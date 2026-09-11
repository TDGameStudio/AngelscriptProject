---
name: brainstorming
description: "You MUST use this before any creative or design work — a new feature, refactor, behavior change, Skill or workflow change — and before replying with a proposal, a recommendation among options, a trade-off, or more than one diagram, or whenever a user-owned decision is unconfirmed. Opens an openspec/drafts/ draft (research | proposal | design), grills the user in recorded rounds, confirms names, and ends with an approved design handed to openspec-create-change or a parked/abandoned draft. Never reopen design mode for a Change that already exists."
---

# Brainstorming: Explore and Record into a Draft

Explore an idea with the user through relentless, recorded dialogue, and write everything you learn — questions, answers in the user's own words, findings, rejected paths, names — into a draft under `openspec/drafts/`. This Skill owns the Brainstorm Gate and writes nothing outside the draft. A draft ends in one of three states: `designed` (handed to `openspec-create-change`, which creates the Change and mines the draft for talks and knowledge), `parked` (worth keeping, no Change now), or `abandoned`.

<HARD-GATE>
Do not create an OpenSpec Change, write code, scaffold files outside the draft, or invoke `openspec-apply-change` until you have presented a design and the user has approved it. This applies regardless of perceived simplicity and regardless of entry mode: a `research` or `proposal` draft must be upgraded to `design` and complete the checklist before anything leaves the draft. Once a Change exists, never reopen `design` mode for that Change's scope; corrections then belong to `openspec-update-change`, and task-local uncertainty to `openspec-apply-change`. `research` and `proposal` drafts are not tied to a Change and may be opened at any time — but a finding that changes an active Change's plan is planning-invalidating evidence and goes to `openspec-update-change`, never straight into implementation.
</HARD-GATE>

## Entry modes

One draft layout, three ways in. The mode is recorded in the draft `README.md` and only decides where you start and where you may stop; recording rules are identical.

| Mode | When | First step | May stop at |
| --- | --- | --- | --- |
| `research` | The user wants to understand something: "how does this part work", a comparison, an ASCII diagram | Explore and write `findings/<topic>.md` (diagrams embedded as-is, conclusions and open points at the end); grill only when a fact needs the user | `parked` — no design, no Change |
| `proposal` | The user asks for a proposal: "give me a proposal for X" | Write a `design.md` draft first — scope, approach, diagram, trade-offs, recommendation — then grill *around that document*: each question points at the section it would change | `parked`, or upgrade to `design` |
| `design` | New feature, architecture refactor, major behavior change, or any unconfirmed user-owned decision | The full checklist below | `designed` → `openspec-create-change` |

Open a draft as soon as your output contains a proposal, a trade-off, or more than one diagram; plain question-and-answer ("what does this function do") is not recorded. Say `Draft opened: <path> (mode: <mode>)` once so the user can object. Upgrading a mode appends to the same draft — change `mode`, keep every finding, and complete the steps the earlier mode skipped (naming round, carryover round).

## Anti-pattern: "this is too simple to brainstorm"

Unexamined assumptions cost the most on small requests. A clear defect repair or a mechanical documentation change may skip the gate, but only after you state the one assumption that makes it clear, in one sentence, where the user can object. If any user-owned decision is still unconfirmed, the gate applies.

## Checklist (design mode)

Work these in order and keep the draft current at every step. `proposal` mode enters at step 6 with a draft `design.md` and then runs steps 3-5 against it; `research` mode runs steps 1-2 and records into `findings/`:

1. **Explore project context** — code, tests, current specs, active Changes, recent commits. Facts are your job, never the user's.
2. **Open the draft** — create `openspec/drafts/<domain>/<topic>/` per [drafts.md](references/drafts.md) before the first question. Append every round, every answer, and every finding as it happens.
3. **Grill in frontier rounds** — per [grilling.md](references/grilling.md): open with a situation brief, number each question, give a recommended answer, ask the whole current frontier, collect the answers through the host's answer form, wait, recompute. Paste the round into `log.md` exactly as sent and the user's reply exactly as written. Include naming questions per [naming.md](references/naming.md) and record settled names in `glossary.md`.
4. **Propose 2-3 approaches** — with trade-offs and one recommendation, lead with the recommendation. Do not manufacture alternatives when requirements force one option.
5. **Present the design** — in sections scaled to their complexity; ask after each section whether it is right so far. Cover scope, architecture and components, data flow, naming, error handling and edge cases, verification.
6. **Write `design.md`** — the approved design, then self-review: placeholders, contradictions, scope too large for one Change, ambiguous requirements. Fix inline.
7. **User reviews the written design** — stop and wait: "Design written to `<path>`. Review it before I write the handoff." Revise and re-review on changes.
8. **Carryover round** — the last grill round. List every candidate worth carrying into the Change: for each, its source (`log.md` round heading or `findings/<file>`), its target (`talk` when the rationale would otherwise be re-decided; `knowledge` when the insight is reusable beyond this work), and the reason. Recommend a selection; the user confirms. Only confirmed items enter `handoff.md`; everything else stays in the draft.
9. **Write `handoff.md`** — the decision-complete handoff per [deep-exploration.md](references/deep-exploration.md), including `OpenSpec Handoff` (Change ID settled in the naming round) and the confirmed `Exploration Carryover`.
10. **Transition** — set the draft to `status: designed` and invoke `openspec-create-change`. That is the only skill invoked after a designed draft. If the user decides not to proceed, set `parked` (with one line on what would revive it) or `abandoned` (with why) and stop.

```text
research: question -> draft opened (mode: research) -> findings/<topic>.md (diagrams, conclusions) -> parked | upgrade
proposal: request  -> draft opened (mode: proposal) -> design.md draft -> grill around it -> parked | upgrade to design
design:
idea -> context -> draft opened -> grill rounds (incl. naming) -> approaches
     -> design sections approved -> design.md + self-review -> user review
     -> carryover round (talks / knowledge confirmed) -> handoff.md
     -> designed  -> openspec-create-change -> Change + seeded attachments -> openspec-apply-change (Ensure plan)
     -> parked    -> draft kept, revisit later
     -> abandoned -> draft kept as record, nothing else
```

## Grilling in short

- Every question to the user is a grill round, whether it is one question, a naming choice, or a full frontier. Do not ask ad-hoc questions outside a round.
- Every round opens with a **situation brief**: what you inspected (with paths); when code is involved, the current state — purpose, lifecycle, caller and callee chains, data formats, and a simplified code block with the explanation embedded as comments, written for someone who has never seen the system; what is already settled; why these questions are unblocked now; and your overall recommendation. The user should never have to scroll back or open a file to answer.
- Model the plan as a design tree. The **frontier** is every decision whose prerequisites are settled. Ask the whole frontier in one round; a question that depends on another open question waits for a later round.
- Every question carries a **recommended answer** and its consequence. Prefer multiple choice; accept partial, out-of-order, or "all recommendations" replies.
- When a question needs a fact, look it up (or dispatch an explore subagent) and ask the rest of the frontier now. Never ask the user for something the repository can answer.
- Use the [marker vocabulary](references/markers.md) so rounds scan well; every line keeps its plain-text label. Write the round in the compact shape from [grilling.md](references/grilling.md): one heading, `**Situation**` marker lines, one `❔ Open decision:` paragraph per question.
- After the written round, issue the same questions through the host's structured answer form (`AskQuestion` in Cursor) with matching letters and the recommended option first; the form never replaces the written round, and a cancelled form falls back to a text reply.
- The session is done when the frontier is empty and the user confirms shared understanding.

## Naming

New public types, modules, files, and key functions are decisions, not details. Inspect neighbouring conventions first, then present each name in a round with the recommendation, alternatives, and the evidence. Settled names go to the draft `glossary.md` and the design's "Vocabulary and Naming" section, and later into each task's **Interfaces**. Apply never asks: a name the task did not list is derived from convention and recorded as `Naming assumed: <name>` in the task Evidence for review. See [naming.md](references/naming.md).

## Design for isolation and clarity

Break the system into units with one purpose, clear interfaces, and independent tests. For each unit answer: what does it do, how is it used, what does it depend on. When existing code obstructs the work (a file grown too large, tangled ownership), include the targeted improvement in the design; do not propose unrelated refactoring.

## Records

- The draft is the durable owner of the conversation. Keep `log.md` append-only; `log.md` and `findings/` may keep the user's original wording, while `design.md` and `handoff.md` are English.
- After acceptance, `openspec-create-change` creates the Change, copies `design.md` and `handoff.md` into `attachments/drafts/`, and materializes only the confirmed carryover: decision-critical rationale into indexed talks, reusable evidence-backed insights into indexed change-local knowledge. The `Ensure plan` step of `openspec-apply-change` then routes settled scope to proposal, durable behavior to specs, non-obvious architecture to design, and executable boundaries to tasks. Never copy the exploration transcript into the Change; it stays in the draft.
- Ask before `change create`, never after. A decision-complete handoff is an input to Change creation, not an active Change or Ready Task DAG.
- A `parked` draft is a legitimate outcome. Its findings and glossary remain discoverable under `openspec/drafts/`; reviving it means reopening `brainstorming` on the same directory, not starting over.

## Brainstorming needs a present user

Grill rounds are conversations. Unattended continuation (for example a Codex `/goal` run) never opens brainstorming and never starts a new draft: it continues only the Ready tasks of an already approved Change. When such a run uncovers a user-owned decision, that is planning-invalidating evidence — record it and route it to `openspec-update-change` replan, which parks the open decision with a recommendation until the next attended session answers it in a grill round.
