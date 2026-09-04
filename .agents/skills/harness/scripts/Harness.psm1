#requires -Version 7.0
#requires -PSEdition Core
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:HarnessSchemaVersion = '1.0'
$script:HarnessRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$script:HarnessContextSchemaVersion = '3'
$script:HarnessRoutes = $null
$script:HarnessRouteByName = $null
$script:HarnessResolvedRoots = @{}
$script:HarnessPackageSafetyModule = $null
$script:HarnessChangeTypes = @('feature', 'fix', 'refactor', 'improve', 'docs', 'test', 'chore')
$script:HarnessChangeNameContract = '<domain>/<type>-<scope>-<outcome>; allowed types: feature, fix, refactor, improve, docs, test, chore'
$script:HarnessOpenSpecIdentity = [ordered]@{
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

function New-HarnessRoute {
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

function Initialize-HarnessRoutes {
    if ($null -ne $script:HarnessRoutes) {
        return
    }

    $workspaceModule = '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $gitModule = '.agents/skills/git-operations/scripts/GitOperations.psd1'
    $unrealModule = '.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1'
    $openspecExecutable = '.agents/skills/openspec/bin/openspec.exe'
    $routes = New-Object System.Collections.Generic.List[object]

    $routes.Add((New-HarnessRoute 'workspace.list' 'PowerShell' $workspaceModule 'Get-HarnessWorkspaceList' @() @{} 'List registered Git workspaces without a dirty-state scan.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.status' 'PowerShell' $workspaceModule 'Get-HarnessWorkspaceStatus' @() @{} 'Inspect fast workspace identity or opt into detailed repository state.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.new' 'PowerShell' $workspaceModule 'New-HarnessWorkspace' @() @{} 'Create and bootstrap an explicitly named worktree.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.bootstrap' 'PowerShell' $workspaceModule 'Initialize-HarnessWorkspace' @() @{} 'Bootstrap an existing worktree safely.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.verify' 'PowerShell' $workspaceModule 'Test-HarnessWorkspace' @() @{} 'Verify exact gitlinks and local configuration safety.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.remove' 'PowerShell' $workspaceModule 'Remove-HarnessWorkspace' @() @{} 'Explicitly remove a clean registered worktree or recover its empty residual root.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.activate' 'PowerShell' $workspaceModule 'Set-HarnessWorkspaceSession' @() @{} 'Bind the selected workspace to this PowerShell process.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.config.status' 'PowerShell' $workspaceModule 'Get-HarnessWorkspaceConfigStatus' @() @{} 'Inspect local configuration identity and readiness without dumping values.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.config.get' 'PowerShell' $workspaceModule 'Get-HarnessWorkspaceConfigValue' @() @{} 'Read one exact local configuration key.')) | Out-Null
    $routes.Add((New-HarnessRoute 'workspace.config.set' 'PowerShell' $workspaceModule 'Set-HarnessWorkspaceConfigValue' @() @{} 'Atomically set one non-managed local configuration key.')) | Out-Null

    $routes.Add((New-HarnessRoute 'git.status' 'PowerShell' $gitModule 'Get-HarnessGitStatus' @() @{} 'Inspect parent and top-level submodule Git state.')) | Out-Null
    $routes.Add((New-HarnessRoute 'git.commit' 'PowerShell' $gitModule 'Complete-HarnessGitCommit' @() @{} 'Commit exact scopes with dirty submodules before parent gitlinks.')) | Out-Null
    $routes.Add((New-HarnessRoute 'git.integrate' 'PowerShell' $gitModule 'Merge-HarnessGitWorkspace' @() @{} 'Explicitly integrate an exact reviewed workspace into the primary workspace.')) | Out-Null
    $routes.Add((New-HarnessRoute 'git.push' 'PowerShell' $gitModule 'Publish-HarnessGitBranches' @() @{} 'Explicitly push named local branches without force.')) | Out-Null

    $routes.Add((New-HarnessRoute 'ue.status' 'PowerShell' $unrealModule 'Get-HarnessUnrealStatus' @() @{} 'Inspect Unreal readiness for the selected workspace.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.engine.list' 'PowerShell' $unrealModule 'Get-HarnessUnrealEngineList' @() @{} 'List configured and registered Unreal Engine installations.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.target.list' 'PowerShell' $unrealModule 'Get-HarnessUnrealTargetList' @() @{} 'List project targets by source scan or an explicit UBT query.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.process.list' 'PowerShell' $unrealModule 'Get-HarnessUnrealProcessList' @() @{} 'List bounded Unreal-related processes for workspace diagnostics.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.ubt.capabilities' 'PowerShell' $unrealModule 'Get-HarnessUnrealUbtCapabilities' @() @{} 'Inspect the maintained UBT capability catalog.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.ubt.invoke' 'PowerShell' $unrealModule 'Invoke-HarnessUnrealUbt' @() @{} 'Plan or invoke one maintained UBT capability.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.build' 'PowerShell' $unrealModule 'Invoke-HarnessUnrealBuild' @() @{ BuildConcurrency = 'Auto' } 'Plan or execute one typed Unreal project build.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.test' 'PowerShell' $unrealModule 'Invoke-HarnessUnrealTest' @() @{} 'Plan or execute one Unreal Automation selection.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.commandlet' 'PowerShell' $unrealModule 'Invoke-HarnessUnrealCommandlet' @() @{} 'Plan or execute one named Unreal commandlet.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.suite.list' 'PowerShell' $unrealModule 'Get-HarnessUnrealSuiteList' @() @{} 'List maintained declarative Unreal Automation suites.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.suite.plan' 'PowerShell' $unrealModule 'New-HarnessUnrealSuitePlan' @() @{} 'Create one deterministic Unreal suite plan.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.suite.run' 'PowerShell' $unrealModule 'Invoke-HarnessUnrealSuite' @() @{} 'Plan or execute one sequential Unreal suite.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.run.status' 'PowerShell' $unrealModule 'Get-HarnessUnrealRunStatus' @() @{} 'Inspect one exact Unreal run identity.')) | Out-Null
    $routes.Add((New-HarnessRoute 'ue.run.cancel' 'PowerShell' $unrealModule 'Stop-HarnessUnrealRun' @() @{} 'Explicitly cancel one exact Unreal run.')) | Out-Null

    foreach ($command in @('init', 'doctor', 'status', 'instructions', 'validate', 'domain', 'spec', 'change', 'workflow', 'completion')) {
        $routes.Add((New-HarnessRoute "openspec.$command" 'Native' $openspecExecutable '' @($command) @{} "Run openspec $command.")) | Out-Null
    }
    $routes.Add((New-HarnessRoute -Name 'task.status' -Kind 'Native' -Target $openspecExecutable -Prefix @('instructions', 'apply', '--json') -Description 'Inspect the selected Task Graph through the OpenSpec parser.' -OutputFormat 'TaskPlanJson')) | Out-Null

    $routes.Add((New-HarnessRoute 'harness.status' 'Internal' '' 'Get-HarnessStatus' @() @{} 'Inspect the selected workspace and installed harness through a fast read-only route.')) | Out-Null
    $routes.Add((New-HarnessRoute 'harness.observe' 'Internal' '' 'Add-HarnessObservation' @() @{} 'Record one bounded ignored workflow observation.')) | Out-Null
    $routes.Add((New-HarnessRoute 'harness.evolution.status' 'Internal' '' 'Get-HarnessEvolutionStatus' @() @{} 'Summarize observations or inspect one exact Change evolution lifecycle and optional terminal gate.')) | Out-Null
    $routes.Add((New-HarnessRoute 'openspec.maintenance.status' 'Internal' '' 'Get-HarnessOpenSpecMaintenanceStatus' @() @{} 'Compare packaged OpenSpec identity with its tracked source without mutation.')) | Out-Null

    $script:HarnessRoutes = @($routes | ForEach-Object { $_ })
    $script:HarnessRouteByName = @{}
    foreach ($route in $script:HarnessRoutes) {
        if ($script:HarnessRouteByName.ContainsKey([string]$route.Name)) {
            throw "Duplicate Harness route name '$($route.Name)'."
        }
        $script:HarnessRouteByName[[string]$route.Name] = $route
    }
}

function Resolve-HarnessProjectRoot {
    param([string]$ProjectRoot)
    $candidate = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $script:HarnessRoot } else { $ProjectRoot }
    try {
        $resolved = [System.IO.Path]::GetFullPath($candidate)
    }
    catch {
        throw "Project root is not a valid file-system path: $candidate"
    }
    if ($script:HarnessResolvedRoots.ContainsKey($resolved)) {
        $cached = [string]$script:HarnessResolvedRoots[$resolved]
        if ([System.IO.Directory]::Exists($cached)) {
            return $cached
        }
        $script:HarnessResolvedRoots.Remove($resolved)
    }
    if (-not [System.IO.Directory]::Exists($resolved)) {
        throw "Project root does not exist: $resolved"
    }
    $canonical = ([System.IO.DirectoryInfo]$resolved).FullName
    $script:HarnessResolvedRoots[$resolved] = $canonical
    $script:HarnessResolvedRoots[$canonical] = $canonical
    return $canonical
}

function Invoke-HarnessGit {
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
        throw "Unable to resolve Harness workspace authority with git ($exitCode): $($result.Output -join [Environment]::NewLine)"
    }
    return $result
}

