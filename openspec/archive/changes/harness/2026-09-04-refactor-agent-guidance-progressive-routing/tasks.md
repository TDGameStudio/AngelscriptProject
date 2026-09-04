---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "2.2": ["2.1"]
    "3.1": ["1.1", "2.2"]
    "4.1": ["3.1"]
---

## 1. Canonical project entry

- [x] 1.1 Establish one thin root Agent entry and remove its duplicate mirror — verify: `pwsh -NoProfile -File ./.agents/skills/harness/tests/HarnessCutover.Tests.ps1`
  > Files: `.agents/skills/harness/tests/HarnessCutover.Tests.ps1`, `AGENTS.md`, `AGENTS_ZH.md`, `README.md`

  > Constraints: Preserve unrelated pre-existing `README.md` edits and change only its two root Agent-entry references. Do not touch `Wiki/Agents_ZH.md`, historical archives, or `Documents/` migration content.

  1. Extend the focused cutover assertions for a sole, thin, progressively routed root entry and observe the expected failure against the current files.
  2. Replace `AGENTS.md`, remove the root Chinese mirror, and update the two README references with the smallest passing edits.
  3. Run the exact focused test and confirm the unrelated README diff remains outside this Change's intended hunks.

## 2. Shared verification routing

- [x] 2.1 Define the focused Harness verification policy and route the Harness entry through it — verify: `pwsh -NoProfile -File ./.agents/skills/harness/tests/Protocol.Tests.ps1`
  > Files: `.agents/skills/harness/references/verification.md`, `.agents/skills/harness/SKILL.md`, `.agents/skills/harness/tests/Protocol.Tests.ps1`

  1. Add protocol assertions for impact-scoped default verification, conditional profile escalation, evidence-driven adjacent expansion, and preserved Review/Replan boundaries; observe the expected failure.
  2. Add the focused reference and replace unconditional-looking aggregate profile guidance with progressive routing.
  3. Run the exact protocol test.

- [x] 2.2 Route OpenSpec lifecycle and task authoring guidance through the same policy — verify: `pwsh -NoProfile -File ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/openspec-archive-change/SKILL.md`, `.agents/skills/openspec/references/tasks.md`, `openspec/workflows/angelscript/templates/tasks.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`

  > Inputs: Task 2.1's canonical `.agents/skills/harness/references/verification.md` policy.

  1. Add focused static assertions that every lifecycle owner and task template routes to the same policy and does not impose broad profiles as unconditional gates; observe the expected failure.
  2. Add concise links and task-writing rules without duplicating the detailed matrix or adding parser fields.
  3. Run the exact OpenSpec Skill test.

## 3. Durable contract

- [x] 3.1 Synchronize the impact-scoped verification and thin-entry behaviors into `harness/core` — verify: `Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $context = New-HarnessContext -WorkspaceRoot (Get-Location).Path; Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs', '--strict', '--json')`
  > Files: `openspec/changes/harness/refactor-agent-guidance-progressive-routing/specs/harness/core/spec.md`, `openspec/specs/harness/core/spec.md`

  1. Semantically merge the complete added and modified requirement cards while preserving unspecified current scenarios and clause-owned detail.
  2. Run strict current-spec validation and confirm the delta remains aligned with the synchronized contract.

## 4. Scoped completion evidence

- [x] 4.1 Run the complete guidance-only verification scope and leave the Change ready for terminal evaluation — verify: `pwsh -NoProfile -File ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
  > Files: `.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`, `openspec/changes/harness/refactor-agent-guidance-progressive-routing/tasks.md`

  > Constraints: Re-run the changed Skill structure checks, `HarnessCutover.Tests.ps1`, `Protocol.Tests.ps1`, `OpenSpecSkill.Tests.ps1`, `HarnessEvolution.Tests.ps1`, and strict validation for the Change, workflow, and current specs. Do not run `Quick`, `Performance`, `Integration`, Unreal builds, UE Automation, full suites, plugin tests, Standalone tests, or C++ tests unless new evidence expands the impact surface.

  1. Validate every changed Skill directory with the skill-creator quick validator.
  2. Run the focused static and evolution tests plus strict OpenSpec checks named above.
  3. Record the successful task state; terminal workflow evaluation is captured last after every Change input is final.
