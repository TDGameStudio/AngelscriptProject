#requires -Version 7.0
#requires -PSEdition Core
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:HardnessSchemaVersion = '1.0'
$script:HardnessHarnessRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$script:HardnessContextSchemaVersion = '2'
$script:HardnessRoutes = $null
$script:HardnessRouteByName = $null
$script:HardnessResolvedRoots = @{}
$script:HardnessPackageSafetyModule = $null
$script:HardnessOpenSpecIdentity = [ordered]@{
    Version           = '0.8.1'
    SourceCommit      = '1930040ab18acba43d44fcd635d2a91a701f04ce'
    SourceTag         = 'v0.8.1'
    SourceTagType     = 'annotated'
    SourceTagObject   = 'cd643b0bb1e12e09f32012bb2364f37e3f43db88'
    SourceTagTarget   = '1930040ab18acba43d44fcd635d2a91a701f04ce'
    Target            = 'x86_64-pc-windows-msvc'
    Profile           = 'release'
    BuildCommand      = 'cargo build --release --locked'
    Rustc             = 'rustc 1.95.0 (59807616e 2026-04-14)'
    Cargo             = 'cargo 1.95.0 (f2d3ce0bd 2026-03-21)'
    Sha256            = '0c19e657120075679e12db22e5ec6b1368c245021f089043008dfd318f43a658'
    BinarySize        = 2970112
    CommandDocCount   = 32
    CommandDocsDigest = '85e8399a09ae013c365dd3b1652ae633ed127e983fd4e4466a5f7b143331a825'
}

function New-HardnessRoute {
    param(
        [string]$Name,
        [string]$Kind,
        [string]$Target,
        [string]$EntryPoint = '',
        [string[]]$Prefix = @(),
        [hashtable]$Defaults = @{},
        [string]$Description = '',
        [ValidateSet('Text', 'TaskPlanJson')][string]$OutputFormat = 'Text'
    )
    return [pscustomobject]@{
        Name         = $Name
        Kind         = $Kind
        Target       = $Target
        EntryPoint   = $EntryPoint
        Prefix       = @($Prefix)
        Defaults     = $Defaults
        Description  = $Description
        OutputFormat = $OutputFormat
    }
}

function Initialize-HardnessRoutes {
    if ($null -ne $script:HardnessRoutes) {
        return
    }

    $workspaceModule = '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $gitModule = '.agents/skills/git-operations/scripts/GitOperations.psd1'
    $openspecExecutable = '.agents/skills/openspec/bin/openspec.exe'
    $routes = New-Object System.Collections.Generic.List[object]

    $routes.Add((New-HardnessRoute 'workspace.list' 'PowerShell' $workspaceModule 'Get-HardnessWorkspaceList' @() @{} 'List registered Git workspaces without a dirty-state scan.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.status' 'PowerShell' $workspaceModule 'Get-HardnessWorkspaceStatus' @() @{} 'Inspect fast workspace identity or opt into detailed repository state.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.new' 'PowerShell' $workspaceModule 'New-HardnessWorkspace' @() @{} 'Create and bootstrap an explicitly named worktree.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.bootstrap' 'PowerShell' $workspaceModule 'Initialize-HardnessWorkspace' @() @{} 'Bootstrap an existing worktree safely.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.verify' 'PowerShell' $workspaceModule 'Test-HardnessWorkspace' @() @{} 'Verify exact gitlinks and local configuration safety.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.remove' 'PowerShell' $workspaceModule 'Remove-HardnessWorkspace' @() @{} 'Explicitly remove a clean registered worktree or recover its empty residual root.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.activate' 'PowerShell' $workspaceModule 'Set-HardnessWorkspaceSession' @() @{} 'Bind the selected workspace to this PowerShell process.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.config.status' 'PowerShell' $workspaceModule 'Get-HardnessWorkspaceConfigStatus' @() @{} 'Inspect local configuration identity and readiness without dumping values.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.config.get' 'PowerShell' $workspaceModule 'Get-HardnessWorkspaceConfigValue' @() @{} 'Read one exact local configuration key.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.config.set' 'PowerShell' $workspaceModule 'Set-HardnessWorkspaceConfigValue' @() @{} 'Atomically set one non-managed local configuration key.')) | Out-Null

    $routes.Add((New-HardnessRoute 'git.status' 'PowerShell' $gitModule 'Get-HardnessGitStatus' @() @{} 'Inspect parent and top-level submodule Git state.')) | Out-Null
    $routes.Add((New-HardnessRoute 'git.commit' 'PowerShell' $gitModule 'Complete-HardnessGitCommit' @() @{} 'Commit exact scopes with dirty submodules before parent gitlinks.')) | Out-Null
    $routes.Add((New-HardnessRoute 'git.integrate' 'PowerShell' $gitModule 'Merge-HardnessGitWorkspace' @() @{} 'Explicitly integrate an exact reviewed workspace into the primary workspace.')) | Out-Null
    $routes.Add((New-HardnessRoute 'git.push' 'PowerShell' $gitModule 'Publish-HardnessGitBranches' @() @{} 'Explicitly push named local branches without force.')) | Out-Null

    foreach ($command in @('init', 'doctor', 'status', 'instructions', 'validate', 'domain', 'spec', 'change', 'workflow', 'completion')) {
        $routes.Add((New-HardnessRoute "openspec.$command" 'Native' $openspecExecutable '' @($command) @{} "Run openspec $command.")) | Out-Null
    }
    $routes.Add((New-HardnessRoute -Name 'task.status' -Kind 'Native' -Target $openspecExecutable -Prefix @('instructions', 'apply', '--json') -Description 'Inspect the selected Task Graph through the OpenSpec parser.' -OutputFormat 'TaskPlanJson')) | Out-Null

    $routes.Add((New-HardnessRoute 'hardness.status' 'Internal' '' 'Get-HardnessStatus' @() @{} 'Inspect the selected workspace and installed harness through a fast read-only route.')) | Out-Null
    $routes.Add((New-HardnessRoute 'hardness.observe' 'Internal' '' 'Add-HardnessObservation' @() @{} 'Record one bounded ignored workflow observation.')) | Out-Null
    $routes.Add((New-HardnessRoute 'hardness.evolution.status' 'Internal' '' 'Get-HardnessEvolutionStatus' @() @{} 'Summarize local observations and the latest tracked workflow evaluation.')) | Out-Null
    $routes.Add((New-HardnessRoute 'openspec.maintenance.status' 'Internal' '' 'Get-HardnessOpenSpecMaintenanceStatus' @() @{} 'Compare packaged OpenSpec identity with its tracked source without mutation.')) | Out-Null

    $script:HardnessRoutes = @($routes | ForEach-Object { $_ })
    $script:HardnessRouteByName = @{}
    foreach ($route in $script:HardnessRoutes) {
        if ($script:HardnessRouteByName.ContainsKey([string]$route.Name)) {
            throw "Duplicate Hardness route name '$($route.Name)'."
        }
        $script:HardnessRouteByName[[string]$route.Name] = $route
    }
}

