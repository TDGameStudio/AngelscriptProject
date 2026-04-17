param(
    [string]$OutputFile = '1.txt'
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$targetFile = if ([System.IO.Path]::IsPathRooted($OutputFile)) {
    $OutputFile
} else {
    Join-Path $PSScriptRoot $OutputFile
}

if (Test-Path $targetFile) {
    Remove-Item $targetFile -Force
}

New-Item -ItemType Directory -Path (Split-Path -Parent $targetFile) -Force | Out-Null

$prompt = 'hello ' + [char]0x4F60 + [char]0x597D
Write-Output "[hello-codex] Running: codex exec `"$prompt`" --skip-git-repo-check *> $targetFile"

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
codex exec $prompt --skip-git-repo-check *> $targetFile
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

Write-Output "[hello-codex] Exit code: $exitCode"
Write-Output "[hello-codex] Output file: $targetFile"

exit $exitCode
