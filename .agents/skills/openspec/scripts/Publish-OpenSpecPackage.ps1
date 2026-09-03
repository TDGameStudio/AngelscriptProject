[CmdletBinding()]
param(
    [string]$ProjectRoot,
    [string]$Version
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$packageSafetyModule = Join-Path $PSScriptRoot 'OpenSpecPackageSafety.psm1'
Import-Module -Name $packageSafetyModule -Force

function Get-CommandDocsDigest {
    param(
        [Parameter(Mandatory = $true)][string]$DocsRoot,
        [Parameter(Mandatory = $true)][System.IO.FileInfo[]]$Files
    )
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
    try {
        [byte[]]$separator = @(0)
        foreach ($file in $Files) {
            $relative = $file.FullName.Substring($DocsRoot.Length).TrimStart('\', '/').Replace('\', '/')
            [byte[]]$pathBytes = [System.Text.Encoding]::UTF8.GetBytes($relative)
            [byte[]]$sourceBytes = [System.IO.File]::ReadAllBytes($file.FullName)
            $documentText = $utf8.GetString($sourceBytes).Replace("`r`n", "`n").Replace("`r", "`n")
            [byte[]]$fileBytes = $utf8.GetBytes($documentText)
            if ($pathBytes.Length -gt 0) { [void]$algorithm.TransformBlock($pathBytes, 0, $pathBytes.Length, $pathBytes, 0) }
            [void]$algorithm.TransformBlock($separator, 0, 1, $separator, 0)
            if ($fileBytes.Length -gt 0) { [void]$algorithm.TransformBlock($fileBytes, 0, $fileBytes.Length, $fileBytes, 0) }
            [void]$algorithm.TransformBlock($separator, 0, 1, $separator, 0)
        }
        [void]$algorithm.TransformFinalBlock([byte[]]@(), 0, 0)
        ([System.BitConverter]::ToString($algorithm.Hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $algorithm.Dispose()
    }
}

function Invoke-GitText {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $output = @(& git -C $Repository @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed:`n$($output -join [Environment]::NewLine)"
    }
    ($output -join [Environment]::NewLine).Trim()
}

function Invoke-ReleaseGate {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    Write-Host "Release gate: $Command"
    $output = @(& $Action 2>&1)
    $exitCode = $LASTEXITCODE
    foreach ($line in $output) { Write-Host $line }
    if ($exitCode -ne 0) { throw "Release gate failed ($exitCode): $Command" }
    [ordered]@{ command = $Command; status = 'passed'; exitCode = 0 }
}

function Invoke-ReproducibleReleaseGate {
    param(
        [Parameter(Mandatory = $true)][string]$SourceRoot,
        [Parameter(Mandatory = $true)][string]$ReferenceExecutable
    )

    $targetRoot = Assert-OpenSpecSafeContainedPath -Root $SourceRoot -Path (Join-Path $SourceRoot 'target') -Description 'Cargo target root'
    $reproRoot = Assert-OpenSpecSafeContainedPath -Root $SourceRoot -Path (Join-Path $targetRoot ('.release-repro.' + [guid]::NewGuid().ToString('N'))) -Description 'isolated reproducibility target'
    $reproExecutable = Join-Path $reproRoot 'release\openspec.exe'
    $command = 'cargo build --release --locked --target-dir <isolated> and byte-compare'
    Write-Host "Release gate: $command"

    try {
        [void](New-Item -ItemType Directory -Path $reproRoot)
        [void](Assert-OpenSpecSafeTree -Root $SourceRoot -Path $reproRoot -Description 'created reproducibility target')
        Push-Location $SourceRoot
        try {
            $output = @(& cargo build --release --locked --target-dir $reproRoot 2>&1)
            $exitCode = $LASTEXITCODE
        }
        finally { Pop-Location }
        foreach ($line in $output) { Write-Host $line }
        if ($exitCode -ne 0) { throw "Release gate failed ($exitCode): $command" }

        [void](Assert-OpenSpecSafeExistingPath -Path $ReferenceExecutable -Description 'reference Release executable' -Leaf)
        [void](Assert-OpenSpecSafeTree -Root $SourceRoot -Path $reproRoot -Description 'completed reproducibility target')
        [void](Assert-OpenSpecSafeExistingPath -Path $reproExecutable -Description 'isolated Release executable' -Leaf)
        $referenceHash = (Get-FileHash -LiteralPath $ReferenceExecutable -Algorithm SHA256).Hash.ToLowerInvariant()
        $reproHash = (Get-FileHash -LiteralPath $reproExecutable -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($referenceHash -ne $reproHash) {
            throw "Release executable is not byte-reproducible: reference $referenceHash, isolated $reproHash."
        }
        [ordered]@{
            command = $command
            status = 'passed'
            exitCode = 0
            sha256 = $referenceHash
        }
    }
    finally {
        try { Remove-OpenSpecSafePackagePath -Root $SourceRoot -Path $reproRoot -Description 'reproducibility target cleanup' }
        catch { throw "Reproducibility cleanup was refused; recovery path is preserved at '${reproRoot}': $($_.Exception.Message)" }
    }
}

function Assert-PackagePayload {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][string]$Docs,
        [Parameter(Mandatory = $true)][string]$Manifest,
        [Parameter(Mandatory = $true)][string]$ReleaseVersion
    )

    if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) { throw "Package executable is missing: $Executable" }
    if (-not (Test-Path -LiteralPath $Docs -PathType Container)) { throw "Package command docs are missing: $Docs" }
    if (-not (Test-Path -LiteralPath $Manifest -PathType Leaf)) { throw "Package manifest is missing: $Manifest" }

    $versionText = (& $Executable --version | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $versionText -ne "openspec $ReleaseVersion") {
        throw "Package executable reports '$versionText', expected 'openspec $ReleaseVersion'."
    }

    $metadata = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
    $docsFiles = @(Get-ChildItem -LiteralPath $Docs -Recurse -File -Filter '*.md' | Sort-Object FullName)
    if ($docsFiles.Count -ne 32) { throw "Package command docs must contain 32 Markdown files; found $($docsFiles.Count)." }
    $actualHash = (Get-FileHash -LiteralPath $Executable -Algorithm SHA256).Hash.ToLowerInvariant()
    $actualDigest = Get-CommandDocsDigest -DocsRoot $Docs -Files $docsFiles
    if ($metadata.version -ne $ReleaseVersion) { throw 'Package manifest version verification failed.' }
    if ($metadata.sha256 -ne $actualHash) { throw 'Package executable hash verification failed.' }
    if ($metadata.commandDocCount -ne $docsFiles.Count) { throw 'Package command-doc count verification failed.' }
    if ($metadata.commandDocsDigest -ne $actualDigest) { throw 'Package command-doc digest verification failed.' }
}

function Publish-OpenSpecPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [string]$ReleaseVersion
    )

    $resolvedRoot = [System.IO.Path]::GetFullPath($Root)
    $sourceRoot = Join-Path $resolvedRoot 'Tools\openspec'
    $skillRoot = Join-Path $resolvedRoot '.agents\skills\openspec'
    $sourceExe = Join-Path $sourceRoot 'target\release\openspec.exe'
    $sourceDocs = Join-Path $sourceRoot 'docs\commands'
    $targetExe = Join-Path $skillRoot 'bin\openspec.exe'
    $targetDocs = Join-Path $skillRoot 'commands'
    $manifestPath = Join-Path $skillRoot 'release-manifest.json'

    # This is deliberately the first filesystem boundary gate in the publisher.
    # It rejects linked roots and linked ancestors before cargo, staging, backup,
    # package replacement, or cleanup can write through them.
    Assert-OpenSpecPackagePreflight -ProjectRoot $resolvedRoot -SourceRoot $sourceRoot -SourceDocs $sourceDocs -SkillRoot $skillRoot
    foreach ($packagePath in @($sourceExe, $targetExe, $targetDocs, $manifestPath)) {
        $packagePathRoot = if ($packagePath -eq $sourceExe) { $sourceRoot } else { $skillRoot }
        [void](Assert-OpenSpecSafeContainedPath -Root $packagePathRoot -Path $packagePath -Description 'package path')
    }

    if ([string]::IsNullOrWhiteSpace($ReleaseVersion)) {
        $cargoText = Get-Content -LiteralPath (Join-Path $sourceRoot 'Cargo.toml') -Raw
        $packageBlock = [regex]::Match($cargoText, '(?ms)^\[package\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
        $versionMatch = [regex]::Match($packageBlock.Groups['body'].Value, '(?m)^version\s*=\s*"(?<version>[^"]+)"\s*$')
        if (-not $packageBlock.Success -or -not $versionMatch.Success) {
            throw 'Unable to resolve the OpenSpec package version from Cargo.toml.'
        }
        $ReleaseVersion = $versionMatch.Groups['version'].Value
    }
    if ($ReleaseVersion -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') {
        throw "Invalid OpenSpec release version: $ReleaseVersion"
    }

    $dirty = @(git -C $sourceRoot status --porcelain --untracked-files=all)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to read the OpenSpec source status.' }
    if ($dirty.Count -ne 0) { throw "OpenSpec source must be clean before packaging:`n$($dirty -join [Environment]::NewLine)" }

    $sourceCommit = Invoke-GitText -Repository $sourceRoot -Arguments @('rev-parse', 'HEAD')
    $expectedTag = "v$ReleaseVersion"
    $tagRef = "refs/tags/$expectedTag"
    $sourceTagObject = Invoke-GitText -Repository $sourceRoot -Arguments @('rev-parse', '--verify', $tagRef)
    $sourceTagType = Invoke-GitText -Repository $sourceRoot -Arguments @('cat-file', '-t', $sourceTagObject)
    if ($sourceTagType -ne 'tag') { throw "$expectedTag must be an annotated tag object (got '$sourceTagType')." }
    $sourceTagTarget = Invoke-GitText -Repository $sourceRoot -Arguments @('rev-parse', "$tagRef^{}")
    if ($sourceTagTarget -ne $sourceCommit) { throw "$expectedTag peels to $sourceTagTarget instead of source commit $sourceCommit." }

    $releaseGates = @()
    Push-Location $sourceRoot
    try {
        $releaseGates += Invoke-ReleaseGate -Command 'cargo fmt --check' -Action { & cargo fmt --check }
        $releaseGates += Invoke-ReleaseGate -Command 'cargo clippy --locked --all-targets -- -D warnings' -Action { & cargo clippy --locked --all-targets -- -D warnings }
        $releaseGates += Invoke-ReleaseGate -Command 'cargo test --locked --all-targets' -Action { & cargo test --locked --all-targets }
        $releaseGates += Invoke-ReleaseGate -Command 'cargo test --locked --test command_docs' -Action { & cargo test --locked --test command_docs }
        $releaseGates += Invoke-ReleaseGate -Command 'cargo build --release --locked' -Action { & cargo build --release --locked }
        $releaseGates += Invoke-ReproducibleReleaseGate -SourceRoot $sourceRoot -ReferenceExecutable $sourceExe
    }
    finally { Pop-Location }

    if ((Invoke-GitText -Repository $sourceRoot -Arguments @('rev-parse', 'HEAD')) -ne $sourceCommit) {
        throw 'OpenSpec source commit changed while release gates were running.'
    }
    if ((Invoke-GitText -Repository $sourceRoot -Arguments @('rev-parse', '--verify', $tagRef)) -ne $sourceTagObject -or
        (Invoke-GitText -Repository $sourceRoot -Arguments @('rev-parse', "$tagRef^{}")) -ne $sourceCommit) {
        throw 'OpenSpec annotated release tag changed while release gates were running.'
    }
    $postGateDirty = @(git -C $sourceRoot status --porcelain --untracked-files=all)
    if ($LASTEXITCODE -ne 0 -or $postGateDirty.Count -ne 0) {
        throw "OpenSpec source changed while release gates were running:`n$($postGateDirty -join [Environment]::NewLine)"
    }
    [void](Assert-OpenSpecSafeExistingPath -Path $sourceExe -Description 'locked Release executable' -Leaf)

    $sourceVersion = (& $sourceExe --version | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $sourceVersion -ne "openspec $ReleaseVersion") {
        throw "Release executable reports '$sourceVersion', expected 'openspec $ReleaseVersion'."
    }
    [void](Assert-OpenSpecSafeTree -Root $sourceRoot -Path $sourceDocs -Description 'OpenSpec command docs')
    $sourceDocFiles = @(Get-ChildItem -LiteralPath $sourceDocs -Recurse -File -Filter '*.md' | Sort-Object FullName)
    if ($sourceDocFiles.Count -ne 32) {
        throw "Command docs must contain README plus 31 command/group documents; found $($sourceDocFiles.Count)."
    }
    $commandDocsDigest = Get-CommandDocsDigest -DocsRoot $sourceDocs -Files $sourceDocFiles

    $rustVerbose = @(& rustc --version --verbose)
    if ($LASTEXITCODE -ne 0) { throw 'rustc --version --verbose failed.' }
    $hostLine = $rustVerbose | Where-Object { $_ -like 'host:*' } | Select-Object -First 1
    $target = if ($hostLine) { $hostLine.Substring(5).Trim() } else { 'unknown' }
    $cargoVersion = (& cargo --version | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'cargo --version failed.' }

    $stageRoot = Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path (Join-Path $skillRoot ('.release-stage.' + [guid]::NewGuid().ToString('N'))) -Description 'release stage'
    $backupRoot = Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path (Join-Path $skillRoot ('.release-backup.' + [guid]::NewGuid().ToString('N'))) -Description 'release backup'
    $stagedExe = Join-Path $stageRoot 'openspec.exe'
    $stagedDocs = Join-Path $stageRoot 'commands'
    $stagedManifest = Join-Path $stageRoot 'release-manifest.json'

    $transactionSucceeded = $false
    $preserveBackup = $false
    try {
        [void](Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path $stageRoot -Description 'release stage before creation')
        [void](New-Item -ItemType Directory -Path $stageRoot)
        [void](Assert-OpenSpecSafeTree -Root $skillRoot -Path $stageRoot -Description 'created release stage')
        [void](Assert-OpenSpecSafeExistingPath -Path $sourceExe -Description 'release executable before staging' -Leaf)
        [void](Assert-OpenSpecSafeTree -Root $sourceRoot -Path $sourceDocs -Description 'command docs before staging')
        Copy-Item -LiteralPath $sourceExe -Destination $stagedExe
        Copy-Item -LiteralPath $sourceDocs -Destination $stagedDocs -Recurse
        [void](Assert-OpenSpecSafeTree -Root $skillRoot -Path $stageRoot -Description 'staged package payload')

        $manifest = [ordered]@{
            version = $ReleaseVersion
            sourceCommit = $sourceCommit
            sourceTag = $expectedTag
            sourceTagType = 'annotated'
            sourceTagObject = $sourceTagObject
            sourceTagTarget = $sourceTagTarget
            target = $target
            profile = 'release'
            buildCommand = 'cargo build --release --locked'
            rustc = $rustVerbose[0]
            cargo = $cargoVersion
            sha256 = (Get-FileHash -LiteralPath $stagedExe -Algorithm SHA256).Hash.ToLowerInvariant()
            binarySize = (Get-Item -LiteralPath $stagedExe).Length
            commandDocCount = $sourceDocFiles.Count
            commandDocsDigest = $commandDocsDigest
            releaseGates = $releaseGates
        }
        $json = ($manifest | ConvertTo-Json -Depth 6 -Compress) + "`n"
        [void](Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path $stagedManifest -Description 'staged manifest before write')
        [System.IO.File]::WriteAllText($stagedManifest, $json, [System.Text.UTF8Encoding]::new($false))
        [void](Assert-OpenSpecSafeTree -Root $skillRoot -Path $stageRoot -Description 'complete staged package payload')
        Assert-PackagePayload -Executable $stagedExe -Docs $stagedDocs -Manifest $stagedManifest -ReleaseVersion $ReleaseVersion

        foreach ($targetPath in @($targetExe, $targetDocs, $manifestPath)) {
            [void](Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path $targetPath -Description 'package target before swap')
            if (Test-Path -LiteralPath $targetPath) {
                [void](Assert-OpenSpecSafeTree -Root $skillRoot -Path $targetPath -Description 'existing package target before swap')
            }
        }
        $targetBin = Split-Path -Parent $targetExe
        [void](Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path $targetBin -Description 'package bin before creation')
        [void](New-Item -ItemType Directory -Path $targetBin -Force)
        [void](Assert-OpenSpecSafeExistingPath -Path $targetBin -Description 'package bin after creation' -Container)
        [void](Assert-OpenSpecSafeContainedPath -Root $skillRoot -Path $backupRoot -Description 'release backup before creation')
        [void](New-Item -ItemType Directory -Path $backupRoot)
        [void](Assert-OpenSpecSafeExistingPath -Path $backupRoot -Description 'release backup after creation' -Container)

        $payload = @(
            [pscustomobject]@{ Staged = $stagedExe; Target = $targetExe; Backup = (Join-Path $backupRoot 'openspec.exe') },
            [pscustomobject]@{ Staged = $stagedDocs; Target = $targetDocs; Backup = (Join-Path $backupRoot 'commands') },
            [pscustomobject]@{ Staged = $stagedManifest; Target = $manifestPath; Backup = (Join-Path $backupRoot 'release-manifest.json') }
        )
        $backedUp = @()
        $installed = @()
        try {
            foreach ($item in $payload) {
                if (Test-Path -LiteralPath $item.Target) {
                    Move-OpenSpecSafePackageItem -Root $skillRoot -Source $item.Target -Destination $item.Backup -Description 'package backup move'
                    $backedUp += $item
                }
            }
            foreach ($item in $payload) {
                Move-OpenSpecSafePackageItem -Root $skillRoot -Source $item.Staged -Destination $item.Target -Description 'package install move'
                $installed += $item
            }
            [void](Assert-OpenSpecSafeTree -Root $skillRoot -Path $targetDocs -Description 'installed command docs')
            Assert-PackagePayload -Executable $targetExe -Docs $targetDocs -Manifest $manifestPath -ReleaseVersion $ReleaseVersion
            $transactionSucceeded = $true
        }
        catch {
            $originalError = $_.Exception.Message
            $rollbackErrors = @()
            for ($index = $installed.Count - 1; $index -ge 0; $index--) {
                $item = $installed[$index]
                try {
                    Remove-OpenSpecSafePackagePath -Root $skillRoot -Path $item.Target -Description 'installed rollback target'
                }
                catch { $rollbackErrors += $_.Exception.Message }
            }
            for ($index = $backedUp.Count - 1; $index -ge 0; $index--) {
                $item = $backedUp[$index]
                try {
                    if (Test-Path -LiteralPath $item.Backup) {
                        Move-OpenSpecSafePackageItem -Root $skillRoot -Source $item.Backup -Destination $item.Target -Description 'package rollback restore'
                    }
                }
                catch { $rollbackErrors += $_.Exception.Message }
            }
            if ($rollbackErrors.Count -ne 0) {
                $preserveBackup = $true
                throw "Package swap failed: $originalError. Rollback also failed; recovery payload is preserved at ${backupRoot}: $($rollbackErrors -join '; ')"
            }
            try { Remove-OpenSpecSafePackagePath -Root $skillRoot -Path $backupRoot -Description 'rolled-back package backup' }
            catch {
                $preserveBackup = $true
                throw "Package swap failed and rollback restored the targets, but cleanup was refused; recovery path is preserved at ${backupRoot}: $($_.Exception.Message)"
            }
            throw "Package swap failed and was rolled back: $originalError"
        }
    }
    finally {
        try { Remove-OpenSpecSafePackagePath -Root $skillRoot -Path $stageRoot -Description 'release stage cleanup' }
        catch { Write-Warning "Release stage cleanup was refused; recovery path is preserved at '${stageRoot}': $($_.Exception.Message)" }
        if (-not $preserveBackup) {
            try { Remove-OpenSpecSafePackagePath -Root $skillRoot -Path $backupRoot -Description 'release backup cleanup' }
            catch {
                $preserveBackup = $true
                Write-Warning "Release backup cleanup was refused; recovery path is preserved at '${backupRoot}': $($_.Exception.Message)"
            }
        }
    }

    Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
}

if (-not $ProjectRoot) {
    $ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
}

Publish-OpenSpecPackage -Root $ProjectRoot -ReleaseVersion $Version
