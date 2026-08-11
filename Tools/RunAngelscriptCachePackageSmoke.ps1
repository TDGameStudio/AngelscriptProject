<#
.SYNOPSIS
    Package and execute the real Cache V2 Development/Shipping launch matrix.

.DESCRIPTION
    This is intentionally separate from the normal All automation suite. It
    mutates only a disposable archived loose Script tree and keeps Cache V2,
    process logs, C++ session JSON, and the combined summary under that archive.

    With -SkipPackage, -OutputRoot must be the exact prior smoke-run root that
    already contains Archive. This prevents guessing or mutating a workspace
    Script directory.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Development', 'Shipping')]
    [string]$Configuration,

    [string]$Label = 'cache-package',

    [string]$OutputRoot = '',

    [int]$TimeoutMs = 3600000,

    [switch]$SkipPackage
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
Import-Module (Join-Path $PSScriptRoot 'Shared\AngelscriptCachePackageSmoke.psm1') -Force

function Get-SingleCacheDumpGenerationId {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$Document,

        [Parameter(Mandatory = $true)]
        [string]$ScenarioId
    )

    $generations = New-Object System.Collections.Generic.List[object]
    foreach ($namespace in @($Document.namespaces)) {
        foreach ($generation in @($namespace.generations)) {
            $generations.Add($generation) | Out-Null
        }
    }
    if ($Document.PSObject.Properties.Name -contains 'generations') {
        foreach ($generation in @($Document.generations)) {
            $generations.Add($generation) | Out-Null
        }
    }
    if ($generations.Count -ne 1) {
        throw "Scenario '$ScenarioId' expected exactly one selected persisted Generation; found $($generations.Count)."
    }
    $generationId = [string]$generations[0].generation_id
    if ($generationId -notmatch '^[0-9a-f]{64}$') {
        throw "Scenario '$ScenarioId' dump returned an invalid Generation id."
    }
    return $generationId
}

function Assert-CacheDumpSessionCorrelation {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$Document,

        [Parameter(Mandatory = $true)]
        [string]$ScenarioId,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedGenerationId,

        [switch]$ExpectCurrent
    )

    if ($Document.PSObject.Properties.Name -notcontains 'session_correlation') {
        throw "Scenario '$ScenarioId' dump omitted C++ session correlation."
    }
    $current = @($Document.session_correlation.publications |
            Where-Object { [string]$_.slot -eq 'Current' })
    if ($current.Count -ne 1) {
        throw "Scenario '$ScenarioId' dump did not contain one Current correlation slot."
    }
    if ($ExpectCurrent) {
        if (-not [bool]$current[0].present) {
            throw "Scenario '$ScenarioId' expected a present Current correlation."
        }
        $matches = @($current[0].candidates | Where-Object {
                [bool]$_.exact_match -and
                [string]$_.generation_id -eq $ExpectedGenerationId
            })
        if ($matches.Count -ne 1) {
            throw "Scenario '$ScenarioId' C++ publication did not exactly correlate with Generation $ExpectedGenerationId."
        }
    }
    elseif ([bool]$current[0].present) {
        throw "Scenario '$ScenarioId' unexpectedly correlated a present Current publication."
    }
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectName = [System.IO.Path]::GetFileNameWithoutExtension(
    (Get-ChildItem -LiteralPath $projectRoot -Filter '*.uproject' -File |
        Select-Object -First 1).Name)
