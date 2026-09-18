[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$module=Import-Module (Join-Path $PSScriptRoot '../scripts/UnrealEngineDevelop.psd1') -Force -PassThru
$failures=[Collections.Generic.List[string]]::new()
try {
    & $module {
        param($Failures)
        function Get-Process { param($ErrorAction) $fixtureProcessRecords }
        function Get-CimInstance { param($ClassName,$Filter,$ErrorAction) if($inspectionFails){throw 'fixture access denied'}; $fixtureCommandRecords }
        $cases=@(
            @{Name='empty process inventory proves quiescence';ProcessNames=@();Commands=@();Fails=$false;Throws=$false;Count=0},
            @{Name='unreadable dotnet cannot masquerade as quiescence';ProcessNames=@('dotnet');Commands=@('');Fails=$false;Throws=$true;Count=0},
            @{Name='failed process command-line inspection refuses removal';ProcessNames=@('UnrealEditor');Commands=@();Fails=$true;Throws=$true;Count=0},
            @{Name='unrelated inspectable dotnet remains irrelevant';ProcessNames=@('dotnet');Commands=@('dotnet fixture.dll');Fails=$false;Throws=$false;Count=0},
            @{Name='native UE candidate remains visible';ProcessNames=@('UnrealEditor');Commands=@('UnrealEditor fixture.uproject');Fails=$false;Throws=$false;Count=1},
            @{Name='bounded inventory truncation cannot prove quiescence';ProcessNames=@('UnrealEditor','UnrealEditor','UnrealEditor','UnrealEditor','UnrealEditor');Commands=@('UE','UE','UE','UE','UE');Fails=$false;Throws=$true;Count=0;Limit=1}
        )
        foreach($case in $cases){
            $fixtureProcessRecords=@();$fixtureCommandRecords=@();$inspectionFails=$case.Fails
            for($i=0;$i -lt $case.ProcessNames.Count;$i++){
                $fixtureProcessRecords += [pscustomobject]@{Id=3000+$i;ProcessName=$case.ProcessNames[$i];Path='C:\Fixture\engine.exe';StartTime=[DateTime]::UtcNow}
                if($i -lt $case.Commands.Count){$fixtureCommandRecords += [pscustomobject]@{ProcessId=3000+$i;CommandLine=$case.Commands[$i]}}
            }
            try {
                $message='';$result=@()
                try {$result=@(Get-HarnessUnrealProcessList -RequireComplete -Limit $(if($case.ContainsKey('Limit')){$case.Limit}else{128}))} catch {$message=$_.Exception.Message}
                if($case.Throws){if($message -notmatch 'quiescence|inspect'){throw "expected fail-closed inspection, got: $message"}}
                elseif($message -or $result.Count -ne $case.Count){throw "unexpected process inspection: $message count=$($result.Count)"}
                Write-Output "PASS $($case.Name)"
            } catch {$Failures.Add("$($case.Name): $_");Write-Output "FAIL $($case.Name): $_"}
        }
    } $failures
} finally {Remove-Module $module -Force}
if($failures.Count){throw ($failures -join "`n")}
