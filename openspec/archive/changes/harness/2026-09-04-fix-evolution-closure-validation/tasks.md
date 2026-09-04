---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
---

## 1. Close task and evaluation bypasses

- [x] 1.1 Add a lightweight focused fixture that reproduces active terminal bypasses — verify: `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
  > Files: `.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`, `openspec/changes/harness/fix-evolution-closure-validation/attachments/INDEX.md`, `openspec/changes/harness/fix-evolution-closure-validation/attachments/implementation/issue-20260904-130017-evolution-terminal-bypass.md`

  > Scope: Exercise the real `harness.evolution.status` route with a temporary OpenSpec Change. Do not invoke Quick or any Git, Workspace, Unreal, performance, build, Editor, or Automation gate.

  1. Prove completed closure currently accepts incomplete or absent completion state.
  2. Prove stale evaluation content and archived terminal evaluation are currently accepted.
  3. Retain the first expected RED in one bounded data artifact.

- [x] 1.2 Implement active closure-kind, TaskPlan, and evaluation-integrity checks — verify: `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
  > Files: `.agents/skills/harness/scripts/Harness.psm1`, `.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`, `.agents/skills/harness/tests/Harness.Performance.Tests.ps1`

  > Produces: Active-only terminal policy, OpenSpec-owned TaskPlan interpretation, current-input digest reporting, closure-kind matching, and capture freshness without parsing Task DAG YAML in Harness.

  1. Add deterministic length-framed Change-input hashing.
  2. Require an exact valid TaskPlan and completed nodes only for completed closure.
  3. Update the existing performance fixture shape without running the performance profile.

## 2. Close issue and Review bypasses

- [x] 2.1 Extend the focused fixture, then implement strict active issue and Review lifecycle validation — verify: `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
  > Files: `.agents/skills/harness/scripts/Harness.psm1`, `.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`

  > Boundaries: Historical schema-less attachments remain readable only in archives. Active validation is recursive, task-bound, indexed, timestamp-ordered, and fail-closed.

  1. Reproduce schema-less/nested issue, invalid task/timestamp/successor, and unfinished Review bypasses before implementation.
  2. Validate required issue body sections without retaining or returning raw bodies.
  3. Validate v2 Review lifecycle and structured blocking finding states only when a Review exists.

- [x] 2.2 Synchronize the durable contract and close with only impact-scoped verification — verify: `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
  > Files: `.agents/skills/harness/references/closure.md`, `.agents/skills/harness/references/review.md`, `.agents/skills/openspec/references/attachments.md`, `.agents/skills/openspec/references/implementation-issues.md`, `openspec/specs/harness/core/spec.md`, `openspec/changes/harness/fix-evolution-closure-validation/specs/harness/core/spec.md`, `openspec/changes/harness/fix-evolution-closure-validation/attachments/**`, `openspec/changes/harness/fix-evolution-closure-validation/tasks.md`

  > Verification: Run the focused evolution fixture, directly affected Protocol test, exact workflow/spec/Change strict validation, Skill validation for changed Skills, terminal closure, and post-archive historical validation. Do not run Harness Quick or unrelated suites.

  1. Update closure/evidence guidance and synchronize the Core requirement.
  2. Resolve the material issue and write the digest-bound evaluation last.
  3. Archive completed and commit only this exact Change scope.
