function Get-UnrealBundledDotNet {
    param(
        [Parameter(Mandatory = $true)][string] $EngineRoot,
        [Parameter(Mandatory = $true)][string] $RuntimeConfigPath
    )

    $frameworkVersion = ''
    $majorMinor = ''
    if (Test-Path -LiteralPath $RuntimeConfigPath -PathType Leaf) {
        try {
            $runtimeConfig = Read-UnrealJsonFile -Path $RuntimeConfigPath
            $frameworkVersion = [string] $runtimeConfig.runtimeOptions.framework.version
            $tfm = [string] $runtimeConfig.runtimeOptions.tfm
            $versionSource = if (-not [string]::IsNullOrWhiteSpace($frameworkVersion)) { $frameworkVersion } else { $tfm }
            if ($versionSource -match '(?<major>\d+)\.(?<minor>\d+)') {
                $majorMinor = '{0}.{1}' -f $Matches.major, $Matches.minor
            }
        }
        catch {
            # Status reports the missing selection below; malformed runtime data is not executed.
        }
    }

    $dotNetRoot = Join-Path $EngineRoot 'Engine/Binaries/ThirdParty/DotNet'
    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($majorMinor) -and (Test-Path -LiteralPath $dotNetRoot -PathType Container)) {
        $candidates = @(
            foreach ($directory in [System.IO.Directory]::EnumerateDirectories($dotNetRoot)) {
                $name = [System.IO.Path]::GetFileName($directory)
                if ($name -ne $majorMinor -and -not $name.StartsWith("$majorMinor.", [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }
                $executable = Join-Path $directory 'win-x64/dotnet.exe'
                if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
                    continue
                }
                $parsedVersion = $null
                $sortVersion = if ([version]::TryParse($name, [ref] $parsedVersion)) { $parsedVersion } else { [version]'0.0' }
                [pscustomobject]@{
                    Directory        = ConvertTo-UnrealCanonicalPath -Path $directory
                    VersionDirectory = $name
                    Executable       = ConvertTo-UnrealCanonicalPath -Path $executable
                    Exact            = $name.Equals($majorMinor, [System.StringComparison]::OrdinalIgnoreCase)
                    SortVersion      = $sortVersion
                }
            }
        )
    }

    $selected = @($candidates | Sort-Object @{ Expression = 'Exact'; Descending = $true }, @{ Expression = 'SortVersion'; Descending = $true }) | Select-Object -First 1
    return [pscustomobject][ordered]@{
        Available        = $null -ne $selected
        Source           = if ($null -ne $selected) { 'EngineBundled' } else { 'Unavailable' }
        FrameworkVersion = $frameworkVersion
        RequiredVersion  = $majorMinor
        VersionDirectory = if ($null -ne $selected) { [string] $selected.VersionDirectory } else { '' }
        Architecture     = 'win-x64'
        Directory        = if ($null -ne $selected) { [string] $selected.Directory } else { '' }
        Executable       = if ($null -ne $selected) { [string] $selected.Executable } else { '' }
    }
}

