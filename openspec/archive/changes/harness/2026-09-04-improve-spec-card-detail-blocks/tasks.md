---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
---

## 1. Make flexible Scenario detail visible

- [x] 1.1 Add a failing flexible-detail contract and admit the user-reported gap — verify: `observable: OpenSpecSkill.Tests.ps1 exits non-zero because the template lacks a Scenario-owned Details list`
  > Files: `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/changes/harness/improve-spec-card-detail-blocks/attachments/INDEX.md`, `openspec/changes/harness/improve-spec-card-detail-blocks/attachments/implementation/issue-20260904-115352-spec-card-detail-blocks.md`

  > Produces: One focused RED test and one indexed open material issue whose source is the user's correction.

  1. Assert the central contract, template, workflow prompt, lifecycle Skills, and four representative current cards expose flexible detail/list semantics.
  2. Run the focused test before implementation and retain the first missing-contract failure.

- [x] 1.2 Expand the Scenario Card reference, template, prompts, and Skills — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec/references/specs.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/openspec-sync-specs/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/README.md`, `openspec/workflows/angelscript/templates/spec.md`, `openspec/workflows/angelscript/workflow.yaml`, `openspec/config.yaml`, `openspec/README.md`

  > Constraints: Detail remains ordinary Markdown owned by the whole Scenario. Keep compact scenarios compact and retain `record-v1`.

  1. Document supported blockquotes, prose, lists, examples, and tables.
  2. Show a visible optional `Details` block and list in the template.
  3. Teach create/update/sync/verify paths to preserve the complete flexible block.

## 2. Demonstrate, synchronize, and close

- [x] 2.1 Add representative detail blocks to all four current Harness capabilities — verify: `observable: strict specs pass and each selected Scenario contains its complete Details block exactly once`
  > Files: `openspec/specs/harness/core/spec.md`, `openspec/specs/harness/workspace/spec.md`, `openspec/specs/harness/git/spec.md`, `openspec/specs/harness/unreal/spec.md`, `openspec/changes/harness/improve-spec-card-detail-blocks/specs/harness/**/spec.md`

  > Boundaries: The added lists state durable identity, isolation, result ordering, and terminal cleanup. They do not prescribe source-file edits or claim a test ran.

  1. Synchronize the complete Core authoring requirement and the four named replacement cards.
  2. Preserve all unnamed requirements, scenarios, and existing details.
  3. Validate exact detail ownership and strict current specs.

- [x] 2.2 Resolve the issue and complete self-hosted closure — verify: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `openspec/changes/harness/improve-spec-card-detail-blocks/tasks.md`, `openspec/changes/harness/improve-spec-card-detail-blocks/attachments/INDEX.md`, `openspec/changes/harness/improve-spec-card-detail-blocks/attachments/implementation/issue-20260904-115352-spec-card-detail-blocks.md`, `openspec/changes/harness/improve-spec-card-detail-blocks/attachments/data/workflow-evaluation.md`

  > Produces: Passing Skill validation, strict workflow/spec/Change validation, Quick Harness evidence, a resolved issue, terminal evaluation, completed archive, and a post-archive focused gate.

  1. Run focused tests and system validation for every changed Skill.
  2. Run strict OpenSpec gates and Harness Quick.
  3. Record GREEN evidence, resolve the issue, require terminal status, archive completed, and rerun the focused gate.