$resolvedTimeoutMs = Resolve-TimeoutMs `
    -RequestedTimeoutMs $TimeoutMs `
    -DefaultTimeoutMs 3600000 `
    -ParameterName 'TimeoutMs'
$deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs

if ($SkipPackage) {
    if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
        throw '-SkipPackage requires -OutputRoot to identify one exact prior smoke-run root.'
    }
    $runRoot = Normalize-PathValue -Path $OutputRoot
    if (-not (Test-Path -LiteralPath $runRoot -PathType Container)) {
        throw "The prior smoke-run root does not exist: $runRoot"
    }
}
else {
    $layout = New-CommandOutputLayout `
        -ProjectRoot $projectRoot `
        -Category 'CachePackage' `
        -Label "$Label-$Configuration" `
        -RequestedOutputRoot $OutputRoot `
        -LogFileName 'CachePackageSmoke.log' `
        -ReportFolderName 'Reports'
    $runRoot = $layout.OutputRoot
}

$archiveRoot = Join-Path $runRoot 'Archive'
$summaryPath = Join-Path $runRoot 'Summary.json'
$metadataPath = Join-Path $runRoot 'RunMetadata.json'
$packageLogRoot = Join-Path $runRoot 'Package'
$phaseRecords = New-Object System.Collections.Generic.List[object]
$startedAtUtc = [DateTime]::UtcNow
$finalExitCode = 1
$failure = ''

try {
    if (-not $SkipPackage) {
        $packageRunner = Join-Path $PSScriptRoot 'RunPackage.ps1'
        $packageTimeoutMs = Get-RemainingTimeoutMs `
            -DeadlineUtc $deadlineUtc `
            -PhaseName "$Configuration package"
        $packageArguments = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $packageRunner,
            '-TimeoutMs', $packageTimeoutMs,
            '-Label', "$Label-$Configuration-package",
            '-Configuration', $Configuration,
            '-ArchiveDir', $archiveRoot,
            '-LogRoot', $packageLogRoot,
            '-NoXGE'
        )
        $packageResult = Invoke-StreamingProcess `
            -FilePath 'powershell.exe' `
            -ArgumentList $packageArguments `
            -WorkingDirectory $projectRoot `
            -TimeoutMs $packageTimeoutMs `
            -LogPath (Join-Path $runRoot 'PackageRunner.log') `
            -Label 'cache-package-build'
        if ($packageResult.TimedOut -or [int]$packageResult.ExitCode -ne 0) {
            throw "RunPackage failed for $Configuration (exit $($packageResult.ExitCode), timedOut=$($packageResult.TimedOut))."
        }
    }

    $layout = Assert-AngelscriptLoosePackageLayout `
        -ArchiveRoot $archiveRoot `
        -ProjectName $projectName `
        -Configuration $Configuration
    $packageRoot = Split-Path -Parent $layout.ScriptRoot
    $evidenceRoot = Join-Path $packageRoot 'Saved\CachePackageSmoke'
    [void](Reset-AngelscriptCacheSmokeEvidence `
            -ArchiveRoot $archiveRoot `
            -EvidenceRoot $evidenceRoot)
    $fixture = New-AngelscriptCacheSmokeFixture `
        -ArchiveRoot $archiveRoot `
        -ScriptRoot $layout.ScriptRoot

    $cacheRoot = Join-Path $evidenceRoot 'CacheV2'
    $reportsRoot = Join-Path $evidenceRoot 'Reports'
    $logsRoot = Join-Path $evidenceRoot 'Logs'
    $dumpsRoot = Join-Path $evidenceRoot 'Dumps'
    New-Item -ItemType Directory -Path $reportsRoot, $logsRoot, $dumpsRoot -Force | Out-Null
    $dumpTool = Join-Path $projectRoot `
        'Plugins\Angelscript\Tools\CacheV2Dump\cache_v2_dump.py'

    $scenarios = @(
        [PSCustomObject]@{ Id = '01-cold'; Fixture = 'Baseline'; Report = 'Cold'; ExpectZero = $true; ExpectCurrent = $true; Reuse = $false; Normal = $true },
        [PSCustomObject]@{ Id = '02-unchanged-warm'; Fixture = 'Baseline'; Report = 'Warm'; ExpectZero = $true; ExpectCurrent = $true; Reuse = $true; Normal = $false },
        [PSCustomObject]@{ Id = '03-one-body-edit'; Fixture = 'BodyEdit'; Report = 'BodyEdit'; ExpectZero = $true; ExpectCurrent = $true; Reuse = $true; Normal = $false },
        [PSCustomObject]@{ Id = '04-invalid-source'; Fixture = 'InvalidSource'; Report = 'InvalidSource'; ExpectZero = $false; ExpectCurrent = $false; Reuse = $false; Normal = $false },
        [PSCustomObject]@{ Id = '05-restored-last-good'; Fixture = 'Baseline'; Report = 'Restored'; ExpectZero = $true; ExpectCurrent = $true; Reuse = $true; Normal = $false },
        [PSCustomObject]@{ Id = '06-structural-cold-start'; Fixture = 'StructuralEdit'; Report = 'StructuralEdit'; ExpectZero = $true; ExpectCurrent = $true; Reuse = $true; Normal = $false },
        [PSCustomObject]@{ Id = '07-structural-warm'; Fixture = 'StructuralEdit'; Report = 'StructuralWarm'; ExpectZero = $true; ExpectCurrent = $true; Reuse = $true; Normal = $false }
    )
    $baselineSnapshot = ''
    $bodySnapshot = ''
    $baselineGenerationId = ''
    $bodyGenerationId = ''
    $structuralGenerationId = ''

    foreach ($scenario in $scenarios) {
        [void](Set-AngelscriptCacheSmokeFixtureScenario `
                -Fixture $fixture `
                -Scenario $scenario.Fixture)
        $reportPath = Join-Path $reportsRoot "$($scenario.Id).json"
        $logPath = Join-Path $logsRoot "$($scenario.Id).log"
        $remainingLaunchTimeoutMs = Get-RemainingTimeoutMs `
            -DeadlineUtc $deadlineUtc `
            -PhaseName "$Configuration $($scenario.Id) launch"
        $launchTimeoutMs = Resolve-AngelscriptCachePackageLaunchTimeoutMs `
            -RemainingTimeoutMs $remainingLaunchTimeoutMs
        $launch = Invoke-AngelscriptPackagedCacheLaunch `
            -ArchiveRoot $archiveRoot `
            -Executable $layout.Executable `
            -CacheRoot $cacheRoot `
            -ReportPath $reportPath `
            -LogPath $logPath `
            -TimeoutMs $launchTimeoutMs

        if ($launch.TimedOut) {
            throw "Scenario '$($scenario.Id)' timed out."
        }
        if ($scenario.ExpectZero -and $launch.ExitCode -ne 0) {
            throw "Scenario '$($scenario.Id)' expected exit 0 but got $($launch.ExitCode)."
        }
        if (-not $scenario.ExpectZero -and $launch.ExitCode -eq 0) {
            throw "Scenario '$($scenario.Id)' expected a nonzero invalid-source exit."
        }

        $report = Read-AngelscriptCacheReport -Path $reportPath
        $assertArguments = @{
            Scenario = $scenario.Report
            Report = $report
            ExpectCurrent = [bool]$scenario.ExpectCurrent
        }
        if ($scenario.Id -eq '02-unchanged-warm' -or
            $scenario.Id -eq '05-restored-last-good') {
            $assertArguments.ExpectedSourceSnapshot = $baselineSnapshot
            $assertArguments.ExpectedPersistedGenerationId =
                $baselineGenerationId
            $assertArguments.ExpectedHybridCandidateGenerationId =
                if ($scenario.Id -eq '05-restored-last-good') {
                    $bodyGenerationId
                }
                else {
                    $baselineGenerationId
                }
        }
        elseif ($scenario.Id -eq '03-one-body-edit') {
            $assertArguments.DifferentSourceSnapshot = $baselineSnapshot
            $assertArguments.ExpectedHybridCandidateGenerationId =
                $baselineGenerationId
        }
        elseif ($scenario.Id -eq '06-structural-cold-start') {
            $assertArguments.DifferentSourceSnapshot = $baselineSnapshot
            $assertArguments.ExpectedHybridCandidateGenerationId =
                $baselineGenerationId
        }
        elseif ($scenario.Id -eq '07-structural-warm') {
            $assertArguments.ExpectedPersistedGenerationId =
                $structuralGenerationId
            $assertArguments.ExpectedHybridCandidateGenerationId =
                $structuralGenerationId
        }
        if ([bool]$scenario.Reuse) {
            $assertArguments.RequireWarmCacheReuse = $true
        }
        elseif ([bool]$scenario.Normal) {
            $assertArguments.RequireNormalCompile = $true
        }
        [void](Assert-AngelscriptCacheScenarioReport @assertArguments)

        $sourceSnapshot = if ([bool]$report.current.present) {
            [string]$report.current.sourceSnapshot
        }
        else {
            ''
        }
        if ($scenario.Id -eq '01-cold') {
            $baselineSnapshot = $sourceSnapshot
        }
        elseif ($scenario.Id -eq '03-one-body-edit') {
            $bodySnapshot = $sourceSnapshot
        }

        $dumpSelector = if ($scenario.Id -eq '05-restored-last-good') {
            $baselineGenerationId
        }
        elseif ($scenario.Id -eq '07-structural-warm') {
            $structuralGenerationId
        }
        else {
            'Current'
        }
        $dumpPath = Join-Path $dumpsRoot "$($scenario.Id).json"
        $dump = Invoke-AngelscriptCacheV2Dump `
            -ArchiveRoot $archiveRoot `
            -CacheRoot $cacheRoot `
            -ToolPath $dumpTool `
            -OutputPath $dumpPath `
            -GenerationSelectors @($dumpSelector) `
            -SessionReport $reportPath `
            -TimeoutMs ([Math]::Min($launchTimeoutMs, 120000))
        $dumpGenerationId = Get-SingleCacheDumpGenerationId `
            -Document $dump `
            -ScenarioId $scenario.Id
        Assert-CacheDumpSessionCorrelation `
            -Document $dump `
            -ScenarioId $scenario.Id `
            -ExpectedGenerationId $dumpGenerationId `
            -ExpectCurrent:([bool]$scenario.ExpectCurrent)
        if ($scenario.Id -eq '01-cold') {
            $baselineGenerationId = $dumpGenerationId
        }
        elseif ($scenario.Id -eq '02-unchanged-warm' -and
            $dumpGenerationId -ne $baselineGenerationId) {
            throw 'Unchanged warm launch selected a different persisted Generation.'
        }
        elseif ($scenario.Id -eq '03-one-body-edit') {
            $bodyGenerationId = $dumpGenerationId
            if ($bodyGenerationId -eq $baselineGenerationId) {
                throw 'Body edit did not publish a distinct persisted Generation.'
            }
        }
        elseif ($scenario.Id -eq '04-invalid-source' -and
            $dumpGenerationId -ne $bodyGenerationId) {
            throw 'Invalid source advanced the persisted Current Generation.'
        }
        elseif ($scenario.Id -eq '05-restored-last-good' -and
            $dumpGenerationId -ne $baselineGenerationId) {
            throw 'Restored-source launch did not select the baseline Generation.'
        }
        elseif ($scenario.Id -eq '06-structural-cold-start') {
            $structuralGenerationId = $dumpGenerationId
            if ($structuralGenerationId -eq $baselineGenerationId -or
                $structuralGenerationId -eq $bodyGenerationId) {
                throw 'Structural edit did not publish a distinct persisted Generation.'
            }
        }
        elseif ($scenario.Id -eq '07-structural-warm' -and
            $dumpGenerationId -ne $structuralGenerationId) {
            throw 'Structural warm launch selected a different persisted Generation.'
        }
        $phaseRecords.Add([PSCustomObject]@{
                Id = $scenario.Id
                Fixture = $scenario.Fixture
                ExitCode = $launch.ExitCode
                TimedOut = $launch.TimedOut
                DurationMs = $launch.DurationMs
                SourceSnapshot = $sourceSnapshot
                GenerationId = $dumpGenerationId
                TransactionOrdinal = if ([bool]$report.current.present) { [string]$report.current.transactionOrdinal } else { '' }
                ReportPath = $reportPath
                DumpPath = $dumpPath
                LogPath = $logPath
            }) | Out-Null
    }

    if ([string]::IsNullOrWhiteSpace($baselineSnapshot) -or
        [string]::IsNullOrWhiteSpace($bodySnapshot) -or
        $baselineSnapshot -eq $bodySnapshot) {
        throw 'Package-smoke source-snapshot transitions were incomplete.'
    }
    $finalExitCode = 0
}
catch {
    $failure = $_.Exception.Message
    Write-Host ("[error] {0}" -f $failure) -ForegroundColor Red
}
finally {
    $completedAtUtc = [DateTime]::UtcNow
    $summary = [ordered]@{
        Kind = 'PackageSmoke'
        Configuration = $Configuration
        Label = $Label
        Status = if ($finalExitCode -eq 0) { 'Passed' } else { 'Failed' }
        ExitCode = $finalExitCode
        Failure = $failure
        StartedAtUtc = $startedAtUtc.ToString('o')
        CompletedAtUtc = $completedAtUtc.ToString('o')
        DurationMs = [int]($completedAtUtc - $startedAtUtc).TotalMilliseconds
        RunRoot = $runRoot
        ArchiveRoot = $archiveRoot
        PhaseCount = $phaseRecords.Count
        Phases = @($phaseRecords.ToArray())
    }
    Write-Utf8JsonFile -Path $summaryPath -Value $summary -Depth 10
    Write-Utf8JsonFile -Path $metadataPath -Value ([ordered]@{
            Kind = 'PackageSmoke'
            Configuration = $Configuration
            Label = $Label
            SkipPackage = [bool]$SkipPackage
            TimeoutMs = $resolvedTimeoutMs
            RunRoot = $runRoot
            ArchiveRoot = $archiveRoot
            SummaryPath = $summaryPath
            ExitCode = $finalExitCode
        }) -Depth 6
}

Write-Host ('CachePackage configuration : {0}' -f $Configuration)
Write-Host ('RunRoot                   : {0}' -f $runRoot)
Write-Host ('Summary                   : {0}' -f $summaryPath)
Write-Host ('FinalExitCode             : {0}' -f $finalExitCode)
exit $finalExitCode
