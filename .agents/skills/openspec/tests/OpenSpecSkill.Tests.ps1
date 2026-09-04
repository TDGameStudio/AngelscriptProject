[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Equal {
    param($Actual, $Expected, [string]$Message)
    if ($Actual -ne $Expected) {
        throw "$Message (expected '$Expected', got '$Actual')"
    }
}

function Test-ContainsDisallowedOpenSpecLanguage {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    $letterCategories = @(
        [System.Globalization.UnicodeCategory]::UppercaseLetter,
        [System.Globalization.UnicodeCategory]::LowercaseLetter,
        [System.Globalization.UnicodeCategory]::TitlecaseLetter,
        [System.Globalization.UnicodeCategory]::ModifierLetter,
        [System.Globalization.UnicodeCategory]::OtherLetter,
        [System.Globalization.UnicodeCategory]::NonSpacingMark,
        [System.Globalization.UnicodeCategory]::SpacingCombiningMark,
        [System.Globalization.UnicodeCategory]::EnclosingMark
    )
    for ($index = 0; $index -lt $Text.Length; $index++) {
        $codeUnit = [int]$Text[$index]
        if ($codeUnit -le 0x7F) { continue }
        $category = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($Text, $index)
        if ($category -in $letterCategories -or $category -eq [System.Globalization.UnicodeCategory]::DecimalDigitNumber) {
            return $true
        }
        if ([char]::IsHighSurrogate($Text[$index]) -and $index + 1 -lt $Text.Length -and [char]::IsLowSurrogate($Text[$index + 1])) {
            $index++
        }
    }
    return $false
}

function Test-IsOpenSpecLocalizationExempt {
    param([Parameter(Mandatory = $true)][string]$FileName)
    return $FileName -cmatch '_ZH(?:\.|$)'
}

function Test-IsLikelyOpenSpecTextFile {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    $textExtensions = @(
        '.bat', '.cfg', '.cmd', '.conf', '.css', '.csv', '.editorconfig', '.fish',
        '.gitattributes', '.gitignore', '.html', '.ini', '.js', '.json', '.lock',
        '.md', '.ps1', '.psd1', '.psm1', '.rs', '.sh', '.toml', '.ts', '.tsx',
        '.txt', '.xml', '.yaml', '.yml', '.zsh'
    )
    $extension = $File.Extension.ToLowerInvariant()
    if ($extension -in $textExtensions -or $File.Name -in @('.gitignore', '.gitattributes', '.editorconfig')) {
        return $true
    }
    if (-not [string]::IsNullOrEmpty($extension)) { return $false }

    $stream = [System.IO.File]::OpenRead($File.FullName)
    try {
        $buffer = New-Object byte[] ([int]$stream.Length)
        if ($buffer.Length -gt 0) { [void]$stream.Read($buffer, 0, $buffer.Length) }
        if ($buffer -contains 0) { return $false }
        $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
        try { [void]$strictUtf8.GetString($buffer); return $true }
        catch [System.Text.DecoderFallbackException] { return $false }
    }
    finally {
        $stream.Dispose()
    }
}

function Test-ContainsForbiddenOpenSpecLanguageDefault {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ($RelativePath -match '(?i)[\\/]attachments[\\/](?:reviews|replans)[\\/]') { return $false }
    return $Text -match '(?i)\bLanguage:\s*(?:zh(?:-[A-Za-z0-9]+)?|Chinese)\b|\bChinese\s+by\s+default\b|\bdefault(?:s|ed|ing)?\s+to\s+Chinese\b|\bwritten\s+in\s+Chinese\b'
}

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
        return ([System.BitConverter]::ToString($algorithm.Hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $algorithm.Dispose()
    }
}

function Get-OpenSpecEnglishViolations {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $roots = @(
        'Tools\openspec',
        '.agents\skills\openspec',
        'openspec'
    )
    $roots += @(Get-ChildItem -LiteralPath (Join-Path $ProjectRoot '.agents\skills') -Directory -Filter 'openspec-*' | ForEach-Object {
        $_.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
    })
    $standaloneFiles = @(
        '.agents\skills\README.md',
        '.gitignore'
    )
    $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    $allFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    foreach ($relativeRoot in $roots) {
        $root = Join-Path $ProjectRoot $relativeRoot
        if (Test-Path -LiteralPath $root -PathType Container) {
            $rootItem = Get-Item -LiteralPath $root -Force
            if (($rootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                $allFiles.Add($rootItem) | Out-Null
                continue
            }
            $generatedRoots = @(
                [System.IO.Path]::GetFullPath((Join-Path $root 'target')),
                [System.IO.Path]::GetFullPath((Join-Path $root 'build'))
            )
            $pending = New-Object System.Collections.Generic.Stack[string]
            $pending.Push([System.IO.Path]::GetFullPath($root))
            while ($pending.Count -gt 0) {
                $directory = $pending.Pop()
                foreach ($entry in @(Get-ChildItem -LiteralPath $directory -Force)) {
                    if ($entry.PSIsContainer) {
                        $entryFull = [System.IO.Path]::GetFullPath($entry.FullName)
                        if ($entry.Name -ne '.git' -and $entryFull -notin $generatedRoots -and -not ($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                            $pending.Push($entry.FullName)
                        }
                    }
                    elseif (-not ($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -and -not (Test-IsOpenSpecLocalizationExempt -FileName $entry.Name)) {
                        $allFiles.Add($entry) | Out-Null
                        if (Test-IsLikelyOpenSpecTextFile -File $entry) { $files.Add($entry) | Out-Null }
                    }
                }
            }
        }
    }

    foreach ($relativeFile in $standaloneFiles) {
        $file = Join-Path $ProjectRoot $relativeFile
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            $item = Get-Item -LiteralPath $file -Force
            if (-not (Test-IsOpenSpecLocalizationExempt -FileName $item.Name)) {
                $allFiles.Add($item) | Out-Null
                if (Test-IsLikelyOpenSpecTextFile -File $item) { $files.Add($item) | Out-Null }
            }
        }
    }

    $violations = New-Object System.Collections.Generic.List[string]
    foreach ($file in @($allFiles | Sort-Object FullName -Unique)) {
        $relativePath = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
        if (Test-ContainsDisallowedOpenSpecLanguage -Text $relativePath) {
            $violations.Add("non-English path: $relativePath") | Out-Null
        }
    }
    foreach ($file in @($files | Sort-Object FullName -Unique)) {
        $relativePath = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
        $lineNumber = 0
        foreach ($line in [System.IO.File]::ReadLines($file.FullName)) {
            $lineNumber++
            if ((Test-ContainsDisallowedOpenSpecLanguage -Text $line) -or
                (Test-ContainsForbiddenOpenSpecLanguageDefault -Text $line -RelativePath $relativePath)) {
                $violations.Add("${relativePath}:$lineNumber") | Out-Null
            }
        }
    }
    return @($violations | ForEach-Object { $_ })
}

function Get-ScenarioBlock {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name
    )
    $pattern = '(?ms)^#### Scenario: ' + [regex]::Escape($Name) + '\r?\n(?<Body>.*?)(?=^#### Scenario: |^### Requirement: |\z)'
    $match = [regex]::Match($Text, $pattern)
    Assert-True $match.Success "Scenario is missing: $Name"
    return $match.Groups['Body'].Value
}

function Get-LocalMarkdownLinkIssues {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo[]]$Files)

    $issues = @()
    $linkPattern = '(?<!\!)\[[^\]\r\n]+\]\((?<target>(?![A-Za-z][A-Za-z0-9+.-]*:)(?![#/\\])[A-Za-z0-9._/-]+\.(?:md|ps1)(?:#[A-Za-z0-9._-]+)?)\)'
    foreach ($file in $Files) {
        $fileText = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($match in [regex]::Matches($fileText, $linkPattern)) {
            $target = $match.Groups['target'].Value
            $relativePath = ($target -split '#', 2)[0]
            try {
                $resolved = [System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName $relativePath))
            }
            catch {
                $issues += "markdown-link: $($file.FullName) has malformed target '$target'"
                continue
            }
            if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
                $issues += "markdown-link: $($file.FullName) has missing target '$target'"
            }
        }
    }
    return $issues
}

