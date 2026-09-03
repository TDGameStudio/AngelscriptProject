[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-False {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}

function Assert-ThrowsMatch {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    $caught = $null
    try { & $Action } catch { $caught = $_ }
    if ($null -eq $caught -or $caught.Exception.Message -notmatch $Pattern) {
        $actual = if ($null -eq $caught) { '<no exception>' } else { $caught.Exception.Message }
        throw "Assertion failed: $Message (actual '$actual')"
    }
}

function Invoke-TestGit {
    param([Parameter(Mandatory = $true)][string]$Repository, [Parameter(Mandatory = $true)][string[]]$Arguments)
    $oldAllow = $env:GIT_ALLOW_PROTOCOL
    $oldPreference = $ErrorActionPreference
    $env:GIT_ALLOW_PROTOCOL = 'file'
    $ErrorActionPreference = 'Continue'
    try { $output = @(& git -C $Repository @Arguments 2>&1); $exitCode = $LASTEXITCODE }
    finally { $env:GIT_ALLOW_PROTOCOL = $oldAllow; $ErrorActionPreference = $oldPreference }
    if ($exitCode -ne 0) { throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($output -join [Environment]::NewLine)" }
    return @($output | ForEach-Object { [string]$_ })
}

function Initialize-TestRepository {
    param([Parameter(Mandatory = $true)][string]$Path)
    [void](New-Item -ItemType Directory -Path $Path -Force)
    & git -C $Path init --initial-branch=main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { & git -C $Path init 2>&1 | Out-Null; Invoke-TestGit -Repository $Path -Arguments @('checkout', '-b', 'main') | Out-Null }
    Invoke-TestGit -Repository $Path -Arguments @('config', 'user.name', 'Hardness Fixture') | Out-Null
    Invoke-TestGit -Repository $Path -Arguments @('config', 'user.email', 'hardness-fixture@example.invalid') | Out-Null
}

$workspaceManifest = Join-Path $PSScriptRoot '..\scripts\WorkspaceLifecycle.psd1'
$workspaceModuleFile = Join-Path $PSScriptRoot '..\scripts\WorkspaceLifecycle.psm1'
$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($workspaceModuleFile, [ref]$tokens, [ref]$parseErrors)
Assert-Equal 0 @($parseErrors).Count 'WorkspaceLifecycle.psm1 must parse without errors'
Import-Module $workspaceManifest -Force
$workspaceModule = Get-Module WorkspaceLifecycle

foreach ($commandName in @(
    'Get-HardnessWorkspaceContext',
    'Get-HardnessWorkspaceList',
    'Get-HardnessWorkspaceStatus',
    'Initialize-HardnessWorkspace',
    'Test-HardnessWorkspace',
    'Get-HardnessWorkspaceConfigStatus',
    'Get-HardnessWorkspaceConfigValue',
    'Get-HardnessWorkspaceConfigValues',
    'Set-HardnessWorkspaceConfigValue',
    'Set-HardnessWorkspaceSession',
    'Assert-HardnessWorkspaceExecution'
)) {
    $command = Get-Command $commandName -ErrorAction Stop
    $hasWorkspaceRoot = $command.Parameters.ContainsKey('WorkspaceRoot')
    if (-not $hasWorkspaceRoot -and $command.Parameters.ContainsKey('ProjectRoot')) {
        $aliases = @($command.Parameters['ProjectRoot'].Aliases)
        $hasWorkspaceRoot = 'WorkspaceRoot' -in $aliases
    }
    Assert-True $hasWorkspaceRoot "$commandName accepts the common WorkspaceRoot contract"
}

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-workspace-{0}" -f [guid]::NewGuid().ToString('N'))
$childRoot = Join-Path $fixtureRoot 'child'
$parentRoot = Join-Path $fixtureRoot 'parent'
$externalRoot = Join-Path $fixtureRoot 'heterogeneous\custom-location'
$refreshRoot = Join-Path $fixtureRoot 'heterogeneous\refresh-location'
$sessionNames = @(
    'HARDNESS_WORKSPACE_ROOT',
    'HARDNESS_PRIMARY_ROOT',
    'HARDNESS_GIT_COMMON_DIR',
    'HARDNESS_WORKSPACE_MODE',
    'HARDNESS_GOAL_NAME'
)
$savedSession = @{}
foreach ($name in $sessionNames) {
    $savedSession[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

try {
    Initialize-TestRepository -Path $childRoot
    [System.IO.File]::WriteAllText((Join-Path $childRoot 'marker.txt'), "v1`n")
    Invoke-TestGit -Repository $childRoot -Arguments @('add', 'marker.txt') | Out-Null
    Invoke-TestGit -Repository $childRoot -Arguments @('commit', '-m', 'child v1') | Out-Null

    Initialize-TestRepository -Path $parentRoot
    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.gitignore'), ".worktrees/`nAgentConfig.ini`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'Fixture.uproject'), "{}`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "fixture`n")
    Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.gitignore', 'Fixture.uproject', 'README.md') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'parent base') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'add', '--name', 'sdk', $childRoot, 'Modules/Child') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-am', 'add child') | Out-Null

    $primaryProjectFile = [System.IO.Path]::GetFullPath((Join-Path $parentRoot 'Fixture.uproject'))
    $commonDirRaw = ((Invoke-TestGit -Repository $parentRoot -Arguments @('rev-parse', '--git-common-dir')) | Select-Object -Last 1).Trim()
    $commonDir = if ([System.IO.Path]::IsPathRooted($commonDirRaw)) { [System.IO.Path]::GetFullPath($commonDirRaw) } else { [System.IO.Path]::GetFullPath((Join-Path $parentRoot $commonDirRaw)) }
    $legacyConfig = @"
; preserve this comment
[Paths]
EngineRoot=C:\FixtureEngine
ProjectFile=C:\Stale\Fixture.uproject

[References]
HazelightAngelscriptEngineRoot=C:\Obsolete
KeepReference=C:\Keep

[Hardness]
SchemaVersion=1
WorkspaceKind=Primary
PrimaryRoot=$parentRoot
WorkspaceRoot=$parentRoot
GitCommonDir=$commonDir
GoalName=

[LocalAgent]
Profile=fixture
"@
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'AgentConfig.ini'), $legacyConfig)

    $bootstrap = Initialize-HardnessWorkspace -ProjectRoot $parentRoot
    $primaryConfig = Get-HardnessWorkspaceConfigStatus -ProjectRoot $parentRoot
    Assert-True $primaryConfig.IdentityValid 'bootstrap stamps exact schema-v2 workspace identity'
    Assert-Equal '2' $primaryConfig.Identity.SchemaVersion 'bootstrap upgrades the managed schema to v2'
    Assert-Equal $primaryProjectFile (Get-HardnessWorkspaceConfigValue -ProjectRoot $parentRoot -Section Paths -Key ProjectFile).Value 'bootstrap rebinds ProjectFile to the selected root'
    Assert-False (Get-HardnessWorkspaceConfigValue -ProjectRoot $parentRoot -Section Hardness -Key WorkspaceKind).Exists 'migration removes WorkspaceKind'
    Assert-False (Get-HardnessWorkspaceConfigValue -ProjectRoot $parentRoot -Section Hardness -Key GoalName).Exists 'migration removes GoalName'
    Assert-False (Get-HardnessWorkspaceConfigValue -ProjectRoot $parentRoot -Section References -Key HazelightAngelscriptEngineRoot).Exists 'migration removes the obsolete Hazelight path'
    Assert-Equal 'C:\Keep' (Get-HardnessWorkspaceConfigValue -ProjectRoot $parentRoot -Section References -Key KeepReference).Value 'migration preserves unrelated reference data'
    Assert-Equal 'fixture' (Get-HardnessWorkspaceConfigValue -ProjectRoot $parentRoot -Section LocalAgent -Key Profile).Value 'migration preserves local agent data'
    Assert-True ((Get-Content -LiteralPath (Join-Path $parentRoot 'AgentConfig.ini') -Raw).Contains('; preserve this comment')) 'migration preserves comments'
    Assert-True $bootstrap.Configuration.Identity.Managed 'bootstrap returns a managed Git-derived identity'

    $harnessRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
    $primaryContext = Get-HardnessWorkspaceContext -ProjectRoot $parentRoot
    foreach ($field in @('SchemaVersion', 'HarnessRoot', 'WorkspaceRoot', 'PrimaryRoot', 'GitCommonDir', 'Topology', 'WorktreeName', 'Branch', 'Head', 'Managed')) {
        Assert-True ($field -in $primaryContext.PSObject.Properties.Name) "context exposes $field"
    }
    Assert-Equal $harnessRoot $primaryContext.HarnessRoot 'HarnessRoot identifies the checkout supplying the loaded module'
    Assert-Equal $parentRoot $primaryContext.WorkspaceRoot 'WorkspaceRoot identifies the selected command target'
    Assert-Equal 'Primary' $primaryContext.Topology 'the canonical checkout has Primary topology'
    Assert-Equal '' $primaryContext.WorktreeName 'the canonical checkout has no linked-worktree name'
    Assert-True $primaryContext.Managed 'the bootstrapped primary checkout is managed'

    $created = New-HardnessWorkspace -Name 'fixture-workspace' -RepositoryRoot $parentRoot
    $worktreeRoot = Join-Path $parentRoot '.worktrees\fixture-workspace'
    Assert-Equal $worktreeRoot $created.WorktreeRoot 'new creates under the canonical local container'
    Assert-Equal 'fixture-workspace' $created.Branch 'the default branch is exactly Name'
    Assert-Equal 'fixture-workspace' (((Invoke-TestGit -Repository $worktreeRoot -Arguments @('branch', '--show-current')) | Select-Object -Last 1).Trim()) 'Git receives the exact default branch'
    Assert-False (Test-Path -LiteralPath (Join-Path $worktreeRoot 'openspec\changes\fixture-workspace')) 'creation does not scaffold workflow records'

    $linkedContext = Get-HardnessWorkspaceContext -ProjectRoot $worktreeRoot
    Assert-Equal 'Worktree' $linkedContext.Topology 'a linked checkout has Worktree topology'
    Assert-Equal 'fixture-workspace' $linkedContext.WorktreeName 'the worktree name is derived from Git registration metadata'
    Assert-True $linkedContext.Managed 'new bootstraps a managed local configuration'
    Assert-Equal ([System.IO.Path]::GetFullPath((Join-Path $worktreeRoot 'Fixture.uproject'))) (Get-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section Paths -Key ProjectFile).Value 'ProjectFile is rebound in a linked checkout'
    Assert-Equal 'fixture' (Get-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section LocalAgent -Key Profile).Value 'shared local values are copied from the primary checkout'

    [void](New-Item -ItemType Directory -Path (Split-Path -Parent $externalRoot) -Force)
    Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'add', '-b', 'topic/no-prefix', $externalRoot, 'HEAD') | Out-Null
    $unmanagedContext = Get-HardnessWorkspaceContext -ProjectRoot $externalRoot
    Assert-Equal 'Worktree' $unmanagedContext.Topology 'a heterogeneous registered checkout is accepted'
    Assert-Equal 'custom-location' $unmanagedContext.WorktreeName 'heterogeneous name comes from registered worktree metadata'
    Assert-Equal 'topic/no-prefix' $unmanagedContext.Branch 'heterogeneous branch naming is preserved'
    Assert-False $unmanagedContext.Managed 'a registered checkout is valid before explicit bootstrap'
    [void](Initialize-HardnessWorkspace -ProjectRoot $externalRoot)
    $managedExternal = Get-HardnessWorkspaceContext -ProjectRoot $externalRoot -Refresh
    Assert-True $managedExternal.Managed 'bootstrap manages a heterogeneous worktree in place'
    Assert-Equal $externalRoot $managedExternal.WorkspaceRoot 'bootstrap does not relocate heterogeneous worktrees'
    Assert-Equal 'topic/no-prefix' $managedExternal.Branch 'bootstrap does not rename heterogeneous branches'

    $workspaces = @(Get-HardnessWorkspaceList -ProjectRoot $externalRoot)
    Assert-Equal 3 $workspaces.Count 'workspace.list returns every registered checkout'
    Assert-Equal 1 @($workspaces | Where-Object { $_.Topology -eq 'Primary' }).Count 'workspace.list identifies one primary checkout'
    Assert-Equal 2 @($workspaces | Where-Object { $_.Topology -eq 'Worktree' }).Count 'workspace.list identifies linked checkouts without path policy'
    Assert-Equal 1 @($workspaces | Where-Object { $_.WorkspaceRoot -eq $externalRoot -and $_.Managed }).Count 'workspace.list reports live managed state'

    [void](New-Item -ItemType Directory -Path (Split-Path -Parent $refreshRoot) -Force)
    Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'add', '-b', 'refresh-visible', $refreshRoot, 'HEAD') | Out-Null
    $refreshed = @(Get-HardnessWorkspaceList -ProjectRoot $parentRoot -Refresh)
    Assert-Equal 4 $refreshed.Count 'explicit refresh sees newly registered worktrees'
    Assert-Equal 1 @($refreshed | Where-Object WorkspaceRoot -eq $refreshRoot).Count 'refresh returns the newly registered root'

    $gitTrace = Join-Path $fixtureRoot 'fast-status.git-trace'
    $oldTrace = $env:GIT_TRACE
    $env:GIT_TRACE = $gitTrace
    try { $fastStatus = Get-HardnessWorkspaceStatus -ProjectRoot $externalRoot }
    finally { $env:GIT_TRACE = $oldTrace }
    Assert-Equal 'Fast' $fastStatus.DetailLevel 'status defaults to the fast tier'
    Assert-False ('Dirty' -in $fastStatus.PSObject.Properties.Name) 'fast status does not pretend to contain dirty-state diagnostics'
    Assert-False ('Submodules' -in $fastStatus.PSObject.Properties.Name) 'fast status does not contain submodule diagnostics'
    $traceText = if (Test-Path -LiteralPath $gitTrace) { Get-Content -LiteralPath $gitTrace -Raw } else { '' }
    Assert-False ($traceText -match '(?m)built-in: git status(?:\s|$)') 'fast status never invokes git status'
    Assert-False ($traceText -match '(?m)built-in: git submodule(?:\s|$)') 'fast status never recursively inspects submodules'

    [System.IO.File]::WriteAllText((Join-Path $externalRoot 'dirty.txt'), "dirty`n")
    $detailedStatus = Get-HardnessWorkspaceStatus -ProjectRoot $externalRoot -Detailed
    Assert-Equal 'Detailed' $detailedStatus.DetailLevel 'Detailed opts into the expensive tier'
    Assert-True $detailedStatus.Dirty 'detailed status reports parent dirty state'
    Assert-True @($detailedStatus.Changes).Count -gt 0 'detailed status includes exact parent changes'
    Assert-True @($detailedStatus.Submodules).Count -eq 1 'detailed status includes top-level submodule diagnostics'
    Assert-True @($detailedStatus.IgnoredFiles).Count -gt 0 'detailed status inventories ignored workspace payload'
    [System.IO.File]::Delete((Join-Path $externalRoot 'dirty.txt'))

    foreach ($legacyName in @('HARDNESS_WORKSPACE_MODE', 'HARDNESS_GOAL_NAME')) {
        [Environment]::SetEnvironmentVariable($legacyName, 'legacy', 'Process')
    }
    $activation = Set-HardnessWorkspaceSession -ProjectRoot $externalRoot
    Assert-Equal $externalRoot $activation.WorkspaceRoot 'selection binds the exact registered workspace'
    Assert-Equal $parentRoot ([Environment]::GetEnvironmentVariable('HARDNESS_PRIMARY_ROOT', 'Process')) 'selection publishes the primary root'
    Assert-Equal $managedExternal.GitCommonDir ([Environment]::GetEnvironmentVariable('HARDNESS_GIT_COMMON_DIR', 'Process')) 'selection publishes the common Git directory'
    Assert-True ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable('HARDNESS_WORKSPACE_MODE', 'Process'))) 'selection clears legacy mode state'
    Assert-True ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable('HARDNESS_GOAL_NAME', 'Process'))) 'selection clears legacy goal-name state'
    Assert-False ('Mode' -in $activation.PSObject.Properties.Name) 'selection result has no repository mode'
    Assert-False ('GoalName' -in $activation.PSObject.Properties.Name) 'selection result has no goal identity'
    Assert-False ((Get-Command Set-HardnessWorkspaceSession).Parameters.ContainsKey('Mode')) 'selection API has no Mode parameter'
    Assert-False ((Get-Command Set-HardnessWorkspaceSession).Parameters.ContainsKey('GoalName')) 'selection API has no GoalName parameter'
    [void](Assert-HardnessWorkspaceExecution -ProjectRoot $externalRoot -CallerPath $externalRoot)
    Assert-ThrowsMatch { Assert-HardnessWorkspaceExecution -ProjectRoot $parentRoot -CallerPath $externalRoot | Out-Null } 'selected workspace|targets' 'a selected linked workspace cannot accidentally target primary'

    [void](Set-HardnessWorkspaceConfigValue -ProjectRoot $externalRoot -Section LocalAgent -Key Profile -Value 'external-fixture')
    Assert-Equal 'external-fixture' (Get-HardnessWorkspaceConfigValue -ProjectRoot $externalRoot -Section LocalAgent -Key Profile).Value 'controlled config mutation updates non-managed data'
    $configValues = Get-HardnessWorkspaceConfigValues -ProjectRoot $externalRoot -RequireExecutionGuard -CallerPath $externalRoot -Entries @(
        [pscustomobject]@{ Section = 'Paths'; Key = 'ProjectFile' }
        [pscustomobject]@{ Section = 'LocalAgent'; Key = 'Profile' }
        [pscustomobject]@{ Section = 'LocalAgent'; Key = 'Missing' }
    )
    Assert-Equal $externalRoot $configValues.ProjectRoot 'batched configuration binds the exact workspace once'
    Assert-Equal (Join-Path $externalRoot 'AgentConfig.ini') $configValues.ConfigPath 'batched configuration retains its validated source path'
    Assert-Equal $managedExternal.GitCommonDir $configValues.Identity.GitCommonDir 'batched configuration retains validated workspace identity'
    Assert-Equal 3 @($configValues.Values).Count 'batched configuration retains every requested entry'
    Assert-Equal (Join-Path $externalRoot 'Fixture.uproject') $configValues.Values[0].Value 'batched configuration returns the managed project path'
    Assert-Equal 'external-fixture' $configValues.Values[1].Value 'batched configuration returns a non-managed value'
    Assert-False $configValues.Values[2].Exists 'batched configuration represents a missing value without another status query'
    Assert-ThrowsMatch { Set-HardnessWorkspaceConfigValue -ProjectRoot $externalRoot -Section Hardness -Key WorkspaceRoot -Value other | Out-Null } 'managed|cannot be set' 'managed identity cannot be overwritten'
    Assert-ThrowsMatch { Set-HardnessWorkspaceConfigValue -ProjectRoot $externalRoot -Section LocalAgent -Key Notes -Value "line1`nline2" | Out-Null } 'single-line|NUL' 'multiline config injection is rejected'

    $externalConfigPath = Join-Path $externalRoot 'AgentConfig.ini'
    $configBeforeObsoleteSet = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($externalConfigPath))
    Assert-ThrowsMatch {
        Set-HardnessWorkspaceConfigValue -ProjectRoot $externalRoot -Section References -Key HazelightAngelscriptEngineRoot -Value 'C:\Obsolete' | Out-Null
    } 'obsolete|cannot be set' 'the obsolete Hazelight reference cannot be recreated through the controlled setter'
    $configAfterObsoleteSet = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($externalConfigPath))
    Assert-Equal $configBeforeObsoleteSet $configAfterObsoleteSet 'obsolete-key rejection happens before any AgentConfig.ini write'

    & $workspaceModule {
        param($path)
        Set-WorkspaceIniValueInternal -Path $path -Section References -Key HazelightAngelscriptEngineRoot -Value 'C:\Obsolete'
    } $externalConfigPath
    $obsoleteStatus = Get-HardnessWorkspaceConfigStatus -ProjectRoot $externalRoot
    Assert-False $obsoleteStatus.IdentityValid 'the obsolete Hazelight reference invalidates config identity status'
    Assert-True (@($obsoleteStatus.Errors | Where-Object { $_ -match 'HazelightAngelscriptEngineRoot.*obsolete' }).Count -eq 1) 'config status identifies the obsolete Hazelight reference exactly'
    Assert-False (Get-HardnessWorkspaceContext -ProjectRoot $externalRoot -Refresh).Managed 'the obsolete Hazelight reference invalidates the managed identity projection'
    Assert-ThrowsMatch {
        Assert-HardnessWorkspaceExecution -ProjectRoot $externalRoot -CallerPath $externalRoot | Out-Null
    } 'HazelightAngelscriptEngineRoot.*obsolete' 'the execution guard rejects a workspace carrying the obsolete Hazelight reference'

    [void](Initialize-HardnessWorkspace -ProjectRoot $externalRoot)
    $repairedStatus = Get-HardnessWorkspaceConfigStatus -ProjectRoot $externalRoot
    Assert-True $repairedStatus.IdentityValid 'bootstrap repairs config identity by removing the obsolete Hazelight reference'
    Assert-True (Get-HardnessWorkspaceContext -ProjectRoot $externalRoot -Refresh).Managed 'bootstrap restores the managed identity projection'
    Assert-False (Get-HardnessWorkspaceConfigValue -ProjectRoot $externalRoot -Section References -Key HazelightAngelscriptEngineRoot).Exists 'bootstrap removes the obsolete Hazelight reference'
    [void](Assert-HardnessWorkspaceExecution -ProjectRoot $externalRoot -CallerPath $externalRoot)

    $gitmodulesPath = Join-Path $parentRoot '.gitmodules'
    $validGitmodules = [System.IO.File]::ReadAllText($gitmodulesPath)
    [System.IO.File]::WriteAllText($gitmodulesPath, "[submodule `"broken`"`n  path = Modules/Child`n")
    Assert-Equal 'Fast' (Get-HardnessWorkspaceStatus -ProjectRoot $parentRoot).DetailLevel 'fast status does not parse submodule configuration'
    Assert-ThrowsMatch { Get-HardnessWorkspaceStatus -ProjectRoot $parentRoot -Detailed | Out-Null } 'gitmodules|config|failed|parse' 'detailed status reports malformed submodule configuration'
    [System.IO.File]::WriteAllText($gitmodulesPath, $validGitmodules)

    $submoduleRecords = @(& $workspaceModule { param($root) Get-WorkspaceSubmodules -Repository $root } $parentRoot)
    Assert-Equal 'sdk' $submoduleRecords[0].Name 'submodule parser preserves its logical name'
    Assert-Equal 'Modules/Child' $submoduleRecords[0].Path 'submodule parser preserves its checkout path'
    $moduleStore = & $workspaceModule { param($root) Get-WorkspaceSubmoduleStore -Repository $root -Name 'sdk' } $parentRoot
    Assert-True ($moduleStore.EndsWith((Join-Path 'modules' 'sdk'), [System.StringComparison]::OrdinalIgnoreCase)) 'fallback storage is keyed by logical name'
}
finally {
    foreach ($name in $sessionNames) {
        [Environment]::SetEnvironmentVariable($name, $savedSession[$name], 'Process')
    }
    Remove-Module WorkspaceLifecycle -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
}

Write-Output 'WorkspaceLifecycle.Tests.ps1: PASS'
