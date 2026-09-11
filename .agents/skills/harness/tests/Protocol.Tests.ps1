#requires -Version 7.0
#requires -PSEdition Core

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

function Test-ReviewClosureGate {
    param([string]$ReviewRoot)

    $issues = @()
    if (-not (Test-Path -LiteralPath $ReviewRoot -PathType Container)) {
        return $issues
    }
    $reviewFiles = @(Get-ChildItem -LiteralPath $ReviewRoot -File -Filter 'review-*.md')
    if ($reviewFiles.Count -eq 0) {
        return $issues
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
            $assignedAtValid = Test-IsoTimestamp $assignedAt
            $reviewedAtPresent = -not [string]::IsNullOrWhiteSpace($reviewedAt)
            $reviewedAtValid = $reviewedAtPresent -and (Test-IsoTimestamp $reviewedAt)
            $closedAtPresent = -not [string]::IsNullOrWhiteSpace($closedAt)
            $closedAtValid = $closedAtPresent -and (Test-IsoTimestamp $closedAt)

            if ($reviewKind -notin @('incident', 'final', 'external')) {
                $issues += "review-kind: $($file.Name) has invalid review_kind '$reviewKind'"
            }
            # Historical review-v2 records may retain the retired Harness requester.
            # Live policy assertions below forbid creating new automatic Reviews.
            if ($requestedBy -notin @('harness', 'user', 'external-agent')) {
                $issues += "review-requester: $($file.Name) has invalid requested_by '$requestedBy'"
            }
            if (-not $assignedAtValid) {
                $issues += "review-assigned-at: $($file.Name) requires an actual ISO-8601 assigned_at"
            }
            if ($reviewState -eq 'closed' -and -not $reviewedAtValid) {
                $issues += "review-reviewed-at: $($file.Name) closed review requires an actual ISO-8601 reviewed_at"
            }
            elseif ($reviewedAtPresent -and -not $reviewedAtValid) {
                $issues += "review-reviewed-at: $($file.Name) populated reviewed_at must be an actual ISO-8601 timestamp"
            }
            if ($reviewState -in @('closed', 'superseded') -and -not $closedAtValid) {
                $issues += "review-closed-at: $($file.Name) closed/superseded review requires an actual ISO-8601 closed_at"
            }
            elseif ($closedAtPresent -and -not $closedAtValid) {
                $issues += "review-closed-at: $($file.Name) populated closed_at must be an actual ISO-8601 timestamp"
            }
            if ($assignedAtValid) {
                $assignedInstant = [DateTimeOffset]::Parse($assignedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
                if ($reviewedAtValid) {
                    $reviewedInstant = [DateTimeOffset]::Parse($reviewedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
                    if ($reviewedInstant -lt $assignedInstant) {
                        $issues += "review-lifecycle-order: $($file.Name) reviewed_at must not precede assigned_at"
                    }
                }
                if ($closedAtValid) {
                    $closedInstant = [DateTimeOffset]::Parse($closedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
                    if ($closedInstant -lt $assignedInstant) {
                        $issues += "review-lifecycle-order: $($file.Name) closed_at must not precede assigned_at"
                    }
                    if ($reviewedAtValid -and $closedInstant -lt $reviewedInstant) {
                        $issues += "review-lifecycle-order: $($file.Name) closed_at must not precede reviewed_at"
                    }
                }
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
    $issueSchema = Get-ReviewMetadataValue -Text $frontmatter -Names @('issue_schema')
    $status = (Get-ReviewMetadataValue -Text $frontmatter -Names @('status')).ToLowerInvariant()
    $source = (Get-ReviewMetadataValue -Text $frontmatter -Names @('source')).ToLowerInvariant()
    $sourceRef = Get-ReviewMetadataValue -Text $frontmatter -Names @('source_ref')
    $createdAt = Get-ReviewMetadataValue -Text $frontmatter -Names @('created_at')

    if (-not [string]::IsNullOrWhiteSpace($issueSchema) -and $issueSchema -ne 'openspec-material-issue-v2') { $issues += "issue-schema: $($File.Name) has unsupported issue_schema '$issueSchema'" }
    if ($issueId -ne $File.BaseName) { $issues += "issue-id: $($File.Name) issue_id must match its filename stem" }
    if ($status -notin @('open', 'resolved', 'rejected', 'superseded')) { $issues += "issue-status: $($File.Name) has invalid status '$status'" }
    if ($source -notin @('dogfooding', 'implementation', 'verification', 'review', 'dependency', 'user')) { $issues += "issue-source: $($File.Name) has invalid source '$source'" }
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
    if ($status -in @('resolved', 'rejected')) {
        if (-not (Test-IsoTimestamp -Value $resolvedAt)) { $issues += "issue-resolved-at: $($File.Name) requires an ISO-8601 resolved_at" }
        if ([string]::IsNullOrWhiteSpace($resolutionRef)) { $issues += "issue-resolution-ref: $($File.Name) requires resolution_ref" }
        if (-not [string]::IsNullOrWhiteSpace($supersededBy)) { $issues += "issue-status-fields: $($File.Name) $status status forbids superseded_by" }
    }
    elseif ($status -eq 'superseded') {
        if (-not (Test-IsoTimestamp -Value $resolvedAt)) { $issues += "issue-resolved-at: $($File.Name) requires an ISO-8601 resolved_at" }
        if ([string]::IsNullOrWhiteSpace($supersededBy)) { $issues += "issue-superseded-by: $($File.Name) requires superseded_by" }
        if (-not [string]::IsNullOrWhiteSpace($resolutionRef)) { $issues += "issue-status-fields: $($File.Name) superseded status forbids resolution_ref" }
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
        $indexLines = if (Test-Path -LiteralPath $indexPath -PathType Leaf) { @(Get-Content -LiteralPath $indexPath) } else { @() }
        if ([string]::IsNullOrWhiteSpace($indexText)) { $issues += "issue-index: $attachmentRoot requires INDEX.md" }
        foreach ($directory in @(Get-ChildItem -LiteralPath $implementationRoot.FullName -Directory)) {
            $issues += "issue-nested-directory: $($directory.FullName) is not allowed"
        }
        foreach ($file in @(Get-ChildItem -LiteralPath $implementationRoot.FullName -File)) {
            $issues += @(Test-ImplementationIssueFile -File $file)
            if (-not [string]::IsNullOrWhiteSpace($indexText)) {
                $relative = $file.FullName.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
                $indexCount = Get-ExactAttachmentIndexEntryCount -IndexLines $indexLines -RelativePath $relative
                if ($indexCount -ne 1) { $issues += "issue-index-entry: $($file.Name) must appear in INDEX.md exactly once (actual $indexCount)" }
            }
        }
    }
    return $issues
}

function Test-ImplementationIssueClosureGate {
    param([Parameter(Mandatory = $true)][string]$ChangeRoot)

    $issues = @(Test-ActiveImplementationIssueGate -ActiveChangesRoot $ChangeRoot)
    $implementationRoot = Join-Path $ChangeRoot 'attachments\implementation'
    if (-not (Test-Path -LiteralPath $implementationRoot -PathType Container)) { return $issues }
    foreach ($file in @(Get-ChildItem -LiteralPath $implementationRoot -File -Filter 'issue-*.md')) {
        $record = Get-Content -LiteralPath $file.FullName -Raw
        $frontmatter = Get-ReviewFrontmatter $record
        $issueSchema = Get-ReviewMetadataValue -Text $frontmatter -Names @('issue_schema')
        $status = (Get-ReviewMetadataValue -Text $frontmatter -Names @('status')).ToLowerInvariant()
        if ($issueSchema -eq 'openspec-material-issue-v2' -and $status -eq 'open') {
            $issues += "issue-open: $($file.Name) must reach resolved, rejected, or superseded before closure"
        }
    }
    return $issues
}

function Get-ExactAttachmentIndexEntryCount {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$IndexLines,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    $expectedPath = $RelativePath.Replace('\', '/')
    $count = 0
    foreach ($rawLine in $IndexLines) {
        $line = $rawLine.Replace('\', '/')
        $tableEntry = [regex]::Match($line, '^[ \t]*\|[ \t]*`(?<path>[^`\r\n]+)`[ \t]*\|')
        $bulletEntry = [regex]::Match(
            $line,
            '^[ \t]*[-*][ \t]+(?:`(?<inline>[^`\r\n]+)`|\[[^\]\r\n]*\]\((?<link>[^)\r\n]+)\)|(?<bare>[^ \t\r\n]+))(?:[ \t]+.*)?$'
        )
        if (-not $tableEntry.Success -and -not $bulletEntry.Success) { continue }
        $indexedPath = if ($tableEntry.Success) {
            $tableEntry.Groups['path'].Value
        }
        elseif ($bulletEntry.Groups['inline'].Success) {
            $bulletEntry.Groups['inline'].Value
        }
        elseif ($bulletEntry.Groups['link'].Success) {
            $bulletEntry.Groups['link'].Value
        }
        else {
            $bulletEntry.Groups['bare'].Value
        }
        if ($indexedPath -ceq $expectedPath) { $count++ }
    }
    return $count
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
    foreach ($file in @(Get-ChildItem -LiteralPath $attachmentRoot -Recurse -File | Where-Object { $_.FullName -ne $indexPath })) {
        $relative = $file.FullName.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $count = Get-ExactAttachmentIndexEntryCount -IndexLines $indexLines -RelativePath $relative
        if ($count -ne 1) { $issues += "attachment-index-entry: $ChangeRoot must index '$relative' exactly once (actual $count)" }
    }
    return $issues
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$referenceRoot = Join-Path $projectRoot '.agents\skills\harness\references'
$changeRoot = Join-Path $projectRoot 'openspec\archive\changes\hardness\2026-09-03-refactor-skill-system'
$exePath = Join-Path $projectRoot '.agents\skills\openspec\bin\openspec.exe'
$harnessSkillPath = Join-Path $projectRoot '.agents\skills\harness\SKILL.md'
$routingPath = Join-Path $referenceRoot 'routing.md'
$verificationPath = Join-Path $referenceRoot 'verification.md'
$hookScriptPath = Join-Path $projectRoot '.agents\skills\harness\scripts\Invoke-HarnessCodexHook.ps1'
$hookConfigPath = Join-Path $projectRoot '.codex\hooks.json'

Assert-True (Test-Path -LiteralPath $changeRoot -PathType Container) 'The archived Hardness dogfood record is required for protocol audit'
Assert-True (Test-Path -LiteralPath $verificationPath -PathType Leaf) 'The canonical impact-scoped verification policy is required'

$harnessSkill = Get-Content -LiteralPath $harnessSkillPath -Raw
$routingProtocol = Get-Content -LiteralPath $routingPath -Raw
$verificationProtocol = Get-Content -LiteralPath $verificationPath -Raw
$taskProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'task-dag.md') -Raw
$replanProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'replan.md') -Raw
$reviewProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'review.md') -Raw
$closureProtocol = Get-Content -LiteralPath (Join-Path $referenceRoot 'closure.md') -Raw
$implementationProtocol = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\references\implementation-issues.md') -Raw

foreach ($legacyPattern in @('native Goal mode', 'Choose the workspace mode', 'Native Goal iteration', 'New-HarnessContext -Mode', '\.worktrees/<goal>', 'goal/<goal>')) {
    Assert-True ($harnessSkill -notmatch $legacyPattern) "Harness entry still exposes legacy repository mode text: $legacyPattern"
}
foreach ($token in @(
    'one Git-derived workspace model',
    'Codex `/goal`',
    'external continuation',
    'do not reopen `design`-mode brainstorming',
    'Brainstorm Gate',
    '`brainstorming`',
    'openspec/drafts/<domain>/<topic>/',
    'Apply never asks the user',
    'never opens `brainstorming`',
    'lightweight investigation',
    'multiple relationships, a sequence, or state transitions'
)) {
    Assert-True ($harnessSkill.Contains($token)) "Harness entry is missing the unified workflow contract: $token"
}
Assert-True ($harnessSkill.Contains('[impact-scoped verification policy](references/verification.md)')) 'Harness entry routes verification decisions to the canonical focused reference'
Assert-True (-not $harnessSkill.Contains('Run the core gates through one public test entry:')) 'Harness entry does not present every aggregate profile as a routine gate'
foreach ($token in @(
    'smallest reliable scope',
    'Skill, Markdown, template, or specification',
    'single Harness route or module',
    'public envelope, dispatcher routing, or shared state',
    'matching Unreal operation',
    '`Performance`',
    '`Integration`',
    '`Quick`',
    'adjacent affected surface',
    'release gate',
    'explicit user request',
    'tests actually run',
    'intentionally omitted',
    'does not add a parser field'
)) {
    Assert-True ($verificationProtocol.Contains($token)) "Impact-scoped verification policy is missing: $token"
}
Assert-Contains $verificationProtocol '(?i)local failure.*(?:diagnose|repair).*current task' 'Local failures remain in the current task'
Assert-Contains $verificationProtocol '(?i)Replan.*requirement.*design.*Task DAG.*verification contract.*required artifact' 'Replan remains evidence-gated by invalid planning truth'
Assert-Contains $verificationProtocol '(?i)(?:full|complete).*Unreal.*(?:product code|release gate|explicit user request)' 'Full Unreal verification remains conditional'
foreach ($token in @('`workspace.list`', '`harness.status`', '`harness.observe`', '`harness.evolution.status`', '`openspec.maintenance.status`')) {
    Assert-True ($routingProtocol.Contains($token)) "Route map is missing: $token"
}
Assert-Contains $taskProtocol 'Outcome, Interfaces, named Cases and Notes stay inside the owning card' 'Task Card detail stays inside the owning heading-node card'
Assert-Contains $taskProtocol 'Harness does not parse those labels' 'Harness adds no Task Card parser contract beyond Files and Verification'
Assert-Contains $reviewProtocol '(?i)explicit user or external-agent request' 'Review starts only from an explicit user or external-agent request'
Assert-Contains $reviewProtocol '(?i)(?:impact|incident).*never.*(?:auto|automatic).*Review|never.*(?:auto|automatic).*Review.*(?:impact|incident)' 'Impact and incident evidence never auto-start Review'
Assert-Contains $reviewProtocol '(?i)verified work.*close and archive directly.*(?:without|no).*Review' 'Verified work may close and archive without Review'
Assert-Contains $reviewProtocol '(?i)local defect.*(?:fix|repair)|(?:fix|repair).*local defect' 'Local defects are repaired directly'
Assert-Contains $reviewProtocol '(?i)planning-invalidating evidence.*Replan|Replan.*planning-invalidating evidence' 'Planning-invalidating evidence triggers Replan'
Assert-Contains $reviewProtocol '(?i)asynchronous' 'An explicitly requested Review may run asynchronously'
Assert-Contains $reviewProtocol '(?i)immutable snapshot' 'Every explicitly requested Review uses an immutable snapshot'
Assert-Contains $closureProtocol 'workspace or worktree' 'Closure is independent from workspace removal'

Assert-True (Test-Path -LiteralPath $hookScriptPath -PathType Leaf) 'The bounded Codex hook adapter is required'
Assert-True (Test-Path -LiteralPath $hookConfigPath -PathType Leaf) 'Project Codex hook configuration is required'
$null = & git -C $projectRoot check-ignore --no-index --quiet -- '.codex/hooks.json' 2>$null
$hookIgnoreExitCode = $LASTEXITCODE
Assert-Equal 1 $hookIgnoreExitCode '.codex/hooks.json remains trackable'
$null = & git -C $projectRoot check-ignore --no-index --quiet -- '.codex/local.json' 2>$null
$localCodexIgnoreExitCode = $LASTEXITCODE
Assert-Equal 0 $localCodexIgnoreExitCode 'Unrelated project-local .codex files remain ignored'
$hookScript = Get-Content -LiteralPath $hookScriptPath -Raw
foreach ($token in @('#requires -Version 7.0', '#requires -PSEdition Core', '[Console]::In.ReadToEnd()', 'rev-parse', 'harness.status', 'hookSpecificOutput', 'additionalContext')) {
    Assert-True ($hookScript.Contains($token)) "Codex hook adapter is missing: $token"
}
foreach ($forbiddenHookToken in @('harness.observe', 'workspace.bootstrap', 'workspace.config.set', 'git.commit', 'git.push', 'Stop-Harness')) {
    Assert-True (-not $hookScript.Contains($forbiddenHookToken)) "Codex hook adapter must remain non-mutating: $forbiddenHookToken"
}

$hookConfig = Get-Content -LiteralPath $hookConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
$hookEventNames = @($hookConfig.hooks.PSObject.Properties.Name)
Assert-True ('SessionStart' -in $hookEventNames) 'SessionStart hook is required'
Assert-True ('SubagentStart' -in $hookEventNames) 'SubagentStart hook is required'
Assert-True ('Stop' -notin $hookEventNames) 'Stop hook is intentionally absent'
Assert-True ('PostToolUse' -notin $hookEventNames) 'PostToolUse hook is intentionally absent'
$sessionRegistration = @($hookConfig.hooks.SessionStart)[0]
Assert-Equal 'startup|resume' ([string]$sessionRegistration.matcher) 'SessionStart is limited to startup and resume'
$hookCommands = @($sessionRegistration.hooks) + @(@($hookConfig.hooks.SubagentStart)[0].hooks)
Assert-True ($hookCommands.Count -eq 2) 'Exactly one command is registered for each supported hook event'
foreach ($hookCommand in $hookCommands) {
    Assert-Equal 'command' ([string]$hookCommand.type) 'Codex hook uses the command adapter'
    Assert-Equal 3 ([int]$hookCommand.timeout) 'Codex hook timeout stays bounded at three seconds'
    Assert-True ([int]$hookCommand.additionalContextLimit -gt 0 -and [int]$hookCommand.additionalContextLimit -le 1200) 'Codex hook context limit stays positive and bounded'
    Assert-Contains ([string]$hookCommand.commandWindows) 'pwsh(?:\.exe)?[ \t]+-NoProfile' 'Codex hook explicitly uses PowerShell 7 without a profile'
}

$hookPayload = [ordered]@{
    cwd = (Join-Path $projectRoot '.agents\skills\harness')
    hook_event_name = 'SessionStart'
    source = 'startup'
} | ConvertTo-Json -Compress
$hookTimer = [System.Diagnostics.Stopwatch]::StartNew()
$hookOutput = @($hookPayload | & (Get-Command pwsh.exe -ErrorAction Stop).Source -NoProfile -File $hookScriptPath 2>&1)
$hookExitCode = $LASTEXITCODE
$hookTimer.Stop()
Assert-Equal 0 $hookExitCode "Optional Codex hook fails open: $($hookOutput -join [Environment]::NewLine)"
$hookResponse = ($hookOutput -join [Environment]::NewLine) | ConvertFrom-Json -ErrorAction Stop
Assert-Equal 'SessionStart' ([string]$hookResponse.hookSpecificOutput.hookEventName) 'Codex hook echoes the supported event name'
$additionalContext = [string]$hookResponse.hookSpecificOutput.additionalContext
Assert-True (-not [string]::IsNullOrWhiteSpace($additionalContext)) 'Codex hook returns concise optional context'
Assert-True ($additionalContext.Length -le [int]$hookCommands[0].additionalContextLimit) 'Codex hook output respects additionalContextLimit'
Assert-True ($hookTimer.ElapsedMilliseconds -lt 5000) "Codex hook remains lightweight (actual $($hookTimer.ElapsedMilliseconds) ms)"

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
    'Root checkbox list nodes, old inline verify, blockquote Files and body-level After formats are unsupported'
)) {
    Assert-True ($taskProtocol.Contains($token)) "Task DAG protocol is missing: $token"
}
Assert-Contains $replanProtocol 'status: applied' 'Replan records are applied-only'
foreach ($token in @('base_commit:', 'base_tasks_sha256:', 'result_tasks_sha256:', 'resume_task:', 'Old Task Disposition', 'Diff Snapshot', 'Preserved Work', 'attachments/talks/')) {
    Assert-True ($replanProtocol.Contains($token)) "Replan protocol is missing: $token"
}
Assert-Contains $reviewProtocol 'finding never directly triggers Replan' 'Review findings require evidence triage before Replan'
Assert-Contains $reviewProtocol 'open \| resolved \| rejected \| deferred' 'Review finding states are explicit'
Assert-Contains $reviewProtocol 'Critical or Required finding' 'Critical and Required findings gate explicit Review closure'
foreach ($token in @(
    'explicit user or external-agent request',
    'inline or asynchronously',
    '`snapshot_ref`',
    'A digest verifies content but does not by itself materialize an asynchronous snapshot',
    '`assigned_at` is never reused as a guessed completion time',
    'Every populated lifecycle timestamp is a real ISO-8601 instant with an explicit offset',
    '`assigned_at <= reviewed_at <= closed_at`',
    'superseded before completion may omit `reviewed_at`',
    'detailed report',
    'There is no Review file line limit',
    'closed or superseded',
    'open or deferred Critical or Required'
)) {
    Assert-True ($reviewProtocol.Contains($token)) "Review protocol is missing: $token"
}
foreach ($retiredReviewPattern in @(
    '(?i)Final Review:[ \t]*not required',
    '(?i)There are exactly three routes',
    '(?i)one batched incremental Final Review',
    '(?i)Diff size alone does not determine impact',
    '(?i)demonstrated major incident',
    '(?i)small low-impact',
    '(?i)Final Review is required',
    '(?i)requires? (?:an? )?Final Review',
    '(?i)must (?:run|perform|complete) (?:an? )?Final Review'
)) {
    Assert-True ($reviewProtocol -notmatch $retiredReviewPattern) "Review protocol still contains retired automatic or mandatory Review policy: $retiredReviewPattern"
}
foreach ($kind in @('`completed`', '`abandoned`', '`superseded`')) {
    Assert-True ($closureProtocol.Contains($kind)) "Closure protocol is missing $kind"
}
Assert-Contains $closureProtocol 'does not merge specs, merge Git branches, push, remove a worktree' 'Archive is separate from integration and removal'
foreach ($token in @('Material threshold', 'One root cause', 'Failure Evidence (RED)', 'Resolution Evidence (GREEN)', 'What This Proves', 'What This Does Not Prove', 'Do not record')) {
    Assert-True ($implementationProtocol.Contains($token)) "Implementation issue protocol is missing: $token"
}

$attachmentIndexFixtureRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine(
    [System.IO.Path]::GetTempPath(),
    ('harness-attachment-index-{0}' -f [guid]::NewGuid().ToString('N'))
))
$attachmentIndexTempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
Assert-True ($attachmentIndexFixtureRoot.StartsWith($attachmentIndexTempRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'Attachment INDEX fixture escaped the system temp directory'
try {
    $fixtureAttachments = Join-Path $attachmentIndexFixtureRoot 'attachments'
    $fixtureKnowledges = Join-Path $fixtureAttachments 'knowledges'
    [void](New-Item -ItemType Directory -Path $fixtureKnowledges -Force)
    $fixtureRelativePath = 'knowledges/clang-source-provenance.md'
    [System.IO.File]::WriteAllText(
        (Join-Path $fixtureKnowledges 'clang-source-provenance.md'),
        '# fixture attachment',
        [System.Text.UTF8Encoding]::new($false)
    )
    $fixtureIndexPath = Join-Path $fixtureAttachments 'INDEX.md'

    $validIndexEntries = @(
        "# INDEX`n`n- $fixtureRelativePath - bare path entry.`n",
        "# INDEX`n`n- ``$fixtureRelativePath`` - inline-code path entry.`n",
        "# INDEX`n`n- [Clang source provenance]($fixtureRelativePath) - Markdown link entry.`n"
    )
    foreach ($validIndex in $validIndexEntries) {
        [System.IO.File]::WriteAllText($fixtureIndexPath, $validIndex, [System.Text.UTF8Encoding]::new($false))
        Assert-Equal 0 @(Test-AttachmentIndexCompatibility -ChangeRoot $attachmentIndexFixtureRoot).Count 'bare, inline-code, and Markdown-link attachment entries each index one exact path'
    }

    $suffixAndProseIndex = @"
# INDEX

- ``$fixtureRelativePath`` - the one attachment entry.

The attachment $fixtureRelativePath is promoted after closure.
- ``openspec/specs/angelscript/language/frontend/source-diagnostics/$fixtureRelativePath`` - durable knowledge location, not another attachment entry.
"@
    [System.IO.File]::WriteAllText($fixtureIndexPath, $suffixAndProseIndex, [System.Text.UTF8Encoding]::new($false))
    Assert-Equal 0 @(Test-AttachmentIndexCompatibility -ChangeRoot $attachmentIndexFixtureRoot).Count 'prose and a longer path with the same suffix do not duplicate an exact attachment entry'

    $duplicateIndex = "# INDEX`n`n- ``$fixtureRelativePath```n- [$fixtureRelativePath]($fixtureRelativePath)`n"
    [System.IO.File]::WriteAllText($fixtureIndexPath, $duplicateIndex, [System.Text.UTF8Encoding]::new($false))
    $duplicateIssues = @(Test-AttachmentIndexCompatibility -ChangeRoot $attachmentIndexFixtureRoot)
    Assert-Equal 1 $duplicateIssues.Count 'two exact attachment entries remain invalid'
    Assert-Contains $duplicateIssues[0] 'actual 2' 'duplicate attachment entries report the exact entry count'

    [System.IO.File]::WriteAllText($fixtureIndexPath, "# INDEX`n", [System.Text.UTF8Encoding]::new($false))
    $missingIssues = @(Test-AttachmentIndexCompatibility -ChangeRoot $attachmentIndexFixtureRoot)
    Assert-Equal 1 $missingIssues.Count 'a missing attachment entry remains invalid'
    Assert-Contains $missingIssues[0] 'actual 0' 'missing attachment entries report zero exact entries'
}
finally {
    if (Test-Path -LiteralPath $attachmentIndexFixtureRoot) {
        Remove-Item -LiteralPath $attachmentIndexFixtureRoot -Recurse -Force
    }
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
    ('harness-review-protocol-{0}' -f [guid]::NewGuid().ToString('N'))
)
try {
    [void](New-Item -ItemType Directory -Path $reviewFixtureRoot)
    Assert-Equal 0 @(Test-ReviewClosureGate -ReviewRoot (Join-Path $reviewFixtureRoot 'reviews-absent')).Count 'verified work may close when no Review directory exists'
    Assert-Equal 0 @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot).Count 'verified work without an explicitly requested Review may close directly'

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
requested_by: user
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

    $validSupersededV2Review = @'
---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-03T14:30:00+08:00
reviewed_at:
closed_at: 2026-09-03T14:31:00+08:00
snapshot_ref: commit:123456789abcdef0123456789abcdef012345678
snapshot_sha256: 123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0
verdict: PENDING
---

# Valid superseded review-v2

The assignment was superseded before review completion.
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-valid-superseded-v2.md'),
        $validSupersededV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    Assert-Equal 0 @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot).Count 'superseded review may close after assignment without a completion timestamp'

    $impossibleTimestampV2Review = @'
---
review_schema: review-v2
review_kind: final
requested_by: user
state: closed
assigned_at: 2026-99-99T99:99:99+99:99
reviewed_at: 2026-09-03T15:01:00+08:00
closed_at: 2026-09-03T15:02:00+08:00
snapshot_ref: commit:23456789abcdef0123456789abcdef0123456789
snapshot_sha256: 23456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef01
verdict: APPROVE
---

# Impossible review-v2 timestamp
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-impossible-timestamp-v2.md'),
        $impossibleTimestampV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    $impossibleTimestampIssues = @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot)
    Assert-True (@($impossibleTimestampIssues | Where-Object { $_ -like 'review-assigned-at:*review-impossible-timestamp-v2.md*' }).Count -eq 1) 'lexically shaped but impossible review timestamp is rejected'

    $reversedLifecycleV2Review = @'
---
review_schema: review-v2
review_kind: final
requested_by: user
state: closed
assigned_at: 2026-09-03T15:00:00+08:00
reviewed_at: 2026-09-03T14:59:00+08:00
closed_at: 2026-09-03T15:01:00+08:00
snapshot_ref: commit:3456789abcdef0123456789abcdef0123456789a
snapshot_sha256: 3456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef012
verdict: APPROVE
---

# Reversed review-v2 lifecycle
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-reversed-lifecycle-v2.md'),
        $reversedLifecycleV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    $reversedLifecycleIssues = @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot)
    Assert-True (@($reversedLifecycleIssues | Where-Object { $_ -like 'review-lifecycle-order:*review-reversed-lifecycle-v2.md*reviewed_at*assigned_at*' }).Count -eq 1) 'review completion before assignment is rejected'

    $earlyClosureV2Review = @'
---
review_schema: review-v2
review_kind: final
requested_by: user
state: closed
assigned_at: 2026-09-03T15:00:00+08:00
reviewed_at: 2026-09-03T15:02:00+08:00
closed_at: 2026-09-03T15:01:00+08:00
snapshot_ref: commit:456789abcdef0123456789abcdef0123456789ab
snapshot_sha256: 456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123
verdict: APPROVE
---

# Early closure review-v2 lifecycle
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-early-closure-v2.md'),
        $earlyClosureV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    $earlyClosureIssues = @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot)
    Assert-True (@($earlyClosureIssues | Where-Object { $_ -like 'review-lifecycle-order:*review-early-closure-v2.md*closed_at*reviewed_at*' }).Count -eq 1) 'review closure before completion is rejected'

    $earlySupersededClosureV2Review = @'
