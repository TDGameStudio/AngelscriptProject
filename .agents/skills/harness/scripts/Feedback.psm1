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

function Get-HarnessHistoricalFeedbackInbox {
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

function Get-HarnessFeedbackRoot {
    param($Context)
    if ('OpenSpecRoot' -in $Context.PSObject.Properties.Name -and $Context.OpenSpecRoot) { return [string]$Context.OpenSpecRoot }
    return [string]$Context.WorkspaceRoot
}

function Assert-HarnessFeedbackPath {
    param([string]$Root, [string]$Path)
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $full = [IO.Path]::GetFullPath($Path)
    if (-not $full.StartsWith($base + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Feedback path escapes canonical records.' }
    $cursor = $base
    foreach ($part in $full.Substring($base.Length).TrimStart('\','/').Split([IO.Path]::DirectorySeparatorChar)) {
        $cursor = Join-Path $cursor $part
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Feedback path must not cross a reparse point.' }
    }
    return $full
}

function Get-HarnessDraftFeedback {
    param($Context)
    $root = Get-HarnessFeedbackRoot $Context
    foreach ($lane in @('openspec/drafts','openspec/archive/drafts')) {
        $base = Join-Path $root $lane
        if (-not (Test-Path -LiteralPath $base)) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $base -Recurse -Filter 'design.md' -File)) {
            [void](Assert-HarnessFeedbackPath $root $file.FullName)
            $text = [IO.File]::ReadAllText($file.FullName)
            foreach ($match in [regex]::Matches($text,'(?ms)^### Observation (?<id>[a-f0-9]{32})\r?\n(?<body>.*?)(?=^#{1,3} |\z)')) {
                $fields = @{}
                foreach ($field in [regex]::Matches($match.Groups['body'].Value,'(?m)^- (?<key>[A-Za-z]+): (?<value>[^\r\n]+)$')) {
                    $fields[$field.Groups['key'].Value] = ConvertFrom-Json -InputObject $field.Groups['value'].Value -Depth 12
                }
                foreach ($required in @('Summary','Source','Recorded','Key','Draft','Scope','Status','Category')) {
                    if (-not $fields[$required]) { throw "Incomplete draft observation $($match.Groups['id'].Value): $required" }
                }
                $disposition = if ($fields.Status -eq 'pending') { $null } else { [pscustomobject]@{Status=$fields.Status;DecisionSource=$fields['DecisionSource'];Scope=$fields['SelectedScope'];Result=$fields['Result'];Evidence=@($fields['Evidence'])} }
                [pscustomobject]@{ObservationId=$match.Groups['id'].Value;Summary=$fields.Summary;Category=$fields.Category;ObservedAt=$fields.Recorded;SourceRef=$fields.Source;OwnerDraftId=$fields.Draft;OwnerScope=$fields.Scope;Key=$fields.Key;Path=$file.FullName;Disposition=$disposition;Historical=$false;Archived=($lane -eq 'openspec/archive/drafts');Fields=$fields;Block=$match.Value}
            }
        }
    }
}

function Get-HarnessFeedbackInbox {
    param([Parameter(Mandatory)]$Context,[ValidateRange(1,1000)][int]$Limit=30)
    $historical = Get-HarnessHistoricalFeedbackInbox $Context -Limit 1000
    $issues = [Collections.Generic.List[string]]::new()
    foreach ($issue in $historical.Issues) { $issues.Add($issue) }
    $groups = [Collections.Generic.List[object]]::new()
    try {
        $draftItems = @(Get-HarnessDraftFeedback $Context)
        foreach ($group in @($draftItems | Group-Object { $_.OwnerDraftId + '/' + $_.OwnerScope + ':' + $_.Key })) {
            $items = @($group.Group | Sort-Object ObservedAt -Descending)
            $states = @($items | ForEach-Object { if ($_.Disposition) { $_.Disposition.Status } else { 'pending' } } | Sort-Object -Unique)
            $status = if ('pending' -in $states) { 'pending' } elseif ($states.Count -eq 1) { $states[0] } else { 'mixed' }
            $groups.Add([pscustomobject]@{Key=$group.Name;Summary=$items[0].Summary;LatestAt=$items[0].ObservedAt;Count=$items.Count;Status=$status;Occurrences=$items})
        }
    } catch { $issues.Add("Draft feedback: $($_.Exception.Message)") }
    foreach ($group in $historical.Groups) {
        foreach ($item in $group.Occurrences) { $item | Add-Member -NotePropertyMembers @{Historical=$true;Archived=$false} -Force }
        $groups.Add($group)
    }
    $ordered = @($groups | Sort-Object LatestAt -Descending)
    [pscustomobject]@{Groups=@($ordered | Select-Object -First $Limit);TotalGroups=$ordered.Count;Truncated=($historical.Truncated -or $ordered.Count -gt $Limit);Issues=@($issues.ToArray());RawBodiesLoaded=$historical.RawBodiesLoaded;InboxPath=$null}
}

function ConvertTo-HarnessFeedbackBlock {
    param([string]$Id,[System.Collections.IDictionary]$Fields)
    $lines = @("### Observation $Id",'')
    foreach ($key in @('Summary','Category','Source','Recorded','Key','Draft','Scope','Status','Change','Stage','CorrelationId','DurationMs','DecisionSource','SelectedScope','Result','Evidence')) {
        if ($Fields.Contains($key)) { $lines += '- ' + $key + ': ' + (ConvertTo-Json -InputObject $Fields[$key] -Depth 12 -Compress) }
    }
    return ($lines -join "`n") + "`n`n"
}

function Enter-HarnessFeedbackLock {
    param([string]$Path)
    $key=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes([IO.Path]::GetFullPath($Path).ToLowerInvariant())))
    $mutex=[Threading.Mutex]::new($false,'HarnessFeedback-'+$key)
    $held=$false
    try { try { $held=$mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $held=$true }; if (-not $held) { throw 'The owning feedback draft is busy; retry after the current write.' }; return $mutex }
    catch { $mutex.Dispose(); throw }
}