function Get-CapabilityKnowledgeIndexIssues {
    param([Parameter(Mandatory = $true)][string]$SpecsRoot)

    $issues = @()
    if (-not (Test-Path -LiteralPath $SpecsRoot -PathType Container)) {
        return "knowledge-root: current specs root is missing: $SpecsRoot"
    }

    $knowledgeDirectories = @(Get-ChildItem -LiteralPath $SpecsRoot -Recurse -Directory | Where-Object { $_.Name -ceq 'knowledges' })
    foreach ($directory in $knowledgeDirectories) {
        $indexPath = Join-Path $directory.FullName 'INDEX.md'
        if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
            $issues += "knowledge-index: $($directory.FullName) lacks INDEX.md"
            continue
        }

        $indexFile = Get-Item -LiteralPath $indexPath
        $indexText = Get-Content -LiteralPath $indexPath -Raw
        $knowledgeFiles = @(Get-ChildItem -LiteralPath $directory.FullName -File -Filter '*.md' | Where-Object { $_.Name -cne 'INDEX.md' })
        foreach ($knowledgeFile in $knowledgeFiles) {
            $escapedName = [regex]::Escape($knowledgeFile.Name)
            $linkPattern = '\[[^\]\r\n]+\]\((?:\./)?' + $escapedName + '(?:#[A-Za-z0-9._-]+)?\)'
            $matches = [regex]::Matches($indexText, $linkPattern)
            if ($matches.Count -ne 1) {
                $issues += "knowledge-entry: $($directory.FullName) '$($knowledgeFile.Name)' has $($matches.Count) INDEX links"
                continue
            }

            $entryPattern = '(?ims)^-[ \t]+\[[^\]\r\n]+\]\((?:\./)?' + $escapedName + '\)[^\r\n]*\r?\n(?<body>.*?)(?=^-[ \t]+\[|\z)'
            $entry = [regex]::Match($indexText, $entryPattern)
            if (-not $entry.Success) {
                $issues += "knowledge-entry-shape: $($knowledgeFile.Name) is not a top-level INDEX entry"
                continue
            }
            foreach ($field in @('Summary', 'Serves', 'Source', 'Status')) {
                $fieldPattern = '(?im)^[ \t]+-[ \t]+' + [regex]::Escape($field) + '[ \t]*:[ \t]+\S'
                if ($entry.Groups['body'].Value -notmatch $fieldPattern) {
                    $issues += "knowledge-entry-field: $($knowledgeFile.Name) lacks $field"
                }
            }
        }

        $issues += @(Get-LocalMarkdownLinkIssues -Files @($indexFile))
    }
    return $issues
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$harnessManifest = Join-Path $projectRoot '.agents\skills\harness\scripts\Harness.psd1'
$exePath = Join-Path $projectRoot '.agents\skills\openspec\bin\openspec.exe'
$manifestPath = Join-Path $projectRoot '.agents\skills\openspec\release-manifest.json'
$sourceDocs = Join-Path $projectRoot 'Tools\openspec\docs\commands'
$bundledDocs = Join-Path $projectRoot '.agents\skills\openspec\commands'
$cargoText = Get-Content -LiteralPath (Join-Path $projectRoot 'Tools\openspec\Cargo.toml') -Raw
$packageBlock = [regex]::Match($cargoText, '(?ms)^\[package\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
$versionMatch = [regex]::Match($packageBlock.Groups['body'].Value, '(?m)^version\s*=\s*"(?<version>[^"]+)"\s*$')
Assert-True ($packageBlock.Success -and $versionMatch.Success) 'Unable to resolve the OpenSpec source version from Cargo.toml.'
$sourceVersion = $versionMatch.Groups['version'].Value

& (Join-Path $PSScriptRoot 'OpenSpecPackageSafety.Tests.ps1')

foreach ($sample in @(
    @{ Name = 'Greek'; Text = [string][char]0x03B1 },
    @{ Name = 'Armenian'; Text = [string][char]0x0531 },
    @{ Name = 'Georgian'; Text = [string][char]0x10D0 },
    @{ Name = 'Bengali'; Text = [string][char]0x0985 },
    @{ Name = 'Tamil'; Text = [string][char]0x0B85 },
    @{ Name = 'Ethiopic'; Text = [string][char]0x1200 },
    @{ Name = 'Supplementary letter'; Text = [char]::ConvertFromUtf32(0x10400) },
    @{ Name = 'Non-ASCII decimal digit'; Text = [string][char]0x0661 }
)) {
    Assert-True (Test-ContainsDisallowedOpenSpecLanguage -Text $sample.Text) "English gate must reject $($sample.Name) letters."
}
foreach ($allowedSymbol in @([string][char]0x2192, [string][char]0x2014, [string][char]0x2502)) {
    Assert-True (-not (Test-ContainsDisallowedOpenSpecLanguage -Text $allowedSymbol)) 'English gate must allow intentional punctuation and diagram symbols.'
}
Assert-True (Test-IsOpenSpecLocalizationExempt -FileName 'CLI_REFERENCE_ZH.md') 'Exact uppercase _ZH filename marker must be exempt.'
foreach ($ordinaryName in @('CLI_REFERENCE_zh.md', 'CLI_REFERENCE_Zh.md', 'CLI_REFERENCE_ZH_notes.md', 'ZH.md')) {
    Assert-True (-not (Test-IsOpenSpecLocalizationExempt -FileName $ordinaryName)) "Localization exception must not match $ordinaryName."
}

$languageFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path ([System.IO.Path]::GetTempPath()) ("openspec-language-{0}" -f [guid]::NewGuid().ToString('N'))))
try {
    foreach ($directory in @(
        'Tools\openspec\docs',
        '.agents\skills\openspec',
        '.agents\skills\README-parent',
        'openspec\changes\fixture\attachments\reviews'
    )) {
        [void](New-Item -ItemType Directory -Path (Join-Path $languageFixtureRoot $directory) -Force)
    }
    $forbiddenDefaultPhrase = 'OpenSpec records default' + ' to Chinese.'
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot '.agents\skills\README.md'), $forbiddenDefaultPhrase, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot 'Tools\openspec\.gitignore'), "ignored-$([char]0x03B1)", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot 'Tools\openspec\NOTICE'), "notice-$([char]0x0531)", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot '.agents\skills\openspec\lower_zh.md'), "lower-$([char]0x10D0)", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot '.agents\skills\openspec\embedded_ZH_notes.md'), "suffix-$([char]0x0985)", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot '.agents\skills\openspec\allowed_ZH.md'), "allowed-$([char]0x0B85)", [System.Text.UTF8Encoding]::new($false))
    [void](New-Item -ItemType Directory -Path (Join-Path $languageFixtureRoot 'Tools\openspec\parent_ZH') -Force)
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot 'Tools\openspec\parent_ZH\ordinary.md'), "parent-$([char]0x1200)", [System.Text.UTF8Encoding]::new($false))
    $nonEnglishDirectory = Join-Path $languageFixtureRoot ("Tools\openspec\path-{0}" -f [char]0x10D0)
    [void](New-Item -ItemType Directory -Path $nonEnglishDirectory)
    [System.IO.File]::WriteAllText((Join-Path $nonEnglishDirectory 'README.md'), 'ASCII content', [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot 'Tools\openspec\docs\supplementary.txt'), [char]::ConvertFromUtf32(0x10400), [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllBytes((Join-Path $languageFixtureRoot 'Tools\openspec\BINARY'), [byte[]]@(0, 0xCE, 0xB1))
    [System.IO.File]::WriteAllText((Join-Path $languageFixtureRoot 'openspec\changes\fixture\attachments\reviews\quoted.md'), "Evidence: $forbiddenDefaultPhrase", [System.Text.UTF8Encoding]::new($false))

    $fixtureViolations = @(Get-OpenSpecEnglishViolations -ProjectRoot $languageFixtureRoot)
    foreach ($requiredPath in @('.agents\skills\README.md', 'Tools\openspec\.gitignore', 'Tools\openspec\NOTICE', '.agents\skills\openspec\lower_zh.md', '.agents\skills\openspec\embedded_ZH_notes.md', 'Tools\openspec\parent_ZH\ordinary.md', 'Tools\openspec\docs\supplementary.txt')) {
        Assert-True (($fixtureViolations -join "`n").Contains($requiredPath)) "Language fixture was not rejected: $requiredPath"
    }
    Assert-True (@($fixtureViolations | Where-Object { $_ -like 'non-English path:*' }).Count -ge 1) 'Language gate must reject a non-English path segment.'
    foreach ($allowedPath in @('.agents\skills\openspec\allowed_ZH.md', 'Tools\openspec\BINARY', 'attachments\reviews\quoted.md')) {
        Assert-True (-not (($fixtureViolations -join "`n").Contains($allowedPath))) "Language fixture should remain allowed: $allowedPath"
    }
}
finally {
    if (Test-Path -LiteralPath $languageFixtureRoot) { Remove-Item -LiteralPath $languageFixtureRoot -Recurse -Force }
}

$englishViolations = @(Get-OpenSpecEnglishViolations -ProjectRoot $projectRoot)
Assert-Equal $englishViolations.Count 0 "Maintained OpenSpec surfaces must use English; only explicitly named *_ZH files are exempt: $($englishViolations -join ', ')"

Assert-True (Test-Path -LiteralPath $harnessManifest -PathType Leaf) 'Harness module manifest is missing.'
Assert-True (Test-Path -LiteralPath $exePath -PathType Leaf) 'Bundled openspec.exe is missing.'
Assert-True (Test-Path -LiteralPath $manifestPath -PathType Leaf) 'OpenSpec release manifest is missing.'

Import-Module $harnessManifest -Force
$context = New-HarnessContext -WorkspaceRoot $projectRoot
$doctor = Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json')
Assert-Equal $doctor.schemaVersion '1.0' 'Harness returned the wrong schema version.'
Assert-Equal $doctor.status 'Succeeded' 'OpenSpec doctor did not succeed through Harness.'
Assert-Equal $doctor.exitCode 0 'OpenSpec doctor returned a non-zero exit code.'

$versionText = (& $exePath --version | Out-String).Trim()
Assert-Equal $LASTEXITCODE 0 'Bundled openspec.exe --version failed.'
Assert-Equal $versionText "openspec $sourceVersion" 'Bundled executable version does not match Cargo.toml.'

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
Assert-Equal $manifest.version $sourceVersion 'Release manifest version does not match Cargo.toml.'
Assert-Equal $manifest.profile 'release' 'Release manifest profile is wrong.'
Assert-Equal $manifest.sourceTag "v$sourceVersion" 'Release manifest source tag does not match Cargo.toml.'
Assert-Equal $manifest.sourceTagType 'annotated' 'Release manifest must record an annotated source tag.'
Assert-Equal $manifest.buildCommand 'cargo build --release --locked' 'Release manifest must record the locked build command.'
$sourceRoot = Join-Path $projectRoot 'Tools\openspec'
Assert-Equal $manifest.sourceCommit (git -C $sourceRoot rev-parse HEAD).Trim() 'Release manifest source commit does not match the submodule.'
$tagRef = "refs/tags/$($manifest.sourceTag)"
$actualTagObject = (git -C $sourceRoot rev-parse --verify $tagRef | Out-String).Trim()
Assert-Equal $LASTEXITCODE 0 'Release manifest source tag does not exist.'
$actualTagType = (git -C $sourceRoot cat-file -t $actualTagObject | Out-String).Trim()
Assert-Equal $LASTEXITCODE 0 'Unable to inspect the release tag object.'
Assert-Equal $actualTagType 'tag' 'Release source tag must be an annotated tag object.'
$actualTagTarget = (git -C $sourceRoot rev-parse "$tagRef^{}" | Out-String).Trim()
Assert-Equal $LASTEXITCODE 0 'Unable to peel the release source tag.'
Assert-Equal $manifest.sourceTagObject $actualTagObject 'Release manifest tag object does not match Git.'
Assert-Equal $manifest.sourceTagTarget $actualTagTarget 'Release manifest tag target does not match Git.'
Assert-Equal $manifest.sourceCommit $actualTagTarget 'Release tag must peel to the packaged source commit.'

$expectedGateCommands = @(
    'cargo fmt --check',
    'cargo clippy --locked --all-targets -- -D warnings',
    'cargo test --locked --all-targets',
    'cargo test --locked --test command_docs',
    'cargo build --release --locked',
    'cargo build --release --locked --target-dir <isolated> and byte-compare'
)
$releaseGates = @($manifest.releaseGates)
Assert-Equal $releaseGates.Count $expectedGateCommands.Count 'Release manifest gate count is wrong.'
for ($index = 0; $index -lt $expectedGateCommands.Count; $index++) {
    Assert-Equal $releaseGates[$index].command $expectedGateCommands[$index] "Release gate command $index is wrong."
    Assert-Equal $releaseGates[$index].status 'passed' "Release gate $index did not pass."
    Assert-Equal $releaseGates[$index].exitCode 0 "Release gate $index recorded a non-zero exit code."
}
$exeHash = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash.ToLowerInvariant()
Assert-Equal $manifest.sha256.ToLowerInvariant() $exeHash 'Release manifest EXE hash does not match the package.'

$sourceFiles = @(Get-ChildItem -LiteralPath $sourceDocs -Recurse -File -Filter '*.md' | Sort-Object FullName)
$bundledFiles = @(Get-ChildItem -LiteralPath $bundledDocs -Recurse -File -Filter '*.md')
Assert-Equal $sourceFiles.Count 32 'Canonical command docs must contain README plus 31 command/group documents.'
Assert-Equal $bundledFiles.Count 32 'Bundled command docs must contain README plus 31 command/group documents.'
Assert-Equal $manifest.commandDocCount 32 'Release manifest command-doc count is wrong.'
$expectedDocsDigest = Get-CommandDocsDigest -DocsRoot $sourceDocs -Files $sourceFiles
Assert-Equal $manifest.commandDocsDigest $expectedDocsDigest 'Release manifest command-doc digest is wrong.'

foreach ($sourceFile in $sourceFiles) {
    $relative = $sourceFile.FullName.Substring($sourceDocs.Length).TrimStart('\', '/')
    $bundledFile = Join-Path $bundledDocs $relative
    Assert-True (Test-Path -LiteralPath $bundledFile -PathType Leaf) "Bundled command doc is missing: $relative"
    $sourceHash = (Get-FileHash -LiteralPath $sourceFile.FullName -Algorithm SHA256).Hash
    $bundledHash = (Get-FileHash -LiteralPath $bundledFile -Algorithm SHA256).Hash
    Assert-Equal $bundledHash $sourceHash "Bundled command doc differs from source: $relative"
}

$specAuthoringPath = Join-Path $projectRoot '.agents\skills\openspec\references\specs.md'
Assert-True (Test-Path -LiteralPath $specAuthoringPath -PathType Leaf) 'Specification and Scenario Card reference is missing.'

$specAuthoringText = Get-Content -LiteralPath $specAuthoringPath -Raw
$specTemplateText = Get-Content -LiteralPath (Join-Path $projectRoot 'openspec\workflows\angelscript\templates\spec.md') -Raw
$workflowDefinitionText = Get-Content -LiteralPath (Join-Path $projectRoot 'openspec\workflows\angelscript\workflow.yaml') -Raw
$syncSpecText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-sync-specs\SKILL.md') -Raw

foreach ($token in @(
    '## Scenario Card', '- **GIVEN**', '- **WHEN**', '- **THEN**', '- **AND**', '- **BUT**',
    '> Context:', '> Inputs:', '> Observables:', '> Boundaries:', '> Verification:',
    '> Details:', 'behavior-clause list item', 'immediately indented beneath', 'same readable composition shape',
    'clause-owned block', 'ordered or unordered lists', 'examples', 'tables',
    'durable behavior order', 'ordinary Markdown', 'not parser fields', 'delete unused', 'simple scenario'
)) {
    Assert-True ($specAuthoringText.Contains($token)) "Scenario Card contract is missing: $token"
}
Assert-True (-not $specAuthoringText.Contains('Scenario heading owns one optional progressive detail block')) 'Scenario Card detail must not remain a shared Scenario-owned tail.'
foreach ($token in @('Specs', 'Design', 'Tasks', 'Attachments', 'durable externally observable behavior', 'implementation steps', 'one-off evidence')) {
    Assert-True ($specAuthoringText.Contains($token)) "Specification content ownership is missing: $token"
}
foreach ($token in @('ADDED', 'MODIFIED', 'REMOVED', 'RENAMED', 'same-name scenario', 'complete Scenario Card', 'new scenario name', 'unspecified scenarios', 'requirement body')) {
    Assert-True ($specAuthoringText.Contains($token)) "Specification delta semantics are missing: $token"
}
foreach ($token in @('### Requirement:', 'SHALL', '#### Scenario:', '- **WHEN**', '- **THEN**', '> Context:', '> Inputs:', '> Observables:', '> Boundaries:', '> Verification:', '> Details:', '  1.', '  -')) {
    Assert-True ($specTemplateText.Contains($token)) "Specification template is missing: $token"
}
Assert-True ($specTemplateText -match '(?m)^- \*\*WHEN\*\*[^\r\n]*\r?\n  > ') 'Specification template must nest quoted detail beneath WHEN.'
Assert-True ($specTemplateText -match '(?m)^  1\. ') 'Specification template must demonstrate a Task-like ordered list nested beneath one behavior clause.'
Assert-True ($specTemplateText -match '(?m)^- \*\*THEN\*\*[^\r\n]*\r?\n  > ') 'Specification template must nest quoted detail beneath THEN.'
foreach ($token in @('Scenario Card', '`WHEN`', '`THEN`', 'clause-owned detail block', 'ordered or unordered lists', 'simple clauses')) {
    Assert-True ($workflowDefinitionText.Contains($token)) "Workflow specification instruction is missing: $token"
}
Assert-True ($workflowDefinitionText -match '(?m)^[ \t]+profile:[ \t]+record-v1[ \t]*\r?$') 'Angelscript workflow must retain record-v1.'
Assert-True ($workflowDefinitionText -notmatch '(?m)^[ \t]+profile:[ \t]+requirements-v1[ \t]*\r?$') 'Angelscript workflow must not switch to requirements-v1.'

$mandatoryLifecycleReferences = [ordered]@{
    'openspec-explore' = @('references/deep-exploration.md', 'references/question-rounds.md', 'references/markers.md')
    'openspec-continue-change' = @('../openspec/references/attachments.md', '../openspec/references/knowledge.md', '../openspec/references/specs.md')
    'openspec-apply-change' = @('../openspec/references/implementation-issues.md')
    'openspec-archive-change' = @('../openspec/references/record-schema.md', '../openspec/references/attachments.md')
    'openspec-update-change' = @('../openspec/references/attachments.md', '../openspec/references/specs.md')
    'openspec-sync-specs' = @('../openspec/references/specs.md')
    'openspec-verify-change' = @('../openspec/references/specs.md')
}
foreach ($entry in $mandatoryLifecycleReferences.GetEnumerator()) {
    $skillFile = Join-Path $projectRoot ".agents\skills\$($entry.Key)\SKILL.md"
    Assert-True (Test-Path -LiteralPath $skillFile -PathType Leaf) "Lifecycle skill is missing: $($entry.Key)"
    $skillText = Get-Content -LiteralPath $skillFile -Raw
    foreach ($relativeReference in $entry.Value) {
        $escapedReference = [regex]::Escape($relativeReference)
        Assert-True ([regex]::IsMatch($skillText, "\[[^\]]+\]\($escapedReference\)")) "$($entry.Key) must use a clickable link to $relativeReference"
        $resolvedReference = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $skillFile) $relativeReference))
        Assert-True (Test-Path -LiteralPath $resolvedReference -PathType Leaf) "$($entry.Key) has a broken mandatory reference: $relativeReference"
    }
}

$authoringFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
$portableSkillRoot = Join-Path $projectRoot '.agents\skills\openspec'
foreach ($file in @(Get-ChildItem -LiteralPath $portableSkillRoot -Recurse -File -Filter '*.md')) {
    $authoringFiles.Add($file) | Out-Null
}
foreach ($directory in @(Get-ChildItem -LiteralPath (Join-Path $projectRoot '.agents\skills') -Directory -Filter 'openspec-*')) {
    $entry = Join-Path $directory.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $entry -PathType Leaf)) { continue }
    $authoringFiles.Add((Get-Item -LiteralPath $entry)) | Out-Null
    $references = Join-Path $directory.FullName 'references'
    if (Test-Path -LiteralPath $references -PathType Container) {
        foreach ($file in @(Get-ChildItem -LiteralPath $references -Recurse -File -Filter '*.md')) {
            $authoringFiles.Add($file) | Out-Null
        }
    }
}

$localLinkIssues = @(Get-LocalMarkdownLinkIssues -Files @($authoringFiles | Sort-Object FullName -Unique))
Assert-Equal $localLinkIssues.Count 0 ("Maintained OpenSpec Markdown has broken local links:`n{0}" -f ($localLinkIssues -join [Environment]::NewLine))

$exploreText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-explore\SKILL.md') -Raw
$deepExplorationText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-explore\references\deep-exploration.md') -Raw
$questionRoundsText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-explore\references\question-rounds.md') -Raw
$markerText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-explore\references\markers.md') -Raw
$applyText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-apply-change\SKILL.md') -Raw
$archiveText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-archive-change\SKILL.md') -Raw
$continueText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-continue-change\SKILL.md') -Raw
$updateText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-update-change\SKILL.md') -Raw
$verifyText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec-verify-change\SKILL.md') -Raw
$openSpecEntryText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\SKILL.md') -Raw
$visualExplainText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\visual-explain\SKILL.md') -Raw
$unrealDevelopText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\unreal-engine-develop\SKILL.md') -Raw
$skillsReadmeText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\README.md') -Raw
$liveConfigText = Get-Content -LiteralPath (Join-Path $projectRoot 'openspec\config.yaml') -Raw
$openSpecReadmeText = Get-Content -LiteralPath (Join-Path $projectRoot 'openspec\README.md') -Raw
$projectReadmeRoutingText = Get-Content -LiteralPath (Join-Path $projectRoot 'README.md') -Raw
$agentsText = Get-Content -LiteralPath (Join-Path $projectRoot 'AGENTS.md') -Raw
$harnessText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\harness\SKILL.md') -Raw
$routingText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\harness\references\routing.md') -Raw
$reviewReferenceText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\harness\references\review.md') -Raw
$taskReferenceText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\references\tasks.md') -Raw
$issueReferenceText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\references\implementation-issues.md') -Raw
$knowledgeReferenceText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\references\knowledge.md') -Raw
$attachmentReferenceText = Get-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\openspec\references\attachments.md') -Raw

