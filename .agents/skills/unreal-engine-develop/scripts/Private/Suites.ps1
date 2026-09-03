$script:UnrealSuiteDataSchema = 'hardness-unreal-suites-v1'
$script:UnrealSuitePlanSchema = 'hardness-unreal-suite-plan-v1'
$script:UnrealSuiteRequestSchema = 'hardness-unreal-suite-request-v1'
$script:UnrealSuiteSummarySchema = 'hardness-unreal-suite-summary-v1'
$script:UnrealSuiteNames = @('Smoke', 'NativeCore', 'RuntimeCpp', 'Bindings', 'HotReload', 'Cache', 'Debugger', 'FunctionalSamples', 'All')
$script:UnrealDeferredSuiteCapabilities = @('Standalone', 'StandaloneRelease', 'CachePackage', 'package', 'coverage', 'release')

function Get-UnrealSuiteCatalog {
    $path = Join-Path $script:UnrealDataRoot 'suites.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Tracked Unreal suite data was not found: $path" }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -gt 1048576) { throw "Tracked Unreal suite data exceeds 1 MiB: $path" }
    $hash = 'sha256:' + [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
    $document = Read-UnrealJsonFile -Path $path
    if ([string] $document.schemaVersion -cne $script:UnrealSuiteDataSchema) {
        throw "Unsupported Unreal suite data schema '$($document.schemaVersion)' in '$path'."
    }
    if ([string] $document.launchProfile -notmatch '^[A-Za-z][A-Za-z0-9-]{0,31}$') {
        throw "Tracked Unreal suite launch profile is invalid: $($document.launchProfile)"
    }

    $suites = @($document.suites)
    if ($suites.Count -ne $script:UnrealSuiteNames.Count) {
        throw "Tracked Unreal suite data must contain exactly $($script:UnrealSuiteNames.Count) maintained suites."
    }
    $seenSuites = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    for ($suiteIndex = 0; $suiteIndex -lt $suites.Count; $suiteIndex++) {
        $suite = $suites[$suiteIndex]
        $name = [string] $suite.name
        if ($name -cne $script:UnrealSuiteNames[$suiteIndex] -or -not $seenSuites.Add($name)) {
            throw "Tracked Unreal suite order or identity is invalid at index $suiteIndex; expected '$($script:UnrealSuiteNames[$suiteIndex])'."
        }
        if ([string]::IsNullOrWhiteSpace([string] $suite.description)) { throw "Unreal suite '$name' requires a description." }
        $entries = @($suite.entries)
        if ($entries.Count -eq 0 -or $entries.Count -gt 64) { throw "Unreal suite '$name' must contain between 1 and 64 entries." }
        $seenPrefixes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $seenLabels = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($entry in $entries) {
            $prefix = [string] $entry.prefix
            $label = [string] $entry.label
            $tier = [string] $entry.tier
            if ($prefix -notmatch '^[A-Za-z0-9_.:-]+$') { throw "Unreal suite '$name' contains an unsafe Automation prefix: $prefix" }
            if ($label -notmatch '^[A-Za-z][A-Za-z0-9-]{0,63}$') { throw "Unreal suite '$name' contains an unsafe entry label: $label" }
            if ($tier -notin @('Light', 'Heavy')) { throw "Unreal suite '$name' entry '$label' has invalid tier '$tier'." }
            if (-not $seenPrefixes.Add($prefix)) { throw "Unreal suite '$name' contains duplicate prefix '$prefix'." }
            if (-not $seenLabels.Add($label)) { throw "Unreal suite '$name' contains duplicate label '$label'." }
        }
        if ($name -ceq 'All') {
            if ($entries.Count -ne 36 -or -not $seenPrefixes.Contains('Angelscript.TestModule.Generator')) {
                throw "Unreal suite 'All' must contain exactly 36 unique prefixes including Angelscript.TestModule.Generator."
            }
        }
    }

    $deferred = @($document.deferredCapabilities)
    if ($deferred.Count -ne $script:UnrealDeferredSuiteCapabilities.Count) {
        throw "Tracked Unreal suite data must describe exactly $($script:UnrealDeferredSuiteCapabilities.Count) deferred capabilities."
    }
    for ($index = 0; $index -lt $deferred.Count; $index++) {
        $record = $deferred[$index]
        if ([string] $record.id -cne $script:UnrealDeferredSuiteCapabilities[$index] -or [string] $record.status -cne 'Deferred') {
            throw "Deferred Unreal capability data is invalid at index $index."
        }
        if ([string]::IsNullOrWhiteSpace([string] $record.kind) -or [string]::IsNullOrWhiteSpace([string] $record.reason)) {
            throw "Deferred Unreal capability '$($record.id)' requires kind and reason."
        }
    }
    return [pscustomobject][ordered]@{ Path = $path; DataHash = $hash; Document = $document }
}

function Get-UnrealSuiteRecord {
    param([Parameter(Mandatory = $true)] $Catalog, [Parameter(Mandatory = $true)][string] $Suite)
    $name = $Suite.Trim()
    $matches = @($Catalog.Document.suites | Where-Object { ([string] $_.name).Equals($name, [System.StringComparison]::OrdinalIgnoreCase) })
    if ($matches.Count -ne 1) {
        if (@($Catalog.Document.deferredCapabilities | Where-Object { ([string] $_.id).Equals($name, [System.StringComparison]::OrdinalIgnoreCase) }).Count -eq 1) {
            throw "Unreal capability '$name' is deferred and is not an executable Unreal Automation suite."
        }
        throw "Unknown Unreal suite '$Suite'. Maintained suites: $($script:UnrealSuiteNames -join ', ')."
    }
    return $matches[0]
}

function ConvertTo-UnrealDeferredCapabilityRecords {
    param([Parameter(Mandatory = $true)] $Catalog)
    return @(
        foreach ($record in @($Catalog.Document.deferredCapabilities)) {
            [pscustomobject][ordered]@{
                Id     = [string] $record.id
                Status = [string] $record.status
                Kind   = [string] $record.kind
                Reason = [string] $record.reason
            }
        }
    )
}

function Get-HardnessUnrealSuiteList {
    [CmdletBinding()]
    param([string] $WorkspaceRoot = '')
    if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot)) { [void](Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot) }
    $catalog = Get-UnrealSuiteCatalog
    return @(
        foreach ($suite in @($catalog.Document.suites)) {
            $entries = @($suite.entries)
            [pscustomobject][ordered]@{
                Name        = [string] $suite.name
                Kind        = 'UnrealAutomation'
                Description = [string] $suite.description
                EntryCount  = $entries.Count
                Light       = @($entries | Where-Object { [string] $_.tier -ceq 'Light' }).Count
                Heavy       = @($entries | Where-Object { [string] $_.tier -ceq 'Heavy' }).Count
                DataHash    = $catalog.DataHash
            }
        }
    )
}

