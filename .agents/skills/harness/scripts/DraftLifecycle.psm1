#requires -Version 7.0
#requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-DraftId {
    param([Parameter(Mandatory = $true)][string]$DraftId)
    if ($DraftId -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw "Draft ID '$DraftId' must be <domain>/<topic> in lowercase kebab-case."
    }
}

function Assert-DraftScope {
    param([Parameter(Mandatory = $true)][string]$Scope)
    if ($Scope -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw "Draft scope '$Scope' must be lowercase kebab-case."
    }
}

function Assert-DraftPath {
    param([string]$Root, [string]$Path)
    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $target = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    if (-not $target.StartsWith(($rootPath + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Draft path '$target' escapes '$rootPath'."
    }
    $cursor = $rootPath
    foreach ($segment in @($target.Substring($rootPath.Length).TrimStart('\', '/') -split '[\\/]')) {
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }
        $cursor = Join-Path $cursor $segment
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Draft path contains a reparse point: $cursor"
        }
    }
    return $target
}

function Get-DraftRoot {
    param($Context, [string]$DraftId, [switch]$Archive)
    Assert-DraftId -DraftId $DraftId
    $subroot = if ($Archive) { 'openspec/archive/drafts' } else { 'openspec/drafts' }
    $root = Join-Path ([string]$Context.WorkspaceRoot) $subroot
    $target = Join-Path $root ($DraftId.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
    [void](Assert-DraftPath -Root ([string]$Context.WorkspaceRoot) -Path $target)
    return $target
}

function Get-DraftMetadata {
    param([string]$Text, [string]$Name)
    $match = [regex]::Match($Text, ('(?m)^{0}:\s*(?<value>[^\r\n]+)' -f [regex]::Escape($Name)))
    if (-not $match.Success) { return '' }
    return $match.Groups['value'].Value.Trim().Trim('"', "'")
}

function Get-DraftCurrent {
    param([string]$Text, [string]$Label)
    $match = [regex]::Match($Text, ('(?m)^- \*\*{0}\*\*[：:]\s*(?<value>[^\r\n]+)' -f [regex]::Escape($Label)))
    if (-not $match.Success) { return '' }
    return $match.Groups['value'].Value.Trim()
}

function Resolve-DraftLink {
    param([string]$Root, [string]$Base, [string]$Link)
    if ($Link -match '^(?:https?:|mailto:|#)') { return '' }
    $pathPart = ($Link -split '#', 2)[0]
    if ([string]::IsNullOrWhiteSpace($pathPart)) { return '' }
    $target = Join-Path $Base $pathPart
    [void](Assert-DraftPath -Root $Root -Path $target)
    return [System.IO.Path]::GetFullPath($target)
}

function New-HarnessDraft {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$DraftId,
        [Parameter(Mandatory = $true)][string]$Title,
        [ValidateSet('research', 'proposal', 'design')][string]$Mode = 'research'
    )
    $root = Get-DraftRoot -Context $Context -DraftId $DraftId
    if (Test-Path -LiteralPath $root) { throw "Draft '$DraftId' already exists." }
    $date = [DateTime]::UtcNow.ToString('yyyy-MM-dd')
    [void][System.IO.Directory]::CreateDirectory($root)
    $now = switch ($Mode) { 'research' { '调查' } 'proposal' { '摊候选' } 'design' { '收束这一刀' } }
    $readme = "---`ndraft: $DraftId`nmode: $Mode`nstatus: exploring`nopened: $date`n---`n`n# $Title`n`n- **此刻**：$now`n- **焦点**：[log.md](log.md)`n- **已决**：无`n- **下一问**：待梳理`n- **讲清于**：未讲`n"
    [System.IO.File]::WriteAllText((Join-Path $root 'README.md'), $readme, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $root 'log.md'), "# Log`n", [System.Text.UTF8Encoding]::new($false))
    return [pscustomobject]@{ DraftId = $DraftId; Path = $root; Mode = $Mode }
}

function Get-HarnessDraftStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$DraftId)
    $root = Get-DraftRoot -Context $Context -DraftId $DraftId
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Draft '$DraftId' does not exist." }
    $readmePath = Join-Path $root 'README.md'
    if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) { throw "Draft '$DraftId' has no README.md." }
    $readme = [System.IO.File]::ReadAllText($readmePath)
    $issues = [System.Collections.Generic.List[string]]::new()
    $identity = Get-DraftMetadata -Text $readme -Name 'draft'
    $mode = Get-DraftMetadata -Text $readme -Name 'mode'
    $state = Get-DraftMetadata -Text $readme -Name 'status'
    if ($identity -cne $DraftId) { $issues.Add('README draft identity does not match the selected topic.') }
    if ($mode -notin @('research', 'proposal', 'design')) { $issues.Add('README mode is missing or invalid.') }
    if ($state -notin @('exploring', 'parked', 'abandoned')) { $issues.Add('README status is missing or invalid.') }
    $current = @{}
    foreach ($label in @('此刻', '焦点', '已决', '下一问', '讲清于')) {
        $current[$label] = Get-DraftCurrent -Text $readme -Label $label
        if ([string]::IsNullOrWhiteSpace($current[$label])) { $issues.Add("README current line '$label' is missing.") }
    }
    $focus = ''
    if ($current['焦点'] -match '^\[[^]]+\]\((?<link>[^)]+)\)$') {
        $focus = $Matches.link
        try {
            $focusPath = Resolve-DraftLink -Root $root -Base $root -Link $focus
            if (-not (Test-Path -LiteralPath $focusPath)) { $issues.Add("README focus target '$focus' does not exist.") }
        }
        catch { $issues.Add("README focus target is unsafe: $($_.Exception.Message)") }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($current['焦点'])) { $issues.Add('README focus must be one local Markdown link.') }
    $round = ''
    if ($current['讲清于'] -ne '未讲' -and -not [string]::IsNullOrWhiteSpace($current['讲清于'])) {
        if ($current['讲清于'] -match '^\[R(?<number>[0-9]+)\]\(log\.md#r[0-9]+\)\s*·\s*[0-9]{4}-[0-9]{2}-[0-9]{2}$') {
            $round = 'R' + $Matches.number
            if ($current['讲清于'] -cnotmatch [regex]::Escape("log.md#$($round.ToLowerInvariant())")) { $issues.Add('Explanation link and round ID disagree.') }
            $logPath = Join-Path $root 'log.md'
            if (-not (Test-Path -LiteralPath $logPath -PathType Leaf) -or
                [System.IO.File]::ReadAllText($logPath) -cnotmatch ('(?m)^## {0}(?:\s|$)' -f [regex]::Escape($round))) {
                $issues.Add("Explained round '$round' does not exist in log.md.")
            }
        }
        else { $issues.Add('Explained at must link to a stable log round with a date, or say 未讲.') }
    }
    return [pscustomobject]@{
        DraftId = $DraftId
        Path = $root
        Mode = $mode
        State = $state
        Focus = $focus
        Next = $current['下一问']
        ExplainedRound = $round
        Valid = ($issues.Count -eq 0)
        Issues = @($issues.ToArray())
    }
}

