---
name: brainstorming
description: "Explore proposals, trade-offs and unresolved design decisions in a continuing local draft. Explain before asking, preserve conversation, and hand off one approved scope when OpenSpec is selected. Respect authorized direct work; existing Changes use update/apply."
---

# Brainstorming

- Open or resume one topic under `openspec/drafts/<domain>/<topic>/` through `harness.draft.create` / `harness.draft.status`. Use [drafts.md](references/drafts.md) for its records and recording setup.
- Open a draft for a proposal, trade-off or more than one diagram. A factual answer outside continuing exploration needs none. Announce `Draft opened: <path> (mode: <mode>)` once.
- Keep one deliverable by default. Create `designs/<scope>/` when an outcome can be described; split only independently deliverable outcomes. Alternatives for one outcome stay together.
- Topic mode follows current work: `research` investigates, `proposal` develops a candidate, `design` resolves its decisions. Each scoped design owns its approval separately; researching another subject does not revoke it.

## Explain, ask, update

1. Inspect the relevant code, specifications and evidence; resolve repository facts yourself.
2. Before a question tool, send a visible situation brief: what is settled, what remains, the evidence, what the options change and your recommendation. Simple decisions need little text; unfamiliar technical choices need sufficient explanation. Later rounds focus on what changed.
3. Ask the unblocked frontier: related independent decisions may share a round; dependent questions wait. Use [grilling.md](references/grilling.md) for answer collection. A file link or form alone is not an explanation.
4. Reflect the answers in chat, update the owning design and the README's five current fields, and continue unblocked work. On correction or resumption, replace stale current conclusions while preserving their original sources and superseded decisions in the append-only log.
5. Present meaningful design revisions before seeking missing approval. Confirm new public names using [naming.md](references/naming.md); recommendations, silence and sibling approval are not acceptance.

- Explain call chains, workflow or ownership with [visual-explain](../visual-explain/SKILL.md) when useful; preserve displayed diagrams with the discussion. Scale detail to the decision.
- Keep instructions and draft navigation in concise Markdown lists. New draft prose uses the user's conversation language; original conversation stays verbatim. Change output is English.
- Bind the exact session and draft with `harness.draft.record` when its source is supported. Hooks record delivered messages; inspect coverage on resume and before handoff. With no working hook, reconcile delivered messages before questions/final and next turn's entry; the current unsent final remains pending. See [recording checkpoints](references/drafts.md#recording-checkpoints).

## Select the authorized route

- An approved plan or clear defect repair with no unresolved user-owned choice can proceed directly; state the assumption. Honor an explicit no-Change instruction without another approval ceremony.
- For unresolved design work, obtain approval for the actual scope before implementation. A topic mode or directory is not authorization.
- When OpenSpec is selected, confirm the selected scope's names and carryover, then write its [handoff](references/deep-exploration.md). Record explicit `approval_round`, exact scope and Change identity; pass `harness.draft.check` before `openspec-create-change`.
- One scoped handoff creates one Change. Creation exports English attachments; Ensure plan builds the Task DAG. Mark only that scope handed-off after seed verification; other research can continue.
- An existing Change never reopens design-mode brainstorming: use `openspec-update-change` for invalidated planning and `openspec-apply-change` for task-local uncertainty.
- Park with a resumption condition, or abandon with a reason. Archive only on explicit `harness.draft.archive`; preserve legacy records per the draft contract.
- Unattended continuation (Codex `/goal` is defined by Harness) never opens brainstorming. A new user-owned decision is parked through the Change's replan route.