function Add-HarnessDraftFeedback {
    param($Context,[string]$Category,[string]$Summary,[string]$SourceRef,[string]$DedupKey,[string]$OwnerDraftId,[string]$OwnerScope,[string]$Change,[string]$Stage,[string]$CorrelationId,[long]$DurationMs)
    if ([string]::IsNullOrWhiteSpace($SourceRef)) {
        if ($CorrelationId) { $SourceRef = 'correlation:' + $CorrelationId }
        else { throw 'Feedback capture requires an actual SourceRef or run CorrelationId.' }
    }
    $root = Get-HarnessFeedbackRoot $Context
    $key = if ($DedupKey) { $DedupKey } else { $Summary.Trim().ToLowerInvariant() }
    $known = @(Get-HarnessDraftFeedback $Context | Where-Object { -not $_.Archived -and $_.Key -ceq $key -and (-not $OwnerDraftId -or $_.OwnerDraftId -ceq $OwnerDraftId) -and (-not $OwnerScope -or $_.OwnerScope -ceq $OwnerScope) })
    $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($key))).ToLowerInvariant().Substring(0,12)
    if ($known.Count) { $OwnerDraftId=$known[0].OwnerDraftId; $OwnerScope=$known[0].OwnerScope }
    if (-not $OwnerDraftId) { $OwnerDraftId = 'harness/feedback-' + $hash }
    if (-not $OwnerScope) { $OwnerScope = 'feedback-' + $hash }
    if ($OwnerDraftId -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*$' -or $OwnerScope -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { throw 'Feedback requires safe draft and scope identities.' }
    $relative = "openspec/drafts/$OwnerDraftId/designs/$OwnerScope/design.md"
    $path = Assert-HarnessFeedbackPath $root (Join-Path $root $relative)
    & git -C $root check-ignore --quiet -- $relative
    if ($LASTEXITCODE) { throw 'Refusing to capture feedback outside an ignored topic draft.' }
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1')
    $draftRoot = Join-Path $root "openspec/drafts/$OwnerDraftId"
    if (-not (Test-Path -LiteralPath $draftRoot)) { [void](New-HarnessDraft -Context $Context -DraftId $OwnerDraftId -Title $Summary -Mode research) }
    $draftStatus=Get-HarnessDraftStatus -Context $Context -DraftId $OwnerDraftId
    if (-not $draftStatus.Valid) { throw 'Cannot capture into an invalid owning draft.' }
    [void][IO.Directory]::CreateDirectory((Split-Path $path))
    $id = [guid]::NewGuid().ToString('N')
    $stamp=[DateTimeOffset]::UtcNow.ToString('o')
    $fields=[ordered]@{Summary=$Summary.Trim();Category=$Category;Source=$SourceRef;Recorded=$stamp;Key=$key;Draft=$OwnerDraftId;Scope=$OwnerScope;Status='pending';Change=$Change;Stage=$Stage;CorrelationId=$CorrelationId;DurationMs=$DurationMs;DecisionSource='';SelectedScope='';Result='';Evidence=@()}
    $lock=Enter-HarnessFeedbackLock $path
    try {
        if (-not [IO.File]::Exists($path)) {
            [IO.File]::WriteAllText($path,"---`ndesign: $OwnerScope`nstatus: exploring`nopened: $($stamp.Substring(0,10))`n---`n`n# $($Summary -replace '[\r\n]+',' ')`n`nSourced improvement questions; causes remain unproven until investigated. Capture does not authorize implementation or create a Change.`n`n")
            $readme=Join-Path $draftRoot 'README.md'
            [IO.File]::AppendAllText($readme,"`n- [$OwnerScope](designs/$OwnerScope/design.md) — sourced improvement findings and disposition.`n")
            [IO.File]::AppendAllText((Join-Path $draftRoot 'CONTEXT.md'),"`nFeedback scope: designs/$OwnerScope/design.md. Investigate the sourced question before selecting any implementation; return to the original authorized work.`n")
        }
        [IO.File]::AppendAllText($path,(ConvertTo-HarnessFeedbackBlock $id $fields))
    } finally { $lock.ReleaseMutex(); $lock.Dispose() }
    [pscustomobject]@{RunId=$id;Path=$path;ObservedAt=$stamp;Category=$Category;OwnerDraftId=$OwnerDraftId;OwnerScope=$OwnerScope;Artifacts=@($path)}
}

