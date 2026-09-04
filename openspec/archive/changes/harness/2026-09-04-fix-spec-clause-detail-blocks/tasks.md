---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
---

## 1. Correct clause ownership

- [x] 1.1 Add a failing per-clause authoring contract and admit the user correction — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/changes/harness/fix-spec-clause-detail-blocks/attachments/INDEX.md`, `openspec/changes/harness/fix-spec-clause-detail-blocks/attachments/implementation/issue-20260904-121653-clause-detail-ownership.md`

  > Produces: One focused RED proving the template still owns detail at Scenario level and one indexed material issue tied to the user's correction.

  1. Assert that quoted notes and ordered lists are indented beneath an exact behavior clause.
  2. Assert that current guidance no longer assigns one shared detail block to the Scenario heading.

- [x] 1.2 Update the authoring contract, template, prompts, and lifecycle Skills — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec/references/specs.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/openspec-sync-specs/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/README.md`, `openspec/workflows/angelscript/templates/spec.md`, `openspec/workflows/angelscript/workflow.yaml`, `openspec/config.yaml`, `openspec/README.md`

  > Constraints: Preserve flexible ordinary Markdown, compact simple clauses, `record-v1`, and the unchanged portable executable.

  1. Define immediate indented ownership for every behavior-clause kind.
  2. Copy the Task Card composition shape into the Scenario template without copying Task state.
  3. Teach create, update, sync, and verify paths to retain each complete clause-owned block.

## 2. Demonstrate, synchronize, and close

- [x] 2.1 Correct representative cards in all four current Harness capabilities — verify: `observable: strict specs pass and each selected WHEN or THEN owns its intended nested block`
  > Files: `openspec/specs/harness/core/spec.md`, `openspec/specs/harness/workspace/spec.md`, `openspec/specs/harness/git/spec.md`, `openspec/specs/harness/unreal/spec.md`, `openspec/changes/harness/fix-spec-clause-detail-blocks/specs/harness/**/spec.md`

  > Produces: A synchronized Core authoring contract plus representative clause-local quoted notes, ordered lists, and unordered lists.

  1. Move each existing Scenario-wide example under the exact `WHEN` or `THEN` it qualifies.
  2. Preserve all unnamed requirements, scenarios, and unrelated detail.
  3. Validate the complete current specs and exact Change strictly.

- [x] 2.2 Resolve the issue and complete self-hosted closure — verify: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `openspec/changes/harness/fix-spec-clause-detail-blocks/tasks.md`, `openspec/changes/harness/fix-spec-clause-detail-blocks/attachments/INDEX.md`, `openspec/changes/harness/fix-spec-clause-detail-blocks/attachments/implementation/issue-20260904-121653-clause-detail-ownership.md`, `openspec/changes/harness/fix-spec-clause-detail-blocks/attachments/data/workflow-evaluation.md`

  > Produces: Focused and Quick GREEN evidence, strict validation, a resolved issue, terminal evaluation, completed archive, and one exact scoped commit.

  1. Validate every changed Skill and run the focused protocol gates.
  2. Run strict workflow, spec, and Change validation plus Harness Quick.
  3. Resolve the issue, record final evaluation, pass the terminal gate, archive, and commit only this Change.
