#requires -Version 7.0
#requires -PSEdition Core
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')"
    }
}

function Assert-Match {
    param([string]$Actual, [string]$Pattern, [string]$Message)
    if ($Actual -notmatch $Pattern) {
        throw "Assertion failed: $Message (pattern '$Pattern', actual '$Actual')"
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Write-FixtureText {
    param([string]$Path, [string]$Text)
    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        [void][System.IO.Directory]::CreateDirectory($parent)
    }
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Invoke-FixtureOpenSpec {
    param([string]$Executable, [string]$WorkingDirectory, [string[]]$Arguments)
    Push-Location -LiteralPath $WorkingDirectory
    try {
        $output = @(& $Executable @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    if ($exitCode -ne 0) {
        throw "OpenSpec fixture command failed ($exitCode): $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
}

function Write-FixtureTasks {
    param([string]$ChangeRoot, [bool]$Complete)
    $mark = if ($Complete) { 'x' } else { ' ' }
    Write-FixtureText -Path (Join-Path $ChangeRoot 'tasks.md') -Text @"
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Tasks

- [$mark] 1.1 Exercise terminal closure

    **Files**

    - ``fixture``

    **Verification**

    ``````sh
    focused fixture
    ``````
"@
}

function Write-FixtureEvaluation {
    param(
        [string]$ChangeRoot,
        [string]$InputSha256,
        [string]$ClosureKind = 'completed',
        [string]$CapturedAt = '2026-09-04T13:15:00+08:00'
    )
    Write-FixtureText -Path (Join-Path $ChangeRoot 'attachments\data\workflow-evaluation.md') -Text @"
---
record: harness-workflow-evaluation-v1
result: passed
change: fixture/evolution-closure
closure_kind: $ClosureKind
input_sha256: $InputSha256
captured_at: $CapturedAt
---

# Workflow Evaluation

Focused fixture evidence.
"@
}

function Write-FixtureIndex {
    param([string]$ChangeRoot, [string[]]$AdditionalEntries = @())
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# INDEX') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add('## Attachment index') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add('- `data/workflow-evaluation.md` - focused terminal evaluation.') | Out-Null
    foreach ($entry in $AdditionalEntries) { $lines.Add("- ``$entry`` - focused evidence fixture.") | Out-Null }
    Write-FixtureText -Path (Join-Path $ChangeRoot 'attachments\INDEX.md') -Text (($lines -join "`n") + "`n")
}

function Update-FixtureEvaluation {
    param($Context, [string]$ChangeRoot, [string]$ClosureKind = 'completed', [string]$CapturedAt = '2026-09-04T13:15:00+08:00')
    $orientation = Invoke-Harness -Command harness.evolution.status -Context $Context -Parameters @{ Change = 'fixture/evolution-closure' }
    Assert-Equal 'Succeeded' $orientation.status 'ordinary status remains inspectable while evidence is invalid'
    Assert-Match $orientation.data.CurrentInputSha256 '^[a-f0-9]{64}$' 'ordinary status returns a current digest while evidence is invalid'
    Write-FixtureEvaluation -ChangeRoot $ChangeRoot -InputSha256 $orientation.data.CurrentInputSha256 -ClosureKind $ClosureKind -CapturedAt $CapturedAt
}

function Write-FixtureIssue {
    param(
        [string]$Path,
        [string]$Schema = 'openspec-material-issue-v2',
        [string]$AffectedTask = '1.1',
        [string]$CreatedAt = '2026-09-04T13:00:00+08:00',
        [string]$ResolvedAt = '2026-09-04T13:10:00+08:00',
        [string]$Status = 'resolved',
        [string]$SourceRef = 'run:fixture-red',
        [string]$SupersededBy = '',
        [switch]$IncompleteBody
    )
    $schemaLine = if ([string]::IsNullOrWhiteSpace($Schema)) { '' } else { "issue_schema: $Schema`n" }
    $terminalLine = if ($Status -eq 'superseded') { "superseded_by: $SupersededBy" } elseif ($Status -eq 'open') { '' } else { 'resolution_ref: run:fixture-green' }
    $body = if ($IncompleteBody) {
        "# Fixture Issue`n`n## Symptom`n`nOnly one section exists.`n"
    }
    else {
        @'
# Fixture Issue

## Symptom

The fixture exposes one terminal-policy branch.

## Investigation Log

The focused route was exercised against controlled input.

## Root Cause

The selected metadata shape is intentionally under test.

## Disposition

The fixture supplies exact terminal metadata.

## Evidence

### Failure Evidence (RED)

- Command: `focused fixture`
- Run ID: fixture-red

### Resolution Evidence (GREEN)

- Command: `focused fixture`
- Run ID: fixture-green

### What This Proves

The real route observes the fixture.

### What This Does Not Prove

No unrelated Harness route is exercised.

## Links

- `tasks.md`
'@
    }
    Write-FixtureText -Path $Path -Text @"
---
$($schemaLine)issue_id: $([System.IO.Path]::GetFileNameWithoutExtension($Path))
status: $Status
source: verification
source_ref: $SourceRef
affected_tasks: ["$AffectedTask"]
created_at: $CreatedAt
resolved_at: $ResolvedAt
$terminalLine
---

$body
"@
}

function Write-FixtureReview {
    param(
        [string]$Path,
        [string]$Schema = 'review-v2',
        [string]$State = 'closed',
        [string]$Verdict = 'APPROVE',
        [string]$FindingSeverity = '',
        [string]$FindingStatus = ''
    )
    $finding = if ([string]::IsNullOrWhiteSpace($FindingSeverity)) {
        'No finding.'
    }
    else {
        "### Finding 1`n`nseverity: $FindingSeverity`nstatus: $FindingStatus`n"
    }
    $schemaLine = if ([string]::IsNullOrWhiteSpace($Schema)) { '' } else { "review_schema: $Schema`n" }
    $closedAt = if ($State -eq 'open') { '' } else { "closed_at: 2026-09-04T13:12:00+08:00`n" }
    Write-FixtureText -Path $Path -Text @"
---
$($schemaLine)review_kind: external
requested_by: user
state: $State
assigned_at: 2026-09-04T13:10:00+08:00
reviewed_at: 2026-09-04T13:11:00+08:00
$($closedAt)snapshot_ref: commit:0123456789abcdef
snapshot_sha256: $('a' * 64)
verdict: $Verdict
---

# Fixture Review

## Findings

$finding
"@
}

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$manifest = Join-Path $repoRoot '.agents\skills\harness\scripts\Harness.psd1'
$openSpec = Join-Path $repoRoot '.agents\skills\openspec\bin\openspec.exe'
Assert-True (Test-Path -LiteralPath $manifest -PathType Leaf) 'Harness manifest is required.'
Assert-True (Test-Path -LiteralPath $openSpec -PathType Leaf) 'Packaged OpenSpec executable is required.'

$temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ('harness-evolution-contract-' + [guid]::NewGuid().ToString('N'))))
Assert-True ($fixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'Fixture must remain below the system temporary directory.'
Assert-True ([System.IO.Path]::GetFileName($fixtureRoot).StartsWith('harness-evolution-contract-', [System.StringComparison]::Ordinal)) 'Fixture basename must retain its safety prefix.'

try {
    [void][System.IO.Directory]::CreateDirectory($fixtureRoot)
    Invoke-FixtureOpenSpec -Executable $openSpec -WorkingDirectory $fixtureRoot -Arguments @(
        'init', $fixtureRoot,
        '--project-id', 'harness-evolution-contract',
        '--title', 'Harness Evolution Contract',
        '--workflow', 'spec-driven',
        '--language', 'en'
    )
    Invoke-FixtureOpenSpec -Executable $openSpec -WorkingDirectory $fixtureRoot -Arguments @('domain', 'create', 'fixture', '--title', 'Fixture', '--description', 'Fixture domain.', '--json')
    Invoke-FixtureOpenSpec -Executable $openSpec -WorkingDirectory $fixtureRoot -Arguments @('change', 'create', 'fixture/evolution-closure', '--title', 'Evolution closure fixture', '--goal', 'Exercise the terminal closure contract.', '--json')

    $changeRoot = Join-Path $fixtureRoot 'openspec\changes\fixture\evolution-closure'
    Write-FixtureText -Path (Join-Path $changeRoot 'proposal.md') -Text "# Proposal`n`nThis focused fixture has enough stable content to exercise terminal closure validation without unrelated integration tests.`n"
    Write-FixtureTasks -ChangeRoot $changeRoot -Complete $false
    Write-FixtureIndex -ChangeRoot $changeRoot
    Write-FixtureEvaluation -ChangeRoot $changeRoot -InputSha256 ('0' * 64)

    Import-Module $manifest -Force
    $context = [pscustomobject][ordered]@{
        HarnessRoot = $repoRoot
        WorkspaceRoot = $fixtureRoot
        PrimaryRoot = $fixtureRoot
        GitCommonDir = $fixtureRoot
        Topology = 'Primary'
        Branch = 'main'
        Head = 'fixture'
    }

    $incomplete = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $incomplete.status 'completed closure rejects an incomplete TaskPlan'
    Assert-Match $incomplete.error.message 'incomplete task|TaskPlan' 'incomplete closure identifies TaskPlan state'

    Write-FixtureTasks -ChangeRoot $changeRoot -Complete $true
    $orientation = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure' }
    Assert-Equal 'Succeeded' $orientation.status 'ordinary exact status exposes current digest input'
    Assert-Match $orientation.data.CurrentInputSha256 '^[a-f0-9]{64}$' 'current input digest is lowercase SHA-256'
    Write-FixtureEvaluation -ChangeRoot $changeRoot -InputSha256 $orientation.data.CurrentInputSha256

    $complete = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; ClosureKind = 'completed'; RequireTerminal = $true }
    $completeError = if ($null -eq $complete.error) { '' } else { [string]$complete.error.message }
    Assert-Equal 'Succeeded' $complete.status "fresh completed fixture passes terminal closure: $completeError"
    Assert-True $complete.data.ClosureReady 'fresh completed fixture is closure-ready'
    Assert-Equal 'completed' $complete.data.ClosureKind 'result reports the evaluated closure kind'
    Assert-True $complete.data.EvaluationFresh 'result reports evaluation freshness'

    Write-FixtureEvaluation -ChangeRoot $changeRoot -InputSha256 $orientation.data.CurrentInputSha256.ToUpperInvariant()
    $uppercaseDigest = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $uppercaseDigest.status 'workflow evaluation digest must retain canonical lowercase spelling'
    Assert-Match $uppercaseDigest.error.message 'lowercase SHA-256' 'uppercase evaluation digest has an exact diagnostic'
    Write-FixtureEvaluation -ChangeRoot $changeRoot -InputSha256 $orientation.data.CurrentInputSha256

    Write-FixtureText -Path (Join-Path $changeRoot 'proposal.md') -Text "# Proposal`n`nA later semantic input mutation must invalidate the previously captured evaluation digest.`n"
    $stale = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; ClosureKind = 'completed'; RequireTerminal = $true }
    Assert-Equal 'Failed' $stale.status 'input mutation invalidates the workflow evaluation'
    Assert-Match $stale.error.message 'stale|input_sha256|digest' 'stale evaluation has a bounded diagnostic'

    $refreshed = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure' }
    Write-FixtureEvaluation -ChangeRoot $changeRoot -InputSha256 $refreshed.data.CurrentInputSha256
    $kindMismatch = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; ClosureKind = 'abandoned'; RequireTerminal = $true }
    Assert-Equal 'Failed' $kindMismatch.status 'evaluation closure kind must match the requested closure kind'
    Assert-Match $kindMismatch.error.message 'closure_kind' 'closure kind mismatch has a bounded diagnostic'

    $issueRelative = 'implementation/nested/issue-20260904-130000-fixture.md'
    $issuePath = Join-Path $changeRoot ('attachments\' + $issueRelative.Replace('/', '\'))
    Write-FixtureIssue -Path $issuePath -Schema ''
    Write-FixtureIndex -ChangeRoot $changeRoot -AdditionalEntries @($issueRelative)
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $legacyActiveIssue = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $legacyActiveIssue.status 'active nested schema-less issue cannot receive archive compatibility'
    Assert-Match $legacyActiveIssue.error.message 'issue_schema|v2' 'active legacy issue has an exact schema diagnostic'

    Write-FixtureIssue -Path $issuePath -AffectedTask '9.9'
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $unknownIssueTask = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $unknownIssueTask.status 'material issue task IDs must exist in the active TaskPlan'
    Assert-Match $unknownIssueTask.error.message '9\.9|affected_tasks' 'unknown issue task has an exact diagnostic'

    Write-FixtureIssue -Path $issuePath -CreatedAt '2026-09-04T13:10:00+08:00' -ResolvedAt '2026-09-04T13:00:00+08:00'
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $reversedIssueTime = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $reversedIssueTime.status 'issue resolution cannot precede creation'
    Assert-Match $reversedIssueTime.error.message 'resolved_at.*created_at|timestamp order' 'reversed issue timestamps have an exact diagnostic'

    Write-FixtureIssue -Path $issuePath -IncompleteBody
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $incompleteIssueBody = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $incompleteIssueBody.status 'active material issue requires its evidence body'
    Assert-Match $incompleteIssueBody.error.message 'section|Evidence|Root Cause' 'incomplete issue body has an exact diagnostic'

    Write-FixtureIssue -Path $issuePath
    $reviewRelative = 'reviews/nested/review-20260904-131000-fixture-agent.md'
    $reviewPath = Join-Path $changeRoot ('attachments\' + $reviewRelative.Replace('/', '\'))
    Write-FixtureReview -Path $reviewPath -Schema '' -State open -Verdict PENDING
    Write-FixtureIndex -ChangeRoot $changeRoot -AdditionalEntries @($issueRelative, $reviewRelative)
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $legacyActiveReview = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $legacyActiveReview.status 'active nested schema-less Review cannot receive archive compatibility'
    Assert-Match $legacyActiveReview.error.message 'review_schema|review-v2' 'active legacy Review has an exact schema diagnostic'

    Write-FixtureReview -Path $reviewPath -State open -Verdict PENDING
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $openReview = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $openReview.status 'an existing open Review blocks closure'
    Assert-Match $openReview.error.message 'open Review|review.*open' 'open Review has an exact diagnostic'

    Write-FixtureReview -Path $reviewPath -FindingSeverity Required -FindingStatus deferred
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $deferredRequired = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $deferredRequired.status 'deferred Required finding blocks closure'
    Assert-Match $deferredRequired.error.message 'Required.*deferred|deferred.*Required' 'blocking Review finding has an exact diagnostic'

    Write-FixtureReview -Path $reviewPath -FindingSeverity Required -FindingStatus resolved
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot -CapturedAt '2026-09-04T13:05:00+08:00'
    $earlyEvaluation = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $earlyEvaluation.status 'workflow evaluation cannot predate terminal evidence'
    Assert-Match $earlyEvaluation.error.message 'captured_at|terminal evidence|fresh' 'early evaluation has an exact diagnostic'

    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $evidenceComplete = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Succeeded' $evidenceComplete.status 'fully terminal issue and Review evidence passes focused closure'

    Invoke-FixtureOpenSpec -Executable $openSpec -WorkingDirectory $fixtureRoot -Arguments @('change', 'create', 'fixture/evolution-successor', '--title', 'Evolution successor fixture', '--goal', 'Own one superseded issue.', '--json')
    $successorRoot = Join-Path $fixtureRoot 'openspec\changes\fixture\evolution-successor'
    Write-FixtureText -Path (Join-Path $successorRoot 'proposal.md') -Text "# Proposal`n`nThis focused successor owns one transferred material issue.`n"
    Write-FixtureTasks -ChangeRoot $successorRoot -Complete $false
    $successorIssueRelative = 'implementation/nested/issue-20260904-132000-successor.md'
    $successorIssuePath = Join-Path $successorRoot ('attachments\' + $successorIssueRelative.Replace('/', '\'))
    Write-FixtureIssue -Path $successorIssuePath -Status open -ResolvedAt '' -SourceRef 'run:not-reciprocal'
    Write-FixtureIndex -ChangeRoot $successorRoot -AdditionalEntries @($successorIssueRelative)

    Write-FixtureIssue -Path $issuePath -Status superseded -SupersededBy 'fixture/evolution-successor#issue-20260904-132000-successor'
    Update-FixtureEvaluation -Context $context -ChangeRoot $changeRoot
    $nonReciprocalSuccessor = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $nonReciprocalSuccessor.status 'superseded issue requires reciprocal successor ownership'
    Assert-Match $nonReciprocalSuccessor.error.message 'source_ref|reciprocal' 'non-reciprocal successor has an exact diagnostic'

    Write-FixtureIssue -Path $successorIssuePath -Status open -ResolvedAt '' -SourceRef 'issue:fixture/evolution-closure#issue-20260904-130000-fixture'
    $validSuccessor = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Succeeded' $validSuccessor.status 'active indexed reciprocal successor satisfies supersession ownership'

    $archiveRoot = Join-Path $fixtureRoot 'openspec\archive\changes\fixture\2026-09-04-evolution-closure'
    [void][System.IO.Directory]::CreateDirectory((Split-Path -Parent $archiveRoot))
    [System.IO.Directory]::Move($changeRoot, $archiveRoot)
    $archivedStatus = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure' }
    Assert-Equal 'Succeeded' $archivedStatus.status 'ordinary archived evolution status remains readable'
    Assert-True $archivedStatus.data.Archived 'ordinary status identifies immutable history'
    $archivedTerminal = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'fixture/evolution-closure'; RequireTerminal = $true }
    Assert-Equal 'Failed' $archivedTerminal.status 'terminal policy rejects an archived Change'
    Assert-Match $archivedTerminal.error.message 'active Change|archived validation' 'archived terminal request names the historical audit boundary'

    'HarnessEvolution.Tests.ps1: PASS'
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot) {
        $resolvedFixture = [System.IO.Path]::GetFullPath($fixtureRoot)
        if (-not $resolvedFixture.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not [System.IO.Path]::GetFileName($resolvedFixture).StartsWith('harness-evolution-contract-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to clean unexpected fixture path: $resolvedFixture"
        }
        Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
    }
}