function Test-HarnessDraft {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$DraftId,
        [Parameter(Mandatory = $true)][string]$Scope,
        [Parameter(Mandatory = $true)][string]$ChangeId
    )
    Assert-DraftScope -Scope $Scope
    $status = Get-HarnessDraftStatus -Context $Context -DraftId $DraftId
    if (-not $status.Valid) { throw "Draft '$DraftId' is not ready: $($status.Issues -join '; ')" }
    $designRoot = Join-Path $status.Path "designs/$Scope"
    [void](Assert-DraftPath -Root $status.Path -Path $designRoot)
    $designReadme = Join-Path $designRoot 'README.md'
    $designPath = Join-Path $designRoot 'design.md'
    $handoffPath = Join-Path $designRoot 'handoff.md'
    foreach ($path in @($designReadme, $designPath, $handoffPath)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Selected design is missing '$path'." }
    }
    $designReadmeText = [System.IO.File]::ReadAllText($designReadme)
    $designState = Get-DraftMetadata -Text $designReadmeText -Name 'status'
    if ($designState -ne 'designed') { throw "Selected design '$Scope' is '$designState', not designed." }
    $handoff = [System.IO.File]::ReadAllText($handoffPath)
    if ($handoff -cnotmatch '(?m)^## OpenSpec Handoff\s*$' -or $handoff -cnotmatch '(?m)^## Exploration Carryover\s*$') {
        throw 'Selected handoff must contain OpenSpec Handoff and Exploration Carryover.'
    }
    if ($handoff -cnotmatch [regex]::Escape($ChangeId)) { throw "Handoff does not name target Change '$ChangeId'." }
    $kind = ($ChangeId -split '/', 2)[-1].Split('-')[0]
    $round = ''
    $approvalRound = [regex]::Match($designReadmeText, '\bR(?<number>[0-9]+)\b')
    if ($kind -notin @('docs', 'chore', 'test') -and -not $approvalRound.Success) {
        throw "Behavior or architecture handoff '$DraftId/$Scope' has no scoped approval round."
    }
    if ($approvalRound.Success) {
        $round = 'R' + $approvalRound.Groups['number'].Value
        $log = Join-Path $status.Path 'log.md'
        if (-not (Test-Path -LiteralPath $log -PathType Leaf) -or
            [System.IO.File]::ReadAllText($log) -cnotmatch ('(?m)^## {0}(?:\s|$)' -f [regex]::Escape($round))) {
            throw "Scoped approval round '$round' does not exist in log.md."
        }
    }
    $references = [System.Collections.Generic.List[string]]::new()
    $workspaceBase = [string]$Context.WorkspaceRoot
    foreach ($file in @($designPath, $handoffPath)) {
        $content = [System.IO.File]::ReadAllText($file)
        foreach ($match in [regex]::Matches($content, '\]\((?<link>[^)]+)\)')) {
            $target = Resolve-DraftLink -Root $workspaceBase -Base (Split-Path $file -Parent) -Link $match.Groups['link'].Value
            if ($target -and -not (Test-Path -LiteralPath $target)) { throw "Selected design link target does not exist: $target" }
            if ($target) { $references.Add($target) }
        }
    }
    return [pscustomobject]@{ DraftId = $DraftId; Scope = $Scope; ChangeId = $ChangeId; Path = $designRoot; ExplainedRound = $status.ExplainedRound; ApprovalRound = $round; ReferencedFiles = @($references.ToArray() | Sort-Object -Unique) }
}