function Get-UnrealEngineDescription {
    param(
        [Parameter(Mandatory = $true)][string] $EngineRoot,
        [string[]] $Sources = @(),
        [bool] $Configured = $false
    )

    $root = ConvertTo-UnrealCanonicalPath -Path $EngineRoot -AllowMissing
    $errors = [System.Collections.Generic.List[string]]::new()
    $exists = Test-Path -LiteralPath $root -PathType Container
    if (-not $exists) {
        $errors.Add("EngineRoot does not exist: $root")
    }

    $installedMarker = Join-Path $root 'Engine/Build/InstalledBuild.txt'
    $sourceDirectory = Join-Path $root 'Engine/Source'
    $kind = if (Test-Path -LiteralPath $installedMarker -PathType Leaf) {
        'Installed'
    }
    elseif (Test-Path -LiteralPath $sourceDirectory -PathType Container) {
        'Source'
    }
    else {
        'Unknown'
    }

    $versionPath = Join-Path $root 'Engine/Build/Build.version'
    $version = ''
    $major = 0
    $minor = 0
    $patch = 0
    if (Test-Path -LiteralPath $versionPath -PathType Leaf) {
        try {
            $buildVersion = Read-UnrealJsonFile -Path $versionPath
            $major = [int] $buildVersion.MajorVersion
            $minor = [int] $buildVersion.MinorVersion
            $patch = [int] $buildVersion.PatchVersion
            $version = '{0}.{1}.{2}' -f $major, $minor, $patch
        }
        catch {
            $errors.Add("Build.version is invalid: $($_.Exception.Message)")
        }
    }
    else {
        $errors.Add("Build.version was not found: $versionPath")
    }

    $ubtDirectory = Join-Path $root 'Engine/Binaries/DotNET/UnrealBuildTool'
    $ubtDll = Join-Path $ubtDirectory 'UnrealBuildTool.dll'
    $runtimeConfig = Join-Path $ubtDirectory 'UnrealBuildTool.runtimeconfig.json'
    if (-not (Test-Path -LiteralPath $ubtDll -PathType Leaf)) {
        $errors.Add("UnrealBuildTool.dll was not found: $ubtDll")
    }
    if (-not (Test-Path -LiteralPath $runtimeConfig -PathType Leaf)) {
        $errors.Add("UnrealBuildTool.runtimeconfig.json was not found: $runtimeConfig")
    }
    $dotNet = Get-UnrealBundledDotNet -EngineRoot $root -RuntimeConfigPath $runtimeConfig
    if (-not $dotNet.Available) {
        $errors.Add('A compatible engine-bundled win-x64 dotnet.exe was not found.')
    }

    $editorCmd = Join-Path $root 'Engine/Binaries/Win64/UnrealEditor-Cmd.exe'
    if (-not (Test-Path -LiteralPath $editorCmd -PathType Leaf)) {
        $errors.Add("UnrealEditor-Cmd.exe was not found: $editorCmd")
    }

    return [pscustomobject][ordered]@{
        EngineRoot       = $root
        Configured       = $Configured
        Sources          = @($Sources | Sort-Object -Unique)
        Exists           = $exists
        Kind             = $kind
        Installed        = $kind -eq 'Installed'
        Version          = $version
        VersionSupported = $major -eq 5 -and $minor -eq 8
        BuildVersion     = [pscustomobject]@{ Major = $major; Minor = $minor; Patch = $patch; Path = $versionPath }
        Ubt              = [pscustomobject]@{
            Available         = (Test-Path -LiteralPath $ubtDll -PathType Leaf)
            Dll               = $ubtDll
            RuntimeConfig     = $runtimeConfig
            WorkingDirectory  = $sourceDirectory
        }
        DotNet           = $dotNet
        EditorCmd        = [pscustomobject]@{ Available = (Test-Path -LiteralPath $editorCmd -PathType Leaf); Executable = $editorCmd }
        Ready            = $errors.Count -eq 0
        Errors           = @($errors)
    }
}