foreach ($entry in ([ordered]@{
    'openspec-continue-change' = $continueText
    'openspec-update-change' = $updateText
    'openspec-sync-specs' = $syncSpecText
    'openspec-verify-change' = $verifyText
}).GetEnumerator()) {
    foreach ($token in @('clause-owned detail block', 'lists', 'complete Scenario Card')) {
        Assert-True ($entry.Value.Contains($token)) "$($entry.Key) is missing flexible Scenario detail guidance: $token"
    }
}

foreach ($token in @('clause-owned detail block', 'ordered or unordered lists', 'no Task state')) {
    Assert-True ($openSpecEntryText.Contains($token)) "OpenSpec entry is missing flexible Scenario detail guidance: $token"
    Assert-True ($skillsReadmeText.Contains($token)) "Skills README is missing flexible Scenario detail guidance: $token"
    Assert-True ($liveConfigText.Contains($token)) "OpenSpec config is missing flexible Scenario detail guidance: $token"
    Assert-True ($openSpecReadmeText.Contains($token)) "OpenSpec README is missing flexible Scenario detail guidance: $token"
}

$representativeScenarioDetails = [ordered]@{
    'openspec\specs\harness\core\spec.md' = 'Interpret Codex Goal continuation'
    'openspec\specs\harness\workspace\spec.md' = 'Coordinate concurrent agents'
    'openspec\specs\harness\git\spec.md' = 'Report resumable partial completion'
    'openspec\specs\harness\unreal\spec.md' = 'Time out a process'
}
foreach ($entry in $representativeScenarioDetails.GetEnumerator()) {
    $text = Get-Content -Raw -LiteralPath (Join-Path $projectRoot $entry.Key)
    $block = Get-ScenarioBlock -Text $text -Name $entry.Value
    Assert-True ($block -match '(?m)^- \*\*WHEN\*\*[^\r\n]*\r?\n  > ') "Representative Scenario lacks WHEN-owned detail: $($entry.Value)"
    Assert-True ($block -match '(?m)^- \*\*THEN\*\*[^\r\n]*\r?\n  > ') "Representative Scenario lacks THEN-owned detail: $($entry.Value)"
    Assert-True ($block -match '(?m)^  (?:>|1\.) ') "Representative Scenario lacks an indented nested detail line: $($entry.Value)"
}