function New-HardnessUnrealSuitePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $Suite,
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto'
    )
    $catalog = Get-UnrealSuiteCatalog
    $suiteRecord = Get-UnrealSuiteRecord -Catalog $catalog -Suite $Suite
    $context = Get-UnrealEditorOperationContext -WorkspaceRoot $WorkspaceRoot
    $profileName = [string] $catalog.Document.launchProfile
    [void](Get-UnrealLaunchProfileRecord -Name $profileName)
    $timeoutValue = Resolve-UnrealPositiveTimeout -TimeoutMs $TimeoutMs -ConfiguredValue $context.Configuration.TestDefaultTimeoutMs -FallbackMs 3600000
    $concurrency = Get-UnrealConcurrencyDecision -Operation Suite -EngineRoot $context.Engine.EngineRoot -Policy $ConcurrencyPolicy -InstalledEngine ([bool] $context.Engine.Installed)
    $entries = [System.Collections.Generic.List[object]]::new()
    $index = 0
    foreach ($entry in @($suiteRecord.entries)) {
        $index++
        $entries.Add([pscustomobject][ordered]@{
            Order            = $index
            Kind             = 'UnrealAutomation'
            Prefix           = [string] $entry.prefix
            AutomationTarget = '^' + [string] $entry.prefix
            Label            = [string] $entry.label
            Tier             = [string] $entry.tier
            LaunchProfile    = $profileName
            RelativeRoot     = ('Entries/{0:D3}-{1}' -f $index, [string] $entry.label)
        })
    }
    return [pscustomobject][ordered]@{
        SchemaVersion        = $script:UnrealSuitePlanSchema
        DataSchemaVersion    = $script:UnrealSuiteDataSchema
        DataHash             = $catalog.DataHash
        Suite                = [string] $suiteRecord.name
        Description          = [string] $suiteRecord.description
        Kind                 = 'UnrealAutomation'
        Execution            = 'SequentialSingleWorkspaceLease'
        WorkspaceRoot        = [string] $context.Configuration.WorkspaceRoot
        EngineRoot           = [string] $context.Engine.EngineRoot
        ProjectFile          = [string] $context.Configuration.ProjectFile
        Executable           = [string] $context.Engine.EditorCmd.Executable
        WorkingDirectory     = [string] $context.Configuration.WorkspaceRoot
        LaunchProfile        = $profileName
        TimeoutMs            = $timeoutValue
        Concurrency          = $concurrency
        EntryCount           = $entries.Count
        Entries              = @($entries)
        DeferredCapabilities = @(ConvertTo-UnrealDeferredCapabilityRecords -Catalog $catalog)
    }
}

