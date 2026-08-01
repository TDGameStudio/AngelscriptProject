[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Invoke-TestCase {
    param([string]$Name, [scriptblock]$Body)
    Write-Host "[test] $Name"
    & $Body
    Write-Host "[pass] $Name" -ForegroundColor Green
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
. (Join-Path $repoRoot 'Tools\Shared\TestSuiteDefinitions.ps1')
. (Join-Path $repoRoot 'Tools\Shared\TestSuiteEntryRunner.ps1')

Invoke-TestCase -Name 'CatalogReturnsTypedStandaloneEntryAndPromotesItToAll' -Body {
    $standalone = @(Get-AngelscriptTestSuiteEntries -SuiteName 'Standalone')
    Assert-Equal 1 $standalone.Count 'Standalone should contain one entry.'
    Assert-Equal 'CMakeCTest' $standalone[0].Kind 'Standalone should use CMake/CTest.'
    $allStandalone = @(
        Get-AngelscriptTestSuiteEntries -SuiteName 'All' |
            Where-Object { $_.Kind -eq 'CMakeCTest' -and $_.Label -eq 'Standalone' }
    )
    Assert-Equal 1 $allStandalone.Count 'All should contain exactly one Standalone entry after the soak gate.'
}

Invoke-TestCase -Name 'CatalogKeepsReleaseStandaloneIndependentAndBuildsPackage' -Body {
    $release = @(Get-AngelscriptTestSuiteEntries -SuiteName 'StandaloneRelease')
    Assert-Equal 1 $release.Count 'StandaloneRelease should contain one entry.'
    Assert-Equal 'CMakeCTest' $release[0].Kind 'StandaloneRelease should use CMake/CTest.'
    Assert-Equal 'win64-msvc-release' $release[0].CMakeBuildPreset `
        'StandaloneRelease should select the Release build preset.'
    Assert-Equal 'win64-msvc-release' $release[0].CTestPreset `
        'StandaloneRelease should select the Release CTest preset.'
    Assert-Equal 1 @($release[0].CMakeAdditionalBuildTargets).Count `
        'StandaloneRelease should declare one additional package target.'
    Assert-Equal 'AngelscriptStandalonePackage' @($release[0].CMakeAdditionalBuildTargets)[0] `
        'StandaloneRelease should build the final package target.'

    $allRelease = @(
        Get-AngelscriptTestSuiteEntries -SuiteName 'All' |
            Where-Object { $_.Label -eq 'StandaloneRelease' }
    )
    Assert-Equal 0 $allRelease.Count 'StandaloneRelease must not be duplicated in All.'
}

Invoke-TestCase -Name 'LegacyEntriesNormalizeToUnrealAutomation' -Body {
    $smoke = @(Get-AngelscriptTestSuiteEntries -SuiteName 'Smoke')
    Assert-True ($smoke.Count -gt 0) 'Smoke should not be empty.'
    Assert-True (-not (@($smoke.Kind | Where-Object { $_ -ne 'UnrealAutomation' }).Count -gt 0)) `
        'Every legacy prefix entry should normalize to UnrealAutomation.'
}

Invoke-TestCase -Name 'UnrealAutomationOutputDoesNotPolluteTypedResult' -Body {
    function powershell.exe {
        param([Parameter(ValueFromRemainingArguments = $true)]$Arguments)
        Write-Output 'fixture child output'
        Write-Output 'fixture child output 2'
        $global:LASTEXITCODE = 7
    }

    try {
        $entry = @{
            Kind = 'UnrealAutomation'
            Label = 'Fixture'
            Prefix = 'Angelscript.TestModule.Fixture'
        }
        $result = Invoke-AngelscriptTestSuiteEntry -Entry $entry `
            -ProjectRoot $repoRoot `
            -RunTestsPath (Join-Path $repoRoot 'Tools\RunTests.ps1') `
            -RunLabel 'fixture-unreal-output'
        Assert-Equal 'System.Management.Automation.PSCustomObject' $result.GetType().FullName `
            'Child stdout must not turn the typed result into a heterogeneous array.'
        Assert-Equal 7 $result.ExitCode 'The child exit code must be returned.'
        Assert-Equal 7 $result.RawExitCode 'The child raw exit code must be retained.'
    }
    finally {
        Remove-Item function:powershell.exe -ErrorAction SilentlyContinue
    }
}

Invoke-TestCase -Name 'CMakeCTestWritesSuccessMetadata' -Body {
    $testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-testsuite-selftest-' + [guid]::NewGuid().ToString('N'))
    try {
        New-Item -ItemType Directory -Path (Join-Path $testRoot 'work') -Force | Out-Null
        $script:TestPhaseNumber = 0
        function Invoke-AngelscriptCTestPhase {
            param($Executable, $Arguments, $WorkingDirectory, $DeadlineUtc, $Phase, $LogPath)
            $script:TestPhaseNumber++
            $text = if ($Phase -eq 'CTest') { '100% tests passed, 0 tests failed out of 2' } else { "$Phase ok" }
            [System.IO.File]::WriteAllText($LogPath, $text)
            [PSCustomObject]@{
                Phase = $Phase
                ExitCode = 0
                TimedOut = $false
                DurationMs = 1
                LogPath = $LogPath
            }
        }

        $entry = @{
            Kind = 'CMakeCTest'
            Label = 'Fixture'
            WorkingDirectory = 'work'
            CMakeConfigurePreset = 'configure'
            CMakeBuildPreset = 'build'
            CTestPreset = 'test'
        }
        $result = Invoke-AngelscriptCMakeCTestEntry -Entry $entry -ProjectRoot $testRoot `
            -RunLabel 'fixture-success' -OutputRoot (Join-Path $testRoot 'output') -TimeoutMs 5000
        Assert-Equal 0 $result.ExitCode 'Successful phases must produce exit zero.'
        Assert-Equal 3 $script:TestPhaseNumber 'Configure, build, and CTest should all run.'
        $summary = Get-Content -LiteralPath $result.SummaryPath -Raw | ConvertFrom-Json
        Assert-Equal 2 ([int]$summary.Total) 'CTest totals should be parsed.'
        Assert-Equal 'Passed' $summary.Status 'Summary should report Passed.'
    }
    finally {
        if (Test-Path -LiteralPath $testRoot) {
            Remove-Item -LiteralPath $testRoot -Recurse -Force
        }
    }
}

Invoke-TestCase -Name 'CMakeCTestRunsAdditionalBuildTargetsBeforeCTest' -Body {
    $testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-testsuite-additional-target-selftest-' + [guid]::NewGuid().ToString('N'))
    try {
        New-Item -ItemType Directory -Path (Join-Path $testRoot 'work') -Force | Out-Null
        $script:ObservedPhases = New-Object 'System.Collections.Generic.List[object]'
        function Invoke-AngelscriptCTestPhase {
            param($Executable, $Arguments, $WorkingDirectory, $DeadlineUtc, $Phase, $LogPath)
            $script:ObservedPhases.Add([PSCustomObject]@{
                    Phase = $Phase
                    Arguments = @($Arguments)
                })
            $text = if ($Phase -eq 'CTest') { '100% tests passed, 0 tests failed out of 2' } else { "$Phase ok" }
            [System.IO.File]::WriteAllText($LogPath, $text)
            [PSCustomObject]@{
                Phase = $Phase
                ExitCode = 0
                TimedOut = $false
                DurationMs = 1
                LogPath = $LogPath
            }
        }

        $entry = @{
            Kind = 'CMakeCTest'
            Label = 'FixtureRelease'
            WorkingDirectory = 'work'
            CMakeConfigurePreset = 'configure'
            CMakeBuildPreset = 'release-build'
            CMakeAdditionalBuildTargets = @('AngelscriptStandalonePackage')
            CTestPreset = 'release-test'
        }
        $result = Invoke-AngelscriptCMakeCTestEntry -Entry $entry -ProjectRoot $testRoot `
            -RunLabel 'fixture-additional-target' -OutputRoot (Join-Path $testRoot 'output') -TimeoutMs 5000
        Assert-Equal 0 $result.ExitCode 'Additional build target fixture should succeed.'
        Assert-Equal 4 $script:ObservedPhases.Count `
            'Configure, build, package target, and CTest should all run.'
        Assert-Equal 'AdditionalBuild-AngelscriptStandalonePackage' $script:ObservedPhases[2].Phase `
            'The additional package target should run after the normal build.'
        Assert-Equal '--target' $script:ObservedPhases[2].Arguments[3] `
            'The additional phase should use the CMake target switch.'
        Assert-Equal 'AngelscriptStandalonePackage' $script:ObservedPhases[2].Arguments[4] `
            'The additional phase should select the requested target.'

        $metadata = Get-Content -LiteralPath $result.MetadataPath -Raw | ConvertFrom-Json
        Assert-Equal 'AngelscriptStandalonePackage' @($metadata.AdditionalBuildTargets)[0] `
            'Metadata should retain the additional build target.'
    }
    finally {
        if (Test-Path -LiteralPath $testRoot) {
            Remove-Item -LiteralPath $testRoot -Recurse -Force
        }
    }
}

Invoke-TestCase -Name 'CMakeCTestStopsAtTimedOutBuildAndPreservesRawExit' -Body {
    $testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-testsuite-timeout-selftest-' + [guid]::NewGuid().ToString('N'))
    try {
        New-Item -ItemType Directory -Path (Join-Path $testRoot 'work') -Force | Out-Null
        $script:TestPhaseNumber = 0
        function Invoke-AngelscriptCTestPhase {
            param($Executable, $Arguments, $WorkingDirectory, $DeadlineUtc, $Phase, $LogPath)
            $script:TestPhaseNumber++
            [System.IO.File]::WriteAllText($LogPath, "$Phase fixture")
            [PSCustomObject]@{
                Phase = $Phase
                ExitCode = if ($Phase -eq 'Build') { 124 } else { 0 }
                TimedOut = ($Phase -eq 'Build')
                DurationMs = 1
                LogPath = $LogPath
            }
        }

        $entry = @{
            Kind = 'CMakeCTest'
            Label = 'Fixture'
            WorkingDirectory = 'work'
            CMakeConfigurePreset = 'configure'
            CMakeBuildPreset = 'build'
            CTestPreset = 'test'
        }
        $result = Invoke-AngelscriptCMakeCTestEntry -Entry $entry -ProjectRoot $testRoot `
            -RunLabel 'fixture-timeout' -OutputRoot (Join-Path $testRoot 'output') -TimeoutMs 5000
        Assert-Equal 1 $result.ExitCode 'Timeout should normalize to suite failure.'
        Assert-Equal 124 $result.RawExitCode 'Raw process timeout code must be retained.'
        Assert-Equal 'Build' $result.TimedOutPhase 'Timed-out phase should be explicit.'
        Assert-Equal 2 $script:TestPhaseNumber 'CTest must not run after build timeout.'
    }
    finally {
        if (Test-Path -LiteralPath $testRoot) {
            Remove-Item -LiteralPath $testRoot -Recurse -Force
        }
    }
}

Write-Host 'RunTestSuite self-tests passed.'
