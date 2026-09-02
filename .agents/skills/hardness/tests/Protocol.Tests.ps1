[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}

function Assert-Contains {
    param([string]$Text, [string]$Pattern, [string]$Message)
    Assert-True ($Text -match $Pattern) $Message
}

function ConvertFrom-ReviewScalar {
    param([string]$Value)

    if ($null -eq $Value) { return '' }
    $normalized = $Value.Trim()
    if ($normalized.Length -ge 2) {
        $first = $normalized.Substring(0, 1)
        $last = $normalized.Substring($normalized.Length - 1, 1)
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            $normalized = $normalized.Substring(1, $normalized.Length - 2).Trim()
        }
    }
    return $normalized
}

function Get-ReviewMetadataValue {
    param(
        [string]$Text,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        $match = [regex]::Match(
            $Text,
            ('(?im)^[ \t]*{0}[ \t]*:[ \t]*(?<value>[^\r\n#]+)' -f [regex]::Escape($name))
        )
        if ($match.Success) {
            return ConvertFrom-ReviewScalar $match.Groups['value'].Value
        }
    }
    return ''
}

function Get-ReviewFrontmatter {
    param([string]$Text)

    $match = [regex]::Match(
        $Text,
        '(?s)\A(?:\uFEFF)?---[ \t]*\r?\n(?<frontmatter>.*?)\r?\n---[ \t]*(?:\r?\n|\z)'
    )
    if (-not $match.Success) { return '' }
    return $match.Groups['frontmatter'].Value
}

function Get-ReviewFindingSections {
    param([string]$Text)

    $headingPattern = '(?im)^[ \t]*#{2,6}[ \t]+Finding(?:[ \t]+[0-9]+)?(?:\b|[ \t]+|-).*$'
    $headings = [regex]::Matches($Text, $headingPattern)
    $sections = @()
    for ($index = 0; $index -lt $headings.Count; $index++) {
        $heading = $headings[$index]
        $end = if (($index + 1) -lt $headings.Count) { $headings[$index + 1].Index } else { $Text.Length }
        $bodyStart = $heading.Index + $heading.Length
        $sections += [pscustomobject]@{
            Heading = $heading.Value.Trim()
            Body = $Text.Substring($bodyStart, $end - $bodyStart)
        }
    }
    return $sections
}

function Get-ReviewFindingMetadata {
    param([string]$Body)

    # Current reviews use a fenced YAML block. Historical reviews used the same
    # fields in an indented YAML block immediately below the Finding heading.
    $windowLength = [Math]::Min($Body.Length, 4096)
    $metadataWindow = $Body.Substring(0, $windowLength)
    $fenced = [regex]::Match(
        $metadataWindow,
        '(?ims)^[ \t]*```ya?ml[ \t]*\r?\n(?<metadata>.*?)^[ \t]*```[ \t]*(?:\r?\n|\z)'
    )
    if ($fenced.Success) {
        $metadata = $fenced.Groups['metadata'].Value
    }
    else {
        $severity = [regex]::Match($metadataWindow, '(?im)^[ \t]{2,}severity[ \t]*:')
        if (-not $severity.Success -or $severity.Index -gt 1024) {
            return $null
        }
        $metadata = $metadataWindow.Substring($severity.Index)
    }

    return [pscustomobject]@{
        Severity = (Get-ReviewMetadataValue -Text $metadata -Names @('severity')).ToLowerInvariant()
        Status = (Get-ReviewMetadataValue -Text $metadata -Names @('status', 'state')).ToLowerInvariant()
        FollowUp = Get-ReviewMetadataValue -Text $metadata -Names @('follow_up', 'follow-up')
    }
}