function Get-UnrealRegisteredEngineCandidates {
    $candidates = [System.Collections.Generic.List[object]]::new()

    $launcherDatabase = if ([string]::IsNullOrWhiteSpace($env:ProgramData)) {
        ''
    }
    else {
        Join-Path $env:ProgramData 'Epic/UnrealEngineLauncher/LauncherInstalled.dat'
    }
    if (-not [string]::IsNullOrWhiteSpace($launcherDatabase) -and (Test-Path -LiteralPath $launcherDatabase -PathType Leaf)) {
        try {
            $launcher = Read-UnrealJsonFile -Path $launcherDatabase
            foreach ($installation in @($launcher.InstallationList)) {
                $location = [string] $installation.InstallLocation
                if (-not [string]::IsNullOrWhiteSpace($location)) {
                    $candidates.Add([pscustomobject]@{ EngineRoot = $location; Source = 'EpicLauncher' })
                }
            }
        }
        catch {
            # Machine registrations are advisory. A broken external record does not hide the configured engine.
        }
    }

    if ([System.OperatingSystem]::IsWindows()) {
        $selectorKey = 'Registry::HKEY_CURRENT_USER\SOFTWARE\Epic Games\Unreal Engine\Builds'
        try {
            if (Test-Path -LiteralPath $selectorKey) {
                $properties = Get-ItemProperty -LiteralPath $selectorKey -ErrorAction Stop
                foreach ($property in $properties.PSObject.Properties) {
                    if ($property.Name -notlike 'PS*' -and $property.Value -is [string] -and -not [string]::IsNullOrWhiteSpace([string] $property.Value)) {
                        $candidates.Add([pscustomobject]@{ EngineRoot = [string] $property.Value; Source = 'UnrealVersionSelector' })
                    }
                }
            }
        }
        catch {
            # Registry enumeration is best-effort and read-only.
        }

        foreach ($baseKey in @(
            'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\EpicGames\Unreal Engine',
            'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\EpicGames\Unreal Engine'
        )) {
            try {
                if (-not (Test-Path -LiteralPath $baseKey)) { continue }
                foreach ($versionKey in @(Get-ChildItem -LiteralPath $baseKey -ErrorAction Stop)) {
                    $installation = Get-ItemProperty -LiteralPath $versionKey.PSPath -Name 'InstalledDirectory' -ErrorAction Stop
                    $location = [string] $installation.InstalledDirectory
                    if (-not [string]::IsNullOrWhiteSpace($location)) {
                        $candidates.Add([pscustomobject]@{ EngineRoot = $location; Source = 'EpicRegistry' })
                    }
                }
            }
            catch {
                # Registry enumeration is best-effort and read-only.
            }
        }
    }

    return @($candidates)
}

function Get-HardnessUnrealStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot)

    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot
    if ([string]::IsNullOrWhiteSpace($configuration.EngineRoot)) {
        throw "AgentConfig.ini Paths.EngineRoot is missing for '$($configuration.WorkspaceRoot)'."
    }
    $engine = Get-UnrealEngineDescription -EngineRoot $configuration.EngineRoot -Sources @('AgentConfig') -Configured $true
    $execution = Get-UnrealExecutionPath `
        -WorkspaceRoot $configuration.WorkspaceRoot `
        -ProjectFile $configuration.ProjectFile `
        -GitCommonDir ([string] $configuration.Identity.GitCommonDir) `
        -RunId '00000000000000000000000000000000'
    return [pscustomobject][ordered]@{
        Ready         = $engine.Ready
        WorkspaceRoot = $configuration.WorkspaceRoot
        ProjectFile   = $configuration.ProjectFile
        ExecutionPath = [string] $execution.workspaceRoot
        ExecutionProjectFile = [string] $execution.projectFile
        Execution     = $execution
        Engine        = $engine
        Errors        = @($engine.Errors)
    }
}

function Get-HardnessUnrealEngineList {
    [CmdletBinding()]
    param([string] $WorkspaceRoot = '')

    $configuration = $null
    if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
        $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot
    }

    $records = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $addCandidate = {
        param([string] $Path, [string] $Source, [bool] $Configured)
        if ([string]::IsNullOrWhiteSpace($Path)) { return }
        try { $root = ConvertTo-UnrealCanonicalPath -Path $Path -AllowMissing }
        catch { return }
        if ($records.ContainsKey($root)) {
            $record = $records[$root]
            $record.Configured = $record.Configured -or $Configured
            if (-not $record.Sources.Contains($Source)) { $record.Sources.Add($Source) }
            return
        }
        $records.Add($root, [pscustomobject]@{
            EngineRoot = $root
            Configured = $Configured
            Sources    = [System.Collections.Generic.List[string]]::new([string[]] @($Source))
        })
    }

    if ($null -ne $configuration) {
        & $addCandidate $configuration.EngineRoot 'AgentConfig' $true
    }
    foreach ($candidate in @(Get-UnrealRegisteredEngineCandidates)) {
        & $addCandidate ([string] $candidate.EngineRoot) ([string] $candidate.Source) $false
    }

    return @(
        foreach ($record in @($records.Values | Sort-Object @{ Expression = 'Configured'; Descending = $true }, EngineRoot)) {
            Get-UnrealEngineDescription -EngineRoot $record.EngineRoot -Sources @($record.Sources) -Configured $record.Configured
        }
    )
}