foreach ($token in @('same-name scenario', 'complete Scenario Card', 'new scenario name', 'Preserve unspecified scenarios', 'requirement body', 'Remove delta-operation headers')) {
    Assert-True ($syncSpecText.Contains($token)) "Spec sync semantics are missing: $token"
}

foreach ($token in @('references/deep-exploration.md', 'references/question-rounds.md', 'references/markers.md', 'before `change create`', 'decision-complete handoff', 'Never invoke it after', 'indexed talks', 'indexed change-local knowledge', 'never copy the exploration transcript')) {
    Assert-True ($exploreText.Contains($token)) "Explore entry is missing: $token"
}
foreach ($token in @('Problem', 'Success Criteria', 'Evidence', 'Scope and Exclusions', 'Constraints', 'Options', 'Decision and Rationale', 'Flip Condition', 'Architecture, Components, and Data Flow', 'Failures and Edge Cases', 'Verification', 'OpenSpec Handoff', 'Exploration Carryover', 'Talk candidate', 'Knowledge candidate', 'Discard')) {
    Assert-True ($deepExplorationText.Contains($token)) "Deep exploration handoff is missing: $token"
}
foreach ($token in @('interactive pre-change work', 'at least three', 'user-owned', 'independent', 'Settled', 'Held', 'Reopened', 'Dropped', 'Pinned fact', 'Never use them for unattended Codex `/goal` continuation or task-local implementation uncertainty', '`/goal` is not a repository mode')) {
    Assert-True ($questionRoundsText.Contains($token)) "Question-round contract is missing: $token"
}
foreach ($token in @('markers.md', '✅ Settled:', '❌ Dropped:', '🔁 Reopened:', '⏳ Held:', '📌 Pinned fact:', '❔ Open decision:', '👉 Recommendation:', '❗ Flip condition:', '✨ New:', '💡 Knowledge candidate:', 'Do not use the historical red/green circles', 'materialize them only after the target Change is created')) {
    Assert-True ($questionRoundsText.Contains($token)) "Question-round visual contract is missing: $token"
}
Assert-True (-not $questionRoundsText.Contains('Do not create a marker file or emoji protocol')) 'Question rounds still prohibit the restored marker reference.'
foreach ($token in @('optional presentation hints, not a state machine', 'at most one leading marker per line', 'never means a test or gate passed', 'Historical `🔴 Reopened` and `🟢 Landed` are deliberately not restored', 'a green dot does not explain what landed', '## Durable carryover', '📌', '❔', '👉', '❗', '✅', '❌', '🚫', '💡', '🔗', '📁', '⭐', '✨', '⏳', '🔁')) {
    Assert-True ($markerText.Contains($token)) "Marker contract is missing: $token"
}
foreach ($token in @('before implementation mutation', 'not an active Change or Ready Task DAG', 'local coherence', '`Files`', 'prerequisites', 'exact verification', 'implementation-issues.md', 'Do not invoke deep pre-change Explore from a Ready task')) {
    Assert-True ($applyText.Contains($token)) "Apply contract is missing: $token"
}
foreach ($token in @('new feature, architecture refactor, or major behavior change', 'decision-complete exploration handoff', 'before this Change was created', 'Never invoke', 'Exploration Carryover', 'attachments/talks/', 'attachments/knowledges/', 'discard temporary round state or transcript prose')) {
    Assert-True ($continueText.Contains($token)) "Continue contract is missing: $token"
}
foreach ($token in @('canonical active Change in the selected workspace', 'Codex `/goal` continuation', 'not a repository mode or workspace selector')) {
    Assert-True ($continueText.Contains($token)) "Continue workspace contract is missing: $token"
    Assert-True ($updateText.Contains($token)) "Update workspace contract is missing: $token"
}
foreach ($token in @('canonical active Change in the selected workspace', 'lightweight task-local investigation', 'Codex `/goal` is not a repository mode or workspace selector')) {
    Assert-True ($applyText.Contains($token)) "Apply workspace contract is missing: $token"
}
foreach ($token in @('new feature, architecture refactor, or major behavior change', 'deep Explore before Change creation', 'decision-complete exploration handoff is not an active Change', 'Ready Task DAG before implementation mutation', 'After Change creation, do not restart deep Explore', 'lightweight investigation inside the Ready task')) {
    Assert-True ($harnessText.Contains($token)) "Harness exploration route is missing: $token"
}
foreach ($token in @('before creating that Change', 'Lightweight investigation inside a Ready task')) {
    Assert-True ($routingText.Contains($token)) "Harness route map is missing: $token"
}
foreach ($token in @('explicit user or external-agent request', 'never auto-starts Review', 'Verified work', 'close and archive directly', 'Local defects', 'planning-invalidating evidence', 'Replan', 'inline or asynchronously', 'immutable snapshot', 'detailed report', 'no Review file line limit', 'closed or superseded', 'open or deferred Critical or Required')) {
    Assert-True ($reviewReferenceText.Contains($token)) "Review scheduling contract is missing: $token"
}
$liveReviewPolicyText = @($harnessText, $reviewReferenceText, $attachmentReferenceText, $knowledgeReferenceText, $applyText, $archiveText, $verifyText) -join "`n"
foreach ($retiredReviewPattern in @(
    '(?i)Final Review:[ \t]*not required',
    '(?i)There are exactly three routes',
    '(?i)one batched incremental Final Review',
    '(?i)Diff size alone does not determine impact',
    '(?i)demonstrated major incident',
    '(?i)small low-impact',
    '(?i)Final Review runs once',
    '(?i)Completed archive requires (?:either )?(?:one )?closed approving Final Review',
    '(?i)provisional until the Final Review approves',
    '(?i)Final Review is required',
    '(?i)requires? (?:an? )?Final Review',
    '(?i)must (?:run|perform|complete) (?:an? )?Final Review'
)) {
    Assert-True ($liveReviewPolicyText -notmatch $retiredReviewPattern) "Live protocol text still contains retired automatic or mandatory Review policy: $retiredReviewPattern"
}
foreach ($token in @('## Authoring quality', 'file, artifact, and exclusive-resource map', 'smallest independently reviewable outcome', 'one-line checkbox statement', 'exact verification command or directly observable result', '`> Files:` line', 'explicitly bounded package-wide glob with exclusions', 'ordinary Markdown', '`> Context:`', '`> Inputs:`', '`> Produces:`', '`> Constraints:`', 'not parser fields or a rigid template', 'Nested numbered steps are real execution order', '`TBD`', 'map every requirement and acceptance condition', 'self-review', 'ready to execute')) {
    Assert-True ($taskReferenceText.Contains($token)) "Task authoring contract is missing: $token"
}

