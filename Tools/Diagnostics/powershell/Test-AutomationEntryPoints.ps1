[CmdletBinding()]
param(
    [string]$ProjectRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\Shared\UnrealCommandUtils.ps1')

function Resolve-ProjectRoot {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    }

    return Normalize-PathValue -Path $Path
}

function Get-AutomationTestNames {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot
    )

    $roots = @(
        'Plugins\Angelscript\Source\AngelscriptTest',
        'Plugins\Angelscript\Source\AngelscriptRuntime\Tests',
        'Plugins\Angelscript\Source\AngelscriptEditor\Tests'
    )

    $names = @()
    $testNamePattern = 'IMPLEMENT_(?:SIMPLE|COMPLEX)_AUTOMATION_TEST\s*\(\s*[^,]+,\s*"(Angelscript\.[^"]+)"'
    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::Singleline

    foreach ($relativeRoot in $roots) {
        $root = Join-Path $ResolvedProjectRoot $relativeRoot
        if (-not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }

        foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Include '*.cpp', '*.h') {
            $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
            foreach ($match in [regex]::Matches($content, $testNamePattern, $regexOptions)) {
                $names += [regex]::Replace($match.Value, '^.*"(Angelscript\.[^"]+)".*$', '$1', $regexOptions)
            }
        }
    }

    return @($names | Sort-Object -Unique)
}

function Get-GroupEntryPointPrefixes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot
    )

    $configPath = Join-Path $ResolvedProjectRoot 'Config\DefaultEngine.ini'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return @()
    }

    $prefixes = @()
    foreach ($line in Get-Content -LiteralPath $configPath -Encoding UTF8) {
        $groupMatch = [regex]::Match($line, '\+Groups=\(Name="([^"]+)"')
        if (-not $groupMatch.Success) {
            continue
        }

        $groupName = [regex]::Replace($groupMatch.Value, '^\+Groups=\(Name="([^"]+)".*$', '$1')
        foreach ($match in [regex]::Matches($line, 'Contains="([^"]+)"')) {
            $prefixes += [PSCustomObject]@{
                    Kind   = 'Group'
                    Name   = $groupName
                    Prefix = [regex]::Replace($match.Value, '^Contains="([^"]+)".*$', '$1')
                }
        }
    }

    return @($prefixes)
}

function Get-SuiteEntryPointPrefixes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot
    )

    $suiteScriptPath = Join-Path $ResolvedProjectRoot 'Tools\RunTestSuite.ps1'
    if (-not (Test-Path -LiteralPath $suiteScriptPath -PathType Leaf)) {
        return @()
    }

    $prefixes = @()
    $currentSuite = '<unknown>'
    foreach ($line in Get-Content -LiteralPath $suiteScriptPath -Encoding UTF8) {
        $suiteMatch = [regex]::Match($line, '^\s*"([^"]+)"\s*=\s*@\(')
        if ($suiteMatch.Success) {
            $currentSuite = [regex]::Replace($suiteMatch.Value, '^\s*"([^"]+)".*$', '$1')
            continue
        }

        $prefixMatch = [regex]::Match($line, 'Prefix\s*=\s*"([^"]+)"')
        if ($prefixMatch.Success) {
            $prefixes += [PSCustomObject]@{
                    Kind   = 'Suite'
                    Name   = $currentSuite
                    Prefix = [regex]::Replace($prefixMatch.Value, '^.*Prefix\s*=\s*"([^"]+)".*$', '$1')
                }
        }
    }

    return @($prefixes)
}

function Test-PrefixMatchesAnyTest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,

        [Parameter(Mandatory = $true)]
        [string[]]$TestNames
    )

    foreach ($testName in $TestNames) {
        if ($testName.StartsWith($Prefix, [System.StringComparison]::Ordinal)) {
            return $true
        }
    }

    return $false
}

$resolvedProjectRoot = Resolve-ProjectRoot -Path $ProjectRoot
$testNames = @(Get-AutomationTestNames -ResolvedProjectRoot $resolvedProjectRoot)
$entryPoints = @()
$entryPoints += @(Get-GroupEntryPointPrefixes -ResolvedProjectRoot $resolvedProjectRoot)
$entryPoints += @(Get-SuiteEntryPointPrefixes -ResolvedProjectRoot $resolvedProjectRoot)

$failures = @()

if ($testNames.Count -eq 0) {
    $failures += 'No Automation test names were found under Plugins\Angelscript\Source.'
}

foreach ($entryPoint in $entryPoints) {
    $source = '{0}:{1}' -f $entryPoint.Kind, $entryPoint.Name
    $prefix = [string]$entryPoint.Prefix

    if ($prefix.StartsWith('Angelscript.TestModule.Native', [System.StringComparison]::Ordinal)) {
        $failures += ('{0} uses stale Native prefix: {1}' -f $source, $prefix)
        continue
    }

    if (-not (Test-PrefixMatchesAnyTest -Prefix $prefix -TestNames $testNames)) {
        $failures += ('{0} prefix matches no Automation tests: {1}' -f $source, $prefix)
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Automation entry point validation failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host ("- {0}" -f $failure)
    }
    exit 1
}

Write-Host ('Automation entry point validation passed. Tests={0} EntryPoints={1}' -f $testNames.Count, $entryPoints.Count)
exit 0
