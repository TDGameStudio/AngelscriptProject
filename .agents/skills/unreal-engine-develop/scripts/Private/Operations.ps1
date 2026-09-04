function Get-UnrealUbtCapabilityRecord {
    param([Parameter(Mandatory = $true)][string] $Capability)
    if ([string]::IsNullOrWhiteSpace($Capability)) {
        throw 'A vetted UBT capability id is required.'
    }
    $catalog = Get-UnrealDataDocument -Name 'ubt-capabilities.json'
    $matches = @($catalog.capabilities | Where-Object { ([string] $_.id).Equals($Capability, [System.StringComparison]::OrdinalIgnoreCase) })
    if ($matches.Count -ne 1) {
        throw "UBT capability '$Capability' is unknown or not audited."
    }
    $record = $matches[0]
    if (-not [bool] $record.available) {
        throw "UBT capability '$($record.id)' is unavailable; destructive clean operations are outside this Change."
    }
    return $record
}

function Get-UnrealUbtOperationContext {
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot)
    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot -RequireExecutionGuard -CallerPath $WorkspaceRoot
    if ([string]::IsNullOrWhiteSpace($configuration.EngineRoot)) {
        throw "AgentConfig.ini Paths.EngineRoot is required for Unreal execution in '$($configuration.WorkspaceRoot)'."
    }
    $engine = Get-UnrealEngineDescription -EngineRoot $configuration.EngineRoot -Sources @('AgentConfig') -Configured $true
    if (-not $engine.VersionSupported) {
        throw "The configured Unreal Engine must be version 5.8; detected '$($engine.Version)' at '$($engine.EngineRoot)'."
    }
    if (-not $engine.Ubt.Available) {
        throw "UnrealBuildTool.dll is unavailable for the configured engine: $($engine.Ubt.Dll)"
    }
    if (-not $engine.DotNet.Available) {
        throw "A compatible engine-bundled win-x64 dotnet.exe is unavailable beneath '$($engine.EngineRoot)'."
    }
    if (-not (Test-Path -LiteralPath $engine.Ubt.WorkingDirectory -PathType Container)) {
        throw "The UBT working directory is unavailable: $($engine.Ubt.WorkingDirectory)"
    }
    return [pscustomobject][ordered]@{
        Configuration = $configuration
        Engine        = $engine
    }
}

function Resolve-UnrealBuildValue {
    param(
        [string] $ExplicitValue,
        [string] $ConfiguredValue,
        [Parameter(Mandatory = $true)][string] $Name,
        [switch] $AllowEmpty
    )
    $value = if ([string]::IsNullOrWhiteSpace($ExplicitValue)) { $ConfiguredValue } else { $ExplicitValue }
    $value = ([string] $value).Trim()
    if ([string]::IsNullOrWhiteSpace($value)) {
        if ($AllowEmpty) { return '' }
        throw "Build $Name must be provided explicitly or configured in AgentConfig.ini."
    }
    if ($value -notmatch '^[A-Za-z0-9_.+-]+$') {
        throw "Build $Name contains unsafe characters: $value"
    }
    return $value
}