foreach ($token in @('New-HarnessContext -WorkspaceRoot', 'one explicit or discovered `WorkspaceRoot`', 'Codex `/goal` invocation', 'not a repository mode', 'tracked `Tools/openspec` submodule', 'packaged `.agents/skills/openspec/bin/openspec.exe`')) {
    Assert-True ($openSpecEntryText.Contains($token)) "Portable OpenSpec workspace/package contract is missing: $token"
}
foreach ($token in @('three or more important relationships or mappings', 'multi-step sequence or state transition', 'hierarchy or layout', 'decision structure', 'Do not add a visual for a single fact', 'trivial one-step action', 'lightweight inline text diagram')) {
    Assert-True ($visualExplainText.Contains($token)) "Visual-explain trigger contract is missing: $token"
}
foreach ($token in @('explicit/discovered WorkspaceRoot', 'Codex /goal', 'no repository mode or branch convention', 'harness.{status,observe,evolution.status}', 'openspec.maintenance.status', 'Root `Tools` PowerShell entrypoints are legacy deletion candidates', 'runtime uses `.agents/skills/openspec/bin/openspec.exe`')) {
    Assert-True ($skillsReadmeText.Contains($token)) "Skills README routing contract is missing: $token"
}
foreach ($token in @('current-directory-discovered WorkspaceRoot', 'Codex /goal invocation is external unattended continuation', 'Root Tools PowerShell entry points are legacy deletion candidates', 'normal runtime uses .agents/skills/openspec/bin/openspec.exe', 'optional Markdown authoring aids, not parser fields or a rigid template')) {
    Assert-True ($liveConfigText.Contains($token)) "Live OpenSpec configuration is missing: $token"
}
Assert-True ($openSpecReadmeText.Contains('New-HarnessContext -WorkspaceRoot $PWD')) 'OpenSpec README still lacks the canonical explicit workspace example.'
foreach ($token in @('validator profile identifiers', 'not a content version', '`record-v1`', '`requirements-v1`', 'Scenario Cards', 'continues to use `record-v1`')) {
    Assert-True ($openSpecReadmeText.Contains($token)) "OpenSpec profile guidance is missing: $token"
}
Assert-True (-not $openSpecReadmeText.Contains('Project Skills are temporarily disabled')) 'OpenSpec README still claims that project Skills are disabled.'
Assert-True (-not $liveConfigText.Contains('While AGENTS.md temporarily disables project Skills')) 'OpenSpec config still carries the lifted temporary Skill restriction.'
Assert-True ([regex]::Matches($projectReadmeRoutingText, [regex]::Escape('New-HarnessContext -WorkspaceRoot $PWD')).Count -ge 2) 'Root README must use the canonical explicit workspace example for OpenSpec and workspace setup.'
foreach ($token in @('user explicitly lifted the temporary Skill restriction', 'current-directory-discovered `WorkspaceRoot`', 'Codex `/goal` is external unattended continuation', 'Root `Tools` PowerShell entrypoints are legacy deletion candidates', 'normal OpenSpec runtime calls use `.agents/skills/openspec/bin/openspec.exe`', 'not parser fields or a rigid template')) {
    Assert-True ($agentsText.Contains($token)) "Prepared AGENTS workflow contract is missing: $token"
}

