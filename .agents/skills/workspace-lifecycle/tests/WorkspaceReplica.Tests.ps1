[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../scripts/WorkspaceLifecycle.psd1') -Force
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('workspace-replica-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($scratch)
function FixtureGit([string[]]$Arguments) {
    $output = & git -C $scratch @Arguments 2>&1
    if ($LASTEXITCODE) { throw "Fixture Git failed: $output" }
}
function Write-Fixture([string]$Path, [string]$Text) {
    $full = Join-Path $scratch $Path
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($full))
    [IO.File]::WriteAllText($full, $Text)
}
$failures = [Collections.Generic.List[string]]::new()
function Check([string]$Name, [scriptblock]$Body) {
    try { if (-not (& $Body)) { throw 'behavior mismatch' }; Write-Output "PASS $Name" }
    catch { $failures.Add("$Name : $_"); Write-Output "FAIL $Name : $_" }
}
try {
    FixtureGit @('init', '-b', 'main')
    FixtureGit @('config', 'user.name', 'Workspace fixture')
    FixtureGit @('config', 'user.email', 'workspace@example.invalid')
    Write-Fixture '.gitignore' ".worktrees/`n.workspaces/`nAgentConfig.ini`nSaved/`n"
    Write-Fixture 'Fixture.uproject' '{"FileVersion":3,"EngineAssociation":"5.8","Modules":[{"Name":"Fixture","Type":"Runtime","LoadingPhase":"Default"},{"Name":"AngelscriptJIT","Type":"Runtime"}],"Plugins":[]}'
    Write-Fixture 'Source/Fixture/Fixture.Build.cs' 'using UnrealBuildTool; public class Fixture : ModuleRules { public Fixture(ReadOnlyTargetRules Target) : base(Target) { PublicDependencyModuleNames.AddRange(new string[]{"Core","CoreUObject","Engine"}); } }'
    Write-Fixture 'Source/Fixture/Fixture.cpp' 'baseline'
    Write-Fixture 'Source/AngelscriptJIT/generated.cpp' 'not part of minimal project'
    Write-Fixture 'Wiki/history.md' 'not part of minimal project'
    Write-Fixture 'Content/Unrelated/huge.uasset' 'not part of minimal project'
    FixtureGit @('add', '.')
    FixtureGit @('commit', '-m', 'fixture')
    Write-Fixture 'Source/Fixture/Fixture.cpp' 'current uncommitted host source'
    Write-Fixture 'AgentConfig.ini' "[Paths]`nEngineRoot=C:\FixtureEngine`n"
    $created = New-HarnessWorkspace -RepositoryRoot $scratch -Name 'example'
    $root = $created.WorktreeRoot
    Check 'project root is not a parent Git worktree' { -not (Test-Path (Join-Path $root '.git')) }
    Check 'only required host files copied from current working tree' {
        (Get-Content (Join-Path $root 'Source/Fixture/Fixture.cpp') -Raw) -eq 'current uncommitted host source' -and
        -not (Test-Path (Join-Path $root 'Wiki')) -and -not (Test-Path (Join-Path $root 'Source/AngelscriptJIT')) -and
        -not (Test-Path (Join-Path $root 'Content/Unrelated'))
    }
    Check 'uproject and editor target have matching minimal module declarations' {
        $project = Get-Content (Join-Path $root 'Fixture.uproject') -Raw | ConvertFrom-Json
        @($project.Modules).Count -eq 1 -and $project.Modules[0].Name -eq 'Fixture' -and
        (Test-Path (Join-Path $root 'Source/FixtureEditor.Target.cs'))
    }
    Check 'workspace identity does not collapse into control center' {
        $context = Get-HarnessWorkspaceContext -WorkspaceRoot (Join-Path $root 'Source/Fixture')
        $context.WorkspaceRoot -eq $root -and $context.PrimaryRoot -eq $scratch -and $context.Topology -eq 'Replica'
    }
    Check 'configuration executes in selected project' {
        $status = Get-HarnessWorkspaceConfigStatus -WorkspaceRoot $root
        $status.IdentityValid -and (Get-HarnessWorkspaceConfigValue -WorkspaceRoot $root -Section Paths -Key ProjectFile).Value -eq (Join-Path $root 'Fixture.uproject')
    }
    Check 'parent Git worktree inventory is unchanged' { @(& git -C $scratch worktree list --porcelain | Where-Object { $_ -like 'worktree *' }).Count -eq 1 }
    Check 'rootless mapped UE project disables the invalid parent Git probe' {
        [xml]$buildConfig = Get-Content (Join-Path $root 'Saved/UnrealBuildTool/BuildConfiguration.xml') -Raw
        $buildConfig.Configuration.SourceFileWorkingSet.Provider -eq 'None'
    }
    $removable = (New-HarnessWorkspace -RepositoryRoot $scratch -Name 'removable').WorktreeRoot
    Check 'querying from a replica can inspect a sibling without drive-relative paths' {
        Push-Location $root
        $processDirectory = [Environment]::CurrentDirectory
        try {
            [Environment]::CurrentDirectory = $root
            (Get-HarnessWorkspaceContext -WorkspaceRoot $removable -Refresh).WorkspaceRoot -eq $removable
        }
        finally { [Environment]::CurrentDirectory = $processDirectory; Pop-Location }
    }
    Check 'replica removal preserves local outputs unless discard is explicit' {
        try { Remove-HarnessWorkspace -RepositoryRoot $scratch -WorktreeRoot $removable; $false }
        catch { (Test-Path $removable) -and $_.Exception.Message -match 'local data|ignored' }
    }
    Check 'explicit clean replica removal unregisters only the selected replica' {
        $result = Remove-HarnessWorkspace -RepositoryRoot $scratch -WorktreeRoot $removable -DiscardIgnoredFiles
        $result.Removed -and (Test-Path $root) -and (Test-Path (Join-Path $scratch '.git'))
    }
    Check 'source mutation is detected without overwriting user files' {
        [IO.File]::AppendAllText((Join-Path $root 'Source/Fixture/Fixture.cpp'), ' changed')
        -not (Test-HarnessWorkspace -WorkspaceRoot $root).IsValid
    }
} finally {
    # This is a fresh isolated fixture; never delete caller-provided paths.
    $resolved = [IO.Path]::GetFullPath($scratch)
    if ($resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($resolved).StartsWith('workspace-replica-')) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
if ($failures.Count) { throw ($failures -join "`n") }
