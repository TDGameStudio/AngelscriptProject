# Talk: grill rounds collect answers through the host form and use the compact template

- Captured: 2026-09-11
- Source: brainstorming draft `openspec/drafts/harness/brainstorming-round-form/` (local, git-ignored), itself split from Round 1 of `openspec/drafts/harness/task-card-format/`; original wording in their `log.md`.
- Requested by: user, while a real design round on the task-card format was running; the user framed that round as the real task through which brainstorming itself is iterated.

## Context

The first design round of the task-card-format draft was sent as a plain numbered list: no markers, no `AskQuestion` form, and the draft log said "see chat". The user asked why there was no popup, whether the grilling flow had been followed, and whether `markers.md` had disappeared.

## Evidence

- `brainstorming/SKILL.md` and `references/grilling.md` never required the host's structured question form; grilling.md only said a bare form must not replace the brief. Every earlier accepted round in the session had used the form by habit.
- `grilling.md` "Round shape" prescribed a `###`-per-question template with four labelled Situation sub-blocks; the rounds the user had accepted earlier were compact (`## Round N`, marker lines, one `❔ Open decision:` paragraph per question).
- `markers.md` was intact and linked from `SKILL.md:64` and `grilling.md:92,142`; the marker vocabulary had simply not been used.
- Four-space-indented `A.` option lines in the earlier compact form render as code blocks in chat; `- **A.**` bullets do not.

## Options considered

- A. Make the answer form a required last step of every round; return the template to the compact form with bullet options; restate verbatim logging in the SKILL checklist. **Chosen.**
- B. Keep the heavy template and only add the form. Rejected: the user pointed at the earlier compact form as the one that worked; the redo in the heavy template with a 15-row table was hard to read.
- C. Fold the repair into the task-card-format Change. Rejected: different scope; the Skill repair should land before the next design round runs.

## Settled decisions

| # | Decision |
|---|---|
| D1 | Every round ends by issuing its questions through the host's structured answer form (`AskQuestion` in Cursor) with matching letters, recommended option first and suffixed `(Recommended)`. A form alone is never a round; a cancelled or missing form falls back to text. |
| D2 | Round shape is the compact template: one `##` per round, `**Situation**` marker lines, `**Overall recommendation**`, one `❔ Open decision:` paragraph per question with `- **A.**` bullets, `👉 Recommendation:` and `❗ Flip condition:` lines. No `###` per question. |
| D3 | Large decision matrices go to `findings/`; the round lists only the rows the user is likely to change. |
| D4 | SKILL.md checklist step 3 restates verbatim logging so the rule is visible at the point of use. |
| D5 | Change name `harness/fix-brainstorming-round-form`. |
