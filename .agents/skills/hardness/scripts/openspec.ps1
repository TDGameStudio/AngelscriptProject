<#
.SYNOPSIS
    Wrapper for the project-local OpenSpec CLI (.agents/skills/openspec/bin/openspec.exe).

.DESCRIPTION
    Locates the OpenSpec executable relative to this script, so it works from any
    current working directory. All arguments are passed through to openspec.exe,
    and its exit code is preserved.

.PARAMETER GetPath
    Print the resolved absolute path of openspec.exe and exit, without running it.

.EXAMPLE
    .\openspec.ps1 -GetPath
    # -> D:\Workspace\AngelscriptProject\.agents\skills\openspec\bin\openspec.exe

.EXAMPLE
    .\openspec.ps1 list
    .\openspec.ps1 validate "my-change" --strict
#>
param([switch]$GetPath)

$ErrorActionPreference = 'Stop'

$exeRelative = Join-Path $PSScriptRoot '..\..\openspec\bin\openspec.exe'
if (-not (Test-Path -LiteralPath $exeRelative)) {
    Write-Error "openspec.exe not found at expected location: $exeRelative`nBuild it from Tools/openspec and copy the release binary to .agents/skills/openspec/bin/openspec.exe"
    exit 1
}
$exePath = (Resolve-Path -LiteralPath $exeRelative).Path

if ($GetPath) {
    Write-Output $exePath
    exit 0
}

& $exePath @args
exit $LASTEXITCODE