function Resolve-HardnessProjectRoot {
    param([string]$ProjectRoot)
    $candidate = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $script:HardnessHarnessRoot } else { $ProjectRoot }
    try {
        $resolved = [System.IO.Path]::GetFullPath($candidate)
    }
    catch {
        throw "Project root is not a valid file-system path: $candidate"
    }
    if ($script:HardnessResolvedRoots.ContainsKey($resolved)) {
        $cached = [string]$script:HardnessResolvedRoots[$resolved]
        if ([System.IO.Directory]::Exists($cached)) {
            return $cached
        }
        $script:HardnessResolvedRoots.Remove($resolved)
    }
    if (-not [System.IO.Directory]::Exists($resolved)) {
        throw "Project root does not exist: $resolved"
    }
    $canonical = ([System.IO.DirectoryInfo]$resolved).FullName
    $script:HardnessResolvedRoots[$resolved] = $canonical
    $script:HardnessResolvedRoots[$canonical] = $canonical
    return $canonical
}

function Invoke-HardnessGit {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $Repository @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    $result = [pscustomobject]@{
        ExitCode = $exitCode
        Output   = @($output | ForEach-Object { [string]$_ })
    }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "Unable to resolve Hardness workspace authority with git ($exitCode): $($result.Output -join [Environment]::NewLine)"
    }
    return $result
}

function Test-HardnessPathEqual {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )

    $leftPath = [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/')
    $rightPath = [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/')
    return $leftPath.Equals($rightPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-HardnessPathChainSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Purpose = 'workspace routing'
    )

    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $targetPath = [System.IO.Path]::GetFullPath($Target).TrimEnd('\', '/')
    $rootPrefix = $rootPath + [System.IO.Path]::DirectorySeparatorChar
    if (-not $targetPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing $Purpose because '$targetPath' escapes the canonical root '$rootPath'."
    }

    $current = $rootPath
    $paths = New-Object System.Collections.Generic.List[string]
    $paths.Add($current) | Out-Null
    $relative = $targetPath.Substring($rootPath.Length).TrimStart('\', '/')
    foreach ($segment in @($relative -split '[\\/]')) {
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }
        $current = Join-Path $current $segment
        $paths.Add($current) | Out-Null
    }
    foreach ($path in @($paths | ForEach-Object { $_ })) {
        $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        if ($null -eq $item) { break }
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing $Purpose because the physical path chain contains reparse point '$path'."
        }
    }
    return $targetPath
}

function Import-HardnessLeafModule {
    param([Parameter(Mandatory = $true)][string]$RelativeManifest)

    $manifest = Join-Path $script:HardnessHarnessRoot $RelativeManifest
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw "Hardness leaf module was not found: $manifest"
    }
    Import-Module $manifest -ErrorAction Stop
    return Get-Module -Name ([System.IO.Path]::GetFileNameWithoutExtension($manifest)) -ErrorAction Stop
}

function Get-HardnessLiveHead {
    param([Parameter(Mandatory = $true)][string]$WorkspaceRoot)

    $result = Invoke-HardnessGit -Repository $WorkspaceRoot -Arguments @('rev-parse', 'HEAD')
    return ([string]($result.Output | Select-Object -Last 1)).Trim().ToLowerInvariant()
}

function ConvertTo-HardnessNativeArguments {
    param([hashtable]$Parameters)
    $arguments = New-Object System.Collections.Generic.List[string]
    if ($null -eq $Parameters) {
        return @()
    }
    foreach ($key in @($Parameters.Keys | Sort-Object)) {
        $value = $Parameters[$key]
        $flag = '--' + ([regex]::Replace([string]$key, '([a-z0-9])([A-Z])', '$1-$2').Replace('_', '-').ToLowerInvariant())
        if ($value -is [bool]) {
            if ($value) { $arguments.Add($flag) | Out-Null }
            continue
        }
        if ($null -eq $value) {
            continue
        }
        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            foreach ($item in $value) {
                $arguments.Add($flag) | Out-Null
                $arguments.Add([string]$item) | Out-Null
            }
        }
        else {
            $arguments.Add($flag) | Out-Null
            $arguments.Add([string]$value) | Out-Null
        }
    }
    return @($arguments | ForEach-Object { $_ })
}

function Sort-HardnessTaskPlanTasks {
    param([object[]]$Tasks)

    $sortable = foreach ($task in @($Tasks)) {
        $id = [string]$task.id
        $match = [regex]::Match($id, '^(?<major>[0-9]+)\.(?<minor>[0-9]+)$')
        if (-not $match.Success) {
            throw "OpenSpec returned an invalid Task Graph ID '$id'."
        }
        $major = $match.Groups['major'].Value.TrimStart('0')
        $minor = $match.Groups['minor'].Value.TrimStart('0')
        if ($major.Length -eq 0) { $major = '0' }
        if ($minor.Length -eq 0) { $minor = '0' }
        [pscustomobject]@{
            Task        = $task
            MajorLength = $major.Length
            Major       = $major
            MinorLength = $minor.Length
            Minor       = $minor
            Id          = $id
        }
    }
    return @(
        $sortable |
            Sort-Object MajorLength, Major, MinorLength, Minor, Id |
            ForEach-Object { $_.Task }
    )
}

