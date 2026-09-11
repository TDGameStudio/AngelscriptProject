# INDEX

## Current position

Change created 2026-09-11 18:27 from the designed draft `harness/cases-expression` (local, git-ignored; every cited file is copied under `attachments/drafts/`, nothing links back to `openspec/drafts/`). Carryover confirmed in Round 4 (talk + one knowledge; the example finding is copied because the design cites it). Proposal, specs delta, root `design.md` (current truth; the draft copy below keeps the approved shape) and `tasks.md` (3 cards) written 18:35; all 3 tasks done 18:50; spec sync and archive pending user direction.

## Hard conclusions

- Case header `N. **Name** — <role> · <kind>` is the only line preflight reads; the body is free Markdown carrying literal input, derived expectation and a named oracle.
- Standard roles `new RED` / `existing control` / `boundary` / `deferred RED until X.Y`; kinds open with a seven-entry catalog; any custom role or kind is legal once defined in `Roles:` / `Kinds:`.
- Tables only inside `example-table`; sequence steps are observations, not work items; one `Setup:` paragraph; `Replaces:` is prose lineage.
- No parser or CLI change; the packaged `openspec 0.10.0` is the parser-neutrality control.

## Forbidden

- Do not edit other Changes' Cases; do not add a `manual` kind; do not reintroduce a closed role vocabulary.
- Do not reference `openspec/drafts/` from any Change file.

## Attachment index

- drafts/design.md — approved design (§3 shape and header grammar, §4 roles, §5 kind catalog, §6 TDD mapping, §7 owned files) — read before writing the contract, preflight text, or tests.
- drafts/handoff.md — decision-complete handoff — read when checking scope, owned files, task boundaries, or carryover.
- drafts/glossary.md — settled names (Change ID, header form, role words, catalog kinds, `Setup:` / `Roles:` / `Kinds:` / `Replaces:`, `cases.md`) — read before naming anything in this Change.
- drafts/findings/case-forms-landscape.md — needs observed in active plans × available forms, with the strain table — evidence for the proposal's Why.
- drafts/findings/example-open-shapes-card.md — filled Cases block exercising seven shapes on one feature — seed for the `cases.md` examples and the Authoring test fixture.
- data/planning-validation.md — self-review of this plan (machine checks, three items, deviations) — evidence for task 3.1.
- talks/talk-20260911-182700-open-shape-cases.md — Rounds 1–4 decisions, rejected paths and the openness correction — read before proposing to close the vocabulary or ban tables again.
- knowledges/case-forms-landscape.md — candidate: match a case's expression form to what it must say; mis-shape signals — read before authoring or reviewing any Cases block.
