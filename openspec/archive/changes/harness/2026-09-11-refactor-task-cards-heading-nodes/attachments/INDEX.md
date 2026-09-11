# INDEX

## Current position

Change created 2026-09-11 from the designed draft `harness/task-card-format`. The draft is local and git-ignored, so every file this Change cites is copied under `attachments/drafts/`; nothing links back to `openspec/drafts/`. Carryover confirmed in Round 5 and materialized below. Proposal, specs delta and tasks are written. `0.10.0` is packaged (submodule `0a39409`, tag `v0.10.0`); this Change's own `tasks.md` and root design are written in the heading-node form. The root design is the current design truth; the draft copy below keeps the approved shape. All 8 tasks done 2026-09-11 18:02. Spec sync 18:08: the five MODIFIED `harness/core` requirements merged into `openspec/specs/harness/core/spec.md` (18 same-name scenarios replaced, `Block a thin card at apply time` added, 5 unspecified carryover scenarios preserved); `openspec.validate harness/core --type spec --strict` Succeeded. Archive authorized by the user 18:02 (original wording in the draft log); closure `completed`.

## Hard conclusions

- A task node is `## [ ] X.Y Title`; body unindented; the root-checkbox list format retires with no dual parser.
- `**Files**` is a diff-marked tree fence; `files[]` stays plain paths, `file_roles[]` is added.
- Cards carry a stage-level outcome, Interfaces, named Cases (Given / When / Then), Files, Verification; no step-level TDD.
- Migration of the 7 active plans is syntax-only; thin cards are blocked by apply preflight until their owning Change updates them.

## Forbidden

- Do not add a compatibility parser for the list format or rewrite archived records.
- Do not enrich other Changes' cards (interfaces, cases) inside this Change.
- Do not commit the submodule, tag, or swap the packaged EXE without explicit user authorization.

## Attachment index

- drafts/design.md — approved design (§3 parser contract, §4 header, §5 card contract and preflight, §7 migration) — read before editing the parser, the contract, or any plan.
- drafts/handoff.md — decision-complete handoff — read when checking scope, owned files, sequencing, or carryover.
- drafts/glossary.md — settled names and their sources (Change ID, `file_roles`, labels, header sections, file names) — read before naming anything in this Change.
- drafts/findings/current-task-format-audit.md — audit of the 7 active plans (format, Ready count, cases, interfaces, steps) — evidence for the problem statement and the migration list.
- drafts/findings/delegates-tasks-review.md — card-by-card review of `angelscript/feature-delegates-ue-interop/tasks.md` — evidence for the "finish the design" smell and the example card.
- drafts/findings/writing-plans-comparison.md — idea-by-idea comparison with superpowers `writing-plans` — source of the provenance knowledge.
- data/planning-validation.md — self-review of this plan (machine checks, three self-review items, recorded deviations) — evidence for task 3.2.
- data/migration-baseline.md — pre-migration ID sets, done sets and graph key counts of the 7 active `angelscript/*` plans, plus the post-migration check — evidence for task 3.1.
- drafts/example-heading-card.md — worked example: delegates plan header and task 2.2 in the new format — seed for the contract's filled example.
- talks/talk-20260911-171700-heading-node-task-cards.md — decisions D1–D8 with the rejected paths (keep machine surface, dual parser, table Cases, three Changes) — read before proposing a format alternative.
- knowledges/task-plan-audit-method.md — candidate: four-count executability audit and the "finish the design" smell — read before accepting or migrating any plan.
- knowledges/writing-plans-provenance.md — candidate: idea-by-idea adopt/adapt/reject reading of superpowers `writing-plans` — read before adapting other external planning guidance.
