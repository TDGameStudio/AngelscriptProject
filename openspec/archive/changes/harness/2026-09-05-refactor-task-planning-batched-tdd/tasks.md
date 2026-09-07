---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
---

## Verification context

Import Harness in the current PowerShell 7 process and select this workspace. For the owner Skill check, use this explicit stable surface selection:

```powershell
$guidanceSurfacePaths = @(
    'AGENTS.md', '.agents/skills/harness', '.agents/skills/test-driven-development',
    '.agents/skills/openspec', '.agents/skills/openspec-apply-change',
    '.agents/skills/openspec-continue-change', '.agents/skills/openspec-verify-change',
    'openspec/workflows/angelscript', 'openspec/specs/harness/core'
)
```

Only repository-content audits (English, capability knowledge indexes and active attachment indexes) are scoped; all package, protocol, authoring/link assertions and hermetic fixtures still run. Selecting a child file includes its whole owning index contract. The unchanged default full scan has unrelated language and knowledge-index baseline violations, recorded in the indexed issue. It is not reported as passing. No archived/active subject path is required by this reusable command.

## 1. Coherent grouped verification

- [x] 1.1 Make feature-group RED/GREEN and shared evidence coherent across execution entries — verify: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`
  > Files: `AGENTS.md`, `.agents/skills/test-driven-development/SKILL.md`, `.agents/skills/test-driven-development/writing-good-tests.md`, `.agents/skills/harness/SKILL.md`, `.agents/skills/harness/references/verification.md`, `.agents/skills/harness/tests/Protocol.Tests.ps1`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `openspec/changes/harness/refactor-task-planning-batched-tdd/attachments/**`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/implementation/issue-20260905-121302-stale-openspec-engine-context.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/implementation/issue-20260905-144517-conversion-target-identity.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/INDEX.md`

  Inputs: The accepted plan, current contradictory per-test and delayed-first-run guidance, and the unchanged consumer exercise in data/behavior-probe.md.
  Produces: One proving/scheduling contract; existing code is preserved and no runtime or parser API changes.

  Adjacent verification repair: the baseline Protocol gate exposed substring-based index counting and missing explicit Command/Run ID labels in two existing open AS issues. Repair the exact-entry test helper and evidence formatting only; do not close those AS issues or change their product/prompt behavior. No task dependency or accepted outcome changes.

  1. Capture the old-policy consumer response for option validation/alias resolution, independent JSON export, prewritten code, a crashed run and an unmapped partial report. Inspect whether batching and completion decisions are justified; do not invent a failing result if the agent already behaves correctly.
  2. Replace per-test process assumptions with bounded grouped RED/GREEN and explicit shared-case evidence. Retain real-test and expected-failure requirements.
  3. Run the exact owner test; repair only stale structural assertions affected by the contract change. Consumer GREEN is evaluated after 2.1 supplies planning guidance.

  Evidence: Protocol.Tests.ps1 passed in the current PowerShell process after exact-entry regression RED/GREEN and truthful evidence-label repairs. HarnessCutover passed; TDD quick validation passed. The before-policy consumer output and its limits are retained in data/behavior-probe.md. No plugin source or UE operation changed.

## 2. Executable task authoring

- [x] 2.1 Route templates and execution checks to detailed outcome-sized Task Cards — verify: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths $guidanceSurfacePaths`
  > Files: `.agents/skills/openspec/references/tasks.md`, `.agents/skills/harness/references/task-dag.md`, `.agents/skills/harness/references/replan.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `openspec/workflows/angelscript/templates/tasks.md`, `openspec/workflows/angelscript/workflow.yaml`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/specs/harness/core/spec.md`, `openspec/changes/harness/refactor-task-planning-batched-tdd/attachments/**`

  Inputs: The grouped proving contract from 1.1. Produces: task-authoring quality visible through the actual workflow/Skill routing, without fixed labels or extra state.

  1. Add a concrete multi-case example and require outcomes, bounded Files, interfaces, fixtures, expected RED and completion mapping when needed for execution. Split independent products, not individual test actions.
  2. Make workflow, template and Ready preflight use that contract, including evidence-backed oversized-node replan. Preserve optional Scenario/Task Markdown composition.
  3. Repeat the identical read-only consumer exercise with a fresh agent and compare outcomes against its rubric. Run the owner test and quick validation for every changed Skill; record both the structural and behavioral proof limits.

  Evidence: the exact stable-surface command passed in the coordinator's current PowerShell process; all package/authoring/link/hermetic checks remain active. Surface selection and owner-closure fixtures observed RED before the implementation and now pass. The default full scan still reports unrelated baseline violations and is not called green. All six changed Skill folders validate; workflow validation e0354888f0b341219bfa359d2e0a985f passed. Independent after-policy exercise produces one grouped parser outcome plus the independent exporter and demonstrates all seven rubric behaviors, with stated limits.

## 3. Apply the task boundary correction and close this guidance change

- [x] 3.1 Replan pending AS outcomes, synchronize the durable contract and close verified Harness guidance — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-builder-engine-independent', '--strict', '--json')`
  > Files: `openspec/changes/angelscript/refactor-builder-engine-independent/tasks.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/design.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/INDEX.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/data/language-coverage.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/replans/replan-20260905-*-feature-group-tasks.md`, `openspec/changes/angelscript/refactor-builder-engine-independent/attachments/implementation/issue-20260905-144517-conversion-target-identity.md`, `openspec/specs/harness/core/spec.md`, `openspec/changes/harness/refactor-task-planning-batched-tdd/**`

  1. Validate the candidate DAG before applying a new immutable replan: preserve eight completed nodes; turn 4.1 into its original integrated acceptance over four concrete pending feature groups; retain downstream outcomes. Update current scope and coverage evidence, not AS source.
  2. Prove task.status derives the new Ready nodes and strict validation accepts the AS change. Preserve the 481-case snapshot as historical evidence and label current source unverified.
  3. Semantically sync the Harness delta; run strict Harness/change/spec/workflow checks, directly affected entry checks, and HarnessEvolution.Tests. Verify plugin source digest is unchanged. Resolve the indexed workflow issue, capture fresh evaluation and pass the exact terminal evolution gate.
  4. Archive this Harness change with completed closure, then run strict archived validation and a minimal active-status check. Leave AS active; do not run UE, commit, push or modify unrelated files.

  Evidence: strict AS validation 2a81e5f013074bb2a26fae4a33851720 passes; task.status aa394baa0ba34726b9f64570da8623c7 confirms 8/17 complete and sole Ready 4.2. Durable synchronization, 15 current specs, workflow, doctor, all selected owner tests and six Skill checks pass. Plugin content digest is unchanged. Indexed verification preserves full-scan failures and proof limits; issue resolutions are recorded. Terminal evaluation and deterministic archive are the final lifecycle actions after task completion.
