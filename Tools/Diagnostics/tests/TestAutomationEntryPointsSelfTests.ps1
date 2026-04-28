[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]
        $Expected,

        [Parameter(Mandatory = $true)]
        $Actual,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Invoke-CapturedProcess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $quotedArguments = foreach ($argument in $ArgumentList) {
        if ($argument -match '[\s"]') {
            '"{0}"' -f ($argument -replace '"', '\"')
        }
        else {
            $argument
        }
    }

    $startInfo.Arguments = ($quotedArguments -join ' ')

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
    }
}

function Invoke-TestCase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Body
    )

    Write-Host ("[test] {0}" -f $Name)
    & $Body
    Write-Host ("[pass] {0}" -f $Name) -ForegroundColor Green
}

function Remove-TestDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $normalizedBase = [System.IO.Path]::GetFullPath($BasePath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar)
    $normalizedTarget = [System.IO.Path]::GetFullPath($TargetPath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar)
    $isWithinBase = $normalizedTarget.StartsWith(
        $normalizedBase + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase
    ) -or $normalizedTarget.Equals($normalizedBase, [System.StringComparison]::OrdinalIgnoreCase)

    if (-not $isWithinBase) {
        throw "Refusing to remove path outside test root: $normalizedTarget"
    }

    if (Test-Path -LiteralPath $normalizedTarget) {
        Remove-Item -LiteralPath $normalizedTarget -Recurse -Force
    }
}

function New-AutomationEntryPointFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string]$GroupPrefix,

        [Parameter(Mandatory = $true)]
        [string]$SuitePrefix
    )

    $configDirectory = Join-Path $ProjectRoot 'Config'
    $testDirectory = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
    $toolsDirectory = Join-Path $ProjectRoot 'Tools'
    New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $testDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $toolsDirectory -Force | Out-Null

    Set-Content -LiteralPath (Join-Path $configDirectory 'DefaultEngine.ini') -Encoding UTF8 -Value @"
[/Script/AutomationController.AutomationControllerSettings]
+Groups=(Name="AngelscriptNative",Filters=((Contains="$GroupPrefix",MatchFromStart=true)))
"@

    Set-Content -LiteralPath (Join-Path $toolsDirectory 'RunTestSuite.ps1') -Encoding UTF8 -Value @"
`$suiteDefinitions = [ordered]@{
    "NativeCore" = @(
        @{ Prefix = "$SuitePrefix"; Label = "Native" }
    )
}
"@

    Set-Content -LiteralPath (Join-Path $testDirectory 'AngelscriptNativeSmokeTest.cpp') -Encoding UTF8 -Value @"
#include "Misc/AutomationTest.h"
#if WITH_DEV_AUTOMATION_TESTS
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FAngelscriptNativeSmokeTest,
    "Angelscript.TestModule.AngelScriptSDK.Smoke",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
#endif
"@
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$diagnosticScript = Join-Path $repoRoot 'Tools\Diagnostics\powershell\Test-AutomationEntryPoints.ps1'
$diagnosticBatch = Join-Path $repoRoot 'Tools\Diagnostics\Test-AutomationEntryPoints.bat'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('automation-entrypoints-test-' + [System.Guid]::NewGuid().ToString('N'))

Invoke-TestCase -Name 'RequiredFilesExist' -Body {
    Assert-True -Condition (Test-Path -LiteralPath $diagnosticScript -PathType Leaf) `
        -Message 'Test-AutomationEntryPoints.ps1 should exist.'
    Assert-True -Condition (Test-Path -LiteralPath $diagnosticBatch -PathType Leaf) `
        -Message 'Test-AutomationEntryPoints.bat should exist.'
}

Invoke-TestCase -Name 'DetectsStaleNativePrefixes' -Body {
    $fixtureRoot = Join-Path $testRoot 'broken'
    New-AutomationEntryPointFixture `
        -ProjectRoot $fixtureRoot `
        -GroupPrefix 'Angelscript.TestModule.Native.' `
        -SuitePrefix 'Angelscript.TestModule.Native'

    $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $diagnosticScript,
        '-ProjectRoot', $fixtureRoot
    ) -WorkingDirectory $repoRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 1 -Actual $run.ExitCode `
        -Message ('Stale Native prefixes should fail validation. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'Angelscript\.TestModule\.Native') `
        -Message ('Failure output should identify the stale Native prefix. Output: {0}' -f $combined)
}

Invoke-TestCase -Name 'AcceptsAngelScriptSdkPrefixes' -Body {
    $fixtureRoot = Join-Path $testRoot 'fixed'
    New-AutomationEntryPointFixture `
        -ProjectRoot $fixtureRoot `
        -GroupPrefix 'Angelscript.TestModule.AngelScriptSDK.' `
        -SuitePrefix 'Angelscript.TestModule.AngelScriptSDK'

    $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $diagnosticScript,
        '-ProjectRoot', $fixtureRoot
    ) -WorkingDirectory $repoRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 0 -Actual $run.ExitCode `
        -Message ('AngelScriptSDK prefixes should pass validation. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'Automation entry point validation passed') `
        -Message ('Passing output should confirm validation. Output: {0}' -f $combined)
}

Invoke-TestCase -Name 'CurrentRepositoryHasValidEntryPoints' -Body {
    $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $diagnosticScript,
        '-ProjectRoot', $repoRoot
    ) -WorkingDirectory $repoRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 0 -Actual $run.ExitCode `
        -Message ('Current repository entry points should pass validation. Output: {0}' -f $combined)
}

Remove-TestDirectory -BasePath ([System.IO.Path]::GetTempPath()) -TargetPath $testRoot
Write-Host 'Automation entry point self-tests passed.'