function ConvertFrom-HardnessTaskPlanOutput {
    param([object[]]$Output)

    $json = @($Output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($json)) {
        throw 'OpenSpec returned an empty TaskPlan JSON response.'
    }
    try {
        $plan = $json | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "OpenSpec returned invalid TaskPlan JSON: $($_.Exception.Message)"
    }
    $properties = @($plan.PSObject.Properties.Name)
    foreach ($required in @('changeId', 'state', 'tasks')) {
        if ($required -notin $properties) {
            throw "OpenSpec TaskPlan JSON is missing '$required'."
        }
    }
    $plan.tasks = @(Sort-HardnessTaskPlanTasks -Tasks @($plan.tasks))
    return $plan
}

function New-HardnessResult {
    param(
        [string]$Command,
        [string]$RunId,
        [string]$Status,
        [int]$ExitCode,
        [long]$DurationMs,
        [object[]]$Artifacts,
        $Data,
        $ErrorRecord
    )
    $normalizedArtifacts = @()
    if ($null -ne $Artifacts) {
        $normalizedArtifacts = @($Artifacts | Where-Object { $null -ne $_ })
    }
    return [pscustomobject][ordered]@{
        schemaVersion = $script:HardnessSchemaVersion
        command       = $Command
        runId         = $RunId
        status        = $Status
        exitCode      = $ExitCode
        durationMs    = $DurationMs
        artifacts     = $normalizedArtifacts
        data          = $Data
        error         = $ErrorRecord
    }
}

function New-HardnessContext {
    [CmdletBinding()]
    param(
        [string]$WorkspaceRoot = '',
        [switch]$Refresh
    )

    $selected = $WorkspaceRoot
    if ([string]::IsNullOrWhiteSpace($selected)) {
        $selected = [Environment]::GetEnvironmentVariable('HARDNESS_WORKSPACE_ROOT', 'Process')
    }
    if ([string]::IsNullOrWhiteSpace($selected)) {
        $selected = (Get-Location).Path
    }
    $selected = Resolve-HardnessProjectRoot -ProjectRoot $selected

    $workspaceModule = Import-HardnessLeafModule -RelativeManifest '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $command = $workspaceModule.ExportedCommands['Get-HardnessWorkspaceContext']
    if ($null -eq $command) { throw 'workspace-lifecycle does not expose Get-HardnessWorkspaceContext.' }
    $identity = & $command -ProjectRoot $selected -Refresh:$Refresh
    $identity.PSObject.TypeNames.Insert(0, 'AngelscriptProject.HardnessContext')
    if ([string]$identity.SchemaVersion -ne $script:HardnessContextSchemaVersion) {
        throw "Unsupported workspace context schema '$($identity.SchemaVersion)'."
    }
    return $identity
}

function Get-HardnessCommand {
    [CmdletBinding()]
    param([string]$Name = '')
    Initialize-HardnessRoutes
    if ([string]::IsNullOrWhiteSpace($Name)) {
        return @($script:HardnessRoutes | Sort-Object Name)
    }
    if ($script:HardnessRouteByName.ContainsKey($Name)) {
        return $script:HardnessRouteByName[$Name]
    }
    return $null
}

function Add-HardnessContextDefaults {
    param(
        [Parameter(Mandatory = $true)]$Route,
        [Parameter(Mandatory = $true)]$Context,
        [hashtable]$Parameters
    )
    $values = @{}
    foreach ($key in @($Route.Defaults.Keys)) { $values[$key] = $Route.Defaults[$key] }
    if ($null -ne $Parameters) {
        foreach ($key in @($Parameters.Keys)) { $values[$key] = $Parameters[$key] }
    }
    switch ($Route.Name) {
        { $_ -in @('workspace.list', 'workspace.status') } {
            if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.WorkspaceRoot }
        }
        'workspace.new'      {
            if (-not $values.ContainsKey('RepositoryRoot')) { $values.RepositoryRoot = $Context.PrimaryRoot }
        }
        'workspace.bootstrap' { if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.WorkspaceRoot } }
        'workspace.verify'   { if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.WorkspaceRoot } }
        'workspace.activate' {
            if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.WorkspaceRoot }
        }
        { $_ -in @('workspace.config.status', 'workspace.config.get', 'workspace.config.set', 'git.status', 'git.push') } {
            if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.WorkspaceRoot }
        }
        'git.commit' {
            if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.WorkspaceRoot }
        }
        'git.integrate' {
            if (-not $values.ContainsKey('WorkspaceRoot')) { $values.WorkspaceRoot = $Context.PrimaryRoot }
        }
        'workspace.remove'   {
            if ($values.ContainsKey('RepositoryRoot') -and -not (Test-HardnessPathEqual -Left ([string]$values.RepositoryRoot) -Right ([string]$Context.PrimaryRoot))) {
                throw 'workspace.remove RepositoryRoot must match the context PrimaryRoot.'
            }
            if ($values.ContainsKey('WorktreeRoot') -and -not (Test-HardnessPathEqual -Left ([string]$values.WorktreeRoot) -Right ([string]$Context.WorkspaceRoot))) {
                throw 'workspace.remove WorktreeRoot must match the context WorkspaceRoot.'
            }
            $values.RepositoryRoot = $Context.PrimaryRoot
            $values.WorktreeRoot = $Context.WorkspaceRoot
        }
        { $_ -in @('hardness.status', 'hardness.observe', 'hardness.evolution.status', 'openspec.maintenance.status') } {
            if (-not $values.ContainsKey('Context')) { $values.Context = $Context }
        }
    }
    return $values
}

