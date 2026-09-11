## Context

Current planning truth for folding `openspec-continue-change` into `openspec-apply-change`; `attachments/drafts/design.md` is the approved draft copy and this file supersedes it where they differ. Names in `attachments/drafts/glossary.md`; decisions in the draft rounds summarized in `attachments/drafts/handoff.md`.

## Problem

`openspec-continue-change` was written when deliberation happened inside the Change, one artifact per round. `brainstorming` moved deliberation upstream and `openspec-create-change` now seeds a decision-complete handoff, so continue-change only reformats the handoff into proposal / specs / design / tasks, is fast-forwarded on every real run, and carries a third copy of the preflight (tasks.md `### Preflight`, continue plan-acceptance, apply task-start). Five Skill files, three preflights and a routing table entry exist for one mechanical step.

## Goals and non-goals

Goals: one Skill (`openspec-apply-change`) takes a Change from "created" to "implemented"; one preflight text in `tasks.md` that apply links at two moments; planning keeps its authority mode (stop on a missing user-owned decision) separate from implementation's (never ask).

Non-goals: changing `openspec-create-change`, `openspec-update-change` or `openspec-archive-change` scope; any CLI change (`openspec.status` / `openspec.instructions` stay the mechanics); changing the artifact set or templates; rewriting archived records.

## Shape of the merged Skill

```
openspec-apply-change
├ 0. Ensure plan                                  // NEW, absorbed from continue-change
│   ├ openspec.status --change → missing artifacts
│   ├ from a draft-created Change: expand attachments/drafts/handoff.md + design.md into proposal, specs (durable behavior only), design (non-obvious decisions only), tasks
│   ├ from a draft-less Change (clear fix, mechanical docs): write proposal + tasks from the request; state the skipped-gate assumption in the proposal
│   ├ never reopen design mode; a new non-obvious decision → one indexed talk in the same edit; never paste log.md
│   ├ names: settled names from glossary.md; an unsettled public name is a planning stop, not a Naming assumed
│   ├ plan-acceptance preflight = tasks.md ### Preflight; failing plan → repair here (nothing is "existing truth" yet) or via openspec-update-change once accepted
│   └ AUTHORITY: a missing user-owned decision stops and reports; unattended continuation never invents it
├ 1. task.status, choose Ready                    // existing
├ 2. task-start preflight = tasks.md ### Preflight // existing, now a link
├ 3–6 TDD, Evidence, Naming assumed, validate      // existing; AUTHORITY: never asks
```

Step 0 runs whenever `openspec.status` reports a missing required artifact, and is skipped otherwise. Fast-forward is the default (that is what happened on every run); the one-artifact cadence is retired.

## Preflight consolidation

`tasks.md ### Preflight` becomes the single text: header sections; labels per card kind in order; behavior card ≥1 `new RED` and an Interfaces fence when it names a symbol; every case header matches the `cases.md` grammar; non-standard role/kind words defined in `Roles:` / `Kinds:`; `deferred RED` targets in `task_graph`; tables only inside `example-table`; no forbidden phrase; `planning-validation.md` recorded and indexed (plan acceptance only). It names the two moments: plan acceptance (apply step 0) and task start (apply step 2). `cases.md` §"How TDD and preflight consume" points at it instead of naming two Skills.

## Ripple (owned files)

```diff
-.agents/skills/openspec-continue-change/            # git rm (SKILL.md only)
 .agents/skills/openspec-apply-change/SKILL.md       # step 0 Ensure plan; preflight sentences → links; description updated
 .agents/skills/openspec/references/tasks.md         # ### Preflight single text with two moments
 .agents/skills/openspec/references/cases.md         # preflight sentence names moments, not Skills
 .agents/skills/openspec-create-change/SKILL.md      # hands the Change to openspec-apply-change step 0; draft-less note
 .agents/skills/harness/SKILL.md                     # flow line and handoff bullet
 .agents/skills/harness/references/routing.md        # drop row 21; row 18 "before openspec-apply-change"
 .agents/skills/README.md                            # drop bullet
 .agents/skills/openspec/SKILL.md                    # lifecycle list
 .agents/skills/brainstorming/SKILL.md               # end-state chain (2 places)
 .agents/skills/brainstorming/references/naming.md   # shared-by list
 .agents/skills/brainstorming/references/deep-exploration.md
 .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1  # continueText removed; continue tokens move to applyText; required-entry list; mode-free list; link map
 openspec/README.md, README.md                       # lifecycle sentences
 openspec/changes/<change>/specs/harness/core/spec.md  # MODIFIED "Exploration markers and durable carryover" (two mentions → openspec-apply-change step 0)
```

Archived records keep their historical references untouched.

## Verification

Scoped `OpenSpecSkill.Tests.ps1` over openspec, apply, create, brainstorming, harness references, READMEs, config; `Test-Path` negative for the removed directory; strict validation of the Change; `harness/core --type spec --strict` after sync. RED: tokens for step 0 in apply and absence of the directory fail before the edits.

## Vocabulary and naming

Change ID `harness/refactor-apply-change-absorb-planning` (to confirm). Step heading `Ensure plan` (internal wording, not a public name). No new files or public names.

## Self-review

Placeholders none. The one contradiction (apply "never asks" vs planning "stops on a missing decision") is resolved by scoping the two authority modes to steps 0 and 1–6 explicitly. Scope: Skill wording, tests, spec delta; no CLI.
