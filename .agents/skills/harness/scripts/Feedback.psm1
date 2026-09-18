#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-HarnessUpdateNotice {
    param([Parameter(Mandatory)][string]$HarnessRoot)
    $path = Join-Path $HarnessRoot '.agents/skills/harness/updates.json'
    try {
        $notice = Get-Content -LiteralPath $path -Raw -ErrorAction Stop | ConvertFrom-Json -AsHashtable
        if (-not $notice.revision -or -not $notice.published_at -or -not $notice.summary -or -not ($notice.affected_skills -is [array])) { throw 'Required update fields are missing.' }
        return [pscustomobject]@{ Updates=[pscustomobject]$notice; UpdatesIssue=$null }
    } catch { return [pscustomobject]@{ Updates=$null; UpdatesIssue="Update notice unavailable: $($_.Exception.Message)" } }
}

function Get-HarnessFeedbackInbox {
    param([Parameter(Mandatory)]$Context, [ValidateRange(1,1000)][int]$Limit=30)
    $issues = [Collections.Generic.List[string]]::new()
    $events = @{}
    $root = Join-Path $Context.WorkspaceRoot 'Saved/Harness/Observations'
    $dispositionRoot = Join-Path $root 'triage'
    if (Test-Path -LiteralPath $dispositionRoot) {
        foreach ($file in @(Get-ChildItem -LiteralPath $dispositionRoot -Filter '*.json' -File | Sort-Object Name)) {
            try {
                $event = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -AsHashtable
                if ($event.schema -ne 'harness-triage-v1' -or -not $event.entries) { throw 'Invalid triage record.' }
                foreach ($entry in $event.entries) { $events[$entry.ObservationId] = $entry }
            } catch { $issues.Add("$($file.Name): $($_.Exception.Message)") }
        }
    }
    $groups = @{}
    foreach ($directory in @($root,(Join-Path $Context.WorkspaceRoot 'Saved/Hardness/Observations'))) {
        if (-not (Test-Path -LiteralPath $directory)) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $directory -Filter '*.json' -File)) {
            try {
                $raw = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json -AsHashtable
                if (-not $raw.runId -or -not $raw.summary -or -not $raw.observedAtUtc) { throw 'Invalid observation.' }
                # Older observation schemas predate these optional metadata fields.
                $key = if ($raw['dedupKey']) { 'key:' + $raw['dedupKey'] } else { 'id:' + $raw.runId }
                if (-not $groups.ContainsKey($key)) { $groups[$key] = [Collections.Generic.List[object]]::new() }
                $groups[$key].Add([pscustomobject]@{
                    ObservationId=$raw.runId; Summary=$raw.summary; Category=$raw.category; ObservedAt=$raw.observedAtUtc
                    SourceRef=$raw['sourceRef']; OwnerDraftId=$raw['ownerDraftId']; Path=$file.FullName; Disposition=$events[$raw.runId]
                })
            } catch { $issues.Add("$($file.Name): $($_.Exception.Message)") }
        }
    }
    $all = @(@(foreach ($key in $groups.Keys) {
        $items = @($groups[$key] | Sort-Object ObservedAt -Descending)
        $states = @($items | ForEach-Object { if ($null -eq $_.Disposition) { 'pending' } else { $_.Disposition.Status } } | Sort-Object -Unique)
        $status = if ('pending' -in $states) { 'pending' } elseif ($states.Count -eq 1) { $states[0] } else { 'mixed' }
        [pscustomobject]@{ Key=$key; Summary=$items[0].Summary; LatestAt=$items[0].ObservedAt; Count=$items.Count; Status=$status; Occurrences=$items }
    }) | Sort-Object LatestAt -Descending)
    [pscustomobject]@{ Groups=@($all | Select-Object -First $Limit); TotalGroups=$all.Count; Truncated=($all.Count -gt $Limit); Issues=@($issues); RawBodiesLoaded=$true; InboxPath=(Join-Path $root 'INBOX.md') }
}

