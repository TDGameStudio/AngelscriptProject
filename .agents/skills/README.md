# Project Skills for AngelscriptProject

`.agents/skills/` hosts the project-local skills. The single entry point is **`hardness`** — its route table maps task types to skill files, defines the unattended loop protocol for `Tools/RalphLoop`, and owns the feedback loop for evolving the harness. When unsure which skill applies, read `hardness/SKILL.md` first; this README does not duplicate the route table.

## Architecture

**Entry / orchestration**

- `hardness` — route table, loop iteration protocol, feedback protocol, and the `scripts/openspec.ps1` wrapper every OpenSpec CLI call goes through.

**OpenSpec family** (record system; lightweight, no phase wall)

- `openspec` — the portable Rust CLI primitive (`bin/openspec.exe`), command surface, and shared operation rules (Start / Update / Verify). Never invoke bare `openspec`: PATH resolves to the incompatible official Node CLI.
- `openspec-schema` — the on-disk schema of both trees (change tree, specs tree) and the three-level knowledge architecture with promotion rules.
- `openspec-continue-change` — create the next planning artifact.
- `openspec-apply-change` — implement the task list with verification discipline.
- `openspec-sync-specs` — merge delta specs into current specs (always agent-driven; the CLI never merges).
- `openspec-archive-change` — the project close policy plus the archive primitive.
- `openspec-explore` — thinking partner before decisions; structured question rounds.

**Engineering discipline**

- `test-driven-development` — TDD for any feature or bugfix.
- `code-review/receiving-code-review`, `code-review/requesting-code-review` — review workflows.
- `git-workflow` — worktree, branch, and commit flow (includes `NewWorktree.ps1`).

**Domain knowledge**

- `angelscript-test-guide` — C++ automation test patterns (CQTest, inline AS fixtures).
- `unreal-engine-develop` — build/test/commandlet entry points and UE knowledge.
- `unreal-engine-debug` — WIP placeholder, not yet activated.
- `hazelight-update-audit` — upstream update comparison and sync decisions.

**Presentation**

- `visual-explain`, `external/archify`, `external/tiddlywiki-wikitext`, `web/*`.

## Project rules

- OpenSpec is the authoritative **record** system. `Documents/Plans/` is legacy, historical reference only.
- Change IDs are `<domain>/<leaf>`; the leaf follows `<type>-<scope>-<outcome>` in lowercase kebab-case with type one of `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, `chore` (`feature`, not `feat`; Git commits may still use `Feat`). Choose `refactor` for structural boundary/module-shape changes, `improve` for quality/diagnostics/performance work without structural reshaping.
- Removed skills — never follow if they resurface in history: `openspec-work`, `openspec-Implementation`, `openspec-replan`. The global Superpowers plugin dependency is being internalized into project-local skills; do not add new hard dependencies on `superpowers:*` names.

## Maintenance

- Routing or protocol changes land in the `hardness` route table with a version bump, via its feedback review process (developer-attended sessions only).
- CLI upgrades: rebuild from the `Tools/openspec` submodule and refresh the bundled `openspec/bin/openspec.exe` copy — procedure in the `openspec` skill.
- Skills are maintained in English; a `_ZH` mirror exists only where intentionally kept in sync (`hardness`, `openspec`). When they conflict, `SKILL.md` wins.