function Test-ConcreteReviewFollowUp {
    param(
        [string]$MetadataFollowUp,
        [string]$FindingBody
    )

    $placeholderPattern = '(?i)^(?:none|n/?a|tbd|todo|unknown|later|future)$'
    if (-not [string]::IsNullOrWhiteSpace($MetadataFollowUp) -and $MetadataFollowUp.Trim() -notmatch $placeholderPattern) {
        return $true
    }

    $label = [regex]::Match($FindingBody, '(?im)^[ \t]*(?:suggested[ -]+follow-up|follow-up)[ \t]*:[ \t]*(?<inline>[^\r\n]*)')
    if (-not $label.Success) { return $false }
    $inline = $label.Groups['inline'].Value.Trim()
    if ($inline.Length -ge 8 -and $inline -notmatch $placeholderPattern) { return $true }

    $tailStart = $label.Index + $label.Length
    $tailLength = [Math]::Min(1024, $FindingBody.Length - $tailStart)
    $tail = $FindingBody.Substring($tailStart, $tailLength)
    foreach ($line in ($tail -split '\r?\n')) {
        $candidate = ($line -replace '^[ \t]*[-*][ \t]*', '').Trim()
        if ($candidate.StartsWith('#')) { break }
        if ($candidate.Length -ge 8 -and $candidate -notmatch $placeholderPattern) { return $true }
    }
    return $false
}

function Test-ReviewClosureGate {
    param([string]$ReviewRoot)

    $issues = @()
    $reviewFiles = @(Get-ChildItem -LiteralPath $ReviewRoot -File -Filter 'review-*.md')
    if ($reviewFiles.Count -eq 0) {
        return 'no-review-files: review closure gate requires at least one review record'
    }

    foreach ($file in $reviewFiles) {
        $record = Get-Content -LiteralPath $file.FullName -Raw
        $frontmatter = Get-ReviewFrontmatter $record
        $reviewState = (Get-ReviewMetadataValue -Text $frontmatter -Names @('state')).ToLowerInvariant()
        if ($reviewState -notin @('closed', 'superseded')) {
            $issues += "review-state: $($file.Name) must be closed or superseded (actual '$reviewState')"
        }

        foreach ($finding in @(Get-ReviewFindingSections $record)) {
            $metadata = Get-ReviewFindingMetadata $finding.Body
            if ($null -eq $metadata -or [string]::IsNullOrWhiteSpace($metadata.Severity) -or [string]::IsNullOrWhiteSpace($metadata.Status)) {
                $issues += "finding-metadata: $($file.Name) $($finding.Heading) lacks readable severity and status/state metadata"
                continue
            }

            if ($metadata.Severity -in @('critical', 'required') -and $metadata.Status -in @('open', 'deferred')) {
                $issues += "blocking-finding: $($file.Name) $($finding.Heading) is $($metadata.Severity)/$($metadata.Status)"
            }
            if ($metadata.Severity -eq 'advisory' -and $metadata.Status -eq 'deferred' -and
                -not (Test-ConcreteReviewFollowUp -MetadataFollowUp $metadata.FollowUp -FindingBody $finding.Body)) {
                $issues += "advisory-follow-up: $($file.Name) $($finding.Heading) is deferred without a concrete follow-up"
            }
        }
    }

    return $issues
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$referenceRoot = Join-Path $projectRoot '.agents\skills\hardness\references'
$changeRoot = Join-Path $projectRoot 'openspec\archive\changes\hardness\2026-09-03-refactor-skill-system'
$exePath = Join-Path $projectRoot '.agents\skills\openspec\bin\openspec.exe'

Assert-True (Test-Path -LiteralPath $changeRoot -PathType Container) 'The archived Hardness dogfood record is required for protocol audit'

$taskProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'task-dag.md') -Raw
$replanProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'replan.md') -Raw
$reviewProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'review.md') -Raw
$closureProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'closure.md') -Raw

Assert-Contains $taskProtocol 'only current Task DAG' 'tasks.md remains the only current DAG'
foreach ($token in @(
    'stable `X.Y` ID',
    '`task_graph.version`',
    '`depends_on`',
    'quote every task and dependency ID',
    'order never creates an edge',
    '`after` and `ready`',
    '`Files`',
    'never unchecked',
    'Historical body-level `After` records remain readable'
)) {
    Assert-True ($taskProtocol.Contains($token)) "Task DAG protocol is missing: $token"
}
Assert-Contains $replanProtocol 'status: applied' 'Replan records are applied-only'
foreach ($token in @('base_commit:', 'base_tasks_sha256:', 'result_tasks_sha256:', 'resume_task:', 'Old Task Disposition', 'Diff Snapshot', 'Preserved Work', 'attachments/talks/')) {
    Assert-True ($replanProtocol.Contains($token)) "Replan protocol is missing: $token"
}
Assert-Contains $reviewProtocol 'finding never directly triggers Replan' 'Review findings require triage before Replan'
Assert-Contains $reviewProtocol 'open \| resolved \| rejected \| deferred' 'Review finding states are explicit'
Assert-Contains $reviewProtocol 'Critical and Required findings' 'Critical and Required findings gate closure'
foreach ($kind in @('`completed`', '`abandoned`', '`superseded`')) {
    Assert-True ($closureProtocol.Contains($kind)) "Closure protocol is missing $kind"
}
Assert-Contains $closureProtocol 'does not merge specs, merge Git branches, push, remove a worktree' 'Archive is separate from integration and removal'

