Set-StrictMode -Version Latest

function Assert-AngelscriptExternalSmokePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AllowedRoot,

        [Parameter(Mandatory = $true)]
        [string]$CandidatePath
    )

    $normalizedRoot = [System.IO.Path]::GetFullPath($AllowedRoot).TrimEnd('\', '/')
    $normalizedCandidate = [System.IO.Path]::GetFullPath($CandidatePath).TrimEnd('\', '/')
    $rootPrefix = $normalizedRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not [string]::Equals(
            $normalizedRoot,
            $normalizedCandidate,
            [System.StringComparison]::OrdinalIgnoreCase) `
        -and -not $normalizedCandidate.StartsWith(
            $rootPrefix,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "External smoke path escapes its allowed root: $normalizedCandidate"
    }
    return $normalizedCandidate
}

function Get-AngelscriptExternalSmokeRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $normalizedBase = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/')
    $normalizedTarget = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = New-Object System.Uri(
        $normalizedBase + [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = New-Object System.Uri($normalizedTarget)
    if (-not [string]::Equals(
            $baseUri.Scheme,
            $targetUri.Scheme,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Cannot make an external-smoke relative path across URI schemes: $BasePath -> $TargetPath"
    }

    return [System.Uri]::UnescapeDataString(
        $baseUri.MakeRelativeUri($targetUri).ToString()).Replace(
            '/',
            [System.IO.Path]::DirectorySeparatorChar)
}

function Get-AngelscriptExternalSmokeSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $stream = [System.IO.File]::OpenRead(
        [System.IO.Path]::GetFullPath($Path))
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString(
            $sha256.ComputeHash($stream))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha256.Dispose()
        $stream.Dispose()
    }
}

function New-AngelscriptExternalConsumerProject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [string]$ProjectName = 'AngelscriptStandaloneExternalConsumer'
    )

    if ($ProjectName -notmatch '^[A-Za-z][A-Za-z0-9_]*$') {
        throw "External consumer project name is invalid: $ProjectName"
    }
    $normalizedRepositoryRoot = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd('\', '/')
    $allowedRoot = Join-Path $normalizedRepositoryRoot 'Saved\StandaloneExternalSmoke'
    $normalizedRunRoot = Assert-AngelscriptExternalSmokePath `
        -AllowedRoot $allowedRoot `
        -CandidatePath $RunRoot
    $projectRoot = Join-Path $normalizedRunRoot $ProjectName
    $scriptRoot = Join-Path $projectRoot 'Script'
    New-Item -ItemType Directory -Path $scriptRoot -Force | Out-Null

    $pluginsRoot = Join-Path $normalizedRepositoryRoot 'Plugins'
    if (-not (Test-Path -LiteralPath $pluginsRoot -PathType Container)) {
        throw "Repository Plugins directory was not found: $pluginsRoot"
    }
    $relativePluginsRoot = (Get-AngelscriptExternalSmokeRelativePath `
        -BasePath $projectRoot `
        -TargetPath $pluginsRoot).Replace('\', '/')

    $projectFile = Join-Path $projectRoot "$ProjectName.uproject"
    $descriptor = [ordered]@{
        FileVersion = 3
        EngineAssociation = '5.8'
        Category = ''
        Description = 'Transient external consumer smoke for Unreal AngelScript Standalone.'
        AdditionalPluginDirectories = @($relativePluginsRoot)
        Plugins = @(
            [ordered]@{ Name = 'PropertyBindingUtils'; Enabled = $true }
            [ordered]@{ Name = 'EnhancedInput'; Enabled = $true }
            [ordered]@{ Name = 'Angelscript'; Enabled = $true }
        )
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText(
        $projectFile,
        ($descriptor | ConvertTo-Json -Depth 8),
        $utf8NoBom)

    $scriptFile = Join-Path $scriptRoot 'ExternalConsumerSmoke.as'
    $scriptSource = @'
class FExternalConsumerSmokeValue
{
    int GetValue() const
    {
        return 42;
    }
}

int ExternalConsumerSmokeValue()
{
    FExternalConsumerSmokeValue Value;
    return Value.GetValue();
}
'@
    [System.IO.File]::WriteAllText($scriptFile, $scriptSource, $utf8NoBom)

    return [PSCustomObject]@{
        ProjectName = $ProjectName
        ProjectRoot = $projectRoot
        ProjectFile = $projectFile
        ScriptRoot = $scriptRoot
        ScriptFile = $scriptFile
    }
}

function Compare-AngelscriptExternalProjectBundles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirstBundle,

        [Parameter(Mandatory = $true)]
        [string]$SecondBundle,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedProjectName,

        [string]$ForbiddenModuleName = '',

        [string[]]$ForbiddenMachinePaths = @()
    )

    $requiredFiles = @('manifest.json', 'symbols.jsonl', 'assets.jsonl')
    $hashes = [ordered]@{}
    foreach ($requiredFile in $requiredFiles) {
        $firstPath = Join-Path $FirstBundle $requiredFile
        $secondPath = Join-Path $SecondBundle $requiredFile
        if (-not (Test-Path -LiteralPath $firstPath -PathType Leaf)) {
            throw "First bundle is missing $requiredFile`: $FirstBundle"
        }
        if (-not (Test-Path -LiteralPath $secondPath -PathType Leaf)) {
            throw "Second bundle is missing $requiredFile`: $SecondBundle"
        }
        $firstHash = Get-AngelscriptExternalSmokeSha256 -Path $firstPath
        $secondHash = Get-AngelscriptExternalSmokeSha256 -Path $secondPath
        if ($firstHash -ne $secondHash) {
            throw "External Project bundle file is not deterministic: $requiredFile"
        }
        $hashes[$requiredFile] = $firstHash

        foreach ($forbiddenMachinePath in @($ForbiddenMachinePaths)) {
            if ([string]::IsNullOrWhiteSpace($forbiddenMachinePath)) {
                continue
            }
            $pathSpellings = @(
                $forbiddenMachinePath,
                $forbiddenMachinePath.Replace('\', '/')
            ) | Select-Object -Unique
            foreach ($pathSpelling in $pathSpellings) {
                if (Select-String -LiteralPath $firstPath -SimpleMatch $pathSpelling -Quiet) {
                    throw "External Project bundle contains a machine path in $requiredFile"
                }
            }
        }
    }

    $manifest = Get-Content -LiteralPath (Join-Path $FirstBundle 'manifest.json') -Raw -Encoding UTF8 |
        ConvertFrom-Json
    if ($manifest.bundleKind -ne 'project') {
        throw "External bundle kind must be project, got '$($manifest.bundleKind)'."
    }
    if ($manifest.engineProperties.'unreal.project-name' -ne $ExpectedProjectName) {
        throw "External bundle producer project mismatch: '$($manifest.engineProperties.'unreal.project-name')'."
    }
    if (-not [bool]$manifest.symbolScope.complete) {
        throw 'External bundle symbol scope must be complete.'
    }
    if (-not [bool]$manifest.assetScope.complete) {
        throw 'External bundle asset scope must be complete.'
    }
    if (-not [string]::IsNullOrWhiteSpace($ForbiddenModuleName) `
        -and @($manifest.loadedModules) -contains $ForbiddenModuleName) {
        throw "External bundle unexpectedly depends on module '$ForbiddenModuleName'."
    }

    return [PSCustomObject]@{
        BundleIdentity = [string]$manifest.bundleIdentity
        Manifest = $manifest
        FileHashes = $hashes
    }
}

function Test-AngelscriptExternalCompileResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedBundleIdentity,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedBundlePath
    )

    if (-not (Test-Path -LiteralPath $ResultPath -PathType Leaf)) {
        throw "Standalone compile result was not found: $ResultPath"
    }
    $result = Get-Content -LiteralPath $ResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($result.status -ne 'complete') {
        throw "Standalone external compile status is '$($result.status)', expected complete."
    }
    if ($result.profile -ne 'ue-validation' -or -not [bool]$result.ueValidationOnly) {
        throw 'Standalone external compile did not preserve the UE-validation-only profile.'
    }
    if ($result.bundle.kind -ne 'project') {
        throw "Standalone external compile used bundle kind '$($result.bundle.kind)'."
    }
    if ($result.bundle.identity -ne $ExpectedBundleIdentity) {
        throw 'Standalone external compile used the wrong bundle identity.'
    }
    $actualBundlePath = [System.IO.Path]::GetFullPath([string]$result.bundle.path).TrimEnd('\', '/')
    $expectedBundlePath = [System.IO.Path]::GetFullPath($ExpectedBundlePath).TrimEnd('\', '/')
    if (-not [string]::Equals(
            $actualBundlePath,
            $expectedBundlePath,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Standalone external compile used bundle path '$actualBundlePath', expected '$expectedBundlePath'."
    }
    return $result
}
