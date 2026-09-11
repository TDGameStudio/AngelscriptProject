# Compact grill rounds with a structured answer form

## Why

A real design round run under the `brainstorming` Skill (task-card-format draft, Round 1) exposed three gaps. The Skill never requires the host's structured question form, so a round can be sent as prose with no way for the user to answer by selection; the user noticed the missing popup immediately. The `grilling.md` "Round shape" template prescribes one `###` per question and four labelled Situation sub-blocks, heavier than the compact marker-line form the user had accepted in every earlier round. The verbatim-logging rule lives only in `grilling.md` and was skipped in practice.

## What Changes

Rewrite the "Round shape" section of `.agents/skills/brainstorming/references/grilling.md` to the compact template: one `##` per round, `**Situation**` marker lines, `**Overall recommendation**`, one `❔ Open decision:` paragraph per question with `- **A.**` option bullets, `👉 Recommendation:` and `❗ Flip condition:` lines; large decision matrices move to `findings/`. Add a final step "Collect the answers": issue the same questions through the host's structured answer form (`AskQuestion` in Cursor) with matching letters and the recommended option first suffixed `(Recommended)`; a form alone is never a round; a cancelled or missing form falls back to text. In `.agents/skills/brainstorming/SKILL.md`, add the form bullet to "Grilling in short" and restate verbatim logging in checklist step 3. Update `OpenSpecSkill.Tests.ps1` tokens. Modify the `harness/core` scenario "Shape a major change before planning" so the durable contract names the answer form, the compact round, and the verbatim log.

## Impact

Owned paths: `.agents/skills/brainstorming/SKILL.md`, `.agents/skills/brainstorming/references/grilling.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/specs/harness/core/spec.md` (via delta sync).

Non-goals: `markers.md`, `naming.md`, `drafts.md`, `deep-exploration.md`, the task-card-format design, baseline test or spec debt outside the owned files, immutable archives. Parent repository only.