function Test-HarnessPathEqual {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )

    $leftPath = [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/')
    $rightPath = [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/')
    return $leftPath.Equals($rightPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-HarnessPathChainSafe {
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

function Import-HarnessLeafModule {
    param([Parameter(Mandatory = $true)][string]$RelativeManifest)

    $manifest = Join-Path $script:HarnessRoot $RelativeManifest
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw "Harness leaf module was not found: $manifest"
    }
    Import-Module $manifest -ErrorAction Stop
    return Get-Module -Name ([System.IO.Path]::GetFileNameWithoutExtension($manifest)) -ErrorAction Stop
}

function Test-HarnessSemanticChangeId {
    param([string]$ChangeId)

    if ([string]::IsNullOrWhiteSpace($ChangeId) -or $ChangeId -cne $ChangeId.Trim()) {
        return $false
    }
    $pathSegments = @($ChangeId -split '/')
    if ($pathSegments.Count -lt 2 -or @($pathSegments | Where-Object { $_ -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$' }).Count -gt 0) {
        return $false
    }
    $leafParts = @($pathSegments[-1] -split '-')
    if ($leafParts.Count -lt 3 -or $leafParts[0] -cnotin $script:HarnessChangeTypes) {
        return $false
    }
    return $true
}

function New-HarnessCodedException {
    param(
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $exception = [System.ArgumentException]::new($Message)
    $exception.Data['HarnessErrorCode'] = $Code
    return $exception
}

function Assert-HarnessOpenSpecChangeName {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [object[]]$ArgumentList = @()
    )

    if ($Command -cne 'openspec.change' -or $ArgumentList.Count -eq 0) {
        return
    }
    $operation = ([string]$ArgumentList[0]).ToLowerInvariant()
    $target = ''
    if ($operation -eq 'create' -and $ArgumentList.Count -ge 2) {
        $target = [string]$ArgumentList[1]
    }
    elseif ($operation -eq 'move') {
        for ($index = 1; $index -lt $ArgumentList.Count; $index++) {
            $argument = [string]$ArgumentList[$index]
            if ($argument -eq '--to' -and ($index + 1) -lt $ArgumentList.Count) {
                $target = [string]$ArgumentList[$index + 1]
                break
            }
            if ($argument.StartsWith('--to=', [System.StringComparison]::Ordinal)) {
                $target = $argument.Substring(5)
                break
            }
        }
    }
    if ([string]::IsNullOrWhiteSpace($target)) {
        return
    }
    if (-not (Test-HarnessSemanticChangeId -ChangeId $target)) {
        throw (New-HarnessCodedException -Code 'InvalidChangeName' -Message "OpenSpec Change target '$target' must follow $script:HarnessChangeNameContract. Change IDs use 'feature', not the Git commit alias 'feat'.")
    }
}

function Get-HarnessInvalidActiveChangeIds {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $changesRoot = Join-Path $ProjectRoot 'openspec/changes'
    if (-not (Test-Path -LiteralPath $changesRoot -PathType Container)) {
        return @()
    }
    $invalid = New-Object System.Collections.Generic.List[string]
    foreach ($domainDirectory in @(Get-ChildItem -LiteralPath $changesRoot -Directory -Force -ErrorAction Stop)) {
        foreach ($changeDirectory in @(Get-ChildItem -LiteralPath $domainDirectory.FullName -Directory -Force -ErrorAction Stop)) {
            if (-not (Test-Path -LiteralPath (Join-Path $changeDirectory.FullName 'change.yaml') -PathType Leaf)) {
                continue
            }
            $changeId = '{0}/{1}' -f $domainDirectory.Name, $changeDirectory.Name
            if (-not (Test-HarnessSemanticChangeId -ChangeId $changeId)) {
                $invalid.Add($changeId) | Out-Null
            }
        }
    }
    return @($invalid | Sort-Object -Unique)
}

function Get-HarnessLiveHead {
    param([Parameter(Mandatory = $true)][string]$WorkspaceRoot)

    $result = Invoke-HarnessGit -Repository $WorkspaceRoot -Arguments @('rev-parse', 'HEAD')
    return ([string]($result.Output | Select-Object -Last 1)).Trim().ToLowerInvariant()
}

function ConvertTo-HarnessNativeArguments {
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

function Sort-HarnessTaskPlanTasks {
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

function ConvertFrom-HarnessTaskPlanOutput {
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
    $plan.tasks = @(Sort-HarnessTaskPlanTasks -Tasks @($plan.tasks))
    return $plan
}

function New-HarnessResult {
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
        schemaVersion = $script:HarnessSchemaVersion
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

function New-HarnessContext {
    [CmdletBinding()]
    param(
        [string]$WorkspaceRoot = '',
        [switch]$Refresh
    )

    $selected = $WorkspaceRoot
    if ([string]::IsNullOrWhiteSpace($selected)) {
        $selected = [Environment]::GetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', 'Process')
    }
    if ([string]::IsNullOrWhiteSpace($selected)) {
        $selected = (Get-Location).Path
    }
    $selected = Resolve-HarnessProjectRoot -ProjectRoot $selected

    $workspaceModule = Import-HarnessLeafModule -RelativeManifest '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $command = $workspaceModule.ExportedCommands['Get-HarnessWorkspaceContext']
    if ($null -eq $command) { throw 'workspace-lifecycle does not expose Get-HarnessWorkspaceContext.' }
    $identity = & $command -ProjectRoot $selected -Refresh:$Refresh
    $identity.PSObject.TypeNames.Insert(0, 'AngelscriptProject.HarnessContext')
    if ([string]$identity.SchemaVersion -ne $script:HarnessContextSchemaVersion) {
        throw "Unsupported workspace context schema '$($identity.SchemaVersion)'."
    }
    return $identity
}

function Get-HarnessCommand {
    [CmdletBinding()]
    param([string]$Name = '')
    Initialize-HarnessRoutes
    if ([string]::IsNullOrWhiteSpace($Name)) {
        return @($script:HarnessRoutes | Sort-Object Name)
    }
    if ($script:HarnessRouteByName.ContainsKey($Name)) {
        return $script:HarnessRouteByName[$Name]
    }
    return $null
}

function Set-HarnessAuthoritativePathParameter {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Values,
        [Parameter(Mandatory = $true)][string[]]$Names,
        [Parameter(Mandatory = $true)][string]$CanonicalName,
        [Parameter(Mandatory = $true)][string]$ExpectedValue,
        [Parameter(Mandatory = $true)][string]$RouteName
    )

    foreach ($name in $Names) {
        if (-not $Values.ContainsKey($name)) {
            continue
        }
        $requestedValue = [string]$Values[$name]
        $matchesContext = $false
        if (-not [string]::IsNullOrWhiteSpace($requestedValue)) {
            try {
                $matchesContext = Test-HarnessPathEqual -Left $requestedValue -Right $ExpectedValue
            }
            catch {
                $matchesContext = $false
            }
        }
        if (-not $matchesContext) {
            throw (New-HarnessCodedException -Code 'ContextAuthorityMismatch' -Message "Route '$RouteName' parameter '$name' must match the selected Harness Context value '$ExpectedValue'; received '$requestedValue'.")
        }
    }
    foreach ($name in $Names) {
        [void]$Values.Remove($name)
    }
    $Values[$CanonicalName] = $ExpectedValue
}

function Add-HarnessContextDefaults {
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
        { $_ -like 'ue.*' } {
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('WorkspaceRoot', 'ProjectRoot') -CanonicalName 'WorkspaceRoot' -ExpectedValue ([string]$Context.WorkspaceRoot) -RouteName ([string]$Route.Name)
        }
        { $_ -in @(
                'workspace.list', 'workspace.status', 'workspace.bootstrap', 'workspace.verify', 'workspace.activate',
                'workspace.config.status', 'workspace.config.get', 'workspace.config.set'
            ) } {
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('WorkspaceRoot', 'ProjectRoot') -CanonicalName 'WorkspaceRoot' -ExpectedValue ([string]$Context.WorkspaceRoot) -RouteName ([string]$Route.Name)
        }
        'workspace.new' {
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('RepositoryRoot') -CanonicalName 'RepositoryRoot' -ExpectedValue ([string]$Context.PrimaryRoot) -RouteName ([string]$Route.Name)
        }
        { $_ -in @('git.status', 'git.commit', 'git.push') } {
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('WorkspaceRoot', 'ProjectRoot') -CanonicalName 'WorkspaceRoot' -ExpectedValue ([string]$Context.WorkspaceRoot) -RouteName ([string]$Route.Name)
        }
        'git.integrate' {
            if (-not (Test-HarnessPathEqual -Left ([string]$Context.WorkspaceRoot) -Right ([string]$Context.PrimaryRoot))) {
                throw (New-HarnessCodedException -Code 'ContextAuthorityMismatch' -Message "Route 'git.integrate' requires the canonical primary Harness Context; selected '$($Context.WorkspaceRoot)'.")
            }
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('WorkspaceRoot', 'ProjectRoot') -CanonicalName 'WorkspaceRoot' -ExpectedValue ([string]$Context.WorkspaceRoot) -RouteName ([string]$Route.Name)
        }
        'workspace.remove' {
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('RepositoryRoot') -CanonicalName 'RepositoryRoot' -ExpectedValue ([string]$Context.PrimaryRoot) -RouteName ([string]$Route.Name)
            Set-HarnessAuthoritativePathParameter -Values $values -Names @('WorktreeRoot') -CanonicalName 'WorktreeRoot' -ExpectedValue ([string]$Context.WorkspaceRoot) -RouteName ([string]$Route.Name)
        }
        { $_ -in @('harness.status', 'harness.observe', 'harness.evolution.status', 'openspec.maintenance.status') } {
            if ($values.ContainsKey('Context')) {
                throw (New-HarnessCodedException -Code 'ContextAuthorityMismatch' -Message "Route '$($Route.Name)' receives Context only from the Harness dispatcher; caller replacement is forbidden.")
            }
            $values.Context = $Context
        }
    }
    return $values
}

function Test-HarnessUnrealExecutionFailure {
    param(
        [Parameter(Mandatory = $true)][string]$RouteName,
        $Data
    )

    if ($RouteName -notin @('ue.build', 'ue.ubt.invoke', 'ue.test', 'ue.commandlet', 'ue.suite.run') -or $null -eq $Data) {
        return $false
    }
    $stateProperty = $Data.PSObject.Properties['State']
    if ($null -eq $stateProperty) {
        return $false
    }
    return [string]$stateProperty.Value -in @('Failed', 'TimedOut', 'Cancelled', 'Orphaned')
}

function New-HarnessUnrealExecutionFailureResult {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string]$RunId,
        [Parameter(Mandatory = $true)][long]$DurationMs,
        [Parameter(Mandatory = $true)]$Data
    )

    $operationExitCode = 0
    $exitCodeProperty = $Data.PSObject.Properties['ExitCode']
    if ($null -eq $exitCodeProperty -or -not [int]::TryParse([string]$exitCodeProperty.Value, [ref]$operationExitCode) -or $operationExitCode -eq 0) {
        $operationExitCode = 1
    }
    $state = [string]$Data.PSObject.Properties['State'].Value
    $operationRunId = ''
    $runIdProperty = $Data.PSObject.Properties['RunId']
    if ($null -ne $runIdProperty) {
        $operationRunId = [string]$runIdProperty.Value
    }
    $message = "Unreal execution route '$Command' reached terminal state '$state' with exit code $operationExitCode."
    if (-not [string]::IsNullOrWhiteSpace($operationRunId)) {
        $message = "Unreal execution route '$Command' reached terminal state '$state' with exit code $operationExitCode for run '$operationRunId'."
    }
    $artifacts = if ('Artifacts' -in @($Data.PSObject.Properties.Name)) { @($Data.Artifacts) } else { @() }
    $errorData = [pscustomobject]@{
        code    = 'UnrealOperationFailed'
        type    = 'AngelscriptProject.HarnessUnrealOperationFailure'
        message = $message
        details = $message
    }
    return New-HarnessResult -Command $Command -RunId $RunId -Status 'Failed' -ExitCode $operationExitCode -DurationMs $DurationMs -Artifacts $artifacts -Data $Data -ErrorRecord $errorData
}

function Invoke-Harness {
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
            $Context = New-HarnessContext
        }
        $route = Get-HarnessCommand -Name $Command
        if ($null -eq $route) {
            throw "Unknown Harness command '$Command'. Use Get-HarnessCommand to list routes."
        }
        foreach ($required in @('HarnessRoot', 'WorkspaceRoot', 'PrimaryRoot', 'GitCommonDir', 'Topology', 'Branch', 'Head')) {
            if ($required -notin @($Context.PSObject.Properties.Name)) { throw "Invalid Harness context: missing '$required'." }
        }
        Assert-HarnessOpenSpecChangeName -Command $Command -ArgumentList $ArgumentList
        $target = if ($route.Kind -eq 'Internal') { '' } else { Join-Path ([string]$Context.HarnessRoot) $route.Target }
        $data = $null
        $exitCode = 0
        if ($route.Kind -eq 'Internal') {
            $invokeParameters = Add-HarnessContextDefaults -Route $route -Context $Context -Parameters $Parameters
            $function = Get-Command -Name $route.EntryPoint -CommandType Function -ErrorAction Stop
            $data = & $function @invokeParameters @ArgumentList
        }
        elseif ($route.Kind -eq 'PowerShell') {
            $invokeParameters = Add-HarnessContextDefaults -Route $route -Context $Context -Parameters $Parameters
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                throw "Leaf module for '$Command' was not found: $target"
            }
            Import-Module $target -ErrorAction Stop
            $function = Get-Command -Name $route.EntryPoint -CommandType Function -ErrorAction Stop
            $data = & $function @invokeParameters @ArgumentList
        }
        elseif ($route.Kind -eq 'Native') {
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                throw "Executable for '$Command' was not found: $target"
            }
            $nativeArguments = @($route.Prefix) + @(ConvertTo-HarnessNativeArguments -Parameters $Parameters) + @($ArgumentList | ForEach-Object { [string]$_ })
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
                $data = ConvertFrom-HarnessTaskPlanOutput -Output @($output)
            }
        }
        else {
            throw "Route '$Command' has unsupported kind '$($route.Kind)'."
        }

        $timer.Stop()
        if ($route.Kind -eq 'PowerShell' -and (Test-HarnessUnrealExecutionFailure -RouteName $Command -Data $data)) {
            return New-HarnessUnrealExecutionFailureResult -Command $Command -RunId $runId -DurationMs $timer.ElapsedMilliseconds -Data $data
        }
        $artifacts = if ($null -ne $data -and 'Artifacts' -in @($data.PSObject.Properties.Name)) { @($data.Artifacts) } else { @() }
        return New-HarnessResult -Command $Command -RunId $runId -Status 'Succeeded' -ExitCode 0 -DurationMs $timer.ElapsedMilliseconds -Artifacts $artifacts -Data $data -ErrorRecord $null
    }
    catch {
        $timer.Stop()
        $capturedExitCode = if ($null -ne (Get-Variable -Name exitCode -Scope Local -ErrorAction SilentlyContinue) -and $exitCode -is [int] -and $exitCode -ne 0) { $exitCode } else { 1 }
        $capturedData = if ($null -ne (Get-Variable -Name data -Scope Local -ErrorAction SilentlyContinue)) { $data } else { $null }
        $errorCode = if ($_.Exception.Data.Contains('HarnessErrorCode')) { [string]$_.Exception.Data['HarnessErrorCode'] } else { 'HarnessFailure' }
        $errorData = [pscustomobject]@{
            code    = $errorCode
            type    = $_.Exception.GetType().FullName
            message = $_.Exception.Message
            details = [string]$_
        }
        return New-HarnessResult -Command $Command -RunId $runId -Status 'Failed' -ExitCode $capturedExitCode -DurationMs $timer.ElapsedMilliseconds -Artifacts @() -Data $capturedData -ErrorRecord $errorData
    }
}

