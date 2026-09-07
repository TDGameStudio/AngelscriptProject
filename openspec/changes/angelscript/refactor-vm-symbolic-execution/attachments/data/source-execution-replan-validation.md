# Source/Detached Replan Validation

## Scope and result

Planning-only update of angelscript/refactor-vm-symbolic-execution on 2026-09-06. No C++ implementation, UE build, Automation execution, current-spec synchronization, archive or Git publication occurred.

- Strict Change validation: PASS, one selected Change valid, zero issues.
- Harness task.status: ready; 19 total, 0 complete, 19 remaining; only initial Ready is 1.1.
- Candidate authoring checks before current-truth writes: 19 unique graph/body IDs, acyclic dependencies, all 13 original IDs/completion states preserved, one WHEN/THEN per changed Scenario Card.
- Requirement audit: five delta specs, 18 Requirements, 44 Scenario Cards. New source and independent-layer requirements map to 1.3 and 5.1-5.5 plus final 4.2.
- Applied tasks SHA-256: 9113a64eaaab9e7ac892e25fc12a78d55610a84fdc48b2c0ee035816f46b6ce0.
- Attachment audit before adding this evidence: nine attachment files, each indexed exactly once. This file adds the tenth indexed attachment in the same edit.
- Scoped OpenSpecSkill owner checks: package safety and skill package tests PASS.

The first scoped owner run found a Chinese quotation in the new Replan source_ref. That record-authoring field was normalized to an English description before this planning delivery was accepted; the same scoped test then passed. Task meaning, DAG and task hash did not change. This was a local authoring failure, not a Harness runtime defect or reason for another architecture Replan.

## Actual commands

Commands executed in the selected workspace's current PowerShell 7 process:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path

Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @(
    'angelscript/refactor-vm-symbolic-execution', '--type', 'change', '--strict', '--json')

Invoke-Harness -Command task.status -Context $context -Parameters @{
    Change = 'angelscript/refactor-vm-symbolic-execution'
}

& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths @(
    'openspec/changes/angelscript/refactor-vm-symbolic-execution'
)
```

Additional read-only checks used Get-FileHash for the actual saved tasks, counted Requirement/Scenario headings, checked each attachment's exact index membership, and searched current-truth artifacts for stale unconditional no-source boundaries. These are authoring audits, not another task parser or product test suite.

## Intentionally omitted

- Unreal build, NativeEngine/Baseline Automation and all wider UE suites: this turn changes only planning records; product execution acceptance is still pending.
- Harness Quick/Performance/Integration and unrelated plugin/Standalone/JIT tests: no implementation or those shared runtime contracts changed this turn.
- Terminal evolution, durable spec sync and archive: this active Change is planning-only and all implementation nodes remain pending.

The earlier data/planning-validation.md is retained as creation-time historical evidence, not overwritten to claim coverage of this Replan.
