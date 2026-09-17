#requires -Version 7.0
#requires -PSEdition Core

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal($Expected, $Actual, [string]$Message) {
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-draft-{0}" -f [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $fixtureRoot -Force)
$context = [pscustomobject]@{
    HarnessRoot = $projectRoot
    WorkspaceRoot = $fixtureRoot
    PrimaryRoot = $fixtureRoot
    GitCommonDir = $fixtureRoot
    Topology = 'Primary'
    Branch = 'fixture'
    Head = '1111111111111111111111111111111111111111'
}

try {
    $created = Invoke-Harness -Command harness.draft.create -Context $context -Parameters @{ DraftId = 'harness/fixture'; Title = 'Fixture discussion'; Mode = 'research' }
    Assert-Equal 'Succeeded' $created.status 'a named topic can be created'
    $draftRoot = Join-Path $fixtureRoot 'openspec/drafts/harness/fixture'
    Assert-True (Test-Path (Join-Path $draftRoot 'README.md')) 'create writes a topic README'
    Assert-True (Test-Path (Join-Path $draftRoot 'log.md')) 'create writes a conversation log'

    $status = Invoke-Harness -Command harness.draft.status -Context $context -Parameters @{ DraftId = 'harness/fixture' }
    Assert-Equal 'Succeeded' $status.status 'a new topic has readable status'
    Assert-True $status.data.Valid 'the initial five-line current state is valid'
    Assert-Equal 'log.md' $status.data.Focus 'the initial focus resolves to its own log'

    $duplicate = Invoke-Harness -Command harness.draft.create -Context $context -Parameters @{ DraftId = 'harness/fixture'; Title = 'Overwrite' }
    Assert-Equal 'Failed' $duplicate.status 'create never overwrites an existing topic'
    $escape = Invoke-Harness -Command harness.draft.create -Context $context -Parameters @{ DraftId = 'harness/../escape'; Title = 'Escape' }
    Assert-Equal 'Failed' $escape.status 'topic identity cannot traverse outside drafts'

    $designRoot = Join-Path $draftRoot 'designs/selected'
    [void](New-Item -ItemType Directory -Path $designRoot -Force)
    [System.IO.File]::WriteAllText((Join-Path $designRoot 'README.md'), "---`ndesign: selected`nstatus: designed`napproval_round: R1`nopened: 2026-09-17`n---`n`nAccepted at R1.`n")
    [System.IO.File]::WriteAllText((Join-Path $designRoot 'design.md'), "# Selected design`n`nSee [explanation](../../findings/explanation.md).`n")
    [void](New-Item -ItemType Directory -Path (Join-Path $draftRoot 'findings') -Force)
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'findings/explanation.md'), "# Explanation`n`nA relevant diagram and explanation.`n")
    [System.IO.File]::WriteAllText((Join-Path $designRoot 'handoff.md'), "## OpenSpec Handoff`n`n- Scope: selected`n- Target Change: harness/improve-draft-gate-coverage`n`n## Exploration Carryover`n`n| Source | Target | Reason |`n| --- | --- | --- |`n| design.md | attachments/drafts/design.md | Accepted design |`n| handoff.md | attachments/drafts/handoff.md | Accepted handoff |`n| not-applicable | attachments/drafts/glossary.md | No names |`n| ../../findings/explanation.md | attachments/drafts/findings/explanation.md | Required evidence |`n")
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'log.md'), "# Log`n`n## R1`n`nAssistant explanation and user decision.`n")
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'README.md'), "---`ndraft: harness/fixture`nmode: design`nstatus: exploring`nopened: 2026-09-17`n---`n`n# Fixture discussion`n`n- **此刻**：收束这一刀`n- **焦点**：[selected](designs/selected/design.md)`n- **已决**：R1 accepted`n- **下一问**：无`n- **讲清于**：[R1](log.md#r1) · 2026-09-17`n")

    $ready = Invoke-Harness -Command harness.draft.check -Context $context -Parameters @{ DraftId = 'harness/fixture'; Scope = 'selected'; ChangeId = 'harness/improve-draft-gate-coverage' }
    Assert-Equal 'Succeeded' $ready.status 'selected approved design passes the exact handoff gate'

    $datedReadme = [System.IO.File]::ReadAllText((Join-Path $draftRoot 'README.md'))
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'README.md'), $datedReadme.Replace(' · 2026-09-17', ''))
    $undated = Invoke-Harness -Command harness.draft.status -Context $context -Parameters @{ DraftId = 'harness/fixture' }
    Assert-True (-not $undated.data.Valid) 'an explained round without a date is not current-state evidence'
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'README.md'), $datedReadme)

    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'log.md'), "# Log`n")
    $missingRound = Invoke-Harness -Command harness.draft.check -Context $context -Parameters @{ DraftId = 'harness/fixture'; Scope = 'selected'; ChangeId = 'harness/improve-draft-gate-coverage' }
    Assert-Equal 'Failed' $missingRound.status 'an explanation link with no actual round blocks handoff'
    [System.IO.File]::WriteAllText((Join-Path $draftRoot 'log.md'), "# Log`n`n## R1`n`nAssistant explanation and user decision.`n")

    [System.IO.File]::WriteAllText((Join-Path $designRoot 'README.md'), "---`ndesign: selected`nstatus: parked`nopened: 2026-09-17`n---`n")
    $parked = Invoke-Harness -Command harness.draft.archive -Context $context -Parameters @{ DraftId = 'harness/fixture'; Closure = 'completed' }
    Assert-Equal 'Failed' $parked.status 'completed archive refuses a parked scoped design'
    [System.IO.File]::WriteAllText((Join-Path $designRoot 'README.md'), "---`ndesign: selected`nstatus: designed`napproval_round: R1`nopened: 2026-09-17`n---`nAccepted at R1.`n")
    $archived = Invoke-Harness -Command harness.draft.archive -Context $context -Parameters @{ DraftId = 'harness/fixture'; Closure = 'completed' }
    Assert-Equal 'Succeeded' $archived.status 'a concluded topic archives explicitly'
    Assert-True (-not (Test-Path $draftRoot)) 'archive removes the active topic path'
    Assert-True (Test-Path (Join-Path $archived.data.Path 'log.md')) 'archive preserves the original conversation'
    Assert-True ($archived.data.Path -like '*openspec*archive*drafts*harness*') 'archive stays in the local draft archive tree'

    $legacyRoot = Join-Path $fixtureRoot 'openspec/drafts/harness/legacy'
    [void][IO.Directory]::CreateDirectory($legacyRoot)
    $legacyReadme = "---`ndraft: harness/legacy`nmode: design`nstatus: handed-off`nhanded_off: 2026-09-11`ntarget_change: harness/test-legacy-handoff`nopened: 2026-09-11`n---`n`nOriginal flat handoff record.`n"
    [IO.File]::WriteAllText((Join-Path $legacyRoot 'README.md'), $legacyReadme)
    foreach ($file in @('log.md','design.md','handoff.md')) { [IO.File]::WriteAllText((Join-Path $legacyRoot $file), "Original $file`n") }
    $missingTarget = Invoke-Harness harness.draft.archive -Context $context -Parameters @{DraftId='harness/legacy';Closure='completed'}
    Assert-Equal 'Failed' $missingTarget.status 'legacy handoff with missing target cannot be archived as completed'
    Assert-Equal $legacyReadme ([IO.File]::ReadAllText((Join-Path $legacyRoot 'README.md'))) 'rejected legacy archive preserves its source metadata'
    $legacyChange = Join-Path $fixtureRoot 'openspec/archive/changes/harness/2026-09-11-test-legacy-handoff'
    [void][IO.Directory]::CreateDirectory($legacyChange)
    [IO.File]::WriteAllText((Join-Path $legacyChange 'change.yaml'), "metadata:`n  id: harness/test-legacy-handoff`n  uid: change_fixture`nclosure:`n  kind: completed`n")
    $legacyArchive = Invoke-Harness harness.draft.archive -Context $context -Parameters @{DraftId='harness/legacy';Closure='completed'}
    Assert-Equal 'Succeeded' $legacyArchive.status 'preserved flat handed-off drafts archive without schema migration'
    foreach ($file in @('log.md','design.md','handoff.md')) {
        Assert-Equal "Original $file`n" ([IO.File]::ReadAllText((Join-Path $legacyArchive.data.Path $file))) 'legacy archive preserves original conversation and handoff bytes'
    }
    Assert-True (-not (Test-Path (Join-Path $legacyArchive.data.Path 'designs'))) 'legacy archive does not invent scoped design directories'
}
finally {
    $resolvedFixture = [System.IO.Path]::GetFullPath($fixtureRoot)
    $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/')
    if (-not $resolvedFixture.StartsWith(($temporaryRoot + [System.IO.Path]::DirectorySeparatorChar + 'harness-draft-'), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing fixture cleanup outside the expected temporary draft root: $resolvedFixture"
    }
    if (Test-Path -LiteralPath $resolvedFixture) { Remove-Item -LiteralPath $resolvedFixture -Recurse -Force }
}

'Harness draft lifecycle tests passed.'
