# Replica support shares the existing configuration and Git primitives.
function Find-WorkspaceReplicaRoot {
    param([string]$Path)
    $cursor = Get-Item -LiteralPath $Path -ErrorAction Stop
    if (-not $cursor.PSIsContainer) { $cursor = $cursor.Directory }
    while ($null -ne $cursor) {
        if (Test-Path -LiteralPath (Join-Path $cursor.FullName '.harness/workspace.json')) { return $cursor.FullName }
        if ($cursor.Name -eq '.workspaces') { throw 'Unregistered project replica; workspace identity file is missing.' }
        $cursor = $cursor.Parent
    }
    return ''
}

function Invoke-WorkspaceFiles {
    param([string[]]$Arguments)
    $output = @(& python -X utf8 (Join-Path $PSScriptRoot 'workspace_files.py') @Arguments 2>&1)
    if ($LASTEXITCODE) { throw "Workspace operation failed: $($output -join "`n")" }
    return ($output -join "`n") | ConvertFrom-Json
}

function Get-WorkspaceReplicaDescriptor {
    param([string]$Root)
    [void](Assert-WorkspaceExistingPathSafe -Target $Root -Purpose 'replica identity')
    $data = Get-Content -LiteralPath (Join-Path $Root '.harness/workspace.json') -Raw | ConvertFrom-Json
    if ($data.schemaVersion -ne 1 -or -not (Test-WorkspacePathEqual $data.WorkspaceRoot $Root) -or $data.WorkspaceId -notmatch '^workspace_[a-f0-9]{32}$') {
        throw 'Replica workspace identity mismatch.'
    }
    $recordPath = Join-Path $data.PrimaryRoot "Saved/Harness/Workspaces/$($data.WorkspaceId).json"
    [void](Assert-WorkspacePathChainSafe -Root $data.PrimaryRoot -Target $recordPath -Purpose 'replica registration')
    if (-not (Test-Path -LiteralPath $recordPath)) { throw 'Replica workspace registration missing.' }
    $record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
    if ($record.WorkspaceId -ne $data.WorkspaceId -or -not (Test-WorkspacePathEqual $record.WorkspaceRoot $Root)) { throw 'Replica workspace registration mismatch.' }
    return $data
}

function Get-WorkspaceReplicaIdentity {
    param([string]$Root)
    $data = Get-WorkspaceReplicaDescriptor $Root
    $identity = [pscustomobject]@{
        SchemaVersion = '3'; HarnessRoot = Get-WorkspaceRepositoryRootFromModule
        WorkspaceRoot = $Root; PrimaryRoot = $data.PrimaryRoot; OpenSpecRoot = $data.PrimaryRoot
        WorkspaceId = $data.WorkspaceId; Topology = 'Replica'; WorktreeName = Split-Path $Root -Leaf
        # This identifies the control repository, never a Git repository at the replica root.
        GitCommonDir = Get-WorkspaceCommonGitDirectory $data.PrimaryRoot
        Branch = ''; Head = ''; Managed = $false; Repositories = $data.Repositories
    }
    $identity.Managed = Test-WorkspaceManagedIdentity -Path (Join-Path $Root 'AgentConfig.ini') -Identity $identity
    return $identity
}

function New-WorkspaceReplica {
    param([string]$RepositoryRoot, [string]$Name, [string]$Branch, [string[]]$EditablePlugins, [string[]]$RequiredPlugins, [string[]]$HostFiles)
    $argsList = @('create', '--root', $RepositoryRoot, '--name', $Name)
    if ($Branch) { $argsList += @('--branch', $Branch) }
    foreach ($plugin in $EditablePlugins) { $argsList += @('--editable', $plugin) }
    foreach ($plugin in $RequiredPlugins) { $argsList += @('--required', $plugin) }
    foreach ($file in $HostFiles) { $argsList += @('--host-file', $file) }
    $data = Invoke-WorkspaceFiles -Arguments $argsList
    $config = Set-WorkspaceManagedConfiguration -ProjectRoot $data.WorkspaceRoot -SourceRoot $RepositoryRoot
    return [pscustomobject]@{ WorktreeRoot = $data.WorkspaceRoot; WorkspaceRoot = $data.WorkspaceRoot; RepositoryRoot = $RepositoryRoot; Created = $true; Mutates = $true; Configuration = $config; Workspace = $data }
}

function Initialize-HarnessWorkspacePlugins {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$WorkspaceRoot, [string[]]$EditablePlugins = @(), [string[]]$RequiredPlugins = @())
    $root = Resolve-WorkspaceRepository $WorkspaceRoot
    if (-not (Test-Path (Join-Path $root '.harness/workspace.json'))) { throw 'workspace.prepare applies to a registered project replica.' }
    $argsList = @('prepare', '--root', $root)
    foreach ($plugin in $EditablePlugins) { $argsList += @('--editable', $plugin) }
    foreach ($plugin in $RequiredPlugins) { $argsList += @('--required', $plugin) }
    return Invoke-WorkspaceFiles -Arguments $argsList
}