function Get-UnrealSuiteEntryPaths {
    param(
        [Parameter(Mandatory = $true)][string] $EntriesRoot,
        [Parameter(Mandatory = $true)][ValidateRange(1, 999)][int] $Order,
        [Parameter(Mandatory = $true)][string] $Label
    )
    if ($Label -notmatch '^[A-Za-z][A-Za-z0-9-]{0,63}$') { throw "Suite entry label is unsafe: $Label" }
    $root = ConvertTo-UnrealCanonicalPath -Path $EntriesRoot -AllowMissing
    $entryRoot = [System.IO.Path]::GetFullPath((Join-Path $root ('{0:D3}-{1}' -f $Order, $Label)))
    [void](Assert-UnrealPathContained -Root $root -Path $entryRoot -Purpose 'Suite entry directory')
    return [pscustomobject][ordered]@{
        EntryRoot     = $entryRoot
        LogPath       = Join-Path $entryRoot 'Command.log'
        StdOutPath    = Join-Path $entryRoot 'Command.stdout.log'
        StdErrPath    = Join-Path $entryRoot 'Command.stderr.log'
        UnrealLogPath = Join-Path $entryRoot 'Unreal.log'
        ReportPath    = Join-Path $entryRoot 'AutomationReport'
        SummaryPath   = Join-Path $entryRoot 'Summary.json'
        TempPath      = Join-Path $entryRoot 'Temp'
    }
}

function Assert-UnrealSuiteEntryPaths {
    param([Parameter(Mandatory = $true)] $Entry, [Parameter(Mandatory = $true)] $ExpectedPaths)
    foreach ($name in @('EntryRoot', 'LogPath', 'StdOutPath', 'StdErrPath', 'UnrealLogPath', 'ReportPath', 'SummaryPath', 'TempPath')) {
        $property = $Entry.paths.PSObject.Properties[$name]
        if ($null -eq $property -or -not (Test-UnrealPathEqual -Left ([string] $property.Value) -Right ([string] $ExpectedPaths.$name))) {
            throw "Suite entry path '$name' does not match its contained entry directory."
        }
    }
}