function Read-UnrealUbtTargetList {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $TargetsPath
    )
    $workspace = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    $outputPath = Assert-UnrealPathContained -Root $workspace -Path $TargetsPath -Purpose 'UBT QueryTargets output'
    $document = Read-UnrealJsonFile -Path $outputPath
    $targetsProperty = $document.PSObject.Properties['Targets']
    if ($null -eq $targetsProperty) {
        throw "UBT QueryTargets output does not contain a Targets array: $outputPath"
    }
    $records = @($targetsProperty.Value)
    if ($records.Count -gt 4096) {
        throw "UBT QueryTargets output exceeded the bounded limit of 4096 targets: $outputPath"
    }
    $outputDirectory = Split-Path -Parent $outputPath
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $results = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $records) {
        $name = [string] $record.Name
        $type = [string] $record.Type
        $relativePath = [string] $record.Path
        if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($type) -or [string]::IsNullOrWhiteSpace($relativePath)) {
            throw "UBT QueryTargets returned an incomplete target record in '$outputPath'."
        }
        if (-not $seen.Add($name)) {
            throw "UBT QueryTargets returned duplicate target '$name' in '$outputPath'."
        }
        $sourcePath = [System.IO.Path]::GetFullPath($relativePath, $outputDirectory)
        $sourcePath = Assert-UnrealPathContained -Root $workspace -Path $sourcePath -Purpose "UBT target '$name' source"
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw "UBT target '$name' source was not found inside the selected workspace: $sourcePath"
        }
        $defaultProperty = $record.PSObject.Properties['DefaultTarget']
        $results.Add([pscustomobject][ordered]@{
            Name          = $name
            Type          = $type
            Source        = 'UbtQuery'
            Path          = $sourcePath
            DefaultTarget = $null -ne $defaultProperty -and [bool] $defaultProperty.Value
        })
    }
    return @($results | Sort-Object Name, Path)
}

function Get-HardnessUnrealTargetList {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot, [switch] $QueryUbt)

    $configuration = Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot
    if ($QueryUbt) {
        $run = Invoke-HardnessUnrealUbt -WorkspaceRoot $configuration.WorkspaceRoot -Capability query-targets
        if ([string] $run.State -ne 'Succeeded') {
            throw "UBT QueryTargets failed with state '$($run.State)'. Inspect '$($run.LogPath)'."
        }
        $request = Read-UnrealJsonFile -Path ([string] $run.RequestPath)
        $expectedPaths = Get-UnrealRunPaths -WorkspaceRoot $configuration.WorkspaceRoot -RunId ([string] $run.RunId)
        Assert-UnrealRequestPaths -Request $request -ExpectedPaths $expectedPaths
        return Read-UnrealUbtTargetList -WorkspaceRoot $configuration.WorkspaceRoot -TargetsPath ([string] $request.paths.TargetsPath)
    }

    $sourceRoot = Join-Path $configuration.WorkspaceRoot 'Source'
    if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
        return @()
    }
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $targets = [System.Collections.Generic.List[object]]::new()
    $scanned = 0
    foreach ($path in [System.IO.Directory]::EnumerateFiles($sourceRoot, '*.Target.cs', [System.IO.SearchOption]::AllDirectories)) {
        $scanned++
        if ($scanned -gt 4096) {
            throw "Target source scan exceeded the bounded limit of 4096 files beneath '$sourceRoot'."
        }
        $fileName = [System.IO.Path]::GetFileName($path)
        $name = $fileName.Substring(0, $fileName.Length - '.Target.cs'.Length)
        if ([string]::IsNullOrWhiteSpace($name) -or -not $seen.Add($name)) { continue }
        $type = if ($name.EndsWith('Editor', [System.StringComparison]::OrdinalIgnoreCase)) {
            'Editor'
        }
        elseif ($name.EndsWith('Server', [System.StringComparison]::OrdinalIgnoreCase)) {
            'Server'
        }
        elseif ($name.EndsWith('Client', [System.StringComparison]::OrdinalIgnoreCase)) {
            'Client'
        }
        elseif ($name.EndsWith('Program', [System.StringComparison]::OrdinalIgnoreCase)) {
            'Program'
        }
        else {
            'Game'
        }
        $targets.Add([pscustomobject][ordered]@{
            Name   = $name
            Type   = $type
            Source = 'SourceScan'
            Path   = ConvertTo-UnrealCanonicalPath -Path $path
        })
    }
    return @($targets | Sort-Object Name, Path)
}

