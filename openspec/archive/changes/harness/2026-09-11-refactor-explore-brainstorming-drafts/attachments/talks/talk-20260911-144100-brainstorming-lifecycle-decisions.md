# Talk: three user-owned decisions that shaped the brainstorming lifecycle

## Context

The `openspec-explore` to `brainstorming` refactor was driven by three complaints: discussion did not accumulate, the agent confirmed requirements vaguely and started implementing, and Change talks were weak. Three rounds in `openspec/drafts/harness/brainstorming-drafts/log.md` settled the shape of the fix. Each decision had a plausible alternative that a future agent could re-open; this talk records why it should not.

## Evidence

- No Skill owned `change create`; `openspec-continue-change` assumed the Change already existed and draft carryover was jammed into its step 5 against its one-artifact contract (Round 3 brief).
- The old `question-rounds.md` only opened a round at three or more decisions, so most requests were never grilled (Round 1 brief).
- Apply-stage naming stops and Codex `/goal` boilerplate had spread to seven files (Round 2 brief).

## Options

| Decision | Chosen | Rejected |
| --- | --- | --- |
| Where the exploration record lives | C: draft persists under `openspec/drafts/`, Change gets copies of `design.md` and `handoff.md` only | A: move the draft into the Change; B: keep both as independent originals |
| Questions during execution | Apply never asks; unlisted names become `Naming assumed`, user-owned findings go to `openspec-update-change` replan | Interactive naming grill inside apply; unattended run opening `brainstorming` |
| Change creation | Dedicated `openspec-create-change` Skill: create + seed drafts/talks/knowledge/INDEX | Step 0 of `openspec-continue-change`; brainstorming creating the Change itself |

## Settled Decision

- The draft is the durable owner of the conversation; the Change never becomes a parallel transcript.
- Execution is question-free; every question to the user is a grill round with a situation brief, and rounds only happen in attended brainstorming or the next attended session after a replan.
- `openspec-create-change` is the only route that turns a designed draft into a Change, and it materializes exactly the carryover the user confirmed in the final brainstorming round.

User's framing of the third point (Round 3, paraphrased; original wording is in the draft `log.md` 14:27 entry): brainstorming is exploration, and everything explored is written to the draft stage; formal Change creation then mines the draft for talk and knowledge material, so it should be its own Skill linked to brainstorming.

## Consequences and Flip Condition

- Consequence: three lifecycle Skills now sit before apply (`brainstorming`, `openspec-create-change`, `openspec-continue-change`); a draft may also end `parked` or `abandoned` with no Change.
- Flip: if Skill count becomes a burden, fold creation back into `openspec-continue-change` as an explicit step 0 that runs only when no Change exists. If the `Naming assumed` review at verify keeps rejecting names, reintroduce a naming checkpoint in task authoring, not in apply. If `parked` drafts pile up unattended, add a `harness.status` count.

## Sources

- `openspec/drafts/harness/brainstorming-drafts/log.md` — Round 1 (13:0x, draft lifecycle), Round 2 (14:17–14:20, execution never asks), Round 3 (14:27–14:30, create-change Skill).
- `openspec/drafts/harness/brainstorming-drafts/design.md` — sections 3, 5a, 5b.
- `openspec/drafts/harness/brainstorming-drafts/glossary.md` — settled names.