function Resolve-UnrealBuildConfiguration {
    param([string] $ExplicitValue, [string] $ConfiguredValue)
    $value = Resolve-UnrealBuildValue -ExplicitValue $ExplicitValue -ConfiguredValue $ConfiguredValue -Name 'Configuration'
    foreach ($candidate in @('Debug', 'DebugGame', 'Development', 'Shipping', 'Test')) {
        if ($candidate.Equals($value, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $candidate
        }
    }
    throw "Build Configuration must be Debug, DebugGame, Development, Shipping, or Test; received '$value'."
}

function Assert-UnrealUbtArgumentsSafe {
    param(
        [AllowEmptyCollection()][string[]] $Arguments = @(),
        [AllowEmptyCollection()][string[]] $ReservedArguments = @()
    )
    Assert-UnrealArgumentArray -Arguments $Arguments
    $reserved = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($name in @(
        'Project', 'Mode', 'Output', 'WaitMutex', 'NoMutex', 'NoEngineChanges', 'Log', 'Session',
        'UniqueBuildEnvironment', 'Clean', 'Architecture', 'NoHotReload', 'NoHotReloadFromIDE',
        'Progress', 'NoXGE', 'NoUBA', 'IncludeAllTargets', 'DontIncludeParentAssembly'
    )) {
        [void] $reserved.Add($name)
    }
    foreach ($argumentName in @($ReservedArguments)) {
        $normalizedName = ([string] $argumentName).Trim().TrimStart('-', '/')
        if (-not [string]::IsNullOrWhiteSpace($normalizedName)) { [void] $reserved.Add($normalizedName) }
    }

    foreach ($argument in @($Arguments)) {
        $text = [string] $argument
        if ($text -cne $text.Trim()) {
            throw "UBT argument contains unsafe leading or trailing whitespace: '$text'"
        }
        if ($text.StartsWith('@', [System.StringComparison]::Ordinal)) {
            throw "UBT response-file arguments are prohibited: $text"
        }
        $body = $text.TrimStart('-', '/')
        if ($body.Equals('Clean', [System.StringComparison]::OrdinalIgnoreCase) -or
            $body -match '^(?i:Mode)[:=](?i:Clean)$') {
            throw "Destructive UBT clean requests are prohibited: $text"
        }
        $separatorIndex = $body.IndexOfAny([char[]] @('=', ':'))
        $key = if ($separatorIndex -lt 0) { $body } else { $body.Substring(0, $separatorIndex) }
        if ($key -in @('NoMutex', 'WaitMutex', 'NoEngineChanges')) {
            throw "UBT argument '$text' is a concurrency ownership conflict; Harness owns '$key' through its typed build and engine-lane policy."
        }
        if ($key.Equals('UniqueBuildEnvironment', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "UBT argument '$text' is prohibited because it bypasses Harness workspace and engine isolation."
        }
        if (($text.StartsWith('-', [System.StringComparison]::Ordinal) -or $text.StartsWith('/', [System.StringComparison]::Ordinal)) -and
            $reserved.Contains($key)) {
            throw "UBT argument '$text' is reserved or unsafe; Harness owns '$key'."
        }
    }
}

function New-UnrealUbtChildEnvironment {
    param(
        [Parameter(Mandatory = $true)] $Engine,
        [Parameter(Mandatory = $true)] $Paths
    )
    $dotNetRoot = Split-Path -Parent ([string] $Engine.DotNet.Executable)
    $parentPath = [Environment]::GetEnvironmentVariable('PATH', 'Process')
    $childPath = if ([string]::IsNullOrWhiteSpace($parentPath)) {
        $dotNetRoot
    }
    else {
        $dotNetRoot + [System.IO.Path]::PathSeparator + $parentPath
    }
    return [ordered]@{
        DOTNET_MULTILEVEL_LOOKUP = '0'
        DOTNET_ROLL_FORWARD      = 'LatestMajor'
        DOTNET_ROOT              = $dotNetRoot
        PATH                     = $childPath
        TEMP                     = [string] $Paths.TempPath
        TMP                      = [string] $Paths.TempPath
        UnrealBuildTool_TMP      = [string] $Paths.TempPath
    }
}

function New-UnrealUbtPlan {
    param(
        [Parameter(Mandatory = $true)] $Request,
        [Parameter(Mandatory = $true)] $Context,
        [string] $Capability = '',
        [string] $Target = '',
        [string] $Platform = '',
        [string] $Configuration = '',
        [string] $Architecture = ''
    )
    return [pscustomobject][ordered]@{
        PlanOnly       = $true
        RunId          = [string] $Request.runId
        Operation      = [string] $Request.operation
        Capability     = $Capability
        WorkspaceRoot  = [string] $Request.workspaceRoot
        EngineRoot     = [string] $Request.engineRoot
        EngineKind     = [string] $Context.Engine.Kind
        ProjectFile    = [string] $Request.projectFile
        ExecutionPath  = [string] $Request.execution.workspaceRoot
        ExecutionProjectFile = [string] $Request.execution.projectFile
        Execution      = $Request.execution
        Target         = $Target
        Platform       = $Platform
        Configuration  = $Configuration
        Architecture   = $Architecture
        Executable     = [string] $Request.filePath
        Arguments      = @($Request.arguments | ForEach-Object { [string] $_ })
        WorkingDirectory = [string] $Request.workingDirectory
        TimeoutMs      = [int] $Request.timeoutMs
        Environment    = $Request.environment
        Concurrency    = $Request.concurrency
        RequestedBuildConcurrency = if ($null -eq $Request.concurrency.PSObject.Properties['requestedBuildConcurrency']) { 'NotApplicable' } else { [string] $Request.concurrency.requestedBuildConcurrency }
        BuildConcurrency = if ($null -eq $Request.concurrency.PSObject.Properties['buildConcurrency']) { 'NotApplicable' } else { [string] $Request.concurrency.buildConcurrency }
        Paths          = $Request.paths
        ExecutionPaths = $Request.executionPaths
        Request        = $Request
    }
}

function New-UnrealBuildOperation {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [string] $Target = '',
        [string] $Platform = '',
        [string] $Configuration = '',
        [string] $Architecture = '',
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto',
        [ValidateSet('Auto', 'Parallel', 'Serialize')][string] $BuildConcurrency = 'Auto',
        [switch] $NoXge,
        [AllowEmptyCollection()][string[]] $ExtraArguments = @()
    )
    $context = Get-UnrealUbtOperationContext -WorkspaceRoot $WorkspaceRoot
    $targetValue = Resolve-UnrealBuildValue -ExplicitValue $Target -ConfiguredValue $context.Configuration.EditorTarget -Name 'Target'
    $platformValue = Resolve-UnrealBuildValue -ExplicitValue $Platform -ConfiguredValue $context.Configuration.Platform -Name 'Platform'
    $configurationValue = Resolve-UnrealBuildConfiguration -ExplicitValue $Configuration -ConfiguredValue $context.Configuration.Configuration
    $architectureValue = Resolve-UnrealBuildValue -ExplicitValue $Architecture -ConfiguredValue $context.Configuration.Architecture -Name 'Architecture' -AllowEmpty
    $timeoutValue = Resolve-UnrealPositiveTimeout -TimeoutMs $TimeoutMs -ConfiguredValue $context.Configuration.BuildDefaultTimeoutMs -FallbackMs 900000
    $capability = Get-UnrealUbtCapabilityRecord -Capability 'build'
    Assert-UnrealUbtArgumentsSafe -Arguments $ExtraArguments -ReservedArguments @($capability.reservedArguments)
    $concurrency = Get-UnrealConcurrencyDecision `
        -Operation Build `
        -EngineRoot $context.Engine.EngineRoot `
        -Policy $ConcurrencyPolicy `
        -InstalledEngine ([bool] $context.Engine.Installed) `
        -BuildConcurrency $BuildConcurrency `
        -TypedProjectBuild
    $request = New-UnrealRunRequest `
        -WorkspaceRoot $context.Configuration.WorkspaceRoot `
        -EngineRoot $context.Engine.EngineRoot `
        -ProjectFile $context.Configuration.ProjectFile `
        -Operation Build `
        -FilePath $context.Engine.DotNet.Executable `
        -Arguments @() `
        -WorkingDirectory $context.Engine.Ubt.WorkingDirectory `
        -TimeoutMs $timeoutValue `
        -ConcurrencyDecision $concurrency `
        -Label $targetValue
    $request | Add-Member -NotePropertyName build -NotePropertyValue ([pscustomobject][ordered]@{
        target          = $targetValue
        platform        = $platformValue
        configuration   = $configurationValue
        architecture    = $architectureValue
    })

    $arguments = [System.Collections.Generic.List[string]]::new()
    foreach ($argument in @(
        $context.Engine.Ubt.Dll,
        $targetValue,
        $platformValue,
        $configurationValue,
        "-Project=$($context.Configuration.ProjectFile)"
    )) { $arguments.Add([string] $argument) }
    if (-not [string]::IsNullOrWhiteSpace($architectureValue)) { $arguments.Add("-architecture=$architectureValue") }
    foreach ($argument in @('-NoHotReload', '-NoHotReloadFromIDE', '-Progress')) { $arguments.Add($argument) }
    if ($NoXge) { $arguments.Add('-NoXGE') }
    foreach ($argument in @($concurrency.UbtArguments)) { $arguments.Add([string] $argument) }
    foreach ($argument in @($ExtraArguments)) { $arguments.Add([string] $argument) }
    $arguments.Add("-Log=$($request.paths.UbtLogPath)")
    $environment = New-UnrealUbtChildEnvironment -Engine $context.Engine -Paths $request.paths
    $request = Set-UnrealRunCommand -Request $request -Arguments @($arguments) -Environment $environment
    return [pscustomobject][ordered]@{
        Request = $request
        Plan    = New-UnrealUbtPlan -Request $request -Context $context -Capability 'build' -Target $targetValue -Platform $platformValue -Configuration $configurationValue -Architecture $architectureValue
    }
}

function Invoke-HarnessUnrealUbt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $Capability,
        [AllowEmptyCollection()][string[]] $Arguments = @(),
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto',
        [switch] $PlanOnly,
        [switch] $NoWait
    )
    if ($PlanOnly -and $NoWait) { throw '-PlanOnly and -NoWait cannot be combined.' }
    $capabilityRecord = Get-UnrealUbtCapabilityRecord -Capability $Capability
    Assert-UnrealUbtArgumentsSafe -Arguments $Arguments -ReservedArguments @($capabilityRecord.reservedArguments)
    $context = Get-UnrealUbtOperationContext -WorkspaceRoot $WorkspaceRoot
    $operation = switch ([string] $capabilityRecord.id) {
        'build' { 'Build' }
        'query-targets' { 'QueryTargets' }
        default { 'Ubt' }
    }
    if ($operation -eq 'Build' -and @($Arguments).Count -lt 3) {
        throw "The generic build capability requires ordered Target, Platform, and Configuration arguments; use Invoke-HarnessUnrealBuild for configured defaults."
    }
    $timeoutValue = Resolve-UnrealPositiveTimeout -TimeoutMs $TimeoutMs -ConfiguredValue $context.Configuration.BuildDefaultTimeoutMs -FallbackMs 900000
    $concurrency = Get-UnrealConcurrencyDecision -Operation $operation -EngineRoot $context.Engine.EngineRoot -Policy $ConcurrencyPolicy -InstalledEngine ([bool] $context.Engine.Installed)
    $request = New-UnrealRunRequest `
        -WorkspaceRoot $context.Configuration.WorkspaceRoot `
        -EngineRoot $context.Engine.EngineRoot `
        -ProjectFile $context.Configuration.ProjectFile `
        -Operation $operation `
        -FilePath $context.Engine.DotNet.Executable `
        -Arguments @() `
        -WorkingDirectory $context.Engine.Ubt.WorkingDirectory `
        -TimeoutMs $timeoutValue `
        -ConcurrencyDecision $concurrency `
        -Label ([string] $capabilityRecord.id)

    $nativeArguments = [System.Collections.Generic.List[string]]::new()
    $nativeArguments.Add([string] $context.Engine.Ubt.Dll)
    switch ([string] $capabilityRecord.id) {
        'build' {
            foreach ($argument in @($Arguments)) { $nativeArguments.Add([string] $argument) }
            $nativeArguments.Add("-Project=$($context.Configuration.ProjectFile)")
            foreach ($argument in @($concurrency.UbtArguments)) { $nativeArguments.Add([string] $argument) }
        }
        'query-targets' {
            foreach ($argument in @(
                '-Mode=QueryTargets',
                "-Project=$($context.Configuration.ProjectFile)",
                "-Output=$($request.paths.TargetsPath)",
                '-IncludeAllTargets',
                '-DontIncludeParentAssembly'
            )) { $nativeArguments.Add([string] $argument) }
            foreach ($argument in @($concurrency.UbtArguments)) { $nativeArguments.Add([string] $argument) }
            foreach ($argument in @($Arguments)) { $nativeArguments.Add([string] $argument) }
        }
        default {
            $nativeArguments.Add("-Mode=$($capabilityRecord.mode)")
            $nativeArguments.Add("-Project=$($context.Configuration.ProjectFile)")
            foreach ($argument in @($concurrency.UbtArguments)) { $nativeArguments.Add([string] $argument) }
            foreach ($argument in @($Arguments)) { $nativeArguments.Add([string] $argument) }
        }
    }
    $nativeArguments.Add("-Log=$($request.paths.UbtLogPath)")
    $environment = New-UnrealUbtChildEnvironment -Engine $context.Engine -Paths $request.paths
    $request = Set-UnrealRunCommand -Request $request -Arguments @($nativeArguments) -Environment $environment
    $plan = New-UnrealUbtPlan -Request $request -Context $context -Capability ([string] $capabilityRecord.id)
    if ($PlanOnly) { return $plan }
    return Start-UnrealRunRequest -Request $request -NoWait:$NoWait
}