$reviewFixtureRoot = [System.IO.Path]::Combine(
    [System.IO.Path]::GetTempPath(),
    ('hardness-review-protocol-{0}' -f [guid]::NewGuid().ToString('N'))
)
try {
    [void](New-Item -ItemType Directory -Path $reviewFixtureRoot)
    $validReview = @'
---
state: closed
---

# Valid review

## Finding 1 - Historical metadata remains readable

    severity: Required
    status: resolved

## Finding 2 - Deferred advice has an owner

```yaml
severity: Advisory
status: deferred
follow_up: optimize-review-parser
```
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-valid.md'),
        $validReview,
        [System.Text.UTF8Encoding]::new($false)
    )
    Assert-Equal 0 @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot).Count 'valid mixed-format review fixture passes closure gate'

    $invalidReview = @'
---
state: open
---

# Invalid review

## Finding 1 - A blocker remains open

```yaml
severity: Required
status: open
```

## Finding 2 - Deferred advice lacks a concrete owner

    severity: Advisory
    status: deferred
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-invalid.md'),
        $invalidReview,
        [System.Text.UTF8Encoding]::new($false)
    )
    $negativeIssues = @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot)
    Assert-True (@($negativeIssues | Where-Object { $_ -like 'review-state:*review-invalid.md*' }).Count -eq 1) 'open review fixture is rejected'
    Assert-True (@($negativeIssues | Where-Object { $_ -like 'blocking-finding:*review-invalid.md*Finding 1*' }).Count -eq 1) 'open Required fixture is rejected'
    Assert-True (@($negativeIssues | Where-Object { $_ -like 'advisory-follow-up:*review-invalid.md*Finding 2*' }).Count -eq 1) 'deferred Advisory without a concrete follow-up is rejected'
}
finally {
    if (Test-Path -LiteralPath $reviewFixtureRoot) {
        Remove-Item -LiteralPath $reviewFixtureRoot -Recurse -Force
    }
}

$reviewIssues = @(Test-ReviewClosureGate -ReviewRoot (Join-Path $changeRoot 'attachments\reviews'))
Assert-Equal 0 $reviewIssues.Count ("Review closure gate failed:`n{0}" -f ($reviewIssues -join [Environment]::NewLine))

$replanFiles = @(Get-ChildItem -LiteralPath (Join-Path $changeRoot 'attachments\replans') -File -Filter 'replan-*.md')
Assert-True ($replanFiles.Count -ge 1) 'The dogfood change keeps at least one applied Replan record'
foreach ($file in $replanFiles) {
    $record = Get-Content -LiteralPath $file.FullName -Raw
    Assert-Contains $record '(?m)^status: applied$' "$($file.Name) is not applied-only"
    Assert-Contains $record '(?m)^base_tasks_sha256: [0-9a-f]{64}$' "$($file.Name) lacks the base Task DAG digest"
    Assert-Contains $record '(?m)^result_tasks_sha256: [0-9a-f]{64}$' "$($file.Name) lacks the result Task DAG digest"
    foreach ($section in @('## Old Task Disposition', '## Diff Snapshot', '## Preserved Work')) {
        Assert-True ($record.Contains($section)) "$($file.Name) lacks $section"
    }
}
Assert-Equal 0 @(Get-ChildItem -LiteralPath (Join-Path $changeRoot 'attachments\replans') -Directory).Count 'Replan records stay flat'

