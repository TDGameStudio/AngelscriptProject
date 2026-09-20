#requires -Version 7.0
#requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-HarnessRecordRoot {
    param($Context)
    if ('OpenSpecRoot' -in $Context.PSObject.Properties.Name -and $Context.OpenSpecRoot) { return [string]$Context.OpenSpecRoot }
    return [string]$Context.WorkspaceRoot
}

function Assert-ChangeId {
    param([string]$ChangeId)
    if ($ChangeId -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*/(?:feature|fix|refactor|improve|docs|test|chore)-[a-z0-9]+(?:-[a-z0-9]+){1,}$') {
        throw "Change ID '$ChangeId' must be <domain>/<type>-<scope>-<outcome>."
    }
}

function Get-ChangeRoot {
    param($Context, [string]$ChangeId)
    if ($ChangeId -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw "Change ID '$ChangeId' is not a safe canonical path."
    }
    $root = [System.IO.Path]::GetFullPath((Join-Path ((Get-HarnessRecordRoot $Context)) ('openspec/changes/' + $ChangeId)))
    $base = [System.IO.Path]::GetFullPath((Join-Path ((Get-HarnessRecordRoot $Context)) 'openspec/changes'))
    if (-not $root.StartsWith(($base + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Change path escapes the selected workspace.'
    }
    $cursor = $base
    foreach ($part in @($root.Substring($base.Length).TrimStart('\', '/') -split '[\\/]')) {
        if (-not $part) { continue }
        $cursor = Join-Path $cursor $part
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Change path contains a reparse point: $cursor"
        }
    }
    return $root
}

function Get-ChangeMarker {
    param($Context, [string]$ChangeId, [switch]$Required)
    $root = Get-ChangeRoot $Context $ChangeId
    if (-not (Test-Path -LiteralPath (Join-Path $root 'change.yaml') -PathType Leaf)) { throw "Change '$ChangeId' does not exist." }
    $path = Join-Path $root 'attachments/data/harness-origin.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        if ($Required) { throw "Change '$ChangeId' has no Harness creation marker." }
        $exemptionsPath = Join-Path ([string]$Context.HarnessRoot) '.agents/skills/harness/scripts/legacy-change-plan-exemptions.json'
        if (Test-Path -LiteralPath $exemptionsPath -PathType Leaf) {
            $exemptions = Get-Content -LiteralPath $exemptionsPath -Raw | ConvertFrom-Json
            if ($exemptions.schema -ne 1 -or $ChangeId -cnotin @($exemptions.activeChangeIds)) {
                throw "Unmarked Change '$ChangeId' is not in the pre-gate active Change snapshot. Restore its origin marker before planning."
            }
        }
        return $null
    }
    $marker = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($marker.schema -notin @(1, 2, 3) -or $marker.changeId -cne $ChangeId -or $marker.origin -notin @('Draft', 'Direct')) {
        throw "Change '$ChangeId' has an invalid Harness creation marker."
    }
    return $marker
}

function Get-HarnessChangeFilePath {
    param([string]$Base, [string]$Relative)
    $basePath = [IO.Path]::GetFullPath($Base).TrimEnd('\', '/')
    $path = [IO.Path]::GetFullPath((Join-Path $basePath $Relative))
    if (-not $path.StartsWith(($basePath + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) { throw 'Creation record path escapes its owner.' }
    $cursor = $basePath
    foreach ($part in @('') + @($path.Substring($basePath.Length).TrimStart('\', '/') -split '[\\/]')) {
        if ($part) { $cursor = Join-Path $cursor $part }
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Creation record path contains a reparse point: $cursor" }
    }
    return $path
}

function Get-HarnessChangeIntentPath {
    param($Context, [string]$ChangeId)
    $owner = [IO.Path]::GetFullPath((Get-HarnessRecordRoot $Context)).TrimEnd('\', '/').ToLowerInvariant()
    $key = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($owner + '|' + $ChangeId))).ToLowerInvariant()
    return Get-HarnessChangeFilePath (Get-HarnessRecordRoot $Context) ('Saved/Harness/ChangeCreates/' + $key + '.json')
}

function Write-HarnessChangeJson {
    param([string]$Path, $Value, [switch]$NoOverwrite)
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path))
    $temporary = $Path + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($temporary, (($Value | ConvertTo-Json -Depth 20) + "`n"), [Text.UTF8Encoding]::new($false))
        [IO.File]::Move($temporary, $Path, (-not $NoOverwrite))
    }
    finally { if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) } }
}

function Write-HarnessChangeMarker {
    param([string]$Root, $Marker)
    $path = Get-HarnessChangeFilePath $Root 'attachments/data/harness-origin.json'
    Write-HarnessChangeJson -Path $path -Value $Marker -NoOverwrite
}

function Get-HarnessCreatedManifest {
    param([string]$Root, [string]$ChangeId)
    $path = Get-HarnessChangeFilePath $Root 'change.yaml'
    if (-not [IO.File]::Exists($path)) { throw 'CreationRecoveryRequired: native creation has no expected manifest.' }
    $content = [IO.File]::ReadAllText($path)
    $ids = [regex]::Matches($content, '(?m)^  id: ([a-z0-9/-]+)\s*$')
    $uids = [regex]::Matches($content, '(?m)^  uid: (change_[a-zA-Z0-9-]+)\s*$')
    if ($ids.Count -ne 1 -or $ids[0].Groups[1].Value -cne $ChangeId -or $uids.Count -ne 1) { throw 'CreationRecoveryRequired: native manifest identity cannot be proven.' }
    return @{uid=$uids[0].Groups[1].Value;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash}
}

function Set-HarnessChangeCreatedCheckpoint {
    param([string]$Path, $Intent, [string]$Root)
    $Intent.manifest = Get-HarnessCreatedManifest $Root $Intent.changeId
    $Intent.state = 'created'
    Write-HarnessChangeJson $Path $Intent
}

function Assert-HarnessChangeIntent {
    param($Intent, [string]$ChangeId, [string]$RequestHash, [string]$Owner, [string]$Workspace, $Gate)
    if ($Intent.schema -ne 1 -or $Intent.changeId -cne $ChangeId -or $Intent.requestHash -cne $RequestHash -or $Intent.owner -ne $Owner -or $Intent.workspace -ne $Workspace -or $Intent.state -notin @('prepared','created') -or $Intent.marker.schema -ne 3 -or $Intent.marker.changeId -cne $ChangeId -or $Intent.marker.gate.operation -cne 'create' -or $Intent.marker.gate.target_change -cne $ChangeId -or $Intent.followup.handoff_id -cne $Intent.marker.gate.handoff_id) {
        throw 'CreationRecoveryRequired: private creation intent does not match this exact request and owner.'
    }
    if ($Gate) {
        foreach ($pair in @(@('ConvergenceSource','convergence_source'),@('DecisionSource','decision_source'),@('Decision','decision'),@('TargetChange','target_change'),@('HandoffRevision','revision'))) {
            if ($Gate[$pair[0]] -cne $Intent.marker.gate[$pair[1]]) { throw 'CreationRecoveryRequired: retry cannot replace the already consumed Gate.' }
        }
    }
}

function Complete-HarnessCreatedPlan {
    param($Context,[string]$Root,[string]$IntentPath,$Intent)
    $plan=$Intent.planning
    if ($plan.stage -eq 'complete') { return $plan.commit }
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/git-operations/scripts/GitOperations.psd1')
    $recordRoot=Get-HarnessRecordRoot $Context
    function Read-PlanningGit([string[]]$Arguments) {
        $output=@(& git -C $recordRoot @Arguments 2>&1)
        if ($LASTEXITCODE) { throw ($output -join "`n") }
        return ($output -join "`n").Trim()
    }
    if ((Read-PlanningGit @('symbolic-ref','--short','HEAD')) -cne $plan.validation.GitPlan.Branch) { throw 'Planning commit branch changed; inspect the saved operation.' }
    $head=Read-PlanningGit @('rev-parse','HEAD')
    if ($head -cne $plan.validation.GitPlan.BaselineHead) {
        if ($plan.ContainsKey('attempt') -and $head -cne $plan.attempt.Head -and
            (Read-PlanningGit @('rev-parse','HEAD^')) -ceq $plan.attempt.Head -and
            (Read-PlanningGit @('rev-parse','HEAD^{tree}')) -ceq $plan.attempt.Tree) {
            $plan.stage='complete'; $plan.commit=$head; Write-HarnessChangeJson $IntentPath $Intent; return $head
        }
        throw 'Planning baseline changed outside the saved commit attempt; do not absorb other work.'
    }
    if ($plan.ContainsKey('outputs')) {
        foreach ($relative in $plan.outputs.Keys) {
            $path=Get-HarnessChangeFilePath $Root $relative
            if (-not [IO.File]::Exists($path) -or (Get-FileHash $path -Algorithm SHA256).Hash -ine $plan.outputs[$relative]) { throw "Planning recovery conflicts with an external edit: $relative" }
        }
    }
    foreach ($relative in $plan.candidates.Keys) {
        $path=Get-HarnessChangeFilePath $Root $relative
        if ([IO.File]::Exists($path) -and [IO.File]::ReadAllText($path) -cne $plan.candidates[$relative]) { throw "Accepted planning candidate conflicts with existing content: $relative" }
        [void][IO.Directory]::CreateDirectory((Split-Path $path))
        [IO.File]::WriteAllText($path,$plan.candidates[$relative],[Text.UTF8Encoding]::new($false))
    }
    foreach ($export in $plan.validation.BinaryExports) {
        $path=Get-HarnessChangeFilePath $Root $export.Target
        if ([IO.File]::Exists($path)) {
            if ((Get-FileHash $path -Algorithm SHA256).Hash -ine $export.Sha256) { throw 'Accepted binary export changed.' }
        } else {
            if ((Get-FileHash -LiteralPath $export.Source -Algorithm SHA256).Hash -ine $export.Sha256) { throw 'Binary export source changed after approval.' }
            [void][IO.Directory]::CreateDirectory((Split-Path $path)); [IO.File]::WriteAllBytes($path,[IO.File]::ReadAllBytes($export.Source))
        }
    }
    $indexPath=Get-HarnessChangeFilePath $Root 'attachments/INDEX.md'
    $index=[IO.File]::ReadAllText($indexPath)
    foreach ($file in @(Get-ChildItem -LiteralPath (Join-Path $Root 'attachments') -Recurse -File)) {
        if ($file.FullName -eq $indexPath) { continue }
        $relative=[IO.Path]::GetRelativePath((Join-Path $Root 'attachments'),$file.FullName).Replace('\','/')
        if (-not $index.Contains($relative)) { $index += "`n- $relative — accepted complete planning; read for its owned design or proof.`n" }
    }
    [IO.File]::WriteAllText($indexPath,$index,[Text.UTF8Encoding]::new($false))
    $allowed=@('change.yaml','attachments/INDEX.md','attachments/data/harness-origin.json',('attachments/talks/'+$Intent.followup.talk_id+'.md')) + @($plan.candidates.Keys) + @($plan.validation.BinaryExports | ForEach-Object Target)
    $outputs=@{}
    foreach ($file in @(Get-ChildItem -LiteralPath $Root -Recurse -File)) {
        $relative=[IO.Path]::GetRelativePath($Root,$file.FullName).Replace('\','/')
        [void](Get-HarnessChangeFilePath $Root $relative)
        if ($relative -cnotin $allowed) { throw "Unapproved file in new Change Git selection: $relative" }
        $outputs[$relative]=(Get-FileHash $file.FullName -Algorithm SHA256).Hash
    }
    $plan.outputs=$outputs; $plan.stage='materialized'; Write-HarnessChangeJson $IntentPath $Intent
    [void](Test-HarnessChangeSeed $Context $Intent.changeId)
    [void](Test-HarnessChangePlan $Context $Intent.changeId)
    $strict=Invoke-Harness -Context $Context -Command openspec.validate -ArgumentList @($Intent.changeId,'--type','change','--strict','--json')
    if ($strict.status -ne 'Succeeded') { throw "Created plan strict validation failed: $($strict.error.message)" }
    $plan.stage='verified'; Write-HarnessChangeJson $IntentPath $Intent
    $gitArgs=@{WorkspaceRoot=$recordRoot;RepositoryScopes=@{'.'=@('openspec/changes/'+$Intent.changeId)};PreserveOutsideStaged=$true;CommitMessage=$plan.validation.GitPlan.CommitMessage}
    $gitPreview=Complete-HarnessGitCommit @gitArgs -WhatIf
    if (@($gitPreview.IncludedChanges).Count -ne 1) { throw 'The expected uncommitted planning candidate disappeared.' }
    $plan.attempt=@{Head=$head;Tree=$gitPreview.IncludedChanges[0].CandidateTree;Revision=$gitPreview.PlanRevision}
    Write-HarnessChangeJson $IntentPath $Intent
    $result=Complete-HarnessGitCommit @gitArgs -ExpectedPlanRevision $gitPreview.PlanRevision
    if (@($result.Commits).Count -ne 1 -or -not $result.ScopedGitStateComplete) { throw 'Planning commit did not complete its exact scope.' }
    $plan.stage='complete'; $plan.commit=$result.Commits[0].Commit; Write-HarnessChangeJson $IntentPath $Intent
    return $plan.commit
}

function Invoke-HarnessChangeCreateCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$ChangeId,
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Goal,
        [Parameter(Mandatory = $true)][ValidateSet('Draft', 'Direct')][string]$Origin,
        [string]$DraftId = '', [string]$Scope = '', [string]$Reason = '',
        [switch]$PlanOnly, [hashtable]$Gate, [string]$HandoffText='', [string]$SessionId='',
        [hashtable]$Candidates=@{}, [hashtable]$GitPlan=@{}
    )
    Assert-ChangeId $ChangeId
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1') -ErrorAction Stop
    $root = Get-ChangeRoot $Context $ChangeId
    $intentPath = Get-HarnessChangeIntentPath $Context $ChangeId
    $owner = [IO.Path]::GetFullPath((Get-HarnessRecordRoot $Context)).TrimEnd('\','/')
    $workspace = [IO.Path]::GetFullPath([string]$Context.WorkspaceRoot).TrimEnd('\','/')
    $request = [ordered]@{changeId=$ChangeId;title=$Title;goal=$Goal;origin=$Origin;draftId=$DraftId;scope=$Scope;reason=$Reason;handoffText=$HandoffText}
    if ($Candidates.Count) {
        $request.candidates=@(foreach ($key in @($Candidates.Keys | Sort-Object)) { $key+':'+[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes([string]$Candidates[$key]))) })
        $request.gitPlan=@{message=$GitPlan['CommitMessage'];scopes=$GitPlan['RepositoryScopes']}
    }
    $requestHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(($request | ConvertTo-Json -Depth 12 -Compress)))).ToLowerInvariant()
    $intent = $null
    if (Test-Path -LiteralPath $intentPath) {
        try {
            $intent = Get-Content -LiteralPath $intentPath -Raw | ConvertFrom-Json -AsHashtable
            Assert-HarnessChangeIntent $intent $ChangeId $requestHash $owner $workspace $Gate
        }
        catch { throw "CreationRecoveryRequired: stored creation intent could not be validated. $($_.Exception.Message)" }
    }
    if (Test-Path -LiteralPath $root) {
        $markerPath = Get-HarnessChangeFilePath $root 'attachments/data/harness-origin.json'
        if (-not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
            # A prepared intent proves approval, not ownership of an existing native
            # manifest. Only the durable post-success checkpoint may repair a marker.
            if (-not $intent -or $intent.state -ne 'created') { throw 'CreationRecoveryRequired: existing unmarked Change has no proven native-success checkpoint; inspect its ownership before recovery.' }
            $manifest = Get-HarnessCreatedManifest $root $ChangeId
            if ($manifest.uid -cne $intent.manifest.uid -or $manifest.sha256 -cne $intent.manifest.sha256) { throw 'CreationRecoveryRequired: manifest differs from the owned native-success checkpoint.' }
            if ($PlanOnly) { return [pscustomobject]@{ChangeId=$ChangeId;Path=$root;Origin=$Origin;Resumed=$true;RecoveryPending=$true;HandoffId=$intent.marker.gate.handoff_id;HandoffRevision=$intent.marker.gate.revision;Followup=$intent.marker.gate.post_talk_id} }
            Write-HarnessChangeMarker $root $intent.marker
        }
        $existing = Get-ChangeMarker -Context $Context -ChangeId $ChangeId -Required
        if ($existing.schema -ne 3 -or $existing.origin -ne $Origin -or ($Origin -eq 'Draft' -and ($existing.draftId -ne $DraftId -or $existing.scope -ne $Scope))) { throw "Change '$ChangeId' already exists with a different creation identity; resume its accepted plan." }
        if ($intent -and $existing.gate.handoff_id -cne $intent.marker.gate.handoff_id) { throw 'CreationRecoveryRequired: existing origin differs from the stored receipt.' }
        if (-not $PlanOnly) {
            [void](Invoke-HarnessHandoff -Context $Context -Action restore-followup -Parameters @{ChangeId=$ChangeId})
            if ($intent -and -not $intent.ContainsKey('planning')) { [IO.File]::Delete($intentPath) }
        }
        $resumed=[pscustomobject]@{ChangeId=$ChangeId;Path=$root;Origin=$Origin;Resumed=$true;HandoffId=$existing.gate.handoff_id;HandoffRevision=$existing.gate.revision;Followup=$existing.gate.post_talk_id}
        if ($intent -and $intent.ContainsKey('planning')) {
            if (-not $PlanOnly) { $commit=Complete-HarnessCreatedPlan $Context $root $intentPath $intent; $resumed | Add-Member PlanningCommit $commit }
            $resumed | Add-Member PlanningStage $intent.planning.stage
        }
        return $resumed
    }
    if ($intent -and $intent.state -eq 'created') { throw 'CreationRecoveryRequired: the owned native manifest has disappeared; do not create a replacement identity.' }
    if ($Origin -eq 'Draft') {
        if (-not $DraftId -or -not $Scope) { throw 'Draft creation requires DraftId and Scope.' }
        Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1') -ErrorAction Stop
        $draft = Test-HarnessDraft -Context $Context -DraftId $DraftId -Scope $Scope -ChangeId $ChangeId
    }
    else {
        if ([string]::IsNullOrWhiteSpace($Reason)) { throw 'Direct Change creation requires the reason for skipping a draft.' }
        if ($DraftId -or $Scope) { throw 'Direct Change creation cannot claim a draft scope.' }
    }
    $handoffParameters = @{ChangeId=$ChangeId;Title=$Title;Goal=$Goal;Origin=$Origin;DraftId=$DraftId;Scope=$Scope;Reason=$Reason;HandoffText=$HandoffText;SessionId=$SessionId;Gate=$Gate}
    $planningValidation=$null
    if ($Candidates.Count) {
        $planningValidation=Invoke-HarnessHandoff -Context $Context -Action create-plan -Parameters ($handoffParameters+@{Candidates=$Candidates;GitPlan=$GitPlan})
        $handoffParameters.Candidates=$Candidates; $handoffParameters.GitPlan=$planningValidation.GitPlan
    }
    $previewAction = if ($intent -and -not $intent.marker.gate.ContainsKey('revision_schema')) { 'create-preview-legacy' } else { 'create-preview' }
    $prepared = Invoke-HarnessHandoff -Context $Context -Action $previewAction -Parameters $handoffParameters
    if ($intent -and $intent.marker.gate.revision -cne $prepared.HandoffRevision) { throw 'CreationRecoveryRequired: accepted design changed before native creation; resolve the saved approval before creating.' }
    if ($PlanOnly) { if ($planningValidation) { $prepared | Add-Member Planning $planningValidation }; return $prepared }
    $exe = Join-Path ([string]$Context.HarnessRoot) '.agents/skills/openspec/bin/openspec.exe'
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw "Portable OpenSpec CLI is missing: $exe" }
    if (-not $intent) {
        $accepted = Invoke-HarnessHandoff -Context $Context -Action create-receipt -Parameters $handoffParameters
        $marker = [ordered]@{
            schema = 3; changeId = $ChangeId; origin = $Origin
            draftId = if ($Origin -eq 'Draft') { $DraftId } else { $null }
            scope = if ($Origin -eq 'Draft') { $Scope } else { $null }
            reason = if ($Origin -eq 'Direct') { $Reason } else { $null }
            approvalRound = if ($Origin -eq 'Draft') { $draft.ApprovalRound } else { $null }
            exportDigestSchema = $accepted.receipt.export_digest_schema
            expectedExports = @($accepted.receipt.expected_exports)
            gate = $accepted.receipt
            createdAt = [DateTime]::UtcNow.ToString('o')
        }
        $intent = @{schema=1;changeId=$ChangeId;owner=$owner;workspace=$workspace;requestHash=$requestHash;state='prepared';manifest=$null;marker=$marker;followup=$accepted.followup}
        if ($planningValidation) {
            $intent.planning=@{stage='prepared';candidates=$Candidates;validation=$planningValidation | ConvertTo-Json -Depth 30 | ConvertFrom-Json -AsHashtable}
            $marker.completePlanning=$true
        }
        Write-HarnessChangeJson -Path $intentPath -Value $intent -NoOverwrite
    }
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        Push-Location -LiteralPath (Get-HarnessRecordRoot $Context)
        try {
            $output = @(& $exe change create $ChangeId --title $Title --goal $Goal --json 2>&1)
            $exitCode = $LASTEXITCODE
        }
        finally { Pop-Location }
    }
    finally { $ErrorActionPreference = $oldPreference }
    if ($exitCode -ne 0) { throw "OpenSpec change create failed ($exitCode): $($output -join ' ')" }
    Set-HarnessChangeCreatedCheckpoint $intentPath $intent $root
    $markerPath = Join-Path $root 'attachments/data/harness-origin.json'
    Write-HarnessChangeMarker $root $intent.marker
    [void](Invoke-HarnessHandoff -Context $Context -Action write-followup -Parameters @{ChangeId=$ChangeId;Followup=$intent.followup})
    $result=[pscustomobject]@{ ChangeId = $ChangeId; Path = $root; Origin = $Origin; Marker = $markerPath; HandoffId=$intent.marker.gate.handoff_id; Followup=$intent.marker.gate.post_talk_id }
    if ($intent.ContainsKey('planning')) {
        $commit=Complete-HarnessCreatedPlan $Context $root $intentPath $intent
        $result | Add-Member PlanningCommit $commit
        $result | Add-Member PlanningStage $intent.planning.stage
    } else { [IO.File]::Delete($intentPath) }
    return $result
}

