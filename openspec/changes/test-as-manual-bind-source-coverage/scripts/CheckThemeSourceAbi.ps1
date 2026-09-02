# Source-semantic check for TestSource theme roots (not Bindings/TestFramework).
# Fails on missing planned symbols, discarded hold locals, tautologies, and framework types.
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$PlanCsv = Join-Path $RepoRoot 'openspec\changes\test-as-manual-bind-source-coverage\inventory\planned-theme-sources.csv'
$ThemeRoots = @(
    'Language','Definitions','Containers','Feature','World','Gameplay','Optional','HotReload','Debugger'
)

if (-not (Test-Path -LiteralPath $PlanCsv))
{
    Write-Error "Missing $PlanCsv"
}

$HoldPattern = '(?m)^\s*bool\s+b[A-Za-z0-9_]*(?:Observation|Observations|Hold|Holds|Returned)[A-Za-z0-9_]*\s*='
$BoolComplement = '\(\s*(?<BoolName>b[A-Za-z_][A-Za-z0-9_]*)\s*\|\|\s*!\s*\k<BoolName>\s*\)'
$NullIdentity = '\(\s*(?<NullName>[A-Za-z_][A-Za-z0-9_\.]*)\s*==\s*nullptr\s*\|\|\s*\k<NullName>\s*!=\s*nullptr\s*\)'
$SelfEq = '\b(?<SelfName>[A-Za-z_][A-Za-z0-9_\.]*)\s*==\s*\k<SelfName>\b'
$Exhaustive = '\(\s*(?<Left>[A-Za-z_][A-Za-z0-9_\.]*)\s*!=\s*(?<Right>[A-Za-z_][A-Za-z0-9_\.]*)\s*\|\|\s*\k<Left>\s*==\s*\k<Right>\s*\)'
$Framework = 'UAngelscriptTestSuite|FAngelscriptTest'

$MissingFiles = New-Object System.Collections.Generic.List[string]
$MissingSymbols = New-Object System.Collections.Generic.List[string]
$HoldFiles = New-Object System.Collections.Generic.List[string]
$TautFiles = New-Object System.Collections.Generic.List[string]
$FrameworkFiles = New-Object System.Collections.Generic.List[string]
$Planned = 0

$PlanRows = Import-Csv -LiteralPath $PlanCsv
foreach ($Row in $PlanRows)
{
    $Planned += 1
    $Rel = $Row.TargetPath.Replace('/', '\')
    $Abs = Join-Path $RepoRoot $Rel
    if (-not (Test-Path -LiteralPath $Abs))
    {
        $MissingFiles.Add($Row.TargetPath)
        continue
    }
    $Text = [System.IO.File]::ReadAllText($Abs)
    foreach ($Symbol in @($Row.PlannedSymbols -split ';' | Where-Object { $_ }))
    {
        if ($Text.IndexOf($Symbol) -lt 0)
        {
            $MissingSymbols.Add("$($Row.TargetPath)::$Symbol")
        }
    }
    $Lines = $Text -split "`r?`n"
    $HoldHits = 0
    for ($i = 0; $i -lt $Lines.Count; $i++)
    {
        if ($Lines[$i] -notmatch $HoldPattern)
        {
            continue
        }
        $Prev = $i - 1
        while ($Prev -ge 0 -and [string]::IsNullOrWhiteSpace($Lines[$Prev])) { $Prev-- }
        if ($Prev -ge 0 -and $Lines[$Prev] -match 'UPROPERTY\s*\(')
        {
            continue
        }
        $HoldHits++
    }
    if ($HoldHits -gt 0) { $HoldFiles.Add($Row.TargetPath) }
    $Taut = ([regex]::Matches($Text, $BoolComplement)).Count +
        ([regex]::Matches($Text, $NullIdentity)).Count +
        ([regex]::Matches($Text, $SelfEq)).Count +
        ([regex]::Matches($Text, $Exhaustive)).Count
    if ($Taut -gt 0) { $TautFiles.Add("$($Row.TargetPath) taut=$Taut") }
    if ([regex]::IsMatch($Text, $Framework)) { $FrameworkFiles.Add($Row.TargetPath) }
}

$OnDisk = 0
foreach ($Root in $ThemeRoots)
{
    $Dir = Join-Path $RepoRoot ("TestSource\" + $Root)
    if (Test-Path -LiteralPath $Dir)
    {
        $OnDisk += @(Get-ChildItem -LiteralPath $Dir -Recurse -File -Filter '*.as').Count
    }
}

Write-Output "planned=$Planned on_disk_theme_as=$OnDisk missing_files=$($MissingFiles.Count) missing_symbols=$($MissingSymbols.Count) hold=$($HoldFiles.Count) taut=$($TautFiles.Count) framework_leaks=$($FrameworkFiles.Count)"
if ($MissingFiles.Count -gt 0)
{
    Write-Output 'missing files (first 20):'
    $MissingFiles | Select-Object -First 20 | ForEach-Object { Write-Output "  $_" }
}
if ($MissingSymbols.Count -gt 0)
{
    Write-Output 'missing symbols (first 20):'
    $MissingSymbols | Select-Object -First 20 | ForEach-Object { Write-Output "  $_" }
}
if ($HoldFiles.Count -gt 0) { $HoldFiles | Select-Object -First 20 | ForEach-Object { Write-Output " HOLD $_" } }
if ($TautFiles.Count -gt 0) { $TautFiles | Select-Object -First 20 | ForEach-Object { Write-Output " TAUT $_" } }
if ($FrameworkFiles.Count -gt 0) { $FrameworkFiles | ForEach-Object { Write-Output " FW $_" } }

$Detector = Join-Path $PSScriptRoot 'DetectThemeNullDeref.py'
if (-not (Test-Path -LiteralPath $Detector))
{
    Write-Error "Missing $Detector"
}
$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python)
{
    $Python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $Python)
{
    Write-Error 'python/py not found for DetectThemeNullDeref.py'
}
$NativePref = $PSNativeCommandUseErrorActionPreference
$PSNativeCommandUseErrorActionPreference = $false
$DetectLines = & $Python.Source $Detector
$DetectExit = $LASTEXITCODE
$PSNativeCommandUseErrorActionPreference = $NativePref
if ($DetectExit -gt 1)
{
    Write-Error "DetectThemeNullDeref.py failed with exit $DetectExit"
}
$NullDerefCount = 0
$NullDerefHits = New-Object System.Collections.Generic.List[string]
foreach ($Line in $DetectLines)
{
    if ($Line -match '^null_deref=(\d+)\s*$')
    {
        $NullDerefCount = [int]$Matches[1]
    }
    elseif ($Line -match '::Observe_')
    {
        $NullDerefHits.Add($Line)
    }
}
Write-Output "null_deref=$NullDerefCount"
if ($NullDerefCount -gt 0)
{
    Write-Output 'null deref Observe locals (first 20):'
    $NullDerefHits | Select-Object -First 20 | ForEach-Object { Write-Output " NULL_DEREF $_" }
}

if ($MissingFiles.Count -gt 0 -or $MissingSymbols.Count -gt 0 -or $HoldFiles.Count -gt 0 -or $TautFiles.Count -gt 0 -or $FrameworkFiles.Count -gt 0 -or $NullDerefCount -gt 0)
{
    exit 1
}
Write-Output 'PASS: theme planned symbols present; no hold locals, tautologies, framework types, or default-null A*/U* derefs.'
exit 0