function Get-HarnessStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context)

    $workspaceModule = Import-HarnessLeafModule -RelativeManifest '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $statusCommand = $workspaceModule.ExportedCommands['Get-HarnessWorkspaceStatus']
    if ($null -eq $statusCommand) { throw 'workspace-lifecycle does not expose Get-HarnessWorkspaceStatus.' }
    $workspace = & $statusCommand -ProjectRoot $Context.WorkspaceRoot

    Initialize-HarnessRoutes
    $manifestPath = Join-Path $Context.HarnessRoot '.agents/skills/openspec/release-manifest.json'
    $packageVersion = ''
    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        try { $packageVersion = [string](Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop).version }
        catch { $packageVersion = 'invalid-manifest' }
    }
    return [pscustomobject][ordered]@{
        SchemaVersion = $script:HarnessContextSchemaVersion
        HarnessRoot   = $Context.HarnessRoot
        Workspace     = $workspace
        RouteCount    = $script:HarnessRoutes.Count
        PowerShell    = [pscustomobject]@{ Edition = $PSVersionTable.PSEdition; Version = [string]$PSVersionTable.PSVersion }
        OpenSpec      = [pscustomobject]@{ Installed = Test-Path -LiteralPath $manifestPath -PathType Leaf; Version = $packageVersion }
        DetailedScan  = $false
    }
}

function Add-HarnessObservation {
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

    $relativeProbe = 'Saved/Harness/Observations/__harness_probe__.json'
    $ignored = Invoke-HarnessGit -Repository $Context.WorkspaceRoot -Arguments @('check-ignore', '--quiet', '--', $relativeProbe) -AllowFailure
    if ($ignored.ExitCode -ne 0) {
        throw "Refusing to write Harness observations because '$relativeProbe' is not ignored."
    }

    $runId = [guid]::NewGuid().ToString('N')
    $observedAt = [DateTimeOffset]::UtcNow
    $directory = Join-Path $Context.WorkspaceRoot 'Saved/Harness/Observations'
    [void][System.IO.Directory]::CreateDirectory($directory)
    $path = Join-Path $directory ("{0}-{1}.json" -f $observedAt.ToString('yyyyMMddTHHmmssfffZ'), $runId)
    $temporary = Join-Path $directory (".{0}.tmp" -f $runId)
    $record = [ordered]@{
        schemaVersion = 'harness-observation-v1'
        runId         = $runId
        observedAtUtc = $observedAt.ToString('o')
        category      = $Category
        summary       = $Summary.Trim()
        change        = $Change
        stage         = $Stage
        correlationId = $CorrelationId
        durationMs    = $DurationMs
        workspaceRoot = $Context.WorkspaceRoot
        head           = Get-HarnessLiveHead -WorkspaceRoot $Context.WorkspaceRoot
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

function ConvertFrom-HarnessFrontmatterScalar {
    param([AllowEmptyString()][string]$Value)

    if ($null -eq $Value) { return '' }
    $normalized = $Value.Trim()
    if ($normalized.Length -ge 2) {
        $first = $normalized.Substring(0, 1)
        $last = $normalized.Substring($normalized.Length - 1, 1)
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            return $normalized.Substring(1, $normalized.Length - 2).Trim()
        }
    }
    return $normalized
}

function Read-HarnessFrontmatter {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [ValidateRange(4, 256)][int]$MaximumLines = 96,
        [ValidateRange(256, 131072)][int]$MaximumCharacters = 32768
    )

    $metadata = @{}
    $collectionBuilders = @{}
    $errors = New-Object System.Collections.Generic.List[string]
    $reader = $null
    $linesRead = 0
    $charactersRead = 0
    $closed = $false
    try {
        $reader = [System.IO.StreamReader]::new($Path, [System.Text.UTF8Encoding]::new($false), $true)
        $first = $reader.ReadLine()
        $linesRead++
        if ($null -eq $first) {
            $errors.Add('frontmatter is missing') | Out-Null
        }
        else {
            $first = $first.TrimStart([char]0xFEFF)
            $charactersRead += $first.Length
            if ($first.Trim() -ne '---') {
                $errors.Add('frontmatter opening delimiter is missing') | Out-Null
            }
            else {
                $currentCollection = ''
                while ($linesRead -lt $MaximumLines -and $charactersRead -le $MaximumCharacters) {
                    $line = $reader.ReadLine()
                    if ($null -eq $line) { break }
                    $linesRead++
                    $charactersRead += $line.Length
                    if ($charactersRead -gt $MaximumCharacters) { break }
                    if ($line -match '^---[ \t]*$') {
                        $closed = $true
                        break
                    }
                    if ([string]::IsNullOrWhiteSpace($line) -or $line -match '^[ \t]*#') { continue }

                    $scalarMatch = [regex]::Match($line, '^(?<name>[A-Za-z_][A-Za-z0-9_-]*)[ \t]*:[ \t]*(?<value>.*)$')
                    if ($scalarMatch.Success) {
                        $name = $scalarMatch.Groups['name'].Value
                        if ($metadata.ContainsKey($name)) {
                            $errors.Add("duplicate frontmatter key '$name'") | Out-Null
                        }
                        else {
                            $metadata[$name] = ConvertFrom-HarnessFrontmatterScalar $scalarMatch.Groups['value'].Value
                        }
                        $currentCollection = if ([string]::IsNullOrWhiteSpace([string]$metadata[$name])) { $name } else { '' }
                        continue
                    }

                    $itemMatch = [regex]::Match($line, '^[ \t]+-[ \t]+(?<value>\S.*)$')
                    if (-not [string]::IsNullOrWhiteSpace($currentCollection) -and $itemMatch.Success) {
                        if (-not $collectionBuilders.ContainsKey($currentCollection)) {
                            $collectionBuilders[$currentCollection] = New-Object System.Collections.Generic.List[string]
                        }
                        $collectionBuilders[$currentCollection].Add((ConvertFrom-HarnessFrontmatterScalar $itemMatch.Groups['value'].Value)) | Out-Null
                        continue
                    }
                    $currentCollection = ''
                }
                if (-not $closed) {
                    $errors.Add("frontmatter closing delimiter was not found within $MaximumLines lines and $MaximumCharacters characters") | Out-Null
                }
            }
        }
    }
    catch {
        $errors.Add("frontmatter could not be read: $($_.Exception.Message)") | Out-Null
    }
    finally {
        if ($null -ne $reader) { $reader.Dispose() }
    }

    $collections = @{}
    foreach ($key in @($collectionBuilders.Keys)) {
        $collections[$key] = @($collectionBuilders[$key] | ForEach-Object { [string]$_ })
    }
    return [pscustomobject][ordered]@{
        Metadata       = $metadata
        Collections    = $collections
        Errors         = @($errors | ForEach-Object { [string]$_ })
        LinesRead      = $linesRead
        CharactersRead = $charactersRead
        BodyRead       = $false
    }
}