function Get-UnrealCommandLineOptionValue {
    param(
        [AllowEmptyString()][string] $CommandLine,
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z][A-Za-z0-9-]{0,31}$')][string] $Name
    )
    if ([string]::IsNullOrWhiteSpace($CommandLine)) { return '' }
    $escaped = [regex]::Escape($Name)
    foreach ($pattern in @(
        ('(?i)(?:^|\s)"[-/]' + $escaped + '[:=](?<value>[^"]*)"'),
        ('(?i)(?:^|\s)[-/]' + $escaped + '[:=]"(?<value>[^"]*)"'),
        ('(?i)(?:^|\s)[-/]' + $escaped + '[:=](?<value>[^\s"]+)')
    )) {
        $match = [regex]::Match($CommandLine, $pattern)
        if ($match.Success) { return [string] $match.Groups['value'].Value }
    }
    return ''
}

function ConvertTo-UnrealProcessView {
    param(
        [Parameter(Mandatory = $true)][int] $ProcessId,
        [Parameter(Mandatory = $true)][string] $Name,
        [AllowEmptyString()][string] $Executable = '',
        [AllowEmptyString()][string] $CommandLine = ''
    )
    if ($CommandLine.Length -gt 16384) { $CommandLine = $CommandLine.Substring(0, 16384) }
    $isUbt = $Name.Equals('UnrealBuildTool', [System.StringComparison]::OrdinalIgnoreCase) -or
        $CommandLine -match '(?i)(?:^|[\\/])UnrealBuildTool(?:\.dll|\.exe)(?:"|\s|$)'
    $result = [pscustomobject][ordered]@{
        Id                  = $ProcessId
        Name                = $Name
        Kind                = if ($isUbt) { 'Ubt' } elseif ($Name -match '^UnrealEditor') { 'Editor' } else { 'UnrealAuxiliary' }
        Executable          = $Executable
        CommandLine         = $CommandLine
        RecognizedBuild     = $false
        RunId               = ''
        WorkspaceRoot       = ''
        EngineRoot          = ''
        ProjectFile         = ''
        ExecutionPath       = ''
        ExecutionProjectFile = ''
        Target              = ''
        Platform            = ''
        Configuration       = ''
        Architecture        = ''
        BuildConcurrency    = ''
        ConcurrencyDecision = ''
        Progress            = New-UnrealUnknownBuildProgress
        WorkspaceMatch      = $false
        EngineMatch         = $false
        StartedAtUtc        = $null
    }
    if (-not $isUbt) { return $result }

    $session = Get-UnrealCommandLineOptionValue -CommandLine $CommandLine -Name 'Session'
    if ($session -notmatch '^[a-fA-F0-9]{32}$') { return $result }
    $session = $session.ToLowerInvariant()
    $projectValue = Get-UnrealCommandLineOptionValue -CommandLine $CommandLine -Name 'Project'
    if ([string]::IsNullOrWhiteSpace($projectValue)) { return $result }
    try {
        $executionProject = ConvertTo-UnrealCanonicalPath -Path $projectValue
        if (-not $executionProject.EndsWith('.uproject', [System.StringComparison]::OrdinalIgnoreCase)) { return $result }
        $resolvedExecution = Resolve-UnrealPhysicalWorkspaceFromExecutionProject -ProjectFile $executionProject
        if ($null -eq $resolvedExecution) {
            $project = $executionProject
            $workspace = ConvertTo-UnrealCanonicalPath -Path (Split-Path -Parent $project)
        }
        else {
            $project = ConvertTo-UnrealCanonicalPath -Path ([string] $resolvedExecution.ProjectFile)
            $workspace = ConvertTo-UnrealCanonicalPath -Path ([string] $resolvedExecution.WorkspaceRoot)
        }
        $paths = Get-UnrealRunPaths -WorkspaceRoot $workspace -RunId $session
        foreach ($jsonPath in @($paths.RequestPath, $paths.MetadataPath)) {
            if (-not (Test-Path -LiteralPath $jsonPath -PathType Leaf)) { return $result }
            if ((Get-Item -LiteralPath $jsonPath).Length -gt (1024 * 1024)) { return $result }
        }
        $request = Read-UnrealJsonFile -Path $paths.RequestPath
        $metadata = Read-UnrealJsonFile -Path $paths.MetadataPath
        if ([string] $request.schemaVersion -ne $script:UnrealRequestSchema -or
            [string] $metadata.schemaVersion -ne $script:UnrealRunSchema -or
            [string] $request.runId -ne $session -or
            [string] $metadata.runId -ne $session -or
            [string] $request.operation -ne 'Build' -or
            [string] $metadata.operation -ne 'Build' -or
            [string] $metadata.state -in $script:UnrealTerminalStates -or
            -not (Test-UnrealPathEqual -Left ([string] $request.workspaceRoot) -Right $workspace) -or
            -not (Test-UnrealPathEqual -Left ([string] $request.projectFile) -Right $project) -or
            -not ([string] $request.execution.projectFile).Equals($executionProject, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $result
        }
        $nativePid = 0
        if (-not [int]::TryParse([string] $metadata.nativePid, [ref] $nativePid) -or $nativePid -ne $ProcessId) { return $result }
        Assert-UnrealRequestPaths -Request $request -ExpectedPaths $paths
        Assert-UnrealExecutionDescription -Request $request
        $sessionArguments = @($request.arguments | Where-Object { [string] $_ -match '(?i)^[-/]Session[:=]([a-f0-9]{32})$' })
        if ($sessionArguments.Count -ne 1 -or (Get-UnrealCommandLineOptionValue -CommandLine ([string] $sessionArguments[0]) -Name 'Session').ToLowerInvariant() -ne $session) {
            return $result
        }
        $buildProperty = $request.PSObject.Properties['build']
        if ($null -eq $buildProperty) { return $result }
        $build = $buildProperty.Value
        foreach ($field in @('target', 'platform', 'configuration', 'architecture')) {
            if ($null -eq $build.PSObject.Properties[$field]) { return $result }
        }
        $concurrency = $request.concurrency
        if ($null -eq $concurrency.PSObject.Properties['buildConcurrency']) { return $result }
        $selectedConcurrency = [string] $concurrency.buildConcurrency
        if ($selectedConcurrency -notin @('Parallel', 'Serialize')) { return $result }

        $result.Kind = 'UbtBuild'
        $result.RecognizedBuild = $true
        $result.RunId = $session
        $result.WorkspaceRoot = $workspace
        $result.EngineRoot = ConvertTo-UnrealCanonicalPath -Path ([string] $request.engineRoot)
        $result.ProjectFile = $project
        $result.ExecutionPath = [string] $request.execution.workspaceRoot
        $result.ExecutionProjectFile = $executionProject
        $result.Target = [string] $build.target
        $result.Platform = [string] $build.platform
        $result.Configuration = [string] $build.configuration
        $result.Architecture = [string] $build.architecture
        $result.BuildConcurrency = $selectedConcurrency
        $result.ConcurrencyDecision = [string] $concurrency.decision
        $result.Progress = Get-UnrealBuildProgressSnapshot -Paths $paths
    }
    catch {
        # Machine-wide process discovery fails soft when a candidate cannot be safely correlated.
    }
    return $result
}

function Get-HardnessUnrealProcessList {
    [CmdletBinding()]
    param(
        [string] $WorkspaceRoot = '',
        [switch] $CurrentWorkspaceOnly,
        [ValidateRange(1, 256)][int] $Limit = 128
    )

    if ($CurrentWorkspaceOnly -and [string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
        throw '-CurrentWorkspaceOnly requires an exact -WorkspaceRoot.'
    }
    $configuration = if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $null } else { Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot }
    $workspace = if ($null -eq $configuration) { '' } else { $configuration.WorkspaceRoot }
    $projectFile = if ($null -eq $configuration) { '' } else { $configuration.ProjectFile }
    $engineRoot = if ($null -eq $configuration -or [string]::IsNullOrWhiteSpace($configuration.EngineRoot)) { '' } else { ConvertTo-UnrealCanonicalPath -Path $configuration.EngineRoot -AllowMissing }

    $interestingNames = @(
        'UnrealEditor', 'UnrealEditor-Cmd', 'UnrealBuildTool', 'AutomationTool',
        'RunUAT', 'ShaderCompileWorker', 'LiveCodingConsole', 'dotnet'
    )
    $processes = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -in $interestingNames } | Sort-Object Id | Select-Object -First ($Limit * 4))
    $commandLines = @{}
    if ([System.OperatingSystem]::IsWindows() -and $processes.Count -gt 0 -and $null -ne (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
        try {
            $ids = @($processes.Id | ForEach-Object { [int] $_ })
            $filter = @($ids | ForEach-Object { "ProcessId = $_" }) -join ' OR '
            foreach ($record in @(Get-CimInstance -ClassName Win32_Process -Filter $filter -ErrorAction Stop)) {
                $commandLines[[int] $record.ProcessId] = [string] $record.CommandLine
            }
        }
        catch {
            # Access to process command lines is optional; the result remains bounded.
        }
    }

    $results = [System.Collections.Generic.List[object]]::new()
    foreach ($process in $processes) {
        $commandLine = if ($commandLines.ContainsKey([int] $process.Id)) { [string] $commandLines[[int] $process.Id] } else { '' }
        if ($process.ProcessName -eq 'dotnet' -and $commandLine -notmatch '(?i)UnrealBuildTool|AutomationTool') { continue }
        $executable = ''
        try { $executable = [string] $process.Path } catch { }
        $view = ConvertTo-UnrealProcessView -ProcessId ([int] $process.Id) -Name ([string] $process.ProcessName) -Executable $executable -CommandLine $commandLine
        $workspaceMatch = if ([string]::IsNullOrWhiteSpace($workspace)) {
            $false
        }
        elseif ($view.RecognizedBuild) {
            Test-UnrealPathEqual -Left $view.WorkspaceRoot -Right $workspace
        }
        else {
            $view.CommandLine.Contains($workspace, [System.StringComparison]::OrdinalIgnoreCase) -or
                $view.CommandLine.Contains($projectFile, [System.StringComparison]::OrdinalIgnoreCase)
        }
        if ($CurrentWorkspaceOnly -and -not $workspaceMatch) { continue }
        $engineMatch = if ([string]::IsNullOrWhiteSpace($engineRoot)) {
            $false
        }
        elseif ($view.RecognizedBuild) {
            Test-UnrealPathEqual -Left $view.EngineRoot -Right $engineRoot
        }
        else {
            (-not [string]::IsNullOrWhiteSpace($executable) -and $executable.StartsWith($engineRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) -or
                $view.CommandLine.Contains($engineRoot, [System.StringComparison]::OrdinalIgnoreCase)
        }
        $startedAt = $null
        try { $startedAt = $process.StartTime.ToUniversalTime() } catch { }
        $view.WorkspaceMatch = $workspaceMatch
        $view.EngineMatch = $engineMatch
        $view.StartedAtUtc = $startedAt
        $results.Add($view)
        if ($results.Count -ge $Limit) { break }
    }
    return @($results)
}

function Get-HardnessUnrealUbtCapabilities {
    [CmdletBinding()]
    param([string] $WorkspaceRoot = '')

    if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
        [void](Get-UnrealWorkspaceConfiguration -WorkspaceRoot $WorkspaceRoot)
    }
    return Get-UnrealDataDocument -Name 'ubt-capabilities.json'
}
