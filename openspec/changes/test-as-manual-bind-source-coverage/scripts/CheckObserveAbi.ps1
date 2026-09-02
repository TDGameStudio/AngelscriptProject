# Fails when Bind Observe_* functions remain void/no-arg with local-only hold Booleans.
# Companion to AuditTestSourceImplementation.ps1. Source-semantic only; does not compile AS.
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$BindRoot = Join-Path $RepoRoot 'TestSource\Bindings'
if (-not (Test-Path -LiteralPath $BindRoot))
{
    Write-Error "Missing Bind root: $BindRoot"
}

$ObservePattern = '(?m)^\s*(?<ReturnType>[A-Za-z_][A-Za-z0-9_:<>,@&\[\]\?\s]*?)\s+(?<Name>Observe_[A-Za-z0-9_]+)\s*\((?<Parameters>[^)]*)\)\s*\{'
$HoldPattern = '(?m)^\s*bool\s+b[A-Za-z0-9_]*(?:Observation|Observations|Hold|Holds|Returned)[A-Za-z0-9_]*\s*='

$VoidNoArgWithHold = New-Object System.Collections.Generic.List[string]
$VoidNoArgObserve = New-Object System.Collections.Generic.List[string]
$HoldFiles = New-Object System.Collections.Generic.List[string]
$ObserveCount = 0
$NonVoidCount = 0

Get-ChildItem -LiteralPath $BindRoot -Recurse -Filter '*.as' | ForEach-Object {
    $Text = [System.IO.File]::ReadAllText($_.FullName)
    $Rel = $_.FullName.Substring($RepoRoot.Length).TrimStart('\', '/') -replace '\\', '/'
    $ObserveMatches = [System.Text.RegularExpressions.Regex]::Matches($Text, $ObservePattern)
    $ObserveCount += $ObserveMatches.Count
    $HoldCount = [System.Text.RegularExpressions.Regex]::Matches($Text, $HoldPattern).Count
    if ($HoldCount -gt 0)
    {
        $HoldFiles.Add("$Rel ($HoldCount)")
    }
    foreach ($Match in $ObserveMatches)
    {
        $ReturnType = $Match.Groups['ReturnType'].Value.Trim()
        $Parameters = $Match.Groups['Parameters'].Value
        $Name = $Match.Groups['Name'].Value
        if ($ReturnType -ne 'void')
        {
            $NonVoidCount += 1
            continue
        }
        if ([string]::IsNullOrWhiteSpace($Parameters))
        {
            $VoidNoArgObserve.Add("${Rel}::$Name")
            if ($HoldCount -gt 0)
            {
                $VoidNoArgWithHold.Add("${Rel}::$Name")
            }
        }
    }
}

Write-Output "Bind Observe_* functions: $ObserveCount"
Write-Output "Non-void Observe_* functions: $NonVoidCount"
Write-Output "Void/no-arg Observe_* functions: $($VoidNoArgObserve.Count)"
Write-Output "Files with discarded hold locals: $($HoldFiles.Count)"
Write-Output "Void/no-arg Observe_* that share a file with hold locals: $($VoidNoArgWithHold.Count)"

$Failed = $false
if ($VoidNoArgWithHold.Count -gt 0)
{
    $Failed = $true
    Write-Output 'FAIL: void/no-arg Observe_* still paired with local-only hold Booleans:'
    $VoidNoArgWithHold | Select-Object -First 40 | ForEach-Object { Write-Output "  $_" }
}
if ($HoldFiles.Count -gt 0)
{
    $Failed = $true
    Write-Output 'FAIL: discarded observation locals remain:'
    $HoldFiles | Select-Object -First 40 | ForEach-Object { Write-Output "  $_" }
}

if ($Failed)
{
    exit 1
}

Write-Output 'PASS: no Bind Observe_* is void/no-arg with a local-only hold Boolean.'
exit 0
