Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:HardnessSchemaVersion = '1.0'
$script:HardnessProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
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

    $workspaceModule = '.agents/skills/git-workflow/scripts/Workspace.psd1'
    $openspecExecutable = '.agents/skills/openspec/bin/openspec.exe'
    $routes = New-Object System.Collections.Generic.List[object]

    $routes.Add((New-HardnessRoute 'workspace.status' 'PowerShell' $workspaceModule 'Get-HardnessWorkspaceStatus' @() @{} 'Inspect workspace and submodule state.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.new' 'PowerShell' $workspaceModule 'New-HardnessWorkspace' @() @{} 'Create and bootstrap an isolated goal worktree.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.bootstrap' 'PowerShell' $workspaceModule 'Initialize-HardnessWorkspace' @() @{} 'Bootstrap an existing worktree safely.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.verify' 'PowerShell' $workspaceModule 'Test-HardnessWorkspace' @() @{} 'Verify exact gitlinks and local configuration safety.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.finish' 'PowerShell' $workspaceModule 'Complete-HardnessWorkspace' @() @{} 'Commit submodules first, then parent changes.')) | Out-Null
    $routes.Add((New-HardnessRoute 'workspace.remove' 'PowerShell' $workspaceModule 'Remove-HardnessWorkspace' @() @{} 'Explicitly remove a clean registered worktree or recover its empty residual root.')) | Out-Null

    foreach ($command in @('init', 'doctor', 'status', 'instructions', 'validate', 'domain', 'spec', 'change', 'workflow', 'completion')) {
        $routes.Add((New-HardnessRoute "openspec.$command" 'Native' $openspecExecutable '' @($command) @{} "Run openspec $command.")) | Out-Null
    }
    $routes.Add((New-HardnessRoute -Name 'task.status' -Kind 'Native' -Target $openspecExecutable -Prefix @('instructions', 'apply', '--json') -Description 'Inspect the selected Task Graph through the OpenSpec parser.' -OutputFormat 'TaskPlanJson')) | Out-Null

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
    $candidate = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $script:HardnessProjectRoot } else { $ProjectRoot }
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
        [string]$Purpose = 'Goal workspace routing'
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

function Get-HardnessRepositoryAuthority {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $requestedRoot = Resolve-HardnessProjectRoot -ProjectRoot $ProjectRoot
    $topLevelResult = Invoke-HardnessGit -Repository $requestedRoot -Arguments @('rev-parse', '--show-toplevel')
    $checkoutRoot = [System.IO.Path]::GetFullPath(([string]($topLevelResult.Output | Select-Object -Last 1)).Trim())
    $worktreeResult = Invoke-HardnessGit -Repository $checkoutRoot -Arguments @('worktree', 'list', '--porcelain')
    $registered = New-Object System.Collections.Generic.List[string]
    foreach ($line in @($worktreeResult.Output)) {
        if ($line -like 'worktree *') {
            $registered.Add([System.IO.Path]::GetFullPath($line.Substring(9).Trim())) | Out-Null
        }
    }
    if ($registered.Count -eq 0) {
        throw "Git did not report a canonical primary worktree for '$checkoutRoot'."
    }
    $primaryRoot = [string]$registered[0]
    if (-not (@($registered | Where-Object { Test-HardnessPathEqual -Left $_ -Right $checkoutRoot }).Count -eq 1)) {
        throw "The requested checkout is not a registered worktree: $checkoutRoot"
    }
    return [pscustomobject]@{
        CheckoutRoot    = $checkoutRoot
        PrimaryRoot     = $primaryRoot
        WorkspaceRoot   = [System.IO.Path]::GetFullPath((Join-Path $primaryRoot '.worktrees'))
        RegisteredRoots = @($registered | ForEach-Object { $_ })
    }
}

function Assert-HardnessGoalName {
    param([Parameter(Mandatory = $true)][string]$GoalName)

    if ([string]::IsNullOrWhiteSpace($GoalName) -or
        $GoalName -notmatch '^[A-Za-z0-9._-]{1,80}$' -or
        $GoalName -eq '.' -or
        $GoalName -eq '..') {
        throw "Invalid GoalName '$GoalName': use 1-80 letters, digits, dots, underscores, or hyphens without traversal or path separators."
    }
    return $GoalName
}

