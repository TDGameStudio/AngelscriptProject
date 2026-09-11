# Design: brainstorming Skill with persistent drafts

Approved by the user on 2026-09-11 (plan `brainstorming_drafts_workflow`).

## 1. Problem

Three failures of the current pre-Change flow:

1. Discussion is lost. `openspec-explore` is read-only; only talk/knowledge candidates survive Change creation, and they record decisions, not the reasoning path.
2. Requirements are confirmed vaguely. Question rounds fire only when at least three dependent user-owned decisions remain; otherwise the agent decides and starts implementing.
3. Naming is never confirmed. Neither task authoring nor apply has a checkpoint for new public names.

## 2. Flow

```text
idea -> brainstorming (grill rounds, each appended to the draft)
     -> design.md approved section by section
     -> handoff.md (decision-complete)
     -> openspec-continue-change creates the Change
          copies design.md + handoff.md -> attachments/drafts/ (indexed once)
          tasks.md interfaces list every grilled public name
     -> openspec-apply-change
          new public name not in the task -> one naming grill round -> continue
```

## 3. `brainstorming` Skill (replaces `openspec-explore`)

- HARD-GATE: no Change creation, code, or apply before the user approves the design. Clear defect repair and mechanical documentation may skip, but the agent states its assumption in one sentence. Any unresolved user-owned decision forbids skipping.
- Grilling replaces the question-round threshold. Each round is the whole frontier; each question is numbered and carries a recommended answer; facts are investigated by the agent; the session ends when the frontier is empty and the user confirms shared understanding.
- (Added 2026-09-11 13:15, user correction) Every question to the user is a grill round — including a single question or a naming choice — and every round opens with a situation brief: what was inspected, what is settled, why these questions are unblocked now, and the overall recommendation.
- Checklist: explore context -> open the draft -> grill rounds (including naming) -> 2-3 approaches with a recommendation -> present design sections and get approval after each -> write `design.md` and self-review -> user review -> write `handoff.md` -> invoke `openspec-continue-change`.
- References: `grilling.md` (new), `drafts.md` (new), `naming.md` (new), `deep-exploration.md` (kept; handoff headings unchanged), `markers.md` (kept). `question-rounds.md` is removed.

## 4. Draft directory `openspec/drafts/<domain>/<topic>/`

```text
README.md     status exploring | designed | handed-off | abandoned; target_change; dates
log.md        append-only rounds: questions, user answers in their own words, agent conclusions
findings/     agent evidence, comparisons, spikes
glossary.md   chosen and rejected names with reasons
design.md     the approved design
handoff.md    decision-complete handoff with Exploration Carryover
```

- Drafts stay permanently under `openspec/drafts/`. After Change creation, `design.md` and `handoff.md` are copied into `changes/<change>/attachments/drafts/` and indexed once; the draft README records `handed-off` and `target_change`.
- Harness scans only `openspec/changes`; the CLI ignores `drafts/`. Drafts are not OpenSpec artifacts and never carry task state.
- `design.md` and `handoff.md` are English. `log.md` and `findings/` may keep the user's original-language wording; `config.yaml` and `record-schema.md` name this exception.

## 5. Naming grill

- Brainstorming grills every new public type, module, file, and key function name after inspecting neighbouring conventions; results go to `glossary.md` and the design's "Vocabulary and Naming" section.
- `tasks.md` "Context and interfaces" lists every new public name the task introduces, with its source (draft glossary or grill round).
- Apply never asks the user (revised 2026-09-11 14:20, Round 2 Q1). A required new public name absent from the task is derived from convention and recorded as `Naming assumed: <name> — <reason>` in task Evidence; verification lists every assumed name for review before the task closes. Frequent assumed names are fixed in planning, not by asking during apply.

## 5a. Unattended continuation (Round 2, Q2/Q3)

- Codex `/goal` is defined once in `harness/SKILL.md`; `brainstorming/SKILL.md` references it once under "Brainstorming needs a present user". Every other Skill says "unattended continuation". Tests enforce the two-file allowance.
- Unattended runs never open brainstorming or start a draft. A user-owned decision uncovered inside a Ready task is planning-invalidating evidence: record it, route it to `openspec-update-change` replan, park it there with the agent's recommendation, and let the next attended session answer it in a grill round.

## 5b. Change creation as its own Skill (Round 3, 2026-09-11 14:30)

- Brainstorming is repositioned as "explore and record into a draft"; it writes nothing outside the draft and ends `designed`, `parked`, or `abandoned`. `parked` keeps a valuable exploration without a Change and is revived by reopening brainstorming on the same directory.
- The last brainstorming round is the **carryover round**: the agent lists every candidate with source (`log.md` round / `findings/<file>`), target (talk / knowledge), and reason; the user confirms; only confirmed entries enter `handoff.md` → `Exploration Carryover`.
- New Skill `openspec-create-change` owns `change create` for major work and the one-time seeding of the Change: `attachments/drafts/{design,handoff}.md`, talks and knowledge candidates materialized exactly from the confirmed list with provenance back to the draft, `INDEX.md`, and the draft README → `handed-off` + `target_change`. It then hands to `openspec-continue-change`, which returns to writing one planning artifact at a time and never recreates seeded carryover.

```text
brainstorming ──designed──► openspec-create-change ──► openspec-continue-change ──► apply / verify / sync / archive
       │
       ├──parked──────► draft kept, revisit later
       └──abandoned───► draft kept as record
```

## 5c. Entry modes and local drafts (Round 4, 2026-09-11 14:47)

- `openspec/drafts/` is git-ignored: drafts are the author's local working records; the Change's `attachments/drafts/`, talks, and knowledge are the shared copies.
- Three entry modes share one draft layout, recorded as `mode:` in the README:
    - `research` — explore, write `findings/<topic>.md` with diagrams embedded and a closing Conclusions / Open block; grill only when a fact needs the user; ends `parked` or upgrades.
    - `proposal` — write the `design.md` draft first (marked `Status: proposal draft`), then grill around it with section-anchored questions; ends `parked` or upgrades to `design`.
    - `design` — the full checklist; the only mode that can reach `designed` and `openspec-create-change`.
- Auto-open rule: a draft is opened as soon as a reply contains a proposal, a trade-off, or more than one diagram; plain Q&A is not recorded; the agent announces `Draft opened: <path> (mode: <mode>)` once.
- Upgrading a mode appends to the same draft and completes the skipped steps (naming round, carryover round); the HARD-GATE applies regardless of mode.

## 6. Out of scope

- No `CONTEXT.md` or ADR files; talks keep the ADR role and drafts keep the glossary.
- No OpenSpec Rust CLI change; drafts are a directory convention guarded by Skills and tests.
- `markers.md` and the handoff heading set are unchanged.
