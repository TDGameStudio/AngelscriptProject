#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
& python -X utf8 -m unittest discover -s (Join-Path $projectRoot '.agents/skills/harness/tests') -p test_draft_record.py
if ($LASTEXITCODE -ne 0) { throw 'Transcript recorder behavior tests failed.' }
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('harness-record-hook-' + [guid]::NewGuid().ToString('N'))
$failures = [Collections.Generic.List[string]]::new()
function Check($ok, $message) { if (-not $ok) { $failures.Add($message) } }
function Invoke-FixtureHook($event, $sourcePath, $sessionId='fixture-session') {
    $info = [Diagnostics.ProcessStartInfo]::new((Get-Command pwsh).Source)
    foreach ($argument in @('-NoProfile','-File',(Join-Path $fixtureRoot '.agents/skills/harness/scripts/Invoke-HarnessCodexHook.ps1'))) { $info.ArgumentList.Add($argument) }
    $info.RedirectStandardInput=$true; $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true; $info.UseShellExecute=$false; $info.CreateNoWindow=$true
    $process = [Diagnostics.Process]::Start($info)
    $process.StandardInput.WriteLine((@{hook_event_name=$event; source='resume'; session_id=$sessionId; cwd=$fixtureRoot; transcript_path=$sourcePath} | ConvertTo-Json -Compress))
    $process.StandardInput.Close()
    $stdout=$process.StandardOutput.ReadToEnd(); $stderr=$process.StandardError.ReadToEnd()
    $process.WaitForExit()
    [pscustomobject]@{Out=$stdout; Error=$stderr; Exit=$process.ExitCode}
    $process.Dispose()
}
try {
    $scripts = Join-Path $fixtureRoot '.agents/skills/harness/scripts'
    [void][IO.Directory]::CreateDirectory($scripts)
    foreach ($file in @('Invoke-HarnessCodexHook.ps1','DraftLifecycle.psm1','DraftLifecycle.psd1','draft_record.py')) { Copy-Item (Join-Path $projectRoot ".agents/skills/harness/scripts/$file") $scripts }
    & git init -q $fixtureRoot
    $context = [pscustomobject]@{WorkspaceRoot=$fixtureRoot; HarnessRoot=$projectRoot; PrimaryRoot=$fixtureRoot; GitCommonDir=$fixtureRoot; Topology='Primary'; Branch='fixture'; Head=('1'*40)}
    [void](Invoke-Harness harness.draft.create -Context $context -Parameters @{DraftId='harness/fixture';Title='Hook fixture'})
    $source = Join-Path $fixtureRoot 'source.jsonl'
    $log = Join-Path $fixtureRoot 'openspec/drafts/harness/fixture/log.md'
    [IO.File]::WriteAllText($source, ((@{type='session_meta';payload=@{id='fixture-session';cwd=$fixtureRoot;cli_version='0.154.0'}} | ConvertTo-Json -Compress) + "`n"))
    & python -X utf8 (Join-Path $scripts 'draft_record.py') bind --workspace $fixtureRoot --session fixture-session --draft-id harness/fixture --source $source --start-line 2 | Out-Null
    foreach ($event in @('PostToolUse','Stop','Interrupt','SessionStart')) {
        $body = "Visible content at $event"
        Add-Content -LiteralPath $source -Value (@{type='response_item';payload=@{type='message';role='assistant';phase='final_answer';content=@(@{type='output_text';text=$body})}} | ConvertTo-Json -Depth 6 -Compress)
        $result = Invoke-FixtureHook $event $source
        Check ((Get-Content $log -Raw).Contains($body)) "$event did not record delivered content"
        Check ($result.Exit -eq 0) "$event must not block the agent"
        if ($event -ne 'SessionStart') { Check ([string]::IsNullOrWhiteSpace($result.Out)) "$event successful recording should be quiet" }
    }
    $before = Get-Content $log -Raw
    [void](Invoke-FixtureHook Stop $source)
    Check ((Get-Content $log -Raw) -ceq $before) 'hook replay duplicated content'
    Add-Content $source '{"type":"response_item","payload":{"type":"unknown"}}'
    $gap = Invoke-FixtureHook Stop $source
    Check (-not [string]::IsNullOrWhiteSpace($gap.Error)) 'unsupported source must surface a concise gap'
    Check ($gap.Out -notmatch '"decision"\s*:\s*"block"') 'recording failure must not restart the assistant'
    $unbound = Invoke-FixtureHook Stop $source 'another-session'
    Check ([string]::IsNullOrWhiteSpace($unbound.Out + $unbound.Error)) 'unbound session must remain quiet'
    $route = Invoke-Harness harness.draft.record -Context $context -Parameters @{Action='status'; SessionId='fixture-session'}
    Check ($route.status -eq 'Succeeded') 'public Harness recording route must read the same binding'
    Check ($route.data.binding.last_hook.event -eq 'Stop') 'status must expose the last hook checkpoint separately from manual sync'
    if ($failures.Count) { throw ($failures -join "`n") }
    'Harness recording route and hook tests passed.'
}
finally {
    $resolved=[IO.Path]::GetFullPath($fixtureRoot)
    $prefix=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar + 'harness-record-hook-'
    if (-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe cleanup path' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
