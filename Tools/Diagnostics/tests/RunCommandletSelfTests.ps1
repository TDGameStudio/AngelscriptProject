[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Assert-Throws {
    param([scriptblock]$Body, [string]$Message)
    try {
        & $Body
    }
    catch {
        return
    }
    throw $Message
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$helperPath = Join-Path $repoRoot 'Tools\Shared\CommandletProjectUtils.ps1'
if (Test-Path -LiteralPath $helperPath -PathType Leaf) {
    . $helperPath
}

$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-commandlet-selftest-' + [guid]::NewGuid().ToString('N'))
try {
    $externalRoot = Join-Path $testRoot 'Saved\ExternalConsumer'
    New-Item -ItemType Directory -Path $externalRoot -Force | Out-Null
    $configuredProject = Join-Path $testRoot 'Host.uproject'
    $externalProject = Join-Path $externalRoot 'ExternalConsumer.uproject'
    [System.IO.File]::WriteAllText($configuredProject, '{}')
    [System.IO.File]::WriteAllText($externalProject, '{}')

    $defaultContext = Resolve-AngelscriptCommandletProjectContext `
        -RepositoryRoot $testRoot `
        -ConfiguredProjectFile $configuredProject
    Assert-Equal $configuredProject $defaultContext.ProjectFile `
        'No override should retain the configured project.'
    Assert-Equal $testRoot $defaultContext.ProjectRoot `
        'Configured project root should be derived from the project file.'

    $relativeExternalProject = [System.IO.Path]::GetRelativePath($testRoot, $externalProject)
    $externalContext = Resolve-AngelscriptCommandletProjectContext `
        -RepositoryRoot $testRoot `
        -ConfiguredProjectFile $configuredProject `
        -ProjectFileOverride $relativeExternalProject
    Assert-Equal $externalProject $externalContext.ProjectFile `
        'Relative override should resolve from the repository root.'
    Assert-Equal $externalRoot $externalContext.ProjectRoot `
        'External project root should be derived from the override.'
    Assert-Equal (Join-Path $externalRoot 'Intermediate\TargetInfo.json') $externalContext.TargetInfoPath `
        'TargetInfo should belong to the selected external project.'

    Assert-Throws -Body {
        Resolve-AngelscriptCommandletProjectContext `
            -RepositoryRoot $testRoot `
            -ConfiguredProjectFile $configuredProject `
            -ProjectFileOverride 'Missing.txt'
    } -Message 'Invalid external project paths should be rejected.'

    $arguments = New-AngelscriptCommandletArgumentList `
        -ProjectFile $externalProject `
        -Commandlet 'AngelscriptOfflineExport' `
        -LogPath (Join-Path $testRoot 'Commandlet.log') `
        -ExtraArgs @('-BundleKind=Project', '-Output=Fixture')
    Assert-Equal $externalProject $arguments[0] `
        'The selected project must be the first Unreal command argument.'
    Assert-True ($arguments -contains '-run=AngelscriptOfflineExport') `
        'The commandlet name should be retained.'
    Assert-True ($arguments -contains '-NullRHI') `
        'Headless commandlets should retain NullRHI by default.'
    Assert-True ($arguments -contains '-BundleKind=Project') `
        'Extra arguments should be forwarded.'

    $extraArgumentsFile = Join-Path $testRoot 'extra-arguments.json'
    [System.IO.File]::WriteAllText(
        $extraArgumentsFile,
        '["-BundleKind=Project","-Output=Fixture"]')
    $fileArguments = @(Resolve-AngelscriptCommandletExtraArguments `
            -ArgumentsFile $extraArgumentsFile)
    Assert-Equal 2 $fileArguments.Count `
        'Structured extra-argument files should retain every argument.'
    Assert-Equal '-BundleKind=Project' $fileArguments[0] `
        'Structured extra-argument files should retain argument order.'
    Assert-Equal '-Output=Fixture' $fileArguments[1] `
        'Dash-prefixed output arguments should not be parsed as runner parameters.'

    $windowsPowerShellCommand = @"
. '$helperPath'
`$resolved = @(Resolve-AngelscriptCommandletExtraArguments -ArgumentsFile '$extraArgumentsFile')
`$resolved | ForEach-Object { Write-Output `$_ }
"@
    $windowsPowerShellArguments = @(
        '-NoProfile'
        '-NonInteractive'
        '-Command'
        $windowsPowerShellCommand
    )
    $windowsPowerShellResult = @(& powershell.exe @windowsPowerShellArguments)
    Assert-Equal 0 $LASTEXITCODE `
        'Structured extra arguments should parse under Windows PowerShell 5.1.'
    Assert-Equal 2 $windowsPowerShellResult.Count `
        'Windows PowerShell 5.1 should flatten the top-level JSON argument array.'

    Assert-Equal 0 (Resolve-AngelscriptCommandletExitCode -ProcessExitCode 0) `
        'Successful child process should map to success.'
    Assert-Equal 1 (Resolve-AngelscriptCommandletExitCode -ProcessExitCode 17) `
        'Failed child process should map to runner failure.'
    Assert-Equal 2 (Resolve-AngelscriptCommandletExitCode -ProcessExitCode 0 -TimedOut) `
        'Timeout should take precedence over the child exit code.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Host 'RunCommandlet self-tests passed.'
