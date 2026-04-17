param(
    [string]$VerifyCommand,
    [string]$WorkingDirectory,
    [string]$RunDir,
    [string]$IterationDir,
    [int]$Iteration
)

$ErrorActionPreference = 'Stop'

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string]$StdOutFile,

        [Parameter(Mandatory = $true)]
        [string]$StdErrFile
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'cmd.exe'
    $startInfo.Arguments = "/d /s /c `"$Command`""
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    Set-Content -Path $StdOutFile -Value $stdout -Encoding UTF8
    Set-Content -Path $StdErrFile -Value $stderr -Encoding UTF8

    return $process.ExitCode
}

if ([string]::IsNullOrWhiteSpace($VerifyCommand)) {
    exit 1
}

Set-Item -Path Env:RALPH_STOP_HOOK_SHELL -Value $PSEdition

$stdoutFile = Join-Path $IterationDir 'verify.stdout.log'
$stderrFile = Join-Path $IterationDir 'verify.stderr.log'
$exitCode = Invoke-LoggedCommand `
    -Command $VerifyCommand `
    -WorkingDirectory $WorkingDirectory `
    -StdOutFile $stdoutFile `
    -StdErrFile $stderrFile

if ($exitCode -eq 0) {
    exit 0
}

if ($exitCode -eq 1) {
    exit 1
}

[Console]::Error.WriteLine("Verification command failed with exit code $exitCode.")
exit $exitCode
