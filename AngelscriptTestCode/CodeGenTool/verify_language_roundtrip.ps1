[CmdletBinding()]
param(
    $Context
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'AngelscriptTestCode/CodeGenTool/codegen.py'))) {
    $repoRoot = (Get-Location).Path
}

if ($null -eq $Context) {
    Import-Module (Join-Path $repoRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
    $Context = New-HarnessContext -WorkspaceRoot $repoRoot
}

$selector = 'Angelscript.UnitTest.Framework.LanguageFixtureCorpus.DumpsAllAuthoredSources'
$python = Join-Path $repoRoot 'AngelscriptTestCode/CodeGenTool/language_roundtrip.py'
$codegen = Join-Path $repoRoot 'AngelscriptTestCode/CodeGenTool/codegen.py'
$authorRoot = Join-Path $repoRoot 'AngelscriptTestCode'
$generatedRoot = Join-Path $repoRoot 'Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated'
$snapshotBefore = Join-Path $repoRoot 'Saved/Harness/Temp/language-roundtrip-before.json'
$controlDir = Join-Path $repoRoot 'Saved/Harness/Temp/language-roundtrip-controls'
$expectedTemp = Join-Path $repoRoot 'Saved/Harness/Temp/language-roundtrip-expected.as'

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $snapshotBefore) | Out-Null

python $codegen check
if ($LASTEXITCODE -ne 0) { throw 'codegen check failed; projections are not synchronized' }

python $python --author-root $authorRoot --generated-root $generatedRoot --snapshot $snapshotBefore
if ($LASTEXITCODE -ne 0) { throw 'failed to capture source snapshot' }

python $python --author-root $authorRoot --write-expected $expectedTemp
if ($LASTEXITCODE -ne 0) { throw 'failed to write expected aggregate' }

python $python --author-root $authorRoot --self-test $controlDir
if ($LASTEXITCODE -ne 0) { throw 'round-trip negative controls failed' }

$build = Invoke-Harness -Command ue.build -Context $Context -Parameters @{ TimeoutMs = 1800000 }
if ($build.ExitCode -ne 0 -and $build.exitCode -ne 0) {
    throw "ue.build failed: $($build | ConvertTo-Json -Depth 6)"
}

$test = Invoke-Harness -Command ue.test -Context $Context -Parameters @{
    TestPrefix = $selector
    Fast       = $true
    TimeoutMs  = 600000
}

$runId = $null
if ($null -ne $test.Data -and $test.Data.PSObject.Properties['RunId']) {
    $runId = [string]$test.Data.RunId
}
if ([string]::IsNullOrWhiteSpace($runId) -and $test.PSObject.Properties['RunId']) {
    $candidate = [string]$test.RunId
    if ($candidate -match '^[a-f0-9]{32}$') {
        $runId = $candidate
    }
}
if ([string]::IsNullOrWhiteSpace($runId)) {
    New-Item -ItemType Directory -Force -Path (Join-Path $repoRoot 'Saved/Harness/Temp/language-roundtrip-failed') | Out-Null
    Copy-Item -Force $expectedTemp (Join-Path $repoRoot 'Saved/Harness/Temp/language-roundtrip-failed/Expected.as')
    throw "ue.test did not return a Harness Unreal RunId. Result=$( $test | ConvertTo-Json -Depth 6 )"
}

$runRoot = Join-Path $repoRoot "Saved/Harness/Unreal/Runs/$runId"
$corpusDir = Join-Path $runRoot 'HandwrittenCorpus'
$actual = Join-Path $corpusDir 'Actual.as'
$expected = Join-Path $corpusDir 'Expected.as'
$comparison = Join-Path $corpusDir 'Comparison.json'
New-Item -ItemType Directory -Force -Path $corpusDir | Out-Null
Copy-Item -Force $expectedTemp $expected

$testFailed = ($test.Status -ne 'Succeeded' -and $test.status -ne 'Succeeded') -or (
    $null -ne $test.Data -and $test.Data.PSObject.Properties['State'] -and [string]$test.Data.State -ne 'Succeeded'
)
if ($testFailed) {
    throw "ue.test failed for $selector runId=$runId. Preserve $corpusDir"
}

$reportCandidates = @(
    (Join-Path $runRoot 'AutomationReport/index.json'),
    (Join-Path $runRoot 'AutomationReport.json')
)
$reportPath = $reportCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($reportPath)) {
    throw "Automation report is missing beside Unreal.log in $runRoot"
}
$report = Get-Content -LiteralPath $reportPath -Raw -Encoding utf8 | ConvertFrom-Json
$tests = @($report.tests)
$exact = $tests | Where-Object { [string]$_.fullTestPath -eq $selector }
if ($null -eq $exact) {
    throw "exact executed-case evidence missing: $selector"
}
if ([string]$exact.state -ne 'Success') {
    throw "$selector state is $($exact.state), expected Success"
}

python $python --expected $expected --actual $actual --comparison $comparison
if ($LASTEXITCODE -ne 0) { throw "round-trip comparison failed; see $comparison" }

$snapshotAfter = Join-Path $corpusDir 'source-snapshot-after.json'
python $python --author-root $authorRoot --generated-root $generatedRoot --snapshot $snapshotAfter
if ($LASTEXITCODE -ne 0) { throw 'failed to recapture source snapshot' }
$before = Get-Content -LiteralPath $snapshotBefore -Raw -Encoding utf8
$after = Get-Content -LiteralPath $snapshotAfter -Raw -Encoding utf8
if ($before -ne $after) {
    throw 'author or generated snapshot changed during the captured run'
}

Copy-Item -Force $snapshotBefore (Join-Path $corpusDir 'source-snapshot-before.json')
Write-Host "Language fixture round-trip passed runId=$runId actual=$actual"
