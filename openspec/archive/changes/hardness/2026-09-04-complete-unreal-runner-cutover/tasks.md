---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "2.3": ["2.1"]
    "3.1": ["2.2", "2.3"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
---

## 1. Record the contract and RED coverage

- [x] 1.1 Create the separate cutover Change with the physical/execution split, ownership model, executor constraint, deletion gate, and no-Documents boundary — verify: `pwsh.exe -NoProfile -Command "Import-Module './.agents/skills/hardness/scripts/Hardness.psd1' -Force; $context = New-HardnessContext -WorkspaceRoot (Get-Location).Path; $result = Invoke-Hardness -Command 'openspec.validate' -Context $context -ArgumentList @('hardness/complete-unreal-runner-cutover','--strict','--json'); if ($result.status -ne 'Succeeded') { exit 1 }"`
  > Files: `openspec/changes/hardness/complete-unreal-runner-cutover/**`

- [x] 1.2 Add focused coverage for stable Request/Run schemas, read-only planning, allocation conflicts, matching foreign mappings, exact cleanup, cancellation, stale recovery, mapped process correlation, suite entries, and Smoke parity — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Foundation`
  > Files: `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`

## 2. Implement the short execution path

- [x] 2.1 Add the bounded assignment registry, native DOS-device interop, stable allocation, exact file-identity validation, and stable Request/Run path projection — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag RunLifecycle`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/WindowsPath.ps1`, `.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psm1`, `.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1`

- [x] 2.2 Integrate workspace/drive/engine lease order, worker mapping lifetime, cancellation cleanup, mapped UBT/editor/temp/report paths, suite entry paths, and physical-evidence handling — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Suites`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Run.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Suites.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/AutomationReport.ps1`, `.agents/skills/unreal-engine-develop/data/**`

- [x] 2.3 Correlate mapped UBT processes to physical workspaces and align `AngelscriptSmoke` with the declarative Smoke suite — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Discovery`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`, `Config/DefaultEngine.ini`

## 3. Verify and complete cutover

- [x] 3.1 Run PowerShell parser and focused isolated tests, including real transient mapping creation/removal in the isolated fixture; repair every failure — verify: `pwsh.exe -NoProfile -Command "$tags = @('Foundation','Discovery','Build','RunLifecycle','ConcurrencyProgress','Automation','Suites'); foreach ($tag in $tags) { & '.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1' -Tag $tag; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }"`
  > Files: `none (verification only)`

- [x] 3.2 Attempt one real default-executor build and run the `AngelscriptSmoke` group through Hardness after the isolated long-path tests pass; preserve the existing executor defaults, record the unrelated generated-JIT compilation failure for later work, and require successful Unreal startup plus Smoke completion — verify: `pwsh.exe -NoProfile -Command "Import-Module './.agents/skills/hardness/scripts/Hardness.psd1' -Force; $context = New-HardnessContext -WorkspaceRoot (Get-Location).Path; $null = Invoke-Hardness -Command 'workspace.activate' -Context $context; $smoke = Invoke-Hardness -Command 'ue.test' -Context $context -Parameters @{ Group = 'AngelscriptSmoke'; TimeoutMs = 600000 }; if ($smoke.status -ne 'Succeeded' -or $smoke.data.State -ne 'Succeeded' -or $smoke.data.Execution.mappingState -ne 'Absent') { exit 1 }"`
  > Files: `none (real verification only)`

- [x] 3.3 Synchronize the verified delta into the current Unreal specification, record the compact workflow evaluation, run the focused Unreal test groups, validate, and archive this focused Change without deleting root Tools or editing Documents — verify: `pwsh.exe -NoProfile -Command "$tags = @('Foundation','Discovery','Build','RunLifecycle','ConcurrencyProgress','Automation','Suites'); foreach ($tag in $tags) { & '.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1' -Tag $tag; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }; Import-Module './.agents/skills/hardness/scripts/Hardness.psd1' -Force; $context = New-HardnessContext -WorkspaceRoot (Get-Location).Path; $result = Invoke-Hardness -Command 'openspec.validate' -Context $context -ArgumentList @('hardness/complete-unreal-runner-cutover','--strict','--json'); if ($result.status -ne 'Succeeded') { exit 1 }"`
  > Files: `openspec/specs/hardness/unreal/spec.md`, `openspec/changes/hardness/complete-unreal-runner-cutover/**`, `AGENTS_ZH.md`, `AGENTS.md`
