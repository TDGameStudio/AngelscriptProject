---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

## 1. Enforce semantic Change identities

- [x] 1.1 Add failing route-level naming regressions — verify: `& ./.agents/skills/harness/tests/Harness.Tests.ps1`
  > Files: `.agents/skills/harness/tests/Harness.Tests.ps1`

  > Context: The portable CLI already owns lowercase portable syntax; these fixtures must exercise the project-specific Harness boundary against real temporary OpenSpec records.

  > Produces: RED coverage for every allowed type, rejected `feat`/unknown/missing-part/uppercase targets, a legacy active source moved to a valid target, an invalid active audit, and unchanged historical archives.

  1. Add behavior fixtures through the public `Invoke-Harness` route.
  2. Run the focused test and observe failure because semantic policy is not implemented.

- [x] 1.2 Implement the Harness guard and project authoring guidance — verify: `& ./.agents/skills/harness/tests/Harness.Tests.ps1`
  > Files: `.agents/skills/harness/scripts/Harness.psm1`, `.agents/skills/harness/SKILL.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec/references/record-schema.md`, `.agents/skills/README.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`

  > Constraints: Validate only normal `openspec.change create` targets, `change move --to` targets, and active project identities. Do not reject an existing legacy move source, modify the generic CLI, or inspect/rewrite archive names.

  1. Add one narrowly scoped semantic-name parser and a structured preflight failure.
  2. Add active-record auditing to the maintained project gate.
  3. Keep the canonical rule in the record-schema reference and concise pointers in entry Skills and command help.
  4. Run Harness and OpenSpec Skill tests green.

## 2. Synchronize and close

- [x] 2.1 Synchronize the naming contract and complete self-hosted verification — verify: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `openspec/specs/harness/core/spec.md`, `openspec/changes/harness/fix-openspec-change-naming/specs/harness/core/spec.md`, `openspec/changes/harness/fix-openspec-change-naming/attachments/INDEX.md`, `openspec/changes/harness/fix-openspec-change-naming/attachments/data/workflow-evaluation.md`

  > Produces: An idempotently synchronized current requirement, strict current/change validation, a passing indexed workflow evaluation, and reusable gates with no dependency on the active Change path.

  1. Merge the complete new Requirement and Scenario Cards into the current Harness core spec.
  2. Run strict Change/spec validation and the Quick Harness gate.
  3. Record the final self-hosted workflow evaluation and pass the exact terminal evolution gate.
