#requires -Version 7.0
#requires -PSEdition Core

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'

function Test-HarnessHookPathEqual {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )

    $leftPath = [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/')
    $rightPath = [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/')
    return [string]::Equals($leftPath, $rightPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Resolve-HarnessHookGitRoot {
    param(
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string]$ExpectedHarnessRoot
    )

    try {
        $resolvedCwd = [System.IO.Path]::GetFullPath($WorkingDirectory)
        if (Test-Path -LiteralPath $resolvedCwd -PathType Leaf) {
            $resolvedCwd = Split-Path -LiteralPath $resolvedCwd -Parent
        }
        if (-not (Test-Path -LiteralPath $resolvedCwd -PathType Container)) { return '' }

        $cursor = Get-Item -LiteralPath $resolvedCwd -Force
        while ($null -ne $cursor) {
            if (Test-HarnessHookPathEqual -Left $cursor.FullName -Right $ExpectedHarnessRoot) {
                $gitOutput = @(& git -C $cursor.FullName rev-parse --show-toplevel 2>$null)
                $gitExitCode = $LASTEXITCODE
                if ($gitExitCode -eq 0 -and $gitOutput.Count -gt 0) {
                    $gitRoot = [System.IO.Path]::GetFullPath([string]$gitOutput[-1])
                    if (Test-HarnessHookPathEqual -Left $gitRoot -Right $ExpectedHarnessRoot) {
                        return $gitRoot
                    }
                }
                return ''
            }
            $cursor = $cursor.Parent
        }
    }
    catch {
        return ''
    }
    return ''
}

function Limit-HarnessHookText {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [ValidateRange(64, 1200)][int]$Limit = 900
    )

    if ($Text.Length -le $Limit) { return $Text }
    return $Text.Substring(0, $Limit - 3) + '...'
}

$hookEventName = 'SessionStart'
$additionalContext = 'Harness status is unavailable for this optional hook. Continue normally; hook output is not a workflow gate.'

try {
    $inputText = [Console]::In.ReadToEnd()
    $hookInput = if ([string]::IsNullOrWhiteSpace($inputText)) { $null } else { $inputText | ConvertFrom-Json -ErrorAction Stop }
    if ($null -ne $hookInput -and 'hook_event_name' -in @($hookInput.PSObject.Properties.Name)) {
        $requestedEvent = [string]$hookInput.hook_event_name
        if ($requestedEvent -in @('SessionStart', 'SubagentStart')) { $hookEventName = $requestedEvent }
    }

    $workingDirectory = if ($null -ne $hookInput -and 'cwd' -in @($hookInput.PSObject.Properties.Name) -and
        -not [string]::IsNullOrWhiteSpace([string]$hookInput.cwd)) {
        [string]$hookInput.cwd
    }
    else {
        (Get-Location).Path
    }

    $expectedHarnessRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
    $workspaceRoot = Resolve-HarnessHookGitRoot -WorkingDirectory $workingDirectory -ExpectedHarnessRoot $expectedHarnessRoot
    if ([string]::IsNullOrWhiteSpace($workspaceRoot)) {
        throw 'The hook working directory is not inside this registered project workspace.'
    }

    $manifestPath = Join-Path $expectedHarnessRoot '.agents\skills\harness\scripts\Harness.psd1'
    Import-Module -Name $manifestPath -Force -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    $context = New-HarnessContext -WorkspaceRoot $workspaceRoot
    $status = Invoke-Harness -Command harness.status -Context $context
    if ([string]$status.status -ne 'Succeeded') {
        throw "Fast status failed with exit code $($status.exitCode)."
    }

    $identity = $status.data.Workspace.Context
    $head = [string]$identity.Head
    if ($head.Length -gt 12) { $head = $head.Substring(0, 12) }
    $additionalContext = Limit-HarnessHookText -Text (
        "Harness read-only workspace: root='$($identity.WorkspaceRoot)'; topology=$($identity.Topology); " +
        "branch='$($identity.Branch)'; head=$head; primary='$($identity.PrimaryRoot)'. " +
        'Keep repository, build, and test operations in this workspace. Codex /goal continuation does not change workspace identity.'
    )
}
catch {
    # Hooks are orientation hints only. Fail open without leaking local diagnostics or
    # making repository correctness depend on Codex hook availability.
}

$response = [ordered]@{
    hookSpecificOutput = [ordered]@{
        hookEventName = $hookEventName
        additionalContext = $additionalContext
    }
}
[Console]::Out.WriteLine(($response | ConvertTo-Json -Depth 4 -Compress))
exit 0
