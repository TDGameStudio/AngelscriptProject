#requires -Version 7.0
param([ValidateSet('All','Abandoned','Superseded')][string]$Scenario='All',[switch]$WithPlugin)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$projectRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
. (Join-Path $PSScriptRoot 'LifecycleFixture.ps1')
function Check-Incomplete($Condition,$Message) { if (-not $Condition) { throw $Message }; Write-Output "PASS $Message" }
function Set-IncompleteFixture($Case,$Kind='abandoned',$Replacement='') {
    $p=$Case.Parameters; $p.ClosureKind=$Kind
    $taskPath=Join-Path $Case.Root 'tasks.md'
    Write-LifecycleFixture $taskPath ([IO.File]::ReadAllText($taskPath).Replace('## [x]','## [ ]'))
    $p.Dispositions.Closure=@{kind=$Kind;reason='Fixture work did not fulfill its objective';task_dispositions=@{'1.1'=@{status=$(if($Kind -eq 'superseded') {'superseded'} else {'cancelled'});reason='Explicit fixture disposition'}}}
    if ($Replacement) { $p.Dispositions.Closure.superseded_by=$Replacement; $p.Dispositions.Closure.task_dispositions['1.1'].follow_up=$Replacement }
    $p.Dispositions.SpecSync='not-synced: unfinished fixture contract remains historical'
    $view=Invoke-LifecycleFixture $Case.Context harness.evolution.status @{Change=$Case.Id;ClosureKind=$Kind}
    Write-LifecycleFixture (Join-Path $Case.Root 'attachments/data/workflow-evaluation.md') "---`nrecord: harness-workflow-evaluation-v1`nresult: passed`nchange: $($Case.Id)`nclosure_kind: $Kind`ninput_sha256: $($view.CurrentInputSha256)`ncaptured_at: $([DateTimeOffset]::UtcNow.ToString('o'))`n---`n`n# Evidence`nThe fixture keeps incomplete tasks and proves exact Git preservation and withdrawal.`n"
}
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('harness-incomplete-'+[guid]::NewGuid().ToString('N'))
try {
    if ($Scenario -ne 'Superseded') {
    $case=New-LifecycleFixture $projectRoot $fixture 'harness/test-abandoned-closure'
    if ($WithPlugin) { $plugin=Add-LifecycleFixturePlugin $fixture $case; $pluginBaseline=& git -C $plugin rev-parse HEAD; $pluginOutside=& git -C $plugin rev-parse ':outside.txt' }
    Set-IncompleteFixture $case
    $ctx=$case.Context; $p=$case.Parameters
    $baseline=& git -C $fixture rev-parse HEAD
    $outside=& git -C $fixture rev-parse ':outside.txt'
    $patchPath=Join-Path $fixture 'Saved/withdraw.patch'
    [void][IO.Directory]::CreateDirectory((Split-Path $patchPath))
    & git -C $fixture diff -R --binary --full-index "--output=$patchPath" -- owned.txt
    $p.GitPlan.Implementation=@{RepositoryScopes=@{'.'=@('owned.txt')};CommitMessage='[Incomplete] fixture abandoned checkpoint'}
    $p.GitPlan.Records.RepositoryScopes['.']=@('openspec/changes/'+$case.Id)
    $p.GitPlan.Withdrawal=@{RepositoryScopes=@{'.'=@('owned.txt')};RepositoryPatches=@{'.'=[IO.File]::ReadAllText($patchPath)};CommitMessage='fixture withdraw abandoned implementation'}
    $p.Dispositions.WithdrawalVerification=@{Kind='baseline';RepositoryReferences=@{'.'=$baseline};Evidence='The fixture proves the selected withdrawal matches the accepted original baseline.'}
    if ($WithPlugin) {
        $pluginPatch=Join-Path $fixture 'Saved/plugin-withdraw.patch'
        & git -C $plugin diff -R --binary --full-index "--output=$pluginPatch" -- owned.txt
        $p.GitPlan.Implementation.RepositoryScopes['Plugins/Foo']=@('owned.txt')
        $p.GitPlan.Withdrawal.RepositoryScopes['Plugins/Foo']=@('owned.txt')
        $p.GitPlan.Withdrawal.RepositoryPatches['Plugins/Foo']=[IO.File]::ReadAllText($pluginPatch)
        $p.Dispositions.WithdrawalVerification.RepositoryReferences['Plugins/Foo']=$pluginBaseline
        $p.GitPlan.Records.RepositoryScopes['.']+=@('Plugins/Foo')
    }
    $bad=$p | ConvertTo-Json -Depth 40 | ConvertFrom-Json -AsHashtable
    $bad.GitPlan.Withdrawal.RepositoryPatches['.']=$bad.GitPlan.Withdrawal.RepositoryPatches['.'].Replace('-owned result','-a different implementation')
    $ambiguous=Invoke-Harness harness.change.close -Context $ctx -Parameters ($bad+@{PlanOnly=$true})
    Check-Incomplete ($ambiguous.status -eq 'Failed' -and (& git -C $fixture rev-parse HEAD) -eq $baseline -and (Get-Content (Join-Path $fixture 'owned.txt') -Raw) -eq "owned result`n") 'an inapplicable withdrawal cannot restore or reset files'
    $shown=Invoke-LifecycleFixture $ctx harness.change.close ($p+@{PlanOnly=$true})
    $gate=@{DecisionSource='fixture:actual-abandon';Decision='close';TargetChange=$case.Id;HandoffRevision=$shown.HandoffRevision}
    Write-LifecycleFixture (Join-Path $fixture '.git/hooks/pre-commit') "#!/bin/sh`nexit 1`n"
    $failed=Invoke-Harness harness.change.close -Context $ctx -Parameters ($p+@{Gate=$gate})
    Check-Incomplete ($failed.status -eq 'Failed' -and $failed.error.message -match 'pre-commit' -and (& git -C $fixture rev-parse HEAD) -eq $baseline -and (Test-Path $case.Root)) 'rejected incomplete checkpoint does not withdraw unsaved code or bypass hooks'
    Check-Incomplete ((Get-Content (Join-Path $fixture 'owned.txt') -Raw) -eq "owned result`n") 'checkpoint failure leaves owned implementation present'
    [IO.File]::Delete((Join-Path $fixture '.git/hooks/pre-commit'))
    $closed=Invoke-LifecycleFixture $ctx harness.change.close ($p+@{Gate=$gate})
    Check-Incomplete $closed.Complete 'approved abandoned closure completes its separate checkpoint, withdrawal and archive stages'
    $checkpoint=$closed.Implementation[0].commit
    Check-Incomplete ((& git -C $fixture show ($checkpoint+':owned.txt')) -eq 'owned result') 'Git retains the incomplete implementation checkpoint'
    Check-Incomplete ((& git -C $fixture show 'HEAD:owned.txt') -eq 'owned baseline' -and (Get-Content (Join-Path $fixture 'owned.txt') -Raw).Replace("`r`n","`n") -eq "owned baseline`n") 'only the shown owned implementation is withdrawn (respecting Git autocrlf)'
    Check-Incomplete ((& git -C $fixture rev-parse ':outside.txt') -eq $outside) 'withdrawal preserves unrelated staged work'
    Check-Incomplete ((Get-Content (Join-Path $closed.ArchivePath 'tasks.md') -Raw).Contains('## [ ] 1.1')) 'abandoned history does not mark unfinished tasks complete'
    if ($WithPlugin) {
        $pluginCheckpoint=@($closed.Implementation | Where-Object repository -EQ 'Plugins/Foo')[0].commit
        Check-Incomplete ((& git -C $plugin show ($pluginCheckpoint+':owned.txt')) -eq 'plugin result' -and (& git -C $plugin show 'HEAD:owned.txt') -eq 'plugin baseline' -and (& git -C $plugin rev-parse ':outside.txt') -eq $pluginOutside) 'multi-repository abandonment saves and withdraws only each owned implementation'
    }
    $queue=Invoke-LifecycleFixture $ctx harness.queue.status
    Check-Incomplete ($queue.recordState -eq 'archive-pending' -and $queue.closureKind -eq 'abandoned') 'queue preserves the abandoned outcome without calling its objective completed'
    $advanced=Invoke-LifecycleFixture $ctx harness.queue.advance @{Token=$queue.controller.token}
    Check-Incomplete ($advanced.items[0].closureKind -eq 'abandoned' -and $advanced.counts.remaining -eq 0) 'fully persisted abandonment retires only its authorized queue item'
    }
    if ($Scenario -ne 'Abandoned') {
    $supRoot=Join-Path $fixture 'Saved/superseded-fixture'
    $sup=New-LifecycleFixture $projectRoot $supRoot 'harness/test-superseded-closure'
    Write-LifecycleFixture (Join-Path $supRoot 'retained.txt') "retained baseline`n"
    & git -C $supRoot add retained.txt
    & git -C $supRoot commit -qm 'fixture carryover baseline' -- retained.txt
    $replacement='harness/test-replacement-plan'
    $create=@{ChangeId=$replacement;Title='Replacement fixture';Goal='Accept retained subset';Origin='Direct';Reason='Explicit fixture replacement';HandoffText='Retain retained.txt and reject owned.txt';SessionId='lifecycle-fixture';Candidates=(Get-LifecycleFixtureCandidates);GitPlan=@{RepositoryScopes=@{'.'=@('openspec/changes/'+$replacement)};CommitMessage='fixture replacement planning'}}
    $preview=Invoke-LifecycleFixture $sup.Context harness.change.create ($create+@{PlanOnly=$true})
    $create.Gate=@{ConvergenceSource='fixture:replacement-ready';DecisionSource='fixture:replacement-create';Decision='create';TargetChange=$replacement;HandoffRevision=$preview.HandoffRevision}
    Invoke-LifecycleFixture $sup.Context harness.change.create $create | Out-Null
    Set-IncompleteFixture $sup 'superseded' $replacement
    $baseline=& git -C $supRoot rev-parse HEAD
    $outside=& git -C $supRoot rev-parse ':outside.txt'
    Write-LifecycleFixture (Join-Path $supRoot 'retained.txt') "retained accepted result`n"
    $withdrawPath=Join-Path $supRoot 'Saved/withdraw.patch'
    $retainPath=Join-Path $supRoot 'Saved/retain.patch'
    & git -C $supRoot diff -R --binary --full-index "--output=$withdrawPath" -- owned.txt
    & git -C $supRoot diff --binary --full-index "--output=$retainPath" -- retained.txt
    $sp=$sup.Parameters
    $sp.GitPlan.Records.RepositoryScopes['.']=@('openspec/changes/'+$sup.Id)
    $sp.GitPlan.Implementation=@{RepositoryScopes=@{'.'=@('owned.txt','retained.txt')};CommitMessage='[Incomplete] fixture superseded checkpoint'}
    $sp.GitPlan.Withdrawal=@{RepositoryScopes=@{'.'=@('owned.txt')};RepositoryPatches=@{'.'=[IO.File]::ReadAllText($withdrawPath)};CommitMessage='fixture withdraw rejected subset'}
    $sp.Dispositions.WithdrawalVerification=@{Kind='baseline';RepositoryReferences=@{'.'=$baseline};Evidence='Retained patch plus original baseline is the explained post-withdrawal contract.'}
    $sp.Dispositions.Carryover=@{Target=$replacement;Evidence='fixture:replacement-create accepts only retained.txt';RepositoryPatches=@{'.'=[IO.File]::ReadAllText($retainPath)}}
    $shown=Invoke-LifecycleFixture $sup.Context harness.change.close ($sp+@{PlanOnly=$true})
    $sg=@{DecisionSource='fixture:actual-supersede';Decision='close';TargetChange=$sup.Id;HandoffRevision=$shown.HandoffRevision}
    # First commit succeeds, second (withdrawal) is rejected by a normal hook.
    Write-LifecycleFixture (Join-Path $supRoot '.git/hooks/pre-commit') "#!/bin/sh`nif git show HEAD:owned.txt | grep -q 'owned result'; then exit 1; fi`n"
    $partial=Invoke-Harness harness.change.close -Context $sup.Context -Parameters ($sp+@{Gate=$sg})
    Check-Incomplete ($partial.status -eq 'Failed' -and $partial.error.message -match 'pre-commit' -and (Test-Path $sup.Root)) 'withdrawal rejection retains the incomplete checkpoint and active closure'
    $checkpoint=& git -C $supRoot rev-parse HEAD
    Check-Incomplete ((& git -C $supRoot show 'HEAD:owned.txt') -eq 'owned result') 'failed withdrawal does not erase the saved implementation'
    [IO.File]::Delete((Join-Path $supRoot '.git/hooks/pre-commit'))
    $supClosed=Invoke-LifecycleFixture $sup.Context harness.change.close ($sp+@{Gate=$sg})
    Check-Incomplete ($supClosed.Complete -and $supClosed.Implementation[0].commit -eq $checkpoint) 'superseded retry completes without duplicating the incomplete checkpoint'
    Check-Incomplete ((& git -C $supRoot show 'HEAD:owned.txt') -eq 'owned baseline' -and (& git -C $supRoot show 'HEAD:retained.txt') -eq 'retained accepted result') 'final records commit keeps the accepted carryover and withdraws only the rejected subset'
    Check-Incomplete ((& git -C $supRoot rev-parse ':outside.txt') -eq $outside -and (Test-Path (Join-Path $supRoot ('openspec/changes/'+$replacement)))) 'superseded closure preserves unrelated staging and does not execute its replacement'
    $supQueue=Invoke-LifecycleFixture $sup.Context harness.queue.status
    $advanced=Invoke-LifecycleFixture $sup.Context harness.queue.advance @{Token=$supQueue.controller.token}
    Check-Incomplete ($advanced.items[0].closureKind -eq 'superseded' -and $advanced.counts.remaining -eq 0) 'queue records superseded closure without authorizing the replacement'
    }
    'HarnessIncompleteClosure.Tests.ps1: PASS'
} finally {
    $resolved=[IO.Path]::GetFullPath($fixture)
    $allowed=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar+'harness-incomplete-'
    if (-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe incomplete fixture cleanup' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
