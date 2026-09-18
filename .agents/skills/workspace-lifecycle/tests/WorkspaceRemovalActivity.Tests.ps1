[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$workspaceModule = Import-Module (Join-Path $PSScriptRoot '../scripts/WorkspaceLifecycle.psd1') -Force -PassThru
$unrealManifest = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../unreal-engine-develop/scripts/UnrealEngineDevelop.psd1'))
$unrealModule = Import-Module $unrealManifest -Force -PassThru
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('workspace-activity-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($scratch)
$failures = [Collections.Generic.List[string]]::new()
function Check([string]$Name, [scriptblock]$Body) {
    try { & $Body; Write-Output "PASS $Name" }
    catch { $failures.Add("$Name : $_"); Write-Output "FAIL $Name : $_" }
}
try {
    & $unrealModule {
        $script:ActivityFixtureNative = @()
        function script:Get-HarnessUnrealProcessList { param($WorkspaceRoot, [switch]$RequireComplete, $Limit) $script:ActivityFixtureNative }
    }
    & $workspaceModule {
        param($Primary)
        $script:ActivityPrimary = $Primary
        $script:ActivityDeleted = $false
        $script:ActivityEffects = [Collections.Generic.List[string]]::new()
        function script:Resolve-WorkspaceRepository { param($Path) $script:ActivityPrimary }
        function script:Get-PrimaryWorkspaceRoot { param($Repository) $Repository }
        function script:Get-RegisteredWorkspaceRoots { param($Repository) $script:ActivityRoot }
        function script:Get-WorkspaceReplicaDescriptor { param($Root) [pscustomobject]@{PrimaryRoot=$script:ActivityPrimary;WorkspaceId='workspace_0123456789abcdef0123456789abcdef';HostFiles=[pscustomobject]@{};Repositories=[pscustomobject]@{}} }
        function script:Assert-WorkspacePathChainSafe { param($Root,$Target,$Purpose) }
        function script:Test-HarnessWorkspace { param($WorkspaceRoot,$ProjectRoot,[switch]$RequireClean) [pscustomobject]@{IsValid=$true;Errors=@();Status=[pscustomobject]@{Submodules=@()}} }
        function script:Get-WorkspaceIgnoredLines { param($Repository) @() }
        function script:Get-ChildItem { param($LiteralPath,[switch]$Force,[switch]$Recurse,$ErrorAction) @() }
        function script:Get-HarnessWorkspaceContext { param($WorkspaceRoot) [pscustomobject]@{WorkspaceRoot=$WorkspaceRoot} }
        function script:Invoke-Harness { param($Command,$Context) [pscustomobject]@{status='Succeeded';data=@()} }
        function script:Assert-FixtureRemovalOwnership {
            foreach ($scope in @('workspace-admission','workspace')) {
                $name = & (Get-Module UnrealEngineDevelop) { param($Root,$Scope) Get-UnrealMutexName -Scope $Scope -Key $Root } $script:ActivityRoot $scope
                $probe = [PowerShell]::Create()
                try {
                    [void]$probe.AddScript({ param($Name) $mutex=[Threading.Mutex]::new($false,$Name); try { $acquired=$mutex.WaitOne(0); if($acquired){$mutex.ReleaseMutex()}; $acquired } finally {$mutex.Dispose()} }).AddArgument($name)
                    $async = $probe.BeginInvoke(); $acquired = @($probe.EndInvoke($async))[0]
                    if ($acquired) { throw "Deletion ran without held $scope ownership" }
                } finally {$probe.Dispose()}
            }
        }
        function script:Remove-Item { param($LiteralPath,[switch]$Recurse,[switch]$Force,$ErrorAction) Assert-FixtureRemovalOwnership; $script:ActivityEffects.Add("remove:$LiteralPath"); if ($LiteralPath -eq $script:ActivityRoot) {$script:ActivityDeleted=$true} }
        function script:Invoke-WorkspaceGit { param($Repository,$Arguments) Assert-FixtureRemovalOwnership; $script:ActivityEffects.Add("git:$($Arguments -join ' ')"); $script:ActivityDeleted=$true }
        function script:Clear-HarnessWorkspaceCache { }
        function script:Test-Path {
            param($LiteralPath,$Path,$PathType)
            $candidate = if ($LiteralPath) {$LiteralPath} else {$Path}
            if ($script:ActivityDeleted -and $candidate -eq $script:ActivityRoot) { return $false }
            Microsoft.PowerShell.Management\Test-Path -LiteralPath $candidate
        }
    } $scratch
    foreach ($topology in @('replica','legacy')) {
        $container = if ($topology -eq 'replica') {'.workspaces'} else {'.worktrees'}
        $root = Join-Path $scratch "$container/selected"
        [void][IO.Directory]::CreateDirectory($root)
        if ($topology -eq 'replica') { [void][IO.Directory]::CreateDirectory((Join-Path $root '.harness')); [IO.File]::WriteAllText((Join-Path $root '.harness/workspace.json'),'{}') }
        & $workspaceModule { param($Root) $script:ActivityRoot=$Root } $root
        foreach ($state in @('Queued','WaitingWorkspace','WaitingExecutionDrive','WaitingEngine','Running','Succeeded')) {
            Check "$topology refuses managed $state worker even with no native processes" {
                $runId = '1234567890abcdef1234567890abcdef'
                & $unrealModule {
                    param($Root,$Id,$State)
                    $paths = Get-UnrealRunPaths $Root $Id
                    Write-UnrealJsonFileAtomic $paths.MetadataPath ([pscustomobject]@{schemaVersion='harness-unreal-run';runId=$Id;workspaceRoot=$Root;state=$State;workerPid=$PID;workerStartedAtUtc=(Get-Process -Id $PID).StartTime.ToUniversalTime().ToString('o')})
                } $root $runId $state
                $result = & $workspaceModule {
                    param($Root,$Primary)
                    $script:ActivityDeleted=$false; $script:ActivityEffects.Clear(); $message=''
                    try { Remove-HarnessWorkspace -WorktreeRoot $Root -RepositoryRoot $Primary -DiscardIgnoredFiles -Confirm:$false | Out-Null } catch { $message=$_.Exception.Message }
                    [pscustomobject]@{Message=$message;Effects=@($script:ActivityEffects)}
                } $root $scratch
                if ($result.Effects.Count -or $result.Message -notmatch $runId) { throw "active run was not refused with its identity; effects=$($result.Effects -join ','); message=$($result.Message)" }
            }
        }
        foreach ($worker in @($null, 2147483647)) {
            Check "$topology preserves a queued or orphaned run with worker PID '$worker'" {
                $runId='1234567890abcdef1234567890abcdef'
                & $unrealModule {param($Root,$Worker) $paths=Get-UnrealRunPaths $Root '1234567890abcdef1234567890abcdef'; Write-UnrealJsonFileAtomic $paths.MetadataPath ([pscustomobject]@{schemaVersion='harness-unreal-run';runId='1234567890abcdef1234567890abcdef';workspaceRoot=$Root;state='Queued';workerPid=$Worker;workerStartedAtUtc=$null})} $root $worker
                $result=& $workspaceModule {
                    param($Root,$Primary)
                    $script:ActivityDeleted=$false;$script:ActivityEffects.Clear();$message=''
                    try {Remove-HarnessWorkspace -WorktreeRoot $Root -RepositoryRoot $Primary -DiscardIgnoredFiles -Confirm:$false|Out-Null} catch {$message=$_.Exception.Message}
                    [pscustomobject]@{Message=$message;Effects=@($script:ActivityEffects)}
                } $root $scratch
                if($result.Effects.Count -or $result.Message -notmatch $runId){throw 'queued/orphaned metadata was treated as quiescent'}
            }
        }
        # A completed run with no worker is the existing removable control.
        & $unrealModule { param($Root) $paths=Get-UnrealRunPaths $Root '1234567890abcdef1234567890abcdef'; [void](Update-UnrealRunMetadata $paths.MetadataPath @{state='Cancelled';workerPid=$null}) } $root
        foreach ($kind in @('workspace-match','uncorrelated','uninspectable')) {
            Check "$topology preserves payload for $kind native activity" {
                & $unrealModule {
                    param($Kind)
                    $script:ActivityFixtureNative=@([pscustomobject]@{Id=7654;Name='UnrealEditor';WorkspaceMatch=($Kind -eq 'workspace-match');WorkspaceRoot='';CommandLine=$(if($Kind -eq 'uninspectable'){''}else{'UnrealEditor'})})
                } $kind
                $result = & $workspaceModule {
                    param($Root,$Primary)
                    $script:ActivityDeleted=$false; $script:ActivityEffects.Clear(); $message=''
                    try { Remove-HarnessWorkspace -WorktreeRoot $Root -RepositoryRoot $Primary -DiscardIgnoredFiles -Confirm:$false | Out-Null } catch {$message=$_.Exception.Message}
                    [pscustomobject]@{Message=$message;Effects=@($script:ActivityEffects)}
                } $root $scratch
                if ($result.Effects.Count -or $result.Message -notmatch '7654') { throw "unsafe native activity did not preserve payload: $($result.Message)" }
            }
        }
        & $unrealModule { $script:ActivityFixtureNative=@() }
        Check "$topology clean quiescent removal reaches only selected deletion spies" {
            $result = & $workspaceModule {
                param($Root,$Primary)
                $script:ActivityDeleted=$false; $script:ActivityEffects.Clear()
                $removed=Remove-HarnessWorkspace -WorktreeRoot $Root -RepositoryRoot $Primary -DiscardIgnoredFiles -Confirm:$false
                [pscustomobject]@{Removed=$removed.Removed;Effects=@($script:ActivityEffects)}
            } $root $scratch
            if (-not $result.Removed -or -not $result.Effects.Count) { throw 'quiescent authorized removal was blocked' }
        }
        foreach ($scope in @('workspace-admission','workspace')) {
            Check "$topology removal refuses held $scope ownership" {
                $mutexName = & $unrealModule {param($Root,$Scope) Get-UnrealMutexName -Scope $Scope -Key $Root} $root $scope
                $ready=[Threading.ManualResetEventSlim]::new($false); $release=[Threading.ManualResetEventSlim]::new($false)
                $shell=[PowerShell]::Create()
                [void]$shell.AddScript({param($Name,$Ready,$Release) $mutex=[Threading.Mutex]::new($false,$Name); try {[void]$mutex.WaitOne();$Ready.Set();[void]$Release.Wait(10000)} finally {$mutex.ReleaseMutex();$mutex.Dispose()}}).AddArgument($mutexName).AddArgument($ready).AddArgument($release)
                $pending=$shell.BeginInvoke()
                try {
                    if(-not $ready.Wait(5000)){throw 'fixture lease acquisition timed out'}
                    $result=& $workspaceModule {
                        param($Root,$Primary)
                        $script:ActivityDeleted=$false; $script:ActivityEffects.Clear();$message=''
                        try {Remove-HarnessWorkspace -WorktreeRoot $Root -RepositoryRoot $Primary -DiscardIgnoredFiles -Confirm:$false | Out-Null} catch {$message=$_.Exception.Message}
                        [pscustomobject]@{Message=$message;Effects=@($script:ActivityEffects)}
                    } $root $scratch
                    if ($result.Effects.Count -or $result.Message -notmatch 'ownership|lease|admission') {throw "removal bypassed held ownership: $($result.Message)"}
                } finally {$release.Set();$shell.EndInvoke($pending)|Out-Null;$shell.Dispose();$ready.Dispose();$release.Dispose()}
            }
        }
    }
} finally {
    Remove-Module $workspaceModule, $unrealModule -Force
    $resolved=[IO.Path]::GetFullPath($scratch)
    if($resolved.StartsWith([IO.Path]::GetTempPath(),[StringComparison]::OrdinalIgnoreCase) -and [IO.Path]::GetFileName($resolved).StartsWith('workspace-activity-')) {Remove-Item -LiteralPath $resolved -Recurse -Force}
}
if($failures.Count){throw ($failures -join "`n")}
