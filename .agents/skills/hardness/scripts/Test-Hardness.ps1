[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Performance', 'Integration')]
    [string]$Profile = 'Quick',

    [ValidateSet('Both', 'PowerShell7', 'WindowsPowerShell')]
    [string]$PowerShellHosts = 'Both',

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
$hardnessManifest = Join-Path $PSScriptRoot 'Hardness.psd1'
if ([string]::IsNullOrWhiteSpace($PerformanceOutputRoot)) {
    $PerformanceOutputRoot = Join-Path $projectRoot 'Saved\Harness\Hardness\Performance'
}
$PerformanceOutputRoot = [System.IO.Path]::GetFullPath($PerformanceOutputRoot)
if ([string]::IsNullOrWhiteSpace($PerformanceRunId)) {
    $PerformanceRunId = 'gate-{0}-{1}' -f ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')), [guid]::NewGuid().ToString('N').Substring(0, 8)
}

function New-HardnessGateCheck {
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

function Resolve-HardnessPowerShellHost {
    param([string]$Name)
    $command = Get-Command -Name $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command) { return $null }
    return $command.Source
}

function Get-HardnessGateChecks {
    $checks = New-Object System.Collections.Generic.List[object]
    $hosts = @()
    if ($PowerShellHosts -in @('Both', 'WindowsPowerShell')) {
        $hosts += [pscustomobject]@{ Suffix = 'PS5'; Executable = (Resolve-HardnessPowerShellHost 'powershell.exe'); Arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass') }
    }
    if ($PowerShellHosts -in @('Both', 'PowerShell7')) {
        $hosts += [pscustomobject]@{ Suffix = 'PS7'; Executable = (Resolve-HardnessPowerShellHost 'pwsh.exe'); Arguments = @('-NoProfile') }
    }

    if ($Profile -in @('Quick', 'Integration')) {
        $scriptTests = [ordered]@{
            Hardness            = '.agents\skills\hardness\tests\Hardness.Tests.ps1'
            HardnessGateContract = '.agents\skills\hardness\tests\Test-Hardness.Tests.ps1'
            Protocol            = '.agents\skills\hardness\tests\Protocol.Tests.ps1'
            Workspace           = '.agents\skills\git-workflow\tests\Workspace.Tests.ps1'
            OpenSpecSkill       = '.agents\skills\openspec\tests\OpenSpecSkill.Tests.ps1'
        }
        foreach ($testName in $scriptTests.Keys) {
            $testPath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $scriptTests[$testName]))
            foreach ($hostInfo in $hosts) {
                $arguments = @($hostInfo.Arguments) + @('-File', $testPath)
                $checks.Add((New-HardnessGateCheck -Name "$testName.$($hostInfo.Suffix)" -Kind 'Script' -Path $testPath -Executable $hostInfo.Executable -Arguments $arguments -WorkingDirectory $projectRoot)) | Out-Null
            }
        }
    }

    if ($Profile -in @('Performance', 'Integration')) {
        $testPath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot '.agents\skills\hardness\tests\Hardness.Performance.Tests.ps1'))
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
            $checks.Add((New-HardnessGateCheck -Name "HardnessPerformance.$($hostInfo.Suffix)" -Kind 'Performance' -Path $testPath -Executable $hostInfo.Executable -Arguments $arguments -WorkingDirectory $projectRoot)) | Out-Null
        }
    }

    if ($Profile -eq 'Integration') {
        foreach ($name in @('Hardness.Installation', 'OpenSpec.Doctor', 'OpenSpec.Workflow', 'OpenSpec.Validate')) {
            $checks.Add((New-HardnessGateCheck -Name $name -Kind 'Hardness' -WorkingDirectory $projectRoot)) | Out-Null
        }
    }
    return @($checks | ForEach-Object { $_ })
}

function Invoke-HardnessGateProcess {
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

function Invoke-HardnessGateRoute {
    param($Check)
    Import-Module $hardnessManifest -Force -ErrorAction Stop
    $context = New-HardnessContext -Mode Current -ProjectRoot $projectRoot
    switch ($Check.Name) {
        'Hardness.Installation' {
            $health = Test-HardnessInstallation -ProjectRoot $projectRoot
            return [pscustomobject]@{ Succeeded = $health.IsValid; ExitCode = $(if ($health.IsValid) { 0 } else { 1 }); Output = @($health | ConvertTo-Json -Depth 8) }
        }
        'OpenSpec.Doctor' {
            $result = Invoke-Hardness -Command 'openspec.doctor' -Context $context -ArgumentList @('--json')
        }
        'OpenSpec.Workflow' {
            $result = Invoke-Hardness -Command 'openspec.workflow' -Context $context -ArgumentList @('validate', 'angelscript', '--json')
        }
        'OpenSpec.Validate' {
            $result = Invoke-Hardness -Command 'openspec.validate' -Context $context -ArgumentList @('--all', '--strict', '--json')
        }
        default { throw "Unknown Hardness integration check '$($Check.Name)'." }
    }
    return [pscustomobject]@{
        Succeeded = $result.status -eq 'Succeeded'
        ExitCode  = $result.exitCode
        Output    = if ($null -ne $result.data) { @($result.data | ConvertTo-Json -Depth 12) } else { @() }
    }
}

$checks = @(Get-HardnessGateChecks)
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
            Invoke-HardnessGateProcess -Check $check
        }
        else {
            Invoke-HardnessGateRoute -Check $check
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
        'The unreal-engine-develop leaf and its public wrappers are deferred to a separate change.',
        'No Editor build, Automation, Smoke, Standalone, complete All, or StaticJIT All belongs to this core gate.',
        'The fixed OpenSpec 0.8.1 source and package gates are reused from their closed independent review.'
    )
}

if ($Json) {
    $summary | ConvertTo-Json -Depth 20
}
else {
    Write-Host "Hardness $Profile gate: $($summary.Passed) passed, $($summary.Failed) failed."
}

Remove-Module Hardness -Force -ErrorAction SilentlyContinue
Remove-Module Workspace -Force -ErrorAction SilentlyContinue

if ($failed.Count -gt 0) {
    throw "Hardness $Profile gate failed: $($failed.Name -join ', ')"
}

if (-not $Json) { $summary }