function New-UnrealSuiteOperation {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $Suite,
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto'
    )
    $plan = New-HardnessUnrealSuitePlan -WorkspaceRoot $WorkspaceRoot -Suite $Suite -TimeoutMs $TimeoutMs -ConcurrencyPolicy $ConcurrencyPolicy
    $profile = Get-UnrealLaunchProfileRecord -Name ([string] $plan.LaunchProfile)
    $request = New-UnrealRunRequest `
        -WorkspaceRoot $plan.WorkspaceRoot `
        -EngineRoot $plan.EngineRoot `
        -ProjectFile $plan.ProjectFile `
        -Operation Suite `
        -FilePath $plan.Executable `
        -Arguments @() `
        -WorkingDirectory $plan.WorkingDirectory `
        -TimeoutMs $plan.TimeoutMs `
        -ConcurrencyDecision $plan.Concurrency `
        -Label $plan.Suite
    $runtimeEntries = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @($plan.Entries)) {
        $paths = Get-UnrealSuiteEntryPaths -EntriesRoot ([string] $request.paths.EntriesRoot) -Order ([int] $entry.Order) -Label ([string] $entry.Label)
        $arguments = [System.Collections.Generic.List[string]]::new()
        foreach ($argument in @(
            $plan.ProjectFile,
            "-ExecCmds=Automation RunTests $($entry.AutomationTarget); Quit",
            '-TestExit=Automation Test Queue Empty',
            '-BUILDMACHINE'
        )) { $arguments.Add([string] $argument) }
        foreach ($argument in @($profile.arguments)) { $arguments.Add([string] $argument) }
        $arguments.Add("-ABSLOG=$($paths.UnrealLogPath)")
        $arguments.Add("-ReportExportPath=$($paths.ReportPath)")
        Assert-UnrealArgumentArray -Arguments @($arguments)
        $runtimeEntries.Add([pscustomobject][ordered]@{
            order            = [int] $entry.Order
            kind             = 'UnrealAutomation'
            prefix           = [string] $entry.Prefix
            automationTarget = [string] $entry.AutomationTarget
            label            = [string] $entry.Label
            tier             = [string] $entry.Tier
            arguments        = @($arguments)
            environment      = [pscustomobject][ordered]@{ TEMP = [string] $paths.TempPath; TMP = [string] $paths.TempPath }
            paths            = $paths
        })
    }
    $suiteRequest = [pscustomobject][ordered]@{
        schemaVersion     = $script:UnrealSuiteRequestSchema
        dataSchemaVersion = $plan.DataSchemaVersion
        dataHash          = $plan.DataHash
        name              = $plan.Suite
        launchProfile     = $plan.LaunchProfile
        execution         = $plan.Execution
        entries           = @($runtimeEntries)
    }
    $request | Add-Member -MemberType NoteProperty -Name suite -Value $suiteRequest
    return [pscustomobject][ordered]@{ Request = $request; Plan = $plan }
}

function Assert-UnrealSuiteRequest {
    param([Parameter(Mandatory = $true)] $Request)
    $suiteProperty = $Request.PSObject.Properties['suite']
    if ($null -eq $suiteProperty -or [string] $Request.suite.schemaVersion -cne $script:UnrealSuiteRequestSchema) {
        throw 'Suite request payload is missing or has an unsupported schema.'
    }
    if ([string] $Request.suite.execution -cne 'SequentialSingleWorkspaceLease') {
        throw "Suite request execution strategy is invalid: $($Request.suite.execution)"
    }
    $entries = @($Request.suite.entries)
    if ($entries.Count -eq 0 -or $entries.Count -gt 64) { throw 'Suite request must contain between 1 and 64 entries.' }
    for ($index = 0; $index -lt $entries.Count; $index++) {
        $entry = $entries[$index]
        $expectedOrder = $index + 1
        if ([int] $entry.order -ne $expectedOrder -or [string] $entry.kind -cne 'UnrealAutomation') {
            throw "Suite request entry order or kind is invalid at index $index."
        }
        if ([string] $entry.prefix -notmatch '^[A-Za-z0-9_.:-]+$' -or [string] $entry.label -notmatch '^[A-Za-z][A-Za-z0-9-]{0,63}$') {
            throw "Suite request entry identity is unsafe at index $index."
        }
        Assert-UnrealArgumentArray -Arguments @($entry.arguments | ForEach-Object { [string] $_ })
        foreach ($property in @($entry.environment.PSObject.Properties)) {
            if ($property.Name -notmatch '^[A-Za-z_][A-Za-z0-9_]*$' -or [string] $property.Value -match "`0") {
                throw "Suite entry environment is unsafe at index $index."
            }
        }
        $expectedPaths = Get-UnrealSuiteEntryPaths -EntriesRoot ([string] $Request.paths.EntriesRoot) -Order $expectedOrder -Label ([string] $entry.label)
        Assert-UnrealSuiteEntryPaths -Entry $entry -ExpectedPaths $expectedPaths
    }
}

