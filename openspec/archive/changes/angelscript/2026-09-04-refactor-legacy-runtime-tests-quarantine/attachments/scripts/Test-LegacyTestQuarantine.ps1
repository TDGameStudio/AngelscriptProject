[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Find-WorkspaceRoot {
    param([Parameter(Mandatory = $true)][string] $StartPath)

    $candidate = [System.IO.DirectoryInfo]::new($StartPath)
    while ($null -ne $candidate) {
        if ((Test-Path -LiteralPath (Join-Path $candidate.FullName 'AngelscriptProject.uproject') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $candidate.FullName '.git'))) {
            return $candidate.FullName
        }
        $candidate = $candidate.Parent
    }
    throw "Unable to locate the AngelscriptProject workspace above '$StartPath'."
}

function Get-CppFiles {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [scriptblock] $Filter = { $true }
    )

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Required source directory is missing: $Root"
    }
    return @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.cpp' | Where-Object $Filter)
}

function Get-HeaderFiles {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [scriptblock] $Filter = { $true }
    )

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Required source directory is missing: $Root"
    }
    return @(Get-ChildItem -LiteralPath $Root -Recurse -File -Include '*.h', '*.hpp', '*.inl' | Where-Object $Filter)
}

function Get-TextWithoutBom {
    param([Parameter(Mandatory = $true)][string] $Path)

    return [System.IO.File]::ReadAllText($Path).TrimStart([char] 0xFEFF)
}

$workspaceRoot = Find-WorkspaceRoot -StartPath $PSScriptRoot
$legacyStart = '#if WITH_ANGELSCRIPT_UNITTESTS'
$failures = [System.Collections.Generic.List[string]]::new()
$sets = [ordered]@{}
$headerSets = [ordered]@{}

$mainTestRoot = Join-Path $workspaceRoot 'Plugins/Angelscript/Source/AngelscriptTest'
$mainLegacyRoot = Join-Path $mainTestRoot 'Legacy'
$editorLegacyRoot = Join-Path $workspaceRoot 'Plugins/Angelscript/Source/AngelscriptEditor/Legacy'
$gameplayTagsLegacyRoot = Join-Path $workspaceRoot 'Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsTest/Private/Legacy'
$gasLegacyRoot = Join-Path $workspaceRoot 'Plugins/AngelscriptGAS/Source/AngelscriptGASTest/Private/Legacy'
$hostLegacyRoot = Join-Path $workspaceRoot 'Source/AngelscriptProjectTest/Legacy'

$sets.AngelscriptTest = @(Get-CppFiles -Root $mainLegacyRoot)
$sets.AngelscriptEditor = @(Get-CppFiles -Root $editorLegacyRoot)
$sets.AngelscriptGameplayTagsTest = @(Get-CppFiles -Root $gameplayTagsLegacyRoot)
$sets.AngelscriptGASTest = @(Get-CppFiles -Root $gasLegacyRoot)
$sets.AngelscriptProjectTest = @(Get-CppFiles -Root $hostLegacyRoot)

$headerSets.AngelscriptTest = @(Get-HeaderFiles -Root $mainLegacyRoot)
$headerSets.AngelscriptEditor = @(Get-HeaderFiles -Root $editorLegacyRoot)
$headerSets.AngelscriptGameplayTagsTest = @(Get-HeaderFiles -Root $gameplayTagsLegacyRoot)
$headerSets.AngelscriptGASTest = @(Get-HeaderFiles -Root $gasLegacyRoot)
$headerSets.AngelscriptProjectTest = @(Get-HeaderFiles -Root $hostLegacyRoot)

$legacyFiles = @($sets.Values | ForEach-Object { $_ } | Sort-Object FullName -Unique)
$legacyHeaders = @($headerSets.Values | ForEach-Object { $_ } | Sort-Object FullName -Unique)
$legacySourceFiles = @($legacyFiles + $legacyHeaders | Sort-Object FullName -Unique)

