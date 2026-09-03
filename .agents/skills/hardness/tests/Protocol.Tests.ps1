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

function Test-ReviewIso8601Timestamp {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    return $Value -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$'
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

        $reviewSchema = (Get-ReviewMetadataValue -Text $frontmatter -Names @('review_schema')).ToLowerInvariant()
        if (-not [string]::IsNullOrWhiteSpace($reviewSchema) -and $reviewSchema -ne 'review-v2') {
            $issues += "review-schema: $($file.Name) has unsupported schema '$reviewSchema'"
        }
        if ($reviewSchema -eq 'review-v2') {
            $reviewKind = (Get-ReviewMetadataValue -Text $frontmatter -Names @('review_kind')).ToLowerInvariant()
            $requestedBy = (Get-ReviewMetadataValue -Text $frontmatter -Names @('requested_by')).ToLowerInvariant()
            $assignedAt = Get-ReviewMetadataValue -Text $frontmatter -Names @('assigned_at')
            $reviewedAt = Get-ReviewMetadataValue -Text $frontmatter -Names @('reviewed_at')
            $closedAt = Get-ReviewMetadataValue -Text $frontmatter -Names @('closed_at')
            $snapshotRef = Get-ReviewMetadataValue -Text $frontmatter -Names @('snapshot_ref')
            $snapshotSha256 = Get-ReviewMetadataValue -Text $frontmatter -Names @('snapshot_sha256')
            $verdict = (Get-ReviewMetadataValue -Text $frontmatter -Names @('verdict')).ToUpperInvariant()

            if ($reviewKind -notin @('incident', 'final', 'external')) {
                $issues += "review-kind: $($file.Name) has invalid review_kind '$reviewKind'"
            }
            if ($requestedBy -notin @('hardness', 'user', 'external-agent')) {
                $issues += "review-requester: $($file.Name) has invalid requested_by '$requestedBy'"
            }
            if (-not (Test-ReviewIso8601Timestamp $assignedAt)) {
                $issues += "review-assigned-at: $($file.Name) requires an actual ISO-8601 assigned_at"
            }
            if ($reviewState -eq 'closed' -and -not (Test-ReviewIso8601Timestamp $reviewedAt)) {
                $issues += "review-reviewed-at: $($file.Name) closed review requires an actual ISO-8601 reviewed_at"
            }
            if ($reviewState -in @('closed', 'superseded') -and -not (Test-ReviewIso8601Timestamp $closedAt)) {
                $issues += "review-closed-at: $($file.Name) closed/superseded review requires an actual ISO-8601 closed_at"
            }
            if ([string]::IsNullOrWhiteSpace($snapshotRef) -or $snapshotRef -match '(?i)^(?:live|current|dirty|working[-_ ]?tree|live[-_ ]?worktree)$') {
                $issues += "review-snapshot-ref: $($file.Name) requires an immutable snapshot_ref"
            }
            if ($snapshotSha256 -notmatch '^[0-9a-f]{64}$') {
                $issues += "review-snapshot-sha256: $($file.Name) requires a lowercase SHA-256"
            }
            if ($reviewState -eq 'closed' -and $verdict -ne 'APPROVE') {
                $issues += "review-verdict: $($file.Name) closed review requires APPROVE (actual '$verdict')"
            }
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

function Get-MarkdownSectionBody {
    param(
        [string]$Text,
        [string]$Heading
    )

    $pattern = '(?ims)^[ \t]*#{2,6}[ \t]+' + [regex]::Escape($Heading) + '[ \t]*\r?\n(?<body>.*?)(?=^[ \t]*#{2,6}[ \t]+|\z)'
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) { return $null }
    return $match.Groups['body'].Value.Trim()
}

function Get-FrontmatterCollectionValues {
    param(
        [string]$Frontmatter,
        [string]$Name
    )

    $match = [regex]::Match(
        $Frontmatter,
        ('(?im)^[ \t]*{0}[ \t]*:[ \t]*(?<value>[^\r\n#]*)' -f [regex]::Escape($Name))
    )
    if (-not $match.Success) { return @() }
    $values = New-Object System.Collections.Generic.List[string]
    $inline = $match.Groups['value'].Value.Trim()
    if (-not [string]::IsNullOrWhiteSpace($inline)) {
        $inlineMatch = [regex]::Match($inline, '^\[(?<items>.*)\]$')
        if (-not $inlineMatch.Success) { return @() }
        foreach ($item in ($inlineMatch.Groups['items'].Value -split ',')) {
            $value = (ConvertFrom-ReviewScalar $item).Trim()
            if (-not [string]::IsNullOrWhiteSpace($value)) { $values.Add($value) | Out-Null }
        }
        return @($values)
    }

    $tail = $Frontmatter.Substring($match.Index + $match.Length)
    foreach ($line in ($tail -split '\r?\n')) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $itemMatch = [regex]::Match($line, '^[ \t]+-[ \t]+(?<value>\S[^\r\n]*)$')
        if (-not $itemMatch.Success) { break }
        $value = (ConvertFrom-ReviewScalar $itemMatch.Groups['value'].Value).Trim()
        if (-not [string]::IsNullOrWhiteSpace($value)) { $values.Add($value) | Out-Null }
    }
    return @($values)
}