function Invoke-UnrealSuiteRequest {
    param([Parameter(Mandatory = $true)] $Request, [Parameter(Mandatory = $true)][string] $MetadataPath)
    Assert-UnrealSuiteRequest -Request $Request
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $results = [System.Collections.Generic.List[object]]::new()
    $commandLines = [System.Collections.Generic.List[string]]::new()
    $timedOut = $false
    [void][System.IO.Directory]::CreateDirectory([string] $Request.paths.EntriesRoot)
    try {
        foreach ($entry in @($Request.suite.entries)) {
            if ((Get-UnrealRemainingTimeout -Request $Request) -le 0) { $timedOut = $true; break }
            $paths = $entry.paths
            [void][System.IO.Directory]::CreateDirectory([string] $paths.EntryRoot)
            [void][System.IO.Directory]::CreateDirectory([string] $paths.TempPath)
            if (-not (Test-Path -LiteralPath $paths.UnrealLogPath -PathType Leaf)) {
                [System.IO.File]::WriteAllText([string] $paths.UnrealLogPath, '', [System.Text.UTF8Encoding]::new($false))
            }
            $entryRequest = [pscustomobject][ordered]@{
                runId            = [string] $Request.runId
                createdAtUtc      = [string] $Request.createdAtUtc
                filePath         = [string] $Request.filePath
                workingDirectory = [string] $Request.workingDirectory
                timeoutMs        = [int] $Request.timeoutMs
                arguments        = @($entry.arguments | ForEach-Object { [string] $_ })
                environment      = $entry.environment
                paths            = $paths
            }
            $native = Invoke-UnrealNativeProcess -Request $entryRequest -MetadataPath $MetadataPath
            $summary = Get-UnrealAutomationSummary -ReportPath ([string] $paths.ReportPath) -LogPath ([string] $paths.UnrealLogPath) -ProcessExitCode ([int] $native.ExitCode)
            Write-UnrealJsonFileAtomic -Path ([string] $paths.SummaryPath) -Value $summary
            $state = if ($native.TimedOut) { 'TimedOut' } elseif ($summary.Passed) { 'Succeeded' } else { 'Failed' }
            $effectiveExitCode = if ($native.TimedOut) { 2 } elseif ($summary.Passed) { 0 } elseif ([int] $native.ExitCode -ne 0) { [int] $native.ExitCode } else { 6 }
            $results.Add([pscustomobject][ordered]@{
                Order         = [int] $entry.order
                Label         = [string] $entry.label
                Prefix        = [string] $entry.prefix
                Tier          = [string] $entry.tier
                State         = $state
                ExitCode      = $effectiveExitCode
                TimedOut      = [bool] $native.TimedOut
                DurationMs    = [long] $native.DurationMs
                LogPath       = [string] $paths.LogPath
                UnrealLogPath = [string] $paths.UnrealLogPath
                ReportPath    = [string] $paths.ReportPath
                SummaryPath   = [string] $paths.SummaryPath
            })
            $commandLines.Add(('{0:D3} {1} {2} exit={3} durationMs={4}' -f [int] $entry.order, [string] $entry.label, $state, $effectiveExitCode, [long] $native.DurationMs))
            [void](Update-UnrealRunMetadata -Path $MetadataPath -Changes @{ nativePid = $null })
            if ($native.TimedOut) { $timedOut = $true; break }
        }

        $executed = $results.Count
        if ($executed -lt @($Request.suite.entries).Count) {
            foreach ($entry in @($Request.suite.entries | Select-Object -Skip $executed)) {
                $results.Add([pscustomobject][ordered]@{
                    Order         = [int] $entry.order
                    Label         = [string] $entry.label
                    Prefix        = [string] $entry.prefix
                    Tier          = [string] $entry.tier
                    State         = 'NotRun'
                    ExitCode      = $null
                    TimedOut      = $false
                    DurationMs    = 0
                    LogPath       = [string] $entry.paths.LogPath
                    UnrealLogPath = [string] $entry.paths.UnrealLogPath
                    ReportPath    = [string] $entry.paths.ReportPath
                    SummaryPath   = [string] $entry.paths.SummaryPath
                })
            }
        }
        $failedCount = @($results | Where-Object { $_.State -eq 'Failed' }).Count
        $succeededCount = @($results | Where-Object { $_.State -eq 'Succeeded' }).Count
        $timedOutCount = @($results | Where-Object { $_.State -eq 'TimedOut' }).Count
        $notRunCount = @($results | Where-Object { $_.State -eq 'NotRun' }).Count
        $outcome = if ($timedOut -or $timedOutCount -gt 0) { 'TimedOut' } elseif ($failedCount -gt 0 -or $notRunCount -gt 0) { 'Failed' } else { 'Passed' }
        $rootSummary = [pscustomobject][ordered]@{
            SchemaVersion     = $script:UnrealSuiteSummarySchema
            DataSchemaVersion = [string] $Request.suite.dataSchemaVersion
            DataHash          = [string] $Request.suite.dataHash
            Suite             = [string] $Request.suite.name
            Outcome           = $outcome
            Passed            = $outcome -eq 'Passed'
            EntryCount        = @($Request.suite.entries).Count
            Executed          = $executed
            Succeeded         = $succeededCount
            Failed            = $failedCount
            TimedOut          = $timedOutCount
            NotRun            = $notRunCount
            DurationMs        = [long] $timer.ElapsedMilliseconds
            Entries           = @($results)
        }
        Write-UnrealJsonFileAtomic -Path ([string] $Request.paths.SummaryPath) -Value $rootSummary
        [System.IO.File]::WriteAllText([string] $Request.paths.LogPath, (($commandLines -join [Environment]::NewLine) + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))
        $exitCode = if ($outcome -eq 'Passed') { 0 } elseif ($outcome -eq 'TimedOut') { 2 } else { 7 }
        return [pscustomobject]@{
            ExitCode   = $exitCode
            TimedOut   = $outcome -eq 'TimedOut'
            DurationMs = [long] $timer.ElapsedMilliseconds
            Message    = if ($outcome -eq 'Passed') { '' } else { "Suite '$($Request.suite.name)' outcome is $outcome." }
        }
    }
    finally { $timer.Stop() }
}

function Invoke-HardnessUnrealSuite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $Suite,
        [int] $TimeoutMs = 0,
        [ValidateSet('Auto', 'Wait', 'Fail')][string] $ConcurrencyPolicy = 'Auto',
        [switch] $PlanOnly,
        [switch] $NoWait
    )
    if ($PlanOnly -and $NoWait) { throw '-PlanOnly and -NoWait cannot be combined.' }
    if ($PlanOnly) { return New-HardnessUnrealSuitePlan -WorkspaceRoot $WorkspaceRoot -Suite $Suite -TimeoutMs $TimeoutMs -ConcurrencyPolicy $ConcurrencyPolicy }
    $operation = New-UnrealSuiteOperation -WorkspaceRoot $WorkspaceRoot -Suite $Suite -TimeoutMs $TimeoutMs -ConcurrencyPolicy $ConcurrencyPolicy
    return Start-UnrealRunRequest -Request $operation.Request -NoWait:$NoWait
}
