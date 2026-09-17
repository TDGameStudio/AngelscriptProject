#requires -Version 7.0
#requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-HarnessRecordRoot {
    param($Context)
    if ('OpenSpecRoot' -in $Context.PSObject.Properties.Name -and $Context.OpenSpecRoot) { return [string]$Context.OpenSpecRoot }
    return [string]$Context.WorkspaceRoot
}

function Assert-ChangeId {
    param([string]$ChangeId)
    if ($ChangeId -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*/(?:feature|fix|refactor|improve|docs|test|chore)-[a-z0-9]+(?:-[a-z0-9]+){1,}$') {
        throw "Change ID '$ChangeId' must be <domain>/<type>-<scope>-<outcome>."
    }
}

function Get-ChangeRoot {
    param($Context, [string]$ChangeId)
    if ($ChangeId -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw "Change ID '$ChangeId' is not a safe canonical path."
    }
    $root = [System.IO.Path]::GetFullPath((Join-Path ((Get-HarnessRecordRoot $Context)) ('openspec/changes/' + $ChangeId)))
    $base = [System.IO.Path]::GetFullPath((Join-Path ((Get-HarnessRecordRoot $Context)) 'openspec/changes'))
    if (-not $root.StartsWith(($base + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Change path escapes the selected workspace.'
    }
    $cursor = $base
    foreach ($part in @($root.Substring($base.Length).TrimStart('\', '/') -split '[\\/]')) {
        if (-not $part) { continue }
        $cursor = Join-Path $cursor $part
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Change path contains a reparse point: $cursor"
        }
    }
    return $root
}

function Get-ChangeMarker {
    param($Context, [string]$ChangeId, [switch]$Required)
    $root = Get-ChangeRoot $Context $ChangeId
    if (-not (Test-Path -LiteralPath (Join-Path $root 'change.yaml') -PathType Leaf)) { throw "Change '$ChangeId' does not exist." }
    $path = Join-Path $root 'attachments/data/harness-origin.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        if ($Required) { throw "Change '$ChangeId' has no Harness creation marker." }
        $exemptionsPath = Join-Path ([string]$Context.HarnessRoot) '.agents/skills/harness/scripts/legacy-change-plan-exemptions.json'
        if (Test-Path -LiteralPath $exemptionsPath -PathType Leaf) {
            $exemptions = Get-Content -LiteralPath $exemptionsPath -Raw | ConvertFrom-Json
            if ($exemptions.schema -ne 1 -or $ChangeId -cnotin @($exemptions.activeChangeIds)) {
                throw "Unmarked Change '$ChangeId' is not in the pre-gate active Change snapshot. Restore its origin marker before planning."
            }
        }
        return $null
    }
    $marker = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($marker.schema -notin @(1, 2) -or $marker.changeId -cne $ChangeId -or $marker.origin -notin @('Draft', 'Direct')) {
        throw "Change '$ChangeId' has an invalid Harness creation marker."
    }
    return $marker
}

function New-HarnessChange {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Context,
        [Parameter(Mandatory = $true)][string]$ChangeId,
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Goal,
        [Parameter(Mandatory = $true)][ValidateSet('Draft', 'Direct')][string]$Origin,
        [string]$DraftId = '', [string]$Scope = '', [string]$Reason = ''
    )
    Assert-ChangeId $ChangeId
    $root = Get-ChangeRoot $Context $ChangeId
    if (Test-Path -LiteralPath $root) { throw "Change '$ChangeId' already exists; resume its exact export or plan." }
    if ($Origin -eq 'Draft') {
        if (-not $DraftId -or -not $Scope) { throw 'Draft creation requires DraftId and Scope.' }
        Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/DraftLifecycle.psd1') -ErrorAction Stop
        $draft = Test-HarnessDraft -Context $Context -DraftId $DraftId -Scope $Scope -ChangeId $ChangeId
    }
    else {
        if ([string]::IsNullOrWhiteSpace($Reason)) { throw 'Direct Change creation requires the reason for skipping a draft.' }
        if ($DraftId -or $Scope) { throw 'Direct Change creation cannot claim a draft scope.' }
    }
    $exe = Join-Path ([string]$Context.HarnessRoot) '.agents/skills/openspec/bin/openspec.exe'
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw "Portable OpenSpec CLI is missing: $exe" }
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        Push-Location -LiteralPath (Get-HarnessRecordRoot $Context)
        try {
            $output = @(& $exe change create $ChangeId --title $Title --goal $Goal --json 2>&1)
            $exitCode = $LASTEXITCODE
        }
        finally { Pop-Location }
    }
    finally { $ErrorActionPreference = $oldPreference }
    if ($exitCode -ne 0) { throw "OpenSpec change create failed ($exitCode): $($output -join ' ')" }
    if (-not (Test-Path -LiteralPath (Join-Path $root 'change.yaml') -PathType Leaf)) { throw 'OpenSpec reported success but did not create the expected Change.' }
    $markerPath = Join-Path $root 'attachments/data/harness-origin.json'
    [void][System.IO.Directory]::CreateDirectory((Split-Path $markerPath -Parent))
    $marker = [ordered]@{
        schema = 2; changeId = $ChangeId; origin = $Origin
        draftId = if ($Origin -eq 'Draft') { $DraftId } else { $null }
        scope = if ($Origin -eq 'Draft') { $Scope } else { $null }
        reason = if ($Origin -eq 'Direct') { $Reason } else { $null }
        approvalRound = if ($Origin -eq 'Draft') { $draft.ApprovalRound } else { $null }
        expectedExports = if ($Origin -eq 'Draft') { @($draft.ExpectedExports) } else { @() }
        createdAt = [DateTime]::UtcNow.ToString('o')
    }
    [System.IO.File]::WriteAllText($markerPath, (($marker | ConvertTo-Json -Depth 5) + "`n"), [System.Text.UTF8Encoding]::new($false))
    return [pscustomobject]@{ ChangeId = $ChangeId; Path = $root; Origin = $Origin; Marker = $markerPath }
}

