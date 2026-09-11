# Decision-complete handoff

Draft: `openspec/drafts/harness/brainstorming-drafts/` — accepted 2026-09-11.

## Problem

Pre-Change discussion is discarded, user decisions are assumed rather than confirmed, and new code names are never reviewed before implementation.

## Success Criteria

- A `brainstorming` Skill exists at `.agents/skills/brainstorming/` and `openspec-explore` no longer exists.
- An `openspec-create-change` Skill owns `change create` and draft-to-Change seeding; `openspec-continue-change` no longer copies draft files (Round 3).
- Brainstorming has `research` / `proposal` / `design` entry modes, drafts auto-open on proposal, trade-off, or multiple diagrams, and `/openspec/drafts/` is git-ignored (Round 4).
- Every brainstorming session appends to `openspec/drafts/<domain>/<topic>/` from its first round.
- Change creation copies the approved `design.md` and `handoff.md` into `attachments/drafts/` and indexes them once.
- `tasks.md` authoring requires new public names in "Context and interfaces"; apply stops for a naming grill when a required name is missing.
- Skill and protocol tests pass with the renamed Skill; strict OpenSpec validation ignores `openspec/drafts/`.

## Evidence

See `findings/current-skill-inventory.md` and `findings/external-references.md`.

## Scope and Exclusions

In scope: the Skill rename and rewrite, draft contract, naming gate, ripple updates to Harness/OpenSpec guidance and tests, harness/core spec delta, Reference registration. Excluded: CLI changes, CONTEXT.md/ADR files, changes to `markers.md` or handoff headings.

## Constraints

Maintained Skills and OpenSpec records remain English; drafts `log.md`/`findings/` are the declared exception. Harness must not begin scanning `openspec/drafts/`. Existing archives are immutable.

## Options

Draft lifecycle: move into the Change (A) / keep top-level only (B) / keep top-level and copy final design+handoff (C). Naming: tasks-first with apply fallback (A) / always in apply (B) / planning only (C).

## Decision and Rationale

Draft lifecycle C: the user wants the full discussion to remain discoverable regardless of Change archive, while the Change still carries the approved design. Naming A: keeps unattended apply possible while guaranteeing a checkpoint whenever a name was not planned.

## Flip Condition

If Harness later needs to validate drafts (for example INDEX-style enforcement), move drafts into Change attachments instead; if unattended `/goal` runs produce unacceptable names, switch naming to option B.

## Architecture, Components, and Data Flow

See `design.md` sections 2-5.

## Failures and Edge Cases

- A draft abandoned before Change creation: README `status: abandoned`, nothing copied.
- A Change created without a draft (clear fix): no `attachments/drafts/`; the Skill records the skipped-gate assumption in the proposal.
- A name missing from tasks (attended or not): `Naming assumed:` marker in Evidence, reviewed at verify. Apply never asks.
- A user-owned decision surfacing in an unattended run: parked through `openspec-update-change` replan; brainstorming is never opened unattended (Round 2, 2026-09-11).

## Verification

`.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/harness/tests/Protocol.Tests.ps1`, `quick_validate.py` on the new Skill, `openspec.validate --all --strict`.

## OpenSpec Handoff

Change `harness/refactor-explore-brainstorming-drafts`; capability `harness/core` MODIFIED Requirements "Two-tier exploration" and "Exploration markers and durable carryover", ADDED Requirement "Persistent brainstorming drafts" and "Naming confirmation before implementation". Artifacts: proposal, specs delta, design, tasks.

## Exploration Carryover

- Canonical truth: design sections 3-5b -> proposal/spec/design/tasks.
- Draft copy: `design.md`, `handoff.md` -> `attachments/drafts/`.
- Talk candidate (confirmed 2026-09-11 14:41): `log.md` Rounds 1-3 (draft lifecycle C, execution never asks, create-change as its own Skill) -> `talks/talk-20260911-144100-brainstorming-lifecycle-decisions.md` -> three user-owned decisions with rejected alternatives that a future agent would otherwise re-decide.
- Knowledge candidate (confirmed 2026-09-11 14:41): `findings/external-references.md` (mattpocock/superpowers -> project-record mapping) -> `knowledges/external-skill-concept-mapping.md` -> reusable when adapting further external skills; `Reference/README.md` only summarizes it.
- Discard: none; the draft keeps everything by design.
