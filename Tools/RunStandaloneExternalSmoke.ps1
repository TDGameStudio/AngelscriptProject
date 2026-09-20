[CmdletBinding()]
param(
    [string]$ReleaseArchive = '',

    [int]$TimeoutMs = 1200000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
. (Join-Path $PSScriptRoot 'Shared\StandaloneExternalSmokeUtils.ps1')

$resolvedTimeoutMs = Resolve-TimeoutMs `
    -RequestedTimeoutMs $TimeoutMs `
    -DefaultTimeoutMs 1200000 `
    -ParameterName 'TimeoutMs'
$allowedRoot = Join-Path $repositoryRoot 'Saved\StandaloneExternalSmoke'
$runId = '{0}_{1}' -f (Get-Date -Format 'yyyyMMdd_HHmmss_fff'), ([guid]::NewGuid().ToString('N').Substring(0, 8))
$runRoot = Assert-AngelscriptExternalSmokePath `
    -AllowedRoot $allowedRoot `
    -CandidatePath (Join-Path $allowedRoot $runId)
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null

if ([string]::IsNullOrWhiteSpace($ReleaseArchive)) {
    $ReleaseArchive = Join-Path $repositoryRoot `
        'Plugins\Angelscript\AngelscriptLSP\out\build\win64-msvc\package\Release\as-standalone-win64.zip'
}
$ReleaseArchive = [System.IO.Path]::GetFullPath($ReleaseArchive)
if (-not (Test-Path -LiteralPath $ReleaseArchive -PathType Leaf)) {
    throw "Standalone Release archive was not found: $ReleaseArchive. Run the StandaloneRelease suite first."
}

$project = New-AngelscriptExternalConsumerProject `
    -RepositoryRoot $repositoryRoot `
    -RunRoot $runRoot `
    -ProjectName 'AngelscriptStandaloneExternalConsumer'
$commandletRunner = Join-Path $PSScriptRoot 'RunCommandlet.ps1'
$commandletOutputRoot = Join-Path $runRoot 'CommandletEvidence'

function Invoke-ExternalProjectExport {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string[]]$ExportArguments
    )

    $extraArgumentsFile = Join-Path $runRoot "$Label-extra-arguments.json"
    Write-Utf8JsonFile -Path $extraArgumentsFile -Value @($ExportArguments) -Depth 3
    $runnerArguments = @(
        '-NoProfile'
        '-ExecutionPolicy', 'Bypass'
        '-File', $commandletRunner
        '-Commandlet', 'AngelscriptOfflineExport'
        '-ProjectFile', $project.ProjectFile
        '-Label', $Label
        '-OutputRoot', $commandletOutputRoot
        '-TimeoutMs', $resolvedTimeoutMs
        '-ExtraArgsFile', $extraArgumentsFile
    )
    & powershell.exe @runnerArguments | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "External project export '$Label' failed with runner exit code $LASTEXITCODE."
    }
}

Write-Host '================================================================'
Write-Host 'Angelscript Standalone External Consumer Smoke'
Write-Host '================================================================'
Write-Host ('RunRoot       : {0}' -f $runRoot)
Write-Host ('ProjectFile   : {0}' -f $project.ProjectFile)
Write-Host ('ReleaseArchive: {0}' -f $ReleaseArchive)
Write-Host '----------------------------------------------------------------'

Invoke-ExternalProjectExport `
    -Label 'standalone-external-default-output' `
    -ExportArguments @('-BundleKind=Project')
$defaultBundle = Join-Path $project.ProjectRoot 'Saved\AngelscriptStandalone\project'
if (-not (Test-Path -LiteralPath $defaultBundle -PathType Container)) {
    throw "The external Commandlet did not use its project-local default output: $defaultBundle"
}

$explicitBundle = Join-Path $runRoot 'explicit-project-bundle'
Invoke-ExternalProjectExport `
    -Label 'standalone-external-explicit-output' `
    -ExportArguments @(
        '-BundleKind=Project'
        "-Output=$explicitBundle"
    )

$bundleComparison = Compare-AngelscriptExternalProjectBundles `
    -FirstBundle $defaultBundle `
    -SecondBundle $explicitBundle `
    -ExpectedProjectName $project.ProjectName `
    -ForbiddenModuleName 'AngelscriptProject' `
    -ForbiddenMachinePaths @($repositoryRoot, $project.ProjectRoot, $runRoot)

$installedRoot = Join-Path $runRoot 'InstalledPackage'
Expand-Archive -LiteralPath $ReleaseArchive -DestinationPath $installedRoot
$installedExecutables = @(
    Get-ChildItem -LiteralPath $installedRoot -Recurse -Filter 'as-standalone.exe' -File
)
if ($installedExecutables.Count -ne 1) {
    throw "Expected exactly one installed as-standalone.exe, found $($installedExecutables.Count)."
}
$installedExecutable = $installedExecutables[0].FullName

$compileOutput = Join-Path $runRoot 'CompileOutput'
$compileLog = Join-Path $runRoot 'InstalledCli.log'
$compileArguments = @(
    'compile'
    '--dialect', 'ue'
    '--script-root', $project.ScriptRoot
    '--entry', 'ExternalConsumerSmoke.as'
    '--bundle', $explicitBundle
    '--output', $compileOutput
    '--diagnostics', 'json'
    '--emit-bytecode'
)
$compileResult = Invoke-StreamingProcess `
    -FilePath $installedExecutable `
    -ArgumentList $compileArguments `
    -WorkingDirectory $project.ProjectRoot `
    -TimeoutMs $resolvedTimeoutMs `
    -LogPath $compileLog `
    -Label 'standalone-external-installed-cli'
if ($compileResult.ExitCode -ne 0) {
    throw "Installed Standalone CLI failed with exit code $($compileResult.ExitCode). See $compileLog"
}

$validatedResult = Test-AngelscriptExternalCompileResult `
    -ResultPath (Join-Path $compileOutput 'result.json') `
    -ExpectedBundleIdentity $bundleComparison.BundleIdentity `
    -ExpectedBundlePath $explicitBundle

$summaryPath = Join-Path $runRoot 'Summary.json'
Write-Utf8JsonFile -Path $summaryPath -Value ([ordered]@{
        Status = 'Passed'
        RunRoot = $runRoot
        ProjectFile = $project.ProjectFile
        ReleaseArchive = $ReleaseArchive
        ReleaseArchiveSha256 = Get-AngelscriptExternalSmokeSha256 -Path $ReleaseArchive
        InstalledExecutable = $installedExecutable
        DefaultBundle = $defaultBundle
        ExplicitBundle = $explicitBundle
        BundleIdentity = $bundleComparison.BundleIdentity
        BundleFileHashes = $bundleComparison.FileHashes
        CompileOutput = $compileOutput
        CompileResultStatus = $validatedResult.status
        CompileProfile = $validatedResult.profile
        CompileBundleKind = $validatedResult.bundle.kind
        CompileBundleIdentity = $validatedResult.bundle.identity
    }) -Depth 8

Write-Host '----------------------------------------------------------------'
Write-Host ('[success] External consumer smoke passed. Summary: {0}' -f $summaryPath) -ForegroundColor Green