function Get-HarnessFrontmatterValue {
    param(
        [Parameter(Mandatory = $true)]$Frontmatter,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($Frontmatter.Metadata.ContainsKey($Name)) { return [string]$Frontmatter.Metadata[$Name] }
    return ''
}

function Get-HarnessFrontmatterCollection {
    param(
        [Parameter(Mandatory = $true)]$Frontmatter,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($Frontmatter.Collections.ContainsKey($Name)) { return @($Frontmatter.Collections[$Name]) }
    $inline = Get-HarnessFrontmatterValue -Frontmatter $Frontmatter -Name $Name
    $match = [regex]::Match($inline, '^\[(?<items>.*)\]$')
    if (-not $match.Success) { return @() }
    $values = New-Object System.Collections.Generic.List[string]
    foreach ($item in ($match.Groups['items'].Value -split ',')) {
        $value = ConvertFrom-HarnessFrontmatterScalar $item
        if (-not [string]::IsNullOrWhiteSpace($value)) { $values.Add($value) | Out-Null }
    }
    return @($values | ForEach-Object { [string]$_ })
}

function Test-HarnessIsoTimestamp {
    param([AllowEmptyString()][string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value) -or $Value -cnotmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$') { return $false }
    $parsed = [DateTimeOffset]::MinValue
    return [DateTimeOffset]::TryParse(
        $Value,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::RoundtripKind,
        [ref]$parsed)
}

function ConvertTo-HarnessIsoInstant {
    param([AllowEmptyString()][string]$Value)

    if (-not (Test-HarnessIsoTimestamp $Value)) { return $null }
    return [DateTimeOffset]::Parse(
        $Value,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::RoundtripKind)
}

function Get-HarnessAttachmentIndexCount {
    param(
        [AllowEmptyString()][string]$IndexText,
        [Parameter(Mandatory = $true)][string]$AttachmentRelativePath
    )

    if ([string]::IsNullOrWhiteSpace($IndexText)) { return 0 }
    $escapedPath = [regex]::Escape($AttachmentRelativePath.Replace('\', '/'))
    return [regex]::Matches($IndexText, "(?m)^[ \t]*-[ \t]+``$escapedPath``(?:[ \t]|$)").Count
}

function Get-HarnessIssueBodyProblems {
    param([Parameter(Mandatory = $true)][string]$Path)

    $problems = New-Object System.Collections.Generic.List[string]
    $file = Get-Item -LiteralPath $Path -ErrorAction Stop
    if ($file.Length -gt 4MB) {
        $problems.Add('issue body exceeds the 4 MiB validation limit') | Out-Null
        return @($problems)
    }
    $text = [System.IO.File]::ReadAllText($file.FullName)
    foreach ($heading in @('Symptom', 'Investigation Log', 'Root Cause', 'Disposition', 'Evidence', 'Links')) {
        $match = [regex]::Match($text, "(?ms)^##[ \t]+$([regex]::Escape($heading))[ \t]*\r?\n(?<body>.*?)(?=^##[ \t]+|\z)")
        if (-not $match.Success -or [string]::IsNullOrWhiteSpace($match.Groups['body'].Value)) {
            $problems.Add("required issue section '$heading' is missing or empty") | Out-Null
        }
    }
    foreach ($heading in @('Failure Evidence (RED)', 'Resolution Evidence (GREEN)', 'What This Proves', 'What This Does Not Prove')) {
        $match = [regex]::Match($text, "(?ms)^###[ \t]+$([regex]::Escape($heading))[ \t]*\r?\n(?<body>.*?)(?=^###[ \t]+|^##[ \t]+|\z)")
        if (-not $match.Success -or [string]::IsNullOrWhiteSpace($match.Groups['body'].Value)) {
            $problems.Add("required issue evidence section '$heading' is missing or empty") | Out-Null
        }
    }
    return @($problems | ForEach-Object { [string]$_ })
}

function Get-HarnessReviewFindingRecords {
    param([Parameter(Mandatory = $true)][string]$Path)

    $file = Get-Item -LiteralPath $Path -ErrorAction Stop
    if ($file.Length -gt 8MB) { throw 'Review body exceeds the 8 MiB validation limit.' }
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $headingMatches = @([regex]::Matches($text, '(?im)^[ \t]*#{2,6}[ \t]+Finding(?:[ \t]+[0-9]+)?(?:\b|[ \t]+|-).*?$'))
    $records = New-Object System.Collections.Generic.List[object]
    for ($index = 0; $index -lt $headingMatches.Count; $index++) {
        $start = $headingMatches[$index].Index
        $end = if ($index + 1 -lt $headingMatches.Count) { $headingMatches[$index + 1].Index } else { $text.Length }
        $body = $text.Substring($start, $end - $start)
        $severityMatch = [regex]::Match($body, '(?im)^[ \t]*(?:[-*][ \t]*)?severity[ \t]*:[ \t]*(?<value>Critical|Required|Advisory)[ \t]*$')
        $statusMatch = [regex]::Match($body, '(?im)^[ \t]*(?:[-*][ \t]*)?(?:status|state)[ \t]*:[ \t]*(?<value>open|resolved|rejected|deferred)[ \t]*$')
        $records.Add([pscustomobject][ordered]@{
            Heading  = $headingMatches[$index].Value.Trim()
            Severity = if ($severityMatch.Success) { $severityMatch.Groups['value'].Value } else { '' }
            Status   = if ($statusMatch.Success) { $statusMatch.Groups['value'].Value.ToLowerInvariant() } else { '' }
        }) | Out-Null
    }
    return @($records | ForEach-Object { $_ })
}

function Get-HarnessChangeYamlId {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return '' }
    foreach ($line in @(Get-Content -LiteralPath $Path -TotalCount 32)) {
        $match = [regex]::Match([string]$line, '^[ \t]+id[ \t]*:[ \t]*(?<value>[^#\r\n]+)')
        if ($match.Success) { return ConvertFrom-HarnessFrontmatterScalar $match.Groups['value'].Value }
    }
    return ''
}

function Resolve-HarnessEvolutionChange {
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,63}/[A-Za-z0-9][A-Za-z0-9._-]{0,127}$')][string]$Change
    )

    $segments = @($Change -split '/', 2)
    $candidates = New-Object System.Collections.Generic.List[object]
    $activeRoot = Join-Path $Context.WorkspaceRoot ("openspec/changes/{0}/{1}" -f $segments[0], $segments[1])
    $activeYaml = Join-Path $activeRoot 'change.yaml'
    if ((Test-Path -LiteralPath $activeYaml -PathType Leaf) -and (Get-HarnessChangeYamlId -Path $activeYaml) -eq $Change) {
        $candidates.Add([pscustomobject]@{ Root = [System.IO.Path]::GetFullPath($activeRoot); Archived = $false }) | Out-Null
    }

    $archiveDomain = Join-Path $Context.WorkspaceRoot ("openspec/archive/changes/{0}" -f $segments[0])
    if (Test-Path -LiteralPath $archiveDomain -PathType Container) {
        foreach ($directory in @(Get-ChildItem -LiteralPath $archiveDomain -Directory -ErrorAction SilentlyContinue)) {
            $changeYaml = Join-Path $directory.FullName 'change.yaml'
            if ((Test-Path -LiteralPath $changeYaml -PathType Leaf) -and (Get-HarnessChangeYamlId -Path $changeYaml) -eq $Change) {
                $candidates.Add([pscustomobject]@{ Root = $directory.FullName; Archived = $true }) | Out-Null
            }
        }
    }

    if ($candidates.Count -eq 0) { throw "Exact Change '$Change' was not found in the selected workspace." }
    if ($candidates.Count -gt 1) { throw "Exact Change '$Change' is ambiguous across active and archived records." }
    return $candidates[0]
}

function Get-HarnessWorkspaceRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $root = [System.IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\', '/')
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$fullPath' is outside selected workspace '$root'."
    }
    return $fullPath.Substring($prefix.Length).Replace('\', '/')
}

function Invoke-HarnessEvolutionTaskPlan {
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$Change
    )

    $executable = Join-Path ([string]$Context.HarnessRoot) '.agents/skills/openspec/bin/openspec.exe'
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw "Packaged OpenSpec executable is missing: $executable"
    }
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $locationPushed = $false
    try {
        Push-Location -LiteralPath ([string]$Context.WorkspaceRoot)
        $locationPushed = $true
        $output = @(& $executable instructions apply --json --change $Change 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        if ($locationPushed) { Pop-Location }
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw "OpenSpec TaskPlan failed with exit code ${exitCode}: $(@($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine)"
    }
    return ConvertFrom-HarnessTaskPlanOutput -Output @($output)
}

function Add-HarnessLengthFramedHashData {
    param(
        [Parameter(Mandatory = $true)][System.Security.Cryptography.IncrementalHash]$Hash,
        [Parameter(Mandatory = $true)][byte[]]$Data
    )

    $length = [BitConverter]::GetBytes([long]$Data.LongLength)
    if ([BitConverter]::IsLittleEndian) { [Array]::Reverse($length) }
    $Hash.AppendData($length)
    if ($Data.Length -gt 0) { $Hash.AppendData($Data) }
}

function Get-HarnessChangeInputSha256 {
    param([Parameter(Mandatory = $true)][string]$ChangeRoot)

    $root = [System.IO.Path]::GetFullPath($ChangeRoot).TrimEnd('\', '/')
    $excluded = 'attachments/data/workflow-evaluation.md'
    $files = New-Object System.Collections.Generic.List[object]
    foreach ($file in @(Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction Stop)) {
        $relative = $file.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
        if ($relative -ne $excluded) { $files.Add([pscustomobject]@{ File = $file; Relative = $relative }) | Out-Null }
    }
    $files.Sort([System.Comparison[object]]{
        param($left, $right)
        return [System.StringComparer]::Ordinal.Compare([string]$left.Relative, [string]$right.Relative)
    })
    $hash = [System.Security.Cryptography.IncrementalHash]::CreateHash([System.Security.Cryptography.HashAlgorithmName]::SHA256)
    try {
        foreach ($entry in $files) {
            if (($entry.File.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Change input contains a reparse-point file: $($entry.Relative)"
            }
            Add-HarnessLengthFramedHashData -Hash $hash -Data ([System.Text.Encoding]::UTF8.GetBytes([string]$entry.Relative))
            Add-HarnessLengthFramedHashData -Hash $hash -Data ([System.IO.File]::ReadAllBytes($entry.File.FullName))
        }
        return [Convert]::ToHexString($hash.GetHashAndReset()).ToLowerInvariant()
    }
    finally {
        $hash.Dispose()
    }
}

function Get-HarnessEvolutionStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,63}/[A-Za-z0-9][A-Za-z0-9._-]{0,127}$')][string]$Change = '',
        [ValidateSet('completed', 'abandoned', 'superseded')][string]$ClosureKind = 'completed',
        [switch]$RequireTerminal
    )

    if ($RequireTerminal -and [string]::IsNullOrWhiteSpace($Change)) {
        throw 'RequireTerminal requires one exact Change identity.'
    }

    $observationRoot = Join-Path $Context.WorkspaceRoot 'Saved/Harness/Observations'
    $legacyObservationRoot = Join-Path $Context.WorkspaceRoot 'Saved/Hardness/Observations'
    $observations = @(@(
        foreach ($root in @($observationRoot, $legacyObservationRoot)) {
            if (Test-Path -LiteralPath $root -PathType Container) {
                Get-ChildItem -LiteralPath $root -Filter '*.json' -File
            }
        }
    ) | Sort-Object FullName -Unique | Sort-Object LastWriteTimeUtc -Descending)

    if ([string]::IsNullOrWhiteSpace($Change)) {
        $evaluations = New-Object System.Collections.Generic.List[object]
        foreach ($root in @(
            (Join-Path $Context.WorkspaceRoot 'openspec/changes'),
            (Join-Path $Context.WorkspaceRoot 'openspec/archive/changes')
        )) {
            if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
            foreach ($file in @(Get-ChildItem -LiteralPath $root -Recurse -Filter 'workflow-evaluation.md' -File -ErrorAction SilentlyContinue)) {
                $frontmatter = Read-HarnessFrontmatter -Path $file.FullName
                $record = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'record'
                $capturedAt = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'captured_at'
                $isHistoricalArchive = $file.FullName.IndexOf((Join-Path $Context.WorkspaceRoot 'openspec/archive/changes'), [System.StringComparison]::OrdinalIgnoreCase) -ge 0
                $recognizedRecord = $record -eq 'harness-workflow-evaluation-v1' -or ($isHistoricalArchive -and $record -eq 'hardness-workflow-evaluation-v1')
                if ($frontmatter.Errors.Count -eq 0 -and $recognizedRecord -and (Test-HarnessIsoTimestamp $capturedAt)) {
                    $evaluations.Add([pscustomobject]@{
                        Path       = Get-HarnessWorkspaceRelativePath -WorkspaceRoot $Context.WorkspaceRoot -Path $file.FullName
                        Result     = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'result'
                        Change     = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'change'
                        CapturedAt = [DateTimeOffset]::Parse($capturedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
                    }) | Out-Null
                }
            }
        }
        $latestEvaluation = @($evaluations | Sort-Object CapturedAt -Descending | Select-Object -First 1)
        return [pscustomobject][ordered]@{
            ObservationRoot            = $observationRoot
            LegacyObservationRoot      = $legacyObservationRoot
            ObservationCount           = $observations.Count
            LatestObservationUtc       = if ($observations.Count -gt 0) { $observations[0].LastWriteTimeUtc.ToString('o') } else { '' }
            LatestEvaluationPath       = if ($latestEvaluation.Count -eq 1) { $latestEvaluation[0].Path } else { '' }
            LatestEvaluationResult     = if ($latestEvaluation.Count -eq 1) { $latestEvaluation[0].Result } else { '' }
            LatestEvaluationChange     = if ($latestEvaluation.Count -eq 1) { $latestEvaluation[0].Change } else { '' }
            LatestEvaluationCapturedAt = if ($latestEvaluation.Count -eq 1) { $latestEvaluation[0].CapturedAt.ToString('o') } else { '' }
            RawBodiesLoaded            = $false
        }
    }

    $resolvedChange = Resolve-HarnessEvolutionChange -Context $Context -Change $Change
    $changeRoot = [string]$resolvedChange.Root
    if ($RequireTerminal -and [bool]$resolvedChange.Archived) {
        throw 'RequireTerminal applies only to one exact active Change. Use openspec validate --archived --strict --json for historical archived validation.'
    }
    $attachmentRoot = Join-Path $changeRoot 'attachments'
    $implementationRoot = Join-Path $attachmentRoot 'implementation'
    $reviewRoot = Join-Path $attachmentRoot 'reviews'
    $indexPath = Join-Path $attachmentRoot 'INDEX.md'
    $indexText = if (Test-Path -LiteralPath $indexPath -PathType Leaf) { (Get-Content -LiteralPath $indexPath -Raw).Replace('\', '/') } else { '' }
    $structuralErrors = New-Object System.Collections.Generic.List[string]
    $closureBlockers = New-Object System.Collections.Generic.List[string]
    $openIssuePaths = New-Object System.Collections.Generic.List[string]
    $issueRecords = New-Object System.Collections.Generic.List[object]
    $counts = [ordered]@{ Open = 0; Resolved = 0; Rejected = 0; Superseded = 0 }
    $legacyIssueCount = 0
    $reviewRecords = New-Object System.Collections.Generic.List[object]
    $reviewCounts = [ordered]@{ Open = 0; Closed = 0; Superseded = 0 }
    $legacyReviewCount = 0
    $openReviewPaths = New-Object System.Collections.Generic.List[string]
    $terminalEvidenceInstants = New-Object System.Collections.Generic.List[DateTimeOffset]
    $currentInputSha256 = ''
    $taskPlanValid = $false
    $taskCount = 0
    $incompleteTaskIds = @()
    $taskIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

    if (-not [bool]$resolvedChange.Archived) {
        try {
            $currentInputSha256 = Get-HarnessChangeInputSha256 -ChangeRoot $changeRoot
        }
        catch {
            $structuralErrors.Add("Change input digest is invalid: $($_.Exception.Message)") | Out-Null
        }
        try {
            $taskPlan = Invoke-HarnessEvolutionTaskPlan -Context $Context -Change $Change
            $taskPlanValid = $true
            $taskCount = @($taskPlan.tasks).Count
            $incompleteTaskIds = @($taskPlan.tasks | Where-Object { -not [bool]$_.done } | ForEach-Object { [string]$_.id })
            foreach ($task in @($taskPlan.tasks)) { [void]$taskIds.Add([string]$task.id) }
        }
        catch {
            $structuralErrors.Add("TaskPlan is invalid: $($_.Exception.Message)") | Out-Null
        }
    }

    $isActiveChange = -not [bool]$resolvedChange.Archived
    if (Test-Path -LiteralPath $implementationRoot -PathType Container) {
        foreach ($file in @(Get-ChildItem -LiteralPath $implementationRoot -Recurse -File -Filter 'issue-*.md' | Sort-Object FullName)) {
            $relativePath = Get-HarnessWorkspaceRelativePath -WorkspaceRoot $Context.WorkspaceRoot -Path $file.FullName
            $attachmentRelativePath = $file.FullName.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
            $frontmatter = Read-HarnessFrontmatter -Path $file.FullName
            foreach ($problem in @($frontmatter.Errors)) { $structuralErrors.Add("${relativePath}: $problem") | Out-Null }
            $schema = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'issue_schema'
            $issueId = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'issue_id'
            $status = (Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'status').ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($schema)) {
                $legacyIssueCount++
                if ($isActiveChange) { $structuralErrors.Add("${relativePath}: active material issue requires issue_schema openspec-material-issue-v2") | Out-Null }
                $issueRecords.Add([pscustomobject]@{ Path = $relativePath; IssueId = $issueId; Status = $status; Schema = ''; Frontmatter = $frontmatter }) | Out-Null
                continue
            }
            if ($schema -ne 'openspec-material-issue-v2') {
                $structuralErrors.Add("${relativePath}: unsupported issue_schema '$schema'") | Out-Null
                continue
            }
            if ($file.BaseName -cnotmatch '^issue-\d{8}-\d{6}-[a-z0-9][a-z0-9-]*$') { $structuralErrors.Add("${relativePath}: invalid material issue filename") | Out-Null }
            if ($issueId -ne $file.BaseName) { $structuralErrors.Add("${relativePath}: issue_id must match the filename stem") | Out-Null }
            if ($status -notin @('open', 'resolved', 'rejected', 'superseded')) {
                $structuralErrors.Add("${relativePath}: invalid status '$status'") | Out-Null
            }
            else {
                $counts[(Get-Culture).TextInfo.ToTitleCase($status)]++
            }
            $source = (Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'source').ToLowerInvariant()
            if ($source -notin @('dogfooding', 'implementation', 'verification', 'review', 'dependency', 'user')) { $structuralErrors.Add("${relativePath}: invalid source '$source'") | Out-Null }
            if ([string]::IsNullOrWhiteSpace((Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'source_ref'))) { $structuralErrors.Add("${relativePath}: source_ref is required") | Out-Null }
            $affectedTasks = @(Get-HarnessFrontmatterCollection -Frontmatter $frontmatter -Name 'affected_tasks')
            if ($affectedTasks.Count -eq 0) { $structuralErrors.Add("${relativePath}: affected_tasks requires at least one task ID") | Out-Null }
            foreach ($taskId in $affectedTasks) {
                if ($taskId -cnotmatch '^\d+\.\d+$') { $structuralErrors.Add("${relativePath}: affected_tasks contains invalid task ID '$taskId'") | Out-Null }
                elseif ($isActiveChange -and $taskPlanValid -and -not $taskIds.Contains($taskId)) { $structuralErrors.Add("${relativePath}: affected_tasks references unknown TaskPlan ID '$taskId'") | Out-Null }
            }
            $createdAt = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'created_at'
            if (-not (Test-HarnessIsoTimestamp $createdAt)) { $structuralErrors.Add("${relativePath}: created_at must be an ISO-8601 timestamp") | Out-Null }
            $resolvedAt = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'resolved_at'
            $resolutionRef = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'resolution_ref'
            $supersededBy = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'superseded_by'
            if ($status -in @('resolved', 'rejected')) {
                if (-not (Test-HarnessIsoTimestamp $resolvedAt)) { $structuralErrors.Add("${relativePath}: $status status requires an ISO-8601 resolved_at") | Out-Null }
                if ([string]::IsNullOrWhiteSpace($resolutionRef)) { $structuralErrors.Add("${relativePath}: $status status requires resolution_ref") | Out-Null }
                if (-not [string]::IsNullOrWhiteSpace($supersededBy)) { $structuralErrors.Add("${relativePath}: $status status forbids superseded_by") | Out-Null }
            }
            elseif ($status -eq 'superseded') {
                if (-not (Test-HarnessIsoTimestamp $resolvedAt)) { $structuralErrors.Add("${relativePath}: superseded status requires an ISO-8601 resolved_at") | Out-Null }
                if ($supersededBy -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,63}/[A-Za-z0-9][A-Za-z0-9._-]{0,127}#issue-\d{8}-\d{6}-[a-z0-9][a-z0-9-]*$') { $structuralErrors.Add("${relativePath}: superseded_by must name one exact material issue") | Out-Null }
                if (-not [string]::IsNullOrWhiteSpace($resolutionRef)) { $structuralErrors.Add("${relativePath}: superseded status forbids resolution_ref") | Out-Null }
            }
            elseif ($status -eq 'open') {
                if (-not [string]::IsNullOrWhiteSpace($resolvedAt) -or -not [string]::IsNullOrWhiteSpace($resolutionRef) -or -not [string]::IsNullOrWhiteSpace($supersededBy)) { $structuralErrors.Add("${relativePath}: open status forbids terminal fields") | Out-Null }
                $openIssuePaths.Add($relativePath) | Out-Null
            }
            if ($isActiveChange) {
                $createdInstant = ConvertTo-HarnessIsoInstant $createdAt
                $resolvedInstant = ConvertTo-HarnessIsoInstant $resolvedAt
                if ($null -ne $createdInstant -and $null -ne $resolvedInstant) {
                    if ($resolvedInstant -lt $createdInstant) { $structuralErrors.Add("${relativePath}: resolved_at must not precede created_at (invalid timestamp order)") | Out-Null }
                    else { $terminalEvidenceInstants.Add($resolvedInstant) | Out-Null }
                }
                $indexCount = Get-HarnessAttachmentIndexCount -IndexText $indexText -AttachmentRelativePath $attachmentRelativePath
                if ($indexCount -ne 1) { $structuralErrors.Add("${relativePath}: must appear in attachments/INDEX.md exactly once (actual $indexCount)") | Out-Null }
                try {
                    foreach ($problem in @(Get-HarnessIssueBodyProblems -Path $file.FullName)) { $structuralErrors.Add("${relativePath}: $problem") | Out-Null }
                }
                catch {
                    $structuralErrors.Add("${relativePath}: issue body validation failed ($($_.Exception.Message))") | Out-Null
                }
            }
            $issueRecords.Add([pscustomobject]@{ Path = $relativePath; IssueId = $issueId; Status = $status; Schema = $schema; SupersededBy = $supersededBy; Frontmatter = $frontmatter }) | Out-Null
        }
    }

    foreach ($issue in @($issueRecords | Where-Object { $isActiveChange -and $_.Schema -eq 'openspec-material-issue-v2' -and $_.Status -eq 'superseded' })) {
        $ownReference = "$Change#$($issue.IssueId)"
        if ($issue.SupersededBy -eq $ownReference) {
            $structuralErrors.Add("$($issue.Path): superseded_by cannot reference itself") | Out-Null
            continue
        }
        if ($issue.SupersededBy -notmatch '^(?<change>[^#]+)#(?<issue>issue-.+)$') { continue }
        try {
            $targetChange = Resolve-HarnessEvolutionChange -Context $Context -Change $Matches['change']
            if ([bool]$targetChange.Archived) { throw 'target Change must be active' }
            $targetImplementationRoot = Join-Path ([string]$targetChange.Root) 'attachments/implementation'
            $targetFiles = @(
                if (Test-Path -LiteralPath $targetImplementationRoot -PathType Container) {
                    Get-ChildItem -LiteralPath $targetImplementationRoot -Recurse -File -Filter "$($Matches['issue']).md" | Sort-Object FullName
                }
            )
            if ($targetFiles.Count -ne 1) { throw "target issue file must exist exactly once (actual $($targetFiles.Count))" }
            $targetPath = $targetFiles[0].FullName
            $targetFrontmatter = Read-HarnessFrontmatter -Path $targetPath
            if ($targetFrontmatter.Errors.Count -gt 0 -or
                (Get-HarnessFrontmatterValue -Frontmatter $targetFrontmatter -Name 'issue_schema') -ne 'openspec-material-issue-v2' -or
                (Get-HarnessFrontmatterValue -Frontmatter $targetFrontmatter -Name 'issue_id') -ne $Matches['issue']) {
                throw 'target is not an exact v2 material issue'
            }
            $targetStatus = (Get-HarnessFrontmatterValue -Frontmatter $targetFrontmatter -Name 'status').ToLowerInvariant()
            if ($targetStatus -notin @('open', 'resolved', 'rejected')) { throw "target issue must be non-superseded with a valid status (actual '$targetStatus')" }
            $expectedSourceRef = "issue:$ownReference"
            if ((Get-HarnessFrontmatterValue -Frontmatter $targetFrontmatter -Name 'source_ref') -ne $expectedSourceRef) { throw "target source_ref must equal '$expectedSourceRef'" }
            $targetAttachmentRoot = Join-Path ([string]$targetChange.Root) 'attachments'
            $targetRelativePath = $targetPath.Substring($targetAttachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
            $targetIndexPath = Join-Path $targetAttachmentRoot 'INDEX.md'
            $targetIndexText = if (Test-Path -LiteralPath $targetIndexPath -PathType Leaf) { (Get-Content -LiteralPath $targetIndexPath -Raw).Replace('\', '/') } else { '' }
            $targetIndexCount = Get-HarnessAttachmentIndexCount -IndexText $targetIndexText -AttachmentRelativePath $targetRelativePath
            if ($targetIndexCount -ne 1) { throw "target issue must appear in its attachments/INDEX.md exactly once (actual $targetIndexCount)" }
            $targetTaskPlan = Invoke-HarnessEvolutionTaskPlan -Context $Context -Change $Matches['change']
            $targetTaskIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            foreach ($task in @($targetTaskPlan.tasks)) { [void]$targetTaskIds.Add([string]$task.id) }
            $targetAffectedTasks = @(Get-HarnessFrontmatterCollection -Frontmatter $targetFrontmatter -Name 'affected_tasks')
            if ($targetAffectedTasks.Count -eq 0) { throw 'target affected_tasks requires at least one TaskPlan ID' }
            foreach ($taskId in $targetAffectedTasks) {
                if (-not $targetTaskIds.Contains($taskId)) { throw "target affected_tasks references unknown TaskPlan ID '$taskId'" }
            }
            $targetSupersededBy = Get-HarnessFrontmatterValue -Frontmatter $targetFrontmatter -Name 'superseded_by'
            if ($targetSupersededBy -eq $ownReference) { throw 'direct supersession cycle detected' }
        }
        catch {
            $structuralErrors.Add("$($issue.Path): superseded_by '$($issue.SupersededBy)' is invalid ($($_.Exception.Message))") | Out-Null
        }
    }

    if (Test-Path -LiteralPath $reviewRoot -PathType Container) {
        foreach ($file in @(Get-ChildItem -LiteralPath $reviewRoot -Recurse -File -Filter 'review-*.md' | Sort-Object FullName)) {
            $relativePath = Get-HarnessWorkspaceRelativePath -WorkspaceRoot $Context.WorkspaceRoot -Path $file.FullName
            $attachmentRelativePath = $file.FullName.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
            $frontmatter = Read-HarnessFrontmatter -Path $file.FullName
            $schema = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'review_schema'
            $state = (Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'state').ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($schema)) {
                $legacyReviewCount++
                if ($isActiveChange) { $structuralErrors.Add("${relativePath}: active Review requires review_schema review-v2") | Out-Null }
                $reviewRecords.Add([pscustomobject]@{ Path = $relativePath; Schema = ''; State = $state }) | Out-Null
                continue
            }
            if (-not $isActiveChange) {
                $reviewRecords.Add([pscustomobject]@{ Path = $relativePath; Schema = $schema; State = $state }) | Out-Null
                continue
            }
            foreach ($problem in @($frontmatter.Errors)) { $structuralErrors.Add("${relativePath}: $problem") | Out-Null }
            if ($schema -ne 'review-v2') {
                $structuralErrors.Add("${relativePath}: unsupported review_schema '$schema'") | Out-Null
                $reviewRecords.Add([pscustomobject]@{ Path = $relativePath; Schema = $schema; State = $state }) | Out-Null
                continue
            }
            if ($file.BaseName -cnotmatch '^review-\d{8}-\d{6}-[a-z0-9][a-z0-9-]*$') { $structuralErrors.Add("${relativePath}: invalid Review filename") | Out-Null }
            $reviewKind = (Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'review_kind').ToLowerInvariant()
            if ($reviewKind -notin @('incident', 'final', 'external')) { $structuralErrors.Add("${relativePath}: invalid review_kind '$reviewKind'") | Out-Null }
            $requestedBy = (Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'requested_by').ToLowerInvariant()
            if ($requestedBy -notin @('user', 'external-agent')) { $structuralErrors.Add("${relativePath}: requested_by must be user or external-agent for an active Review") | Out-Null }
            if ($state -notin @('open', 'closed', 'superseded')) {
                $structuralErrors.Add("${relativePath}: invalid Review state '$state'") | Out-Null
            }
            else {
                $reviewCounts[(Get-Culture).TextInfo.ToTitleCase($state)]++
                if ($state -eq 'open') { $openReviewPaths.Add($relativePath) | Out-Null }
            }

            $assignedAt = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'assigned_at'
            $reviewedAt = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'reviewed_at'
            $closedAt = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'closed_at'
            $assignedInstant = ConvertTo-HarnessIsoInstant $assignedAt
            $reviewedInstant = ConvertTo-HarnessIsoInstant $reviewedAt
            $closedInstant = ConvertTo-HarnessIsoInstant $closedAt
            if ($null -eq $assignedInstant) { $structuralErrors.Add("${relativePath}: assigned_at must be an ISO-8601 timestamp") | Out-Null }
            if (-not [string]::IsNullOrWhiteSpace($reviewedAt) -and $null -eq $reviewedInstant) { $structuralErrors.Add("${relativePath}: reviewed_at must be an ISO-8601 timestamp when populated") | Out-Null }
            if (-not [string]::IsNullOrWhiteSpace($closedAt) -and $null -eq $closedInstant) { $structuralErrors.Add("${relativePath}: closed_at must be an ISO-8601 timestamp when populated") | Out-Null }
            if ($state -eq 'closed' -and $null -eq $reviewedInstant) { $structuralErrors.Add("${relativePath}: closed Review requires reviewed_at") | Out-Null }
            if ($state -in @('closed', 'superseded') -and $null -eq $closedInstant) { $structuralErrors.Add("${relativePath}: $state Review requires closed_at") | Out-Null }
            if ($state -eq 'open' -and -not [string]::IsNullOrWhiteSpace($closedAt)) { $structuralErrors.Add("${relativePath}: open Review forbids closed_at") | Out-Null }
            if ($null -ne $assignedInstant -and $null -ne $reviewedInstant -and $reviewedInstant -lt $assignedInstant) { $structuralErrors.Add("${relativePath}: reviewed_at must not precede assigned_at") | Out-Null }
            if ($null -ne $assignedInstant -and $null -ne $closedInstant -and $closedInstant -lt $assignedInstant) { $structuralErrors.Add("${relativePath}: closed_at must not precede assigned_at") | Out-Null }
            if ($null -ne $reviewedInstant -and $null -ne $closedInstant -and $closedInstant -lt $reviewedInstant) { $structuralErrors.Add("${relativePath}: closed_at must not precede reviewed_at") | Out-Null }
            if ($state -in @('closed', 'superseded') -and $null -ne $closedInstant) { $terminalEvidenceInstants.Add($closedInstant) | Out-Null }

            $snapshotRef = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'snapshot_ref'
            if ([string]::IsNullOrWhiteSpace($snapshotRef) -or $snapshotRef -match '(?i)^(?:live|current|dirty|working[-_ ]?tree|live[-_ ]?worktree)$') { $structuralErrors.Add("${relativePath}: snapshot_ref must identify immutable content") | Out-Null }
            $snapshotSha256 = Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'snapshot_sha256'
            if ($snapshotSha256 -cnotmatch '^[a-f0-9]{64}$') { $structuralErrors.Add("${relativePath}: snapshot_sha256 must be a lowercase SHA-256") | Out-Null }
            $verdict = (Get-HarnessFrontmatterValue -Frontmatter $frontmatter -Name 'verdict').ToUpperInvariant()
            if ($verdict -notin @('PENDING', 'APPROVE', 'CHANGES_REQUIRED')) { $structuralErrors.Add("${relativePath}: invalid Review verdict '$verdict'") | Out-Null }
            if ($state -eq 'closed' -and $verdict -ne 'APPROVE') { $structuralErrors.Add("${relativePath}: closed Review requires verdict APPROVE") | Out-Null }

            $indexCount = Get-HarnessAttachmentIndexCount -IndexText $indexText -AttachmentRelativePath $attachmentRelativePath
            if ($indexCount -ne 1) { $structuralErrors.Add("${relativePath}: must appear in attachments/INDEX.md exactly once (actual $indexCount)") | Out-Null }
            try {
                foreach ($finding in @(Get-HarnessReviewFindingRecords -Path $file.FullName)) {
                    if ([string]::IsNullOrWhiteSpace($finding.Severity) -or [string]::IsNullOrWhiteSpace($finding.Status)) {
                        $structuralErrors.Add("${relativePath}: $($finding.Heading) requires valid severity and status") | Out-Null
                    }
                    elseif ($finding.Severity -in @('Critical', 'Required') -and $finding.Status -in @('open', 'deferred')) {
                        $structuralErrors.Add("${relativePath}: $($finding.Severity) finding remains $($finding.Status)") | Out-Null
                    }
                }
            }
            catch {
                $structuralErrors.Add("${relativePath}: Review finding validation failed ($($_.Exception.Message))") | Out-Null
            }
            $reviewRecords.Add([pscustomobject]@{ Path = $relativePath; Schema = $schema; State = $state }) | Out-Null
        }
    }

    $evaluationPath = Join-Path $attachmentRoot 'data/workflow-evaluation.md'
    $evaluationRelativePath = ''
    $evaluationResult = ''
    $evaluationCapturedAt = ''
    $evaluationClosureKind = ''
    $evaluationInputSha256 = ''
    $evaluationFresh = $false
    $evaluationValid = $false
    $evaluationCapturedInstant = $null
    $latestTerminalEvidenceInstant = @($terminalEvidenceInstants | Sort-Object -Descending | Select-Object -First 1)
    if (Test-Path -LiteralPath $evaluationPath -PathType Leaf) {
        $evaluationRelativePath = Get-HarnessWorkspaceRelativePath -WorkspaceRoot $Context.WorkspaceRoot -Path $evaluationPath
        $evaluation = Read-HarnessFrontmatter -Path $evaluationPath
        foreach ($problem in @($evaluation.Errors)) { $structuralErrors.Add("${evaluationRelativePath}: $problem") | Out-Null }
        $evaluationRecord = Get-HarnessFrontmatterValue -Frontmatter $evaluation -Name 'record'
        $evaluationResult = (Get-HarnessFrontmatterValue -Frontmatter $evaluation -Name 'result').ToLowerInvariant()
        $evaluationChange = Get-HarnessFrontmatterValue -Frontmatter $evaluation -Name 'change'
        $evaluationCapturedAt = Get-HarnessFrontmatterValue -Frontmatter $evaluation -Name 'captured_at'
        $evaluationCapturedInstant = ConvertTo-HarnessIsoInstant $evaluationCapturedAt
        $evaluationClosureKind = (Get-HarnessFrontmatterValue -Frontmatter $evaluation -Name 'closure_kind').ToLowerInvariant()
        $evaluationInputSha256 = Get-HarnessFrontmatterValue -Frontmatter $evaluation -Name 'input_sha256'
        $recognizedEvaluationRecord = $evaluationRecord -eq 'harness-workflow-evaluation-v1' -or ([bool]$resolvedChange.Archived -and $evaluationRecord -eq 'hardness-workflow-evaluation-v1')
        if (-not $recognizedEvaluationRecord) { $structuralErrors.Add("${evaluationRelativePath}: record must be harness-workflow-evaluation-v1 (immutable archives may retain hardness-workflow-evaluation-v1)") | Out-Null }
        if ($evaluationResult -notin @('passed', 'failed')) { $structuralErrors.Add("${evaluationRelativePath}: result must be passed or failed") | Out-Null }
        if ($evaluationChange -ne $Change) { $structuralErrors.Add("${evaluationRelativePath}: change must equal '$Change'") | Out-Null }
        if (-not (Test-HarnessIsoTimestamp $evaluationCapturedAt)) { $structuralErrors.Add("${evaluationRelativePath}: captured_at must be an ISO-8601 timestamp") | Out-Null }
        if (-not [bool]$resolvedChange.Archived) {
            if ($evaluationClosureKind -notin @('completed', 'abandoned', 'superseded')) { $structuralErrors.Add("${evaluationRelativePath}: closure_kind must be completed, abandoned, or superseded") | Out-Null }
            if ($evaluationInputSha256 -cnotmatch '^[a-f0-9]{64}$') { $structuralErrors.Add("${evaluationRelativePath}: input_sha256 must be a lowercase SHA-256") | Out-Null }
            $evaluationFresh = -not [string]::IsNullOrWhiteSpace($currentInputSha256) -and $evaluationInputSha256 -eq $currentInputSha256
        }
        if ([string]::IsNullOrWhiteSpace($indexText)) {
            $structuralErrors.Add("${evaluationRelativePath}: attachments/INDEX.md is required") | Out-Null
        }
        else {
            $evaluationIndexPath = $evaluationPath.Substring($attachmentRoot.Length).TrimStart('\', '/').Replace('\', '/')
            $evaluationIndexCount = Get-HarnessAttachmentIndexCount -IndexText $indexText -AttachmentRelativePath $evaluationIndexPath
            if ($evaluationIndexCount -ne 1) { $structuralErrors.Add("${evaluationRelativePath}: must appear in attachments/INDEX.md exactly once (actual $evaluationIndexCount)") | Out-Null }
        }
        $evaluationValid = $evaluation.Errors.Count -eq 0 -and $recognizedEvaluationRecord -and $evaluationResult -in @('passed', 'failed') -and $evaluationChange -eq $Change -and (Test-HarnessIsoTimestamp $evaluationCapturedAt)
        if (-not [bool]$resolvedChange.Archived) {
            $evaluationValid = $evaluationValid -and $evaluationClosureKind -in @('completed', 'abandoned', 'superseded') -and $evaluationInputSha256 -cmatch '^[a-f0-9]{64}$'
        }
    }

    foreach ($problem in @($structuralErrors)) { $closureBlockers.Add([string]$problem) | Out-Null }
    foreach ($path in @($openIssuePaths)) { $closureBlockers.Add("open material issue: $path") | Out-Null }
    foreach ($path in @($openReviewPaths)) { $closureBlockers.Add("open Review: $path") | Out-Null }
    if (-not (Test-Path -LiteralPath $evaluationPath -PathType Leaf)) { $closureBlockers.Add('workflow evaluation is missing') | Out-Null }
    elseif (-not $evaluationValid) { $closureBlockers.Add('workflow evaluation frontmatter is invalid') | Out-Null }
    elseif ($evaluationResult -ne 'passed') { $closureBlockers.Add("workflow evaluation result is '$evaluationResult'") | Out-Null }
    if (-not [bool]$resolvedChange.Archived) {
        if (-not $taskPlanValid) { $closureBlockers.Add('TaskPlan is invalid') | Out-Null }
        elseif ($taskCount -eq 0) { $closureBlockers.Add('TaskPlan is empty') | Out-Null }
        elseif ($ClosureKind -eq 'completed' -and $incompleteTaskIds.Count -gt 0) { $closureBlockers.Add("incomplete task(s): $($incompleteTaskIds -join ', ')") | Out-Null }
        if ($evaluationValid -and $evaluationClosureKind -ne $ClosureKind) { $closureBlockers.Add("workflow evaluation closure_kind '$evaluationClosureKind' does not match requested '$ClosureKind'") | Out-Null }
        if ($evaluationValid -and -not $evaluationFresh) { $closureBlockers.Add('workflow evaluation is stale because input_sha256 does not match the current Change digest') | Out-Null }
        if ($evaluationValid -and $latestTerminalEvidenceInstant.Count -eq 1 -and $null -ne $evaluationCapturedInstant -and $evaluationCapturedInstant -lt $latestTerminalEvidenceInstant[0]) {
            $closureBlockers.Add("workflow evaluation captured_at precedes latest terminal evidence at $($latestTerminalEvidenceInstant[0].ToString('o'))") | Out-Null
        }
    }

    $result = [pscustomobject][ordered]@{
        ChangeId                  = $Change
        ChangeRoot                = $changeRoot
        Archived                  = [bool]$resolvedChange.Archived
        ClosureKind               = $ClosureKind
        TaskPlanValid             = $taskPlanValid
        TaskCount                 = $taskCount
        IncompleteTaskIds         = @($incompleteTaskIds)
        CurrentInputSha256        = $currentInputSha256
        ObservationRoot           = $observationRoot
        LegacyObservationRoot     = $legacyObservationRoot
        ObservationCount          = $observations.Count
        LatestObservationUtc      = if ($observations.Count -gt 0) { $observations[0].LastWriteTimeUtc.ToString('o') } else { '' }
        V2IssueCount              = @($issueRecords | Where-Object Schema -eq 'openspec-material-issue-v2').Count
        LegacyIssueCount          = $legacyIssueCount
        IssueCounts               = [pscustomobject]$counts
        OpenIssuePaths            = @($openIssuePaths | ForEach-Object { [string]$_ })
        V2ReviewCount             = @($reviewRecords | Where-Object Schema -eq 'review-v2').Count
        LegacyReviewCount         = $legacyReviewCount
        ReviewCounts              = [pscustomobject]$reviewCounts
        OpenReviewPaths           = @($openReviewPaths | ForEach-Object { [string]$_ })
        StructuralErrors          = @($structuralErrors | ForEach-Object { [string]$_ })
        LatestTerminalEvidenceAt  = if ($latestTerminalEvidenceInstant.Count -eq 1) { $latestTerminalEvidenceInstant[0].ToString('o') } else { '' }
        LatestEvaluationPath      = $evaluationRelativePath
        LatestEvaluationResult    = $evaluationResult
        LatestEvaluationCapturedAt = $evaluationCapturedAt
        EvaluationClosureKind     = $evaluationClosureKind
        EvaluationInputSha256     = $evaluationInputSha256
        EvaluationFresh           = $evaluationFresh
        ClosureReady              = $closureBlockers.Count -eq 0
        ClosureBlockers           = @($closureBlockers | ForEach-Object { [string]$_ })
        RawBodiesLoaded           = $false
    }
    if ($RequireTerminal -and -not $result.ClosureReady) {
        throw "Evolution closure gate failed for '$Change': $($result.ClosureBlockers -join '; ')"
    }
    return $result
}

function Get-HarnessOpenSpecMaintenanceStatus {
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

    $recorded = Invoke-HarnessGit -Repository $root -Arguments @('rev-parse', 'HEAD:Tools/openspec') -AllowFailure
    if ($recorded.ExitCode -eq 0) { $recordedCommit = ([string]($recorded.Output | Select-Object -Last 1)).Trim().ToLowerInvariant() }
    else { $reasons.Add('The parent commit does not record a Tools/openspec gitlink.') | Out-Null }

    if (Test-Path -LiteralPath $sourcePath -PathType Container) {
        $head = Invoke-HarnessGit -Repository $sourcePath -Arguments @('rev-parse', 'HEAD') -AllowFailure
        if ($head.ExitCode -eq 0) {
            $workingHead = ([string]($head.Output | Select-Object -Last 1)).Trim().ToLowerInvariant()
            $sourceStatus = Invoke-HarnessGit -Repository $sourcePath -Arguments @('status', '--porcelain=v1') -AllowFailure
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

function Get-HarnessPackageSafetyModule {
    if ($null -ne $script:HarnessPackageSafetyModule) {
        return $script:HarnessPackageSafetyModule
    }
    $modulePath = Join-Path $script:HarnessRoot '.agents\skills\openspec\scripts\OpenSpecPackageSafety.psm1'
    if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
        throw "Trusted OpenSpec package-safety verifier is missing: $modulePath"
    }
    $script:HarnessPackageSafetyModule = Import-Module -Name $modulePath -Force -PassThru -ErrorAction Stop
    return $script:HarnessPackageSafetyModule
}

function ConvertTo-HarnessManifestInteger {
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

function Assert-HarnessOpenSpecManifestSchema {
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
    $binarySize = ConvertTo-HarnessManifestInteger -Value $Metadata.binarySize -Field 'binarySize'
    $docCount = ConvertTo-HarnessManifestInteger -Value $Metadata.commandDocCount -Field 'commandDocCount'
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
        $gateExitCode = ConvertTo-HarnessManifestInteger -Value $gate.exitCode -Field "releaseGates[$index].exitCode"
        if ([string]$gate.command -ne $expectedGateCommands[$index] -or [string]$gate.status -ne 'passed' -or $gateExitCode -ne 0) {
            throw "OpenSpec release-manifest gate $index does not describe the required successful command."
        }
    }
    if ([string]$gates[-1].sha256 -ne $script:HarnessOpenSpecIdentity.Sha256) {
        throw 'OpenSpec release-manifest reproducibility gate does not bind the final executable identity.'
    }
}

function Assert-HarnessOpenSpecFinalIdentity {
    param([Parameter(Mandatory = $true)]$Metadata)

    $expected = $script:HarnessOpenSpecIdentity
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

function Get-HarnessCommandDocsDigest {
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

function Assert-HarnessOpenSpecPackage {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $safetyModule = Get-HarnessPackageSafetyModule
    $assertExisting = $safetyModule.ExportedCommands['Assert-OpenSpecSafeExistingPath']
    $assertContained = $safetyModule.ExportedCommands['Assert-OpenSpecSafeContainedPath']
    $assertTree = $safetyModule.ExportedCommands['Assert-OpenSpecSafeTree']
    if ($null -eq $assertExisting -or $null -eq $assertContained -or $null -eq $assertTree) {
        throw 'Trusted OpenSpec package-safety verifier does not expose its bounded path checks.'
    }

    $root = & $assertExisting -Path $ProjectRoot -Description 'Harness installation root' -Container
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
    Assert-HarnessOpenSpecManifestSchema -Metadata $metadata
    Assert-HarnessOpenSpecFinalIdentity -Metadata $metadata

    $executableInfo = Get-Item -LiteralPath $executablePath -Force
    if ($executableInfo.Length -ne [long]$script:HarnessOpenSpecIdentity.BinarySize) {
        throw "OpenSpec executable size identity mismatch: expected $($script:HarnessOpenSpecIdentity.BinarySize), found $($executableInfo.Length)."
    }
    $actualHash = (Get-FileHash -LiteralPath $executablePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne [string]$script:HarnessOpenSpecIdentity.Sha256 -or $actualHash -ne [string]$metadata.sha256) {
        throw "OpenSpec executable hash identity mismatch: $actualHash"
    }

    $allDocsFiles = @(Get-ChildItem -LiteralPath $docsRoot -Recurse -File | Sort-Object FullName)
    $docsFiles = @($allDocsFiles | Where-Object { $_.Extension -eq '.md' })
    if ($docsFiles.Count -ne [int]$script:HarnessOpenSpecIdentity.CommandDocCount) {
        throw "OpenSpec command-doc set mismatch: expected $($script:HarnessOpenSpecIdentity.CommandDocCount) Markdown files, found $($docsFiles.Count)."
    }
    if ($allDocsFiles.Count -ne $docsFiles.Count) {
        throw "OpenSpec command-doc set contains $($allDocsFiles.Count - $docsFiles.Count) unexpected non-Markdown files."
    }
    $totalDocsBytes = [long]0
    foreach ($file in $docsFiles) { $totalDocsBytes += $file.Length }
    if ($totalDocsBytes -gt 8388608) {
        throw "OpenSpec command docs exceed the 8 MiB verifier bound: $totalDocsBytes bytes."
    }
    $actualDocsDigest = Get-HarnessCommandDocsDigest -DocsRoot $docsRoot -Files $docsFiles
    if ($actualDocsDigest -ne [string]$script:HarnessOpenSpecIdentity.CommandDocsDigest -or $actualDocsDigest -ne [string]$metadata.commandDocsDigest) {
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
    if ($versionExitCode -ne 0 -or $versionText -ne "openspec $($script:HarnessOpenSpecIdentity.Version)") {
        throw "Verified OpenSpec package executable reports '$versionText' (exit $versionExitCode), expected 'openspec $($script:HarnessOpenSpecIdentity.Version)'."
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

function Test-HarnessInstallation {
    [CmdletBinding()]
    param([string]$ProjectRoot = '')

    $root = Resolve-HarnessProjectRoot -ProjectRoot $ProjectRoot
    Initialize-HarnessRoutes
    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $openSpecPackage = [pscustomobject]@{
        Verified          = $false
        Version           = [string]$script:HarnessOpenSpecIdentity.Version
        SourceCommit      = [string]$script:HarnessOpenSpecIdentity.SourceCommit
        SourceTag         = [string]$script:HarnessOpenSpecIdentity.SourceTag
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
    $unrealManifest = Join-Path $root '.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1'
    if (-not (Test-Path -LiteralPath $unrealManifest -PathType Leaf)) {
        $errors.Add("Missing Unreal module manifest: $unrealManifest") | Out-Null
    }
    else {
        try { Test-ModuleManifest -Path $unrealManifest -ErrorAction Stop | Out-Null } catch { $errors.Add($_.Exception.Message) | Out-Null }
    }
    try {
        $openSpecPackage = Assert-HarnessOpenSpecPackage -ProjectRoot $root
    }
    catch {
        $errors.Add("OpenSpec package verification failed: $($_.Exception.Message)") | Out-Null
    }
    $duplicateNames = @($script:HarnessRoutes | Group-Object Name | Where-Object Count -gt 1)
    if ($duplicateNames.Count -gt 0) {
        $errors.Add("Duplicate route names: $($duplicateNames.Name -join ', ')") | Out-Null
    }
    foreach ($invalidChangeId in @(Get-HarnessInvalidActiveChangeIds -ProjectRoot $root)) {
        $errors.Add("Active Change identity '$invalidChangeId' must follow $script:HarnessChangeNameContract.") | Out-Null
    }
    return [pscustomobject]@{
        IsValid  = $errors.Count -eq 0
        Root     = $root
        Routes   = $script:HarnessRoutes.Count
        OpenSpecPackage = $openSpecPackage
        Errors   = @($errors | ForEach-Object { $_ })
        Warnings = @($warnings | ForEach-Object { $_ })
    }
}

Export-ModuleMember -Function @(
    'New-HarnessContext',
    'Get-HarnessCommand',
    'Invoke-Harness',
    'Test-HarnessInstallation'
)
