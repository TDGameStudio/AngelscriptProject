# Design: compact grill rounds with a structured answer form

Approved 2026-09-11 (the user asked to iterate brainstorming first, with the assumptions in `log.md` 16:27).

## 1. Problem

Running a real design round (`openspec/drafts/harness/task-card-format/`, Round 1) exposed three gaps in the `brainstorming` Skill:

1. **No answer form.** `SKILL.md` and `references/grilling.md` never require the host's structured question form. grilling.md only says a bare form must not replace the written brief. Earlier rounds used the form by habit; the first Round 1 did not, and the user noticed the missing popup.
2. **Heavy template.** grilling.md "Round shape" prescribes `### Situation` with four labelled sub-blocks and one `###` per question. The rounds the user accepted earlier were compact: `## Round N`, a `**Situation**` block of marker lines, one `❔ Open decision:` paragraph per question. The heavy template plus tables made the redo hard to read.
3. **Verbatim logging skipped.** The rule exists in grilling.md "Record every round" but the checklist in SKILL.md does not restate it, and the first Round 1 wrote "see chat" into the log.

## 2. Scope

Owned files:

- `.agents/skills/brainstorming/references/grilling.md` — "Round shape" section rewritten; new final step "Collect the answers".
- `.agents/skills/brainstorming/SKILL.md` — "Grilling in short" gains the form bullet; checklist step 3 restates verbatim logging.
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1` — tokens for the new contract.
- `openspec/specs/harness/core/spec.md` (via sync) — MODIFIED "Two-tier exploration": scenario "Shape a major change before planning" adds the answer form and compact-round detail.

Non-goals: markers.md (unchanged), naming.md, drafts.md, deep-exploration.md, the task-card-format design.

## 3. Round shape (replaces grilling.md "Round shape")

```markdown
## Round <N> — <topic>

**Situation**

📌 Pinned fact: <what was inspected and what it showed> 🔗 Source: `<path:line>`
📌 Pinned fact: <...>
✅ Settled: Q<i> — <accepted decision>
❌ Dropped: Q<j> — <rejected path, reason>
⏳ Held: <decision> — <what it waits on>
Why now: <branch that just unblocked>. Still blocked: <branches waiting on this round>.

**How it works today** — only when the round touches code; full text in `findings/<topic>.md`, the round keeps purpose, chain tree and simplified code.

**Overall recommendation**: <the answer set if the user says "all recommendations">.

❔ Open decision: **Q<m> — <title>** ⭐ Heavyweight

- **A.** <option — trade-off>
- **B.** <option — trade-off>

👉 Recommendation: **A** — <reason>.
❗ Flip condition: <evidence that would reverse it>.

❔ Open decision: **Q<n> — <title>** ✨ New: <what unblocked it>

- **A.** <option>
- **B.** <option>

👉 Recommendation: **A** — <reason>.
```

Rules:

- One `##` for the round; no `###` per question. Each question is one `❔ Open decision:` paragraph followed by its option bullets and two marker lines.
- Options are `- **A.**` bullets, one line each; a consequence needing more goes in an indented sub-bullet. Never indent option lines with four spaces (chat renders that as a code block).
- Markers keep their plain-text labels per markers.md; one marker per line.
- Situation lines are short; long evidence goes to `findings/` and is linked. A decision matrix with more than ~6 rows goes to `findings/` too, with the round listing only the rows the user is likely to change.
- Blank line between blocks.

## 4. Collect the answers (new final step of every round)

After the written round is sent, issue the same questions through the host's structured question form (`AskQuestion` in Cursor): one form question per `❔ Open decision:`, the same letters and titles, the recommended option first and suffixed `(Recommended)`, `allow_multiple` only when the question allows several picks. The written round is the brief the form points at; a form alone is never a round. If the form is cancelled or the host has no form, accept the answers as text and continue. Record form answers in `log.md` exactly as returned.

## 5. Verbatim logging restated

SKILL.md checklist step 3 adds: "Paste the round into `log.md` exactly as sent, before or immediately after sending; paste the user's reply exactly as written."

## 6. Specification delta

MODIFIED `harness/core` requirement "Two-tier exploration", scenario "Shape a major change before planning": the detail block adds that the round is compact Markdown with the marker vocabulary, that its questions are also issued through the host's structured answer form when one exists (matching letters, recommended option first), that a cancelled form falls back to a text reply, and that the round and the reply are logged verbatim in the draft.

## 7. Verification

- Skill validator on `.agents/skills/brainstorming`.
- Scoped `OpenSpecSkill.Tests.ps1` with tokens: grilling.md contains `AskQuestion`, `(Recommended)`, `Collect the answers`, `never a round`, `- **A.**`, `Never indent option lines`; SKILL.md contains `AskQuestion`, `exactly as sent`.
- `Protocol.Tests.ps1` temp copy.
- `openspec.validate <change> --strict`, `openspec.validate harness/core --type spec --strict` after sync.

## Self-review

No placeholders; scope fits one Change; no new public type names beyond the Change ID and two terms; the spec delta touches one scenario only.
