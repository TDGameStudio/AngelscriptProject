#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $root '.agents/skills/harness/scripts/Harness.psd1') -Force
$exe = Join-Path $root '.agents/skills/openspec/bin/openspec.exe'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('harness-mutation-gates-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($fixture)
$context = [pscustomobject]@{HarnessRoot=$root;WorkspaceRoot=$fixture;PrimaryRoot=$fixture;GitCommonDir=$fixture;Topology='Primary';Branch='fixture';Head=('1'*40)}
$failures = [Collections.Generic.List[string]]::new()
function Check($Condition, [string]$Message) { if (-not $Condition) { $failures.Add($Message); Write-Output "FAIL: $Message" } }
function Write-Fixture([string]$Path, [string]$Text) { [void][IO.Directory]::CreateDirectory((Split-Path $Path)); [IO.File]::WriteAllText($Path,$Text) }
function Native([string[]]$Arguments) {
    Push-Location $fixture
    try { & $exe @Arguments | Out-Null; if ($LASTEXITCODE) { throw "Native fixture setup failed: $Arguments" } }
    finally { Pop-Location }
}
function New-Case([string]$Name, [string]$Evidence='fresh', [string]$Kind='completed', [switch]$NoTasks) {
    $id = "fixture/fix-mutation-$Name"
    Native @('change','create',$id,'--title',$Name,'--goal','Exercise mutation boundaries','--json')
    $folder = Join-Path $fixture "openspec/changes/$id"
    Write-Fixture (Join-Path $folder 'proposal.md') '# A focused fixture'
    if (-not $NoTasks) {
        Write-Fixture (Join-Path $folder 'tasks.md') @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---
## [x] 1.1 Prove the fixture outcome

**Files**

```diff
 fixture
```

**Verification**

```sh
fixture proof
```
'@
    }
    Write-Fixture (Join-Path $folder 'attachments/INDEX.md') "# INDEX`n`n- ``data/workflow-evaluation.md`` - Terminal fixture evidence.`n"
    if ($Evidence -ne 'missing') {
        $state = Invoke-Harness harness.evolution.status -Context $context -Parameters @{Change=$id;ClosureKind=$Kind}
        if ($state.status -ne 'Succeeded') { throw $state.error.message }
        $evaluationKind = if ($Evidence -eq 'wrong-kind') { 'completed' } else { $Kind }
        Write-Fixture (Join-Path $folder 'attachments/data/workflow-evaluation.md') "---`nrecord: harness-workflow-evaluation-v1`nresult: passed`nchange: $id`nclosure_kind: $evaluationKind`ninput_sha256: $($state.data.CurrentInputSha256)`ncaptured_at: $([DateTimeOffset]::UtcNow.ToString('o'))`n---`n`n# Evidence`nFixture proof.`n"
        if ($Evidence -eq 'stale') { Add-Content (Join-Path $folder 'proposal.md') 'A material change after evaluation.' }
    }
    $closure = Join-Path $fixture "$Name.yaml"
    Write-Fixture $closure "kind: '$Kind' # Explicit closure kind`nreason: Bounded fixture`ntask_dispositions: {}`n"
    return @{Id=$id;Folder=$folder;Closure=$closure}
}
try {
    Native @('init',$fixture,'--project-id','mutation-fixture','--title','Mutation fixture','--workflow','spec-driven','--language','en')
    Native @('domain','create','fixture','--title','Fixture','--json')
    $index=0
    foreach ($route in @('openspec.change','OPENSPEC.CHANGE','OpenSpec.Change')) {
        $id = "fixture/fix-raw-$index"; $index++
        $actual = Invoke-Harness -Command $route -Context $context -ArgumentList @('create',$id,'--title','Raw','--goal','No approval','--json')
        Check ($actual.status -eq 'Failed' -and $actual.error.code -eq 'ChangeCreationGate') "Raw Create rejected for $route"
        Check (-not (Test-Path (Join-Path $fixture "openspec/changes/$id"))) "Raw Create leaves no directory for $route"
    }
    foreach($case in @(@{name='missing';evidence='missing';kind='completed'},@{name='stale';evidence='stale';kind='completed'},@{name='wrong';evidence='wrong-kind';kind='abandoned'})) {
        $item = New-Case $case.name $case.evidence $case.kind
        $before = (Get-FileHash (Join-Path $item.Folder 'change.yaml')).Hash
        $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$item.Id,'--closure-file',$item.Closure,'--json')
        Check ($actual.status -eq 'Failed') "Archive rejects $($case.name) terminal evaluation"
        Check ((Test-Path (Join-Path $item.Folder 'change.yaml')) -and (Get-FileHash (Join-Path $item.Folder 'change.yaml')).Hash -eq $before) "Archive preserves active manifest after $($case.name) rejection"
    }
    $format = New-Case 'format'
    foreach ($content in @("kind: completed`nkind: abandoned`nreason: duplicate", "kind: *unresolved`nreason: ambiguous")) {
        Write-Fixture $format.Closure $content
        $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$format.Id,'--closure-file',$format.Closure,'--json')
        Check ($actual.status -eq 'Failed' -and (Test-Path $format.Folder)) 'Ambiguous closure kind cannot select a different terminal contract'
    }
    Write-Fixture $format.Closure '{"kind":"completed","reason":"JSON fixture","task_dispositions":{}}'
    $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$format.Id,'--closure-file',$format.Closure,"--closure-file=$($format.Closure)",'--json')
    Check ($actual.status -eq 'Failed' -and (Test-Path $format.Folder)) 'Duplicate closure options cannot split checked and consumed files'
    $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$format.Id,'--closure-file',$format.Closure,'--json')
    Check ($actual.status -eq 'Succeeded' -and -not (Test-Path $format.Folder)) 'Explicit JSON closure uses the same terminal gate'
    $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive','--help')
    Check ($actual.status -eq 'Succeeded') 'Archive help stays read-only without a terminal target'
    $valid = New-Case 'valid'
    $actual = Invoke-Harness OpenSpec.Change -Context $context -ArgumentList @('archive',$valid.Id,"--closure-file=$($valid.Closure)",'--json')
    Check ($actual.status -eq 'Succeeded' -and -not (Test-Path $valid.Folder)) 'Valid completed archive passes with equals option and canonical route handling'
    $early = New-Case 'early' 'fresh' 'abandoned' -NoTasks
    $terminal = Invoke-Harness harness.evolution.status -Context $context -Parameters @{Change=$early.Id;ClosureKind='abandoned';RequireTerminal=$true}
    Check ($terminal.status -eq 'Succeeded') 'Explicit early abandonment with fresh evidence requires no fabricated Task DAG'
    $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$early.Id,'--closure-file',(Split-Path $early.Closure -Leaf),'--json')
    Check ($actual.status -eq 'Succeeded' -and -not (Test-Path $early.Folder)) 'Early abandonment archives using a canonical-record-root relative closure path'
    $invalid = New-Case 'invalid' 'fresh' 'abandoned' -NoTasks
    Write-Fixture (Join-Path $invalid.Folder 'tasks.md') '# Present but not a TaskPlan'
    $actual = Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$invalid.Id,'--closure-file',$invalid.Closure,'--json')
    Check ($actual.status -eq 'Failed' -and (Test-Path $invalid.Folder)) 'Incomplete closure never exempts an existing invalid plan'
    Check (@(Get-ChildItem -LiteralPath (Join-Path $fixture 'Saved/AgentTemp/harness-archive') -File).Count -eq 0) 'Checked closure snapshots are cleaned after archive'
    if ($failures.Count) { throw "Mutation Gate failures: $($failures -join '; ')" }
    'HarnessMutationGate.Tests.ps1: PASS'
}
finally {
    $resolved = [IO.Path]::GetFullPath($fixture)
    $allowed = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar + 'harness-mutation-gates-'
    if (-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe fixture cleanup' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
