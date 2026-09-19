[CmdletBinding()]
param([switch]$DeclineConfirmation)
$ErrorActionPreference = 'Stop'
$module = Import-Module (Join-Path $PSScriptRoot '../scripts/UnrealEngineDevelop.psd1') -Force -PassThru
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('unreal-cancel-safety-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($scratch)
$failures = [Collections.Generic.List[string]]::new()
try {
    & $module {
        param($Root, $Failures, $Decline)
        # Real cancellation, path validation, metadata persistence and transition checks;
        # only workspace configuration, OS process lookup/kill and DOS mapping effects are isolated.
        function Get-UnrealWorkspaceConfiguration { param($WorkspaceRoot, [switch]$RequireExecutionGuard, $CallerPath) [pscustomobject]@{WorkspaceRoot=$WorkspaceRoot} }
        function Get-UnrealRunStatusRecord {
            param($WorkspaceRoot, $RunId)
            $metadata = Read-UnrealJsonFile (Get-UnrealRunPaths $WorkspaceRoot $RunId).MetadataPath
            [pscustomobject]@{RecordedState=$metadata.state; State=$metadata.state}
        }
        function Get-UnrealProcessRecordById { param($ProcessId) if ($ProcessId -eq 123) { [pscustomobject]@{CommandLine="pwsh Invoke-UnrealRunWorker.ps1 $runId"} } }
        function Stop-UnrealProcessTree { param($ProcessId) $effects.Add("kill:$ProcessId") }
        function Exit-UnrealExecutionDriveMappingAfterWorker { param($Mapping, $RunId) $effects.Add('mapping cleanup') }
        foreach ($initialState in @('Running', 'WaitingExternalBuild')) {
        foreach ($worker in @($null, 2147483647, 123)) {
            foreach ($preview in $(if ($Decline) {@($false)} else {@($true, $false)})) {
                $runId = [guid]::NewGuid().ToString('N')
                $paths = Get-UnrealRunPaths $Root $runId
                Write-UnrealJsonFileAtomic $paths.MetadataPath ([pscustomobject]@{state=$initialState;workerPid=$worker})
                Write-UnrealJsonFileAtomic $paths.RequestPath ([pscustomobject]@{execution=@{}})
                $before = [IO.File]::ReadAllText($paths.MetadataPath)
                $effects = [Collections.Generic.List[string]]::new()
                $name = "state=$initialState worker=$worker preview=$preview declined=$Decline preserves cancellation contract"
                try {
                    $result = Stop-HarnessUnrealRun -WorkspaceRoot $Root -RunId $runId -WhatIf:$preview -Confirm:$Decline
                    if ($preview -or $Decline) {
                        if ($effects.Count -or [IO.File]::ReadAllText($paths.MetadataPath) -cne $before -or $result.RecordedState -ne $initialState) { throw 'preview changed mappings, metadata, or process state' }
                    } else {
                        if ($result.RecordedState -ne 'Cancelled' -or $effects[-1] -ne 'mapping cleanup' -or $effects.Count -ne $(if ($worker -eq 123) {2} else {1})) { throw 'authorized cancellation did not finish expected cleanup' }
                    }
                    Write-Output "PASS $name"
                } catch { $Failures.Add("$name : $_"); Write-Output "FAIL $name : $_" }
            }
        }
        }
    } $scratch $failures ([bool]$DeclineConfirmation)
    if (-not $DeclineConfirmation) {
        # Exercise the real PowerShell confirmation host with explicit No answers.
        # This bounded child only runs the same filesystem fixture and effect spies.
        $start = [Diagnostics.ProcessStartInfo]::new((Join-Path $PSHOME 'pwsh.exe'))
        $start.UseShellExecute=$false; $start.CreateNoWindow=$true
        $start.RedirectStandardInput=$true; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
        foreach ($argument in @('-NoLogo','-NoProfile','-File',$PSCommandPath,'-DeclineConfirmation')) { [void]$start.ArgumentList.Add($argument) }
        $child=[Diagnostics.Process]::Start($start)
        try {
            foreach ($answer in 1..6) { $child.StandardInput.WriteLine('n') }
            $child.StandardInput.Close()
            $output=$child.StandardOutput.ReadToEnd(); $errors=$child.StandardError.ReadToEnd(); $child.WaitForExit()
            Write-Output $output
            if($child.ExitCode -ne 0){throw "Declined confirmation fixture failed: $errors"}
        } finally {$child.Dispose()}
    }
} finally {
    $resolved = [IO.Path]::GetFullPath($scratch)
    if ($resolved.StartsWith([IO.Path]::GetTempPath(), [StringComparison]::OrdinalIgnoreCase) -and [IO.Path]::GetFileName($resolved).StartsWith('unreal-cancel-safety-')) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
if ($failures.Count) { throw ($failures -join "`n") }
