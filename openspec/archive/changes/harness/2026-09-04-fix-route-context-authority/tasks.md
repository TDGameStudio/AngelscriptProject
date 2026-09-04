---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

## 1. Enforce dispatcher context authority

- [x] 1.1 Add failing route-authority regressions — verify: `& ./.agents/skills/harness/tests/Harness.Tests.ps1`
  > Files: `.agents/skills/harness/tests/Harness.Tests.ps1`

  > Context: Exercise the public dispatcher against temporary primary and linked workspaces; leaf behavior is not the authority under test.

  > Produces: RED coverage for every routed root category, matching aliases, internal Context replacement, primary-only integration, and rejection without target-side effects.

  1. Add table-driven mismatched and matching parameter fixtures.
  2. Run the focused test and observe the current dispatcher retarget a leaf or internal operation.

- [x] 1.2 Bind dispatcher-owned parameters to the selected Context — verify: `& ./.agents/skills/harness/tests/Harness.Tests.ps1`
  > Files: `.agents/skills/harness/scripts/Harness.psm1`, `.agents/skills/harness/SKILL.md`

  > Constraints: `SourceWorkspaceRoot` for `git.integrate` is the sole permitted different root. Do not move authority checks into leaf modules or change native OpenSpec/task argument syntax.

  1. Add one private canonical-root assertion and normalizer.
  2. Apply the authoritative route matrix and reject caller-supplied internal Context.
  3. Return stable `ContextAuthorityMismatch` failures before leaf import or invocation.

## 2. Synchronize and close

- [x] 2.1 Synchronize the authority contract and complete self-hosted verification — verify: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `openspec/specs/harness/core/spec.md`, `openspec/changes/harness/fix-route-context-authority/specs/harness/core/spec.md`, `openspec/changes/harness/fix-route-context-authority/attachments/INDEX.md`, `openspec/changes/harness/fix-route-context-authority/attachments/data/workflow-evaluation.md`

  > Produces: A complete modified current Requirement, strict validations, a passing indexed evaluation, exact terminal status, and a post-archive focused gate.

  1. Replace the current unified-context Requirement with the complete delta version.
  2. Run strict Change/spec validation and the Quick Harness gate.
  3. Record the workflow evaluation, require terminal evolution, archive completed, and rerun focused verification.
