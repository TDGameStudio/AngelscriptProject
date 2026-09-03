[CmdletBinding()]
param()

#Requires -Version 7.0
#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal {
    param($Expected, $Actual, [string] $Message)
    if ($Expected -ne $Actual) {
        throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')"
    }
}

function Assert-Match {
    param([string] $Actual, [string] $Pattern, [string] $Message)
    if ($Actual -notmatch $Pattern) {
        throw "Assertion failed: $Message (actual '$Actual', pattern '$Pattern')"
    }
}

function New-UeAutomationTest {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][ValidateSet('Success', 'Fail', 'NotRun', 'InProcess', 'Skipped')][string] $State,
        [int] $Warnings = 0,
        [int] $Errors = 0
    )
    return [pscustomobject][ordered]@{
        testDisplayName = ($Path -split '\.')[-1]
        fullTestPath    = $Path
        state           = $State
        deviceInstance  = @('FixtureDevice')
        duration        = 0.01
        dateTime        = '2026.09.03-12.00.00'
        entries         = if ($Errors -gt 0) {
            @([pscustomobject][ordered]@{ event = [pscustomobject][ordered]@{ type = 'Error'; message = "Failure in $Path" } })
        }
        elseif ($Warnings -gt 0) {
            @([pscustomobject][ordered]@{ event = [pscustomobject][ordered]@{ type = 'Warning'; message = "Warning in $Path" } })
        }
        else { @() }
        warnings        = $Warnings
        errors          = $Errors
        artifacts       = @()
    }
}

function New-UeAutomationReport {
    param(
        [Parameter(Mandatory = $true)][object[]] $Tests,
        [int] $Succeeded = 0,
        [int] $SucceededWithWarnings = 0,
        [int] $Failed = 0,
        [int] $NotRun = 0,
        [int] $InProcess = 0
    )
    return [pscustomobject][ordered]@{
        devices               = @()
        reportCreatedOn       = '2026.09.03-12.00.00'
        succeeded             = $Succeeded
        succeededWithWarnings = $SucceededWithWarnings
        failed                = $Failed
        notRun                = $NotRun
        inProcess             = $InProcess
        totalDuration         = 0.01
        comparisonExported    = $false
        comparisonExportDirectory = ''
        tests                 = @($Tests)
    }
}

function Write-UeAutomationReport {
    param([Parameter(Mandatory = $true)][string] $Directory, [Parameter(Mandatory = $true)] $Value)
    [void][System.IO.Directory]::CreateDirectory($Directory)
    $path = Join-Path $Directory 'index.json'
    [System.IO.File]::WriteAllText($path, ($Value | ConvertTo-Json -Depth 20), [System.Text.UTF8Encoding]::new($false))
    return $path
}

$parserPath = Join-Path $PSScriptRoot '../scripts/Private/AutomationReport.ps1'
if (-not (Test-Path -LiteralPath $parserPath -PathType Leaf)) {
    throw "Automation report parser was not found: $parserPath"
}
. $parserPath

$scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("unreal-automation-report-tests-{0}" -f [guid]::NewGuid().ToString('N'))
[void][System.IO.Directory]::CreateDirectory($scratch)
try {
    $passDirectory = Join-Path $scratch 'pass'
    $passReport = New-UeAutomationReport -Succeeded 2 -Tests @(
        New-UeAutomationTest -Path 'Angelscript.Fixture.PassOne' -State Success
        New-UeAutomationTest -Path 'Angelscript.Fixture.PassTwo' -State Success
    )
    $passIndex = Write-UeAutomationReport -Directory $passDirectory -Value $passReport
    $pass = Get-UnrealAutomationSummary -ReportPath $passDirectory -ProcessExitCode 0
    Assert-Equal 'hardness-unreal-automation-summary-v1' $pass.SchemaVersion 'the parser emits a versioned result'
    Assert-Equal 'UEAutomationJson' $pass.SummarySource 'a valid index.json is structured UE truth'
    Assert-Equal 'Passed' $pass.Outcome 'a complete successful report passes'
    Assert-True $pass.Passed 'the pass flag is true for successful structured truth'
    Assert-True $pass.Complete 'the pass report is complete'
    Assert-Equal 2 $pass.Total 'total includes every serialized test'
    Assert-Equal 2 $pass.Succeeded 'successful count is retained'
    Assert-Equal $passIndex $pass.ReportPath 'a report directory resolves to index.json'

    $warningDirectory = Join-Path $scratch 'warnings'
    $warningReport = New-UeAutomationReport -SucceededWithWarnings 1 -Tests @(
        New-UeAutomationTest -Path 'Angelscript.Fixture.Warning' -State Success -Warnings 1
    )
    [void](Write-UeAutomationReport -Directory $warningDirectory -Value $warningReport)
    $warning = Get-UnrealAutomationSummary -ReportPath (Join-Path $warningDirectory 'index.json') -ProcessExitCode 0
    Assert-Equal 'PassedWithWarnings' $warning.Outcome 'warnings remain a successful distinct outcome'
    Assert-True $warning.Passed 'warnings do not fail structured Automation truth'
    Assert-Equal 1 $warning.SucceededWithWarnings 'the UE warning-success count is retained'
    Assert-Equal 1 $warning.Warnings 'per-test warnings are aggregated'

    $failureDirectory = Join-Path $scratch 'failure'
    $failureReport = New-UeAutomationReport -Failed 1 -Tests @(
        New-UeAutomationTest -Path 'Angelscript.Fixture.Failure' -State Fail -Errors 1
    )
    [void](Write-UeAutomationReport -Directory $failureDirectory -Value $failureReport)
    $failure = Get-UnrealAutomationSummary -ReportPath $failureDirectory -ProcessExitCode 0
    Assert-Equal 'Failed' $failure.Outcome 'structured failures override a zero process exit'
    Assert-True (-not $failure.Passed) 'a failing report is not successful'
    Assert-Equal 1 $failure.Failed 'the failed count is retained'
    Assert-Equal 1 @($failure.FailedTests).Count 'failed test details are retained'
    Assert-Equal 'Angelscript.Fixture.Failure' $failure.FailedTests[0].FullTestPath 'failed test identity is exact'

    $skipDirectory = Join-Path $scratch 'skipped'
    $skipReport = New-UeAutomationReport -Succeeded 1 -Tests @(
        New-UeAutomationTest -Path 'Angelscript.Fixture.Pass' -State Success
        New-UeAutomationTest -Path 'Angelscript.Fixture.Skipped' -State Skipped -Warnings 1
    )
    [void](Write-UeAutomationReport -Directory $skipDirectory -Value $skipReport)
    $skipped = Get-UnrealAutomationSummary -ReportPath $skipDirectory -ProcessExitCode 0
    Assert-Equal 'PassedWithWarnings' $skipped.Outcome 'a UE skipped test is complete and warning-bearing'
    Assert-Equal 1 $skipped.Skipped 'Skipped is derived from tests because UE omits a top-level count'
    Assert-Equal 2 $skipped.Total 'total includes skipped tests omitted from UE aggregate counts'
    Assert-Equal 1 @($skipped.SkippedTests).Count 'skipped test details are retained'

    $incompleteDirectory = Join-Path $scratch 'incomplete'
    $incompleteReport = New-UeAutomationReport -NotRun 1 -InProcess 1 -Tests @(
        New-UeAutomationTest -Path 'Angelscript.Fixture.NotRun' -State NotRun
        New-UeAutomationTest -Path 'Angelscript.Fixture.StillRunning' -State InProcess
    )
    [void](Write-UeAutomationReport -Directory $incompleteDirectory -Value $incompleteReport)
    $incomplete = Get-UnrealAutomationSummary -ReportPath $incompleteDirectory -ProcessExitCode 0
    Assert-Equal 'Incomplete' $incomplete.Outcome 'NotRun or InProcess makes structured truth incomplete'
    Assert-True (-not $incomplete.Complete) 'incomplete tests clear the completion flag'
    Assert-Equal 2 @($incomplete.IncompleteTests).Count 'incomplete test details include both UE states'

    $missing = Get-UnrealAutomationSummary -ReportPath (Join-Path $scratch 'missing') -ProcessExitCode 0
    Assert-Equal 'None' $missing.SummarySource 'a missing index has no structured source'
    Assert-Equal 'Missing' $missing.Outcome 'zero exit with no structured report is not success'
    Assert-True (-not $missing.Passed) 'missing structured truth fails closed'

    $malformedDirectory = Join-Path $scratch 'malformed'
    [void][System.IO.Directory]::CreateDirectory($malformedDirectory)
    [System.IO.File]::WriteAllText((Join-Path $malformedDirectory 'index.json'), '{ invalid', [System.Text.UTF8Encoding]::new($false))
    $malformed = Get-UnrealAutomationSummary -ReportPath $malformedDirectory -ProcessExitCode 0
    Assert-Equal 'None' $malformed.SummarySource 'malformed JSON is not structured truth'
    Assert-Equal 'Malformed' $malformed.Outcome 'malformed JSON fails with a distinct outcome'
    Assert-Match ($malformed.Reasons -join ' ') 'invalid' 'malformed JSON exposes a bounded diagnostic reason'

    $nonZero = Get-UnrealAutomationSummary -ReportPath $passDirectory -ProcessExitCode 7
    Assert-Equal 'Failed' $nonZero.Outcome 'a non-zero process exit fails even with a passing report'
    Assert-Equal 7 $nonZero.ProcessExitCode 'the native exit code is retained'

    $inconsistentDirectory = Join-Path $scratch 'inconsistent-success'
    $inconsistentReport = New-UeAutomationReport -Succeeded 1 -Tests @(
        New-UeAutomationTest -Path 'Angelscript.Fixture.InconsistentSuccess' -State Success -Errors 1
    )
    [void](Write-UeAutomationReport -Directory $inconsistentDirectory -Value $inconsistentReport)
    $inconsistent = Get-UnrealAutomationSummary -ReportPath $inconsistentDirectory -ProcessExitCode 0
    Assert-True (-not $inconsistent.Passed) 'a Success test carrying errors cannot yield Passed'
    Assert-Equal 'Malformed' $inconsistent.Outcome 'an error-bearing Success state is inconsistent structured truth'

    $manyFailureDirectory = Join-Path $scratch 'many-failures'
    $manyFailureTests = @(1..205 | ForEach-Object { New-UeAutomationTest -Path "Angelscript.Fixture.Failure$_" -State Fail -Errors 1 })
    $manyFailureReport = New-UeAutomationReport -Failed 205 -Tests $manyFailureTests
    [void](Write-UeAutomationReport -Directory $manyFailureDirectory -Value $manyFailureReport)
    $manyFailures = Get-UnrealAutomationSummary -ReportPath $manyFailureDirectory -ProcessExitCode 0
    Assert-Equal 205 $manyFailures.FailedTestsTotal 'the actual failed-test detail count is retained'
    Assert-Equal 200 @($manyFailures.FailedTests).Count 'retained failed-test details are bounded'
    Assert-True $manyFailures.FailedTestsTruncated 'failed-test detail truncation is explicit'

    $oversizeDirectory = Join-Path $scratch 'oversize'
    [void][System.IO.Directory]::CreateDirectory($oversizeDirectory)
    $oversizePath = Join-Path $oversizeDirectory 'index.json'
    $originalMaximum = $script:UnrealAutomationMaxReportBytes
    try {
        $script:UnrealAutomationMaxReportBytes = 1024
        $stream = [System.IO.File]::Open($oversizePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try { $stream.SetLength(1025) }
        finally { $stream.Dispose() }
        $oversize = Get-UnrealAutomationSummary -ReportPath $oversizeDirectory -ProcessExitCode 0
    }
    finally {
        $script:UnrealAutomationMaxReportBytes = $originalMaximum
    }
    Assert-Equal 134217728 $originalMaximum 'the production structured-report limit is 128 MiB'
    Assert-Equal 'Malformed' $oversize.Outcome 'an oversized report is rejected before JSON loading'
    Assert-Equal 1025 $oversize.ReportBytes 'the rejected report size is explicit'
    Assert-Match ($oversize.Reasons -join ' ') 'maximum|size' 'oversized report rejection explains the bound'

    $logPath = Join-Path $scratch 'large-command.log'
    $tailHints = 1..30 | ForEach-Object { "LogAutomationController: Error: bounded-tail-hint-$_" }
    $largeLog = ('x' * 270000) + "`nLogAutomationController: Error: truncated-head-hint`n" + ($tailHints -join "`n")
    [System.IO.File]::WriteAllText($logPath, $largeLog, [System.Text.UTF8Encoding]::new($false))
    $bounded = Get-UnrealAutomationSummary -ReportPath $passDirectory -LogPath $logPath -ProcessExitCode 0
    Assert-True $bounded.LogTruncated 'large logs are read from a bounded tail window'
    Assert-True ($bounded.LogBytesInspected -le 262144) 'no more than 256 KiB of log data is inspected'
    Assert-True (@($bounded.LogFailureHints).Count -le 20) 'at most twenty log failure hints are retained'
    Assert-True (@($bounded.LogFailureHints | Where-Object { $_.Length -gt 512 }).Count -eq 0) 'each retained log hint is bounded to 512 characters'
    Assert-Match ($bounded.LogFailureHints -join ' ') 'bounded-tail-hint-30' 'the newest bounded failure evidence is retained'
    Assert-Equal 'Passed' $bounded.Outcome 'text hints do not override complete structured UE truth'
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        $tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        $resolvedScratch = [System.IO.Path]::GetFullPath($scratch)
        if (-not $resolvedScratch.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            [System.IO.Path]::GetFileName($resolvedScratch) -notlike 'unreal-automation-report-tests-*') {
            throw "Refusing to remove unexpected Automation report test path: $resolvedScratch"
        }
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
}

Write-Output 'AutomationReport.Tests.ps1: PASS'