function Get-WorkspaceReplicaDetails {
    param([string]$Root)
    $verification = Invoke-WorkspaceFiles -Arguments @('verify', '--root', $Root)
    $repos = @($verification.Workspace.Repositories.PSObject.Properties | ForEach-Object {
        $entry = $_.Value
        $dirty = if ($entry.Mode -eq 'Worktree') { @(Get-WorkspaceDirtyLines $entry.Root) } else { @() }
        $actual = if ($entry.Mode -eq 'Worktree' -and (Test-Path $entry.Root)) { ((Invoke-WorkspaceGit -Repository $entry.Root -Arguments @('rev-parse','HEAD')).Output | Select-Object -Last 1).Trim() } else { $entry.BaseCommit }
        [pscustomobject]@{ Name = $_.Name; Path = $entry.Path; Initialized = (Test-Path $entry.Root); Expected = $entry.BaseCommit; Actual = $actual; Exact = $true; Dirty = $dirty.Count -gt 0; Payload = @(); IgnoredFiles = @(); Mode = $entry.Mode }
    })
    return [pscustomobject]@{ Submodules = $repos; Dirty = @($repos | Where-Object Dirty).Count -gt 0; Errors = @($verification.Errors) }
}

function Remove-WorkspaceReplica {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Root, [string]$PrimaryRoot, [switch]$DiscardIgnoredFiles)
    $data = Get-WorkspaceReplicaDescriptor $Root
    $container = Join-Path $PrimaryRoot '.workspaces'
    if (-not (Test-WorkspacePathEqual $data.PrimaryRoot $PrimaryRoot) -or -not (Test-WorkspacePathEqual (Split-Path $Root -Parent) $container)) { throw 'Replica removal requires its exact registered control center and root.' }
    [void](Assert-WorkspacePathChainSafe -Root $PrimaryRoot -Target $Root -Purpose 'replica removal')
    $queue = Join-Path $Root 'Saved/Harness/ChangeQueue/queue.json'
    if (Test-Path $queue) {
        $state = Get-Content $queue -Raw | ConvertFrom-Json
        if ($state.controller -or @($state.items | Where-Object disposition -eq 'pending').Count) { throw 'Release the controller and explicitly remove pending queue entries before workspace removal.' }
    }
    $verification = Test-HarnessWorkspace -WorkspaceRoot $Root -RequireClean
    if (-not $verification.IsValid) { throw "Refusing to remove changed replica: $($verification.Errors -join '; ')" }
    $known = @{}; foreach ($entry in $data.HostFiles.PSObject.Properties) { $known[$entry.Name] = $true }
    $known['.harness/workspace.json'] = $true
    $repositories = @($data.Repositories.PSObject.Properties | ForEach-Object Value)
    $local = [Collections.Generic.List[string]]::new()
    foreach ($file in Get-ChildItem -LiteralPath $Root -Force -Recurse) {
        [void](Assert-WorkspacePathChainSafe -Root $Root -Target $file.FullName -Purpose 'replica removal payload')
        if ($file.PSIsContainer) { continue }
        $relative = [IO.Path]::GetRelativePath($Root, $file.FullName).Replace('\','/')
        if ($known.ContainsKey($relative)) { continue }
        $repo = $repositories | Where-Object { $relative.StartsWith($_.Path + '/', [StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
        if ($repo) { continue } # Snapshot hashes and Git dirty checks were verified above.
        if ($relative -notmatch '^(AgentConfig\.ini$|Saved/|Intermediate/|Binaries/|\.vs/)') { throw "Unrecognized local data preserved: $relative" }
        $local.Add($relative)
    }
    foreach ($repo in $repositories | Where-Object Mode -eq 'Worktree') {
        foreach ($line in @(Get-WorkspaceIgnoredLines -Repository $repo.Root)) { $local.Add($repo.Path + '/' + $line.Substring(3)) }
    }
    if ($local.Count -and -not $DiscardIgnoredFiles) { throw 'Replica contains ignored local data; explicit DiscardIgnoredFiles is required.' }
    if ($PSCmdlet.ShouldProcess($Root, 'remove verified project replica and plugin worktrees; preserve branches')) {
        $removalLease = Enter-WorkspaceRemovalLease -Root $Root
        try {
            $verification = Test-HarnessWorkspace -WorkspaceRoot $Root -RequireClean
            if (-not $verification.IsValid) { throw "Replica changed before removal: $($verification.Errors -join '; ')" }
            foreach ($repo in $repositories | Where-Object Mode -eq 'Worktree') {
                [void](Assert-WorkspacePathChainSafe -Root $Root -Target $repo.Root -Purpose 'plugin worktree removal')
                [void](Invoke-WorkspaceGit -Repository $repo.SourceRoot -Arguments @('worktree','remove','--force',$repo.Root))
            }
            [void](Assert-WorkspacePathChainSafe -Root $PrimaryRoot -Target $Root -Purpose 'replica payload removal')
            Remove-Item -LiteralPath $Root -Recurse -Force
            $registration = Join-Path $PrimaryRoot "Saved/Harness/Workspaces/$($data.WorkspaceId).json"
            [void](Assert-WorkspacePathChainSafe -Root $PrimaryRoot -Target $registration -Purpose 'replica unregister')
            Remove-Item -LiteralPath $registration
        } finally { Exit-WorkspaceRemovalLease -Lease $removalLease }
    }
    return [pscustomobject]@{WorktreeRoot=$Root; Removed=(-not (Test-Path $Root)); BranchPreserved=$true; DiscardedIgnoredFiles=@($local)}
}
