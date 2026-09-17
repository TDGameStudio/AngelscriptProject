#requires -Version 7.0
#requires -PSEdition Core

[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Performance', 'Integration')]
    [string]$Profile = 'Quick',

    [ValidateRange(0, 1000)]
    [int]$WarmupRuns = 3,

    [ValidateRange(1, 10000)]
    [int]$MeasurementRuns = 15,

    [ValidateRange(1, 100000)]
    [int]$BatchSize = 1000,

    [string]$TaskChange = '',

    [string]$PerformanceOutputRoot = '',

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,100}$')]
    [string]$PerformanceRunId = '',

    [switch]$ListChecks,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$harnessManifest = Join-Path $PSScriptRoot 'Harness.psd1'
if ([string]::IsNullOrWhiteSpace($PerformanceOutputRoot)) {
    $PerformanceOutputRoot = Join-Path $projectRoot 'Saved\Harness\Performance'
}
$PerformanceOutputRoot = [System.IO.Path]::GetFullPath($PerformanceOutputRoot)
if ([string]::IsNullOrWhiteSpace($PerformanceRunId)) {
    $PerformanceRunId = 'gate-{0}-{1}' -f ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')), [guid]::NewGuid().ToString('N').Substring(0, 8)
}

function New-HarnessGateCheck {
    param(
        [string]$Name,
        [string]$Kind,
        [string]$Path = '',
        [string]$Executable = '',
        [object[]]$Arguments = @(),
        [string]$WorkingDirectory = ''
    )
    [pscustomobject][ordered]@{
        Name             = $Name
        Kind             = $Kind
        Path             = $Path
        Executable       = $Executable
        Arguments        = @($Arguments)
        WorkingDirectory = $WorkingDirectory
    }
}

function Resolve-HarnessPowerShellHost {
    param([string]$Name)
    $command = Get-Command -Name $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command) { return $null }
    return $command.Source
}

function Get-HarnessGateChecks {
    $checks = New-Object System.Collections.Generic.List[object]
    $hosts = @(
        [pscustomobject]@{ Suffix = 'PS7'; Executable = (Resolve-HarnessPowerShellHost 'pwsh.exe'); Arguments = @('-NoProfile') }
    )

    if ($Profile -in @('Quick', 'Integration')) {
        $scriptTests = [ordered]@{
            Harness            = '.agents\skills\harness\tests\Harness.Tests.ps1'
            HarnessDraft       = '.agents\skills\harness\tests\HarnessDraft.Tests.ps1'
            HarnessChangeGate  = '.agents\skills\harness\tests\HarnessChangeGate.Tests.ps1'
            HarnessEvolution   = '.agents\skills\harness\tests\HarnessEvolution.Tests.ps1'
            HarnessCutover     = '.agents\skills\harness\tests\HarnessCutover.Tests.ps1'
            HarnessGateContract = '.agents\skills\harness\tests\Test-Harness.Tests.ps1'
            Protocol            = '.agents\skills\harness\tests\Protocol.Tests.ps1'
            Workspace           = '.agents\skills\workspace-lifecycle\tests\WorkspaceLifecycle.Tests.ps1'
            GitOperations       = '.agents\skills\git-operations\tests\GitOperations.Tests.ps1'
            OpenSpecSkill       = '.agents\skills\openspec\tests\OpenSpecSkill.Tests.ps1'
            UnrealIntegration   = '.agents\skills\unreal-engine-develop\tests\UnrealEngineDevelop.Tests.ps1'
        }
        foreach ($testName in $scriptTests.Keys) {
            $testPath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $scriptTests[$testName]))
            foreach ($hostInfo in $hosts) {
                $arguments = @($hostInfo.Arguments) + @('-File', $testPath)
                if ($testName -eq 'UnrealIntegration') {
                    $arguments += @('-Tag', 'Integration')
                }
                $checks.Add((New-HarnessGateCheck -Name "$testName.$($hostInfo.Suffix)" -Kind 'Script' -Path $testPath -Executable $hostInfo.Executable -Arguments $arguments -WorkingDirectory $projectRoot)) | Out-Null
            }
        }
    }

    if ($Profile -in @('Performance', 'Integration')) {
        $testPath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot '.agents\skills\harness\tests\Harness.Performance.Tests.ps1'))
        foreach ($hostInfo in $hosts) {
            $hostRunId = '{0}-{1}' -f $PerformanceRunId, $hostInfo.Suffix
            $arguments = @($hostInfo.Arguments) + @(
                '-File', $testPath,
                '-ProjectRoot', $projectRoot,
                '-OutputRoot', $PerformanceOutputRoot,
                '-RunId', $hostRunId,
                '-WarmupRuns', [string]$WarmupRuns,
                '-MeasurementRuns', [string]$MeasurementRuns,
                '-BatchSize', [string]$BatchSize
            )
            if (-not [string]::IsNullOrWhiteSpace($TaskChange)) {
                $arguments += @('-TaskChange', $TaskChange)
            }
            $checks.Add((New-HarnessGateCheck -Name "HarnessPerformance.$($hostInfo.Suffix)" -Kind 'Performance' -Path $testPath -Executable $hostInfo.Executable -Arguments $arguments -WorkingDirectory $projectRoot)) | Out-Null
        }
    }

    if ($Profile -eq 'Integration') {
        foreach ($name in @('Harness.Installation', 'OpenSpec.Doctor', 'OpenSpec.Workflow', 'OpenSpec.Validate')) {
            $checks.Add((New-HarnessGateCheck -Name $name -Kind 'Harness' -WorkingDirectory $projectRoot)) | Out-Null
        }
    }
    return @($checks | ForEach-Object { $_ })
}

