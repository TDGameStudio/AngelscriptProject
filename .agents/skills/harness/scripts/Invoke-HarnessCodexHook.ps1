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
        if ($requestedEvent -notin @('SessionStart', 'Stop', 'Interrupt', 'UserPromptSubmit')) { exit 0 }
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

    $sessionId = ''
    if ($null -ne $hookInput -and 'session_id' -in $hookInput.PSObject.Properties.Name) {
        $sessionId = [string]$hookInput.session_id
        if ($sessionId -notmatch '^[A-Za-z0-9_-]+$') { throw 'An exact session ID is required.' }
    }
    $orientation = $hookEventName -eq 'SessionStart'
    $executionSummary = ''
    $workflowModule = Join-Path $expectedHarnessRoot '.agents/skills/harness/scripts/Workflow.psm1'
    # Save feedback/pause before optional recording; Stop still reconciles before deciding continuation.
    $stages = if ($hookEventName -in @('UserPromptSubmit', 'Interrupt')) { @('execution', 'record') } else { @('record', 'execution') }
    foreach ($stage in $stages) {
        if ($stage -eq 'record' -and $sessionId -and $hookEventName -ne 'Interrupt') {
            try {
                $bindingPath = Join-Path $workspaceRoot "Saved/Harness/draft-record/$sessionId.json"
                if (-not (Test-Path -LiteralPath $bindingPath -PathType Leaf)) { continue }
                $binding = Get-Content -LiteralPath $bindingPath -Raw | ConvertFrom-Json -ErrorAction Stop
                if ($null -eq $binding.active) { continue }
                Import-Module (Join-Path $expectedHarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1') -ErrorAction Stop
                $recordContext = [pscustomobject]@{WorkspaceRoot=$workspaceRoot; HarnessRoot=$expectedHarnessRoot}
                if ($null -ne $workspaceContext) { $recordContext | Add-Member -NotePropertyName OpenSpecRoot -NotePropertyValue $workspaceContext.OpenSpecRoot }
                # The shared recorder retains complete source identity, prefix and coverage checks.
                [void](Invoke-HarnessDraftRecord -Context $recordContext -Action sync -SessionId $sessionId -HookInput $hookInput)
            }
            catch {
                [Console]::Error.WriteLine((Limit-HarnessHookText -Text ("Draft recording incomplete: " + $_.Exception.Message + ' Retry harness.draft.record sync.') -Limit 600))
            }
        }
        if ($stage -eq 'execution' -and $sessionId -and $null -ne $workspaceContext -and
            ($orientation -or $hookEventName -in @('UserPromptSubmit', 'Interrupt', 'Stop')) -and
            (Test-Path -LiteralPath (Join-Path $workspaceRoot "Saved/Harness/Execution/$sessionId.json") -PathType Leaf) -and
            (Test-Path -LiteralPath $workflowModule -PathType Leaf)) {
            try {
                Import-Module $workflowModule -ErrorAction Stop
                if ($orientation) {
                    $execution = Invoke-HarnessExecution -Context $workspaceContext -Action status -SessionId $sessionId
                    if ($execution.state -ne 'unbound') { $executionSummary = " Execution: state=$($execution.state); change=$($execution.change); phase=$($execution.phase). Query harness.execution.status for this session before continuing." }
                } else {
                    $hookValues = @{}; foreach ($property in $hookInput.PSObject.Properties) { $hookValues[$property.Name] = $property.Value }
                    $decision = Invoke-HarnessWorkflowCore -Context $workspaceContext -Group execution -Action hook -Parameters $hookValues
                    if (@($decision.PSObject.Properties).Count) { [Console]::Out.WriteLine(($decision | ConvertTo-Json -Depth 8 -Compress)) }
                }
            } catch { [Console]::Error.WriteLine((Limit-HarnessHookText -Text ('Harness continuation check unavailable: ' + $_.Exception.Message) -Limit 600)) }
        }
    }
    if (-not $orientation) { exit 0 }
    if ($null -eq $workspaceContext) { throw 'Workspace identity is unavailable for orientation.' }
    # Orientation needs the identity already checked above, not another full Harness dispatch.
    $identity = $workspaceContext
    $head = [string]$identity.Head
    if ($head.Length -gt 12) { $head = $head.Substring(0, 12) }
    $additionalContext = Limit-HarnessHookText -Text (
        "Harness read-only workspace: id='$($identity.WorkspaceId)'; root='$($identity.WorkspaceRoot)'; topology=$($identity.Topology); " +
        "branch='$($identity.Branch)'; head=$head; primary='$($identity.PrimaryRoot)'; records='$($identity.OpenSpecRoot)'. " +
        ('Resolve code/edit/build/test paths under root and OpenSpec edits under records; shared Harness scripts do not switch the selected workspace. Codex /goal does not change workspace identity.' + $executionSummary)
    )
}
catch {
    if ($hookEventName -ne 'SessionStart') {
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