function Invoke-HarnessUnrealBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [string] $Target = '',
        [string] $Platform = '',
        [string] $Configuration = '',
        [string] $Architecture = '',
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto',
        [ValidateSet('Auto', 'Parallel', 'Serialize')][string] $BuildConcurrency = 'Auto',
        [switch] $NoXge,
        [switch] $PlanOnly,
        [switch] $NoWait,
        [AllowEmptyCollection()][string[]] $ExtraArguments = @()
    )
    if ($PlanOnly -and $NoWait) { throw '-PlanOnly and -NoWait cannot be combined.' }
    $operation = New-UnrealBuildOperation `
        -WorkspaceRoot $WorkspaceRoot `
        -Target $Target `
        -Platform $Platform `
        -Configuration $Configuration `
        -Architecture $Architecture `
        -TimeoutMs $TimeoutMs `
        -ConcurrencyPolicy $ConcurrencyPolicy `
        -BuildConcurrency $BuildConcurrency `
        -NoXge:$NoXge `
        -ExtraArguments $ExtraArguments
    if ($PlanOnly) { return $operation.Plan }
    return Start-UnrealRunRequest -Request $operation.Request -NoWait:$NoWait
}

function Get-UnrealEditorOperationContext {
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot)
    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot -RequireExecutionGuard -CallerPath $WorkspaceRoot
    if ([string]::IsNullOrWhiteSpace($configuration.EngineRoot)) {
        throw "AgentConfig.ini Paths.EngineRoot is required for Unreal execution in '$($configuration.WorkspaceRoot)'."
    }
    $engine = Get-UnrealEngineDescription -EngineRoot $configuration.EngineRoot -Sources @('AgentConfig') -Configured $true
    if (-not $engine.VersionSupported) {
        throw "The configured Unreal Engine must be version 5.8; detected '$($engine.Version)' at '$($engine.EngineRoot)'."
    }
    if (-not $engine.EditorCmd.Available) {
        throw "UnrealEditor-Cmd.exe is unavailable for the configured engine: $($engine.EditorCmd.Executable)"
    }
    return [pscustomobject][ordered]@{ Configuration = $configuration; Engine = $engine }
}

