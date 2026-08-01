Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'UnrealCommandUtils.ps1')

function Invoke-AngelscriptCTestPhase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Executable,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [DateTime]$DeadlineUtc,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [Parameter(Mandatory = $true)]
        [string]$LogPath
    )

    $remainingTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $DeadlineUtc -PhaseName $Phase
    $processResult = Invoke-StreamingProcess `
        -FilePath $Executable `
        -ArgumentList $Arguments `
        -WorkingDirectory $WorkingDirectory `
        -TimeoutMs $remainingTimeoutMs `
        -LogPath $LogPath `
        -Label "standalone-$($Phase.ToLowerInvariant())"
    $processResult | Add-Member -NotePropertyName Phase -NotePropertyValue $Phase -Force
    return $processResult
}

function Invoke-AngelscriptCMakeCTestEntry {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string]$RunLabel,

        [string]$OutputRoot = '',

        [int]$TimeoutMs = 600000,

        [switch]$DryRun
    )

    $workingDirectory = Normalize-PathValue -Path (Join-Path $ProjectRoot ([string]$Entry.WorkingDirectory))
    $layout = New-CommandOutputLayout `
        -ProjectRoot $ProjectRoot `
        -Category 'StandaloneTests' `
        -Label $RunLabel `
        -RequestedOutputRoot $OutputRoot `
        -LogFileName 'Standalone.log' `
        -ReportFolderName 'Artifacts'

    $configureLog = Join-Path $layout.OutputRoot 'Configure.log'
    $buildLog = Join-Path $layout.OutputRoot 'Build.log'
    $ctestLog = Join-Path $layout.OutputRoot 'CTest.log'
    $metadataPath = Join-Path $layout.OutputRoot 'RunMetadata.json'
    $summaryPath = Join-Path $layout.OutputRoot 'Summary.json'

    $cmake = Get-Command cmake.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $cmake) {
        $cmake = Get-Command cmake -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    $ctest = Get-Command ctest.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $ctest) {
        $ctest = Get-Command ctest -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($null -eq $cmake -or $null -eq $ctest) {
        throw 'Standalone suite requires cmake and ctest on PATH.'
    }

    $additionalBuildTargets = if ($Entry.ContainsKey('CMakeAdditionalBuildTargets')) {
        @($Entry.CMakeAdditionalBuildTargets | Where-Object {
                -not [string]::IsNullOrWhiteSpace([string]$_)
            } | ForEach-Object { [string]$_ })
    }
    else {
        @()
    }

    $phaseDefinitions = New-Object 'System.Collections.Generic.List[object]'
    $phaseDefinitions.Add([PSCustomObject]@{
            Name = 'Configure'
            Executable = [string]$cmake.Source
            Arguments = @('--preset', [string]$Entry.CMakeConfigurePreset)
            LogPath = $configureLog
        })
    $phaseDefinitions.Add([PSCustomObject]@{
            Name = 'Build'
            Executable = [string]$cmake.Source
            Arguments = @('--build', '--preset', [string]$Entry.CMakeBuildPreset)
            LogPath = $buildLog
        })
    foreach ($additionalBuildTarget in $additionalBuildTargets) {
        $safeTargetName = $additionalBuildTarget -replace '[^A-Za-z0-9_.-]', '_'
        $phaseDefinitions.Add([PSCustomObject]@{
                Name = "AdditionalBuild-$additionalBuildTarget"
                Executable = [string]$cmake.Source
                Arguments = @(
                    '--build',
                    '--preset', [string]$Entry.CMakeBuildPreset,
                    '--target', $additionalBuildTarget
                )
                LogPath = Join-Path $layout.OutputRoot "AdditionalBuild-$safeTargetName.log"
            })
    }
    $phaseDefinitions.Add([PSCustomObject]@{
            Name = 'CTest'
            Executable = [string]$ctest.Source
            Arguments = @('--preset', [string]$Entry.CTestPreset, '--output-on-failure')
            LogPath = $ctestLog
        })

    if ($DryRun) {
        foreach ($phaseDefinition in $phaseDefinitions) {
            Write-Host ("[DryRun] {0} {1}" -f $phaseDefinition.Executable, ($phaseDefinition.Arguments -join ' '))
        }
        return [PSCustomObject]@{
            Kind = 'CMakeCTest'
            Label = $RunLabel
            ExitCode = 0
            RawExitCode = 0
            OutputRoot = $layout.OutputRoot
            MetadataPath = $metadataPath
            SummaryPath = $summaryPath
            TimedOut = $false
            TimedOutPhase = ''
        }
    }

    $deadlineUtc = New-ExecutionDeadline -TimeoutMs $TimeoutMs
    $phaseResults = New-Object 'System.Collections.Generic.List[object]'
    $failedPhase = ''
    $timedOutPhase = ''
    $rawExitCode = 0
    $startedAtUtc = [DateTime]::UtcNow

    foreach ($phaseDefinition in $phaseDefinitions) {
        $phaseResult = Invoke-AngelscriptCTestPhase `
            -Executable $phaseDefinition.Executable `
            -Arguments $phaseDefinition.Arguments `
            -WorkingDirectory $workingDirectory `
            -DeadlineUtc $deadlineUtc `
            -Phase $phaseDefinition.Name `
            -LogPath $phaseDefinition.LogPath
        $phaseResults.Add($phaseResult)

        if ($phaseResult.ExitCode -ne 0) {
            $failedPhase = $phaseDefinition.Name
            $rawExitCode = [int]$phaseResult.ExitCode
            if ($phaseResult.TimedOut) {
                $timedOutPhase = $phaseDefinition.Name
            }
            break
        }
    }

    $combinedLogBuilder = New-Object System.Text.StringBuilder
    foreach ($phaseResult in $phaseResults) {
        [void]$combinedLogBuilder.AppendLine(("=== {0} ===" -f $phaseResult.Phase))
        if (Test-Path -LiteralPath $phaseResult.LogPath -PathType Leaf) {
            [void]$combinedLogBuilder.AppendLine((Get-Content -LiteralPath $phaseResult.LogPath -Raw -Encoding UTF8))
        }
    }
    [System.IO.File]::WriteAllText(
        $layout.LogPath,
        $combinedLogBuilder.ToString(),
        (New-Object System.Text.UTF8Encoding($false)))

    $ctestText = if (Test-Path -LiteralPath $ctestLog -PathType Leaf) {
        Get-Content -LiteralPath $ctestLog -Raw -Encoding UTF8
    }
    else {
        ''
    }
    $totalTests = 0
    $failedTests = 0
    $passedTests = 0
    $countMatch = [regex]::Match($ctestText, '(\d+)% tests passed,\s+(\d+) tests failed out of\s+(\d+)')
    if ($countMatch.Success) {
        $failedTests = [int]$countMatch.Groups[2].Value
        $totalTests = [int]$countMatch.Groups[3].Value
        $passedTests = $totalTests - $failedTests
    }

    $finalExitCode = if ($rawExitCode -eq 0) { 0 } else { 1 }
    $metadata = [ordered]@{
        Kind = 'CMakeCTest'
        Label = [string]$Entry.Label
        RunLabel = $RunLabel
        WorkingDirectory = $workingDirectory
        OutputRoot = $layout.OutputRoot
        TimeoutMs = $TimeoutMs
        StartedAtUtc = $startedAtUtc.ToString('o')
        CompletedAtUtc = [DateTime]::UtcNow.ToString('o')
        FailedPhase = $failedPhase
        TimedOut = -not [string]::IsNullOrWhiteSpace($timedOutPhase)
        TimedOutPhase = $timedOutPhase
        ProcessExitCode = $rawExitCode
        FinalExitCode = $finalExitCode
        ConfigurePreset = [string]$Entry.CMakeConfigurePreset
        BuildPreset = [string]$Entry.CMakeBuildPreset
        AdditionalBuildTargets = @($additionalBuildTargets)
        CTestPreset = [string]$Entry.CTestPreset
        LogPath = $layout.LogPath
        PhaseResults = @($phaseResults | ForEach-Object {
                [ordered]@{
                    Phase = $_.Phase
                    ExitCode = $_.ExitCode
                    TimedOut = $_.TimedOut
                    DurationMs = $_.DurationMs
                    LogPath = $_.LogPath
                }
            })
    }
    $summary = [ordered]@{
        Kind = 'CMakeCTest'
        Label = $RunLabel
        Status = if ($finalExitCode -eq 0) { 'Passed' } elseif (-not [string]::IsNullOrWhiteSpace($timedOutPhase)) { 'TimedOut' } else { 'Failed' }
        Total = $totalTests
        Passed = $passedTests
        Failed = $failedTests
        ProcessExitCode = $rawExitCode
        FinalExitCode = $finalExitCode
        FailedPhase = $failedPhase
        TimedOutPhase = $timedOutPhase
    }
    Write-Utf8JsonFile -Path $metadataPath -Value $metadata -Depth 10
    Write-Utf8JsonFile -Path $summaryPath -Value $summary -Depth 6

    return [PSCustomObject]@{
        Kind = 'CMakeCTest'
        Label = $RunLabel
        ExitCode = $finalExitCode
        RawExitCode = $rawExitCode
        OutputRoot = $layout.OutputRoot
        MetadataPath = $metadataPath
        SummaryPath = $summaryPath
        TimedOut = -not [string]::IsNullOrWhiteSpace($timedOutPhase)
        TimedOutPhase = $timedOutPhase
    }
}