function Resolve-HardnessGoalSelection {
    param(
        [Parameter(Mandatory = $true)]$Authority,
        [string]$GoalName,
        [string]$WorkspaceRoot
    )

    $hasName = -not [string]::IsNullOrWhiteSpace($GoalName)
    $hasRoot = -not [string]::IsNullOrWhiteSpace($WorkspaceRoot)
    if (-not $hasName -and -not $hasRoot) {
        throw 'Goal mode requires -GoalName or -WorkspaceRoot so the isolated workspace is explicit.'
    }

    $explicitRoot = if ($hasRoot) {
        try { [System.IO.Path]::GetFullPath($WorkspaceRoot) }
        catch { throw "Goal WorkspaceRoot is not a valid file-system path: $WorkspaceRoot" }
    }
    else { '' }
    $selectedName = if ($hasName) { Assert-HardnessGoalName -GoalName $GoalName } else { Split-Path -Leaf $explicitRoot.TrimEnd('\', '/') }
    [void](Assert-HardnessGoalName -GoalName $selectedName)
    $canonicalRoot = [System.IO.Path]::GetFullPath((Join-Path $Authority.WorkspaceRoot $selectedName))
    if (-not (Test-HardnessPathEqual -Left (Split-Path -Parent $canonicalRoot) -Right $Authority.WorkspaceRoot)) {
        throw "Goal workspace must be a direct child of the canonical '$($Authority.WorkspaceRoot)' directory."
    }
    if ($hasRoot -and -not (Test-HardnessPathEqual -Left $explicitRoot -Right $canonicalRoot)) {
        throw "Explicit Goal WorkspaceRoot '$explicitRoot' does not match canonical workspace '$canonicalRoot'."
    }
    [void](Assert-HardnessPathChainSafe -Root $Authority.PrimaryRoot -Target $canonicalRoot -Purpose 'Goal workspace routing')
    return [pscustomobject]@{ GoalName = $selectedName; WorkspaceRoot = $canonicalRoot }
}

function Assert-HardnessGoalRouteAuthority {
    param(
        [Parameter(Mandatory = $true)]$Context,
        [switch]$AllowCreateCandidate,
        [switch]$AllowEmptyUnregisteredRemoval
    )

    $authorityRoot = if ($AllowEmptyUnregisteredRemoval -and
        'PrimaryRoot' -in @($Context.PSObject.Properties.Name) -and
        -not [string]::IsNullOrWhiteSpace([string]$Context.PrimaryRoot)) {
        [string]$Context.PrimaryRoot
    }
    else {
        [string]$Context.ProjectRoot
    }
    $authority = Get-HardnessRepositoryAuthority -ProjectRoot $authorityRoot
    $selection = Resolve-HardnessGoalSelection -Authority $authority -GoalName ([string]$Context.GoalName) -WorkspaceRoot ([string]$Context.WorkspaceRoot)
    if ($AllowCreateCandidate) {
        return $selection.WorkspaceRoot
    }
    if (-not [System.IO.Directory]::Exists($selection.WorkspaceRoot)) {
        throw "Goal workspace is not an existing registered worktree: $($selection.WorkspaceRoot)"
    }
    [void](Assert-HardnessPathChainSafe -Root $authority.PrimaryRoot -Target $selection.WorkspaceRoot -Purpose 'Goal route execution')
    $isRegistered = @($authority.RegisteredRoots | Where-Object { Test-HardnessPathEqual -Left $_ -Right $selection.WorkspaceRoot }).Count -eq 1
    if (-not $isRegistered) {
        if ($AllowEmptyUnregisteredRemoval) {
            $targetItem = Get-Item -LiteralPath $selection.WorkspaceRoot -Force -ErrorAction Stop
            $remainingEntries = @(Get-ChildItem -LiteralPath $selection.WorkspaceRoot -Force -ErrorAction Stop)
            if ($targetItem.PSIsContainer -and $remainingEntries.Count -eq 0) {
                return $selection.WorkspaceRoot
            }
        }
        throw "Goal workspace is not a registered worktree: $($selection.WorkspaceRoot)"
    }
    $workspaceTop = Invoke-HardnessGit -Repository $selection.WorkspaceRoot -Arguments @('rev-parse', '--show-toplevel')
    $resolvedTop = [System.IO.Path]::GetFullPath(([string]($workspaceTop.Output | Select-Object -Last 1)).Trim())
    if (-not (Test-HardnessPathEqual -Left $resolvedTop -Right $selection.WorkspaceRoot)) {
        throw "Goal workspace does not resolve to its registered worktree root: $($selection.WorkspaceRoot)"
    }
    return $selection.WorkspaceRoot
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
        [ValidateSet('Goal', 'Current')][string]$Mode = 'Goal',
        [string]$ProjectRoot = '',
        [string]$GoalName = '',
        [string]$WorkspaceRoot = ''
    )

    $root = Resolve-HardnessProjectRoot -ProjectRoot $ProjectRoot
    $primaryRoot = $root
    $workspaceContainer = ''
    $resolvedGoalName = $GoalName
    $resolvedWorkspace = $root
    if ($Mode -eq 'Goal') {
        $authority = Get-HardnessRepositoryAuthority -ProjectRoot $root
        $selection = Resolve-HardnessGoalSelection -Authority $authority -GoalName $GoalName -WorkspaceRoot $WorkspaceRoot
        $root = $authority.CheckoutRoot
        $primaryRoot = $authority.PrimaryRoot
        $workspaceContainer = $authority.WorkspaceRoot
        $resolvedGoalName = $selection.GoalName
        $resolvedWorkspace = $selection.WorkspaceRoot
    }
    return [pscustomobject]@{
        PSTypeName    = 'AngelscriptProject.HardnessContext'
        Mode          = $Mode
        ProjectRoot   = $root
        PrimaryRoot   = $primaryRoot
        WorkspaceContainer = $workspaceContainer
        GoalName      = $resolvedGoalName
        WorkspaceRoot = [System.IO.Path]::GetFullPath($resolvedWorkspace)
        CreatedAt     = [DateTimeOffset]::UtcNow
    }
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
        'workspace.status'   { if (-not $values.ContainsKey('ProjectRoot')) { $values.ProjectRoot = $Context.WorkspaceRoot } }
        'workspace.new'      {
            if (-not $values.ContainsKey('RepositoryRoot')) { $values.RepositoryRoot = $Context.ProjectRoot }
            if (-not $values.ContainsKey('Name') -and -not [string]::IsNullOrWhiteSpace($Context.GoalName)) { $values.Name = $Context.GoalName }
        }
        'workspace.bootstrap' { if (-not $values.ContainsKey('ProjectRoot')) { $values.ProjectRoot = $Context.WorkspaceRoot } }
        'workspace.verify'   { if (-not $values.ContainsKey('ProjectRoot')) { $values.ProjectRoot = $Context.WorkspaceRoot } }
        'workspace.finish'   { if (-not $values.ContainsKey('ProjectRoot')) { $values.ProjectRoot = $Context.WorkspaceRoot } }
        'workspace.remove'   {
            if ([string]$Context.Mode -eq 'Goal') {
                if ($values.ContainsKey('RepositoryRoot') -and
                    ([string]::IsNullOrWhiteSpace([string]$values.RepositoryRoot) -or
                    -not (Test-HardnessPathEqual -Left ([string]$values.RepositoryRoot) -Right ([string]$Context.PrimaryRoot)))) {
                    throw 'Goal workspace.remove RepositoryRoot must match the context PrimaryRoot.'
                }
                if ($values.ContainsKey('WorktreeRoot') -and
                    ([string]::IsNullOrWhiteSpace([string]$values.WorktreeRoot) -or
                    -not (Test-HardnessPathEqual -Left ([string]$values.WorktreeRoot) -Right ([string]$Context.WorkspaceRoot)))) {
                    throw 'Goal workspace.remove WorktreeRoot must match the context WorkspaceRoot.'
                }
                $values.RepositoryRoot = $Context.PrimaryRoot
                $values.WorktreeRoot = $Context.WorkspaceRoot
            }
            else {
                if (-not $values.ContainsKey('RepositoryRoot')) { $values.RepositoryRoot = $Context.ProjectRoot }
                if (-not $values.ContainsKey('WorktreeRoot')) { $values.WorktreeRoot = $Context.WorkspaceRoot }
            }
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
            $Context = New-HardnessContext -Mode Current
        }
        $route = Get-HardnessCommand -Name $Command
        if ($null -eq $route) {
            throw "Unknown Hardness command '$Command'. Use Get-HardnessCommand to list routes."
        }
        $allowEmptyUnregisteredRemoval = $false
        if ($route.Name -eq 'workspace.remove' -and $null -ne $Parameters -and $Parameters.ContainsKey('DiscardIgnoredFiles')) {
            $discardValue = $Parameters['DiscardIgnoredFiles']
            $allowEmptyUnregisteredRemoval = ($discardValue -is [bool] -and $discardValue)
        }
        if ([string]$Context.Mode -eq 'Goal') {
            [void](Assert-HardnessGoalRouteAuthority -Context $Context -AllowCreateCandidate:($route.Name -eq 'workspace.new') -AllowEmptyUnregisteredRemoval:$allowEmptyUnregisteredRemoval)
        }
        $routeRoot = if ($Context.Mode -eq 'Goal') {
            if ($route.Name -eq 'workspace.new') {
                $Context.ProjectRoot
            }
            elseif ($route.Name -eq 'workspace.remove') {
                $Context.PrimaryRoot
            }
            else {
                $Context.WorkspaceRoot
            }
        }
        else {
            $Context.ProjectRoot
        }
        $target = Join-Path $routeRoot $route.Target
        $data = $null
        $exitCode = 0
        if ($route.Kind -eq 'PowerShell') {
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
                Push-Location -LiteralPath $routeRoot
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

function Get-HardnessPackageSafetyModule {
    if ($null -ne $script:HardnessPackageSafetyModule) {
        return $script:HardnessPackageSafetyModule
    }
    $modulePath = Join-Path $script:HardnessProjectRoot '.agents\skills\openspec\scripts\OpenSpecPackageSafety.psm1'
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
    $workspaceManifest = Join-Path $root '.agents/skills/git-workflow/scripts/Workspace.psd1'
    if (-not (Test-Path -LiteralPath $workspaceManifest -PathType Leaf)) {
        $errors.Add("Missing workspace module: $workspaceManifest") | Out-Null
    }
    else {
        try { Test-ModuleManifest -Path $workspaceManifest -ErrorAction Stop | Out-Null } catch { $errors.Add($_.Exception.Message) | Out-Null }
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