function Get-UnrealLaunchProfileRecord {
    param([Parameter(Mandatory = $true)][string] $Name)
    $catalog = Get-UnrealDataDocument -Name 'launch-profiles.json'
    $matches = @($catalog.profiles | Where-Object { ([string] $_.name).Equals($Name, [System.StringComparison]::OrdinalIgnoreCase) })
    if ($matches.Count -ne 1) { throw "Unreal launch profile '$Name' is missing or ambiguous." }
    $record = $matches[0]
    Assert-UnrealArgumentArray -Arguments @($record.arguments | ForEach-Object { [string] $_ })
    return $record
}

function Assert-UnrealEditorArgumentsSafe {
    param([AllowEmptyCollection()][string[]] $Arguments = @())
    Assert-UnrealArgumentArray -Arguments $Arguments
    $reserved = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($name in @(
        'ExecCmds', 'TestExit', 'ReportExportPath', 'ReportOutputPath', 'ABSLOG', 'LOG', 'run',
        'BUILDMACHINE', 'NullRHI', 'Unattended', 'NoPause', 'NoSplash', 'stdout', 'FullStdOutLogOutput',
        'UTF8Output', 'NOSOUND', 'NoLoadStartupPackages', 'NoLiveCoding', 'NoScreenMessages',
        'DisableAutomaticShaderCompilerLaunch', 'NoAssetRegistryCacheWrite', 'AngelscriptRunCrashOnlyTests'
    )) { [void] $reserved.Add($name) }

    foreach ($argument in @($Arguments)) {
        $text = [string] $argument
        if ($text -cne $text.Trim()) { throw "Editor argument contains unsafe leading or trailing whitespace: '$text'" }
        if ($text.StartsWith('@', [System.StringComparison]::Ordinal)) { throw "Editor response-file arguments are prohibited: $text" }
        if (-not ($text.StartsWith('-', [System.StringComparison]::Ordinal) -or $text.StartsWith('/', [System.StringComparison]::Ordinal))) {
            throw "Editor extra arguments must be switches; positional argument '$text' is prohibited."
        }
        $body = $text.TrimStart('-', '/')
        $separator = $body.IndexOfAny([char[]] @('=', ':'))
        $key = if ($separator -lt 0) { $body } else { $body.Substring(0, $separator) }
        if ($reserved.Contains($key)) { throw "Editor argument '$text' is reserved; Harness owns '$key'." }
    }
}