function New-HarnessChange {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$ChangeId,
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Goal,
        [Parameter(Mandatory = $true)][ValidateSet('Draft', 'Direct')][string]$Origin,
        [string]$DraftId = '', [string]$Scope = '', [string]$Reason = '',
        [switch]$PlanOnly, [hashtable]$Gate, [string]$HandoffText='', [string]$SessionId='',
        [hashtable]$Candidates=@{}, [hashtable]$GitPlan=@{}
    )
    Assert-ChangeId $ChangeId
    if (-not $Candidates.Count -and -not (Test-Path -LiteralPath (Get-ChangeRoot $Context $ChangeId)) -and
        -not (Test-Path -LiteralPath (Get-HarnessChangeIntentPath $Context $ChangeId))) {
        throw 'New Change creation requires complete Candidates and an exact GitPlan before its Gate.'
    }
    if ($PlanOnly) { return Invoke-HarnessChangeCreateCore @PSBoundParameters }
    # Serialize the same canonical target across Harness processes. The durable
    # intent carries recovery evidence; the mutex is only a short creation lock.
    $key = [IO.Path]::GetFileNameWithoutExtension((Get-HarnessChangeIntentPath $Context $ChangeId))
    $mutex = [Threading.Mutex]::new($false, ('HarnessChangeCreate-' + $key))
    $held = $false
    try {
        try { $held = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $held = $true }
        if (-not $held) { throw 'CreationBusy: another Harness process owns this exact creation; inspect and retry after it finishes.' }
        return Invoke-HarnessChangeCreateCore @PSBoundParameters
    }
    finally { if ($held) { $mutex.ReleaseMutex() }; $mutex.Dispose() }
}

