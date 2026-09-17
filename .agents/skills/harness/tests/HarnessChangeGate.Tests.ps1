#requires -Version 7.0
#requires -PSEdition Core

[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Equal($Expected, $Actual, [string]$Message) {
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}
function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-change-gate-{0}" -f [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $fixtureRoot -Force)
$exe = Join-Path $projectRoot '.agents/skills/openspec/bin/openspec.exe'
$context = [pscustomobject]@{
    HarnessRoot = $projectRoot; WorkspaceRoot = $fixtureRoot; PrimaryRoot = $fixtureRoot
    GitCommonDir = $fixtureRoot; Topology = 'Primary'; Branch = 'fixture'; Head = '1111111111111111111111111111111111111111'
}
try {
    & $exe init $fixtureRoot --project-id fixture --title Fixture --workflow angelscript | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Fixture OpenSpec init failed.' }
    [void](New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'openspec/workflows') -Force)
    Copy-Item -LiteralPath (Join-Path $projectRoot 'openspec/workflows/angelscript') -Destination (Join-Path $fixtureRoot 'openspec/workflows/angelscript') -Recurse -Force
    $domain = Invoke-Harness -Command openspec.domain -Context $context -ArgumentList @('create', 'harness', '--title', 'Harness', '--json')
    Assert-Equal 'Succeeded' $domain.status 'fixture domain is created'

    $legacy = Invoke-Harness -Command openspec.change -Context $context -ArgumentList @('create', 'harness/improve-bypass-new-gate', '--title', 'Bypass', '--goal', 'No bypass', '--json')
    Assert-Equal 'Failed' $legacy.status 'generic route cannot bypass the new creation gate'
    $reorderedCreate = Invoke-Harness -Command openspec.change -Context $context -ArgumentList @('--json', 'create', 'harness/improve-reordered-bypass', '--title', 'Bypass')
    Assert-Equal 'Failed' $reorderedCreate.status 'leading CLI options cannot bypass the creation gate'
    Push-Location -LiteralPath $fixtureRoot
    try { & $exe change create harness/improve-bypass-new-gate --title Bypass --goal 'No bypass' --json | Out-Null }
    finally { Pop-Location }
    Assert-Equal 0 $LASTEXITCODE 'portable CLI fixture demonstrates an external creation path'
    $unmarked = Invoke-Harness -Command harness.change.plan.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-bypass-new-gate' }
    Assert-Equal 'Failed' $unmarked.status 'an unmarked post-gate Change cannot masquerade as a grandfathered plan'

    $missingReason = Invoke-Harness -Command harness.change.create -Context $context -Parameters @{ ChangeId = 'harness/improve-direct-change'; Title = 'Direct'; Goal = 'Direct work'; Origin = 'Direct' }
    Assert-Equal 'Failed' $missingReason.status 'direct creation requires a concrete skipped-draft reason'
    $direct = Invoke-Harness -Command harness.change.create -Context $context -Parameters @{ ChangeId = 'harness/improve-direct-change'; Title = 'Direct'; Goal = 'Direct work'; Origin = 'Direct'; Reason = 'A bounded correction with no user-owned decision' }
    Assert-Equal 'Succeeded' $direct.status 'direct change is created through Harness'
    $changeRoot = Join-Path $fixtureRoot 'openspec/changes/harness/improve-direct-change'
    Assert-True (Test-Path (Join-Path $changeRoot 'attachments/data/harness-origin.json')) 'new Change carries an origin marker'
    $beforeDesign = Invoke-Harness -Command harness.change.plan.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-direct-change' }
    Assert-Equal 'Failed' $beforeDesign.status 'new Change cannot enter tasks without root design'
    $blockedTask = Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'harness/improve-direct-change' }
    Assert-Equal 'Failed' $blockedTask.status 'task.status applies the new plan gate before exposing Ready tasks'
    Assert-True ($blockedTask.error.message -match 'design\.md') 'task.status names the missing design artifact'
    $positionalBypass = Invoke-Harness -Command task.status -Context $context -ArgumentList @('--change', 'harness/improve-direct-change')
    Assert-Equal 'Failed' $positionalBypass.status 'positional arguments cannot bypass the plan gate'
    [System.IO.File]::WriteAllText((Join-Path $changeRoot 'design.md'), "## Call chains`n`nnone — documentation-only change with no code path.`n")
    $validPlan = Invoke-Harness -Command harness.change.plan.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-direct-change' }
    Assert-Equal 'Succeeded' $validPlan.status 'non-code Change records none and reason in its own design'

    $draftRoot = Join-Path $fixtureRoot 'openspec/drafts/harness/fixture'
    [void](New-Item -ItemType Directory -Path (Join-Path $draftRoot 'designs/selected') -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $draftRoot 'findings') -Force)
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'README.md'), "---`ndraft: harness/fixture`nmode: design`nstatus: exploring`nopened: 2026-09-17`n---`n`n- **此刻**：收束`n- **焦点**：[selected](designs/selected/design.md)`n- **已决**：R1`n- **下一问**：无`n- **讲清于**：[R1](log.md#r1) · 2026-09-17`n")
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'log.md'), "## R1`n`nExplained call chain and approval.`n")
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'findings/evidence.md'), "# Evidence`n")
    $selected = Join-Path $draftRoot 'designs/selected'
    [System.IO.File]::WriteAllText((Join-Path $selected 'README.md'), "---`ndesign: selected`nstatus: designed`napproval_round: R1`nopened: 2026-09-17`n---`n`nApproved at R1.`n")
    [System.IO.File]::WriteAllText((Join-Path $selected 'design.md'), "# Selected`n`n[Evidence](../../findings/evidence.md)`n")
    [System.IO.File]::WriteAllText((Join-Path $selected 'handoff.md'), "## OpenSpec Handoff`n`n- Scope: selected`n- Target Change: harness/improve-seeded-change`n`n## Exploration Carryover`n`n| Source | Target | Reason |`n| --- | --- | --- |`n| design.md | attachments/drafts/design.md | Accepted design |`n| handoff.md | attachments/drafts/handoff.md | Accepted handoff |`n| not-applicable | attachments/drafts/glossary.md | No names |`n| ../../findings/evidence.md | attachments/drafts/findings/evidence.md | Required evidence |`n")
    $seeded = Invoke-Harness -Command harness.change.create -Context $context -Parameters @{ ChangeId = 'harness/improve-seeded-change'; Title = 'Seeded'; Goal = 'Seed handoff'; Origin = 'Draft'; DraftId = 'harness/fixture'; Scope = 'selected' }
    Assert-Equal 'Succeeded' $seeded.status 'approved exact draft can create a Change'
    $seedRoot = Join-Path $fixtureRoot 'openspec/changes/harness/improve-seeded-change'
    $early = Invoke-Harness -Command harness.change.seed.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-seeded-change' }
    Assert-Equal 'Failed' $early.status 'created skeleton cannot pass an unseeded export gate'
    $blockedPlanning = Invoke-Harness -Command openspec.instructions -Context $context -ArgumentList @('proposal', '--change', 'harness/improve-seeded-change', '--json')
    Assert-Equal 'Failed' $blockedPlanning.status 'Ensure plan cannot request planning instructions before the draft export gate'
    Assert-True ($blockedPlanning.error.message -match 'INDEX\.md') 'planning gate names the missing index'
    $reorderedPlanning = Invoke-Harness -Command openspec.instructions -Context $context -ArgumentList @('--change', 'harness/improve-seeded-change', 'proposal')
    Assert-Equal 'Failed' $reorderedPlanning.status 'leading CLI options cannot bypass the planning gate'
    $implicitPlanning = Invoke-Harness -Command openspec.instructions -Context $context -ArgumentList @('proposal', '--json')
    Assert-Equal 'Failed' $implicitPlanning.status 'planning instructions require an exact Change identity'
    [void](New-Item -ItemType Directory -Path (Join-Path $seedRoot 'attachments/drafts/findings') -Force)
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'attachments/drafts/design.md'), "# Selected`n`n[Evidence](findings/evidence.md)`n")
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'attachments/drafts/handoff.md'), "## OpenSpec Handoff`n`n- Scope: selected`n- Target Change: harness/improve-seeded-change`n`n## Exploration Carryover`n`n| Source | Target | Reason |`n| --- | --- | --- |`n| design.md | attachments/drafts/design.md | Accepted design |`n| handoff.md | attachments/drafts/handoff.md | Accepted handoff |`n| not-applicable | attachments/drafts/glossary.md | No names |`n| ../../findings/evidence.md | attachments/drafts/findings/evidence.md | Required evidence |`n")
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'attachments/drafts/glossary.md'), "# Glossary`n`nNot applicable.`n")
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'attachments/drafts/findings/evidence.md'), "# Evidence`n")
    [void](New-Item -ItemType Directory -Path (Join-Path $seedRoot 'attachments/talks') -Force)
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'attachments/talks/talk.md'), "# Confirmed talk`n")
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'attachments/INDEX.md'), "# Index`n`n- [Design](drafts/design.md)`n- [Handoff](drafts/handoff.md)`n- [Glossary](drafts/glossary.md)`n- [Evidence](drafts/findings/evidence.md)`n- [Origin](data/harness-origin.json)`n")
    $unindexedTalk = Invoke-Harness -Command harness.change.seed.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-seeded-change' }
    Assert-Equal 'Failed' $unindexedTalk.status 'all confirmed carryover must be indexed before planning'
    Add-Content -LiteralPath (Join-Path $seedRoot 'attachments/INDEX.md') -Value '- [Talk](talks/talk.md)'
    $completeSeed = Invoke-Harness -Command harness.change.seed.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-seeded-change' }
    Assert-Equal 'Succeeded' $completeSeed.status 'indexed self-contained seed passes'
    $allowedPlanning = Invoke-Harness -Command openspec.instructions -Context $context -ArgumentList @('proposal', '--change', 'harness/improve-seeded-change', '--json')
    if ($allowedPlanning.status -ne 'Succeeded') { throw "Allowed planning failed: $($allowedPlanning.error.message); $($allowedPlanning.data | ConvertTo-Json -Depth 5 -Compress)" }
    Assert-Equal 'Succeeded' $allowedPlanning.status 'Ensure plan can request instructions after the export gate'
    [System.IO.File]::WriteAllText((Join-Path $seedRoot 'design.md'), "## Call chains`n`n- `"A`" -> `"B`"`n`nMeasured at: 1111111111111111111111111111111111111111; dirty: none.`n")
    $completePlan = Invoke-Harness -Command harness.change.plan.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-seeded-change' }
    Assert-Equal 'Succeeded' $completePlan.status 'root design with measured call chain passes'
}
finally {
    $resolvedFixture = [System.IO.Path]::GetFullPath($fixtureRoot)
    $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/')
    if (-not $resolvedFixture.StartsWith(($temporaryRoot + [System.IO.Path]::DirectorySeparatorChar + 'harness-change-gate-'), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing fixture cleanup outside the expected temporary Change gate root: $resolvedFixture"
    }
    if (Test-Path -LiteralPath $resolvedFixture) { Remove-Item -LiteralPath $resolvedFixture -Recurse -Force }
}
'Harness Change gate tests passed.'
