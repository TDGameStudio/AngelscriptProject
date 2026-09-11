# Handoff

## OpenSpec Handoff

- Target Change: `harness/refactor-task-cards-heading-nodes`
- Title: Heading-node task cards with diff Files and a structured authoring contract
- Design: `design.md` (approved 2026-09-11, Round 5)
- Requirement changes: MODIFIED `harness/core` "Harness-recognized Task Graph" (heading nodes, diff Files fence, `file_roles[]`, retired list format), "Ready-to-execute Task authoring" (mandatory labels and header, preflight, forbidden phrases, self-review record, no step-level TDD, quota prohibition retained), "Deterministic OpenSpec package" (release `0.10.0`). No new requirement.
- Files owned: `Tools/openspec/**` (submodule source, tests, `Cargo.toml` version), `.agents/skills/openspec/bin/openspec.exe` and package manifest/command docs, `.agents/skills/openspec/references/tasks.md`, `.agents/skills/openspec/SKILL.md` (format sentences), `openspec/config.yaml` rules.tasks, `.agents/skills/harness/references/task-dag.md`, new `.agents/skills/harness/references/execution-conventions.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/harness/tests/Protocol.Tests.ps1` fixtures, `openspec/changes/angelscript/*/tasks.md` (7 plans, syntax only), `openspec/specs/harness/core/spec.md` (via sync).
- Verification: `cargo test` / fmt / clippy in `Tools/openspec`; `Publish-OpenSpecPackage.ps1` from tagged `v0.10.0` (submodule commit + tag + parent EXE swap need explicit user authorization); scoped `OpenSpecSkill.Tests.ps1`; `Protocol.Tests.ps1` temp copy; Skill validator; `openspec validate --all --strict`; `task.status` on the 7 migrated plans; `harness/core --type spec --strict` after sync.
- Non-goals: content enrichment of thin plans, archives, Harness scheduling semantics, step-level checkboxes, markers/visual-explain files.
- Sequencing: parser and release tasks first; contract and tests second; migration last (needs the released EXE to validate).

## Exploration Carryover

Confirmed by the user 2026-09-11 17:14 (Round 5, R2 = A).

- Rounds 2–3 decisions (heading nodes, retire list format, diff Files, one Change, syntax-only migration) and the overturned Round 1 "keep the machine surface" path → talk `talks/talk-<ts>-heading-node-task-cards.md` — prevents re-deciding the node syntax, dual-format support, or migration depth.
- `findings/current-task-format-audit.md` + `findings/delegates-tasks-review.md` → knowledge `knowledges/task-plan-audit-method.md` (candidate) — how optional labels degrade into prose and how deferred naming shows up as a "finish the design" task; reusable when auditing any plan.
- `findings/example-heading-card.md` → draft copy `attachments/drafts/example-heading-card.md` — seed for the contract's filled example.
- `findings/writing-plans-comparison.md` → knowledge `knowledges/writing-plans-provenance.md` (candidate) — adopt/adapt/reject table for the superpowers `writing-plans` ideas.
- `findings/parser-card-surface.md` → not carried (covered by design §3).