function Invoke-Hardness {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        $Context,
        [hashtable]$Parameters = @{},
        [object[]]$ArgumentList = @()
    )

    $runId = [guid]::NewGuid().ToString('N')
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        if ($null -eq $Context) {
            $Context = New-HardnessContext
        }
        $route = Get-HardnessCommand -Name $Command
        if ($null -eq $route) {
            throw "Unknown Hardness command '$Command'. Use Get-HardnessCommand to list routes."
        }
        foreach ($required in @('HarnessRoot', 'WorkspaceRoot', 'PrimaryRoot', 'GitCommonDir', 'Topology', 'Branch', 'Head')) {
            if ($required -notin @($Context.PSObject.Properties.Name)) { throw "Invalid Hardness context: missing '$required'." }
        }
        $target = if ($route.Kind -eq 'Internal') { '' } else { Join-Path ([string]$Context.HarnessRoot) $route.Target }
        $data = $null
        $exitCode = 0
        if ($route.Kind -eq 'Internal') {
            $invokeParameters = Add-HardnessContextDefaults -Route $route -Context $Context -Parameters $Parameters
            $function = Get-Command -Name $route.EntryPoint -CommandType Function -ErrorAction Stop
            $data = & $function @invokeParameters @ArgumentList
        }
        elseif ($route.Kind -eq 'PowerShell') {
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                throw "Leaf module for '$Command' was not found: $target"
            }
            Import-Module $target -ErrorAction Stop
            $function = Get-Command -Name $route.EntryPoint -CommandType Function -ErrorAction Stop
            $invokeParameters = Add-HardnessContextDefaults -Route $route -Context $Context -Parameters $Parameters
            $data = & $function @invokeParameters @ArgumentList
        }
        elseif ($route.Kind -eq 'Native') {
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                throw "Executable for '$Command' was not found: $target"
            }
            $nativeArguments = @($route.Prefix) + @(ConvertTo-HardnessNativeArguments -Parameters $Parameters) + @($ArgumentList | ForEach-Object { [string]$_ })
            $previousPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $locationPushed = $false
            try {
                Push-Location -LiteralPath $Context.WorkspaceRoot
                $locationPushed = $true
                $output = & $target @nativeArguments 2>&1
                $exitCode = $LASTEXITCODE
            }
            finally {
                if ($locationPushed) {
                    Pop-Location
                }
                $ErrorActionPreference = $previousPreference
            }
            $data = [pscustomobject]@{ Arguments = $nativeArguments; Output = @($output | ForEach-Object { [string]$_ }) }
            if ($exitCode -ne 0) {
                throw "Native leaf '$Command' failed with exit code $exitCode."
            }
            if ($route.OutputFormat -eq 'TaskPlanJson') {
                $data = ConvertFrom-HardnessTaskPlanOutput -Output @($output)
            }
        }
        else {
            throw "Route '$Command' has unsupported kind '$($route.Kind)'."
        }

        $timer.Stop()
        $artifacts = if ($null -ne $data -and 'Artifacts' -in @($data.PSObject.Properties.Name)) { @($data.Artifacts) } else { @() }
        return New-HardnessResult -Command $Command -RunId $runId -Status 'Succeeded' -ExitCode 0 -DurationMs $timer.ElapsedMilliseconds -Artifacts $artifacts -Data $data -ErrorRecord $null
    }
    catch {
        $timer.Stop()
        $capturedExitCode = if ($null -ne (Get-Variable -Name exitCode -Scope Local -ErrorAction SilentlyContinue) -and $exitCode -is [int] -and $exitCode -ne 0) { $exitCode } else { 1 }
        $capturedData = if ($null -ne (Get-Variable -Name data -Scope Local -ErrorAction SilentlyContinue)) { $data } else { $null }
        $errorData = [pscustomobject]@{
            type    = $_.Exception.GetType().FullName
            message = $_.Exception.Message
            details = [string]$_
        }
        return New-HardnessResult -Command $Command -RunId $runId -Status 'Failed' -ExitCode $capturedExitCode -DurationMs $timer.ElapsedMilliseconds -Artifacts @() -Data $capturedData -ErrorRecord $errorData
    }
}

function Get-HardnessStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context)

    $workspaceModule = Import-HardnessLeafModule -RelativeManifest '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $statusCommand = $workspaceModule.ExportedCommands['Get-HardnessWorkspaceStatus']
    if ($null -eq $statusCommand) { throw 'workspace-lifecycle does not expose Get-HardnessWorkspaceStatus.' }
    $workspace = & $statusCommand -ProjectRoot $Context.WorkspaceRoot

    Initialize-HardnessRoutes
    $manifestPath = Join-Path $Context.HarnessRoot '.agents/skills/openspec/release-manifest.json'
    $packageVersion = ''
    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        try { $packageVersion = [string](Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop).version }
        catch { $packageVersion = 'invalid-manifest' }
    }
    return [pscustomobject][ordered]@{
        SchemaVersion = $script:HardnessContextSchemaVersion
        HarnessRoot   = $Context.HarnessRoot
        Workspace     = $workspace
        RouteCount    = $script:HardnessRoutes.Count
        PowerShell    = [pscustomobject]@{ Edition = $PSVersionTable.PSEdition; Version = [string]$PSVersionTable.PSVersion }
        OpenSpec      = [pscustomobject]@{ Installed = Test-Path -LiteralPath $manifestPath -PathType Leaf; Version = $packageVersion }
        DetailedScan  = $false
    }
}