function Write-HarnessFeedbackInbox {
    param($Context)
    # Compatibility entry: the view is derived on demand, never a second ledger.
    return Get-HarnessFeedbackInbox $Context
}

function Set-HarnessEvolutionTriage {
    param([Parameter(Mandatory)]$Context,[Parameter(Mandatory)][string[]]$ObservationIds,[Parameter(Mandatory)][ValidateSet('selected','deferred','dismissed','resolved')][string]$Disposition,[string]$DecisionSource,[string]$Scope,[string]$Result,[string[]]$Evidence=@())
    if (-not $ObservationIds.Count) { throw 'Select at least one observation.' }
    if ($Disposition -eq 'resolved') {
        if (-not $Result -or -not @($Evidence | Where-Object { $_ }).Count) { throw 'Resolution requires Result and Evidence.' }
    } elseif (-not $DecisionSource -or -not $Scope) { throw 'Triage requires the actual user DecisionSource and bounded Scope.' }
    $inbox=Get-HarnessFeedbackInbox $Context -Limit 1000
    if ($inbox.Issues.Count -or $inbox.Truncated) { throw 'Resolve feedback read issues before triage.' }
    $known=@{}
    foreach ($group in $inbox.Groups) { foreach ($item in $group.Occurrences) { $known[$item.ObservationId]=$item } }
    $selected=@(foreach ($id in @($ObservationIds | Sort-Object -Unique)) {
        if (-not $known.ContainsKey($id)) { throw "Unknown observation: $id" }
        $item=$known[$id]
        if ($item.Historical -or $item.Archived) { throw 'Historical or archived feedback is read-only; select an active topic draft with the actual source for further work.' }
        if ($Disposition -eq 'resolved' -and ($null -eq $item.Disposition -or $item.Disposition.Status -ne 'selected')) { throw 'Resolution requires a selected scope.' }
        $item
    })
    $paths=@()
    foreach ($group in @($selected | Group-Object Path)) {
        $path=Assert-HarnessFeedbackPath (Get-HarnessFeedbackRoot $Context) $group.Name
        $lock=Enter-HarnessFeedbackLock $path
        try {
            $text=[IO.File]::ReadAllText($path)
            foreach ($item in $group.Group) {
                $fields=$item.Fields
                $fields.Status=$Disposition
                $fields.DecisionSource=if ($Disposition -eq 'resolved') { $item.Disposition.DecisionSource } else { $DecisionSource }
                $fields.SelectedScope=if ($Disposition -eq 'resolved') { $item.Disposition.Scope } else { $Scope }
                $fields.Result=$Result; $fields.Evidence=@($Evidence)
                $pattern='(?ms)^### Observation '+[regex]::Escape($item.ObservationId)+'\r?\n.*?(?=^#{1,3} |\z)'
                $block=ConvertTo-HarnessFeedbackBlock $item.ObservationId $fields
                $current=[regex]::Matches($text,$pattern)
                if ($current.Count -ne 1 -or $current[0].Value -cne $item.Block) { throw 'Draft observation identity or disposition changed during triage.' }
                $text=[regex]::Replace($text,$pattern,[Text.RegularExpressions.MatchEvaluator]{param($match) $block})
            }
            $temporary=$path+'.tmp-'+[guid]::NewGuid().ToString('N')
            try { [IO.File]::WriteAllText($temporary,$text); [IO.File]::Move($temporary,$path,$true) }
            finally { if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) } }
            $paths+=$path
        } finally { $lock.ReleaseMutex(); $lock.Dispose() }
    }
    [pscustomobject]@{Disposition=$Disposition;ObservationIds=@($ObservationIds);Artifacts=@($paths)}
}

Export-ModuleMember -Function Get-HarnessUpdateNotice,Get-HarnessFeedbackInbox,Write-HarnessFeedbackInbox,Set-HarnessEvolutionTriage,Add-HarnessDraftFeedback
