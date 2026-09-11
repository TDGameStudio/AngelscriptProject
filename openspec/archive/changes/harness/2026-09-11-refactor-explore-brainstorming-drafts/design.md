# Design

Source: `openspec/drafts/harness/brainstorming-drafts/design.md` (approved 2026-09-11); a copy is indexed at `attachments/drafts/design.md`.

## Decisions

1. **Drafts are a sibling of `changes/`, not an attachment type first.** Brainstorming happens before a Change exists, so the record must live where no Change identity is required. `openspec/drafts/<domain>/<topic>/` keeps it under `openspec/` while staying outside Harness Change scanning (`Harness.psm1` enumerates `openspec/changes` only) and outside portable-CLI validation. Alternative rejected: creating a placeholder Change to hold the discussion, which would violate the Brainstorm Gate and pollute Change identity.
2. **Drafts persist; the Change receives a copy.** The user chose to keep the full discussion discoverable independent of Change archive while still carrying the approved `design.md` and `handoff.md` in `attachments/drafts/`. The copy is indexed once in `INDEX.md`; the draft README records `target_change`. Talks and knowledge carryover are unchanged.
3. **Grilling replaces the question-round threshold.** Every unresolved user-owned decision is asked, in frontier rounds with a recommended answer. The agent still settles engineering facts itself. This directly targets the "confirmed vaguely, then implemented" failure.
4. **Naming is planned, then guarded.** Names are grilled during brainstorming and written into tasks' "Context and interfaces"; apply stops only when a required new public name is absent. Unattended Codex `/goal` continuation records `Naming assumed: <name>` so the flow does not deadlock.
5. **Language exception is explicit.** `design.md`/`handoff.md` stay English like every OpenSpec record; `log.md` and `findings/` may keep the user's original wording because they are working evidence, not maintained records.

## Boundaries and compatibility

- `deep-exploration.md` keeps its handoff heading set and `markers.md` is retained, so downstream carryover rules in `attachments.md`/`knowledge.md` do not change shape.
- `question-rounds.md` is removed; its marker vocabulary moves into `grilling.md`.
- Existing archived Changes and their talks are untouched. Tests that hard-code `openspec-explore` paths are updated to `brainstorming`.
- The global superpowers plugin also exposes a `brainstorming` skill. The project Skill's description names AngelscriptProject and `openspec/drafts/` to disambiguate; renaming to `openspec-brainstorming` remains the fallback.

## Rollback

Reverse the rename and restore `question-rounds.md`; delete `openspec/drafts/` guidance. Draft directories already written remain harmless plain Markdown.
