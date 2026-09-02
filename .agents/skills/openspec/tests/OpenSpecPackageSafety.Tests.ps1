[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    try {
        & $Action
    }
    catch {
        if ([string]::IsNullOrWhiteSpace($Pattern) -or $_.Exception.Message -match $Pattern) { return }
        throw "$Message Unexpected error: $($_.Exception.Message)"
    }
    throw $Message
}

function Remove-TestJunction {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
        throw "Test cleanup refused a non-junction path: $Path"
    }
    [System.IO.Directory]::Delete($item.FullName, $false)
}

$skillRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$modulePath = Join-Path $skillRoot 'scripts\OpenSpecPackageSafety.psm1'
$publisherPath = Join-Path $skillRoot 'scripts\Publish-OpenSpecPackage.ps1'
Import-Module -Name $modulePath -Force

$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) ("openspec-package-safety-{0}" -f [guid]::NewGuid().ToString('N'))))
$externalRoot = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) ("openspec-package-external-{0}" -f [guid]::NewGuid().ToString('N'))))
$junctions = [System.Collections.Generic.List[string]]::new()
try {
    $projectRoot = Join-Path $fixtureRoot 'project'
    $sourceRoot = Join-Path $projectRoot 'Tools\openspec'
    $sourceDocs = Join-Path $sourceRoot 'docs\commands'
    $packageRoot = Join-Path $projectRoot '.agents\skills\openspec'
    foreach ($directory in @($sourceDocs, (Join-Path $packageRoot 'bin'), $externalRoot)) {
        [void](New-Item -ItemType Directory -Path $directory -Force)
    }
    $sentinel = Join-Path $externalRoot 'sentinel.txt'
    [System.IO.File]::WriteAllText($sentinel, 'external-sentinel', [System.Text.UTF8Encoding]::new($false))

    Assert-OpenSpecPackagePreflight -ProjectRoot $projectRoot -SourceRoot $sourceRoot -SourceDocs $sourceDocs -SkillRoot $packageRoot
    $missingStage = Join-Path $packageRoot '.release-stage.missing'
    $resolvedMissingStage = Assert-OpenSpecSafeContainedPath -Root $packageRoot -Path $missingStage -Description 'missing stage'
    Assert-True ($resolvedMissingStage -eq [System.IO.Path]::GetFullPath($missingStage)) 'A safe missing descendant should be accepted.'

    $safeStage = Join-Path $packageRoot '.release-stage.safe'
    [void](New-Item -ItemType Directory -Path $safeStage)
    [System.IO.File]::WriteAllText((Join-Path $safeStage 'payload.txt'), 'payload', [System.Text.UTF8Encoding]::new($false))
    Remove-OpenSpecSafePackagePath -Root $packageRoot -Path $safeStage -Description 'safe stage'
    Assert-True (-not (Test-Path -LiteralPath $safeStage)) 'Safe cleanup did not remove the exact stage directory.'

    $moveStage = Join-Path $packageRoot '.release-stage.move'
    [void](New-Item -ItemType Directory -Path $moveStage)
    $moveSource = Join-Path $moveStage 'release-manifest.json'
    $moveTarget = Join-Path $packageRoot 'moved-release-manifest.json'
    [System.IO.File]::WriteAllText($moveSource, '{}', [System.Text.UTF8Encoding]::new($false))
    Move-OpenSpecSafePackageItem -Root $packageRoot -Source $moveSource -Destination $moveTarget -Description 'direct package-root install'
    Assert-True (Test-Path -LiteralPath $moveTarget -PathType Leaf) 'A safe move directly into the package root must succeed.'
    Remove-OpenSpecSafePackagePath -Root $packageRoot -Path $moveTarget -Description 'moved manifest cleanup'
    Remove-OpenSpecSafePackagePath -Root $packageRoot -Path $moveStage -Description 'move stage cleanup'

    $linkedProjectTarget = Join-Path $externalRoot 'linked-project-target'
    [void](New-Item -ItemType Directory -Path $linkedProjectTarget)
    $linkedProject = Join-Path $fixtureRoot 'linked-project'
    [void](New-Item -ItemType Junction -Path $linkedProject -Target $linkedProjectTarget)
    $junctions.Add($linkedProject)
    Assert-Throws { Assert-OpenSpecSafeExistingPath -Path $linkedProject -Description 'project root' } 'reparse|link' 'A project root junction must be rejected.'
    Assert-Throws { & $publisherPath -ProjectRoot $linkedProject -Version '9.9.9' } 'reparse|link' 'The publisher must reject a linked project root before staging.'
    Assert-True (@(Get-ChildItem -LiteralPath $linkedProjectTarget -Force -Filter '.release-stage.*').Count -eq 0) 'The publisher staged through a linked project root.'

    $ancestorTarget = Join-Path $externalRoot 'ancestor-target'
    [void](New-Item -ItemType Directory -Path (Join-Path $ancestorTarget 'nested-project') -Force)
    $linkedAncestor = Join-Path $fixtureRoot 'linked-ancestor'
    [void](New-Item -ItemType Junction -Path $linkedAncestor -Target $ancestorTarget)
    $junctions.Add($linkedAncestor)
    Assert-Throws { Assert-OpenSpecSafeExistingPath -Path (Join-Path $linkedAncestor 'nested-project') -Description 'project root through linked ancestor' } 'reparse|link' 'A linked ancestor must be rejected.'

    $externalSkill = Join-Path $externalRoot 'external-skill'
    [void](New-Item -ItemType Directory -Path $externalSkill)
    $linkedSkill = Join-Path $projectRoot '.agents\skills\linked-openspec'
    [void](New-Item -ItemType Junction -Path $linkedSkill -Target $externalSkill)
    $junctions.Add($linkedSkill)
    Assert-Throws { Assert-OpenSpecSafeExistingPath -Path $linkedSkill -Description 'skill root' } 'reparse|link' 'A skill root junction must be rejected.'

    $linkedSkillProject = Join-Path $fixtureRoot 'linked-skill-project'
    [void](New-Item -ItemType Directory -Path (Join-Path $linkedSkillProject 'Tools\openspec\docs\commands') -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $linkedSkillProject '.agents\skills') -Force)
    $expectedLinkedSkill = Join-Path $linkedSkillProject '.agents\skills\openspec'
    [void](New-Item -ItemType Junction -Path $expectedLinkedSkill -Target $externalSkill)
    $junctions.Add($expectedLinkedSkill)
    Assert-Throws { & $publisherPath -ProjectRoot $linkedSkillProject -Version '9.9.9' } 'reparse|link' 'The publisher must reject a linked skill root before staging.'
    Assert-True (@(Get-ChildItem -LiteralPath $externalSkill -Force -Filter '.release-stage.*').Count -eq 0) 'The publisher staged through a linked skill root.'

    foreach ($leaf in @('commands', '.release-stage.changed', '.release-backup.changed')) {
        $linkedPath = Join-Path $packageRoot $leaf
        [void](New-Item -ItemType Junction -Path $linkedPath -Target $externalRoot)
        $junctions.Add($linkedPath)
        Assert-Throws { Assert-OpenSpecSafeContainedPath -Root $packageRoot -Path $linkedPath -Description $leaf } 'reparse|link' "A linked $leaf path must be rejected."
        Assert-Throws { Remove-OpenSpecSafePackagePath -Root $packageRoot -Path $linkedPath -Description $leaf } 'reparse|link' "Cleanup must preserve a linked $leaf path."
        Assert-True (Test-Path -LiteralPath $linkedPath) "Unsafe cleanup removed the linked $leaf recovery path."
        Assert-True ((Get-Content -LiteralPath $sentinel -Raw) -eq 'external-sentinel') "Unsafe cleanup changed the external sentinel for $leaf."
        Remove-TestJunction -Path $linkedPath
        [void]$junctions.Remove($linkedPath)
    }

    $externalBin = Join-Path $externalRoot 'external-bin'
    [void](New-Item -ItemType Directory -Path $externalBin)
    $binPath = Join-Path $packageRoot 'bin'
    Remove-Item -LiteralPath $binPath -Force
    [void](New-Item -ItemType Junction -Path $binPath -Target $externalBin)
    $junctions.Add($binPath)
    Assert-Throws { Assert-OpenSpecSafeContainedPath -Root $packageRoot -Path (Join-Path $binPath 'openspec.exe') -Description 'target executable' } 'reparse|link' 'A linked bin path must be rejected.'
    Assert-True ((Get-Content -LiteralPath $sentinel -Raw) -eq 'external-sentinel') 'The linked bin probe changed the external sentinel.'
    Remove-TestJunction -Path $binPath
    [void]$junctions.Remove($binPath)
    [void](New-Item -ItemType Directory -Path $binPath)

    $nestedStage = Join-Path $packageRoot '.release-stage.nested-link'
    [void](New-Item -ItemType Directory -Path $nestedStage)
    $nestedLink = Join-Path $nestedStage 'external'
    [void](New-Item -ItemType Junction -Path $nestedLink -Target $externalRoot)
    $junctions.Add($nestedLink)
    Assert-Throws { Remove-OpenSpecSafePackagePath -Root $packageRoot -Path $nestedStage -Description 'stage with linked child' } 'reparse|link' 'Cleanup must reject a linked descendant.'
    Assert-True (Test-Path -LiteralPath $nestedStage) 'Unsafe cleanup removed a recovery stage containing a link.'
    Assert-True ((Get-Content -LiteralPath $sentinel -Raw) -eq 'external-sentinel') 'Nested-link cleanup changed the external sentinel.'
    Remove-TestJunction -Path $nestedLink
    [void]$junctions.Remove($nestedLink)
    Remove-Item -LiteralPath $nestedStage -Recurse -Force

    $publisherText = Get-Content -LiteralPath $publisherPath -Raw
    $preflightIndex = $publisherText.IndexOf('Assert-OpenSpecPackagePreflight', [System.StringComparison]::Ordinal)
    $stageWriteIndex = $publisherText.IndexOf('New-Item -ItemType Directory -Path $stageRoot', [System.StringComparison]::Ordinal)
    Assert-True ($preflightIndex -ge 0 -and $stageWriteIndex -gt $preflightIndex) 'Publisher preflight must occur before stage creation.'
    Assert-True ($publisherText.Contains('$releaseGates += Invoke-ReproducibleReleaseGate')) 'Publisher must enforce a byte-identical isolated Release rebuild.'
    Assert-True (-not $publisherText.Contains('Remove-Item -LiteralPath $stageRoot -Recurse')) 'Publisher must not recursively delete the stage without the safety helper.'
    Assert-True (-not $publisherText.Contains('Remove-Item -LiteralPath $backupRoot -Recurse')) 'Publisher must not recursively delete the backup without the safety helper.'

    Assert-True ((Get-Content -LiteralPath $sentinel -Raw) -eq 'external-sentinel') 'Package safety tests changed the external sentinel.'
}
finally {
    for ($index = $junctions.Count - 1; $index -ge 0; $index--) {
        try { Remove-TestJunction -Path $junctions[$index] } catch { Write-Warning $_.Exception.Message }
    }
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
    if (Test-Path -LiteralPath $externalRoot) { Remove-Item -LiteralPath $externalRoot -Recurse -Force }
}

Write-Host 'OpenSpec package safety tests passed.'
