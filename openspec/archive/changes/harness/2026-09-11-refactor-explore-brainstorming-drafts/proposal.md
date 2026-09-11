# Brainstorming skill with persistent openspec drafts

## Why

Pre-Change discovery currently runs through the read-only `openspec-explore` Skill. Its contract discards the exploration transcript, so the reasoning behind a design survives only as isolated talk files written after the Change exists. Interactive question rounds fire only when at least three dependent user-owned decisions remain, so smaller decisions are assumed and implementation starts before the user has confirmed them. New public type, file, and function names are never reviewed before code is written, and the user repeatedly rejects the resulting names.

## What Changes

Replace `openspec-explore` with a `brainstorming` Skill modeled on the superpowers brainstorming skeleton (hard gate before any implementation, checklist, approaches, section-by-section design approval, self-review, user review, one terminal skill) and on the mattpocock grilling loop (design tree, frontier rounds, numbered questions with a recommended answer, facts investigated by the agent). The terminal skill is `openspec-continue-change`.

Add a persistent draft directory convention `openspec/drafts/<domain>/<topic>/` that captures every round, the user's answers, agent findings, a glossary, the approved design, and the decision-complete handoff. Drafts stay under `openspec/drafts/` permanently; Change creation copies the approved `design.md` and `handoff.md` into `attachments/drafts/` and indexes them once.

Add a naming confirmation gate: brainstorming grills new public names into the draft glossary and task authoring lists every new public name in "Context and interfaces". Execution never asks the user: apply derives an unlisted name from convention and records `Naming assumed: <name>` for review, and a user-owned decision surfacing in a task is parked through `openspec-update-change` replan.

Add `openspec-create-change`, the only Skill that runs `change create` for major work: it creates the Change from a `designed` draft, copies `design.md`/`handoff.md` into `attachments/drafts/`, materializes the user-confirmed talks and knowledge candidates with provenance to the draft, writes `INDEX.md`, and marks the draft `handed-off`. Brainstorming's final round is a carryover round that confirms that list; a draft may also end `parked` or `abandoned`.

Update Harness, OpenSpec, and project guidance, tests, and the `harness/core` durable specification accordingly. Register `mattpocock/skills` and `superpowers` in `Reference/README.md`.

## Impact

Owned paths: `.agents/skills/brainstorming/**` (renamed from `openspec-explore`), `.agents/skills/openspec-create-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/harness/SKILL.md` and `references/routing.md`, `.agents/skills/README.md`, `.agents/skills/openspec/SKILL.md` and `references/{record-schema,attachments,tasks}.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/harness/tests/Protocol.Tests.ps1`, `openspec/README.md`, `openspec/config.yaml`, `openspec/specs/harness/core/spec.md` (via delta), `openspec/drafts/**`, root `README.md`, `AGENTS.md`, `Reference/README.md`, `Tools/PullReference/PullReference.bat`.

Non-goals: no OpenSpec Rust CLI change, no Harness scanning of `openspec/drafts/`, no `CONTEXT.md`/ADR file formats, no change to `markers.md` or to the decision-complete handoff heading set, no edits to immutable archives. Parent repository only; no submodule changes.
