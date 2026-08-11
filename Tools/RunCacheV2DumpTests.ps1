[CmdletBinding()]
param(
    [string]$OutputRoot = '',
    [int]$Verbosity = 2
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$toolRoot = Join-Path $projectRoot 'Plugins\Angelscript\Tools\CacheV2Dump'
$testsRoot = Join-Path $toolRoot 'tests'

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
    $OutputRoot = Join-Path $projectRoot "Saved\Tests\cache-v2-dump\$stamp"
}
$resolvedOutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
New-Item -ItemType Directory -Force -Path $resolvedOutputRoot | Out-Null
$logPath = Join-Path $resolvedOutputRoot 'python-unittest.log'

Write-Host "Cache V2 dump tests: $testsRoot"
Write-Host "Output             : $resolvedOutputRoot"

$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = 'python'
$startInfo.Arguments = ('-m unittest discover -s "{0}" -p "test_*.py" -v' -f $testsRoot)
$startInfo.WorkingDirectory = $projectRoot
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
if (-not $process.Start()) {
    throw 'Failed to start Python unittest process.'
}
$standardOutputTask = $process.StandardOutput.ReadToEndAsync()
$standardErrorTask = $process.StandardError.ReadToEndAsync()
$process.WaitForExit()
$standardOutput = $standardOutputTask.GetAwaiter().GetResult()
$standardError = $standardErrorTask.GetAwaiter().GetResult()
$rawExitCode = [int]$process.ExitCode
$combinedOutput = $standardOutput + $standardError
$combinedOutput | Tee-Object -FilePath $logPath | Out-Host
$process.Dispose()

$summary = [ordered]@{
    kind = 'PythonUnittest'
    label = 'CacheV2Dump'
    exitCode = $rawExitCode
    log = $logPath
    completedAt = (Get-Date).ToUniversalTime().ToString('o')
}
$summary | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (
    Join-Path $resolvedOutputRoot 'summary.json') -Encoding UTF8

exit $rawExitCode
