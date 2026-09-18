#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
foreach ($suite in @('test_draft_record.py')) {
    & python -X utf8 -m unittest discover -s (Join-Path $projectRoot '.agents/skills/harness/tests') -p $suite
    if ($LASTEXITCODE -ne 0) { throw "$suite failed." }
}
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('harness-record-route-' + [guid]::NewGuid().ToString('N'))
$failures = [Collections.Generic.List[string]]::new()
function Check($ok, $message) { if (-not $ok) { $failures.Add($message) } }
try {
    $scripts = Join-Path $fixtureRoot '.agents/skills/harness/scripts'
    [void][IO.Directory]::CreateDirectory($scripts)
    foreach ($file in @('DraftLifecycle.psm1','DraftLifecycle.psd1','draft_record.py')) { Copy-Item (Join-Path $projectRoot ".agents/skills/harness/scripts/$file") $scripts }
    & git init -q $fixtureRoot
    $context = [pscustomobject]@{WorkspaceRoot=$fixtureRoot; HarnessRoot=$projectRoot; PrimaryRoot=$fixtureRoot; GitCommonDir=$fixtureRoot; Topology='Primary'; Branch='fixture'; Head=('1'*40)}
    [void](Invoke-Harness harness.draft.create -Context $context -Parameters @{DraftId='harness/fixture';Title='Record fixture'})
    $source = Join-Path $fixtureRoot 'source.jsonl'
    $log = Join-Path $fixtureRoot 'openspec/drafts/harness/fixture/attachments/transcript.md'
    $contextFile = Join-Path $fixtureRoot 'openspec/drafts/harness/fixture/CONTEXT.md'
    $contextHash = (Get-FileHash -LiteralPath $contextFile).Hash
    Check (-not (Test-Path -LiteralPath $log)) 'new draft does not start recording without an explicit bind'
    [IO.File]::WriteAllText($source, ((@{type='session_meta';payload=@{id='fixture-session';cwd=$fixtureRoot;cli_version='0.154.0'}} | ConvertTo-Json -Compress) + "`n"))
    $bind = Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='bind'; SessionId='fixture-session'; DraftId='harness/fixture'; Source=$source; StartLine=2}
    Check ($bind.status -eq 'Succeeded') 'public bind must succeed'
    $body = 'Visible content at public sync'
    Add-Content -LiteralPath $source -Value (@{type='response_item';payload=@{type='message';role='assistant';phase='final_answer';content=@(@{type='output_text';text=$body})}} | ConvertTo-Json -Depth 6 -Compress)
    $sync = Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='sync'; SessionId='fixture-session'}
    Check ($sync.status -eq 'Succeeded') 'public sync must succeed'
    Check ((Get-Content $log -Raw).Contains($body)) 'sync did not record delivered content'
    Check ((Get-FileHash -LiteralPath $contextFile).Hash -eq $contextHash) 'optional recording preserves key-decision context'
    $before = Get-Content $log -Raw
    [void](Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='sync'; SessionId='fixture-session'})
    Check ((Get-Content $log -Raw) -ceq $before) 'sync replay duplicated content'
    Add-Content $source '{"type":"response_item","payload":{"type":"unknown"}}'
    $gap = Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='sync'; SessionId='fixture-session'}
    Check ($gap.status -eq 'Failed') 'unsupported source must surface a concise gap'
    $unbound = Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='status'; SessionId='another-session'}
    Check ($unbound.status -eq 'Succeeded' -and $unbound.data.status -eq 'unbound') 'unbound session must remain unbound'
    $route = Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='status'; SessionId='fixture-session'}
    Check ($route.status -eq 'Succeeded') 'public Harness recording route must read the same binding'
    $hasLastHook = $null -ne $route.data.binding -and @($route.data.binding.PSObject.Properties.Name) -contains 'last_hook'
    Check (-not $hasLastHook) 'public sync must not require a Codex hook checkpoint'
    if ($failures.Count) { throw ($failures -join "`n") }
    'Harness recording route tests passed.'
}
finally {
    $resolved=[IO.Path]::GetFullPath($fixtureRoot)
    $prefix=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar + 'harness-record-route-'
    if (-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe cleanup path' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
