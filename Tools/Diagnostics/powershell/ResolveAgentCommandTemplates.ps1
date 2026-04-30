[CmdletBinding()]
param(
    [string]$ProjectRoot = '',

    [string]$ConfigPath = '',

    [string]$TestName = '<TestName>',

    [string]$BuildLabel = 'agent-build',

    [string]$TestLabel = 'agent-test'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\Shared\UnrealCommandUtils.ps1')

$resolvedProjectRoot = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}
else {
    Normalize-PathValue -Path $ProjectRoot
}

$resolvedConfigPath = if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    Join-Path $resolvedProjectRoot 'AgentConfig.ini'
}
else {
    Normalize-PathValue -Path $ConfigPath
}

$powerShell = Get-ConsolePowerShellPath
$bootstrapScript = Join-Path $resolvedProjectRoot 'Tools\Bootstrap\powershell\BootstrapWorktree.ps1'
$buildScript = Join-Path $resolvedProjectRoot 'Tools\RunBuild.ps1'
$testScript = Join-Path $resolvedProjectRoot 'Tools\RunTests.ps1'
$testSuiteScript = Join-Path $resolvedProjectRoot 'Tools\RunTestSuite.ps1'
$ubtProcessScript = Join-Path $resolvedProjectRoot 'Tools\Diagnostics\powershell\Get-UbtProcess.ps1'

$resolved = [ordered]@{
    Status                  = 'BootstrapRequired'
    BootstrapCommand        = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}"' -f $powerShell, $bootstrapScript)
    BootstrapAllCommand     = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -AllRegisteredWorktrees' -f $powerShell, $bootstrapScript)
    ConfigPath              = $resolvedConfigPath
    ProjectRoot             = $resolvedProjectRoot
    Message                 = 'AgentConfig.ini is missing or needs normalization. Run BootstrapCommand first.'
}

try {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $resolvedProjectRoot -ConfigPath $resolvedConfigPath
    $buildTimeoutMs = $agentConfig.BuildDefaultTimeoutMs
    $testTimeoutMs = $agentConfig.TestDefaultTimeoutMs

    $resolved.Status = 'Ready'
    $resolved.Message = 'Official build and test runners resolved from AgentConfig.ini.'
    $resolved.EngineRoot = $agentConfig.EngineRoot
    $resolved.ProjectFile = $agentConfig.ProjectFile
    $resolved.EditorTarget = $agentConfig.EditorTarget
    $resolved.Platform = $agentConfig.Platform
    $resolved.Configuration = $agentConfig.Configuration
    $resolved.Architecture = $agentConfig.Architecture
    $resolved.BuildDefaultTimeoutMs = $buildTimeoutMs
    $resolved.TestDefaultTimeoutMs = $testTimeoutMs
    $resolved.BuildCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -Label "{2}" -TimeoutMs {3}' -f $powerShell, $buildScript, $BuildLabel, $buildTimeoutMs)
    $resolved.NoXgeBuildCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -Label "{2}" -TimeoutMs {3} -NoXGE' -f $powerShell, $buildScript, $BuildLabel, $buildTimeoutMs)
    $resolved.DebuggerBuildCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -Target AngelscriptDebugger -Label "{2}-debugger" -TimeoutMs {3} -SerializeByEngine' -f $powerShell, $buildScript, $BuildLabel, $buildTimeoutMs)
    $resolved.DebuggerSmokeCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -TimeoutSeconds 30' -f $powerShell, (Join-Path $resolvedProjectRoot 'Tools\Diagnostics\powershell\Test-AngelscriptDebuggerSmoke.ps1'))
    $resolved.SerializedBuildCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -Label "{2}" -TimeoutMs {3} -SerializeByEngine' -f $powerShell, $buildScript, $BuildLabel, $buildTimeoutMs)
    $resolved.TestCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -TestPrefix "{2}" -Label "{3}" -TimeoutMs {4}' -f $powerShell, $testScript, $TestName, $TestLabel, $testTimeoutMs)
    $resolved.TestSuiteSmokeCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -Suite Smoke -LabelPrefix "{2}" -TimeoutMs {3}' -f $powerShell, $testSuiteScript, $TestLabel, $testTimeoutMs)
    $resolved.UbtProcessCommand = ('{0} -NoProfile -ExecutionPolicy Bypass -File "{1}" -CurrentWorktreeOnly' -f $powerShell, $ubtProcessScript)
}
catch {
    $resolved.Message = $_.Exception.Message
}

$resolved.GetEnumerator() | ForEach-Object {
    Write-Output ("{0}={1}" -f $_.Key, $_.Value)
}