function Split-UnrealTestPrefixes {
    param([Parameter(Mandatory = $true)][string] $TestPrefix)
    $tokens = @($TestPrefix.Split([char] '+') | ForEach-Object { $_.Trim() })
    if ($tokens.Count -eq 0 -or @($tokens | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
        throw 'TestPrefix must contain one or more non-empty + separated prefixes.'
    }
    foreach ($token in $tokens) {
        if ($token -notmatch '^[A-Za-z0-9_.:-]+$') { throw "TestPrefix contains unsafe syntax: $token" }
    }
    return $tokens
}

function Get-UnrealAutomationGroupRecords {
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot)
    $configPath = Join-Path $WorkspaceRoot 'Config/DefaultEngine.ini'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return @() }
    if ((Get-Item -LiteralPath $configPath).Length -gt 4194304) { throw "Automation group configuration exceeds 4 MiB: $configPath" }
    $validSections = @('/Script/AutomationController.AutomationControllerSettings', '/Script/AutomationTest.AutomationTestSettings')
    $currentSection = ''
    $records = [System.Collections.Generic.List[object]]::new()
    foreach ($line in Get-Content -LiteralPath $configPath -Encoding UTF8) {
        $trimmed = $line.Trim()
        if ($trimmed.StartsWith('[') -and $trimmed.EndsWith(']')) {
            $currentSection = $trimmed.Substring(1, $trimmed.Length - 2)
            continue
        }
        if ($currentSection -notin $validSections -or $trimmed -notmatch '^\+Groups=\(Name="([^"]+)"') { continue }
        $name = [string] $matches[1]
        if ($name -notmatch '^[A-Za-z0-9_.-]+$') { throw "Automation group name contains unsafe syntax: $name" }
        $filters = @([regex]::Matches($trimmed, 'Contains="([^"]+)"') | ForEach-Object { [string] $_.Groups[1].Value })
        $records.Add([pscustomobject]@{ Name = $name; Filters = $filters })
        if ($records.Count -gt 256) { throw 'Automation group configuration exceeds 256 groups.' }
    }
    return @($records)
}

