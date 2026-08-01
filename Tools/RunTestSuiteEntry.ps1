<#
.SYNOPSIS
    Internal process boundary for one typed test-suite entry.

.DESCRIPTION
    Used by the parallel suite runner for non-Unreal entries. The entry is
    selected from the shared catalog by suite name and zero-based index so no
    executable command line is stored in the suite definition.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Suite,

    [Parameter(Mandatory = $true)]
    [int]$EntryIndex,

    [Parameter(Mandatory = $true)]
    [string]$RunLabel,

    [Parameter(Mandatory = $true)]
    [string]$ResultPath,

    [string]$OutputRoot = '',
    [int]$TimeoutMs = 0,
    [int]$ExecutionSlot = 0,
    [switch]$NoReport,
    [switch]$Fast,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\TestSuiteDefinitions.ps1')
. (Join-Path $PSScriptRoot 'Shared\TestSuiteEntryRunner.ps1')

$entries = @(Get-AngelscriptTestSuiteEntries -SuiteName $Suite)
if ($EntryIndex -lt 0 -or $EntryIndex -ge $entries.Count) {
    throw "EntryIndex $EntryIndex is outside suite '$Suite' (count $($entries.Count))."
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$runTestsPath = Join-Path $PSScriptRoot 'RunTests.ps1'
$entry = $entries[$EntryIndex]
$result = Invoke-AngelscriptTestSuiteEntry `
    -Entry $entry `
    -ProjectRoot $projectRoot `
    -RunTestsPath $runTestsPath `
    -RunLabel $RunLabel `
    -OutputRoot $OutputRoot `
    -TimeoutMs $TimeoutMs `
    -ExecutionSlot $ExecutionSlot `
    -NoReport:$NoReport `
    -Fast:$Fast `
    -DryRun:$DryRun

$resultDirectory = Split-Path -Parent $ResultPath
if (-not [string]::IsNullOrWhiteSpace($resultDirectory)) {
    New-Item -ItemType Directory -Path $resultDirectory -Force | Out-Null
}

$record = [ordered]@{
    Kind = [string]$entry.Kind
    Label = [string]$entry.Label
    RunLabel = $RunLabel
    ExitCode = [int]$result.ExitCode
    RawExitCode = [int]$result.RawExitCode
    OutputRoot = if ($result.PSObject.Properties.Name -contains 'OutputRoot') { $result.OutputRoot } else { $null }
    MetadataPath = if ($result.PSObject.Properties.Name -contains 'MetadataPath') { $result.MetadataPath } else { $null }
    SummaryPath = if ($result.PSObject.Properties.Name -contains 'SummaryPath') { $result.SummaryPath } else { $null }
    TimedOut = if ($result.PSObject.Properties.Name -contains 'TimedOut') { [bool]$result.TimedOut } else { $false }
    TimedOutPhase = if ($result.PSObject.Properties.Name -contains 'TimedOutPhase') { [string]$result.TimedOutPhase } else { '' }
}
Write-Utf8JsonFile -Path $ResultPath -Value $record -Depth 6
exit ([int]$result.ExitCode)
