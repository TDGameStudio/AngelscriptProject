# Fold planning-artifact creation into openspec-apply-change

## Why

`openspec-continue-change` was designed for a lifecycle in which deliberation happened inside the Change, one planning artifact per round. `brainstorming` moved deliberation upstream into drafts, and `openspec-create-change` now seeds a decision-complete handoff into the new Change. What remains for continue-change is mechanical: expand `attachments/drafts/handoff.md` and `design.md` into proposal, specs, design and tasks, then validate. On every real run this session it was fast-forwarded in one pass (`refactor-task-cards-heading-nodes`, `refactor-task-cases-open-shapes`). Meanwhile the plan preflight text exists three times: `tasks.md ### Preflight`, continue-change plan acceptance, apply task start. The user asked whether the Skill still needs to exist and chose to fold it into `openspec-apply-change` (draft `harness/lifecycle-skill-consolidation`, Round 1 Q1 A).

## What Changes

**`openspec-apply-change` gains step 0 `Ensure plan`.** When `openspec.status --change` reports a missing required artifact, apply writes the missing planning artifacts before selecting Ready nodes: from a draft-created Change it expands the seeded handoff and design (specs only for durable behavior, design only for non-obvious decisions); from a draft-less Change (clear fix, mechanical documentation) it writes proposal and tasks from the request and states the skipped-gate assumption in the proposal. It never reopens `design`-mode brainstorming, adds one indexed talk for a newly surfaced non-obvious decision, never pastes the draft `log.md`, and takes names from the copied `glossary.md`. Planning authority differs from implementation authority and the Skill says so: a missing user-owned decision or an unsettled public name stops step 0 and is reported (unattended continuation never invents it), while steps 1–6 keep "apply never asks" and `Naming assumed`. The one-artifact-per-invocation cadence is retired; fast-forward through all missing artifacts is the only mode.

**One preflight text.** `tasks.md ### Preflight` becomes the single list (header sections, labels per card kind, `new RED` and Interfaces fence, case header grammar, defined role/kind words, deferred targets in `task_graph`, tables only in `example-table`, forbidden phrases, `planning-validation.md` recorded and indexed at plan acceptance) and names its two moments: plan acceptance (apply step 0) and task start (apply step 2). Apply links it at both moments instead of restating it; `cases.md` names the moments, not two Skills.

**Retire the Skill.** `.agents/skills/openspec-continue-change/SKILL.md` is deleted. References move to apply step 0 in `openspec-create-change`, `harness/SKILL.md`, `routing.md` (row removed), `.agents/skills/README.md`, `openspec/SKILL.md`, `brainstorming/SKILL.md`, `naming.md`, `deep-exploration.md`, `openspec/README.md`, root `README.md`; `OpenSpecSkill.Tests.ps1` drops `$continueText`, moves the surviving contract tokens to `$applyText`, removes the Skill from the required-entry and mode-free lists, and asserts the directory is gone. Archived records keep their historical references.

**Specification.** `harness/core` MODIFIED "Exploration markers and durable carryover" (canonical truth enters planning artifacts through `openspec-apply-change` step 0; same-name scenario "Carry accepted exploration into a new Change" replaced) and "Ready-to-execute Task authoring" (the single preflight text and its two moments; new scenario "Plan a created Change inside apply").

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: "Exploration markers and durable carryover" — the Skill that turns the seeded handoff into planning artifacts is `openspec-apply-change` step 0. "Ready-to-execute Task authoring" — one preflight text in the task authoring reference, applied at plan acceptance and task start by `openspec-apply-change`; planning stops on a missing user-owned decision, implementation never asks.

## Impact

Owned paths: `.agents/skills/openspec-continue-change/SKILL.md` (delete), `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec/references/tasks.md`, `.agents/skills/openspec/references/cases.md`, `.agents/skills/openspec-create-change/SKILL.md`, `.agents/skills/harness/SKILL.md`, `.agents/skills/harness/references/routing.md`, `.agents/skills/README.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/brainstorming/SKILL.md`, `.agents/skills/brainstorming/references/naming.md`, `.agents/skills/brainstorming/references/deep-exploration.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/README.md`, `README.md`, `openspec/specs/harness/core/spec.md` (via sync). Parent repository only.

Non-goals: CLI changes (`openspec.status` / `openspec.instructions` stay the mechanics); the artifact set, templates or `config.yaml` rules; scope of `openspec-create-change`, `openspec-update-change`, `openspec-archive-change`; archived records; any Git commit without explicit user authorization.