function Get-LocalMarkdownTargets {
    param([string]$File, [string]$Root)
    $content = [System.IO.File]::ReadAllText($File)
    foreach ($match in [regex]::Matches($content, '\]\((?<target>[^)]+)\)')) {
        $value = $match.Groups['target'].Value
        if ($value -match '^(?:https?:|mailto:|#)') { continue }
        if ($value -match 'openspec[/\\]drafts[/\\]') { throw "Change link in '$File' depends on local draft content: $value" }
        $relative = ($value -split '#', 2)[0]
        if (-not $relative) { continue }
        $target = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $File -Parent) $relative))
        if (-not $target.StartsWith(($Root + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Change link in '$File' escapes the Change: $value"
        }
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Change link in '$File' is missing: $value" }
        $item = Get-Item -LiteralPath $target
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Change link resolves through a reparse point: $value" }
        $target
    }
}

function Test-HarnessChangeSeed {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$ChangeId)
    $marker = Get-ChangeMarker $Context $ChangeId -Required
    $root = Get-ChangeRoot $Context $ChangeId
    if ($marker.schema -eq 3) {
        Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1') -ErrorAction Stop
        $handoff = Invoke-HarnessHandoff -Context $Context -Action status -Parameters @{Change=$ChangeId}
        if (@($handoff.issues).Count) { throw "Handoff evidence is incomplete: $($handoff.issues -join '; ')" }
    }
    if ($marker.origin -eq 'Direct') {
        if ([string]::IsNullOrWhiteSpace([string]$marker.reason)) { throw 'Direct Change marker has no skipped-draft reason.' }
        return [pscustomobject]@{ ChangeId = $ChangeId; Origin = 'Direct'; Seeded = $true }
    }
    $indexPath = Join-Path $root 'attachments/INDEX.md'
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) { throw 'Draft Change needs attachments/INDEX.md before planning.' }
    $requiredExports = @('attachments/drafts/design.md', 'attachments/drafts/handoff.md')
    if ($marker.schema -lt 3) { $requiredExports += 'attachments/drafts/glossary.md' }
    foreach ($relative in $requiredExports) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw "Draft export is missing '$relative'." }
    }
    $exportedHandoff = [System.IO.File]::ReadAllText((Join-Path $root 'attachments/drafts/handoff.md'))
    if ($exportedHandoff -notmatch [regex]::Escape($ChangeId)) { throw 'Exported handoff does not name this Change.' }
    if ($marker.schema -ge 2) {
        if (($marker.schema -eq 2 -and $marker.approvalRound -cnotmatch '^R[0-9]+$') -or -not $marker.scope -or -not $marker.draftId) { throw 'Draft marker has incomplete approval identity.' }
        foreach ($field in @(@('Scope', $marker.scope), @('Target Change', $ChangeId))) {
            $entries = [regex]::Matches($exportedHandoff, ('(?m)^- {0}:\s*`?(?<value>[^`\r\n]+)`?\s*$' -f [regex]::Escape($field[0])))
            if ($entries.Count -ne 1 -or $entries[0].Groups['value'].Value.Trim() -cne $field[1]) { throw 'Exported handoff identity differs from its creation marker.' }
        }
        $targets = @($marker.expectedExports | ForEach-Object { [string]$_.Target })
        foreach ($required in $requiredExports) {
            if ($required -cnotin $targets) { throw "Origin marker is missing expected export: $required" }
        }
        foreach ($target in $targets) {
            if ($target -cnotmatch '^attachments/(?:drafts|talks|knowledges|data)/[a-zA-Z0-9_./-]+$' -or '..' -in ($target -split '/') -or @($targets | Where-Object { $_ -ceq $target }).Count -ne 1) { throw "Invalid or duplicate expected export: $target" }
            if (-not (Test-Path -LiteralPath (Join-Path $root $target) -PathType Leaf)) { throw "Promised export is missing: $target" }
        }
        if ('exportDigestSchema' -in $marker.PSObject.Properties.Name) {
            if ($marker.exportDigestSchema -ne 1) { throw 'Unsupported export digest schema.' }
            foreach ($export in $marker.expectedExports) {
                if ('Preservation' -notin $export.PSObject.Properties.Name -or $export.Preservation -notin @('bytes','translated-text')) { throw 'Export is missing its preservation contract.' }
                if ($export.Preservation -eq 'bytes') {
                    if ('Sha256' -notin $export.PSObject.Properties.Name -or $export.Sha256 -cnotmatch '^[0-9a-f]{64}$') { throw "Export is missing its accepted SHA256: $($export.Target)" }
                    $exportPath = Get-HarnessChangeFilePath $root $export.Target
                    if ((Get-FileHash -LiteralPath $exportPath -Algorithm SHA256).Hash -ine $export.Sha256) { throw "Export bytes differ from the accepted handoff: $($export.Target)" }
                }
            }
        }
    }
    $index = [System.IO.File]::ReadAllText($indexPath)
    $attachmentRoot = Join-Path $root 'attachments'
    $files = @(Get-ChildItem -LiteralPath $attachmentRoot -File -Recurse | Where-Object { $_.FullName -ne $indexPath })
    foreach ($file in $files) {
        $relative = [System.IO.Path]::GetRelativePath($attachmentRoot, $file.FullName).Replace('\', '/')
        $indexCount = [regex]::Matches($index, ('(?:\]\(|(?m)^- ){0}(?:\)|\s+—)' -f [regex]::Escape($relative))).Count
        if ($indexCount -ne 1) { throw "Attachment '$relative' must be indexed exactly once (actual $indexCount)." }
        if ($file.Extension -eq '.md') { [void]@(Get-LocalMarkdownTargets -File $file.FullName -Root $root) }
    }
    [void]@(Get-LocalMarkdownTargets -File $indexPath -Root $root)
    return [pscustomobject]@{ ChangeId = $ChangeId; Origin = 'Draft'; Seeded = $true; Indexed = $files.Count }
}