function Close-HarnessDraft {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$DraftId,
        [Parameter(Mandatory = $true)][ValidateSet('completed', 'abandoned')][string]$Closure,
        [string]$Reason = ''
    )
    $status = Get-HarnessDraftStatus -Context $Context -DraftId $DraftId
    if (-not $status.Valid) { throw "Cannot archive invalid draft: $($status.Issues -join '; ')" }
    if ($status.State -eq 'parked') { throw 'A parked topic stays in active drafts until it is explicitly completed or abandoned.' }
    if ($Closure -eq 'abandoned' -and [string]::IsNullOrWhiteSpace($Reason)) { throw 'Abandoned draft closure requires a reason.' }
    if ($Closure -eq 'completed') {
        if ($status.Next -notin @('无', 'none', 'None')) { throw 'Completed draft still has a next question.' }
        $designsRoot = Join-Path $status.Path 'designs'
        if (Test-Path -LiteralPath $designsRoot -PathType Container) {
            foreach ($design in @(Get-ChildItem -LiteralPath $designsRoot -Directory)) {
                $path = Join-Path $design.FullName 'README.md'
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Scoped design '$($design.Name)' has no README." }
                $designState = Get-DraftMetadata -Text ([System.IO.File]::ReadAllText($path)) -Name 'status'
                if ($designState -notin @('designed', 'handed-off', 'abandoned')) {
                    throw "Scoped design '$($design.Name)' remains '$designState'."
                }
            }
        }
    }
    $archiveBase = Get-DraftRoot -Context $Context -DraftId $DraftId -Archive
    $archiveParent = Split-Path $archiveBase -Parent
    $leaf = Split-Path $archiveBase -Leaf
    $archive = Join-Path $archiveParent ('{0}-{1}' -f [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'), $leaf)
    [void](Assert-DraftPath -Root ([string]$Context.WorkspaceRoot) -Path $archive)
    if (Test-Path -LiteralPath $archive) { throw "Draft archive target already exists: $archive" }
    [void][System.IO.Directory]::CreateDirectory($archiveParent)
    Move-Item -LiteralPath $status.Path -Destination $archive -ErrorAction Stop
    $readmePath = Join-Path $archive 'README.md'
    $readme = [System.IO.File]::ReadAllText($readmePath)
    $readme = [regex]::new('(?m)^status:\s*[^\r\n]+').Replace($readme, 'status: archived', 1)
    $date = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $readme = [regex]::new('(?m)^opened:\s*[^\r\n]+').Replace($readme, ('$0' + "`narchived_at: $date`nclosure: $Closure"), 1)
    if ($Reason) { $readme += "`nArchive reason: $Reason`n" }
    [System.IO.File]::WriteAllText($readmePath, $readme, [System.Text.UTF8Encoding]::new($false))
    return [pscustomobject]@{ DraftId = $DraftId; Closure = $Closure; Path = $archive }
}

Export-ModuleMember -Function New-HarnessDraft, Get-HarnessDraftStatus, Test-HarnessDraft, Close-HarnessDraft