$modeFreeTexts = @($openSpecEntryText, $exploreText, $deepExplorationText, $questionRoundsText, $continueText, $updateText, $applyText, $unrealDevelopText, $skillsReadmeText, $liveConfigText, $openSpecReadmeText, $projectReadmeRoutingText, $agentsText) -join "`n"
foreach ($staleModePattern in @('(?i)\bGoal mode\b', '(?i)\bCurrent mode\b', '(?i)-Mode[ \t]+(?:Current|Goal)\b', '(?i)\.worktrees/<goal>', '(?i)goal/<goal>', '(?i)explicit/Goal', '(?i)Goal context')) {
    Assert-True ($modeFreeTexts -notmatch $staleModePattern) "Prepared authoring guidance still contains retired repository-mode syntax: $staleModePattern"
}
foreach ($token in @('## Material threshold', 'One root cause and its repair lifecycle', 'issue_id', 'source_ref', 'affected_tasks', 'Failure Evidence (RED)', 'Resolution Evidence (GREEN)', 'Rejected Evidence', 'What This Proves', 'What This Does Not Prove', 'update `attachments/INDEX.md` in the same edit')) {
    Assert-True ($issueReferenceText.Contains($token)) "Implementation issue contract is missing: $token"
}
foreach ($token in @('change evidence', 'capability knowledge plus knowledges/INDEX.md', 'AGENTS project instruction only for cross-capability invariants', 'Every capability `knowledges/` directory has one `INDEX.md`', 'Promote only after evidence', 'Archive never promotes automatically')) {
    Assert-True ($knowledgeReferenceText.Contains($token)) "Knowledge promotion contract is missing: $token"
}
foreach ($token in @('## Exploration carryover', 'decision-critical visualization', 'reusable evidence-backed insights', 'transcript prose', 'candidate', 'promoted', 'superseded', 'retired')) {
    Assert-True ($attachmentReferenceText.Contains($token)) "Exploration attachment routing is missing: $token"
}
foreach ($token in @('review_schema: review-v2', 'review_kind: incident | final | external', 'requested_by: user | external-agent', 'only after an explicit request', 'asynchronously', 'no line limit', 'per-file manifest is optional')) {
    Assert-True ($attachmentReferenceText.Contains($token)) "Review attachment contract is missing: $token"
}
foreach ($token in @('attachments/knowledges/', '## Exploration candidates', 'accepted pre-Change handoff', 'plausible reuse across tasks or later work', 'candidate | promoted | superseded | retired', 'Emoji is optional presentation')) {
    Assert-True ($knowledgeReferenceText.Contains($token)) "Exploration knowledge contract is missing: $token"
}