function Write-HarnessFeedbackInbox {
    param([Parameter(Mandatory)]$Context)
    $inbox = Get-HarnessFeedbackInbox -Context $Context -Limit 1000
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('# Harness feedback inbox')
    $lines.Add('')
    $lines.Add('- Derived from raw observations and triage records. Edit through harness.evolution.triage; this file is not an approval source.')
    foreach ($group in $inbox.Groups) {
        $lines.Add('')
        $lines.Add("## $($group.Summary -replace '[\r\n]+',' ')")
        $lines.Add("- Status: $($group.Status); occurrences: $($group.Count)")
        foreach ($item in $group.Occurrences) {
            $lines.Add("- $($item.ObservationId): $($item.Summary -replace '[\r\n]+',' ') — source: $($item.SourceRef); draft: $($item.OwnerDraftId)")
            if ($null -ne $item.Disposition) {
                $d = $item.Disposition
                $lines.Add("  - $($d.Status); scope: $($d.Scope); decision: $($d.DecisionSource); result: $($d.Result); evidence: $($d.Evidence -join ', ')")
            }
        }
    }
    foreach ($issue in $inbox.Issues) { $lines.Add("- Read issue: $issue") }
    if ($inbox.Truncated) { $lines.Add('- Additional groups omitted; inspect raw records for full history.') }
    [void][IO.Directory]::CreateDirectory((Split-Path $inbox.InboxPath))
    $temporary = $inbox.InboxPath + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
    try { [IO.File]::WriteAllText($temporary,($lines -join "`n") + "`n"); [IO.File]::Move($temporary,$inbox.InboxPath,$true) }
    finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary } }
    return $inbox.InboxPath
}

function Set-HarnessEvolutionTriage {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Context, [Parameter(Mandatory)][string[]]$ObservationIds,
        [Parameter(Mandatory)][ValidateSet('selected','deferred','dismissed','resolved')][string]$Disposition,
        [string]$DecisionSource, [string]$Scope, [string]$Result, [string[]]$Evidence=@())
    if (-not $ObservationIds.Count) { throw 'Select at least one observation.' }
    if ($Disposition -eq 'resolved') {
        if ([string]::IsNullOrWhiteSpace($Result) -or -not @($Evidence | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count) { throw 'Resolution requires Result and Evidence.' }
    } elseif ([string]::IsNullOrWhiteSpace($DecisionSource) -or [string]::IsNullOrWhiteSpace($Scope)) { throw 'Triage requires the actual user DecisionSource and bounded Scope.' }
    $probe = & git -C $Context.WorkspaceRoot check-ignore --quiet -- 'Saved/Harness/Observations/triage/probe.json'
    if ($LASTEXITCODE -ne 0) { throw 'Refusing to write triage outside an ignored observation store.' }
    $directory = Join-Path $Context.WorkspaceRoot 'Saved/Harness/Observations/triage'
    [void][IO.Directory]::CreateDirectory($directory)
    $lock = $null
    try {
        $lock = [IO.File]::Open((Join-Path $directory '.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
        $inbox = Get-HarnessFeedbackInbox -Context $Context -Limit 1000
        if ($inbox.Issues.Count -or $inbox.Truncated) { throw 'Resolve inbox read issues or excess groups before triage.' }
        $known = @{}
        foreach ($group in $inbox.Groups) { foreach ($item in $group.Occurrences) { $known[$item.ObservationId] = $item } }
        $entries = @(foreach ($id in @($ObservationIds | Sort-Object -Unique)) {
            if (-not $known.ContainsKey($id)) { throw "Unknown observation: $id" }
            $prior = $known[$id].Disposition
            if ($Disposition -eq 'resolved' -and ($null -eq $prior -or $prior.Status -ne 'selected')) { throw "Resolution requires a selected scope: $id" }
            [ordered]@{ ObservationId=$id; Status=$Disposition
                DecisionSource=$(if ($Disposition -eq 'resolved') { $prior.DecisionSource } else { $DecisionSource })
                Scope=$(if ($Disposition -eq 'resolved') { $prior.Scope } else { $Scope })
                Result=$Result; Evidence=@($Evidence) }
        })
        $path = Join-Path $directory ([DateTimeOffset]::UtcNow.ToString('yyyyMMddTHHmmssfffffff') + '-' + [guid]::NewGuid().ToString('N') + '.json')
        $temporary = $path + '.tmp'
        try {
            [IO.File]::WriteAllText($temporary,(@{schema='harness-triage-v1';recorded_at=[DateTimeOffset]::UtcNow.ToString('o');entries=$entries} | ConvertTo-Json -Depth 12))
            [IO.File]::Move($temporary,$path,$false)
        } finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary } }
        $inboxPath = Write-HarnessFeedbackInbox -Context $Context
        [pscustomobject]@{ Disposition=$Disposition; ObservationIds=@($ObservationIds); Artifacts=@($path,$inboxPath) }
    } finally { if ($null -ne $lock) { $lock.Dispose() } }
}

Export-ModuleMember -Function Get-HarnessUpdateNotice,Get-HarnessFeedbackInbox,Write-HarnessFeedbackInbox,Set-HarnessEvolutionTriage