function Test-HarnessChangePlan {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$ChangeId)
    $marker = Get-ChangeMarker $Context $ChangeId
    if ($null -eq $marker) { return [pscustomobject]@{ ChangeId = $ChangeId; Grandfathered = $true } }
    [void](Test-HarnessChangeSeed -Context $Context -ChangeId $ChangeId)
    $root = Get-ChangeRoot $Context $ChangeId
    $path = Join-Path $root 'design.md'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "New Change '$ChangeId' needs its own design.md before tasks are Ready." }
    $text = [System.IO.File]::ReadAllText($path)
    $heading = [regex]::Match($text, '(?m)^## Call chains\s*$')
    if (-not $heading.Success) { throw "New Change '$ChangeId' design.md needs a '## Call chains' section." }
    $body = [regex]::Split($text.Substring($heading.Index + $heading.Length), '(?m)^## ')[0].Trim()
    if ($body -match '(?im)^none\b') {
        if ($body -notmatch '(?im)^none\s*[-—:]\s*\S+') { throw 'Non-code call chains need none and a concrete reason.' }
    }
    elseif ($body -notmatch '(?:->|→)' -or $body -notmatch '(?im)^Measured at:.*\b[0-9a-f]{7,40}\b' -or $body -notmatch '(?i)dirty\s*:') {
        throw 'Code call chains need a caller-to-callee path, Measured at with a Git SHA, and a dirty-path note.'
    }
    [void]@(Get-LocalMarkdownTargets -File $path -Root $root)
    return [pscustomobject]@{ ChangeId = $ChangeId; Origin = $marker.origin; Design = $path; Valid = $true }
}

function Test-HarnessChangeSeedIfNeeded {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$ChangeId)
    $marker = Get-ChangeMarker $Context $ChangeId
    if ($null -eq $marker) { return [pscustomobject]@{ ChangeId = $ChangeId; Grandfathered = $true } }
    return Test-HarnessChangeSeed -Context $Context -ChangeId $ChangeId
}

Export-ModuleMember -Function New-HarnessChange, Test-HarnessChangeSeed, Test-HarnessChangePlan, Test-HarnessChangeSeedIfNeeded