function Add-HardnessObservation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z][A-Za-z0-9._-]{0,63}$')][string]$Category,
        [Parameter(Mandatory = $true)][ValidateLength(1, 1000)][string]$Summary,
        [ValidatePattern('^[A-Za-z0-9._/-]{0,160}$')][string]$Change = '',
        [ValidatePattern('^[A-Za-z0-9._-]{0,80}$')][string]$Stage = '',
        [ValidatePattern('^[A-Za-z0-9._-]{0,100}$')][string]$CorrelationId = '',
        [ValidateRange(0, [long]::MaxValue)][long]$DurationMs = 0
    )

    $relativeProbe = 'Saved/Hardness/Observations/__hardness_probe__.json'
    $ignored = Invoke-HardnessGit -Repository $Context.WorkspaceRoot -Arguments @('check-ignore', '--quiet', '--', $relativeProbe) -AllowFailure
    if ($ignored.ExitCode -ne 0) {
        throw "Refusing to write Hardness observations because '$relativeProbe' is not ignored."
    }

    $runId = [guid]::NewGuid().ToString('N')
    $observedAt = [DateTimeOffset]::UtcNow
    $directory = Join-Path $Context.WorkspaceRoot 'Saved/Hardness/Observations'
    [void][System.IO.Directory]::CreateDirectory($directory)
    $path = Join-Path $directory ("{0}-{1}.json" -f $observedAt.ToString('yyyyMMddTHHmmssfffZ'), $runId)
    $temporary = Join-Path $directory (".{0}.tmp" -f $runId)
    $record = [ordered]@{
        schemaVersion = 'hardness-observation-v1'
        runId         = $runId
        observedAtUtc = $observedAt.ToString('o')
        category      = $Category
        summary       = $Summary.Trim()
        change        = $Change
        stage         = $Stage
        correlationId = $CorrelationId
        durationMs    = $DurationMs
        workspaceRoot = $Context.WorkspaceRoot
        head           = Get-HardnessLiveHead -WorkspaceRoot $Context.WorkspaceRoot
    }
    try {
        [System.IO.File]::WriteAllText($temporary, ($record | ConvertTo-Json -Depth 6), [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporary, $path, $false)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) { Remove-Item -LiteralPath $temporary -Force }
    }
    return [pscustomobject][ordered]@{
        RunId       = $runId
        Path        = $path
        ObservedAt  = $observedAt
        Category    = $Category
        Artifacts   = @($path)
    }
}

function Get-HardnessEvolutionStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context)

    $observationRoot = Join-Path $Context.WorkspaceRoot 'Saved/Hardness/Observations'
    $observations = @(
        if (Test-Path -LiteralPath $observationRoot -PathType Container) {
            Get-ChildItem -LiteralPath $observationRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending
        }
    )

    $evaluations = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    foreach ($root in @(
        (Join-Path $Context.WorkspaceRoot 'openspec/changes'),
        (Join-Path $Context.WorkspaceRoot 'openspec/archive/changes')
    )) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $root -Recurse -Filter 'workflow-evaluation.md' -File -ErrorAction SilentlyContinue)) {
            $evaluations.Add($file) | Out-Null
        }
    }
    $latestEvaluation = @($evaluations | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1)
    $evaluationResult = ''
    $evaluationPath = ''
    if ($latestEvaluation.Count -eq 1) {
        $evaluationPath = $latestEvaluation[0].FullName.Substring($Context.WorkspaceRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $header = @(Get-Content -LiteralPath $latestEvaluation[0].FullName -TotalCount 24)
        $resultLine = @($header | Where-Object { $_ -match '^result:\s*([A-Za-z0-9_-]+)\s*$' } | Select-Object -First 1)
        if ($resultLine.Count -eq 1) { $evaluationResult = [regex]::Match($resultLine[0], '^result:\s*([^\s]+)').Groups[1].Value }
    }
    return [pscustomobject][ordered]@{
        ObservationRoot       = $observationRoot
        ObservationCount      = $observations.Count
        LatestObservationUtc  = if ($observations.Count -gt 0) { $observations[0].LastWriteTimeUtc.ToString('o') } else { '' }
        LatestEvaluationPath  = $evaluationPath
        LatestEvaluationResult = $evaluationResult
        RawBodiesLoaded       = $false
    }
}

function Get-HardnessOpenSpecMaintenanceStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context)

    $root = [string]$Context.HarnessRoot
    $sourcePath = Join-Path $root 'Tools/openspec'
    $manifestPath = Join-Path $root '.agents/skills/openspec/release-manifest.json'
    $executablePath = Join-Path $root '.agents/skills/openspec/bin/openspec.exe'
    $reasons = New-Object System.Collections.Generic.List[string]
    $recordedCommit = ''
    $workingHead = ''
    $sourceDirty = $false
    $manifest = $null
    $actualHash = ''

    $recorded = Invoke-HardnessGit -Repository $root -Arguments @('rev-parse', 'HEAD:Tools/openspec') -AllowFailure
    if ($recorded.ExitCode -eq 0) { $recordedCommit = ([string]($recorded.Output | Select-Object -Last 1)).Trim().ToLowerInvariant() }
    else { $reasons.Add('The parent commit does not record a Tools/openspec gitlink.') | Out-Null }

    if (Test-Path -LiteralPath $sourcePath -PathType Container) {
        $head = Invoke-HardnessGit -Repository $sourcePath -Arguments @('rev-parse', 'HEAD') -AllowFailure
        if ($head.ExitCode -eq 0) {
            $workingHead = ([string]($head.Output | Select-Object -Last 1)).Trim().ToLowerInvariant()
            $sourceStatus = Invoke-HardnessGit -Repository $sourcePath -Arguments @('status', '--porcelain=v1') -AllowFailure
            $sourceDirty = @($sourceStatus.Output).Count -gt 0
        }
        else { $reasons.Add('The Tools/openspec working tree is not initialized.') | Out-Null }
    }
    else { $reasons.Add('The Tools/openspec source path is missing.') | Out-Null }

    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        try { $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop }
        catch { $reasons.Add('The packaged OpenSpec release manifest is invalid JSON.') | Out-Null }
    }
    else { $reasons.Add('The packaged OpenSpec release manifest is missing.') | Out-Null }
    if (Test-Path -LiteralPath $executablePath -PathType Leaf) {
        $actualHash = (Get-FileHash -LiteralPath $executablePath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    else { $reasons.Add('The packaged OpenSpec executable is missing.') | Out-Null }

    if ($null -ne $manifest) {
        if ($recordedCommit -ne [string]$manifest.sourceCommit) { $reasons.Add('The parent gitlink does not match the packaged source commit.') | Out-Null }
        if (-not [string]::IsNullOrWhiteSpace($workingHead) -and $workingHead -ne [string]$manifest.sourceCommit) { $reasons.Add('The initialized source HEAD does not match the packaged source commit.') | Out-Null }
        if ($actualHash -ne [string]$manifest.sha256) { $reasons.Add('The packaged executable hash does not match the release manifest.') | Out-Null }
    }
    if ($sourceDirty) { $reasons.Add('The Tools/openspec source working tree is dirty.') | Out-Null }

    return [pscustomobject][ordered]@{
        SourcePath       = $sourcePath
        RecordedCommit   = $recordedCommit
        WorkingHead      = $workingHead
        SourceDirty      = $sourceDirty
        PackagedVersion  = if ($null -ne $manifest) { [string]$manifest.version } else { '' }
        PackagedSha256   = $actualHash
        ManifestSha256   = if ($null -ne $manifest) { [string]$manifest.sha256 } else { '' }
        Aligned          = $reasons.Count -eq 0
        Reasons          = @($reasons | ForEach-Object { $_ })
        Mutated          = $false
    }
}

function Get-HardnessPackageSafetyModule {
    if ($null -ne $script:HardnessPackageSafetyModule) {
        return $script:HardnessPackageSafetyModule
    }
    $modulePath = Join-Path $script:HardnessHarnessRoot '.agents\skills\openspec\scripts\OpenSpecPackageSafety.psm1'
    if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
        throw "Trusted OpenSpec package-safety verifier is missing: $modulePath"
    }
    $script:HardnessPackageSafetyModule = Import-Module -Name $modulePath -Force -PassThru -ErrorAction Stop
    return $script:HardnessPackageSafetyModule
}