function Invoke-HarnessGateProcess {
    param($Check)
    if ([string]::IsNullOrWhiteSpace([string]$Check.Executable)) {
        throw "No executable was resolved for $($Check.Name)."
    }
    $command = Get-Command -Name $Check.Executable -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command -and -not (Test-Path -LiteralPath $Check.Executable -PathType Leaf)) {
        throw "Executable for $($Check.Name) was not found: $($Check.Executable)"
    }
    Push-Location $Check.WorkingDirectory
    try {
        $previousPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $output = & $Check.Executable @($Check.Arguments) 2>&1
            $exitCode = $LASTEXITCODE
        }
        finally {
            $ErrorActionPreference = $previousPreference
        }
    }
    finally {
        Pop-Location
    }
    [pscustomobject]@{
        Succeeded = $exitCode -eq 0
        ExitCode  = $exitCode
        Output    = @($output | ForEach-Object { [string]$_ })
    }
}

function Invoke-HarnessGateRoute {
    param($Check)
    Import-Module $harnessManifest -Force -ErrorAction Stop
    $context = New-HarnessContext -WorkspaceRoot $projectRoot
    switch ($Check.Name) {
        'Harness.Installation' {
            $health = Test-HarnessInstallation -ProjectRoot $projectRoot
            return [pscustomobject]@{ Succeeded = $health.IsValid; ExitCode = $(if ($health.IsValid) { 0 } else { 1 }); Output = @($health | ConvertTo-Json -Depth 8) }
        }
        'OpenSpec.Doctor' {
            $result = Invoke-Harness -Command 'openspec.doctor' -Context $context -ArgumentList @('--json')
        }
        'OpenSpec.Workflow' {
            $result = Invoke-Harness -Command 'openspec.workflow' -Context $context -ArgumentList @('validate', 'angelscript', '--json')
        }
        'OpenSpec.Validate' {
            $result = Invoke-Harness -Command 'openspec.validate' -Context $context -ArgumentList @('--all', '--strict', '--json')
        }
        default { throw "Unknown Harness integration check '$($Check.Name)'." }
    }
    return [pscustomobject]@{
        Succeeded = $result.status -eq 'Succeeded'
        ExitCode  = $result.exitCode
        Output    = if ($null -ne $result.data) { @($result.data | ConvertTo-Json -Depth 12) } else { @() }
    }
}

$checks = @(Get-HarnessGateChecks)
if ($ListChecks) {
    $checks
    return
}

$results = New-Object System.Collections.Generic.List[object]
foreach ($check in $checks) {
    if (-not $Json) { Write-Host "[RUN ] $($check.Name)" }
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $outcome = if ($check.Kind -in @('Script', 'Performance', 'Process')) {
            Invoke-HarnessGateProcess -Check $check
        }
        else {
            Invoke-HarnessGateRoute -Check $check
        }
        $timer.Stop()
        $status = if ($outcome.Succeeded) { 'Passed' } else { 'Failed' }
        $results.Add([pscustomobject][ordered]@{
            Name       = $check.Name
            Kind       = $check.Kind
            Status     = $status
            ExitCode   = $outcome.ExitCode
            DurationMs = $timer.ElapsedMilliseconds
            Output     = @($outcome.Output)
        }) | Out-Null
        if (-not $Json) {
            Write-Host ("[{0}] {1} ({2} ms)" -f $(if ($outcome.Succeeded) { 'PASS' } else { 'FAIL' }), $check.Name, $timer.ElapsedMilliseconds)
            if (-not $outcome.Succeeded) {
                foreach ($line in @($outcome.Output)) { Write-Host "       $line" }
            }
        }
    }
    catch {
        $timer.Stop()
        $results.Add([pscustomobject][ordered]@{
            Name       = $check.Name
            Kind       = $check.Kind
            Status     = 'Failed'
            ExitCode   = 1
            DurationMs = $timer.ElapsedMilliseconds
            Output     = @([string]$_)
        }) | Out-Null
        if (-not $Json) { Write-Host "[FAIL] $($check.Name): $($_.Exception.Message)" }
    }
}

$failed = @($results | Where-Object Status -eq 'Failed')
$summary = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    Profile       = $Profile
    Passed        = $results.Count - $failed.Count
    Failed        = $failed.Count
    Results       = @($results | ForEach-Object { $_ })
    Excluded      = @(
        'Fixture-only Unreal route integration is included; no real Editor, UBT, build, Automation, suite, or commandlet process is started.',
        'Smoke, Standalone, complete All, and StaticJIT All remain outside this core gate.',
        'The fixed OpenSpec 0.9.0 source and package gates are recorded in its verified release manifest.'
    )
}

if ($Json) {
    $summary | ConvertTo-Json -Depth 20
}
else {
    Write-Host "Harness $Profile gate: $($summary.Passed) passed, $($summary.Failed) failed."
}

Remove-Module Harness -Force -ErrorAction SilentlyContinue
Remove-Module Workspace -Force -ErrorAction SilentlyContinue

if ($failed.Count -gt 0) {
    throw "Harness $Profile gate failed: $($failed.Name -join ', ')"
}

if (-not $Json) { $summary }