function Invoke-AngelscriptTestSuiteEntry {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string]$RunTestsPath,

        [Parameter(Mandatory = $true)]
        [string]$RunLabel,

        [string]$OutputRoot = '',

        [int]$TimeoutMs = 0,

        [int]$ExecutionSlot = 0,

        [switch]$Fast,

        [switch]$NoReport,

        [switch]$DryRun
    )

    switch ([string]$Entry.Kind) {
        'UnrealAutomation' {
            $arguments = @(
                '-NoProfile',
                '-ExecutionPolicy', 'Bypass',
                '-File', $RunTestsPath,
                '-TestPrefix', [string]$Entry.Prefix,
                '-Label', $RunLabel
            )
            if ($ExecutionSlot -gt 0) {
                $arguments += @('-ExecutionSlot', $ExecutionSlot)
            }
            if (-not [string]::IsNullOrWhiteSpace($OutputRoot)) {
                $arguments += @('-OutputRoot', $OutputRoot)
            }
            if ($TimeoutMs -gt 0) {
                $arguments += @('-TimeoutMs', $TimeoutMs)
            }
            if ($NoReport) {
                $arguments += '-NoReport'
            }
            if ($Fast) {
                $arguments += '-Fast'
            }

            if ($DryRun) {
                Write-Host "[DryRun] powershell.exe $($arguments -join ' ')"
                return [PSCustomObject]@{ Kind = 'UnrealAutomation'; Label = $RunLabel; ExitCode = 0; RawExitCode = 0 }
            }

            & powershell.exe @arguments | Out-Host
            $rawExitCode = [int]$LASTEXITCODE
            return [PSCustomObject]@{
                Kind = 'UnrealAutomation'
                Label = $RunLabel
                ExitCode = $rawExitCode
                RawExitCode = $rawExitCode
            }
        }
        'CMakeCTest' {
            $effectiveTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs 600000 -ParameterName 'TimeoutMs'
            return Invoke-AngelscriptCMakeCTestEntry `
                -Entry $Entry `
                -ProjectRoot $ProjectRoot `
                -RunLabel $RunLabel `
                -OutputRoot $OutputRoot `
                -TimeoutMs $effectiveTimeoutMs `
                -DryRun:$DryRun
        }
        default {
            throw "Unsupported suite entry kind '$($Entry.Kind)' for label '$($Entry.Label)'."
        }
    }
}
