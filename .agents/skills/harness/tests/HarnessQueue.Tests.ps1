param()
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
foreach ($suite in @('test_change_queue.py','test_shared_specs.py','test_source_identity.py')) {
    & python -X utf8 (Join-Path $PSScriptRoot $suite)
    if ($LASTEXITCODE) { throw "$suite failed" }
}
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('harness-queue-integration-' + [guid]::NewGuid().ToString('N'))
function G($root, $arguments) {
    $out = @(& git -C $root @arguments 2>&1)
    if ($LASTEXITCODE) { throw ($out -join "`n") }
    return ($out -join "`n")
}
function W($path, $body) { [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path)); [IO.File]::WriteAllText($path, $body) }
function Invoke-FixtureHarness($context, $command, $parameters=@{}, $arguments=@()) {
    $result = Invoke-Harness -Context $context -Command $command -Parameters $parameters -ArgumentList $arguments
    if ($result.status -ne 'Succeeded') { throw "$command : $($result.error.message)" }
    return $result.data
}
function Check($value, $message) { if (-not $value) { throw $message }; Write-Output "PASS $message" }
try {
    [void][IO.Directory]::CreateDirectory($fixture)
    G $fixture @('init','-b','main') | Out-Null
    G $fixture @('config','user.name','Fixture') | Out-Null
    G $fixture @('config','user.email','fixture@example.invalid') | Out-Null
    W (Join-Path $fixture '.gitignore') ".workspaces/`nSaved/`nAgentConfig.ini`nPlugins/`n"
    W (Join-Path $fixture 'Fixture.uproject') '{"FileVersion":3,"Modules":[],"Plugins":[]}'
    G $fixture @('add','.') | Out-Null
    G $fixture @('commit','-m','fixture') | Out-Null
    W (Join-Path $fixture 'AgentConfig.ini') "[Paths]`nEngineRoot=C:\FixtureEngine`n"
    foreach ($name in @('Foo','Bar','Unused')) {
        $repo = Join-Path $fixture "Plugins/$name"
        [void][IO.Directory]::CreateDirectory($repo)
        G $repo @('init','-b','main') | Out-Null
        G $repo @('config','user.name','Fixture') | Out-Null
        G $repo @('config','user.email','fixture@example.invalid') | Out-Null
        $deps = if ($name -eq 'Foo') { @(@{Name='Bar';Enabled=$true}) } else { @() }
        W (Join-Path $repo "$name.uplugin") (@{FileVersion=3;Plugins=@($deps | Where-Object { $null -ne $_ })} | ConvertTo-Json -Depth 4)
        W (Join-Path $repo 'owned.txt') 'committed baseline'
        G $repo @('add','.') | Out-Null
        G $repo @('commit','-m','plugin baseline') | Out-Null
    }
    W (Join-Path $fixture 'Plugins/Bar/owned.txt') 'uncommitted changes excluded'
    $main = New-HarnessContext -WorkspaceRoot $fixture
    Invoke-FixtureHarness $main workspace.bootstrap | Out-Null
    Invoke-FixtureHarness $main openspec.init @{} @('--project-id','queue-fixture','--title','Queue fixture') | Out-Null
    Invoke-FixtureHarness $main openspec.domain @{} @('create','fixture','--title','Fixture','--description','Queue fixture') | Out-Null
    foreach ($id in @('fixture/test-queue-first','fixture/test-queue-second')) {
        Invoke-FixtureHarness $main harness.change.create @{ChangeId=$id; Title=$id; Goal='Exercise queue routing'; Origin='Direct'; Reason='Isolated acceptance fixture'} | Out-Null
    }
    $created = Invoke-FixtureHarness $main workspace.new @{Name='alpha';EditablePlugins=@('Foo')}
    $replica = New-HarnessContext -WorkspaceRoot $created.WorkspaceRoot
    $wrongRecords = $replica | ConvertTo-Json -Depth 15 | ConvertFrom-Json
    $wrongRecords.OpenSpecRoot = $replica.WorkspaceRoot
    $misdirected = Invoke-Harness openspec.status -Context $wrongRecords
    Check ($misdirected.status -eq 'Failed' -and $misdirected.error.code -eq 'ContextAuthorityMismatch') 'mixed execution and record roots are rejected before native dispatch'
    Check (-not (Test-Path (Join-Path $replica.WorkspaceRoot '.git'))) 'replica root has no parent Git worktree'
    Check (Test-Path (Join-Path $replica.WorkspaceRoot 'Plugins/Foo/.git')) 'editable plugin is a Git worktree'
    Check (-not (Test-Path (Join-Path $replica.WorkspaceRoot 'Plugins/Bar/.git'))) 'dependency is an ordinary fixed snapshot'
    Check ((Get-Content (Join-Path $replica.WorkspaceRoot 'Plugins/Bar/owned.txt') -Raw) -eq 'committed baseline') 'snapshot excludes source uncommitted changes'
    Check (-not (Test-Path (Join-Path $replica.WorkspaceRoot 'Plugins/Unused'))) 'unneeded plugin is absent'
    $rootPublish = Invoke-Harness git.push -Context $replica -Parameters @{RepositoryBranches=@{'.'='main'};WhatIf=$true}
    Check ($rootPublish.status -eq 'Failed' -and $rootPublish.error.message -match 'Publish repository') 'replica publication cannot fall back to the primary Git root'
    $queue = Invoke-FixtureHarness $replica harness.queue.set @{Changes=@('fixture/test-queue-first','fixture/test-queue-second');ExpectedRevision=0}
    Check ($queue.planState -eq 'plan-needed' -and $null -eq $queue.progress) 'unplanned queue member has unknown task counts'
    Check (-not (Test-Path (Join-Path $replica.WorkspaceRoot 'openspec'))) 'canonical OpenSpec is not copied into replica'
    $conflict = Invoke-Harness -Context $main -Command harness.queue.set -Parameters @{Changes=@('fixture/test-queue-first');ExpectedRevision=0}
    Check ($conflict.status -eq 'Failed' -and $conflict.error.message -match 'assigned') 'primary cannot double-assign a replica Change'
    $centralView = Invoke-FixtureHarness $main harness.queue.status @{TargetWorkspaceRoot=$replica.WorkspaceRoot}
    Check ($centralView.counts.remaining -eq 2) 'control center reads target queue without executing it'
    $changeRoot = Join-Path $fixture 'openspec/changes/fixture/test-queue-first'
    W (Join-Path $changeRoot 'design.md') "## Call chains`n`nnone — fixture contains no product implementation.`n"
    W (Join-Path $changeRoot 'tasks.md') @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
---
## [x] 1.1 Base

**Files**
```diff
 base
```
**Verification**
```sh
base
```
## [ ] 1.2 Follow-up

**Files**
```diff
 next
```
**Verification**
```sh
next
```
'@
    $live = Invoke-FixtureHarness $replica harness.queue.status
    Check ($live.progress.total -eq 2 -and $live.progress.complete -eq 1 -and $live.ready -eq 1) 'TaskPlan progress is read from canonical records'
    $owned = Join-Path $replica.WorkspaceRoot 'Plugins/Foo/owned.txt'
    $initialOwner = Invoke-FixtureHarness $replica harness.queue.claim @{SessionId='fixture-session'}
    Invoke-FixtureHarness $replica harness.queue.checkpoint @{Token=$initialOwner.controller.token} | Out-Null
    $initialFooHead = G (Join-Path $replica.WorkspaceRoot 'Plugins/Foo') @('rev-parse','HEAD')
    W $owned 'plugin result'
    $commit = Invoke-FixtureHarness $replica git.commit @{RepositoryScopes=@{'Plugins/Foo'=@('owned.txt')};PluginsOnly=$true;PreserveOutsideStaged=$true;CommitMessage='replica result'}
    Check ($commit.Commits.Count -eq 1 -and $commit.Commits[0].Repository -eq 'Plugins/Foo') 'replica commits only the exact editable plugin'
    $ctxFromPlugin = New-HarnessContext -WorkspaceRoot (Join-Path $replica.WorkspaceRoot 'Plugins/Foo')
    Check ($ctxFromPlugin.WorkspaceRoot -eq $replica.WorkspaceRoot) 'plugin directory resolves to containing workspace'
    W (Join-Path $replica.WorkspaceRoot 'Plugins/Bar/Intermediate/build-cache.bin') 'keep generated cache'
    Invoke-FixtureHarness $replica workspace.prepare @{EditablePlugins=@('Bar')} | Out-Null
    Check (Test-Path (Join-Path $replica.WorkspaceRoot 'Plugins/Bar/.git')) 'later approved modification upgrades unchanged snapshot to worktree'
    Check ((Get-Content (Join-Path $replica.WorkspaceRoot 'Plugins/Bar/Intermediate/build-cache.bin') -Raw) -eq 'keep generated cache') 'snapshot upgrade preserves generated build outputs'
    $claimed = Invoke-FixtureHarness $replica harness.queue.claim @{SessionId='fixture-session'}
    Invoke-FixtureHarness $replica harness.queue.checkpoint @{Token=$claimed.controller.token} | Out-Null
    $execution = Get-Content (Join-Path $changeRoot 'attachments/data/harness-execution.json') -Raw | ConvertFrom-Json
    Check ($execution.source.host.files.Count -gt 0 -and $execution.source.repositories.Count -eq 2 -and $execution.sourceBaseline.recordBaseCommit) 'checkpoint captures actual host hashes and per-plugin source identity'
    $fooBefore = $execution.sourceBaseline.repositories | Where-Object path -eq 'Plugins/Foo'
    $fooAfter = $execution.repositories | Where-Object path -eq 'Plugins/Foo'
    Check ($fooBefore.head -eq $initialFooHead -and $fooAfter.baseCommit -eq $initialFooHead -and $fooAfter.resultCommit -ne $initialFooHead) 'later checkpoint retains the actual pre-implementation baseline'
    $specPath = Join-Path $fixture 'openspec/specs/fixture/query/spec.md'
    W $specPath 'original shared spec'
    $originalSpec = Invoke-FixtureHarness $replica harness.specs.read @{Spec='fixture/query'}
    Invoke-FixtureHarness $main harness.specs.write @{Spec='fixture/query';ExpectedSha256=$originalSpec.sha256;Content='first merge'} | Out-Null
    $stale = Invoke-Harness harness.specs.write -Context $replica -Parameters @{Spec='fixture/query';ExpectedSha256=$originalSpec.sha256;Content='stale merge'}
    Check ($stale.status -eq 'Failed' -and (Get-Content $specPath -Raw) -eq 'first merge') 'canonical spec writes reject stale replica content'
    # Exercise the checked-in command wrapper from a nested replica directory.
    foreach ($folder in @('harness','workspace-lifecycle')) {
        $scripts = Join-Path $fixture ".agents/skills/$folder/scripts"
        [void][IO.Directory]::CreateDirectory($scripts)
        $files = if ($folder -eq 'harness') { @('Invoke-HarnessCodexHook.ps1','DraftLifecycle.psm1','DraftLifecycle.psd1','draft_record.py') }
            else { @('WorkspaceLifecycle.psm1','WorkspaceLifecycle.psd1','WorkspaceReplica.ps1','workspace_files.py') }
        foreach ($file in $files) { Copy-Item (Join-Path $projectRoot ".agents/skills/$folder/scripts/$file") $scripts }
    }
    Invoke-FixtureHarness $replica harness.draft.create @{DraftId='fixture/hook';Title='Replica hook'} | Out-Null
    $source = Join-Path $replica.WorkspaceRoot 'Saved/session.jsonl'
    W $source ((@{type='session_meta';payload=@{id='replica-hook';cwd=$replica.WorkspaceRoot;cli_version='0.154.0'}} | ConvertTo-Json -Compress) + "`n")
    Invoke-FixtureHarness $replica harness.draft.record @{Action='bind';SessionId='replica-hook';DraftId='fixture/hook';Source=$source;StartLine=2} | Out-Null
    Add-Content $source (@{type='response_item';payload=@{type='message';role='assistant';phase='commentary';content=@(@{type='output_text';text='replica hook visible message'})}} | ConvertTo-Json -Depth 6 -Compress)
    $hooks = Get-Content (Join-Path $projectRoot '.codex/hooks.json') -Raw | ConvertFrom-Json
    $command = $hooks.hooks.Stop[0].hooks[0].commandWindows
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = (Get-Command pwsh).Source
    $info.Arguments = $command.Substring($command.IndexOf(' ') + 1)
    $info.WorkingDirectory = Join-Path $replica.WorkspaceRoot 'Plugins/Foo'
    $info.UseShellExecute=$false; $info.CreateNoWindow=$true; $info.RedirectStandardInput=$true; $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true
    $process = [Diagnostics.Process]::Start($info)
    $process.StandardInput.WriteLine((@{hook_event_name='Stop';cwd=$replica.WorkspaceRoot;session_id='replica-hook';transcript_path=$source} | ConvertTo-Json -Compress))
    $process.StandardInput.Close()
    $stdout=$process.StandardOutput.ReadToEnd(); $stderr=$process.StandardError.ReadToEnd()
    $process.WaitForExit()
    Check ($process.ExitCode -eq 0 -and [string]::IsNullOrWhiteSpace($stdout + $stderr)) 'registered hook command resolves replica without blocking output'
    $process.Dispose()
    Check ((Get-Content (Join-Path $fixture 'openspec/drafts/fixture/hook/log.md') -Raw).Contains('replica hook visible message')) 'replica hook records to canonical draft using local session binding'
    # Simulate a finished archive whose queue advance was interrupted.
    $queueFile = Join-Path $replica.WorkspaceRoot 'Saved/Harness/ChangeQueue/queue.json'
    $queueBeforeQuery = (Get-FileHash -LiteralPath $queueFile).Hash
    $archiveTarget = Join-Path $fixture 'openspec/archive/changes/fixture/2026-09-17-test-queue-first'
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($archiveTarget))
    $checkedSource = [IO.Path]::GetFullPath($changeRoot)
    $checkedTarget = [IO.Path]::GetFullPath($archiveTarget)
    $fixturePrefix = [IO.Path]::GetFullPath($fixture) + [IO.Path]::DirectorySeparatorChar
    if (-not $checkedSource.StartsWith($fixturePrefix) -or -not $checkedTarget.StartsWith($fixturePrefix)) { throw 'Archive fixture must remain inside its temporary root' }
    Move-Item -LiteralPath $checkedSource -Destination $checkedTarget
    Add-Content -LiteralPath (Join-Path $archiveTarget 'change.yaml') -Value "`nclosure:`n  kind: completed"
    $awaitingAdvance = Invoke-FixtureHarness $main harness.queue.status @{TargetWorkspaceRoot=$replica.WorkspaceRoot}
    Check ($awaitingAdvance.planState -eq 'archive-pending' -and $null -eq $awaitingAdvance.progress -and $awaitingAdvance.currentArchive) 'completed archive is awaiting advance rather than missing planning'
    Check ((Get-FileHash -LiteralPath $queueFile).Hash -eq $queueBeforeQuery) 'archive recovery query leaves queue ownership and revision unchanged'
    $advanced = Invoke-FixtureHarness $replica harness.queue.advance @{Token=$claimed.controller.token}
    Check ($advanced.currentChange -eq 'fixture/test-queue-second' -and $advanced.planState -eq 'plan-needed') 'archive recovery advances once and preserves missing-plan status for the next active Change'
    Invoke-FixtureHarness $replica harness.queue.release @{Token=$claimed.controller.token} | Out-Null
    Write-Output 'HarnessQueue.Tests.ps1: PASS'
} finally {
    $target = [IO.Path]::GetFullPath($fixture)
    if ($target.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath())) -and [IO.Path]::GetFileName($target).StartsWith('harness-queue-integration-')) { Remove-Item -LiteralPath $target -Recurse -Force }
}
