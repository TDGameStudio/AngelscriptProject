---
name: brainstorming
description: "Explore proposals, trade-offs and unresolved design decisions in a continuing local draft. Explain before asking, preserve conversation, and hand off one approved scope when OpenSpec is selected. Respect authorized direct work; existing Changes use update/apply."
---

# Brainstorming

- Open or resume one topic under `openspec/drafts/<domain>/<topic>/` through `harness.draft.create` / `harness.draft.status`.
  - Use [drafts.md](references/drafts.md) for its records and recording setup.
- Open a draft for a proposal, trade-off or more than one diagram.
  - A factual answer outside continuing exploration needs none.
  - Announce `Draft opened: <path> (mode: <mode>)` once.
- Keep one deliverable by default.
  - Create `designs/<scope>/` when an outcome can be described; split only independently deliverable outcomes.
  - Alternatives for one outcome stay together.
- Topic mode follows current work: `research` investigates, `proposal` develops a candidate, `design` resolves its decisions.
  - Each scoped design owns its approval separately; researching another subject does not revoke it.

## Explore with Grill

- Call the independent [grill](../grill/SKILL.md) with this draft/design as its record owner and a return position.
  - It owns impact discovery, visible explanation, frontier questions and answer collection.
- Update the owning design and the README's five current fields after answers or corrections.
  - Preserve original sources and superseded decisions in the append-only log, then continue unblocked work.
- Present meaningful design revisions before seeking missing approval.
  - Confirm public names using [naming.md](references/naming.md); recommendations, silence and sibling approval are not acceptance.
- Keep instructions and draft navigation in concise Markdown lists.
  - New draft prose uses the user's conversation language; original conversation stays verbatim.
  - Change output is English.
- Bind the exact session and draft with `harness.draft.record` when its source is supported.
  - Hooks record delivered messages; inspect coverage on resume and before handoff.
  - With no working hook, reconcile delivered messages before questions/final and next turn's entry; the current unsent final remains pending.
  - See [recording checkpoints](references/drafts.md#recording-checkpoints).

- A completed round or design is a return point, not automatic session termination.
  - Continue the caller's already authorized next step; retain required unanswered decisions without inventing approval.

## Select the authorized route

- An approved plan or clear defect repair with no unresolved user-owned choice can proceed directly; state the assumption.
  - Honor an explicit no-Change instruction without another approval ceremony.
- For unresolved design work, obtain approval for the actual scope before implementation.
  - A topic mode or directory is not authorization.
- When OpenSpec is selected, confirm the selected scope's names and carryover, then write its [handoff](references/deep-exploration.md).
  - Record explicit `approval_round`, exact scope and Change identity; pass `harness.draft.check` before `openspec-create-change`.
- One scoped handoff creates one Change.
  - Creation exports English attachments; Ensure plan builds the Task DAG.
  - Mark only that scope handed-off after seed verification; other research can continue.
- An existing Change uses `openspec-update-change`, which calls `grill` with a Change-owned talk and returns to execution; it does not reopen design-mode brainstorming.
- Park with a resumption condition, or abandon with a reason.
- Archive only on explicit `harness.draft.archive`; preserve legacy records per the draft contract.
- Unattended continuation (defined by Harness) never opens brainstorming.
  - A new user-owned decision stays open in its Change discussion until actual answers arrive.
