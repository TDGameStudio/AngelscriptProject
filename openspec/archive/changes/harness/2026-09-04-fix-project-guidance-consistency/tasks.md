---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

## 1. Align the live project guidance

- [x] 1.1 Add a failing project-guidance regression — verify: `& ./.agents/skills/harness/tests/HarnessCutover.Tests.ps1`
  > Files: `.agents/skills/harness/tests/HarnessCutover.Tests.ps1`

  > Context: Assert only current, maintained entry documents. Immutable archives and the independently versioned `Tools/openspec` source package are outside this repair.

  > Produces: RED coverage for UE 5.8, enabled Skills, Harness-only identity, selected-workspace semantics, explicit Review intake, PowerShell 7, direct in-process invocation, and non-fallback root wrappers.

  1. Add focused positive and forbidden-text assertions.
  2. Run the focused test and retain the stale-guidance failures before editing documentation.

- [x] 1.2 Update Chinese guidance first, then synchronize English and Skill entry guidance — verify: `& ./.agents/skills/harness/tests/HarnessCutover.Tests.ps1`
  > Files: `AGENTS_ZH.md`, `AGENTS.md`, `README.md`, `.agents/skills/README.md`, `.agents/skills/harness/SKILL.md`, `.agents/skills/harness/references/task-dag.md`, `.agents/skills/unreal-engine-develop/SKILL.md`

  > Constraints: Preserve unrelated README edits. Do not edit `Documents/`, remove wrappers, modify `Tools/openspec`, or imply that ordinary Harness routing launches a child shell.

  1. Replace stale Hardness, Current/Goal, automatic Review, UE 5.7, and Windows PowerShell guidance.
  2. Document current-process Harness calls and the bounded reasons for intentional child `pwsh` processes.
  3. Keep the Chinese and English agent guidance semantically aligned.

## 2. Synchronize and close

- [x] 2.1 Synchronize the guidance contract and complete self-hosted verification — verify: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `openspec/specs/harness/core/spec.md`, `openspec/changes/harness/fix-project-guidance-consistency/specs/harness/core/spec.md`, `openspec/changes/harness/fix-project-guidance-consistency/attachments/INDEX.md`, `openspec/changes/harness/fix-project-guidance-consistency/attachments/data/workflow-evaluation.md`

  > Produces: Strict Change/spec validation, the focused cutover gate, a passing Quick Harness gate, an indexed workflow evaluation, exact terminal status, completed archive, and a post-archive focused gate.

  1. Merge the complete modified requirements into the current Harness core spec.
  2. Run focused and Quick verification plus strict OpenSpec validation.
  3. Record the final evaluation, require terminal evolution, archive completed, and rerun the focused gate.
