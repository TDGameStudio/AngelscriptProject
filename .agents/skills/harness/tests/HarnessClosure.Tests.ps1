#requires -Version 7.0
param([switch]$IncludeReplan)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$projectRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
. (Join-Path $PSScriptRoot 'LifecycleFixture.ps1')
function Check($Value,$Message) { if (-not $Value) { throw $Message }; Write-Output "PASS $Message" }
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('harness-close-'+[guid]::NewGuid().ToString('N'))
try {
    $case=New-LifecycleFixture $projectRoot $fixture
    $plugin=Add-LifecycleFixturePlugin $fixture $case
    if ($IncludeReplan) {
        $replanCommit=Invoke-LifecycleFixtureReplan $case
        Check ((& git -C $fixture rev-parse HEAD) -eq $replanCommit -and ((& git -C $fixture show ('HEAD:openspec/changes/'+$case.Id+'/design.md')) -join "`n").Contains('accepted clarified guidance')) 'integrated Replan persists its accepted design before closure'
        Check ((& git -C $fixture show 'HEAD:owned.txt') -eq 'owned baseline') 'integrated Replan leaves the unfinished implementation outside the planning commit'
    }
    $pluginOutside=& git -C $plugin rev-parse ':outside.txt'
    $pluginBase=& git -C $plugin rev-parse HEAD
    $ctx=$case.Context; $p=$case.Parameters
    $beforeHead=& git -C $fixture rev-parse HEAD
    $outside=& git -C $fixture rev-parse ':outside.txt'
    $shown=Invoke-LifecycleFixture $ctx harness.change.close ($p+@{PlanOnly=$true})
    Check ((Test-Path $case.Root) -and (& git -C $fixture rev-parse HEAD) -eq $beforeHead) 'closure preview is read-only'
    $gate=@{DecisionSource='fixture:actual-close';Decision='close';TargetChange=$case.Id;HandoffRevision=$shown.HandoffRevision}
    Add-Content (Join-Path $fixture 'owned.txt') 'unshown change'
    $stale=Invoke-Harness harness.change.close -Context $ctx -Parameters ($p+@{Gate=$gate})
    Check ($stale.status -eq 'Failed' -and (Test-Path $case.Root) -and (& git -C $fixture rev-parse HEAD) -eq $beforeHead) 'stale close candidate cannot mutate refs or archive'
    Check ((& git -C $plugin rev-parse HEAD) -eq $pluginBase) 'stale close does not commit a plugin before rejecting the parent candidate'
    Write-LifecycleFixture (Join-Path $fixture 'owned.txt') "owned result`n"
    Write-LifecycleFixture (Join-Path $fixture '.git/hooks/pre-commit') "#!/bin/sh`nexit 1`n"
    $failed=Invoke-Harness harness.change.close -Context $ctx -Parameters ($p+@{Gate=$gate})
    Check ($failed.status -eq 'Failed' -and $failed.error.message -match 'pre-commit' -and -not (Test-Path $case.Root)) "parent hook failure leaves an archived commit-pending operation: $($failed.error.message)"
    $pending=Invoke-LifecycleFixture $ctx harness.change.close ($p+@{PlanOnly=$true})
    Check (-not $pending.Complete -and $pending.Stage -eq 'archived') 'read-only recovery reports the actual incomplete stage'
    $queuePending=Invoke-LifecycleFixture $ctx harness.queue.status
    Check ($queuePending.recordState -eq 'close-pending') 'queue cannot treat an uncommitted new archive as fully closed'
    $advancePending=Invoke-Harness harness.queue.advance -Context $ctx -Parameters @{Token=$queuePending.controller.token}
    Check ($advancePending.status -eq 'Failed') 'queue advancement refuses the pending close commit'
    $executionPending=Invoke-LifecycleFixture $ctx harness.execution.status @{SessionId='lifecycle-fixture'}
    Check ($executionPending.state -eq 'running' -and $executionPending.phase -eq 'closing' -and -not $executionPending.implementationAllowed) 'execution remains recoverable without allowing more implementation'
    $archiveManifest=Join-Path $pending.ArchivePath 'change.yaml'
    $archiveBefore=(Get-FileHash -LiteralPath $archiveManifest).Hash
    $pluginCommitted=& git -C $plugin rev-parse HEAD
    Check ($pluginCommitted -ne $pluginBase -and (& git -C $plugin show 'HEAD:owned.txt') -eq 'plugin result') 'plugin result was committed before terminal archive evidence'
    [IO.File]::Delete((Join-Path $fixture '.git/hooks/pre-commit'))
    $closed=Invoke-LifecycleFixture $ctx harness.change.close ($p+@{Gate=$gate})
    Check ($closed.Complete -and $closed.Stage -eq 'complete') 'one accepted close finishes archive validation and final Git persistence'
    Check ((Get-FileHash -LiteralPath $archiveManifest).Hash -eq $archiveBefore) 'retry keeps the archive immutable'
    Check ((& git -C $fixture rev-parse ':outside.txt') -eq $outside) 'closure preserves unrelated staged content'
    Check ((& git -C $plugin rev-parse ':outside.txt') -eq $pluginOutside -and (& git -C $plugin rev-parse HEAD) -eq $pluginCommitted) 'recovery preserves plugin staged content and does not duplicate its successful commit'
    Check ((& git -C $fixture rev-parse 'HEAD:Plugins/Foo') -eq $pluginCommitted) 'canonical commit records the explicitly selected resulting gitlink'
    $saved=@(& git -C $fixture show 'HEAD:owned.txt') -join "`n"
    Check ($saved -eq 'owned result') 'final canonical commit includes only the approved owned implementation'
    $again=Invoke-LifecycleFixture $ctx harness.change.close ($p+@{Gate=$gate})
    Check ($again.RecordCommit -eq $closed.RecordCommit) 'exact close retry does not duplicate the final commit'
    $queue=Invoke-LifecycleFixture $ctx harness.queue.status
    Check ($queue.recordState -eq 'archive-pending' -and $queue.closureKind -eq 'completed') 'queue observes the actual fully persisted completed outcome'
    $privateState=$closed.OperationPath
    [IO.File]::Move($privateState,$privateState+'.fixture-backup')
    try { Check ((Invoke-LifecycleFixture $ctx harness.queue.status).recordState -eq 'archive-pending') 'committed archive is recognizable without machine-local recovery state' }
    finally { [IO.File]::Move($privateState+'.fixture-backup',$privateState) }
    Invoke-LifecycleFixture $ctx harness.queue.advance @{Token=$queue.controller.token} | Out-Null
    Write-LifecycleFixture (Join-Path $fixture 'AgentConfig.ini') "[Paths]`nEngineRoot=C:\FixtureEngine`n"
    Invoke-LifecycleFixture $ctx workspace.bootstrap | Out-Null
    $replicaData=Invoke-LifecycleFixture $ctx workspace.new @{Name='closure-replica';EditablePlugins=@('Foo')}
    $replicaContext=New-HarnessContext -WorkspaceRoot $replicaData.WorkspaceRoot
    $replicaCase=New-LifecycleFixtureChange $replicaContext $replicaData.WorkspaceRoot 'harness/test-replica-closure'
    $replicaPlugin=Join-Path $replicaData.WorkspaceRoot 'Plugins/Foo'
    Write-LifecycleFixture (Join-Path $replicaPlugin 'owned.txt') "replica result`n"
    $replicaCase.Parameters.GitPlan.Implementation=@{RepositoryScopes=@{'Plugins/Foo'=@('owned.txt')};CommitMessage='fixture replica implementation'}
    $replicaShown=Invoke-LifecycleFixture $replicaContext harness.change.close ($replicaCase.Parameters+@{PlanOnly=$true})
    $replicaGate=@{DecisionSource='fixture:actual-replica-close';Decision='close';TargetChange=$replicaCase.Id;HandoffRevision=$replicaShown.HandoffRevision}
    $replicaClosed=Invoke-LifecycleFixture $replicaContext harness.change.close ($replicaCase.Parameters+@{Gate=$replicaGate})
    Check ($replicaClosed.Complete -and $replicaClosed.ArchivePath.StartsWith($fixture) -and -not (Test-Path (Join-Path $replicaData.WorkspaceRoot '.git'))) 'replica closure persists canonical records without inventing a parent repository'
    Check ((& git -C $replicaPlugin show 'HEAD:owned.txt') -eq 'replica result' -and (& git -C $plugin rev-parse HEAD) -eq $pluginCommitted) 'replica commits only its editable plugin without implicit integration'
    Check ((& git -C $fixture rev-parse 'HEAD:Plugins/Foo') -eq $pluginCommitted) 'replica closure preserves the unselected primary gitlink'
    'HarnessClosure.Tests.ps1: PASS'
} finally {
    $resolved=[IO.Path]::GetFullPath($fixture)
    $allowed=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar+'harness-close-'
    if (-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe closure fixture cleanup' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
