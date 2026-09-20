#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

function ConvertTo-ClosureCanonical($Value) {
    if ($null -eq $Value) { return $null }
    # PowerShell pipeline strings can also satisfy -is [pscustomobject]. Keep
    # scalar values scalar before considering structured object conversion.
    if ($Value -is [string] -or $Value -is [ValueType]) { return $Value }
    if ($Value -is [Collections.IDictionary]) {
        $result=[ordered]@{}; $keys=[string[]]@($Value.Keys); [Array]::Sort($keys,[StringComparer]::Ordinal)
        foreach ($key in $keys) { $result[$key]=ConvertTo-ClosureCanonical $Value[$key] }
        return $result
    }
    if ($Value -is [pscustomobject]) { return ConvertTo-ClosureCanonical ($Value | ConvertTo-Json -Depth 80 | ConvertFrom-Json -AsHashtable) }
    if ($Value -is [Collections.IEnumerable] -and $Value -isnot [string]) { return ,@(foreach ($item in $Value) { ConvertTo-ClosureCanonical $item }) }
    return $Value
}
function Get-ClosureHash($Value) {
    $bytes=[Text.Encoding]::UTF8.GetBytes(((ConvertTo-ClosureCanonical $Value) | ConvertTo-Json -Depth 80 -Compress))
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}
function Get-ClosurePath([string]$Root,[string]$Relative) {
    $base=[IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $path=[IO.Path]::GetFullPath((Join-Path $base $Relative))
    if (-not $path.StartsWith($base+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Closure path escapes its owning root.' }
    $cursor=$path
    while ($cursor -and $cursor.Length -ge $base.Length) {
        $item=Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Closure path contains a reparse point.' }
        $cursor=Split-Path $cursor
    }
    return $path
}
function Write-ClosureState($Path,$Value) {
    [void][IO.Directory]::CreateDirectory((Split-Path $Path))
    $temp=$Path+'.'+[guid]::NewGuid().ToString('N')+'.tmp'
    try { [IO.File]::WriteAllText($temp,($Value | ConvertTo-Json -Depth 80),[Text.UTF8Encoding]::new($false)); [IO.File]::Move($temp,$Path,$true) }
    finally { if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) } }
}
function Read-ClosureGit([string]$Root,[string[]]$Arguments) {
    $output=@(& git -C $Root @Arguments 2>&1)
    if ($LASTEXITCODE) { throw ($output -join "`n") }
    return ($output -join "`n").Trim()
}
function Invoke-ClosureRoute($Context,$Command,$Parameters=@{},$Arguments=@()) {
    $r=Invoke-Harness -Context $Context -Command $Command -Parameters $Parameters -ArgumentList $Arguments
    if ($r.status -ne 'Succeeded') { throw "$Command : $($r.error.message) $($r.data | ConvertTo-Json -Depth 8 -Compress)" }
    return $r.data
}
function Get-ClosureFiles($Root) {
    $files=@{}
    foreach ($file in @(Get-ChildItem -LiteralPath $Root -File -Recurse -Force)) {
        $relative=[IO.Path]::GetRelativePath($Root,$file.FullName).Replace('\','/')
        [void](Get-ClosurePath $Root $relative)
        $files[$relative]=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    return $files
}
function Set-ClosureGeneratedFile($State,$Root,$Relative,$Text) {
    if (-not $State.ContainsKey('generated')) { $State.generated=@{} }
    $path=Get-ClosurePath $Root $Relative
    if (-not $State.generated.ContainsKey($Relative)) {
        $before=if (Test-Path -LiteralPath $path) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) } else { $null }
        $State.generated[$Relative]=@{before=$before;after=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Text))}
        Write-ClosureState $State.path $State
    }
    $entry=$State.generated[$Relative]
    $actual=if (Test-Path -LiteralPath $path) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) } else { $null }
    if ($actual -cne $entry.before -and $actual -cne $entry.after) { throw "Closure generated output conflicts with an external edit: $Relative" }
    [void][IO.Directory]::CreateDirectory((Split-Path $path))
    [IO.File]::WriteAllBytes($path,[Convert]::FromBase64String($entry.after))
}
function Assert-ClosureMetadataInputs($State,$Root) {
    $current=Get-ClosureFiles $Root
    foreach ($name in @($current.Keys)+@($State.files.Keys) | Sort-Object -Unique) {
        if ($name -eq 'attachments/data/harness-execution.json') { continue } # Recomputed only by the queue source-identity owner.
        if ($State.ContainsKey('generated') -and $State.generated.ContainsKey($name)) {
            $entry=$State.generated[$name]
            $actual=if (Test-Path -LiteralPath (Join-Path $Root $name)) { [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $Root $name))) } else { $null }
            if ($actual -ceq $entry.before -or $actual -ceq $entry.after) { continue }
        } elseif ($current.ContainsKey($name) -and $State.files.ContainsKey($name) -and $current[$name] -ceq $State.files[$name]) { continue }
        throw "Close record content changed outside its declared generated outputs: $name"
    }
}
function Assert-ClosureExecution($Context,$ChangeId,$SessionId) {
    $run=Invoke-ClosureRoute $Context harness.execution.status @{SessionId=$SessionId}
    if ($run.change -cne $ChangeId -or $run.state -ne 'running' -or @($run.pendingInputs).Count -or $run.phase -in @('grilling','replanning','handoff-followup')) { throw 'Close requires the exact running authorized Change without pending feedback or decisions.' }
    return $run
}
function Get-ClosureStatePath($Context,$ChangeId) {
    $root=if ($Context.PSObject.Properties['OpenSpecRoot']) { $Context.OpenSpecRoot } else { $Context.WorkspaceRoot }
    $key=Get-ClosureHash @($root.ToLowerInvariant(),$ChangeId)
    return Get-ClosurePath $root ('Saved/Harness/ChangeClosures/'+$key+'.json')
}
function Get-ClosureGitArgs($Root,$Plan,[switch]$PluginsOnly) {
    foreach ($key in $Plan.Keys) { if ($key -notin @('RepositoryScopes','RepositoryPatches','CommitMessage','SubmoduleCommitMessages','TargetBranches')) { throw "Unsupported exact closure Git field: $key" } }
    if (-not $Plan.RepositoryScopes -or -not $Plan.CommitMessage) { throw 'Each closure Git step requires explicit scopes and commit intent.' }
    $args=@{WorkspaceRoot=$Root;PreserveOutsideStaged=$true}
    foreach ($key in $Plan.Keys) { $args[$key]=$Plan[$key] }
    if ($PluginsOnly) { $args.PluginsOnly=$true }
    return $args
}
function Get-ClosureView($State) {
    return [pscustomobject]@{HandoffRevision=$State.revision;Stage=$State.stage;Complete=($State.stage -eq 'complete');
        ArchivePath=$State.archivePath;RecordCommit=$(if ($State.ContainsKey('recordCommit')) { $State.recordCommit } else { $null });
        GitPlan=$State.plan;RecordCandidate=$State.recordPreview;Implementation=$State.steps;Withdrawal=$State.withdrawals;Dispositions=$State.dispositions;OperationPath=$State.path;DerivedOutputs=@('source checkpoint','indexed close receipt','evaluation digest/timestamp refresh','native manifest and archive move','resulting explicitly selected gitlinks')}
}
function Get-ClosureExpectedParent($State) {
    $head=$State.recordBaseline
    foreach ($step in @($State.steps)+@($State.withdrawals)) {
        if ($step.repository -eq '.' -and $step.complete) { $head=$step.commit }
    }
    return $head
}
function New-ClosureWithdrawals($Context,$Steps,$Plan,$Dispositions,$Kind) {
    if ($Kind -eq 'completed') {
        if ($Plan.ContainsKey('Withdrawal')) { throw 'Completed closure cannot withdraw implementation.' }
        return @()
    }
    if (-not $Steps.Count) {
        if (-not $Dispositions.ContainsKey('NoImplementation') -or -not $Dispositions.NoImplementation) { throw 'An incomplete closure without owned code needs an explicit no-implementation disposition.' }
        return @()
    }
    if (-not $Plan.ContainsKey('Withdrawal') -or -not $Dispositions.ContainsKey('WithdrawalVerification') -or
        $Dispositions.WithdrawalVerification.Kind -ne 'baseline' -or -not $Dispositions.WithdrawalVerification.Evidence) { throw 'Incomplete closure needs exact withdrawal patches and a named baseline verification with evidence.' }
    $withdraw=$Plan.Withdrawal
    [void](Get-ClosureGitArgs $Context.WorkspaceRoot $withdraw)
    $results=@()
    foreach ($step in $Steps) {
        $repo=$step.repository
        if (-not $withdraw.RepositoryScopes.ContainsKey($repo) -or -not $withdraw.RepositoryPatches.ContainsKey($repo) -or
            -not $Dispositions.WithdrawalVerification.RepositoryReferences.ContainsKey($repo)) { throw "Every incomplete checkpoint needs its exact withdrawal and baseline proof: $repo" }
        $retained=''
        if ($Dispositions.ContainsKey('Carryover')) {
            if ($Kind -ne 'superseded' -or -not $Dispositions.Carryover.Evidence -or $Dispositions.Carryover.Target -cne $Dispositions.Closure.superseded_by) { throw 'Carryover must name the explained replacement and acceptance evidence.' }
            if ($Dispositions.Carryover.RepositoryPatches.ContainsKey($repo)) { $retained=$Dispositions.Carryover.RepositoryPatches[$repo] }
        }
        $request=@{root=$step.root;tree=$step.tree;patch=$withdraw.RepositoryPatches[$repo];scopes=$withdraw.RepositoryScopes[$repo];ownedScopes=$step.args.RepositoryScopes[$repo];reference=$Dispositions.WithdrawalVerification.RepositoryReferences[$repo];retainedPatch=$retained;kind=$Kind}
        $output=@(($request | ConvertTo-Json -Depth 40 -Compress) | & python -X utf8 (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/closure_withdrawal.py'))
        $code=$LASTEXITCODE; $proof=($output -join "`n") | ConvertFrom-Json -AsHashtable
        if ($code) { throw "Withdrawal preflight failed: $($proof.error)" }
        $single=@{RepositoryScopes=@{$repo=$withdraw.RepositoryScopes[$repo]};RepositoryPatches=@{$repo=$withdraw.RepositoryPatches[$repo]};CommitMessage=$withdraw.CommitMessage}
        foreach ($key in @('SubmoduleCommitMessages','TargetBranches')) { if ($withdraw.ContainsKey($key) -and $withdraw[$key].ContainsKey($repo)) { $single[$key]=@{$repo=$withdraw[$key][$repo]} } }
        $args=Get-ClosureGitArgs $Context.WorkspaceRoot $single -PluginsOnly:($repo -ne '.')
        $results+=@{repository=$repo;root=$step.root;args=$args;tree=$proof.tree;reference=$proof.reference;files=$proof.files;retainedPaths=$proof.retainedPaths;complete=$false}
    }
    if (@($withdraw.RepositoryScopes.Keys).Count -ne $Steps.Count) { throw 'Withdrawal contains a repository outside the shown incomplete checkpoints.' }
    return $results
}
function Complete-ClosureWithdrawal($State,$Step) {
    if ($Step.complete) { return }
    # A previous successful commit may have lost its reply. Let the exact Git
    # journal recover it before trying to mutate any live content again.
    if ($Step.ContainsKey('attempt')) { Complete-ClosureGitStep $State $Step; return }
    $saved=@($State.steps | Where-Object repository -CEQ $Step.repository)[0]
    if ((Read-ClosureGit $Step.root @('rev-parse','HEAD')) -cne $saved.commit) { throw 'Withdrawal requires its saved incomplete checkpoint as HEAD.' }
    foreach ($name in $Step.files.Keys) {
        $path=Get-ClosurePath $Step.root $name; $image=$Step.files[$name]
        $actual=if (Test-Path -LiteralPath $path) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) } else { $null }
        if ($actual -cne $image.before -and $actual -cne $image.after) { throw "Withdrawal conflicts with an external edit: $name" }
    }
    foreach ($name in $Step.files.Keys) {
        $path=Get-ClosurePath $Step.root $name; $image=$Step.files[$name]
        if ($null -eq $image.after) { [IO.File]::Delete($path) }
        else { [void][IO.Directory]::CreateDirectory((Split-Path $path)); [IO.File]::WriteAllBytes($path,[Convert]::FromBase64String($image.after)) }
    }
    $args=$Step.args; $preview=Complete-HarnessGitCommit @args -WhatIf
    if (@($preview.IncludedChanges).Count -ne 1 -or $preview.IncludedChanges[0].CandidateTree -cne $Step.tree) { throw 'Withdrawal proof does not match the exact planned baseline/carryover result.' }
    $Step.baseline=$saved.commit; $Step.revision=$preview.PlanRevision; $Step.verified=$true
    Write-ClosureState $State.path $State
    Complete-ClosureGitStep $State $Step
}
function Complete-ClosureGitStep($State,$Step) {
    if ($Step.complete) { return }
    $root=$Step.root
    $head=Read-ClosureGit $root @('rev-parse','HEAD')
    if ($head -cne $Step.baseline) {
        if ($Step.ContainsKey('attempt') -and (Read-ClosureGit $root @('rev-parse','HEAD^')) -ceq $Step.baseline -and
            (Read-ClosureGit $root @('rev-parse','HEAD^{tree}')) -ceq $Step.tree) {
            $Step.complete=$true; $Step.commit=$head; Write-ClosureState $State.path $State; return
        }
        throw 'Closure Git baseline changed outside its saved attempt.'
    }
    $Step.attempt=$true; Write-ClosureState $State.path $State
    $commitArgs=$Step.args
    $result=Complete-HarnessGitCommit @commitArgs -ExpectedPlanRevision $Step.revision
    if (@($result.Commits).Count -ne 1 -or -not $result.ScopedGitStateComplete) { throw 'Closure Git step did not persist exactly one accepted candidate.' }
    $Step.commit=$result.Commits[0].Commit; $Step.complete=$true; Write-ClosureState $State.path $State
}
function New-ClosureRecordTree($State) {
    $index=Get-ClosurePath $State.workspaceRoot ('Saved/AgentTemp/closure/'+[guid]::NewGuid().ToString('N')+'.index')
    [void][IO.Directory]::CreateDirectory((Split-Path $index))
    $previous=Get-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
    try {
        $env:GIT_INDEX_FILE=$index
        [void](Read-ClosureGit $State.recordRoot @('read-tree',(Get-ClosureExpectedParent $State)))
        if ($State.recordPatch) {
            $patchPath=$index+'.patch'
            [IO.File]::WriteAllText($patchPath,$State.recordPatch,[Text.UTF8Encoding]::new($false))
            [void](Read-ClosureGit $State.recordRoot @('apply','--cached','--whitespace=nowarn',$patchPath))
        }
        [void](Read-ClosureGit $State.recordRoot @('rm','--cached','-r','--ignore-unmatch','--',$State.activeRelative))
        [void](Read-ClosureGit $State.recordRoot @('add','--',$State.archiveRelative))
        foreach ($step in @($State.steps)+@($State.withdrawals)) {
            if ($step.repository -ne '.' -and $step.repository -cin @($State.plan.Records.RepositoryScopes['.'])) {
                [void](Read-ClosureGit $State.recordRoot @('update-index','--add','--cacheinfo',('160000,'+$step.commit+','+$step.repository)))
            }
        }
        return Read-ClosureGit $State.recordRoot @('write-tree')
    } finally {
        if ($previous) { $env:GIT_INDEX_FILE=$previous.Value } else { Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false }
        if ([IO.File]::Exists($index)) { [IO.File]::Delete($index) }
        if ([IO.File]::Exists($index+'.patch')) { [IO.File]::Delete($index+'.patch') }
    }
}
function Assert-HarnessCloseArchive {
    param($Context,[string]$ChangeId,[string]$OperationPath,[byte[]]$ClosureBytes,[string]$InputSha256)
    if (-not $OperationPath -or [IO.Path]::GetFullPath($OperationPath) -ne (Get-ClosureStatePath $Context $ChangeId)) { throw 'Archive requires the exact approved harness.change.close operation.' }
    $state=Get-Content -LiteralPath $OperationPath -Raw | ConvertFrom-Json -AsHashtable
    if ($state.stage -ne 'archive-ready' -or $state.change -cne $ChangeId -or $state.gate.Decision -cne 'close' -or
        $state.gate.HandoffRevision -cne $state.revision -or -not $state.gate.DecisionSource -or
        $state.terminalDigest -cne $InputSha256 -or (Get-ClosureHash ([Text.Encoding]::UTF8.GetString($ClosureBytes))) -cne $state.closureBytesHash) { throw 'Archive decision, content or closure operation stage differs.' }
    [void](Assert-ClosureExecution $Context $ChangeId $state.sessionId)
    $active=Get-ClosurePath $state.recordRoot $state.activeRelative
    if ((Get-ClosureHash (Get-ClosureFiles $active)) -cne (Get-ClosureHash $state.archiveInputs)) { throw 'Archive candidate changed after the terminal checkpoint.' }
}
function Close-HarnessChange {
    [CmdletBinding()]
    param($Context,[string]$ChangeId,[ValidateSet('completed','abandoned','superseded')][string]$ClosureKind,
          [string]$SessionId,[switch]$PlanOnly,[hashtable]$Gate,[hashtable]$GitPlan,[hashtable]$Dispositions)
    if ($ChangeId -cnotmatch '^[a-z0-9-]+/[a-z0-9-]+$' -or -not $SessionId) { throw 'Closure requires an exact Change and session.' }
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/git-operations/scripts/GitOperations.psd1')
    $recordRoot=if ($Context.PSObject.Properties['OpenSpecRoot']) { $Context.OpenSpecRoot } else { $Context.WorkspaceRoot }
    $statePath=Get-ClosureStatePath $Context $ChangeId
    $parts=$ChangeId.Split('/')
    $requestHash=Get-ClosureHash @{change=$ChangeId;kind=$ClosureKind;session=$SessionId;plan=$GitPlan;dispositions=$Dispositions;workspace=$Context.WorkspaceRoot;records=$recordRoot}
    $mutex=[Threading.Mutex]::new($false,('HarnessClosure-'+(Get-ClosureHash @($recordRoot,$ChangeId))))
    $held=$false
    try {
        try { $held=$mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $held=$true }
        if (-not $held) { throw 'This exact closure is busy.' }
        if (Test-Path -LiteralPath $statePath) {
            $state=Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json -AsHashtable
            if ($state.schema -ne 1 -or $state.path -ne $statePath -or $state.recordRoot -ne $recordRoot -or
                $state.workspaceRoot -ne $Context.WorkspaceRoot -or $state.change -cne $ChangeId -or $state.sessionId -cne $SessionId -or
                (Get-ClosureHash $state.plan) -cne (Get-ClosureHash $GitPlan) -or (Get-ClosureHash $state.dispositions) -cne (Get-ClosureHash $Dispositions) -or
                $state.requestHash -cne $requestHash) { throw 'Closure recovery owns another request; inspect the saved exact decision.' }
            if ($Gate -and (Get-ClosureHash $Gate) -cne (Get-ClosureHash $state.gate)) { throw 'Retry cannot replace the consumed close Gate.' }
            if ($PlanOnly -or $state.stage -eq 'complete') { return Get-ClosureView $state }
        } else {
            if (-not $Dispositions.Closure -or $Dispositions.Closure.kind -cne $ClosureKind -or -not $Dispositions.SpecSync -or -not $Dispositions.Verification) { throw 'Explain the exact closure, spec synchronization and verification evidence before its Gate.' }
            foreach ($field in $Dispositions.Closure.Keys) { if ($field -notin @('kind','reason','task_dispositions','superseded_by')) { throw "Unsupported closure disposition: $field" } }
            if ($ClosureKind -ne 'superseded' -and $Dispositions.Closure.ContainsKey('superseded_by')) { throw 'Only superseded closure may name a replacement.' }
            if ($ClosureKind -eq 'completed' -and $Dispositions.Closure.ContainsKey('task_dispositions') -and $Dispositions.Closure.task_dispositions.Count) { throw 'Completed closure cannot dispose of unfinished tasks.' }
            $run=Assert-ClosureExecution $Context $ChangeId $SessionId
            $terminal=Invoke-ClosureRoute $Context harness.evolution.status @{Change=$ChangeId;ClosureKind=$ClosureKind;RequireTerminal=$true}
            [void](Invoke-ClosureRoute $Context openspec.validate @{} @($ChangeId,'--type','change','--strict','--json'))
            $activeRelative='openspec/changes/'+$ChangeId
            $active=Get-ClosurePath $recordRoot $activeRelative
            if ($ClosureKind -ne 'completed') {
                if (-not $Dispositions.Closure.reason -or $Dispositions.SpecSync -notmatch '^(not-synced|not-applicable):') { throw 'Incomplete closure needs an honest reason and cannot promote unfinished contracts as completed specs.' }
                $tasks=Invoke-ClosureRoute $Context task.status @{Change=$ChangeId}
                $unfinished=@($tasks.tasks | Where-Object { -not $_.done } | ForEach-Object id | Sort-Object)
                $dispositionMap=if ($Dispositions.Closure.ContainsKey('task_dispositions')) { $Dispositions.Closure.task_dispositions } else { @{} }
                if ((Get-ClosureHash $unfinished) -cne (Get-ClosureHash @($dispositionMap.Keys | Sort-Object))) { throw 'Incomplete dispositions must exactly identify all unfinished tasks.' }
                foreach ($entry in $dispositionMap.Values) {
                    foreach ($field in $entry.Keys) { if ($field -notin @('status','reason','follow_up')) { throw "Unsupported task disposition: $field" } }
                    if ([string]::IsNullOrWhiteSpace($entry.reason) -or $entry.status -notin @('cancelled','superseded','needs_followup')) { throw 'Every unfinished task requires its actual disposition and reason.' }
                    if ($entry.status -eq 'needs_followup' -and (-not $entry.ContainsKey('follow_up') -or [string]::IsNullOrWhiteSpace($entry.follow_up))) { throw 'A needs_followup disposition requires its actual follow-up reference.' }
                }
                foreach ($scope in $GitPlan.Records.RepositoryScopes['.']) { if ($scope -eq 'openspec' -or $scope -match '^openspec/specs(?:/|$)') { throw 'Incomplete closure cannot include current specification promotion.' } }
                if ($ClosureKind -eq 'superseded') {
                    $replacement=$Dispositions.Closure.superseded_by
                    if (-not $replacement -or $replacement -ceq $ChangeId) { throw 'Superseded closure needs a distinct existing replacement.' }
                    [void](Invoke-ClosureRoute $Context openspec.change @{} @('show',$replacement,'--json'))
                }
            }
            $date=[DateTime]::UtcNow.ToString('yyyy-MM-dd')
            $parts=$ChangeId.Split('/')
            $archiveRelative='openspec/archive/changes/'+$parts[0]+'/'+$date+'-'+$parts[1]
            $archive=Get-ClosurePath $recordRoot $archiveRelative
            if (Test-Path -LiteralPath $archive) { throw 'The deterministic archive destination already exists.' }
            if (@($GitPlan.Records.RepositoryScopes.Keys).Count -ne 1 -or -not $GitPlan.Records.RepositoryScopes.ContainsKey('.') -or $activeRelative -cnotin @($GitPlan.Records.RepositoryScopes['.'])) { throw 'Records GitPlan must explicitly include this whole Change under the canonical parent repository.' }
            $recordArgs=Get-ClosureGitArgs $recordRoot $GitPlan.Records
            $recordPreview=Complete-HarnessGitCommit @recordArgs -WhatIf
            $steps=@()
            if ($GitPlan.Implementation.Count) {
                foreach ($repo in @($GitPlan.Implementation.RepositoryScopes.Keys | Sort-Object)) {
                    if ($repo -eq '.' -and $ClosureKind -eq 'completed') { throw 'Completed primary implementation belongs in the final Records commit; implementation steps select editable plugins.' }
                    if ($ClosureKind -ne 'completed' -and $GitPlan.Implementation.CommitMessage -notmatch '(?i)incomplete') { throw 'An incomplete implementation checkpoint must be visibly labelled incomplete in its shown commit intent.' }
                    if ($repo -eq '.') {
                        foreach ($owned in $GitPlan.Implementation.RepositoryScopes[$repo]) {
                            foreach ($record in $GitPlan.Records.RepositoryScopes['.']) {
                                if ($owned -eq $record -or $owned.StartsWith($record.TrimEnd('/')+'/') -or $record.StartsWith($owned.TrimEnd('/')+'/')) { throw 'Incomplete parent checkpoint and final record scopes must be disjoint.' }
                            }
                        }
                    }
                    $plan=@{RepositoryScopes=@{$repo=$GitPlan.Implementation.RepositoryScopes[$repo]};CommitMessage=$GitPlan.Implementation.CommitMessage}
                    foreach ($key in @('RepositoryPatches','SubmoduleCommitMessages','TargetBranches')) { if ($GitPlan.Implementation.ContainsKey($key) -and $GitPlan.Implementation[$key].ContainsKey($repo)) { $plan[$key]=@{$repo=$GitPlan.Implementation[$key][$repo]} } }
                    $args=Get-ClosureGitArgs $Context.WorkspaceRoot $plan -PluginsOnly:($repo -ne '.')
                    $preview=Complete-HarnessGitCommit @args -WhatIf
                    if (@($preview.IncludedChanges).Count -ne 1) { throw 'Each declared implementation step must have an exact attributable candidate.' }
                    $candidate=$preview.IncludedChanges[0]
                    $steps+=@{repository=$repo;root=$(if ($repo -eq '.') {$Context.WorkspaceRoot} else {Get-ClosurePath $Context.WorkspaceRoot $repo});args=$args;revision=$preview.PlanRevision;baseline=$candidate.Baseline;tree=$candidate.CandidateTree;complete=$false;patch=$candidate.Patch;excluded=$candidate.ExcludedPatch}
                }
            }
            $withdrawals=@(New-ClosureWithdrawals $Context $steps $GitPlan $Dispositions $ClosureKind)
            $files=Get-ClosureFiles $active
            $basis=@{request=$requestHash;files=$files;records=$recordPreview.PlanRevision;steps=$steps;withdrawals=$withdrawals;archive=$archiveRelative;uid=$run.changeUid}
            $revision=Get-ClosureHash $basis
            $state=@{schema=1;path=$statePath;requestHash=$requestHash;revision=$revision;stage='prepared';change=$ChangeId;uid=$run.changeUid;sessionId=$SessionId;kind=$ClosureKind;workspaceRoot=$Context.WorkspaceRoot;recordRoot=$recordRoot;activeRelative=$activeRelative;archiveRelative=$archiveRelative;archivePath=$archive;date=$date;plan=$GitPlan;dispositions=$Dispositions;steps=$steps;files=$files;recordBaseline=(Read-ClosureGit $recordRoot @('rev-parse','HEAD'));recordTree=$(if (@($recordPreview.IncludedChanges).Count) { $recordPreview.IncludedChanges[0].CandidateTree } else { Read-ClosureGit $recordRoot @('rev-parse','HEAD^{tree}') });recordPreview=$recordPreview}
            $state.withdrawals=$withdrawals
            $state.recordPatch=if (@($recordPreview.IncludedChanges).Count) { $recordPreview.IncludedChanges[0].Patch } else { '' }
            if ($PlanOnly) { return Get-ClosureView $state }
            if (-not $Gate -or $Gate.Decision -cne 'close' -or $Gate.TargetChange -cne $ChangeId -or $Gate.HandoffRevision -cne $revision -or -not $Gate.DecisionSource) { throw 'An actual close Gate for this exact current preview is required; stale content needs a new explanation and decision.' }
            $state.gate=$Gate; Write-ClosureState $statePath $state
        }
        $active=Get-ClosurePath $recordRoot $state.activeRelative
        if ($state.stage -eq 'prepared') {
            [void](Assert-ClosureExecution $Context $ChangeId $SessionId)
            if ((Get-ClosureHash (Get-ClosureFiles $active)) -cne (Get-ClosureHash $state.files)) { throw 'Change records changed after the close decision.' }
            foreach ($step in $state.steps) { Complete-ClosureGitStep $state $step }
            $state.stage='implementation-saved'; Write-ClosureState $statePath $state
        }
        if ($state.stage -eq 'implementation-saved') {
            foreach ($step in $state.withdrawals) { Complete-ClosureWithdrawal $state $step }
            $state.stage='withdrawal-saved'; Write-ClosureState $statePath $state
        }
        if ($state.stage -eq 'withdrawal-saved') {
            [void](Assert-ClosureExecution $Context $ChangeId $SessionId)
            Assert-ClosureMetadataInputs $state $active
            if ((Read-ClosureGit $recordRoot @('rev-parse','HEAD')) -cne (Get-ClosureExpectedParent $state)) { throw 'Canonical Git baseline changed before archive preparation.' }
            if (-not $state.ContainsKey('checkpointSaved')) {
                $queue=Invoke-ClosureRoute $Context harness.queue.status
                if ($null -eq $queue.controller -or $queue.controller.sessionId -cne $SessionId -or $queue.currentChange -cne $ChangeId) { throw 'Closure source checkpoint lost its exact queue controller.' }
                [void](Invoke-ClosureRoute $Context harness.queue.checkpoint @{Change=$ChangeId;Token=$queue.controller.token})
                $state.checkpointSaved=$true; Write-ClosureState $statePath $state
            }
            $receipt=@{schema=1;operation=$state.path;revision=$state.revision;gate=$state.gate;uid=$state.uid;kind=$state.kind;archive=$state.archiveRelative;gitPlan=$state.plan;recordBaseline=$state.recordBaseline;acceptedRecordTree=$state.recordTree;acceptedInputs=$state.files;implementation=@($state.steps | ForEach-Object { @{repository=$_.repository;baseline=$_.baseline;commit=$_.commit} });dispositions=$state.dispositions}
            $receipt.withdrawal=@($state.withdrawals | ForEach-Object { @{repository=$_.repository;baseline=$_.baseline;commit=$_.commit;reference=$_.reference;retainedPaths=$_.retainedPaths;verified=$_.verified} })
            Set-ClosureGeneratedFile $state $active 'attachments/data/harness-closure.json' ($receipt | ConvertTo-Json -Depth 60)
            $indexPath=Get-ClosurePath $active 'attachments/INDEX.md'
            $index=[IO.File]::ReadAllText($indexPath)
            if (-not $index.Contains('data/harness-closure.json')) { $index+="`n- data/harness-closure.json — exact close decision, Git results and disposition.`n" }
            Set-ClosureGeneratedFile $state $active 'attachments/INDEX.md' $index
            $current=Invoke-ClosureRoute $Context harness.evolution.status @{Change=$ChangeId;ClosureKind=$ClosureKind}
            $evaluationPath=Get-ClosurePath $active 'attachments/data/workflow-evaluation.md'
            $evaluation=[IO.File]::ReadAllText($evaluationPath)
            $evaluation=[regex]::Replace($evaluation,'(?m)^input_sha256:.*$',('input_sha256: '+$current.CurrentInputSha256))
            $evaluation=[regex]::Replace($evaluation,'(?m)^captured_at:.*$',('captured_at: '+[DateTimeOffset]::UtcNow.ToString('o')))
            Set-ClosureGeneratedFile $state $active 'attachments/data/workflow-evaluation.md' $evaluation
            $terminal=Invoke-ClosureRoute $Context harness.evolution.status @{Change=$ChangeId;ClosureKind=$ClosureKind;RequireTerminal=$true}
            $state.terminalDigest=$terminal.CurrentInputSha256; $state.archiveInputs=Get-ClosureFiles $active
            $closureText=$state.dispositions.Closure | ConvertTo-Json -Depth 20
            $state.closureBytesHash=Get-ClosureHash $closureText
            $state.closureFile=Get-ClosurePath $Context.WorkspaceRoot ('Saved/AgentTemp/closure/'+$state.uid+'.json')
            [void][IO.Directory]::CreateDirectory((Split-Path $state.closureFile)); [IO.File]::WriteAllText($state.closureFile,$closureText,[Text.UTF8Encoding]::new($false))
            $state.stage='archive-ready'; Write-ClosureState $statePath $state
        }
        if ($state.stage -eq 'archive-ready') {
            if (Test-Path -LiteralPath $active) {
                [void](Invoke-ClosureRoute $Context openspec.change @{ClosureOperation=$state.path} @('archive',$ChangeId,'--closure-file',$state.closureFile,'--date',$state.date,'--json'))
            }
            if (-not (Test-Path -LiteralPath $state.archivePath)) { throw 'Expected archive is missing; keep the saved closure for recovery.' }
            $archivedFiles=Get-ClosureFiles $state.archivePath
            if (@($archivedFiles.Keys).Count -ne @($state.archiveInputs.Keys).Count) { throw 'Archive contains unexpected added or removed outputs.' }
            $manifest=[IO.File]::ReadAllText((Join-Path $state.archivePath 'change.yaml'))
            if ($manifest -cnotmatch ('(?m)^  uid: '+[regex]::Escape($state.uid)+'\s*$') -or $manifest -cnotmatch ('(?m)^  kind: '+$state.kind+'\s*$')) { throw 'Archived identity or closure kind differs from the approved operation.' }
            foreach ($name in $state.archiveInputs.Keys) {
                if ($name -eq 'change.yaml') { continue }
                $path=Get-ClosurePath $state.archivePath $name
                if (-not (Test-Path -LiteralPath $path) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ine $state.archiveInputs[$name]) { throw "Archive content differs from accepted generated output: $name" }
            }
            # The portable CLI's archived selector is aggregate-only. Consume
            # its exact per-item result without imposing new rules on other history.
            $audit=Invoke-Harness openspec.validate -Context $Context -ArgumentList @('--archived','--strict','--json')
            if ($null -eq $audit.data -or $audit.exitCode -notin @(0,1)) { throw 'Archived validation did not produce a usable report.' }
            $report=($audit.data.Output -join "`n") | ConvertFrom-Json
            $archiveId=$parts[0]+'/'+$state.date+'-'+$parts[1]
            $item=@($report.items | Where-Object id -CEQ $archiveId)
            if ($item.Count -ne 1 -or -not $item[0].valid) { throw ('Exact archived validation failed: '+($item | ConvertTo-Json -Depth 20 -Compress)) }
            $state.archiveValidation=@{runId=$audit.runId;id=$archiveId;valid=$true;otherInvalid=@($report.items | Where-Object { -not $_.valid -and $_.id -cne $archiveId }).Count}
            $state.archivedFiles=Get-ClosureFiles $state.archivePath; $state.stage='archived'; Write-ClosureState $statePath $state
        }
        if ($state.stage -eq 'archived') {
            if ((Get-ClosureHash (Get-ClosureFiles $state.archivePath)) -cne (Get-ClosureHash $state.archivedFiles)) { throw 'Immutable archive changed during closure recovery.' }
            if (-not $state.ContainsKey('recordStep')) {
                $parentBaseline=Get-ClosureExpectedParent $state
                if ((Read-ClosureGit $recordRoot @('rev-parse','HEAD')) -cne $parentBaseline) { throw 'Canonical Git baseline changed after close approval.' }
                $tree=New-ClosureRecordTree $state
                $patchPath=Get-ClosurePath $Context.WorkspaceRoot ('Saved/AgentTemp/closure/'+$state.uid+'.patch')
                [void](Read-ClosureGit $recordRoot @('diff','--binary','--full-index',('--output='+$patchPath),$parentBaseline,$tree,'--'))
                $plan=@{RepositoryScopes=@{'.'=@($state.plan.Records.RepositoryScopes['.'])+@($state.archiveRelative)};RepositoryPatches=@{'.'=[IO.File]::ReadAllText($patchPath)};CommitMessage=$state.plan.Records.CommitMessage}
                $args=Get-ClosureGitArgs $recordRoot $plan
                $shown=Complete-HarnessGitCommit @args -WhatIf
                if (@($shown.IncludedChanges).Count -ne 1 -or $shown.IncludedChanges[0].CandidateTree -cne $tree) { throw 'Final canonical candidate differs from the approved content and its derived archive.' }
                $state.recordStep=@{root=$recordRoot;repository='.';args=$args;baseline=$parentBaseline;tree=$tree;revision=$shown.PlanRevision;complete=$false}
                Write-ClosureState $statePath $state
            }
            Complete-ClosureGitStep $state $state.recordStep
            $state.recordCommit=$state.recordStep.commit; $state.stage='complete'; Write-ClosureState $statePath $state
        }
        return Get-ClosureView $state
    } finally { if ($held) { $mutex.ReleaseMutex() }; $mutex.Dispose() }
}
Export-ModuleMember -Function Close-HarnessChange,Assert-HarnessCloseArchive