Assert-True (Test-Path -LiteralPath $exePath -PathType Leaf) 'Packaged OpenSpec is required for Task DAG fixtures'
$temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ("hardness-protocol-{0}" -f [guid]::NewGuid().ToString('N'))))
Assert-True ($fixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'Protocol fixture escaped the system temp directory'

try {
    [void](New-Item -ItemType Directory -Path $fixtureRoot)
    $init = & $exePath init $fixtureRoot --project-id hardness-protocol-fixture --title 'Hardness Protocol Fixture' --workflow spec-driven --language en 2>&1
    Assert-Equal 0 $LASTEXITCODE "Fixture init failed: $($init -join [Environment]::NewLine)"
    Push-Location $fixtureRoot
    try {
        $domain = & $exePath domain create fixture --title Fixture --description Fixture --json 2>&1
        Assert-Equal 0 $LASTEXITCODE "Fixture domain creation failed: $($domain -join [Environment]::NewLine)"
        $change = & $exePath change create fixture/dag --title 'Task DAG' --goal 'Verify ready and cycle derivation' --json 2>&1
        Assert-Equal 0 $LASTEXITCODE "Fixture change creation failed: $($change -join [Environment]::NewLine)"
        $tasksPath = Join-Path $fixtureRoot 'openspec\changes\fixture\dag\tasks.md'
        $taskSeparator = [string][char]0x2014
        $readyTasks = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
---

## Tasks

- [x] 1.1 Establish the base __TASK_SEPARATOR__ verify: `base`
  > Files: `base`

- [ ] 1.2 Ready work __TASK_SEPARATOR__ verify: `ready`
  > Files: `ready`

- [ ] 1.3 Blocked work __TASK_SEPARATOR__ verify: `blocked`
  > Files: `blocked`
'@
        $readyTasks = $readyTasks.Replace('__TASK_SEPARATOR__', $taskSeparator)
        [System.IO.File]::WriteAllText($tasksPath, $readyTasks, [System.Text.UTF8Encoding]::new($false))
        $readyJson = & $exePath instructions apply --change fixture/dag --json
        Assert-Equal 0 $LASTEXITCODE 'Ready Task DAG instructions failed'
        $readyPlan = ($readyJson -join [Environment]::NewLine) | ConvertFrom-Json
        Assert-True ($readyPlan.PSObject.Properties.Name -contains 'tasks') "Ready Task DAG response lacks tasks: $($readyJson -join [Environment]::NewLine)"
        Assert-True (($readyPlan.tasks | Where-Object id -eq '1.2').ready) '1.2 is derived Ready after 1.1 completes'
        Assert-True (-not ($readyPlan.tasks | Where-Object id -eq '1.3').ready) '1.3 remains blocked by 1.2'
        $readyIssues = if ($readyPlan.PSObject.Properties.Name -contains 'taskIssues') { @($readyPlan.taskIssues) } else { @() }
        Assert-Equal 0 (@($readyIssues).Count) 'valid Task DAG has no issues'

        $cycleTasks = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": ["1.2"]
    "1.2": ["1.1"]
---

## Tasks

- [ ] 1.1 First __TASK_SEPARATOR__ verify: `one`
  > Files: `one`

- [ ] 1.2 Second __TASK_SEPARATOR__ verify: `two`
  > Files: `two`
'@
        $cycleTasks = $cycleTasks.Replace('__TASK_SEPARATOR__', $taskSeparator)
        [System.IO.File]::WriteAllText($tasksPath, $cycleTasks, [System.Text.UTF8Encoding]::new($false))
        $cycleJson = & $exePath instructions apply --change fixture/dag --json
        Assert-Equal 0 $LASTEXITCODE 'Cycle instructions should return structured task issues'
        $cyclePlan = ($cycleJson -join [Environment]::NewLine) | ConvertFrom-Json
        Assert-True ($cyclePlan.PSObject.Properties.Name -contains 'tasks') "Cycle Task DAG response lacks tasks: $($cycleJson -join [Environment]::NewLine)"
        Assert-True ('cycle' -in @($cyclePlan.taskIssues.code)) 'cycle is reported as a structured Task DAG issue'
        Assert-Equal 0 (@($cyclePlan.tasks | Where-Object ready).Count) 'cycle never produces Ready work'
    }
    finally {
        Pop-Location
    }
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot) {
        Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
    }
}

Write-Output 'Protocol.Tests.ps1: PASS'
