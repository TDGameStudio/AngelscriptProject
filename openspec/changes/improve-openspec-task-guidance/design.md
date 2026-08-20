## Context

See `proposal.md` for why. Current generation path is `.agents/skills/openspec-work/SKILL.md` plus whatever the agent remembers from `AGENTS.md`. Official OpenSpec injects `context` / `rules` only from `openspec/config.yaml`, which this repo does not have. Superpowers `writing-plans` already defines executable-plan quality, but it is a separate skill and is skipped when `openspec-work` says start lean.

Catalog routing: `attachments/INDEX.md`. Discussion stays in `attachments/planning/` and is not apply context. Apply reads `attachments/implementation/` only, plus main artifacts. Spec Kit clone stays gitignored `Reference\spec-kit`, documented only under planning.

## Goals / Non-Goals

**Goals:**

- Make generated `tasks.md` executable by a later session that has not seen the chat.
- Put the quality bar in OpenSpec's official injection path so `/opsx:propose` and `openspec-work` cannot silently ignore it.
- Steal Spec Kit's hard task rules (path, grouping, independent test, parallel definition, generate-then-self-check) without adopting Spec Kit.

**Non-Goals:**

- Migrating to Spec Kit or running both toolchains.
- Installing community schemas wholesale (`superpowers-bridge`, `anvil`, `intent-driven`).
- Rewriting historical active or archived changes.
- Making every chore/docs change as thick as a feature.
- Pasting full code blocks into every checkbox. Title stays short; Files/Impact/Tests are indented fields, not a writing-plans micro-plan.

## Decisions

### Decision: Keep OpenSpec; steal Spec Kit task contract

Spec Kit's value here is the `/speckit.tasks` format and `/speckit.implement` consumption rules, not its feature-folder or constitution files. This repo already has delta specs, archive merge, and a large `openspec/specs/` tree.

Alternatives considered: switch to Spec Kit (loses delta/archive, huge migration); run both (two instruction sets in one agent context). Rejected.

### Decision: Two injection surfaces, same contract

1. `openspec/config.yaml` `rules.tasks` and `operations.apply.guidance` — official prompt injection.
2. `openspec-work` — stop authorizing start-lean for `feature` / `fix` / `refactor` / `improve` / `test`. Keep lean only for `chore` / `docs` unless the user asks for a plan-only deliverable.

If only the skill changes, `/opsx:propose` stays thin. If only config changes, the skill's "start lean" still wins. Both must agree.

### Decision: Keep `1.1` numbering; map Spec Kit labels onto this repo

Keep hierarchical `1.x` checkboxes so existing apply parsing and human habit stay. Do not rename to `T001`.

Map:

| Spec Kit | This repo |
|---|---|
| `[USn]` | capability or `### Requirement:` name from the change's delta spec |
| `[P]` | keep the marker, same definition (different files, no unfinished deps) |
| User-story phase | independently deliverable increment with an Independent Test sentence |
| Foundational phase | blocking prerequisites group |
| Independent Test | one sentence per group |
| constitution | `config.yaml` `context` plus existing test conventions in the skill |

### Decision: Depth by change type

- `chore` / `docs`: short tasks allowed; path + done condition still required.
- `feature` / `fix` / `refactor` / `improve` / `test`: full contract (paths, trace, TDD/Non-TDD, verification command, group Independent Test, parallel markers).
- Plan-only sessions: Superpowers `writing-plans` quality, then stop.

### Decision: Multi-line task body, one checkbox

OpenSpec still parses one `- [ ]` per task. Title stays short. `Files`, `Impact`, `Tests`, `Verify`, `Requirement` are indented under it. Do not pack those fields into the title line. Template: `attachments/implementation/task-body-template.md`.

### Decision: Planning notes vs apply notes are isolated

`attachments/planning/` records the discussion. `attachments/implementation/` is the apply working set (`issues.md`, `progress.md`, task template, OpenSpec-refactor log). Apply does not read planning unless stuck, and then only one file. This is a token rule, not optional courtesy.

### Decision: Mid-apply OpenSpec refactors are first-class

If implementation changes OpenSpec layout, task format, skill, or config, append `attachments/implementation/openspec-refactors.md` and update specs/tasks in the same session.

### Decision: Progressive issues stay out of `tasks.md`

Planning issues: `attachments/planning/issues.md`. Apply issues: `attachments/implementation/issues.md`. Checkboxes only flip `[x]`.

### Decision: Record now, implement later

This session only writes artifacts and attachments. Skill and `config.yaml` edits are later tasks on this same change.

## Risks / Trade-offs

- [Rules are advisory] → OpenSpec does not fail validate when a task lacks a path. Mitigation: skill must treat missing fields as "do not apply"; later optional hook/CI if still ignored.
- [Thicker tasks cost tokens] → Mitigation: depth by type; keep notes out of checkboxes.
- [Agents ignore two sources if they conflict] → Mitigation: config and skill must state the same bar; remove "start lean" from feature/fix/refactor.
- [Over-copying Spec Kit phases] → Mitigation: no greenfield Setup theater; Foundational only when something actually blocks all later groups.

## Open Questions

- Whether to fork `spec-driven` into `openspec/schemas/angelscript/` so the tasks `instruction` itself is thick, or rely on `config.yaml` rules on top of stock `spec-driven`. Default: config first; fork only if rules are still ignored.
- Whether apply should default to one group per session (Spec Kit phase checkpoint / community apply-one). Recommend yes for feature/fix/refactor; confirm when implementing.
