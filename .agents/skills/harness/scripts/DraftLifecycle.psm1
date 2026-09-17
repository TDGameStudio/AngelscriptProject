#requires -Version 7.0
#requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-HarnessRecordRoot {
    param($Context)
    if ('OpenSpecRoot' -in $Context.PSObject.Properties.Name -and $Context.OpenSpecRoot) { return [string]$Context.OpenSpecRoot }
    return [string]$Context.WorkspaceRoot
}

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
    $root = Join-Path ((Get-HarnessRecordRoot $Context)) $subroot
    $target = Join-Path $root ($DraftId.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
    [void](Assert-DraftPath -Root ((Get-HarnessRecordRoot $Context)) -Path $target)
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
    $metadata = [regex]::Match($designReadmeText, '\A---\r?\n(?<fields>[\s\S]*?)\r?\n---(?:\r?\n|$)')
    if (-not $metadata.Success) { throw 'Selected design README needs frontmatter metadata.' }
    $fields = $metadata.Groups['fields'].Value
    if ((Get-DraftMetadata -Text $fields -Name 'design') -cne $Scope) { throw 'Selected README design identity does not match Scope.' }
    $designState = Get-DraftMetadata -Text $fields -Name 'status'
    if ($designState -ne 'designed') { throw "Selected design '$Scope' is '$designState', not designed." }
    $handoff = [System.IO.File]::ReadAllText($handoffPath)
    if ($handoff -cnotmatch '(?m)^## OpenSpec Handoff\s*$' -or $handoff -cnotmatch '(?m)^## Exploration Carryover\s*$') {
        throw 'Selected handoff must contain OpenSpec Handoff and Exploration Carryover.'
    }
    $identity = [regex]::Split(([regex]::Split($handoff, '(?m)^## OpenSpec Handoff\s*$', 2)[1]), '(?m)^## ', 2)[0]
    foreach ($field in @(@('Scope', $Scope), @('Target Change', $ChangeId))) {
        $entries = [regex]::Matches($identity, ('(?m)^- {0}:\s*`?(?<value>[^`\r\n]+)`?\s*$' -f [regex]::Escape($field[0])))
        if ($entries.Count -ne 1 -or $entries[0].Groups['value'].Value.Trim() -cne $field[1]) { throw "Handoff needs exact '$($field[0]): $($field[1])'." }
    }
    $approval = [regex]::Matches($fields, '(?m)^approval_round: *(?<round>R[0-9]+) *\r?$')
    if ($approval.Count -ne 1) { throw "Selected design '$Scope' needs one explicit approval_round: R<n>." }
    $round = $approval[0].Groups['round'].Value
    if ($round) {
        $log = Join-Path $status.Path 'log.md'
        if (-not (Test-Path -LiteralPath $log -PathType Leaf) -or
            [System.IO.File]::ReadAllText($log) -cnotmatch ('(?m)^## {0}(?:\s|$)' -f [regex]::Escape($round))) {
            throw "Scoped approval round '$round' does not exist in log.md."
        }
    }
    $carryover = [regex]::Split(([regex]::Split($handoff, '(?m)^## Exploration Carryover\s*$', 2)[1]), '(?m)^## ', 2)[0]
    if ($carryover -notmatch '(?m)^\| Source \| Target \| Reason \|\s*$') { throw 'Exploration Carryover needs a Source / Target / Reason table.' }
    $exports = [System.Collections.Generic.List[object]]::new()
    foreach ($line in ($carryover -split '\r?\n')) {
        if ($line -notmatch '^\|(?<source>[^|]+)\|(?<target>[^|]+)\|(?<reason>[^|]+)\|\s*$') { continue }
        $source = $Matches.source.Trim().Trim('`')
        $target = $Matches.target.Trim().Trim('`')
        $reason = $Matches.reason.Trim()
        if ($source -eq 'Source' -or $source -match '^:?-+:?$') { continue }
        if ($target -cnotmatch '^attachments/(?:drafts|talks|knowledges)/[a-zA-Z0-9_./-]+\.md$' -or '..' -in ($target -split '/') -or -not $reason) { throw "Invalid carryover target or reason: $target" }
        if ($target -cin @($exports | ForEach-Object Target)) { throw "Duplicate carryover target: $target" }
        if ($source -eq 'not-applicable') {
            if ($target -cne 'attachments/drafts/glossary.md') { throw 'Only an inapplicable glossary can omit a source.' }
        }
        else {
            $sourcePath = Resolve-DraftLink -Root $status.Path -Base $designRoot -Link $source
            if (-not $sourcePath -or -not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Carryover source is missing or not local: $source" }
        }
        $exports.Add([pscustomobject]@{ Source = $source; Target = $target; Reason = $reason })
    }
    foreach ($required in @('attachments/drafts/design.md', 'attachments/drafts/handoff.md', 'attachments/drafts/glossary.md')) {
        if ($required -cnotin @($exports | ForEach-Object Target)) { throw "Carryover omits required export: $required" }
    }
    $references = [System.Collections.Generic.List[string]]::new()
    $workspaceBase = (Get-HarnessRecordRoot $Context)
    foreach ($file in @($designPath, $handoffPath)) {
        $content = [System.IO.File]::ReadAllText($file)
        foreach ($match in [regex]::Matches($content, '\]\((?<link>[^)]+)\)')) {
            $target = Resolve-DraftLink -Root $workspaceBase -Base (Split-Path $file -Parent) -Link $match.Groups['link'].Value
            if ($target -and -not (Test-Path -LiteralPath $target)) { throw "Selected design link target does not exist: $target" }
            if ($target) { $references.Add($target) }
        }
    }
    return [pscustomobject]@{ DraftId = $DraftId; Scope = $Scope; ChangeId = $ChangeId; Path = $designRoot; ExplainedRound = $status.ExplainedRound; ApprovalRound = $round; ExpectedExports = @($exports.ToArray()); ReferencedFiles = @($references.ToArray() | Sort-Object -Unique) }
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
    if (-not $status.Valid) {
        # Preserve the pre-scoped flat handoff format during explicit archive.
        $legacyReadme = [IO.File]::ReadAllText((Join-Path $status.Path 'README.md'))
        $legacyHandoff = $Closure -eq 'completed' -and $status.State -eq 'handed-off' -and
            (Get-DraftMetadata $legacyReadme 'draft') -ceq $DraftId -and
            (Get-DraftMetadata $legacyReadme 'mode') -eq 'design' -and
            (Get-DraftMetadata $legacyReadme 'handed_off') -match '^\d{4}-\d{2}-\d{2}$' -and
            $legacyReadme -notmatch '(?m)^- \*\*(?:此刻|焦点|已决|下一问|讲清于)\*\*'
        if (-not $legacyHandoff) { throw "Cannot archive invalid draft: $($status.Issues -join '; ')" }
        foreach ($file in @('log.md','design.md','handoff.md')) {
            if (-not (Test-Path -LiteralPath (Join-Path $status.Path $file) -PathType Leaf)) { throw "Legacy handoff lacks $file." }
        }
        $targetChange = Get-DraftMetadata $legacyReadme 'target_change'
        Assert-DraftId $targetChange
        $recordRoot = Get-HarnessRecordRoot $Context
        $activeManifest = Join-Path $recordRoot "openspec/changes/$targetChange/change.yaml"
        $archiveDomain = Join-Path $recordRoot ("openspec/archive/changes/" + $targetChange.Split('/')[0])
        [void](Assert-DraftPath -Root $recordRoot -Path $archiveDomain)
        $manifests = @($activeManifest)
        if (Test-Path -LiteralPath $archiveDomain -PathType Container) {
            $manifests += @(Get-ChildItem -LiteralPath $archiveDomain -Directory | ForEach-Object { Join-Path $_.FullName 'change.yaml' })
        }
        $matchingManifests = @($manifests | Where-Object {
            [void](Assert-DraftPath -Root $recordRoot -Path $_)
            (Test-Path -LiteralPath $_ -PathType Leaf) -and (Get-DraftMetadata ([IO.File]::ReadAllText($_)) '  id') -ceq $targetChange
        })
        if ($matchingManifests.Count -ne 1) { throw 'Legacy handoff requires one exact existing target Change.' }
        $status.Next = 'none'
    }
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
    [void](Assert-DraftPath -Root ((Get-HarnessRecordRoot $Context)) -Path $archive)
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

function Invoke-HarnessDraftRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)][ValidateSet('bind', 'sync', 'status', 'unbind')][string]$Action,
        [Parameter(Mandatory)][string]$SessionId,
        [string]$DraftId = '', [string]$Source = '', [int]$StartLine = 0,
        [object]$HookInput = $null
    )
    $scriptPath = Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/draft_record.py'
    $arguments = @('-X', 'utf8', $scriptPath, $Action, '--workspace', [string]$Context.WorkspaceRoot, '--session', $SessionId)
    $arguments += @('--records-root', (Get-HarnessRecordRoot $Context))
    if ($DraftId) { $arguments += @('--draft-id', $DraftId) }
    if ($Source) { $arguments += @('--source', $Source) }
    if ($StartLine) { $arguments += @('--start-line', [string]$StartLine) }
    $output = if ($null -ne $HookInput) {
        $arguments += '--hook-input'
        @(($HookInput | ConvertTo-Json -Depth 30 -Compress) | & python @arguments)
    } else { @(& python @arguments) }
    if ($LASTEXITCODE -notin @(0, 2)) { throw "Draft recorder process failed ($LASTEXITCODE)." }
    $result = ($output -join "`n") | ConvertFrom-Json -ErrorAction Stop
    if ($LASTEXITCODE -eq 2 -and $Action -ne 'status') { throw "Draft recording gap: $($result.gaps -join '; ')" }
    return $result
}

Export-ModuleMember -Function New-HarnessDraft, Get-HarnessDraftStatus, Test-HarnessDraft, Close-HarnessDraft, Invoke-HarnessDraftRecord