function Test-IsoTimestamp {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -cnotmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$') { return $false }
    $parsed = [DateTimeOffset]::MinValue
    return [DateTimeOffset]::TryParse(
        $Value,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::RoundtripKind,
        [ref]$parsed)
}

function Test-ImplementationIssueFile {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    $issues = @()
    if ($File.Name -cnotmatch '^issue-\d{8}-\d{6}-[a-z0-9][a-z0-9-]*\.md$') {
        $issues += "issue-filename: $($File.Name) is not a canonical material issue filename"
    }

    $record = Get-Content -LiteralPath $File.FullName -Raw
    $frontmatter = Get-ReviewFrontmatter $record
    if ([string]::IsNullOrWhiteSpace($frontmatter)) {
        $issues += "issue-frontmatter: $($File.Name) has no readable frontmatter"
    }

    $issueId = Get-ReviewMetadataValue -Text $frontmatter -Names @('issue_id')
    $status = (Get-ReviewMetadataValue -Text $frontmatter -Names @('status')).ToLowerInvariant()
    $source = (Get-ReviewMetadataValue -Text $frontmatter -Names @('source')).ToLowerInvariant()
    $sourceRef = Get-ReviewMetadataValue -Text $frontmatter -Names @('source_ref')
    $createdAt = Get-ReviewMetadataValue -Text $frontmatter -Names @('created_at')

    if ($issueId -ne $File.BaseName) { $issues += "issue-id: $($File.Name) issue_id must match its filename stem" }
    if ($status -notin @('open', 'resolved', 'superseded')) { $issues += "issue-status: $($File.Name) has invalid status '$status'" }
    if ($source -notin @('implementation', 'verification', 'review', 'dependency', 'user')) { $issues += "issue-source: $($File.Name) has invalid source '$source'" }
    if ([string]::IsNullOrWhiteSpace($sourceRef)) { $issues += "issue-source-ref: $($File.Name) requires source_ref" }
    $affectedTasks = @(Get-FrontmatterCollectionValues -Frontmatter $frontmatter -Name 'affected_tasks')
    if ($affectedTasks.Count -eq 0) { $issues += "issue-affected-tasks: $($File.Name) requires at least one affected task" }
    foreach ($taskId in $affectedTasks) {
        if ($taskId -cnotmatch '^\d+\.\d+$') { $issues += "issue-affected-task-id: $($File.Name) has invalid task ID '$taskId'" }
    }
    if (-not (Test-IsoTimestamp -Value $createdAt)) { $issues += "issue-created-at: $($File.Name) requires an ISO-8601 created_at" }

    $resolvedAt = Get-ReviewMetadataValue -Text $frontmatter -Names @('resolved_at')
    $resolutionRef = Get-ReviewMetadataValue -Text $frontmatter -Names @('resolution_ref')
    $supersededBy = Get-ReviewMetadataValue -Text $frontmatter -Names @('superseded_by')
    if ($status -eq 'resolved') {
        if (-not (Test-IsoTimestamp -Value $resolvedAt)) { $issues += "issue-resolved-at: $($File.Name) requires an ISO-8601 resolved_at" }
        if ([string]::IsNullOrWhiteSpace($resolutionRef)) { $issues += "issue-resolution-ref: $($File.Name) requires resolution_ref" }
        if (-not [string]::IsNullOrWhiteSpace($supersededBy)) { $issues += "issue-status-fields: $($File.Name) resolved status forbids superseded_by" }
    }
    elseif ($status -eq 'superseded') {
        if ([string]::IsNullOrWhiteSpace($supersededBy)) { $issues += "issue-superseded-by: $($File.Name) requires superseded_by" }
        if (-not [string]::IsNullOrWhiteSpace($resolvedAt) -or -not [string]::IsNullOrWhiteSpace($resolutionRef)) { $issues += "issue-status-fields: $($File.Name) superseded status forbids resolution fields" }
    }
    elseif ($status -eq 'open') {
        if (-not [string]::IsNullOrWhiteSpace($resolvedAt) -or -not [string]::IsNullOrWhiteSpace($resolutionRef) -or -not [string]::IsNullOrWhiteSpace($supersededBy)) { $issues += "issue-status-fields: $($File.Name) open status forbids closure fields" }
    }

    foreach ($heading in @('Symptom', 'Investigation Log', 'Root Cause', 'Disposition', 'Links')) {
        $topLevelPattern = '(?ims)^[ \t]*##[ \t]+' + [regex]::Escape($heading) + '[ \t]*\r?\n(?<body>.*?)(?=^[ \t]*##[ \t]+|\z)'
        $topLevelMatch = [regex]::Match($record, $topLevelPattern)
        if (-not $topLevelMatch.Success -or [string]::IsNullOrWhiteSpace($topLevelMatch.Groups['body'].Value)) { $issues += "issue-section: $($File.Name) requires non-empty top-level '$heading'" }
    }
    $evidenceMatch = [regex]::Match($record, '(?ims)^[ \t]*##[ \t]+Evidence[ \t]*\r?\n(?<body>.*?)(?=^[ \t]*##[ \t]+|\z)')
    $evidenceBody = if ($evidenceMatch.Success) { $evidenceMatch.Groups['body'].Value } else { '' }
    if ([string]::IsNullOrWhiteSpace($evidenceBody)) { $issues += "issue-section: $($File.Name) requires the Evidence container" }
    foreach ($heading in @('Failure Evidence (RED)', 'Resolution Evidence (GREEN)', 'What This Proves', 'What This Does Not Prove')) {
        $childPattern = '(?ims)^[ \t]*###[ \t]+' + [regex]::Escape($heading) + '[ \t]*\r?\n(?<body>.*?)(?=^[ \t]*###[ \t]+|\z)'
        $childMatch = [regex]::Match($evidenceBody, $childPattern)
        if (-not $childMatch.Success -or [string]::IsNullOrWhiteSpace($childMatch.Groups['body'].Value)) { $issues += "issue-section: $($File.Name) requires non-empty Evidence child '$heading'" }
    }

    $redBody = Get-MarkdownSectionBody -Text $evidenceBody -Heading 'Failure Evidence (RED)'
    if (-not [string]::IsNullOrWhiteSpace($redBody)) {
        if ($redBody -notmatch '(?im)^[ \t]*[-*]?[ \t]*Command[ \t]*:[ \t]*\S') { $issues += "issue-red-command: $($File.Name) RED requires the exact command" }
        if ($redBody -notmatch '(?im)^[ \t]*[-*]?[ \t]*(?:Run ID|Artifact|Commit|SHA-256|Hash)[ \t]*:[ \t]*\S') { $issues += "issue-red-reference: $($File.Name) RED requires a durable evidence reference" }
    }

    $greenBody = Get-MarkdownSectionBody -Text $evidenceBody -Heading 'Resolution Evidence (GREEN)'
    if ($status -eq 'resolved' -and -not [string]::IsNullOrWhiteSpace($greenBody)) {
        if ($greenBody -notmatch '(?im)^[ \t]*[-*]?[ \t]*Command[ \t]*:[ \t]*\S') { $issues += "issue-green-command: $($File.Name) resolved GREEN requires the exact command" }
        if ($greenBody -notmatch '(?im)^[ \t]*[-*]?[ \t]*(?:Run ID|Artifact|Commit|SHA-256|Hash)[ \t]*:[ \t]*\S') { $issues += "issue-green-reference: $($File.Name) resolved GREEN requires a durable evidence reference" }
    }

    if ($record -match '(?m)^[ \t]*[-*][ \t]+\[[ xX]\]') { $issues += "issue-checkbox: $($File.Name) duplicates task state" }
    return $issues
}

