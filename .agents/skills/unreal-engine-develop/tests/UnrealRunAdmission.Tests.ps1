[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$module=Import-Module (Join-Path $PSScriptRoot '../scripts/UnrealEngineDevelop.psd1') -Force -PassThru
$root=Join-Path ([IO.Path]::GetTempPath()) ('unreal-admission-'+[guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($root)
$ready=[Threading.ManualResetEventSlim]::new($false);$release=[Threading.ManualResetEventSlim]::new($false)
$shell=[PowerShell]::Create()
$name=& $module {param($Root) Get-UnrealMutexName -Scope 'workspace-admission' -Key $Root} $root
[void]$shell.AddScript({param($Name,$Ready,$Release) $mutex=[Threading.Mutex]::new($false,$Name); try {[void]$mutex.WaitOne();$Ready.Set();[void]$Release.Wait(10000)} finally {$mutex.ReleaseMutex();$mutex.Dispose()}}).AddArgument($name).AddArgument($ready).AddArgument($release)
$pending=$shell.BeginInvoke()
$failures=[Collections.Generic.List[string]]::new()
try {
    if(-not $ready.Wait(5000)){throw 'fixture lease acquisition timed out'}
    & $module {
        param($Root,$Failures)
        function Get-UnrealRunPaths {param($WorkspaceRoot,$RunId) throw 'START_PREFLIGHT_REACHED'}
        $request=[pscustomobject]@{schemaVersion='harness-unreal-request';workspaceRoot=$Root;runId='1234567890abcdef1234567890abcdef';timeoutMs=1000;concurrency=[pscustomobject]@{policy='Fail'}}
        $message=''
        try {Start-UnrealRunRequest $request -NoWait | Out-Null} catch {$message=$_.Exception.Message}
        if($message -notmatch 'admission|ownership|lease' -or $message -eq 'START_PREFLIGHT_REACHED') {$Failures.Add("Run admission passed a removal gate: $message");Write-Output "FAIL competing run admission: $message"}
        else {Write-Output 'PASS competing run admission refuses held removal gate before run artifacts or worker startup'}
    } $root $failures
} finally {
    $release.Set();$shell.EndInvoke($pending)|Out-Null;$shell.Dispose();$ready.Dispose();$release.Dispose()
}
try {
    & $module {
        param($Root)
        function Get-UnrealRunPaths {param($WorkspaceRoot,$RunId) throw 'START_PREFLIGHT_REACHED'}
        $request=[pscustomobject]@{schemaVersion='harness-unreal-request';workspaceRoot=$Root;runId='1234567890abcdef1234567890abcdef';timeoutMs=1000;concurrency=[pscustomobject]@{policy='Fail'}}
        $message=''
        try {Start-UnrealRunRequest $request -NoWait | Out-Null} catch {$message=$_.Exception.Message}
        if($message -ne 'START_PREFLIGHT_REACHED'){throw "Released admission did not permit normal validation: $message"}
        Write-Output 'PASS released admission permits normal validation without launching a worker'
    } $root
    # A launcher already waiting at admission must revalidate after removal wins.
    $removalMutex=[Threading.Mutex]::new($false,$name)
    [void]$removalMutex.WaitOne()
    $held=$true
    $waiting=[Threading.ManualResetEventSlim]::new($false)
    $launcher=[PowerShell]::Create()
    try {
        [void]$launcher.AddScript({
            param($Manifest,$Root,$Waiting)
            $leaf=Import-Module $Manifest -PassThru
            & $leaf {
                param($Root,$Waiting)
                $leaseBody=${function:Enter-UnrealLease}
                function Enter-UnrealLease {
                    param($Scope,$Key,$Policy,$TimeoutMs)
                    $Waiting.Set()
                    & $leaseBody -Scope $Scope -Key $Key -Policy $Policy -TimeoutMs $TimeoutMs
                }
                function Get-UnrealRunPaths {param($WorkspaceRoot,$RunId) throw 'START_PREFLIGHT_REACHED'}
                $request=[pscustomobject]@{schemaVersion='harness-unreal-request';workspaceRoot=$Root;runId='1234567890abcdef1234567890abcdef';timeoutMs=5000;concurrency=[pscustomobject]@{policy='Wait'}}
                try {Start-UnrealRunRequest $request -NoWait|Out-Null; 'unexpected admission success'} catch {$_.Exception.Message}
            } $Root $Waiting
        }).AddArgument($module.Path).AddArgument($root).AddArgument($waiting)
        $launchPending=$launcher.BeginInvoke()
        if(-not $waiting.Wait(5000)){throw 'launcher did not reach admission wait'}
        $resolved=[IO.Path]::GetFullPath($root)
        if(-not $resolved.StartsWith([IO.Path]::GetTempPath(),[StringComparison]::OrdinalIgnoreCase) -or -not [IO.Path]::GetFileName($resolved).StartsWith('unreal-admission-')){throw 'unexpected fixture path'}
        [IO.Directory]::Delete($resolved) # Empty isolated fixture, never a registered workspace.
        $removalMutex.ReleaseMutex();$held=$false
        $result=@($launcher.EndInvoke($launchPending)) -join '\n'
        if($result -notmatch 'Path does not exist' -or (Test-Path -LiteralPath $root)){throw "waiting launcher recreated removed workspace: $result"}
        Write-Output 'PASS launcher waiting during removal refuses the missing root after admission releases'
    } finally {
        if($held){$removalMutex.ReleaseMutex()}
        $removalMutex.Dispose();$waiting.Dispose();$launcher.Dispose()
    }
} finally {
    $resolved=[IO.Path]::GetFullPath($root)
    if($resolved.StartsWith([IO.Path]::GetTempPath(),[StringComparison]::OrdinalIgnoreCase) -and [IO.Path]::GetFileName($resolved).StartsWith('unreal-admission-') -and (Test-Path -LiteralPath $resolved)) {Remove-Item -LiteralPath $resolved -Recurse -Force}
}
if($failures.Count){throw ($failures -join "`n")}
