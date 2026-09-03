#requires -Version 7.0
#requires -PSEdition Core

[CmdletBinding()]
param(
    [ValidateRange(3, 31)][int] $Iterations = 3,
    [ValidateRange(1, 120)][int] $OperationLimitSeconds = 30,
    [ValidateRange(1, 64)][int] $ProcessLimit = 16,
    [string] $ActualWorkspaceRoot = '',
    [string] $OutputPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Measure {
    param([bool] $Condition, [Parameter(Mandatory = $true)][string] $Message)
    if (-not $Condition) { throw "Measurement assertion failed: $Message" }
}

function Invoke-MeasureGit {
    param(
        [Parameter(Mandatory = $true)][string] $Repository,
        [Parameter(Mandatory = $true)][string[]] $Arguments
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $Repository @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $previousPreference }
    if ($exitCode -ne 0) {
        throw "Fixture Git command failed ($exitCode): git -C <fixture> $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
}

function New-UnrealMeasureFixture {
    param([Parameter(Mandatory = $true)][string] $Parent)

    $workspace = Join-Path $Parent 'workspace'
    $engine = Join-Path $Parent 'engine'
    foreach ($directory in @(
        $workspace,
        (Join-Path $workspace 'Source'),
        (Join-Path $engine 'Engine/Build'),
        (Join-Path $engine 'Engine/Source'),
        (Join-Path $engine 'Engine/Binaries/DotNET/UnrealBuildTool'),
        (Join-Path $engine 'Engine/Binaries/ThirdParty/DotNet/10.0/win-x64'),
        (Join-Path $engine 'Engine/Binaries/Win64')
    )) {
        [void][System.IO.Directory]::CreateDirectory($directory)
    }

    Invoke-MeasureGit -Repository $workspace -Arguments @('init', '-b', 'main')
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText((Join-Path $workspace '.gitignore'), "AgentConfig.ini`nSaved/`n", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $workspace 'Fixture.uproject'), "{}`n", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $workspace 'Source/FixtureEditor.Target.cs'), "public class FixtureEditorTarget {}`n", $utf8)
    Invoke-MeasureGit -Repository $workspace -Arguments @('add', '--', '.gitignore', 'Fixture.uproject', 'Source/FixtureEditor.Target.cs')
    Invoke-MeasureGit -Repository $workspace -Arguments @(
        '-c', 'user.name=Hardness Fixture',
        '-c', 'user.email=fixture@example.invalid',
        'commit', '-m', 'fixture'
    )

    [System.IO.File]::WriteAllText((Join-Path $engine 'Engine/Build/InstalledBuild.txt'), 'Fixture', $utf8)
    [System.IO.File]::WriteAllText((Join-Path $engine 'Engine/Build/Build.version'), '{"MajorVersion":5,"MinorVersion":8,"PatchVersion":0}', $utf8)
    [System.IO.File]::WriteAllText(
        (Join-Path $engine 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.runtimeconfig.json'),
        '{"runtimeOptions":{"tfm":"net10.0","framework":{"name":"Microsoft.NETCore.App","version":"10.0.0"}}}',
        $utf8
    )
    [System.IO.File]::WriteAllBytes((Join-Path $engine 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll'), [byte[]] (1, 2, 3))
    [System.IO.File]::WriteAllBytes((Join-Path $engine 'Engine/Binaries/ThirdParty/DotNet/10.0/win-x64/dotnet.exe'), [byte[]] (1, 2, 3))
    [System.IO.File]::WriteAllBytes((Join-Path $engine 'Engine/Binaries/Win64/UnrealEditor-Cmd.exe'), [byte[]] (1, 2, 3))

    $projectFile = Join-Path $workspace 'Fixture.uproject'
    $gitCommonDir = (Resolve-Path -LiteralPath (Join-Path $workspace '.git')).Path
    $configuration = @"
[Build]
Architecture=x64
Configuration=Development
DefaultTimeoutMs=120000
EditorTarget=FixtureEditor
Platform=Win64

[Paths]
EngineRoot=$engine
ProjectFile=$projectFile

[Test]
DefaultTimeoutMs=120000

[Hardness]
SchemaVersion=2
WorkspaceRoot=$workspace
PrimaryRoot=$workspace
GitCommonDir=$gitCommonDir
"@
    [System.IO.File]::WriteAllText((Join-Path $workspace 'AgentConfig.ini'), $configuration, $utf8)

    $runsRoot = Join-Path $workspace 'Saved/Hardness/Unreal/Runs'
    $runRoot = Join-Path $runsRoot '11111111111111111111111111111111'
    [void][System.IO.Directory]::CreateDirectory($runRoot)
    $ubtLog = Join-Path $runRoot 'Ubt.log'
    [System.IO.File]::WriteAllText($ubtLog, "@progress 'Compiling' 40%`n[7/10] Compile Fixture.cpp`n", $utf8)
    $progressPaths = [pscustomobject][ordered]@{
        RunsRoot   = $runsRoot
        RunRoot    = $runRoot
        UbtLogPath = $ubtLog
        StdOutPath = Join-Path $runRoot 'stdout.log'
    }

    return [pscustomobject][ordered]@{
        WorkspaceRoot = $workspace
        EngineRoot    = $engine
        ProjectFile   = $projectFile
        ProgressPaths = $progressPaths
    }
}

function Get-MeasurePercentile {
    param(
        [Parameter(Mandatory = $true)][double[]] $Values,
        [Parameter(Mandatory = $true)][ValidateRange(1, 100)][int] $Percentile
    )
    $sorted = @($Values | Sort-Object)
    $index = [Math]::Max(0, [Math]::Ceiling(($Percentile / 100.0) * $sorted.Count) - 1)
    return [double] $sorted[$index]
}

function Invoke-MeasuredOperation {
    param(
        [Parameter(Mandatory = $true)][string] $Id,
        [Parameter(Mandatory = $true)][string] $Operation,
        [Parameter(Mandatory = $true)][scriptblock] $Action
    )

    [void](& $Action)
    $samples = [System.Collections.Generic.List[double]]::new()
    for ($index = 0; $index -lt $Iterations; $index++) {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        [void](& $Action)
        $stopwatch.Stop()
        if ($stopwatch.Elapsed.TotalSeconds -gt $OperationLimitSeconds) {
            throw "Measured operation '$Id' exceeded the $OperationLimitSeconds-second bound."
        }
        $samples.Add([Math]::Round($stopwatch.Elapsed.TotalMilliseconds, 3))
    }

    $values = @($samples)
    return [pscustomobject][ordered]@{
        Id          = $Id
        Operation   = $Operation
        Unit        = 'ms'
        SampleCount = $values.Count
        Samples     = $values
        Min         = [Math]::Round(($values | Measure-Object -Minimum).Minimum, 3)
        P50         = [Math]::Round((Get-MeasurePercentile -Values $values -Percentile 50), 3)
        P95         = [Math]::Round((Get-MeasurePercentile -Values $values -Percentile 95), 3)
        Max         = [Math]::Round(($values | Measure-Object -Maximum).Maximum, 3)
    }
}

function Get-MeasureCompositeHash {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][System.IO.FileInfo[]] $Files
    )

    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $records = @(
        foreach ($file in @($Files | Sort-Object FullName)) {
            $path = [System.IO.Path]::GetFullPath($file.FullName)
            Assert-Measure -Condition $path.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase) -Message "hash input escapes its declared root"
            $relative = $path.Substring($rootPath.Length).Replace('\', '/')
            $hash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.IO.File]::ReadAllBytes($path))).ToLowerInvariant()
            "$relative`:$hash"
        }
    )
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes(($records -join "`n"))
    return 'sha256:' + [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function ConvertTo-MeasureSafeError {
    param([Parameter(Mandatory = $true)][System.Management.Automation.ErrorRecord] $ErrorRecord)
    $message = [string] $ErrorRecord.Exception.Message
    $message = [regex]::Replace($message, '(?i)[A-Z]:[\\/][^;\r\n]+', '<local-path>')
    if ($message.Length -gt 512) { $message = $message.Substring(0, 512) }
    return ('{0}: {1}' -f $ErrorRecord.Exception.GetType().Name, $message)
}

function Invoke-ActualWorkspaceCheck {
    param(
        [Parameter(Mandatory = $true)][string] $Id,
        [Parameter(Mandatory = $true)][string] $Operation,
        [Parameter(Mandatory = $true)][scriptblock] $Action
    )
    try {
        $details = & $Action
        return [pscustomobject][ordered]@{
            Id        = $Id
            Operation = $Operation
            Success   = $true
            Reason    = 'Completed without launching Unreal Engine, UBT, or a native worker.'
            Details   = $details
        }
    }
    catch {
        return [pscustomobject][ordered]@{
            Id        = $Id
            Operation = $Operation
            Success   = $false
            Reason    = ConvertTo-MeasureSafeError -ErrorRecord $_
            Details   = $null
        }
    }
}

$skillRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$manifestPath = Join-Path $skillRoot 'scripts/UnrealEngineDevelop.psd1'
$workspaceSkillRoot = [System.IO.Path]::GetFullPath((Join-Path $skillRoot '../workspace-lifecycle'))
$workspaceManifest = Join-Path $workspaceSkillRoot 'scripts/WorkspaceLifecycle.psd1'
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $skillRoot '../../..'))
$temporaryBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/')
$fixtureRoot = Join-Path $temporaryBase ("hardness-unreal-measure-{0}" -f [guid]::NewGuid().ToString('N'))
$savedSelection = @{}
foreach ($name in @('HARDNESS_WORKSPACE_ROOT', 'HARDNESS_PRIMARY_ROOT', 'HARDNESS_GIT_COMMON_DIR')) {
    $savedSelection[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

$document = $null
$rawJson = ''
$rawHash = ''
try {
    $fixture = New-UnrealMeasureFixture -Parent $fixtureRoot

    $measurements = [System.Collections.Generic.List[object]]::new()
    $measurements.Add((Invoke-MeasuredOperation -Id 'module-import' -Operation 'Import-Module <unreal-manifest> -Force' -Action {
        Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue
        Remove-Module WorkspaceLifecycle -Force -ErrorAction SilentlyContinue
        Import-Module $manifestPath -Force -ErrorAction Stop
        Assert-Measure -Condition ($null -ne (Get-Module UnrealEngineDevelop)) -Message 'Unreal module import did not produce the expected module'
    }))

    $measurements.Add((Invoke-MeasuredOperation -Id 'fixture-status' -Operation 'Get-HardnessUnrealStatus -WorkspaceRoot <fixture>' -Action {
        $status = Get-HardnessUnrealStatus -WorkspaceRoot $fixture.WorkspaceRoot
        Assert-Measure -Condition ([bool] $status.Ready) -Message 'fixture Unreal status is not ready'
    }))
    $measurements.Add((Invoke-MeasuredOperation -Id 'source-target-scan' -Operation 'Get-HardnessUnrealTargetList -WorkspaceRoot <fixture>' -Action {
        $targets = @(Get-HardnessUnrealTargetList -WorkspaceRoot $fixture.WorkspaceRoot)
        Assert-Measure -Condition ($targets.Count -eq 1 -and [string] $targets[0].Name -ceq 'FixtureEditor' -and [string] $targets[0].Source -ceq 'SourceScan') -Message 'source-only target scan was not exact'
    }))
    $measurements.Add((Invoke-MeasuredOperation -Id 'bounded-process-scan' -Operation "Get-HardnessUnrealProcessList -WorkspaceRoot <fixture> -Limit $ProcessLimit" -Action {
        $processes = @(Get-HardnessUnrealProcessList -WorkspaceRoot $fixture.WorkspaceRoot -Limit $ProcessLimit)
        Assert-Measure -Condition ($processes.Count -le $ProcessLimit) -Message 'process scan exceeded its public result bound'
    }))
    $measurements.Add((Invoke-MeasuredOperation -Id 'suite-plan' -Operation 'New-HardnessUnrealSuitePlan -WorkspaceRoot <fixture> -Suite Smoke' -Action {
        $plan = New-HardnessUnrealSuitePlan -WorkspaceRoot $fixture.WorkspaceRoot -Suite Smoke
        Assert-Measure -Condition ([string] $plan.SchemaVersion -ceq 'hardness-unreal-suite-plan' -and [string] $plan.Suite -ceq 'Smoke' -and $plan.EntryCount -gt 0) -Message 'suite plan contract was not exact'
    }))
    $measurements.Add((Invoke-MeasuredOperation -Id 'typed-build-plan' -Operation 'Invoke-HardnessUnrealBuild -WorkspaceRoot <fixture> -PlanOnly' -Action {
        $plan = Invoke-HardnessUnrealBuild -WorkspaceRoot $fixture.WorkspaceRoot -PlanOnly
        Assert-Measure -Condition ([bool] $plan.PlanOnly -and [string] $plan.Operation -ceq 'Build' -and [string] $plan.Target -ceq 'FixtureEditor') -Message 'typed build PlanOnly contract was not exact'
    }))
    $measurements.Add((Invoke-MeasuredOperation -Id 'contained-progress-parse' -Operation 'Get-UnrealBuildProgressSnapshot(<contained fixture run paths>)' -Action {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $progress = & $module { param($Paths) Get-UnrealBuildProgressSnapshot -Paths $Paths } $fixture.ProgressPaths
        Assert-Measure -Condition ([bool] $progress.ProgressKnown -and [int] $progress.Current -eq 7 -and [int] $progress.Total -eq 10 -and [double] $progress.Percent -eq 70) -Message 'contained progress parser result was not exact'
        Assert-Measure -Condition ([long] $progress.BytesInspected -le (256 * 1024)) -Message 'progress parser exceeded its bounded tail'
    }))

    $suitePlanA = New-HardnessUnrealSuitePlan -WorkspaceRoot $fixture.WorkspaceRoot -Suite Smoke | ConvertTo-Json -Depth 20 -Compress
    $suitePlanB = New-HardnessUnrealSuitePlan -WorkspaceRoot $fixture.WorkspaceRoot -Suite Smoke | ConvertTo-Json -Depth 20 -Compress
    Assert-Measure -Condition ($suitePlanA -ceq $suitePlanB) -Message 'identical suite planning inputs did not produce byte-identical JSON'

    $unrealSourceFiles = @(
        Get-ChildItem -LiteralPath (Join-Path $skillRoot 'scripts') -Recurse -File -ErrorAction Stop |
            Where-Object { $_.Extension -in @('.ps1', '.psm1', '.psd1') }
    )
    $unrealDataFiles = @(Get-ChildItem -LiteralPath (Join-Path $skillRoot 'data') -Filter '*.json' -File -ErrorAction Stop)
    $workspaceSourceFiles = @(Get-ChildItem -LiteralPath (Join-Path $workspaceSkillRoot 'scripts') -File -ErrorAction Stop | Where-Object { $_.Extension -in @('.psm1', '.psd1') })
    $scriptHash = 'sha256:' + [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.IO.File]::ReadAllBytes($PSCommandPath))).ToLowerInvariant()

    $actualChecks = [System.Collections.Generic.List[object]]::new()
    $activated = $false
    if (-not [string]::IsNullOrWhiteSpace($ActualWorkspaceRoot)) {
        $actualRoot = (Resolve-Path -LiteralPath $ActualWorkspaceRoot -ErrorAction Stop).Path
        Import-Module $workspaceManifest -Force -ErrorAction Stop
        [void](Set-HardnessWorkspaceSession -ProjectRoot $actualRoot)
        $activated = $true

        $actualChecks.Add((Invoke-ActualWorkspaceCheck -Id 'status' -Operation 'Get-HardnessUnrealStatus -WorkspaceRoot <actual-workspace>' -Action {
            $status = Get-HardnessUnrealStatus -WorkspaceRoot $actualRoot
            [pscustomobject][ordered]@{
                Ready      = [bool] $status.Ready
                EngineKind = [string] $status.Engine.Kind
                Version    = [string] $status.Engine.Version
                ErrorCount = @($status.Errors).Count
            }
        }))
        $actualChecks.Add((Invoke-ActualWorkspaceCheck -Id 'source-target-scan' -Operation 'Get-HardnessUnrealTargetList -WorkspaceRoot <actual-workspace>' -Action {
            $targets = @(Get-HardnessUnrealTargetList -WorkspaceRoot $actualRoot)
            [pscustomobject][ordered]@{ Count = $targets.Count; Names = @($targets.Name | Sort-Object) }
        }))
        $actualChecks.Add((Invoke-ActualWorkspaceCheck -Id 'bounded-process-scan' -Operation "Get-HardnessUnrealProcessList -WorkspaceRoot <actual-workspace> -Limit $ProcessLimit" -Action {
            $processes = @(Get-HardnessUnrealProcessList -WorkspaceRoot $actualRoot -Limit $ProcessLimit)
            [pscustomobject][ordered]@{
                Count           = $processes.Count
                RecognizedBuild = @($processes | Where-Object RecognizedBuild).Count
                ProgressKnown   = @($processes | Where-Object { $_.Progress.ProgressKnown }).Count
            }
        }))
        $actualChecks.Add((Invoke-ActualWorkspaceCheck -Id 'suite-plan' -Operation 'New-HardnessUnrealSuitePlan -WorkspaceRoot <actual-workspace> -Suite Smoke' -Action {
            $plan = New-HardnessUnrealSuitePlan -WorkspaceRoot $actualRoot -Suite Smoke
            [pscustomobject][ordered]@{
                SchemaVersion = [string] $plan.SchemaVersion
                Suite         = [string] $plan.Suite
                EntryCount    = [int] $plan.EntryCount
                DataHash      = [string] $plan.DataHash
                Execution     = [string] $plan.Execution
            }
        }))
        $actualChecks.Add((Invoke-ActualWorkspaceCheck -Id 'typed-build-plan' -Operation 'Invoke-HardnessUnrealBuild -WorkspaceRoot <actual-workspace> -PlanOnly' -Action {
            $plan = Invoke-HardnessUnrealBuild -WorkspaceRoot $actualRoot -PlanOnly
            Assert-Measure -Condition ([bool] $plan.PlanOnly) -Message 'actual workspace build route did not remain PlanOnly'
            [pscustomobject][ordered]@{
                PlanOnly        = [bool] $plan.PlanOnly
                Operation       = [string] $plan.Operation
                Target          = [string] $plan.Target
                Platform        = [string] $plan.Platform
                Configuration   = [string] $plan.Configuration
                EngineKind      = [string] $plan.EngineKind
                BuildConcurrency = [string] $plan.BuildConcurrency
                ArgumentCount   = @($plan.Arguments).Count
            }
        }))
    }

    $document = [pscustomobject][ordered]@{
        SchemaVersion = 'hardness-unreal-workflow-measurement'
        Environment   = [pscustomobject][ordered]@{
            PSEdition      = [string] $PSVersionTable.PSEdition
            PSVersion      = [string] $PSVersionTable.PSVersion
            Platform       = [string] $PSVersionTable.Platform
            WarmupCount    = 1
            SampleCount    = $Iterations
            OperationLimitSeconds = $OperationLimitSeconds
            ProcessLimit   = $ProcessLimit
        }
        Hashes        = [pscustomobject][ordered]@{
            MeasurementScript = $scriptHash
            UnrealSourceTree  = Get-MeasureCompositeHash -Root $skillRoot -Files $unrealSourceFiles
            UnrealDataTree    = Get-MeasureCompositeHash -Root $skillRoot -Files $unrealDataFiles
            WorkspaceDependencyTree = Get-MeasureCompositeHash -Root $workspaceSkillRoot -Files $workspaceSourceFiles
        }
        Reproducibility = [pscustomobject][ordered]@{
            SuitePlanByteIdentical = $true
            FixtureTargetCount     = 1
            FixtureProgressPercent = 70
        }
        Measurements = @($measurements)
        ActualWorkspace = [pscustomobject][ordered]@{
            Requested = -not [string]::IsNullOrWhiteSpace($ActualWorkspaceRoot)
            Activated = $activated
            Mode      = 'ReadOnlyAndPlanOnly'
            Checks    = @($actualChecks)
        }
    }

    $rawJson = $document | ConvertTo-Json -Depth 30 -Compress
    $rawBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($rawJson)
    $rawHash = 'sha256:' + [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($rawBytes)).ToLowerInvariant()
    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $fullOutput = [System.IO.Path]::GetFullPath($OutputPath)
        $outputDirectory = Split-Path -Parent $fullOutput
        if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
            throw "Measurement output directory does not exist: $outputDirectory"
        }
        [System.IO.File]::WriteAllBytes($fullOutput, $rawBytes)
    }

    $actualFailures = @($actualChecks | Where-Object { -not $_.Success })
    if ($actualFailures.Count -gt 0) {
        throw "Actual-workspace read-only/PlanOnly validation failed: $(@($actualFailures.Id) -join ', '). Raw evidence hash: $rawHash"
    }

    [pscustomobject][ordered]@{
        SchemaVersion = 'hardness-unreal-workflow-measurement-result'
        RawJsonSha256 = $rawHash
        RawJson       = $rawJson
        Data          = $document
    }
}
finally {
    foreach ($name in $savedSelection.Keys) {
        [Environment]::SetEnvironmentVariable($name, $savedSelection[$name], 'Process')
    }
    Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue
    Remove-Module WorkspaceLifecycle -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) {
        $resolvedFixture = [System.IO.Path]::GetFullPath($fixtureRoot).TrimEnd('\', '/')
        $temporaryPrefix = $temporaryBase + [System.IO.Path]::DirectorySeparatorChar
        if (-not $resolvedFixture.StartsWith($temporaryPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not [System.IO.Path]::GetFileName($resolvedFixture).StartsWith('hardness-unreal-measure-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to remove unexpected measurement fixture path: $resolvedFixture"
        }
        Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
    }
}