function Test-ActiveImplementationIssueGate {
    param([Parameter(Mandatory = $true)][string]$ActiveChangesRoot)

    $issues = @()
    if (-not (Test-Path -LiteralPath $ActiveChangesRoot -PathType Container)) { return $issues }
    $implementationRoots = @(Get-ChildItem -LiteralPath $ActiveChangesRoot -Recurse -Directory -Filter 'implementation' | Where-Object { $_.Parent.Name -eq 'attachments' })
    foreach ($implementationRoot in $implementationRoots) {
        $attachmentRoot = $implementationRoot.Parent.FullName
        $indexPath = Join-Path $attachmentRoot 'INDEX.md'
        $indexText = if (Test-Path -LiteralPath $indexPath -PathType Leaf) { (Get-Content -LiteralPath $indexPath -Raw).Replace('\', '/') } else { '' }
        if ([string]::IsNullOrWhiteSpace($indexText)) { $issues += "issue-index: $attachmentRoot requires INDEX.md" }
        foreach ($directory in @(Get-ChildItem -LiteralPath $implementationRoot.FullName -Directory)) {
            $issues += "issue-nested-directory: $($directory.FullName) is not allowed"
        }
        foreach ($file in @(Get-ChildItem -LiteralPath $implementationRoot.FullName -File)) {
            $issues += @(Test-ImplementationIssueFile -File $file)
            if (-not [string]::IsNullOrWhiteSpace($indexText)) {
                $relative = $file.FullName.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
                $indexCount = [regex]::Matches($indexText, [regex]::Escape($relative)).Count
                if ($indexCount -ne 1) { $issues += "issue-index-entry: $($file.Name) must appear in INDEX.md exactly once (actual $indexCount)" }
            }
        }
    }
    return $issues
}

function Test-AttachmentIndexCompatibility {
    param([Parameter(Mandatory = $true)][string]$ChangeRoot)

    $issues = @()
    $attachmentRoot = Join-Path $ChangeRoot 'attachments'
    if (-not (Test-Path -LiteralPath $attachmentRoot -PathType Container)) { return $issues }
    $indexPath = Join-Path $attachmentRoot 'INDEX.md'
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
        return "attachment-index-missing: $ChangeRoot"
    }

    $indexLines = @(Get-Content -LiteralPath $indexPath)
    if ($indexLines.Count -gt 120) { $issues += "attachment-index-size: $ChangeRoot has $($indexLines.Count) lines" }
    $indexText = (Get-Content -LiteralPath $indexPath -Raw).Replace('\', '/')
    foreach ($file in @(Get-ChildItem -LiteralPath $attachmentRoot -Recurse -File | Where-Object { $_.FullName -ne $indexPath })) {
        $relative = $file.FullName.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $count = [regex]::Matches($indexText, [regex]::Escape($relative)).Count
        if ($count -ne 1) { $issues += "attachment-index-entry: $ChangeRoot must index '$relative' exactly once (actual $count)" }
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
$implementationProtocol = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\references\implementation-issues.md') -Raw

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
foreach ($token in @(
    'There are exactly three routes',
    '**Incident Review**',
    '**Final Review**',
    '**External Review**',
    'Final Review: not required',
    'Diff size alone does not determine impact',
    'asynchronous subagent',
    '`snapshot_ref`',
    'A digest alone can verify content but is not sufficient to materialize an asynchronous snapshot',
    '`assigned_at` is never reused as a guessed completion time',
    'There is no Review file line limit',
    'one batched incremental Final Review'
)) {
    Assert-True ($reviewProtocol.Contains($token)) "Review protocol is missing: $token"
}
foreach ($kind in @('`completed`', '`abandoned`', '`superseded`')) {
    Assert-True ($closureProtocol.Contains($kind)) "Closure protocol is missing $kind"
}
Assert-Contains $closureProtocol 'does not merge specs, merge Git branches, push, remove a worktree' 'Archive is separate from integration and removal'
foreach ($token in @('Material threshold', 'One root cause', 'Failure Evidence (RED)', 'Resolution Evidence (GREEN)', 'What This Proves', 'What This Does Not Prove', 'Do not record')) {
    Assert-True ($implementationProtocol.Contains($token)) "Implementation issue protocol is missing: $token"
}

$archiveCompatibilityIssues = @()
$archiveRoot = Join-Path $projectRoot 'openspec\archive\changes'
$closureV1Count = 0
foreach ($manifest in @(Get-ChildItem -LiteralPath $archiveRoot -Recurse -File -Filter 'change.yaml')) {
    $manifestText = Get-Content -LiteralPath $manifest.FullName -Raw
    if ($manifestText -match '(?m)^archive_schema:[ \t]*closure-v1[ \t]*\r?$') {
        $closureV1Count++
        $archiveCompatibilityIssues += @(Test-AttachmentIndexCompatibility -ChangeRoot $manifest.DirectoryName)
    }
}
Assert-True ($closureV1Count -ge 1) 'At least one closure-v1 archive is required for attachment compatibility audit'
Assert-Equal 0 $archiveCompatibilityIssues.Count ("Closure-v1 attachment compatibility failed:`n{0}" -f ($archiveCompatibilityIssues -join [Environment]::NewLine))

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

    $validV2Review = @'
---
review_schema: review-v2
review_kind: final
requested_by: hardness
state: closed
assigned_at: 2026-09-03T14:30:00+08:00
reviewed_at: 2026-09-03T14:42:00+08:00
closed_at: 2026-09-03T14:45:00+08:00
snapshot_ref: commit:0123456789abcdef0123456789abcdef01234567
snapshot_sha256: 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
verdict: APPROVE
---

# Valid review-v2 Final Review

No Critical, Required, or Advisory finding.
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-valid-v2.md'),
        $validV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    Assert-Equal 0 @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot).Count 'valid review-v2 fixture passes closure gate'

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

    $invalidV2Review = @'
---
review_schema: review-v2
review_kind: routine
requested_by: nobody
state: closed
assigned_at: 2026-09-03T15:00:00+08:00
snapshot_ref: live-worktree
snapshot_sha256: abc123
verdict: PENDING
---

# Invalid review-v2 metadata
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-invalid-v2.md'),
        $invalidV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    $invalidV2Issues = @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot)
    foreach ($prefix in @('review-kind:', 'review-requester:', 'review-reviewed-at:', 'review-closed-at:', 'review-snapshot-ref:', 'review-snapshot-sha256:', 'review-verdict:')) {
        Assert-True (@($invalidV2Issues | Where-Object { $_ -like "$prefix*review-invalid-v2.md*" }).Count -eq 1) "invalid review-v2 fixture must report $prefix"
    }
}
finally {
    if (Test-Path -LiteralPath $reviewFixtureRoot) {
        Remove-Item -LiteralPath $reviewFixtureRoot -Recurse -Force
    }
}

$issueFixtureRoot = [System.IO.Path]::Combine(
    [System.IO.Path]::GetTempPath(),
    ('hardness-implementation-issue-{0}' -f [guid]::NewGuid().ToString('N'))
)
try {
    $fixtureAttachmentRoot = Join-Path $issueFixtureRoot 'fixture\sample\attachments'
    $fixtureImplementationRoot = Join-Path $fixtureAttachmentRoot 'implementation'
    [void](New-Item -ItemType Directory -Path $fixtureImplementationRoot -Force)
    $validIssueName = 'issue-20260903-143000-shared-root-cause.md'
    $validIssue = @'
---
issue_id: issue-20260903-143000-shared-root-cause
status: resolved
source: review
source_ref: "reviews/review-example.md#finding-1"
affected_tasks:
  - "2.1"
created_at: 2026-09-03T14:30:00+08:00
resolved_at: 2026-09-03T15:20:00+08:00
resolution_ref: commit:0123456789abcdef
---

# Shared Root Cause

## Symptom

Two protocol assertions failed after the same parser boundary changed.

## Investigation Log

The first reproduction isolated both symptoms to one normalization branch.

## Root Cause

The shared branch normalized metadata after validation instead of before it.

## Disposition

Normalize once before validation and retain one regression fixture.

## Evidence

### Failure Evidence (RED)

- Command: `pwsh.exe -NoProfile -File tests/Protocol.Tests.ps1`
- Run ID: protocol-red-001

### Resolution Evidence (GREEN)

- Command: `pwsh.exe -NoProfile -File tests/Protocol.Tests.ps1`
- Commit: 0123456789abcdef

### Rejected Evidence

An unrelated timing run did not exercise the parser boundary.

### What This Proves

The shared normalization branch now satisfies both protocol fixtures.

### What This Does Not Prove

It does not prove unrelated OpenSpec CLI behavior.

## Links

- Task 2.1 and the assigned fixed-snapshot Review.
'@
    $validIssuePath = Join-Path $fixtureImplementationRoot $validIssueName
    [System.IO.File]::WriteAllText($validIssuePath, $validIssue, [System.Text.UTF8Encoding]::new($false))
    $fixtureIndex = "# INDEX`n`n- ``implementation/$validIssueName`` - valid material issue fixture.`n"
    [System.IO.File]::WriteAllText((Join-Path $fixtureAttachmentRoot 'INDEX.md'), $fixtureIndex, [System.Text.UTF8Encoding]::new($false))
    Assert-Equal 0 @(Test-ImplementationIssueFile -File (Get-Item -LiteralPath $validIssuePath)).Count 'valid material implementation issue passes'
    Assert-Equal 0 @(Test-ActiveImplementationIssueGate -ActiveChangesRoot $issueFixtureRoot).Count 'valid active implementation issue and INDEX pass'

    [System.IO.File]::WriteAllText((Join-Path $fixtureAttachmentRoot 'INDEX.md'), "# INDEX`n", [System.Text.UTF8Encoding]::new($false))
    $missingIndexProblems = @(Test-ActiveImplementationIssueGate -ActiveChangesRoot $issueFixtureRoot)
    Assert-True (@($missingIndexProblems | Where-Object { $_ -like 'issue-index-entry:*' }).Count -eq 1) 'a valid active issue omitted from INDEX is rejected'
    [System.IO.File]::WriteAllText((Join-Path $fixtureAttachmentRoot 'INDEX.md'), $fixtureIndex, [System.Text.UTF8Encoding]::new($false))

    $invalidIssueName = 'issue-20260903-153000-invalid-contract.md'
    $invalidIssue = @'
---
issue_id: issue-20260903-153000-invalid-contract
status: resolved
source: summary
source_ref: task:2.2
affected_tasks: []
created_at: 2026-09-03T15:30:00+08:00
---

# Invalid Contract

## Symptom

The fixture intentionally violates the protocol.

## Investigation Log

The fixture omits required lifecycle detail.

## Disposition

- [ ] Track completion here.

## Evidence

### Failure Evidence (RED)

- Command: `pwsh.exe -NoProfile -File tests/Protocol.Tests.ps1`
- Run ID: protocol-red-002

### What This Proves

The negative fixture reaches the checker.

### What This Does Not Prove

It does not represent a valid issue.

## Links

- Task 2.2.
'@
    $invalidIssuePath = Join-Path $fixtureImplementationRoot $invalidIssueName
    [System.IO.File]::WriteAllText($invalidIssuePath, $invalidIssue, [System.Text.UTF8Encoding]::new($false))
    $invalidIssueProblems = @(Test-ImplementationIssueFile -File (Get-Item -LiteralPath $invalidIssuePath))
    foreach ($prefix in @('issue-source:', 'issue-affected-tasks:', 'issue-resolved-at:', 'issue-resolution-ref:', 'issue-section:', 'issue-checkbox:')) {
        Assert-True (@($invalidIssueProblems | Where-Object { $_ -like "$prefix*" }).Count -ge 1) "invalid material issue must report $prefix"
    }
}
finally {
    if (Test-Path -LiteralPath $issueFixtureRoot) {
        Remove-Item -LiteralPath $issueFixtureRoot -Recurse -Force
    }
}

$activeImplementationIssues = @(Test-ActiveImplementationIssueGate -ActiveChangesRoot (Join-Path $projectRoot 'openspec\changes'))
Assert-Equal 0 $activeImplementationIssues.Count ("Active implementation issue gate failed:`n{0}" -f ($activeImplementationIssues -join [Environment]::NewLine))

$reviewIssues = @(Test-ReviewClosureGate -ReviewRoot (Join-Path $changeRoot 'attachments\reviews'))
Assert-Equal 0 $reviewIssues.Count ("Review closure gate failed:`n{0}" -f ($reviewIssues -join [Environment]::NewLine))

$replanFiles = @(Get-ChildItem -LiteralPath (Join-Path $changeRoot 'attachments\replans') -File -Filter 'replan-*.md')
Assert-True ($replanFiles.Count -ge 1) 'The dogfood change keeps at least one applied Replan record'
foreach ($file in $replanFiles) {
    $record = Get-Content -LiteralPath $file.FullName -Raw
    Assert-Contains $record '(?m)^status: applied[ \t]*\r?$' "$($file.Name) is not applied-only"
    Assert-Contains $record '(?m)^base_tasks_sha256: [0-9a-f]{64}[ \t]*\r?$' "$($file.Name) lacks the base Task DAG digest"
    Assert-Contains $record '(?m)^result_tasks_sha256: [0-9a-f]{64}[ \t]*\r?$' "$($file.Name) lacks the result Task DAG digest"
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