function ConvertTo-HardnessManifestInteger {
    param(
        $Value,
        [Parameter(Mandatory = $true)][string]$Field
    )

    if ($null -eq $Value) {
        throw "OpenSpec release-manifest schema field '$Field' must be an integer."
    }
    $typeCode = [System.Type]::GetTypeCode($Value.GetType())
    if ($typeCode -notin @(
        [System.TypeCode]::Byte, [System.TypeCode]::SByte,
        [System.TypeCode]::Int16, [System.TypeCode]::UInt16,
        [System.TypeCode]::Int32, [System.TypeCode]::UInt32,
        [System.TypeCode]::Int64, [System.TypeCode]::UInt64
    )) {
        throw "OpenSpec release-manifest schema field '$Field' must be a JSON integer."
    }
    try { return [long]$Value }
    catch { throw "OpenSpec release-manifest schema field '$Field' is outside the supported integer range." }
}

function Assert-HardnessOpenSpecManifestSchema {
    param([Parameter(Mandatory = $true)]$Metadata)

    if ($Metadata -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'OpenSpec release-manifest schema requires one JSON object.'
    }
    $required = @(
        'version', 'sourceCommit', 'sourceTag', 'sourceTagType', 'sourceTagObject', 'sourceTagTarget',
        'target', 'profile', 'buildCommand', 'rustc', 'cargo', 'sha256', 'binarySize',
        'commandDocCount', 'commandDocsDigest', 'releaseGates'
    )
    $actual = @($Metadata.PSObject.Properties.Name)
    $missing = @($required | Where-Object { $_ -notin $actual })
    $unexpected = @($actual | Where-Object { $_ -notin $required })
    if ($missing.Count -gt 0 -or $unexpected.Count -gt 0) {
        throw "OpenSpec release-manifest schema mismatch. Missing: $($missing -join ', '); unexpected: $($unexpected -join ', ')."
    }
    foreach ($name in @(
        'version', 'sourceCommit', 'sourceTag', 'sourceTagType', 'sourceTagObject', 'sourceTagTarget',
        'target', 'profile', 'buildCommand', 'rustc', 'cargo', 'sha256', 'commandDocsDigest'
    )) {
        if ($Metadata.$name -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$Metadata.$name)) {
            throw "OpenSpec release-manifest schema field '$name' must be a non-empty string."
        }
    }
    $binarySize = ConvertTo-HardnessManifestInteger -Value $Metadata.binarySize -Field 'binarySize'
    $docCount = ConvertTo-HardnessManifestInteger -Value $Metadata.commandDocCount -Field 'commandDocCount'
    if ($binarySize -le 0) {
        throw "OpenSpec release-manifest schema field 'binarySize' must be a positive integer."
    }
    if ($docCount -le 0 -or $docCount -gt [int]::MaxValue) {
        throw "OpenSpec release-manifest schema field 'commandDocCount' must be a positive integer."
    }
    foreach ($name in @('sourceCommit', 'sourceTagObject', 'sourceTagTarget')) {
        if ([string]$Metadata.$name -notmatch '^[0-9a-f]{40}$') {
            throw "OpenSpec release-manifest schema field '$name' must be a lowercase 40-character Git object ID."
        }
    }
    foreach ($name in @('sha256', 'commandDocsDigest')) {
        if ([string]$Metadata.$name -notmatch '^[0-9a-f]{64}$') {
            throw "OpenSpec release-manifest schema field '$name' must be a lowercase SHA-256 value."
        }
    }

    $expectedGateCommands = @(
        'cargo fmt --check',
        'cargo clippy --locked --all-targets -- -D warnings',
        'cargo test --locked --all-targets',
        'cargo test --locked --test command_docs',
        'cargo build --release --locked',
        'cargo build --release --locked --target-dir <isolated> and byte-compare'
    )
    $gates = @($Metadata.releaseGates)
    if ($gates.Count -ne $expectedGateCommands.Count) {
        throw "OpenSpec release-manifest schema requires $($expectedGateCommands.Count) release gates; found $($gates.Count)."
    }
    for ($index = 0; $index -lt $gates.Count; $index++) {
        $gate = $gates[$index]
        $gateProperties = @($gate.PSObject.Properties.Name)
        foreach ($name in @('command', 'status', 'exitCode')) {
            if ($name -notin $gateProperties) {
                throw "OpenSpec release-manifest gate $index is missing schema field '$name'."
            }
        }
        $allowedGateProperties = @('command', 'status', 'exitCode')
        if ($index -eq $gates.Count - 1) { $allowedGateProperties += 'sha256' }
        $unexpectedGateProperties = @($gateProperties | Where-Object { $_ -notin $allowedGateProperties })
        if ($unexpectedGateProperties.Count -gt 0) {
            throw "OpenSpec release-manifest gate $index has unexpected schema fields: $($unexpectedGateProperties -join ', ')."
        }
        $gateExitCode = ConvertTo-HardnessManifestInteger -Value $gate.exitCode -Field "releaseGates[$index].exitCode"
        if ([string]$gate.command -ne $expectedGateCommands[$index] -or [string]$gate.status -ne 'passed' -or $gateExitCode -ne 0) {
            throw "OpenSpec release-manifest gate $index does not describe the required successful command."
        }
    }
    if ([string]$gates[-1].sha256 -ne $script:HardnessOpenSpecIdentity.Sha256) {
        throw 'OpenSpec release-manifest reproducibility gate does not bind the final executable identity.'
    }
}