$policyFiles = @(
    '.agents\skills\openspec-explore\SKILL.md',
    '.agents\skills\openspec-explore\references\deep-exploration.md',
    '.agents\skills\openspec-explore\references\question-rounds.md',
    '.agents\skills\openspec-explore\references\markers.md',
    '.agents\skills\openspec-apply-change\SKILL.md',
    '.agents\skills\openspec-continue-change\SKILL.md',
    '.agents\skills\openspec\references\record-schema.md',
    '.agents\skills\openspec\references\tasks.md',
    '.agents\skills\openspec\references\attachments.md',
    '.agents\skills\openspec\references\implementation-issues.md',
    '.agents\skills\openspec\references\knowledge.md'
)
$policyText = @($policyFiles | ForEach-Object { Get-Content -LiteralPath (Join-Path $projectRoot $_) -Raw }) -join "`n"
foreach ($forbiddenPattern in @('(?i)\bopenspec-schema\b', '(?i)\bnpx[ \t]+openspec\b', '(?i)@fission-ai/openspec', '(?i)\bopenspec[ \t]+store\b')) {
    Assert-True ($policyText -notmatch $forbiddenPattern) "Maintained OpenSpec authoring policy contains stale syntax: $forbiddenPattern"
}

$rootReadmeText = Get-Content -LiteralPath (Join-Path $projectRoot 'README.md') -Raw
foreach ($staleEntry in @('openspec-work', '/opsx:', '@fission-ai/openspec', 'npm install -g', 'Superpowers')) {
    Assert-True ($rootReadmeText -notmatch [regex]::Escape($staleEntry)) "Root README contains stale OpenSpec workflow entry: $staleEntry"
}
foreach ($requiredEntry in @('openspec-explore', 'openspec-continue-change', 'openspec-update-change', 'openspec-apply-change', 'openspec-archive-change')) {
    Assert-True ($rootReadmeText.Contains($requiredEntry)) "Root README is missing the current OpenSpec lifecycle entry: $requiredEntry"
}

$knowledgeIndexIssues = @(Get-CapabilityKnowledgeIndexIssues -SpecsRoot (Join-Path $projectRoot 'openspec\specs'))
Assert-Equal $knowledgeIndexIssues.Count 0 ("Current capability knowledge INDEX audit failed:`n{0}" -f ($knowledgeIndexIssues -join [Environment]::NewLine))

$activeAttachmentIndexIssues = @()
$activeChangesRoot = Join-Path $projectRoot 'openspec\changes'
if (Test-Path -LiteralPath $activeChangesRoot -PathType Container) {
    foreach ($attachmentRoot in @(Get-ChildItem -LiteralPath $activeChangesRoot -Recurse -Directory -Filter 'attachments')) {
        $indexPath = Join-Path $attachmentRoot.FullName 'INDEX.md'
        if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
            $activeAttachmentIndexIssues += "attachment-index-missing: $($attachmentRoot.FullName)"
            continue
        }
        $indexLines = @(Get-Content -LiteralPath $indexPath)
        if ($indexLines.Count -gt 120) { $activeAttachmentIndexIssues += "attachment-index-size: $($attachmentRoot.FullName) has $($indexLines.Count) lines" }
        $indexText = (Get-Content -LiteralPath $indexPath -Raw).Replace('\', '/')
        foreach ($file in @(Get-ChildItem -LiteralPath $attachmentRoot.FullName -Recurse -File | Where-Object { $_.FullName -ne $indexPath })) {
            $relative = $file.FullName.Substring($attachmentRoot.FullName.Length).TrimStart('\', '/').Replace('\', '/')
            $count = [regex]::Matches($indexText, [regex]::Escape($relative)).Count
            if ($count -ne 1) { $activeAttachmentIndexIssues += "attachment-index-entry: $relative appears $count times" }
        }
    }
}
Assert-Equal $activeAttachmentIndexIssues.Count 0 ("Active change attachment INDEX audit failed:`n{0}" -f ($activeAttachmentIndexIssues -join [Environment]::NewLine))

$workflow = & $exePath workflow validate angelscript 2>&1
Assert-Equal $LASTEXITCODE 0 "Project workflow validation failed: $($workflow -join [Environment]::NewLine)"

$temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$fixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ("openspec-skill-{0}" -f [guid]::NewGuid().ToString('N'))))
Assert-True ($fixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'Temporary OpenSpec fixture escaped the system temp directory.'
try {
    [void](New-Item -ItemType Directory -Path $fixtureRoot)
    $initOutput = & $exePath init $fixtureRoot --project-id openspec-skill-fixture --title 'OpenSpec Skill Fixture' --workflow spec-driven --language en 2>&1
    Assert-Equal $LASTEXITCODE 0 "Fixture init failed: $($initOutput -join [Environment]::NewLine)"
    Push-Location $fixtureRoot
    try {
        $domainOutput = & $exePath domain create fixture --title Fixture --description Fixture --json 2>&1
        Assert-Equal $LASTEXITCODE 0 "Fixture domain creation failed: $($domainOutput -join [Environment]::NewLine)"
        $changeOutput = & $exePath change create fixture/glob-output --title 'Glob Output' --goal 'Verify safe glob instructions' --json 2>&1
        Assert-Equal $LASTEXITCODE 0 "Fixture change creation failed: $($changeOutput -join [Environment]::NewLine)"
        $specPath = Join-Path $fixtureRoot 'openspec\changes\fixture\glob-output\specs\fixture\sample\spec.md'
        [void](New-Item -ItemType Directory -Path (Split-Path -Parent $specPath) -Force)
        [System.IO.File]::WriteAllText($specPath, "## Purpose`n`nFixture.`n`n## ADDED Requirements`n`n### Requirement: Fixture`n`nThe fixture SHALL exist.`n`n#### Scenario: Exists`n- **WHEN** inspected`n- **THEN** it exists`n", [System.Text.UTF8Encoding]::new($false))
        $instructionsJson = & $exePath instructions specs --change fixture/glob-output --json
        Assert-Equal $LASTEXITCODE 0 'Specs instructions failed.'
        $instructions = $instructionsJson | ConvertFrom-Json
        Assert-Equal $instructions.outputKind 'glob' 'Specs instructions must identify a glob output.'
        Assert-True ($null -eq $instructions.writePath) 'Glob instructions must never expose a writable wildcard path.'
        Assert-True (@($instructions.existingOutputPaths).Count -eq 1) 'Specs instructions must expose the one concrete existing file.'
    }
    finally {
        Pop-Location
    }
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot) {
        Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
    }
}

Write-Output 'OpenSpec skill package tests passed.'
