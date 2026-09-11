---
name: openspec-create-change
description: Create the target OpenSpec Change from an approved brainstorming draft and carry the draft's confirmed material into it — design/handoff copies, talks, knowledge candidates, and INDEX — then hand the empty Change to openspec-continue-change. Use once per draft; never use it to write proposal, specs, design, or tasks.
---

# Create a Change from a Draft

This Skill owns `change create` and the one-time move of draft material into the new Change. It sits between `brainstorming` (which only writes the draft) and `openspec-continue-change` (which only writes the next planning artifact).

```text
draft status: designed ──► openspec-create-change ──► Change exists, attachments seeded ──► openspec-continue-change (proposal)
```

## Preconditions

1. The draft `openspec/drafts/<domain>/<topic>/README.md` has `status: designed`. `exploring` means the user has not approved the design — go back to `brainstorming` in an attended session; `parked` or `abandoned` means no Change is wanted.
2. `handoff.md` has an `OpenSpec Handoff` section naming the Change ID and capabilities, and an `Exploration Carryover` section whose talk and knowledge candidates the user confirmed in the final brainstorming round (each entry: source in the draft, target, reason).
3. The Change ID follows `<domain>/<type>-<scope>-<outcome>` per the [record schema](../openspec/references/record-schema.md) and was settled in the draft `glossary.md`. A missing or unconfirmed ID is a naming decision; do not invent one here — unattended continuation stops and reports.

## Steps

1. Import Harness once and run `openspec.change create <id> --title <title> --json` in the selected workspace. Harness rejects a nonconforming ID before the CLI runs. Never hand-create `change.yaml`.
2. Copy the draft `design.md` and `handoff.md` verbatim into `attachments/drafts/`.
3. Materialize the confirmed carryover list, nothing more:
    - Each **Talk candidate** becomes `attachments/talks/talk-YYYYMMDD-HHmmss-<theme>.md` with Context, Evidence, Options, Settled Decision, Consequences and Flip Condition, Visual (only if decision-critical), and Sources. Sources cite the draft path and the round heading in `log.md` or the file under `findings/`. Change records are English: paraphrase the user's intent and point to the log entry that holds the original wording instead of quoting it.
    - Each **Knowledge candidate** becomes `attachments/knowledges/<theme>.md` with Reusable Insight, Evidence, Boundaries, Application, and Sources, disposition `candidate`, per the [knowledge contract](../openspec/references/knowledge.md).
    - Items the user did not confirm stay in the draft. Do not paste `log.md` or round navigation into the Change.
4. Write `attachments/INDEX.md` per the [attachment contract](../openspec/references/attachments.md): current position ("created from draft `<path>`; next artifact proposal"), hard conclusions and forbidden items lifted from the handoff, and every attachment file indexed exactly once with a one-line reason to load it.
5. Set the draft `README.md` to `status: handed-off`, `handed_off: <date>`, `target_change: <id>` per the [draft contract](../brainstorming/references/drafts.md). `log.md`, `findings/`, and `glossary.md` stay in the draft only.
6. Run strict change validation and the Harness attachment audit, then invoke `openspec-continue-change` for the proposal.

## Boundaries

- One draft, one Change, one invocation. A second Change from the same draft needs its own confirmed handoff section.
- Do not write proposal, specs, design, or tasks here; do not edit the draft beyond its README status.
- A Change created without a draft (clear fix, mechanical documentation) skips this Skill: `openspec-continue-change` states the skipped-gate assumption in the proposal and no `attachments/drafts/` is created.
- Unattended continuation may run this Skill only when the preconditions already hold; it never confirms carryover or names the Change itself.
