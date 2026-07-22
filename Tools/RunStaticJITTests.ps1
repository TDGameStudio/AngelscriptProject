<#
.SYNOPSIS
    Prepare the paired StaticJIT AOT artifacts and run the StaticJIT automation prefix.

.DESCRIPTION
    StaticJIT AOT precompiled data serializes reference identities that are embedded
    in the generated .jit.cpp/.jit.hpp sources. The cache is therefore valid only
    after the commandlet has generated both artifacts and UBT has compiled the
    generated sources. This runner keeps that required build -> generate -> build
    -> test sequence in one explicit, test-only entry point.
#>
[CmdletBinding()]
param(
    [string]$LabelPrefix = 'staticjit-aot',

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

function Invoke-StaticJITGeneration {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $true)]
        [string]$GenerationLabel,

        [Parameter(Mandatory = $true)]
        [int]$TimeoutMs
    )

    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $outputRoot = Join-Path $projectRoot 'Saved\StaticJIT\Preflight'
    $outputLabelRoot = Join-Path (Join-Path $outputRoot 'Commandlet') $GenerationLabel

    Write-Host '----------------------------------------------------------------'
    Write-Host 'StaticJIT step: Generate paired AOT artifacts'
    Write-Host ("Command       : powershell.exe -File {0}" -f $ScriptPath)
    Write-Host '----------------------------------------------------------------'

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath `
        -Commandlet 'AngelscriptStaticJITAotTest' `
        -Label $GenerationLabel `
        -OutputRoot $outputRoot `
        -TimeoutMs $TimeoutMs `
        -ExtraArgs '-Mode=Generate'
    $processExitCode = $LASTEXITCODE
    if ($processExitCode -eq 0) {
        return
    }

    # Unreal can convert unrelated project-startup log errors into a non-zero
    # host process code after this commandlet has already returned result 0.
    # Do not generally suppress commandlet failures: only continue after
    # proving this invocation reported success and wrote every paired artifact.
    $metadataPath = Get-ChildItem -Path $outputLabelRoot -Filter 'RunMetadata.json' -File -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1 -ExpandProperty FullName
    if ([string]::IsNullOrWhiteSpace($metadataPath)) {
        throw "StaticJIT generation failed with exit code $processExitCode and wrote no run metadata."
    }

    $metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
    $logPath = [string]$metadata.LogPath
    if ([string]::IsNullOrWhiteSpace($logPath) -or -not (Test-Path -LiteralPath $logPath -PathType Leaf)) {
        throw "StaticJIT generation failed with exit code $processExitCode and wrote no commandlet log."
    }

    $logText = Get-Content -LiteralPath $logPath -Raw
    $reportedSuccess = $logText -match 'Commandlet .*AngelscriptStaticJITAotTestCommandlet.*finished execution \(result 0\)'
    $writtenArtifactCount = [regex]::Matches($logText, 'StaticJIT AOT wrote ').Count
    $generatedDirectory = Join-Path $projectRoot 'Plugins\Angelscript\Source\AngelscriptTest\StaticJIT\AOT\Generated'
    $requiredArtifacts = @(
        'ASStaticJITAotFixture.as.jit.hpp',
        'AngelscriptJitCode_0.jit.cpp',
        'AngelscriptJitInfo.jit.cpp',
        'StaticJITAotFixture.Cache'
    )
    $missingArtifacts = @($requiredArtifacts | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $generatedDirectory $_) -PathType Leaf)
    })

    if (-not $reportedSuccess -or $writtenArtifactCount -ne $requiredArtifacts.Count -or $missingArtifacts.Count -ne 0) {
        throw ("StaticJIT generation failed with exit code {0}; commandlet success={1}, written artifacts={2}, missing artifacts={3}. See {4}" -f `
            $processExitCode, $reportedSuccess, $writtenArtifactCount, ($missingArtifacts -join ', '), $logPath)
    }

    Write-Warning ("StaticJIT generation completed successfully, but Unreal returned exit code {0} after unrelated project-startup errors. Artifact success was verified from {1}." -f $processExitCode, $logPath)
}

$testPrefix = if ($AotOnly) {
    'Angelscript.TestModule.StaticJIT.AOT'
}
else {
    'Angelscript.TestModule.StaticJIT'
}

Write-Host '================================================================'
Write-Host '  Angelscript StaticJIT AOT Test Runner'
Write-Host '================================================================'
Write-Host ("LabelPrefix         : {0}" -f $LabelPrefix)
Write-Host ("TestPrefix          : {0}" -f $testPrefix)
Write-Host ("BuildTimeoutMs      : {0}" -f $BuildTimeoutMs)
Write-Host ("CommandletTimeoutMs : {0}" -f $CommandletTimeoutMs)
Write-Host ("TestTimeoutMs       : {0}" -f $TestTimeoutMs)
Write-Host '================================================================'

Invoke-StaticJITStep -Name 'Baseline build' -ScriptPath $runBuildPath -Arguments @(
    '-Label', ("{0}_01_baseline_build" -f $LabelPrefix),
    '-TimeoutMs', $BuildTimeoutMs
)

Invoke-StaticJITGeneration `
    -ScriptPath $runCommandletPath `
    -GenerationLabel ("{0}_02_generate" -f $LabelPrefix) `
    -TimeoutMs $CommandletTimeoutMs

Invoke-StaticJITStep -Name 'Build generated AOT sources' -ScriptPath $runBuildPath -Arguments @(
    '-Label', ("{0}_03_generated_build" -f $LabelPrefix),
    '-TimeoutMs', $BuildTimeoutMs
)

Invoke-StaticJITStep -Name 'Run StaticJIT automation' -ScriptPath $runTestsPath -Arguments @(
    '-TestPrefix', $testPrefix,
    '-Label', ("{0}_04_tests" -f $LabelPrefix),
    '-TimeoutMs', $TestTimeoutMs
)

Write-Host ''
Write-Host 'StaticJIT AOT preparation and automation tests completed successfully.' -ForegroundColor Green
