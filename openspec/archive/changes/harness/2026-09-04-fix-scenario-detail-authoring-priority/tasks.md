---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

## 1. Authoring policy and regression proof

- [x] 1.1 Make useful clause-owned detail the preferred optional authoring default — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec/references/specs.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/openspec-sync-specs/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/workflows/angelscript/workflow.yaml`, `openspec/workflows/angelscript/templates/spec.md`

  > Produces: One aligned policy that actively evaluates every new or modified behavior clause, prefers the smallest useful combination from the complete Markdown palette, preserves exact clause ownership, and permits omission only when detail adds no information.

  1. Extend the authoring-contract fixture first and observe the expected failure against the current complex-only and compact-first wording.
  2. Update the focused reference, entry and lifecycle Skills, workflow instruction, and template without adding parser fields or a detail quota.
  3. Run the exact owner test and Skill package validators.

  Evidence: The focused test first failed because the authoring reference lacked the active-evaluation contract. After the reference, entry, lifecycle Skills, workflow instruction, and template were aligned, the exact owner test passed. The Skill Creator `quick_validate.py` check also passed for `openspec`, `openspec-continue-change`, `openspec-update-change`, `openspec-sync-specs`, and `openspec-verify-change`.

- [x] 1.2 Align the actual generated-instruction rule and maintained overview mirrors — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `openspec/config.yaml`, `openspec/README.md`, `.agents/skills/README.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/changes/harness/fix-scenario-detail-authoring-priority/attachments/replans/replan-20260904-215500-align-generated-instructions.md`, `openspec/changes/harness/fix-scenario-detail-authoring-priority/attachments/INDEX.md`

  > Context: The first GREEN covered the workflow instruction but a subsequent generated `openspec instructions specs` inspection proved that `openspec/config.yaml` independently injected the old complex-only rule.

  1. Extend the focused fixture to cover the live config and maintained overview mirrors, then observe the expected RED.
  2. Align those sources with the same active-evaluation and optionality policy.
  3. Rerun the exact owner test and confirm generated instructions contain no conflicting complex-only or compact-first guidance.

  Evidence: The expanded fixture failed because `openspec/config.yaml` lacked the active-evaluation contract. After aligning the live config and both maintained overview mirrors, the exact owner test passed. A fresh `openspec instructions specs` result contained active evaluation, the smallest useful combination, and the complete Markdown palette, while neither complex-only nor compact-first regression phrase remained.

## 2. Durable examples and completion

- [x] 2.1 Synchronize meaningful detail into recent current Scenario Cards and verify the affected contracts — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1; & ./.agents/skills/harness/tests/Protocol.Tests.ps1`
  > Files: `openspec/specs/harness/core/spec.md`, `openspec/specs/harness/unreal/spec.md`, `openspec/specs/angelscript/runtime/startup/spec.md`, `openspec/specs/angelscript/testing/baseline/spec.md`, `openspec/changes/harness/fix-scenario-detail-authoring-priority/specs/**/*.md`, `openspec/changes/harness/fix-scenario-detail-authoring-priority/tasks.md`, `openspec/changes/harness/fix-scenario-detail-authoring-priority/attachments/INDEX.md`, `openspec/changes/harness/fix-scenario-detail-authoring-priority/attachments/data/workflow-evaluation.md`

  > Context: Archived Change records remain immutable. Only current durable specifications receive the enriched replacement cards.

  1. Semantically merge each complete modified Requirement, retaining every unspecified current scenario and keeping each detail block beneath its exact clause.
  2. Run the owner tests, Protocol tests, strict Change/workflow/current-spec validation, and focused Skill validation.
  3. Record actual verification and justified heavier-suite exclusions, then pass the terminal Harness evolution gate.

  Evidence: The 12 modified Requirement bodies and 26 complete replacement Scenario Cards match between the four delta specs and current durable specs; the 24 cards introduced by the four recent affected Changes all contain useful clause-owned `WHEN` and `THEN` detail. The corpus demonstrates quoted notes, prose, ordered and unordered lists, an example, and a table. `OpenSpecSkill.Tests.ps1`, `Protocol.Tests.ps1`, and `HarnessEvolution.Tests.ps1` passed. OpenSpec doctor reported zero errors, the `angelscript` workflow and exact Change validated, and all seven current specs passed strict validation. Broader Harness Quick, Performance, Integration, Unreal operations, plugin tests, and Standalone tests were omitted because no executable Harness, Unreal, plugin, performance, or cross-component behavior changed.
