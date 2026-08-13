<#
.SYNOPSIS
    Generate, rebuild, verify, and test the Editor-only AngelscriptTestJIT provider.

.DESCRIPTION
    The committed TestJIT provider is generated from isolated plugin-owned source
    fixtures and compiled by the normal Editor target. Runtime proof uses current
    source compilation and a fresh Engine restored from an isolated Cache V2 root;
    no legacy paired .Cache artifact is read or written beside generated C++.

    Mode All runs the reproducible end-to-end order:
      baseline build -> Generate -> generated-source rebuild -> Verify -> tests.
    Mode Generate runs the first two stages so callers can inspect/commit output.
    Mode Verify runs read-only Verify followed by the focused automation tests.
#>
[CmdletBinding()]
param(
    [ValidateSet('All', 'Generate', 'Verify')]
    [string]$Mode = 'All',

    [string]$LabelPrefix = 'staticjit-testjit',

    [int]$BuildTimeoutMs = 1800000,

    [int]$CommandletTimeoutMs = 600000,

    [int]$TestTimeoutMs = 600000,

    [switch]$AotOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

foreach ($Timeout in @($BuildTimeoutMs, $CommandletTimeoutMs, $TestTimeoutMs)) {
    if ($Timeout -le 0) {
        throw 'All timeout values must be positive milliseconds.'
    }
}

$runBuildPath = Join-Path $PSScriptRoot 'RunBuild.ps1'
$runCommandletPath = Join-Path $PSScriptRoot 'RunCommandlet.ps1'
$runTestsPath = Join-Path $PSScriptRoot 'RunTests.ps1'
foreach ($RequiredPath in @($runBuildPath, $runCommandletPath, $runTestsPath)) {
    if (-not (Test-Path -LiteralPath $RequiredPath -PathType Leaf)) {
        throw "Required runner was not found: $RequiredPath"
    }
}

function Invoke-StaticJITStep {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Host '----------------------------------------------------------------'
    Write-Host ("StaticJIT step: {0}" -f $Name)
    Write-Host ("Command       : powershell.exe {0}" -f (($Arguments | ForEach-Object { '"{0}"' -f $_ }) -join ' '))
    Write-Host '----------------------------------------------------------------'

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "StaticJIT step '$Name' failed with exit code $LASTEXITCODE."
    }
}

function Invoke-TestJITCommandlet {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Generate', 'Verify')]
        [string]$CommandMode,

        [Parameter(Mandatory = $true)]
        [string]$GenerationLabel,

        [Parameter(Mandatory = $true)]
        [int]$TimeoutMs
    )

    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $outputRoot = Join-Path $projectRoot 'Saved\StaticJIT\TestJIT'
    $modeArgument = if ($CommandMode -eq 'Generate') {
        '-Mode=Generate'
    }
    else {
        '-Mode=Verify'
    }
    Invoke-StaticJITStep `
        -Name ("AngelscriptTestJIT {0}" -f $CommandMode) `
        -ScriptPath $runCommandletPath `
        -Arguments @(
            '-Commandlet', 'AngelscriptTestJIT',
            '-Label', $GenerationLabel,
            '-OutputRoot', $outputRoot,
            '-TimeoutMs', $TimeoutMs,
            '-ExtraArgs', $modeArgument
        )
}

$testPrefix = if ($AotOnly) {
    'Angelscript.TestModule.StaticJIT.AOT'
}
else {
    'Angelscript.TestModule.StaticJIT'
}

Write-Host '================================================================'
Write-Host '  Angelscript TestJIT Provider Runner'
Write-Host '================================================================'
Write-Host ("Mode                : {0}" -f $Mode)
Write-Host ("LabelPrefix         : {0}" -f $LabelPrefix)
Write-Host ("TestPrefix          : {0}" -f $testPrefix)
Write-Host ("BuildTimeoutMs      : {0}" -f $BuildTimeoutMs)
Write-Host ("CommandletTimeoutMs : {0}" -f $CommandletTimeoutMs)
Write-Host ("TestTimeoutMs       : {0}" -f $TestTimeoutMs)
Write-Host '================================================================'

if ($Mode -in @('All', 'Generate')) {
    Invoke-StaticJITStep -Name 'Baseline Editor build' -ScriptPath $runBuildPath -Arguments @(
        '-Label', ("{0}_01_baseline_build" -f $LabelPrefix),
        '-TimeoutMs', $BuildTimeoutMs,
        '-NoXGE'
    )

    Invoke-TestJITCommandlet `
        -CommandMode 'Generate' `
        -GenerationLabel ("{0}_02_generate" -f $LabelPrefix) `
        -TimeoutMs $CommandletTimeoutMs
}

if ($Mode -eq 'All') {
    Invoke-StaticJITStep -Name 'Build generated TestJIT sources' -ScriptPath $runBuildPath -Arguments @(
        '-Label', ("{0}_03_generated_build" -f $LabelPrefix),
        '-TimeoutMs', $BuildTimeoutMs,
        '-NoXGE'
    )
}

if ($Mode -in @('All', 'Verify')) {
    $verifyOrdinal = if ($Mode -eq 'All') { '04' } else { '01' }
    $testOrdinal = if ($Mode -eq 'All') { '05' } else { '02' }

    Invoke-TestJITCommandlet `
        -CommandMode 'Verify' `
        -GenerationLabel ("{0}_{1}_verify" -f $LabelPrefix, $verifyOrdinal) `
        -TimeoutMs $CommandletTimeoutMs

    Invoke-StaticJITStep -Name 'Run StaticJIT automation' -ScriptPath $runTestsPath -Arguments @(
        '-TestPrefix', $testPrefix,
        '-Label', ("{0}_{1}_tests" -f $LabelPrefix, $testOrdinal),
        '-TimeoutMs', $TestTimeoutMs
    )
}

Write-Host ''
Write-Host ("Angelscript TestJIT mode '{0}' completed successfully." -f $Mode) -ForegroundColor Green