function Get-LocalMarkdownTargets {
    param([string]$File, [string]$Root)
    $content = [System.IO.File]::ReadAllText($File)
    foreach ($match in [regex]::Matches($content, '\]\((?<target>[^)]+)\)')) {
        $value = $match.Groups['target'].Value
        if ($value -match '^(?:https?:|mailto:|#)') { continue }
        if ($value -match 'openspec[/\\]drafts[/\\]') { throw "Change link in '$File' depends on local draft content: $value" }
        $relative = ($value -split '#', 2)[0]
        if (-not $relative) { continue }
        $target = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $File -Parent) $relative))
        if (-not $target.StartsWith(($Root + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Change link in '$File' escapes the Change: $value"
        }
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Change link in '$File' is missing: $value" }
        $item = Get-Item -LiteralPath $target
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Change link resolves through a reparse point: $value" }
        $target
    }
}

function Test-HarnessChangeSeed {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$ChangeId)
    $marker = Get-ChangeMarker $Context $ChangeId -Required
    $root = Get-ChangeRoot $Context $ChangeId
    if ($marker.origin -eq 'Direct') {
        if ([string]::IsNullOrWhiteSpace([string]$marker.reason)) { throw 'Direct Change marker has no skipped-draft reason.' }
        return [pscustomobject]@{ ChangeId = $ChangeId; Origin = 'Direct'; Seeded = $true }
    }
    $indexPath = Join-Path $root 'attachments/INDEX.md'
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) { throw 'Draft Change needs attachments/INDEX.md before planning.' }
    foreach ($relative in @('attachments/drafts/design.md', 'attachments/drafts/handoff.md', 'attachments/drafts/glossary.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw "Draft export is missing '$relative'." }
    }
    $exportedHandoff = [System.IO.File]::ReadAllText((Join-Path $root 'attachments/drafts/handoff.md'))
    if ($exportedHandoff -notmatch [regex]::Escape($ChangeId)) { throw 'Exported handoff does not name this Change.' }
    if ($marker.schema -eq 2) {
        if ($marker.approvalRound -cnotmatch '^R[0-9]+$' -or -not $marker.scope -or -not $marker.draftId) { throw 'Draft marker has incomplete approval identity.' }
        foreach ($field in @(@('Scope', $marker.scope), @('Target Change', $ChangeId))) {
            $entries = [regex]::Matches($exportedHandoff, ('(?m)^- {0}:\s*`?(?<value>[^`\r\n]+)`?\s*$' -f [regex]::Escape($field[0])))
            if ($entries.Count -ne 1 -or $entries[0].Groups['value'].Value.Trim() -cne $field[1]) { throw 'Exported handoff identity differs from its creation marker.' }
        }
        $targets = @($marker.expectedExports | ForEach-Object { [string]$_.Target })
        foreach ($required in @('attachments/drafts/design.md', 'attachments/drafts/handoff.md', 'attachments/drafts/glossary.md')) {
            if ($required -cnotin $targets) { throw "Origin marker is missing expected export: $required" }
        }
        foreach ($target in $targets) {
            if ($target -cnotmatch '^attachments/(?:drafts|talks|knowledges)/[a-zA-Z0-9_./-]+\.md$' -or '..' -in ($target -split '/') -or @($targets | Where-Object { $_ -ceq $target }).Count -ne 1) { throw "Invalid or duplicate expected export: $target" }
            if (-not (Test-Path -LiteralPath (Join-Path $root $target) -PathType Leaf)) { throw "Promised export is missing: $target" }
        }
    }
    $index = [System.IO.File]::ReadAllText($indexPath)
    $attachmentRoot = Join-Path $root 'attachments'
    $files = @(Get-ChildItem -LiteralPath $attachmentRoot -File -Recurse | Where-Object { $_.FullName -ne $indexPath })
    foreach ($file in $files) {
        $relative = [System.IO.Path]::GetRelativePath($attachmentRoot, $file.FullName).Replace('\', '/')
        $indexCount = [regex]::Matches($index, ('\]\({0}\)' -f [regex]::Escape($relative))).Count
        if ($indexCount -ne 1) { throw "Attachment '$relative' must be indexed exactly once (actual $indexCount)." }
        if ($file.Extension -eq '.md') { [void]@(Get-LocalMarkdownTargets -File $file.FullName -Root $root) }
    }
    [void]@(Get-LocalMarkdownTargets -File $indexPath -Root $root)
    return [pscustomobject]@{ ChangeId = $ChangeId; Origin = 'Draft'; Seeded = $true; Indexed = $files.Count }
}

function Test-HarnessChangePlan {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$ChangeId)
    $marker = Get-ChangeMarker $Context $ChangeId
    if ($null -eq $marker) { return [pscustomobject]@{ ChangeId = $ChangeId; Grandfathered = $true } }
    [void](Test-HarnessChangeSeed -Context $Context -ChangeId $ChangeId)
    $root = Get-ChangeRoot $Context $ChangeId
    $path = Join-Path $root 'design.md'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "New Change '$ChangeId' needs its own design.md before tasks are Ready." }
    $text = [System.IO.File]::ReadAllText($path)
    $heading = [regex]::Match($text, '(?m)^## Call chains\s*$')
    if (-not $heading.Success) { throw "New Change '$ChangeId' design.md needs a '## Call chains' section." }
    $body = [regex]::Split($text.Substring($heading.Index + $heading.Length), '(?m)^## ')[0].Trim()
    if ($body -match '(?im)^none\b') {
        if ($body -notmatch '(?im)^none\s*[-—:]\s*\S+') { throw 'Non-code call chains need none and a concrete reason.' }
    }
    elseif ($body -notmatch '(?:->|→)' -or $body -notmatch '(?im)^Measured at:.*\b[0-9a-f]{7,40}\b' -or $body -notmatch '(?i)dirty\s*:') {
        throw 'Code call chains need a caller-to-callee path, Measured at with a Git SHA, and a dirty-path note.'
    }
    [void]@(Get-LocalMarkdownTargets -File $path -Root $root)
    return [pscustomobject]@{ ChangeId = $ChangeId; Origin = $marker.origin; Design = $path; Valid = $true }
}

function Test-HarnessChangeSeedIfNeeded {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Context, [Parameter(Mandatory = $true)][string]$ChangeId)
    $marker = Get-ChangeMarker $Context $ChangeId
    if ($null -eq $marker) { return [pscustomobject]@{ ChangeId = $ChangeId; Grandfathered = $true } }
    return Test-HarnessChangeSeed -Context $Context -ChangeId $ChangeId
}

Export-ModuleMember -Function New-HarnessChange, Test-HarnessChangeSeed, Test-HarnessChangePlan, Test-HarnessChangeSeedIfNeeded
