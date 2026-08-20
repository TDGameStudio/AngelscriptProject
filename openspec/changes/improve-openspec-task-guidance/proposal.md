## Why

OpenSpec changes in this repo often produce `tasks.md` that is too short to execute: slogan checkboxes, missing paths, missing verification, and no requirement trace. The `openspec-work` skill treats OpenSpec as a lightweight record and authorizes "start lean" for record-and-implement sessions, so official OpenSpec and Superpowers task depth rarely reach the agent. Spec Kit's `/speckit.tasks` rules are a concrete quality bar we can steal without switching tools.

## What Changes

- Record discussion under `attachments/planning/` and keep apply notes under `attachments/implementation/`. Apply must not load planning notes unless stuck. Mid-apply OpenSpec refactors go in `implementation/openspec-refactors.md`.
- Each behavior-changing task is a short checkbox plus indented `Files` / `Impact` / `Tests` / `Verify` / `Requirement` — not one packed line.
- This session is record-only. Do not catalog Spec Kit in `Reference/README.md` or `AGENTS.md`.
- Establish the project contract for `tasks.md`: multi-line body, grouping, depth by type, and injection via `config.yaml` + skill.
- Later (not this session): inject that contract through `openspec/config.yaml` rules and a rewritten `openspec-work` skill, so both `/opsx:propose` and the merged skill emit the same depth. Feature/fix/refactor default to executable plans; chore/docs may stay lean.
- Do **not** migrate the repo to Spec Kit. Do **not** copy community schemas wholesale.

## Capabilities

### New Capabilities

- `openspec-task-guidance`: Agent-visible contract for generating and applying OpenSpec `tasks.md` in this project. Covers required task fields, grouping, depth by change type, and the injection path (`config.yaml` + skill) so the contract is not optional prose.

### Modified Capabilities

- None.

## Impact

- Process only: later `.agents/skills/openspec-work/SKILL.md` and likely a new `openspec/config.yaml`. Optionally a forked schema under `openspec/schemas/`.
- No AngelScript runtime, Editor, Standalone, Wiki, or test-harness code.
- Existing active changes are not rewritten in this change. The contract applies to new and subsequently updated changes.
- Routing: `attachments/INDEX.md`. Planning notes: `attachments/planning/`. Apply working set: `attachments/implementation/`.
- Offline Spec Kit clone is gitignored `Reference\spec-kit`; catalog only in `attachments/planning/speckit-local-copy.md`.