$ignoredDirectories = @(
    Get-Item -LiteralPath $mainLegacyRoot
    Get-Item -LiteralPath $editorLegacyRoot
    Get-Item -LiteralPath $gameplayTagsLegacyRoot
    Get-Item -LiteralPath $gasLegacyRoot
    Get-Item -LiteralPath $hostLegacyRoot
)
foreach ($directory in $ignoredDirectories) {
    $marker = Join-Path $directory.FullName '.ubtignore'
    if (-not (Test-Path -LiteralPath $marker -PathType Leaf)) {
        $failures.Add("legacy source directory is missing its UBT/UHT isolation marker: $($directory.FullName)")
    }
}

foreach ($file in $legacySourceFiles) {
    $covered = $false
    foreach ($directory in $ignoredDirectories) {
        $prefix = $directory.FullName.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        if ($file.FullName.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $covered = $true
            break
        }
    }
    if (-not $covered) {
        $failures.Add("legacy source is not below an ignored directory: $($file.FullName)")
    }
    if ((Get-TextWithoutBom -Path $file.FullName).StartsWith($legacyStart, [System.StringComparison]::Ordinal)) {
        $failures.Add("legacy source was rewritten instead of retained behind directory isolation: $($file.FullName)")
    }
}

$excludedModuleFiles = @(
    (Join-Path $workspaceRoot 'Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp'),
    (Join-Path $workspaceRoot 'Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTestModule.h'),
    # Passive ABI support referenced by generated TestJIT objects; the provider
    # module remains runtime-gated and this file registers no Automation tests.
    (Join-Path $workspaceRoot 'Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.cpp'),
    (Join-Path $workspaceRoot 'Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsTest/Private/AngelscriptGameplayTagsTestModule.cpp'),
    (Join-Path $workspaceRoot 'Plugins/AngelscriptGAS/Source/AngelscriptGASTest/Private/AngelscriptGASTestModule.cpp')
)
foreach ($path in $excludedModuleFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $failures.Add("excluded module source is missing: $path")
        continue
    }
    if ((Get-TextWithoutBom -Path $path).StartsWith($legacyStart, [System.StringComparison]::Ordinal)) {
        $failures.Add("module implementation was incorrectly quarantined: $path")
    }
}

$replacementFiles = @(Get-CppFiles -Root (Join-Path $mainTestRoot 'NewVersion'))
if ($replacementFiles.Count -eq 0) {
    $failures.Add('no replacement test translation unit exists under AngelscriptTest/NewVersion')
}
foreach ($file in $replacementFiles) {
    $text = Get-TextWithoutBom -Path $file.FullName
    if ($text.StartsWith($legacyStart, [System.StringComparison]::Ordinal)) {
        $failures.Add("replacement test was incorrectly quarantined: $($file.FullName)")
    }
    if (-not $text.Contains('#if WITH_ANGELSCRIPT_TESTS', [System.StringComparison]::Ordinal)) {
        $failures.Add("replacement test does not use WITH_ANGELSCRIPT_TESTS: $($file.FullName)")
    }
}

$generatedRoots = @(
    (Join-Path $workspaceRoot 'Plugins/Angelscript/Source/AngelscriptTestJIT/Generated'),
    (Join-Path $workspaceRoot 'Source/AngelscriptJIT/Generated')
)
$generatedFiles = @()
foreach ($root in $generatedRoots) {
    if (Test-Path -LiteralPath $root -PathType Container) {
        $generatedFiles += @(Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName)
    }
}
foreach ($file in $generatedFiles) {
    if ((Get-TextWithoutBom -Path $file.FullName).StartsWith($legacyStart, [System.StringComparison]::Ordinal)) {
        $failures.Add("generated JIT artifact was incorrectly quarantined: $($file.FullName)")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "ERROR: $_" -ForegroundColor Red }
    throw "Legacy test quarantine audit failed with $($failures.Count) problem(s)."
}

$counts = @($sets.GetEnumerator() | ForEach-Object { "$($_.Key)=$(@($_.Value).Count)" }) -join ', '
$headerCounts = @($headerSets.GetEnumerator() | ForEach-Object { "$($_.Key)=$(@($_.Value).Count)" }) -join ', '
Write-Host "Legacy test quarantine audit passed: $($legacyFiles.Count) translation units ($counts); $($legacyHeaders.Count) headers ($headerCounts); ignored-directories=$($ignoredDirectories.Count); replacements=$($replacementFiles.Count); generated-exclusions=$($generatedFiles.Count)."
