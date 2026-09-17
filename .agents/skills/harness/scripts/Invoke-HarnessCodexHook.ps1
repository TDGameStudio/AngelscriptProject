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
        if ($requestedEvent -notin @('SessionStart', 'SubagentStart', 'PostToolUse', 'Stop', 'Interrupt')) { exit 0 }
        $hookEventName = $requestedEvent
    }

    $workingDirectory = if ($null -ne $hookInput -and 'cwd' -in @($hookInput.PSObject.Properties.Name) -and
        -not [string]::IsNullOrWhiteSpace([string]$hookInput.cwd)) {
        [string]$hookInput.cwd
    }
    else {
        (Get-Location).Path
    }

    $expectedHarnessRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
    $workspaceManifest = Join-Path $expectedHarnessRoot '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1'
    $workspaceContext = $null
    if (Test-Path -LiteralPath $workspaceManifest) {
        Import-Module $workspaceManifest -ErrorAction Stop
        $workspaceContext = Get-HarnessWorkspaceContext -WorkspaceRoot $workingDirectory
        if (-not (Test-HarnessHookPathEqual $workspaceContext.PrimaryRoot $expectedHarnessRoot) -and
            -not (Test-HarnessHookPathEqual $workspaceContext.WorkspaceRoot $expectedHarnessRoot)) { throw 'Hook belongs to another control center.' }
        $workspaceRoot = $workspaceContext.WorkspaceRoot
    } else {
        $workspaceRoot = Resolve-HarnessHookGitRoot -WorkingDirectory $workingDirectory -ExpectedHarnessRoot $expectedHarnessRoot
    }
    if ([string]::IsNullOrWhiteSpace($workspaceRoot)) {
        throw 'The hook working directory is not inside this registered project workspace.'
    }

    if ($hookEventName -ne 'SubagentStart' -and $null -ne $hookInput -and 'session_id' -in $hookInput.PSObject.Properties.Name) {
        try {
            Import-Module (Join-Path $expectedHarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1') -ErrorAction Stop
            $recordContext = [pscustomobject]@{WorkspaceRoot=$workspaceRoot; HarnessRoot=$expectedHarnessRoot}
            if ($null -ne $workspaceContext) { $recordContext | Add-Member -NotePropertyName OpenSpecRoot -NotePropertyValue $workspaceContext.OpenSpecRoot }
            # The recorder owns source identity and reports a Stop final that is not flushed yet.
            [void](Invoke-HarnessDraftRecord -Context $recordContext -Action sync -SessionId $hookInput.session_id -HookInput $hookInput)
        }
        catch {
            [Console]::Error.WriteLine((Limit-HarnessHookText -Text ("Draft recording incomplete: " + $_.Exception.Message + ' Retry harness.draft.record sync.') -Limit 600))
        }
    }
    if ($hookEventName -notin @('SessionStart', 'SubagentStart')) { exit 0 }
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
        "Harness read-only workspace: id='$($identity.WorkspaceId)'; root='$($identity.WorkspaceRoot)'; topology=$($identity.Topology); " +
        "branch='$($identity.Branch)'; head=$head; primary='$($identity.PrimaryRoot)'; records='$($identity.OpenSpecRoot)'. " +
        'Resolve code/edit/build/test paths under root and OpenSpec edits under records; shared Harness scripts do not switch the selected workspace. Codex /goal does not change workspace identity.'
    )
}
catch {
    if ($hookEventName -notin @('SessionStart', 'SubagentStart')) {
        [Console]::Error.WriteLine('Draft recording unavailable for this workspace; retry the bound session with harness.draft.record sync.')
        exit 0
    }
}

$response = [ordered]@{
    hookSpecificOutput = [ordered]@{
        hookEventName = $hookEventName
        additionalContext = $additionalContext
    }
}
[Console]::Out.WriteLine(($response | ConvertTo-Json -Depth 4 -Compress))
exit 0