function Assert-HardnessOpenSpecFinalIdentity {
    param([Parameter(Mandatory = $true)]$Metadata)

    $expected = $script:HardnessOpenSpecIdentity
    $bindings = [ordered]@{
        version           = $expected.Version
        sourceCommit      = $expected.SourceCommit
        sourceTag         = $expected.SourceTag
        sourceTagType     = $expected.SourceTagType
        sourceTagObject   = $expected.SourceTagObject
        sourceTagTarget   = $expected.SourceTagTarget
        target            = $expected.Target
        profile           = $expected.Profile
        buildCommand      = $expected.BuildCommand
        rustc             = $expected.Rustc
        cargo             = $expected.Cargo
        sha256            = $expected.Sha256
        binarySize        = [string]$expected.BinarySize
        commandDocCount   = [string]$expected.CommandDocCount
        commandDocsDigest = $expected.CommandDocsDigest
    }
    foreach ($name in @($bindings.Keys)) {
        if ([string]$Metadata.$name -ne [string]$bindings[$name]) {
            throw "OpenSpec release identity mismatch for '$name': expected '$($bindings[$name])', found '$($Metadata.$name)'."
        }
    }
}

function Get-HardnessCommandDocsDigest {
    param(
        [Parameter(Mandatory = $true)][string]$DocsRoot,
        [Parameter(Mandatory = $true)][System.IO.FileInfo[]]$Files
    )

    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
    try {
        [byte[]]$separator = @(0)
        foreach ($file in $Files) {
            if ($file.Length -gt 1048576) {
                throw "OpenSpec command document exceeds the 1 MiB verifier bound: $($file.Name)"
            }
            $relative = $file.FullName.Substring($DocsRoot.Length).TrimStart('\', '/').Replace('\', '/')
            [byte[]]$pathBytes = [System.Text.Encoding]::UTF8.GetBytes($relative)
            [byte[]]$sourceBytes = [System.IO.File]::ReadAllBytes($file.FullName)
            $documentText = $utf8.GetString($sourceBytes).Replace("`r`n", "`n").Replace("`r", "`n")
            [byte[]]$fileBytes = $utf8.GetBytes($documentText)
            if ($pathBytes.Length -gt 0) { [void]$algorithm.TransformBlock($pathBytes, 0, $pathBytes.Length, $pathBytes, 0) }
            [void]$algorithm.TransformBlock($separator, 0, 1, $separator, 0)
            if ($fileBytes.Length -gt 0) { [void]$algorithm.TransformBlock($fileBytes, 0, $fileBytes.Length, $fileBytes, 0) }
            [void]$algorithm.TransformBlock($separator, 0, 1, $separator, 0)
        }
        [void]$algorithm.TransformFinalBlock([byte[]]@(), 0, 0)
        return ([System.BitConverter]::ToString($algorithm.Hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $algorithm.Dispose()
    }
}

function Assert-HardnessOpenSpecPackage {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $safetyModule = Get-HardnessPackageSafetyModule
    $assertExisting = $safetyModule.ExportedCommands['Assert-OpenSpecSafeExistingPath']
    $assertContained = $safetyModule.ExportedCommands['Assert-OpenSpecSafeContainedPath']
    $assertTree = $safetyModule.ExportedCommands['Assert-OpenSpecSafeTree']
    if ($null -eq $assertExisting -or $null -eq $assertContained -or $null -eq $assertTree) {
        throw 'Trusted OpenSpec package-safety verifier does not expose its bounded path checks.'
    }

    $root = & $assertExisting -Path $ProjectRoot -Description 'Hardness installation root' -Container
    $skillRoot = & $assertContained -Root $root -Path (Join-Path $root '.agents\skills\openspec') -Description 'OpenSpec package root'
    [void](& $assertExisting -Path $skillRoot -Description 'OpenSpec package root' -Container)
    $manifestPath = & $assertContained -Root $skillRoot -Path (Join-Path $skillRoot 'release-manifest.json') -Description 'OpenSpec release manifest'
    $executablePath = & $assertContained -Root $skillRoot -Path (Join-Path $skillRoot 'bin\openspec.exe') -Description 'OpenSpec executable'
    $docsRoot = & $assertContained -Root $skillRoot -Path (Join-Path $skillRoot 'commands') -Description 'OpenSpec command docs'
    [void](& $assertExisting -Path $manifestPath -Description 'OpenSpec release manifest' -Leaf)
    [void](& $assertExisting -Path $executablePath -Description 'OpenSpec executable' -Leaf)
    [void](& $assertExisting -Path $docsRoot -Description 'OpenSpec command docs' -Container)
    [void](& $assertTree -Root $skillRoot -Path $docsRoot -Description 'OpenSpec command docs')

    $manifestInfo = Get-Item -LiteralPath $manifestPath -Force
    if ($manifestInfo.Length -le 1 -or $manifestInfo.Length -gt 65536) {
        throw "OpenSpec release manifest exceeds the 64 KiB verifier bound or is empty: $($manifestInfo.Length) bytes."
    }
    try {
        $metadata = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "OpenSpec release-manifest schema is invalid JSON: $($_.Exception.Message)"
    }
    Assert-HardnessOpenSpecManifestSchema -Metadata $metadata
    Assert-HardnessOpenSpecFinalIdentity -Metadata $metadata

    $executableInfo = Get-Item -LiteralPath $executablePath -Force
    if ($executableInfo.Length -ne [long]$script:HardnessOpenSpecIdentity.BinarySize) {
        throw "OpenSpec executable size identity mismatch: expected $($script:HardnessOpenSpecIdentity.BinarySize), found $($executableInfo.Length)."
    }
    $actualHash = (Get-FileHash -LiteralPath $executablePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne [string]$script:HardnessOpenSpecIdentity.Sha256 -or $actualHash -ne [string]$metadata.sha256) {
        throw "OpenSpec executable hash identity mismatch: $actualHash"
    }

    $allDocsFiles = @(Get-ChildItem -LiteralPath $docsRoot -Recurse -File | Sort-Object FullName)
    $docsFiles = @($allDocsFiles | Where-Object { $_.Extension -eq '.md' })
    if ($docsFiles.Count -ne [int]$script:HardnessOpenSpecIdentity.CommandDocCount) {
        throw "OpenSpec command-doc set mismatch: expected $($script:HardnessOpenSpecIdentity.CommandDocCount) Markdown files, found $($docsFiles.Count)."
    }
    if ($allDocsFiles.Count -ne $docsFiles.Count) {
        throw "OpenSpec command-doc set contains $($allDocsFiles.Count - $docsFiles.Count) unexpected non-Markdown files."
    }
    $totalDocsBytes = [long]0
    foreach ($file in $docsFiles) { $totalDocsBytes += $file.Length }
    if ($totalDocsBytes -gt 8388608) {
        throw "OpenSpec command docs exceed the 8 MiB verifier bound: $totalDocsBytes bytes."
    }
    $actualDocsDigest = Get-HardnessCommandDocsDigest -DocsRoot $docsRoot -Files $docsFiles
    if ($actualDocsDigest -ne [string]$script:HardnessOpenSpecIdentity.CommandDocsDigest -or $actualDocsDigest -ne [string]$metadata.commandDocsDigest) {
        throw "OpenSpec command-doc digest identity mismatch: $actualDocsDigest"
    }

    # All static identity checks complete before the package binary is allowed to execute.
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $versionOutput = @(& $executablePath --version 2>&1)
        $versionExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    $versionText = ($versionOutput | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    $versionText = $versionText.Trim()
    if ($versionExitCode -ne 0 -or $versionText -ne "openspec $($script:HardnessOpenSpecIdentity.Version)") {
        throw "Verified OpenSpec package executable reports '$versionText' (exit $versionExitCode), expected 'openspec $($script:HardnessOpenSpecIdentity.Version)'."
    }
    return [pscustomobject]@{
        Verified          = $true
        Version           = [string]$metadata.version
        SourceCommit      = [string]$metadata.sourceCommit
        SourceTag         = [string]$metadata.sourceTag
        ExecutableSha256  = $actualHash
        CommandDocsDigest = $actualDocsDigest
        CommandDocCount   = $docsFiles.Count
    }
}

function Test-HardnessInstallation {
    [CmdletBinding()]
    param([string]$ProjectRoot = '')

    $root = Resolve-HardnessProjectRoot -ProjectRoot $ProjectRoot
    Initialize-HardnessRoutes
    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $openSpecPackage = [pscustomobject]@{
        Verified          = $false
        Version           = [string]$script:HardnessOpenSpecIdentity.Version
        SourceCommit      = [string]$script:HardnessOpenSpecIdentity.SourceCommit
        SourceTag         = [string]$script:HardnessOpenSpecIdentity.SourceTag
        ExecutableSha256  = ''
        CommandDocsDigest = ''
        CommandDocCount   = 0
    }
    $workspaceManifest = Join-Path $root '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    if (-not (Test-Path -LiteralPath $workspaceManifest -PathType Leaf)) {
        $errors.Add("Missing workspace module: $workspaceManifest") | Out-Null
    }
    else {
        try { Test-ModuleManifest -Path $workspaceManifest -ErrorAction Stop | Out-Null } catch { $errors.Add($_.Exception.Message) | Out-Null }
    }
    $gitManifest = Join-Path $root '.agents/skills/git-operations/scripts/GitOperations.psd1'
    if (-not (Test-Path -LiteralPath $gitManifest -PathType Leaf)) {
        $errors.Add("Missing Git operations module: $gitManifest") | Out-Null
    }
    else {
        try { Test-ModuleManifest -Path $gitManifest -ErrorAction Stop | Out-Null } catch { $errors.Add($_.Exception.Message) | Out-Null }
    }
    try {
        $openSpecPackage = Assert-HardnessOpenSpecPackage -ProjectRoot $root
    }
    catch {
        $errors.Add("OpenSpec package verification failed: $($_.Exception.Message)") | Out-Null
    }
    $duplicateNames = @($script:HardnessRoutes | Group-Object Name | Where-Object Count -gt 1)
    if ($duplicateNames.Count -gt 0) {
        $errors.Add("Duplicate route names: $($duplicateNames.Name -join ', ')") | Out-Null
    }
    return [pscustomobject]@{
        IsValid  = $errors.Count -eq 0
        Root     = $root
        Routes   = $script:HardnessRoutes.Count
        OpenSpecPackage = $openSpecPackage
        Errors   = @($errors | ForEach-Object { $_ })
        Warnings = @($warnings | ForEach-Object { $_ })
    }
}

Export-ModuleMember -Function @(
    'New-HardnessContext',
    'Get-HardnessCommand',
    'Invoke-Hardness',
    'Test-HardnessInstallation'
)