function Resolve-UnrealTestSelection {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [string] $TestPrefix = '',
        [string] $Group = ''
    )
    $hasPrefix = -not [string]::IsNullOrWhiteSpace($TestPrefix)
    $hasGroup = -not [string]::IsNullOrWhiteSpace($Group)
    if ($hasPrefix -eq $hasGroup) { throw 'Specify exactly one of TestPrefix or Group.' }
    $crashRoot = 'Angelscript.CrashOnly'
    if ($hasPrefix) {
        $tokens = @(Split-UnrealTestPrefixes -TestPrefix $TestPrefix)
        $crashOnly = @($tokens | Where-Object { $_.Equals($crashRoot, [System.StringComparison]::OrdinalIgnoreCase) -or $_.StartsWith("$crashRoot.", [System.StringComparison]::OrdinalIgnoreCase) }).Count -eq $tokens.Count
        $wouldIncludeCrash = @($tokens | Where-Object { $crashRoot.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
        if ($wouldIncludeCrash -and -not $crashOnly) {
            throw "Crash-only tests must be run separately with an exact '$crashRoot...' TestPrefix."
        }
        return [pscustomobject][ordered]@{
            Kind = 'Prefix'; Value = ($tokens -join '+'); AutomationTarget = (($tokens | ForEach-Object { "^$_" }) -join '+'); CrashOnly = $crashOnly
        }
    }

    $groupValue = $Group.Trim()
    if ($groupValue -notmatch '^[A-Za-z0-9_.-]+$') { throw "Automation Group contains unsafe syntax: $groupValue" }
    $matches = @(Get-UnrealAutomationGroupRecords -WorkspaceRoot $WorkspaceRoot | Where-Object { $_.Name.Equals($groupValue, [System.StringComparison]::OrdinalIgnoreCase) })
    if ($matches.Count -ne 1) {
        $defined = @(Get-UnrealAutomationGroupRecords -WorkspaceRoot $WorkspaceRoot | ForEach-Object { $_.Name })
        throw "Unknown automation group '$groupValue'. Defined groups: $($defined -join ', ')"
    }
    $filters = @($matches[0].Filters)
    $crashFilters = @($filters | Where-Object { $_.Equals($crashRoot, [System.StringComparison]::OrdinalIgnoreCase) -or $_.StartsWith("$crashRoot.", [System.StringComparison]::OrdinalIgnoreCase) })
    $wouldIncludeCrash = @($filters | Where-Object { $crashRoot.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
    $crashOnly = $filters.Count -gt 0 -and $crashFilters.Count -eq $filters.Count
    if ($wouldIncludeCrash -and -not $crashOnly) { throw "Crash-only tests must be run separately; automation group '$groupValue' has a broad or mixed filter." }
    return [pscustomobject][ordered]@{ Kind = 'Group'; Value = [string] $matches[0].Name; AutomationTarget = "Group:$($matches[0].Name)"; CrashOnly = $crashOnly }
}

function New-UnrealEditorPlan {
    param(
        [Parameter(Mandatory = $true)] $Request,
        [Parameter(Mandatory = $true)] $Context,
        [Parameter(Mandatory = $true)][string] $LaunchProfile,
        [string] $SelectionKind = '',
        [string] $TestPrefix = '',
        [string] $Group = '',
        [string] $AutomationTarget = '',
        [bool] $CrashOnly = $false,
        [string] $Commandlet = ''
    )
    return [pscustomobject][ordered]@{
        PlanOnly               = $true
        RunId                  = [string] $Request.runId
        Operation              = [string] $Request.operation
        WorkspaceRoot          = [string] $Request.workspaceRoot
        EngineRoot             = [string] $Request.engineRoot
        EngineKind             = [string] $Context.Engine.Kind
        ProjectFile            = [string] $Request.projectFile
        ExecutionPath          = [string] $Request.execution.workspaceRoot
        ExecutionProjectFile   = [string] $Request.execution.projectFile
        Execution              = $Request.execution
        SelectionKind          = $SelectionKind
        TestPrefix             = $TestPrefix
        Group                  = $Group
        AutomationTarget       = $AutomationTarget
        CrashOnly              = $CrashOnly
        Commandlet             = $Commandlet
        LaunchProfile          = $LaunchProfile
        EnforceAutomationReport = [bool] $Request.enforceAutomationReport
        Executable             = [string] $Request.filePath
        Arguments              = @($Request.arguments | ForEach-Object { [string] $_ })
        WorkingDirectory       = [string] $Request.workingDirectory
        TimeoutMs              = [int] $Request.timeoutMs
        Environment            = $Request.environment
        Concurrency            = $Request.concurrency
        Paths                  = $Request.paths
        ExecutionPaths         = $Request.executionPaths
        Request                = $Request
    }
}

function Invoke-HarnessUnrealTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [string] $TestPrefix = '',
        [string] $Group = '',
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto',
        [switch] $Render,
        [switch] $Fast,
        [switch] $NoReport,
        [switch] $PlanOnly,
        [switch] $NoWait,
        [AllowEmptyCollection()][string[]] $ExtraArguments = @()
    )
    if ($PlanOnly -and $NoWait) { throw '-PlanOnly and -NoWait cannot be combined.' }
    if ($Render -and $Fast) { throw 'Fast and Render cannot be combined because they select conflicting launch profiles.' }
    Assert-UnrealEditorArgumentsSafe -Arguments $ExtraArguments
    $hasPrefix = -not [string]::IsNullOrWhiteSpace($TestPrefix)
    $hasGroup = -not [string]::IsNullOrWhiteSpace($Group)
    if ($hasPrefix -eq $hasGroup) { throw 'Specify exactly one of TestPrefix or Group.' }
    $selection = if ($hasPrefix) {
        Resolve-UnrealTestSelection -WorkspaceRoot $WorkspaceRoot -TestPrefix $TestPrefix
    }
    else {
        $null
    }
    $context = Get-UnrealEditorOperationContext -WorkspaceRoot $WorkspaceRoot
    if ($null -eq $selection) { $selection = Resolve-UnrealTestSelection -WorkspaceRoot $context.Configuration.WorkspaceRoot -Group $Group }
    $profileName = if ($Render) { 'render' } elseif ($Fast) { 'fast-headless' } else { 'headless' }
    $profile = Get-UnrealLaunchProfileRecord -Name $profileName
    $timeoutValue = Resolve-UnrealPositiveTimeout -TimeoutMs $TimeoutMs -ConfiguredValue $context.Configuration.TestDefaultTimeoutMs -FallbackMs 600000
    $concurrency = Get-UnrealConcurrencyDecision -Operation Test -EngineRoot $context.Engine.EngineRoot -Policy $ConcurrencyPolicy -InstalledEngine ([bool] $context.Engine.Installed)
    $request = New-UnrealRunRequest `
        -WorkspaceRoot $context.Configuration.WorkspaceRoot `
        -EngineRoot $context.Engine.EngineRoot `
        -ProjectFile $context.Configuration.ProjectFile `
        -Operation Test `
        -FilePath $context.Engine.EditorCmd.Executable `
        -Arguments @() `
        -WorkingDirectory $context.Configuration.WorkspaceRoot `
        -TimeoutMs $timeoutValue `
        -ConcurrencyDecision $concurrency `
        -EnforceAutomationReport:(-not $NoReport) `
        -Label ([string] $selection.Value)
    $arguments = [System.Collections.Generic.List[string]]::new()
    foreach ($argument in @(
        $context.Configuration.ProjectFile,
        "-ExecCmds=Automation RunTests $($selection.AutomationTarget); Quit",
        '-TestExit=Automation Test Queue Empty',
        '-BUILDMACHINE'
    )) { $arguments.Add([string] $argument) }
    foreach ($argument in @($profile.arguments)) { $arguments.Add([string] $argument) }
    $arguments.Add("-ABSLOG=$($request.paths.UnrealLogPath)")
    if (-not $NoReport) { $arguments.Add("-ReportExportPath=$($request.paths.ReportPath)") }
    if ($selection.CrashOnly) { $arguments.Add('-AngelscriptRunCrashOnlyTests') }
    foreach ($argument in @($ExtraArguments)) { $arguments.Add([string] $argument) }
    $environment = [ordered]@{ TEMP = [string] $request.paths.TempPath; TMP = [string] $request.paths.TempPath }
    $request = Set-UnrealRunCommand -Request $request -Arguments @($arguments) -Environment $environment
    $plan = New-UnrealEditorPlan `
        -Request $request `
        -Context $context `
        -LaunchProfile $profileName `
        -SelectionKind ([string] $selection.Kind) `
        -TestPrefix $(if ($selection.Kind -eq 'Prefix') { [string] $selection.Value } else { '' }) `
        -Group $(if ($selection.Kind -eq 'Group') { [string] $selection.Value } else { '' }) `
        -AutomationTarget ([string] $selection.AutomationTarget) `
        -CrashOnly ([bool] $selection.CrashOnly)
    if ($PlanOnly) { return $plan }
    return Start-UnrealRunRequest -Request $request -NoWait:$NoWait
}

function Invoke-HarnessUnrealCommandlet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $Commandlet,
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto',
        [switch] $Render,
        [switch] $PlanOnly,
        [switch] $NoWait,
        [AllowEmptyCollection()][string[]] $ExtraArguments = @()
    )
    if ($PlanOnly -and $NoWait) { throw '-PlanOnly and -NoWait cannot be combined.' }
    $commandletValue = $Commandlet.Trim()
    if ($commandletValue -notmatch '^[A-Za-z][A-Za-z0-9_]*$') { throw "Commandlet name contains unsafe syntax: $Commandlet" }
    Assert-UnrealEditorArgumentsSafe -Arguments $ExtraArguments
    $context = Get-UnrealEditorOperationContext -WorkspaceRoot $WorkspaceRoot
    $profileName = if ($Render) { 'render' } else { 'headless' }
    $profile = Get-UnrealLaunchProfileRecord -Name $profileName
    $timeoutValue = Resolve-UnrealPositiveTimeout -TimeoutMs $TimeoutMs -ConfiguredValue $context.Configuration.TestDefaultTimeoutMs -FallbackMs 600000
    $concurrency = Get-UnrealConcurrencyDecision -Operation Commandlet -EngineRoot $context.Engine.EngineRoot -Policy $ConcurrencyPolicy -InstalledEngine ([bool] $context.Engine.Installed)
    $request = New-UnrealRunRequest `
        -WorkspaceRoot $context.Configuration.WorkspaceRoot `
        -EngineRoot $context.Engine.EngineRoot `
        -ProjectFile $context.Configuration.ProjectFile `
        -Operation Commandlet `
        -FilePath $context.Engine.EditorCmd.Executable `
        -Arguments @() `
        -WorkingDirectory $context.Configuration.WorkspaceRoot `
        -TimeoutMs $timeoutValue `
        -ConcurrencyDecision $concurrency `
        -Label $commandletValue
    $arguments = [System.Collections.Generic.List[string]]::new()
    foreach ($argument in @($context.Configuration.ProjectFile, "-run=$commandletValue", '-BUILDMACHINE')) { $arguments.Add([string] $argument) }
    foreach ($argument in @($profile.arguments)) { $arguments.Add([string] $argument) }
    $arguments.Add("-ABSLOG=$($request.paths.UnrealLogPath)")
    foreach ($argument in @($ExtraArguments)) { $arguments.Add([string] $argument) }
    $environment = [ordered]@{ TEMP = [string] $request.paths.TempPath; TMP = [string] $request.paths.TempPath }
    $request = Set-UnrealRunCommand -Request $request -Arguments @($arguments) -Environment $environment
    $plan = New-UnrealEditorPlan -Request $request -Context $context -LaunchProfile $profileName -Commandlet $commandletValue
    if ($PlanOnly) { return $plan }
    return Start-UnrealRunRequest -Request $request -NoWait:$NoWait
}
