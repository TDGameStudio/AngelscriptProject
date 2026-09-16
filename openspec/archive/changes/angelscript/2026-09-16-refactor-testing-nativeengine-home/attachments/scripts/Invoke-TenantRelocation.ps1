# Purpose: relocate the four NewVersion tenants to module-root homes and nest
# NativeEngine TestDir tokens. Does not launch Unreal.
# Dependencies: git, the current Angelscript submodule working tree.

[CmdletBinding()]
param(
    [string] $WorkspaceRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pluginRoot = Join-Path $WorkspaceRoot 'Plugins/Angelscript'
$testRoot = Join-Path $pluginRoot 'Source/AngelscriptTest'
$newVersion = Join-Path $testRoot 'NewVersion'
$nativeSrc = Join-Path $newVersion 'NativeEngine'
$nativeDst = Join-Path $testRoot 'NativeEngine'

function Test-GitTracked {
    param([string] $Repo, [string] $Relative)
    git -C $Repo ls-files --error-unmatch -- $Relative 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Move-TreeItem {
    param(
        [Parameter(Mandatory = $true)][string] $From,
        [Parameter(Mandatory = $true)][string] $To
    )

    if (-not (Test-Path -LiteralPath $From)) {
        return
    }
    $destParent = Split-Path -Parent $To
    if (-not (Test-Path -LiteralPath $destParent)) {
        New-Item -ItemType Directory -Path $destParent | Out-Null
    }
    if (Test-Path -LiteralPath $To) {
        $destItems = @(Get-ChildItem -LiteralPath $To -Force)
        if ($destItems.Count -eq 0) {
            Remove-Item -LiteralPath $To -Force
        }
        else {
            throw "Move destination already exists: $To"
        }
    }

    $fromRel = [System.IO.Path]::GetRelativePath($pluginRoot, $From).Replace('\', '/')
    $toRel = [System.IO.Path]::GetRelativePath($pluginRoot, $To).Replace('\', '/')
    if (Test-GitTracked -Repo $pluginRoot -Relative $fromRel) {
        git -C $pluginRoot mv -- $fromRel $toRel
        if ($LASTEXITCODE -ne 0) { throw "git mv failed: $fromRel -> $toRel" }
        return
    }
    Move-Item -LiteralPath $From -Destination $To
}

function Move-Children {
    param(
        [Parameter(Mandatory = $true)][string] $FromDir,
        [Parameter(Mandatory = $true)][string] $ToDir
    )

    if (-not (Test-Path -LiteralPath $FromDir)) { return }
    if (-not (Test-Path -LiteralPath $ToDir)) {
        New-Item -ItemType Directory -Path $ToDir | Out-Null
    }
    Get-ChildItem -LiteralPath $FromDir -Force | ForEach-Object {
        Move-TreeItem -From $_.FullName -To (Join-Path $ToDir $_.Name)
    }
    if ((Get-ChildItem -LiteralPath $FromDir -Force | Measure-Object).Count -eq 0) {
        Remove-Item -LiteralPath $FromDir -Force
    }
}

if (-not (Test-Path -LiteralPath $nativeSrc)) {
    throw "NewVersion NativeEngine is already gone; refuse to re-run relocation."
}

New-Item -ItemType Directory -Force -Path $nativeDst | Out-Null

$wholesale = @{
    AST           = 'AST'
    VM            = 'VM'
    Diagnostics   = 'Diagnostics'
    Tooling       = 'Tooling'
    Definitions   = 'Definitions'
    Identity      = 'Identity'
    TypeOwnership = 'TypeOwnership'
    Registration  = 'Registration'
}
foreach ($pair in $wholesale.GetEnumerator()) {
    Move-TreeItem -From (Join-Path $nativeSrc $pair.Key) -To (Join-Path $nativeDst $pair.Value)
}

Move-Children -FromDir (Join-Path $nativeSrc 'Preprocessor') -ToDir (Join-Path $nativeDst 'Lexer')
Move-Children -FromDir (Join-Path $nativeSrc 'Declarations') -ToDir (Join-Path $nativeDst 'Sema')
Move-Children -FromDir (Join-Path $nativeSrc 'Bodies') -ToDir (Join-Path $nativeDst 'Sema')

$compileDir = Join-Path $nativeDst 'Compile'
New-Item -ItemType Directory -Force -Path $compileDir | Out-Null
foreach ($name in @('Builder', 'ModuleGraph', 'Reflection', 'Api')) {
    Move-Children -FromDir (Join-Path $nativeSrc $name) -ToDir $compileDir
}
Move-TreeItem -From (Join-Path $nativeSrc 'CompileLifecycleTests.cpp') -To (Join-Path $compileDir 'CompileLifecycleTests.cpp')

$sourceExec = Join-Path $nativeDst 'SourceExecution'
Move-TreeItem -From (Join-Path $nativeSrc 'Compiler') -To $sourceExec

$basic = Join-Path $nativeDst 'Basic'
New-Item -ItemType Directory -Force -Path $basic | Out-Null
Move-TreeItem -From (Join-Path $nativeSrc 'NativeEngineTestFoundationTests.cpp') -To (Join-Path $basic 'NativeEngineTestFoundationTests.cpp')
if (Test-Path -LiteralPath (Join-Path $nativeSrc 'SourceInputTests.cpp')) {
    Move-TreeItem -From (Join-Path $nativeSrc 'SourceInputTests.cpp') -To (Join-Path $basic 'SourceInputTests.cpp')
}

Move-TreeItem -From (Join-Path $nativeSrc 'SourceDiagnosticsTests.cpp') -To (Join-Path $nativeDst 'Diagnostics/SourceDiagnosticsTests.cpp')
Move-TreeItem -From (Join-Path $nativeSrc 'NativeEngineTestSupport.h') -To (Join-Path $nativeDst 'NativeEngineTestSupport.h')

$sema = Join-Path $nativeDst 'Sema'
$surface = Join-Path $nativeSrc 'LanguageSurface'
Move-TreeItem -From (Join-Path $surface 'SyntaxTests.cpp') -To (Join-Path $sema 'SyntaxTests.cpp')
Move-TreeItem -From (Join-Path $surface 'LambdaTests.cpp') -To (Join-Path $sema 'LambdaTests.cpp')
Move-TreeItem -From (Join-Path $surface 'SDKTests.cpp') -To (Join-Path $compileDir 'SDKTests.cpp')
Move-TreeItem -From (Join-Path $surface 'CallableSDKTests.cpp') -To (Join-Path $compileDir 'CallableSDKTests.cpp')
Move-TreeItem -From (Join-Path $surface 'ReflectionTests.cpp') -To (Join-Path $compileDir 'LanguageSurfaceReflectionTests.cpp')
if ((Get-ChildItem -LiteralPath $surface -Force | Measure-Object).Count -eq 0) {
    Remove-Item -LiteralPath $surface -Force
}

Move-TreeItem -From (Join-Path $newVersion 'Framework') -To (Join-Path $testRoot 'Framework')
Move-TreeItem -From (Join-Path $newVersion 'FrameworkTests') -To (Join-Path $testRoot 'FrameworkTests')
Move-TreeItem -From (Join-Path $newVersion 'Bindings') -To (Join-Path $testRoot 'Bindings')
New-Item -ItemType Directory -Force -Path (Join-Path $testRoot 'Baseline') | Out-Null
Move-TreeItem -From (Join-Path $newVersion 'AngelscriptIsolationBaselineTests.cpp') -To (Join-Path $testRoot 'Baseline/AngelscriptIsolationBaselineTests.cpp')

if (Test-Path -LiteralPath $nativeSrc) {
    $left = @(Get-ChildItem -LiteralPath $nativeSrc -Recurse -Force)
    if ($left.Count -gt 0) {
        throw ("Unmoved NewVersion/NativeEngine items:`n" + ($left.FullName -join "`n"))
    }
    Remove-Item -LiteralPath $nativeSrc -Recurse -Force
}
if (Test-Path -LiteralPath $newVersion) {
    $leftNv = @(Get-ChildItem -LiteralPath $newVersion -Recurse -Force)
    if ($leftNv.Count -gt 0) {
        throw ("Unmoved NewVersion items:`n" + ($leftNv.FullName -join "`n"))
    }
    Remove-Item -LiteralPath $newVersion -Recurse -Force
}

function Get-LayerFromPath {
    param([string] $Path)
    switch -Regex ($Path.Replace('\', '/')) {
        '/NativeEngine/Basic/' { return 'Basic' }
        '/NativeEngine/Lexer/' { return 'Lexer' }
        '/NativeEngine/Parser/' { return 'Parser' }
        '/NativeEngine/AST/' { return 'AST' }
        '/NativeEngine/Sema/' { return 'Sema' }
        '/NativeEngine/Compile/' { return 'Compile' }
        '/NativeEngine/SourceExecution/' { return 'SourceExecution' }
        '/NativeEngine/Diagnostics/' { return 'Diagnostics' }
        '/NativeEngine/Tooling/' { return 'Tooling' }
        '/NativeEngine/Definitions/' { return 'Definitions' }
        '/NativeEngine/Identity/' { return 'Identity' }
        '/NativeEngine/TypeOwnership/' { return 'TypeOwnership' }
        '/NativeEngine/Registration/' { return 'Registration' }
        '/NativeEngine/VM/' { return 'VM' }
        default { return $null }
    }
}

$nativeFiles = @(Get-ChildItem -LiteralPath $nativeDst -Recurse -File -Include *.cpp, *.h, *.hpp)
foreach ($file in $nativeFiles) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $updated = $text
    $layer = Get-LayerFromPath $file.FullName
    if ($layer -and $file.Extension -ceq '.cpp') {
        $updated = $updated.Replace('"Angelscript.UnitTest.NativeEngine.LanguageSurface"', "`"Angelscript.UnitTest.NativeEngine.$layer`"")
        $updated = [regex]::Replace(
            $updated,
            '"Angelscript\.UnitTest\.NativeEngine"(?!\.)',
            "`"Angelscript.UnitTest.NativeEngine.$layer`"")
    }
    $updated = $updated.Replace('#include "../Compiler/NativeSourceExecutionTestSupport.h"', '#include "NativeEngine/SourceExecution/NativeSourceExecutionTestSupport.h"')
    $updated = $updated.Replace('#include "../Preprocessor/NativePreprocessorTestSupport.h"', '#include "NativeEngine/Lexer/NativePreprocessorTestSupport.h"')
    $updated = $updated.Replace('#include "../NativeEngineTestSupport.h"', '#include "NativeEngine/NativeEngineTestSupport.h"')
    $updated = $updated.Replace('#include "NativeEngineTestSupport.h"', '#include "NativeEngine/NativeEngineTestSupport.h"')
    if ($updated -cne $text) {
        [System.IO.File]::WriteAllText($file.FullName, $updated)
    }
}

$rewriteRoots = @(
    $testRoot
    (Join-Path $pluginRoot 'Source/AngelscriptTestJIT')
    (Join-Path $WorkspaceRoot 'AngelscriptTestCode')
)
foreach ($root in $rewriteRoots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    Get-ChildItem -LiteralPath $root -Recurse -File -Include *.cpp, *.h, *.hpp, *.py | ForEach-Object {
        $text = [System.IO.File]::ReadAllText($_.FullName)
        $updated = $text.Replace('NewVersion/Framework/', 'Framework/')
        $updated = $updated.Replace('NewVersion/FrameworkTests/', 'FrameworkTests/')
        if ($updated -cne $text) {
            [System.IO.File]::WriteAllText($_.FullName, $updated)
        }
    }
}

$builderStages = Join-Path $compileDir 'BuilderStageTests.cpp'
if (Test-Path -LiteralPath $builderStages) {
    $text = [System.IO.File]::ReadAllText($builderStages)
    $updated = $text.Replace('TEST_CLASS_WITH_FLAGS(Builder,', 'TEST_CLASS_WITH_FLAGS(BuilderStages,')
    if ($updated -cne $text) {
        [System.IO.File]::WriteAllText($builderStages, $updated)
    }
}

Write-Output 'Tenant relocation applied.'
