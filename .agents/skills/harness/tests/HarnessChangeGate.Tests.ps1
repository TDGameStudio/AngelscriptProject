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
function Invoke-GatedCreate([hashtable]$Parameters) {
    $Parameters.SessionId = 'gate-fixture'
    $preview = Invoke-Harness harness.change.create -Context $context -Parameters ($Parameters + @{PlanOnly=$true})
    if ($preview.status -ne 'Succeeded') { throw $preview.error.message }
    $Parameters.Gate = @{ConvergenceSource='message:ready';DecisionSource='message:create';Decision='create';TargetChange=$Parameters.ChangeId;HandoffRevision=$preview.data.HandoffRevision}
    return Invoke-Harness harness.change.create -Context $context -Parameters $Parameters
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
    $direct = Invoke-GatedCreate @{ ChangeId = 'harness/improve-direct-change'; Title = 'Direct'; Goal = 'Direct work'; Origin = 'Direct'; Reason = 'A bounded correction with no user-owned decision'; HandoffText='The shown bounded direct correction.' }
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

    # A native success followed by a marker-write failure retains the consumed Gate.
    # Inject only the private write boundary: the portable CLI still creates the real fixture.
    $gateModule = Get-Module ChangeGate -All | Select-Object -First 1
    $markerWriter = & $gateModule { $entry = Get-Item Function:Write-HarnessChangeMarker -ErrorAction SilentlyContinue; if ($entry) { $entry.ScriptBlock } }
    $partialParams = @{ChangeId='harness/improve-partial-create';Title='Partial';Goal='Recover accepted creation';Origin='Direct';Reason='Explicit formal work';HandoffText='Shown recoverable design';SessionId='gate-fixture'}
    try {
        & $gateModule { function script:Write-HarnessChangeMarker { param($Root, $Marker) throw 'Injected marker write failure' } }
        $partial = Invoke-GatedCreate $partialParams.Clone()
        Assert-Equal 'Failed' $partial.status 'marker write failure is reported instead of completing creation'
        Assert-True ($partial.error.message -match 'Injected marker write failure') 'fixture reached the intended marker write boundary'
    }
    finally {
        & $gateModule { param($Original) if ($Original) { Set-Item Function:script:Write-HarnessChangeMarker $Original } else { Remove-Item Function:script:Write-HarnessChangeMarker -ErrorAction SilentlyContinue } } $markerWriter
    }
    $partialRoot = Join-Path $fixtureRoot ('openspec/changes/' + $partialParams.ChangeId)
    Assert-True (Test-Path (Join-Path $partialRoot 'change.yaml')) 'native manifest survived the injected marker failure'
    Assert-True (-not (Test-Path (Join-Path $partialRoot 'attachments/data/harness-origin.json'))) 'failed marker write has not claimed completion'
    $intentPath = & $gateModule { param($FixtureContext,$Id) Get-HarnessChangeIntentPath $FixtureContext $Id } $context $partialParams.ChangeId
    $intent = Get-Content -LiteralPath $intentPath -Raw | ConvertFrom-Json
    Assert-Equal 'created' $intent.state 'native success checkpoint proves creation ownership'
    $acceptedId = $intent.marker.gate.handoff_id
    $journalBytes = [IO.File]::ReadAllText($intentPath)
    $partialPreview = Invoke-Harness harness.change.create -Context $context -Parameters ($partialParams + @{PlanOnly=$true})
    Assert-Equal 'Succeeded' $partialPreview.status 'partial owned creation can be inspected without rewriting state'
    Assert-Equal $journalBytes ([IO.File]::ReadAllText($intentPath)) 'PlanOnly leaves the private intent byte-identical'
    Assert-True (-not (Test-Path (Join-Path $partialRoot 'attachments/data/harness-origin.json'))) 'PlanOnly does not repair the marker'
    $wrongParams = $partialParams.Clone(); $wrongParams.Goal = 'A different creation request'
    $wrongRetry = Invoke-Harness harness.change.create -Context $context -Parameters $wrongParams
    Assert-Equal 'Failed' $wrongRetry.status 'a different request cannot consume another creation intent'
    $manifestPath = Join-Path $partialRoot 'change.yaml'
    $manifest = [IO.File]::ReadAllText($manifestPath)
    Add-Content -LiteralPath $manifestPath -Value '# External manifest edit'
    $changedRetry = Invoke-Harness harness.change.create -Context $context -Parameters $partialParams
    Assert-Equal 'Failed' $changedRetry.status 'changed native manifest cannot acquire the stored creation identity'
    Assert-True ($changedRetry.error.message -match 'CreationRecoveryRequired') 'ambiguous ownership exposes a recovery issue'
    [IO.File]::WriteAllText($manifestPath, $manifest)
    $recovered = Invoke-Harness harness.change.create -Context $context -Parameters $partialParams
    if ($recovered.status -ne 'Succeeded') { throw $recovered.error.message }
    Assert-Equal $acceptedId $recovered.data.HandoffId 'exact retry reuses the already consumed receipt without a new Gate'
    Assert-True (-not (Test-Path -LiteralPath $intentPath)) 'finished creation removes its private recovery intent'
    $recoveredMarker = Get-Content -LiteralPath (Join-Path $partialRoot 'attachments/data/harness-origin.json') -Raw | ConvertFrom-Json
    Assert-Equal $acceptedId $recoveredMarker.gate.handoff_id 'recovered marker retains the original receipt'
    Assert-True (Test-Path (Join-Path $partialRoot ('attachments/talks/' + $recoveredMarker.gate.post_talk_id + '.md'))) 'exact retry also completes the mandatory follow-up'

    # Prepared intent alone cannot distinguish our interrupted native write from an
    # external unmarked Change: this narrower crash window deliberately fails closed.
    $checkpointWriter = & $gateModule { (Get-Item Function:Set-HarnessChangeCreatedCheckpoint).ScriptBlock }
    $ambiguousParams = @{ChangeId='harness/improve-ambiguous-create';Title='Ambiguous';Goal='Do not claim an unproven manifest';Origin='Direct';Reason='Explicit formal work';HandoffText='Shown exact design';SessionId='gate-fixture'}
    try {
        & $gateModule { function script:Set-HarnessChangeCreatedCheckpoint { param($Path, $Intent, $Root) throw 'Injected native checkpoint failure' } }
        $ambiguous = Invoke-GatedCreate $ambiguousParams.Clone()
        Assert-Equal 'Failed' $ambiguous.status 'native checkpoint failure is visible'
        Assert-True ($ambiguous.error.message -match 'Injected native checkpoint failure') 'fixture reached the checkpoint boundary'
    }
    finally { & $gateModule { param($Original) Set-Item Function:script:Set-HarnessChangeCreatedCheckpoint $Original } $checkpointWriter }
    $ambiguousRetry = Invoke-Harness harness.change.create -Context $context -Parameters $ambiguousParams
    Assert-Equal 'Failed' $ambiguousRetry.status 'prepared intent does not prove ownership of an existing native Change'
    Assert-True ($ambiguousRetry.error.message -match 'CreationRecoveryRequired') 'unprovable partial creation names its explicit recovery issue'
    Assert-True (-not (Test-Path (Join-Path $fixtureRoot ('openspec/changes/' + $ambiguousParams.ChangeId + '/attachments/data/harness-origin.json')))) 'ambiguous retry did not claim the Change'
    $foreignRetry = Invoke-Harness harness.change.create -Context $context -Parameters @{ChangeId='harness/improve-bypass-new-gate';Title='Bypass';Goal='No bypass';Origin='Direct';Reason='Foreign unmarked creation';HandoffText='No prior Harness intent'}
    Assert-Equal 'Failed' $foreignRetry.status 'an external unmarked Change cannot be adopted by retry'
    Assert-True ($foreignRetry.error.message -match 'CreationRecoveryRequired') 'unmarked foreign creation reports the same fail-closed recovery boundary'

    # A rejected native create leaves no manifest: register its missing domain and
    # retry the same accepted request, without manufacturing a second approval.
    $preparedParams = @{ChangeId='recovery/improve-prepared-retry';Title='Prepared';Goal='Retry native prerequisite failure';Origin='Direct';Reason='Explicit formal work';HandoffText='Shown retryable design';SessionId='gate-fixture'}
    $preparedFailure = Invoke-GatedCreate $preparedParams.Clone()
    Assert-Equal 'Failed' $preparedFailure.status 'a missing native domain preserves a prepared intent'
    $preparedPath = & $gateModule { param($FixtureContext,$Id) Get-HarnessChangeIntentPath $FixtureContext $Id } $context $preparedParams.ChangeId
    $preparedIntent = Get-Content -LiteralPath $preparedPath -Raw | ConvertFrom-Json
    Assert-Equal 'prepared' $preparedIntent.state 'native prerequisite failure is not recorded as owned creation'
    $alteredGate = @{ConvergenceSource='message:replacement';DecisionSource='message:create';Decision='create';TargetChange=$preparedParams.ChangeId;HandoffRevision=$preparedIntent.marker.gate.revision}
    $replacedApproval = Invoke-Harness harness.change.create -Context $context -Parameters ($preparedParams + @{Gate=$alteredGate})
    Assert-Equal 'Failed' $replacedApproval.status 'retry cannot replace the original consumed approval source'
    $recoveryDomain = Invoke-Harness openspec.domain -Context $context -ArgumentList @('create','recovery','--title','Recovery','--json')
    Assert-Equal 'Succeeded' $recoveryDomain.status 'native prerequisite is repaired inside the fixture'
    $preparedRetry = Invoke-Harness harness.change.create -Context $context -Parameters $preparedParams
    if ($preparedRetry.status -ne 'Succeeded') { throw $preparedRetry.error.message }
    Assert-Equal $preparedIntent.marker.gate.handoff_id $preparedRetry.data.HandoffId 'safe prepared retry keeps the original consumed receipt'
    Assert-True (-not (Test-Path -LiteralPath $preparedPath)) 'completed prepared retry removes its intent'

    # Marker-present recovery must preserve the receipt when follow-up writing
    # fails, and finish the same talk after the local obstruction is removed.
    $followupParams = @{ChangeId='harness/improve-followup-recovery';Title='Followup';Goal='Recover delivery after marker';Origin='Direct';Reason='Explicit formal work';HandoffText='Shown followup design';SessionId='gate-fixture'}
    try {
        & $gateModule {
            param($Original)
            $script:FixtureMarkerWriter = $Original
            function script:Write-HarnessChangeMarker {
                param($Root, $Marker)
                & $script:FixtureMarkerWriter $Root $Marker
                [IO.File]::WriteAllText((Join-Path $Root 'attachments/talks'), 'Fixture directory obstruction')
            }
        } $markerWriter
        $followupFailure = Invoke-GatedCreate $followupParams.Clone()
        Assert-Equal 'Failed' $followupFailure.status 'post-marker follow-up write failure is reported'
    }
    finally { & $gateModule { param($Original) Set-Item Function:script:Write-HarnessChangeMarker $Original; Remove-Variable FixtureMarkerWriter -Scope Script } $markerWriter }
    $followupRoot = Join-Path $fixtureRoot ('openspec/changes/' + $followupParams.ChangeId)
    $followupMarker = Get-Content -LiteralPath (Join-Path $followupRoot 'attachments/data/harness-origin.json') -Raw | ConvertFrom-Json
    [IO.File]::Delete((Join-Path $followupRoot 'attachments/talks'))
    $followupRetry = Invoke-Harness harness.change.create -Context $context -Parameters $followupParams
    if ($followupRetry.status -ne 'Succeeded') { throw $followupRetry.error.message }
    Assert-Equal $followupMarker.gate.handoff_id $followupRetry.data.HandoffId 'post-marker retry retains the original handoff identity'
    Assert-True (Test-Path (Join-Path $followupRoot ('attachments/talks/' + $followupMarker.gate.post_talk_id + '.md'))) 'post-marker retry restores its exact mandatory talk'

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
    $seeded = Invoke-GatedCreate @{ ChangeId = 'harness/improve-seeded-change'; Title = 'Seeded'; Goal = 'Seed handoff'; Origin = 'Draft'; DraftId = 'harness/fixture'; Scope = 'selected' }
    Assert-Equal 'Succeeded' $seeded.status 'approved exact draft can create a Change'
    $seedRoot = Join-Path $fixtureRoot 'openspec/changes/harness/improve-seeded-change'
    $early = Invoke-Harness -Command harness.change.seed.verify -Context $context -Parameters @{ ChangeId = 'harness/improve-seeded-change' }
    Assert-Equal 'Failed' $early.status 'created skeleton cannot pass an unseeded export gate'
    $blockedPlanning = Invoke-Harness -Command openspec.instructions -Context $context -ArgumentList @('proposal', '--change', 'harness/improve-seeded-change', '--json')
    Assert-Equal 'Failed' $blockedPlanning.status 'Ensure plan cannot request planning instructions before the draft export gate'
    Assert-True ($blockedPlanning.error.message -match 'missing') 'planning gate names the missing export'
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
    Add-Content -LiteralPath (Join-Path $seedRoot 'attachments/INDEX.md') -Value "- [Design](drafts/design.md)`n- [Handoff](drafts/handoff.md)`n- [Glossary](drafts/glossary.md)`n- [Evidence](drafts/findings/evidence.md)"
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