---
review_schema: review-v2
review_kind: external
requested_by: external-agent
state: superseded
assigned_at: 2026-09-03T15:00:00+08:00
reviewed_at:
closed_at: 2026-09-03T14:59:00+08:00
snapshot_ref: commit:56789abcdef0123456789abcdef0123456789abc
snapshot_sha256: 56789abcdef0123456789abcdef0123456789abcdef0123456789abcdef01234
verdict: PENDING
---

# Early superseded review-v2 lifecycle
'@
    [System.IO.File]::WriteAllText(
        (Join-Path $reviewFixtureRoot 'review-early-superseded-v2.md'),
        $earlySupersededClosureV2Review,
        [System.Text.UTF8Encoding]::new($false)
    )
    $earlySupersededIssues = @(Test-ReviewClosureGate -ReviewRoot $reviewFixtureRoot)
    Assert-True (@($earlySupersededIssues | Where-Object { $_ -like 'review-lifecycle-order:*review-early-superseded-v2.md*closed_at*assigned_at*' }).Count -eq 1) 'superseded closure before assignment is rejected'

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
    ('harness-implementation-issue-{0}' -f [guid]::NewGuid().ToString('N'))
)
try {
    $fixtureAttachmentRoot = Join-Path $issueFixtureRoot 'fixture\sample\attachments'
    $fixtureImplementationRoot = Join-Path $fixtureAttachmentRoot 'implementation'
    [void](New-Item -ItemType Directory -Path $fixtureImplementationRoot -Force)
    $validIssueName = 'issue-20260903-143000-shared-root-cause.md'
    $validIssue = @'
---
issue_schema: openspec-material-issue-v2
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
    Assert-Equal 0 @(Test-ImplementationIssueClosureGate -ChangeRoot (Join-Path $issueFixtureRoot 'fixture\sample')).Count 'resolved v2 material issue passes the closure gate'

    $issueSuffixAndProseIndex = @"
# INDEX

- ``implementation/$validIssueName`` - the one material issue entry.

The issue implementation/$validIssueName is discussed here without creating an index entry.
- ``openspec/archive/changes/fixture/sample/attachments/implementation/$validIssueName`` - a longer durable path, not another local entry.
"@
    [System.IO.File]::WriteAllText((Join-Path $fixtureAttachmentRoot 'INDEX.md'), $issueSuffixAndProseIndex, [System.Text.UTF8Encoding]::new($false))
    Assert-Equal 0 @(Test-ActiveImplementationIssueGate -ActiveChangesRoot $issueFixtureRoot).Count 'active issue indexing uses the same exact-entry boundary as attachment compatibility'

    $duplicateIssueIndex = "# INDEX`n`n- ``implementation/$validIssueName```n- [material issue](implementation/$validIssueName)`n"
    [System.IO.File]::WriteAllText((Join-Path $fixtureAttachmentRoot 'INDEX.md'), $duplicateIssueIndex, [System.Text.UTF8Encoding]::new($false))
    $duplicateIssueProblems = @(Test-ActiveImplementationIssueGate -ActiveChangesRoot $issueFixtureRoot)
    Assert-Equal 1 @($duplicateIssueProblems | Where-Object { $_ -like 'issue-index-entry:*actual 2*' }).Count 'duplicate active issue entries remain invalid with their exact count'
    [System.IO.File]::WriteAllText((Join-Path $fixtureAttachmentRoot 'INDEX.md'), $fixtureIndex, [System.Text.UTF8Encoding]::new($false))

    $legacyIssue = $validIssue -replace '(?m)^issue_schema: openspec-material-issue-v2\r?\n', ''
    [System.IO.File]::WriteAllText($validIssuePath, $legacyIssue, [System.Text.UTF8Encoding]::new($false))
    Assert-Equal 0 @(Test-ImplementationIssueFile -File (Get-Item -LiteralPath $validIssuePath)).Count 'legacy material issue without issue_schema remains readable'
    [System.IO.File]::WriteAllText($validIssuePath, $validIssue, [System.Text.UTF8Encoding]::new($false))

    $rejectedIssue = $validIssue.Replace('status: resolved', 'status: rejected')
    [System.IO.File]::WriteAllText($validIssuePath, $rejectedIssue, [System.Text.UTF8Encoding]::new($false))
    Assert-Equal 0 @(Test-ImplementationIssueFile -File (Get-Item -LiteralPath $validIssuePath)).Count 'evidence-backed rejected v2 material issue is terminal'
    Assert-Equal 0 @(Test-ImplementationIssueClosureGate -ChangeRoot (Join-Path $issueFixtureRoot 'fixture\sample')).Count 'rejected v2 material issue passes the closure gate'
    [System.IO.File]::WriteAllText($validIssuePath, $validIssue, [System.Text.UTF8Encoding]::new($false))

    $openIssue = ($validIssue.Replace('status: resolved', 'status: open') -replace '(?m)^resolved_at: 2026-09-03T15:20:00\+08:00\r?\n', '') -replace '(?m)^resolution_ref: commit:0123456789abcdef\r?\n', ''
    [System.IO.File]::WriteAllText($validIssuePath, $openIssue, [System.Text.UTF8Encoding]::new($false))
    Assert-Equal 0 @(Test-ActiveImplementationIssueGate -ActiveChangesRoot $issueFixtureRoot).Count 'an open v2 material issue remains structurally valid during active work'
    $openClosureProblems = @(Test-ImplementationIssueClosureGate -ChangeRoot (Join-Path $issueFixtureRoot 'fixture\sample'))
    Assert-Equal 1 @($openClosureProblems | Where-Object { $_ -like 'issue-open:*' }).Count 'an open v2 material issue fails only the closure gate'
    [System.IO.File]::WriteAllText($validIssuePath, $validIssue, [System.Text.UTF8Encoding]::new($false))

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
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ("harness-protocol-{0}" -f [guid]::NewGuid().ToString('N'))))
Assert-True ($fixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'Protocol fixture escaped the system temp directory'

try {
    [void](New-Item -ItemType Directory -Path $fixtureRoot)
    $init = & $exePath init $fixtureRoot --project-id harness-protocol-fixture --title 'Harness Protocol Fixture' --workflow spec-driven --language en 2>&1
    Assert-Equal 0 $LASTEXITCODE "Fixture init failed: $($init -join [Environment]::NewLine)"
    Push-Location $fixtureRoot
    try {
        $domain = & $exePath domain create fixture --title Fixture --description Fixture --json 2>&1
        Assert-Equal 0 $LASTEXITCODE "Fixture domain creation failed: $($domain -join [Environment]::NewLine)"
        $change = & $exePath change create fixture/dag --title 'Task DAG' --goal 'Verify ready and cycle derivation' --json 2>&1
        Assert-Equal 0 $LASTEXITCODE "Fixture change creation failed: $($change -join [Environment]::NewLine)"
        $tasksPath = Join-Path $fixtureRoot 'openspec\changes\fixture\dag\tasks.md'
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

## [x] 1.1 Establish the base

**Files**

```diff
 base
```

**Verification**

```sh
base
```

## [ ] 1.2 Ready work

**Files**

```diff
 ready
```

**Verification**

```sh
ready
```

## [ ] 1.3 Blocked work

**Files**

```diff
 blocked
```

**Verification**

```sh
blocked
```
'@
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

## [ ] 1.1 First

**Files**

```diff
 one
```

**Verification**

```sh
one
```

## [ ] 1.2 Second

**Files**

```diff
 two
```

**Verification**

```sh
two
```
'@
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
