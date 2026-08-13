<#
.SYNOPSIS
    Build and launch a Development or Shipping package twice to prove StaticJIT provider routing.

.DESCRIPTION
    The runner validates the generated profile manifest, the game link response,
    the archived module surface, and two independent packaged-process starts.
    Stable selection evidence deliberately excludes process-local pointers,
    FunctionIds, and publication ordinals.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Development', 'Shipping')]
    [string]$Configuration,

    [string]$Label = 'staticjit-package',

    [string]$OutputRoot = '',

    [int]$TimeoutMs = 3600000,

    [switch]$SkipPackage
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
Import-Module (Join-Path $PSScriptRoot 'Shared\AngelscriptCachePackageSmoke.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'Shared\AngelscriptJITPackageSmoke.psm1') -Force

function Read-StaticJITProviderManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedProfile
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "StaticJIT provider manifest was not found: $Path"
    }
    $document = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if ([int]$document.schemaRevision -lt 3 -or
        [int]$document.providerAbiRevision -lt 2) {
        throw 'StaticJIT provider manifest has an unsupported schema or ABI revision.'
    }
    if ([string]$document.targetProfile -ne $ExpectedProfile) {
        throw "Manifest target profile '$($document.targetProfile)' does not match '$ExpectedProfile'."
    }
    foreach ($identityName in @(
            'providerId', 'providerGeneration', 'artifactSetDigest',
            'artifactProfile', 'nativeEnvironment')) {
        $identity = [string]$document.$identityName
        if ($identity -notmatch '^[0-9a-f]{64}$') {
            throw "Manifest field '$identityName' is not a complete 256-bit lowercase identity."
        }
    }
    if ([string]$document.ownerModuleName -ne 'AngelscriptJIT') {
        throw "Manifest owner must be AngelscriptJIT; found '$($document.ownerModuleName)'."
    }

    $modules = @($document.modules)
    $functions = @($document.functions)
    if ($modules.Count -lt 2 -or $functions.Count -lt 2) {
        throw 'Package smoke requires a multi-AS-module, multi-function provider manifest.'
    }
    $moduleSources = @($modules | ForEach-Object { [string]$_.source })
    if (@($moduleSources | Sort-Object -Unique).Count -ne $modules.Count) {
        throw 'Strict module ownership failed: two AS modules share one generated source.'
    }
    foreach ($module in $modules) {
        if ([string]$module.moduleKey -notmatch '^[0-9a-f]{64}$') {
            throw "Manifest module '$($module.canonicalName)' has an invalid StableModuleKey."
        }
		if ([string]::IsNullOrWhiteSpace([string]$module.virtualSourcePath) -or
			-not ([string]$module.virtualSourcePath).StartsWith(
				'/Angelscript/',
				[System.StringComparison]::Ordinal)) {
			throw "Manifest module '$($module.canonicalName)' has no canonical virtual source path."
		}
		if (([string]$module.source).StartsWith(
				'Modules/',
				[System.StringComparison]::Ordinal)) {
			throw "Manifest module '$($module.canonicalName)' still uses the legacy Modules path."
		}
        $expectedSuffix = ".$ExpectedProfile.jit.cpp"
        if (-not ([string]$module.source).EndsWith(
                $expectedSuffix,
                [System.StringComparison]::Ordinal)) {
            throw "Manifest module '$($module.canonicalName)' does not own exactly one profile-specific .jit.cpp."
        }
        $ownedFunctions = @($functions | Where-Object {
                [string]$_.moduleKey -eq [string]$module.moduleKey
            })
        if ($ownedFunctions.Count -ne [int]$module.functionCount) {
            throw "Manifest function count disagrees for module '$($module.canonicalName)'."
        }
        if (@($ownedFunctions | Where-Object {
                    [string]$_.moduleSource -ne [string]$module.source
                }).Count -ne 0) {
            throw "A function escaped module source ownership for '$($module.canonicalName)'."
        }
		foreach ($function in $ownedFunctions) {
			if ([string]::IsNullOrWhiteSpace([string]$function.canonicalDeclaration) -or
				[string]::IsNullOrWhiteSpace([string]$function.sourceSection) -or
				[int]$function.sourceLine -lt 1 -or
				[int]$function.sourceColumn -lt 0) {
				throw "Manifest function '$($function.functionKey)' has incomplete readable source metadata."
			}
		}
    }
    return $document
}

function Assert-StaticJITGameLinkSurface {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$Configuration,

        [Parameter(Mandatory = $true)]
        [string]$Profile,

        [Parameter(Mandatory = $true)]
        [int]$ExpectedModuleCount
    )

    $responsePath = Resolve-AngelscriptJITGameLinkResponsePath `
        -ProjectRoot $ProjectRoot `
        -ProjectName $ProjectName `
        -Configuration $Configuration
    $response = Get-Content -LiteralPath $responsePath -Raw
    foreach ($required in @(
            'AngelscriptJITModule.cpp.obj',
            'Provider.generated.cpp.obj')) {
        if ($response.IndexOf(
                $required,
                [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "Game link response omitted required StaticJIT object '$required'."
        }
    }
    $profileObjectPattern = [regex]::Escape(".$Profile.jit.cpp.obj")
    $profileObjectCount = [regex]::Matches(
        $response,
        $profileObjectPattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count
    if ($profileObjectCount -ne $ExpectedModuleCount) {
        throw "Game link response contains $profileObjectCount '$Profile' module objects; expected $ExpectedModuleCount."
    }
    foreach ($forbidden in @(
            'AngelscriptEditor',
            'AngelscriptTestJIT',
            'AngelscriptTest')) {
        if ($response.IndexOf(
                $forbidden,
                [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Game link response unexpectedly contains forbidden module surface '$forbidden'."
        }
    }
    return (Resolve-Path -LiteralPath $responsePath).Path
}

function Assert-StaticJITModuleDependencySurface {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $moduleRoot = Join-Path $ProjectRoot 'Source\AngelscriptJIT'
    $buildRulesPath = Join-Path $moduleRoot 'AngelscriptJIT.Build.cs'
    if (-not (Test-Path -LiteralPath $buildRulesPath -PathType Leaf)) {
        throw "AngelscriptJIT build rules were not found: $buildRulesPath"
    }
    $buildRules = Get-Content -LiteralPath $buildRulesPath -Raw
    foreach ($required in @('"Core"', '"AngelscriptRuntime"')) {
        if ($buildRules.IndexOf(
                $required,
                [System.StringComparison]::Ordinal) -lt 0) {
            throw "AngelscriptJIT build rules omitted required dependency $required."
        }
    }
    foreach ($forbidden in @(
            'LiveCoding',
            'AngelscriptEditor',
            'AngelscriptTestJIT',
            'AngelscriptTest')) {
        if ($buildRules.IndexOf(
                $forbidden,
                [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "AngelscriptJIT build rules unexpectedly depend on '$forbidden'."
        }
    }
    $sourceFiles = @(Get-ChildItem -LiteralPath $moduleRoot -Recurse -File |
            Where-Object { $_.Extension -in @('.cpp', '.h', '.inl') })
    foreach ($sourceFile in $sourceFiles) {
        $source = Get-Content -LiteralPath $sourceFile.FullName -Raw
        foreach ($forbidden in @(
                'ILiveCodingModule',
                'LiveCodingModule.h',
                'AngelscriptEditor',
                'AngelscriptTestJIT')) {
            if ($source.IndexOf(
                    $forbidden,
                    [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                throw "Packaged JIT source '$($sourceFile.FullName)' references forbidden surface '$forbidden'."
            }
        }
    }
    return (Resolve-Path -LiteralPath $buildRulesPath).Path
}

function Assert-StaticJITArchiveSurface {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot
    )

    $forbiddenPatterns = @(
        '(?i)AngelscriptEditor',
        '(?i)AngelscriptTestJIT',
        '(?i)AngelscriptTest')
    $binaryFiles = @(Get-ChildItem -LiteralPath $ArchiveRoot -Recurse -File |
            Where-Object { $_.Extension -in @('.dll', '.exe', '.modules', '.target') })
    foreach ($binary in $binaryFiles) {
        foreach ($pattern in $forbiddenPatterns) {
            if ($binary.Name -match $pattern) {
                throw "Packaged archive unexpectedly contains forbidden binary surface '$($binary.FullName)'."
            }
        }
    }
    $legacy = @(Get-ChildItem -LiteralPath $ArchiveRoot -Recurse -File |
            Where-Object { $_.Name -like 'PrecompiledScript*.Cache' })
    if ($legacy.Count -ne 0) {
        throw "Packaged archive contains rejected legacy StaticJIT cache artifacts: $(@($legacy.FullName) -join '; ')"
    }
}

function Read-StaticJITRoutingRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,

        [Parameter(Mandatory = $true)]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [PSObject]$Manifest,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedProfile
    )

    if (-not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
        throw "Packaged process log was not produced: $LogPath"
    }
    $log = [string](Get-Content -LiteralPath $LogPath -Raw)
    $pattern = 'StaticJIT Provider routing: code=(?<code>\d+) profile=(?<profile>\w+) publication=(?<publication>\d+) providers=(?<providers>\d+) verified=(?<verified>\d+) exact=(?<exact>\d+) native=(?<native>\d+) vm=(?<vm>\d+) references=(?<resolved>\d+)/(?<requested>\d+) sourceRoute=(?<source>\d+) publishedRoute=(?<published>\d+) matchResults=\[(?<matches>[^\]]*)\]'
    $matches = [regex]::Matches($log, $pattern)
    if ($matches.Count -eq 0) {
        return Read-AngelscriptJITStructuredRoutingRecord `
            -ReportPath $ReportPath `
            -Manifest $Manifest `
            -ExpectedProfile $ExpectedProfile
    }
    if ($matches.Count -gt 1) {
        throw "Expected exactly one successful startup StaticJIT routing record; found $($matches.Count)."
    }
    $match = $matches[0]
    $stableRouteSet = @($Manifest.functions | ForEach-Object {
            '{0}|{1}' -f $_.moduleKey, $_.functionKey
        } | Sort-Object) -join ','
    $record = [ordered]@{
        EvidenceSource = 'StartupLog'
        Code = [int]$match.Groups['code'].Value
        Profile = $match.Groups['profile'].Value
        PublicationOrdinal = [uint64]$match.Groups['publication'].Value
        ProviderCount = [int]$match.Groups['providers'].Value
        VerifiedRouteCount = [int]$match.Groups['verified'].Value
        ExactMatchCount = [int]$match.Groups['exact'].Value
        PublishedNativeCount = [int]$match.Groups['native'].Value
        VmFallbackCount = [int]$match.Groups['vm'].Value
        ResolvedReferenceCount = [int]$match.Groups['resolved'].Value
        RequestedReferenceCount = [int]$match.Groups['requested'].Value
        SourceRouteGeneration = [uint64]$match.Groups['source'].Value
        PublishedRouteGeneration = [uint64]$match.Groups['published'].Value
        MatchResults = $match.Groups['matches'].Value
        StableRouteSet = $stableRouteSet
    }
    if ($record.Code -ne 0 -or $record.Profile -ne $ExpectedProfile) {
        throw "Packaged StaticJIT routing did not apply the expected profile '$ExpectedProfile'."
    }
    if ($record.ProviderCount -ne 1) {
        throw "Packaged startup expected exactly one project provider; found $($record.ProviderCount)."
    }
    $expectedNativeCount = @($Manifest.functions).Count
    if ($record.PublishedNativeCount -ne $expectedNativeCount -or
        $record.ExactMatchCount -ne $expectedNativeCount) {
        throw "Packaged provider published $($record.PublishedNativeCount)/$($record.ExactMatchCount) native/exact routes; expected $expectedNativeCount."
    }
    if ($record.ResolvedReferenceCount -ne $record.RequestedReferenceCount) {
        throw 'Packaged provider did not resolve every requested stable reference.'
    }
    if (($record.PublishedNativeCount + $record.VmFallbackCount) -ne
        $record.VerifiedRouteCount) {
        throw 'Packaged native plus VM routes do not account for every verified route.'
    }
    return [PSCustomObject]$record
}

function Get-StaticJITStableLaunchSignature {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$Manifest,

        [Parameter(Mandatory = $true)]
        [PSObject]$Route
    )

    $moduleKeys = @($Manifest.modules | ForEach-Object { [string]$_.moduleKey } |
            Sort-Object) -join ','
    return @(
        [string]$Manifest.providerId,
        [string]$Manifest.providerGeneration,
        [string]$Manifest.artifactSetDigest,
        [string]$Manifest.artifactProfile,
        [string]$Manifest.nativeEnvironment,
        $moduleKeys,
        [string]$Route.Profile,
        [string]$Route.ProviderCount,
        [string]$Route.VerifiedRouteCount,
        [string]$Route.ExactMatchCount,
        [string]$Route.PublishedNativeCount,
        [string]$Route.VmFallbackCount,
        [string]$Route.ResolvedReferenceCount,
        [string]$Route.RequestedReferenceCount,
        [string]$Route.MatchResults,
        [string]$Route.StableRouteSet
    ) -join '|'
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectName = [System.IO.Path]::GetFileNameWithoutExtension(
    (Get-ChildItem -LiteralPath $projectRoot -Filter '*.uproject' -File |
        Select-Object -First 1).Name)
$profile = if ($Configuration -eq 'Shipping') {
    'GameShipping'
}
else {
    'GameDevelopment'
}
$resolvedTimeoutMs = Resolve-TimeoutMs `
    -RequestedTimeoutMs $TimeoutMs `
    -DefaultTimeoutMs 3600000 `
    -ParameterName 'TimeoutMs'
$deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs

if ($SkipPackage) {
    if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
        throw '-SkipPackage requires -OutputRoot to identify one exact prior smoke-run root.'
    }
    $runRoot = Normalize-PathValue -Path $OutputRoot
    if (-not (Test-Path -LiteralPath $runRoot -PathType Container)) {
        throw "The prior StaticJIT package-smoke root does not exist: $runRoot"
    }
}
else {
    $layout = New-CommandOutputLayout `
        -ProjectRoot $projectRoot `
        -Category 'StaticJITPackage' `
        -Label "$Label-$Configuration" `
        -RequestedOutputRoot $OutputRoot `
        -LogFileName 'StaticJITPackageSmoke.log' `
        -ReportFolderName 'Reports'
    $runRoot = $layout.OutputRoot
}

$archiveRoot = Join-Path $runRoot 'Archive'
$packageLogRoot = Join-Path $runRoot 'Package'
$summaryPath = Join-Path $runRoot 'Summary.json'
$metadataPath = Join-Path $runRoot 'RunMetadata.json'
$startedAtUtc = [DateTime]::UtcNow
$launchRecords = New-Object System.Collections.Generic.List[object]
$finalExitCode = 1
$failure = ''
$manifestPath = Join-Path $projectRoot (
    "Source\AngelscriptJIT\Generated\{0}\ProviderManifest.generated.json" -f
        $profile)
$manifest = $null
$linkResponsePath = ''
$moduleBuildRulesPath = ''

try {
    $manifest = Read-StaticJITProviderManifest `
        -Path $manifestPath `
        -ExpectedProfile $profile
    $moduleBuildRulesPath = Assert-StaticJITModuleDependencySurface `
        -ProjectRoot $projectRoot

    if (-not $SkipPackage) {
        $packageTimeoutMs = Get-RemainingTimeoutMs `
            -DeadlineUtc $deadlineUtc `
            -PhaseName "$Configuration StaticJIT package"
        $packageResult = Invoke-StreamingProcess `
            -FilePath 'powershell.exe' `
            -ArgumentList @(
                '-NoProfile',
                '-ExecutionPolicy', 'Bypass',
                '-File', (Join-Path $PSScriptRoot 'RunPackage.ps1'),
                '-TimeoutMs', $packageTimeoutMs,
                '-Label', "$Label-$Configuration-package",
                '-Configuration', $Configuration,
                '-ArchiveDir', $archiveRoot,
                '-LogRoot', $packageLogRoot,
                '-NoXGE') `
            -WorkingDirectory $projectRoot `
            -TimeoutMs $packageTimeoutMs `
            -LogPath (Join-Path $runRoot 'PackageRunner.log') `
            -Label 'staticjit-package-build'
        if ($packageResult.TimedOut -or [int]$packageResult.ExitCode -ne 0) {
            throw "RunPackage failed for $Configuration (exit $($packageResult.ExitCode), timedOut=$($packageResult.TimedOut))."
        }
    }

    $packageLayout = Assert-AngelscriptLoosePackageLayout `
        -ArchiveRoot $archiveRoot `
        -ProjectName $projectName `
        -Configuration $Configuration
    $linkResponsePath = Assert-StaticJITGameLinkSurface `
        -ProjectRoot $projectRoot `
        -ProjectName $projectName `
        -Configuration $Configuration `
        -Profile $profile `
        -ExpectedModuleCount @($manifest.modules).Count
    Assert-StaticJITArchiveSurface -ArchiveRoot $archiveRoot

    $packageRoot = Split-Path -Parent $packageLayout.ScriptRoot
    $evidenceRoot = Join-Path $packageRoot 'Saved\StaticJITPackageSmoke'
    New-Item -ItemType Directory -Path $evidenceRoot -Force | Out-Null
    $signatures = New-Object System.Collections.Generic.List[string]
    for ($launchIndex = 1; $launchIndex -le 2; ++$launchIndex) {
        $launchId = '{0:D2}' -f $launchIndex
        # Deliberately create cache roots in reverse lexical order. StaticJIT
        # matching must not depend on persisted-cache directory creation order.
        $cacheLeaf = if ($launchIndex -eq 1) { 'CacheZ' } else { 'CacheA' }
        $cacheRoot = Join-Path $evidenceRoot $cacheLeaf
        $reportPath = Join-Path $evidenceRoot "Launch-$launchId.json"
        $logPath = Join-Path $evidenceRoot "Launch-$launchId.log"
        $remainingMs = Get-RemainingTimeoutMs `
            -DeadlineUtc $deadlineUtc `
            -PhaseName "$Configuration packaged launch $launchId"
        $launchTimeoutMs = Resolve-AngelscriptCachePackageLaunchTimeoutMs `
            -RemainingTimeoutMs $remainingMs
        $launch = Invoke-AngelscriptPackagedCacheLaunch `
            -ArchiveRoot $archiveRoot `
            -Executable $packageLayout.Executable `
            -CacheRoot $cacheRoot `
            -ReportPath $reportPath `
            -LogPath $logPath `
            -DiagnosticsMode Summary `
            -TimeoutMs $launchTimeoutMs
        if ($launch.TimedOut -or $launch.ExitCode -ne 0) {
            throw "Packaged launch $launchId failed (exit $($launch.ExitCode), timedOut=$($launch.TimedOut))."
        }
        $route = Read-StaticJITRoutingRecord `
            -LogPath $logPath `
            -ReportPath $reportPath `
            -Manifest $manifest `
            -ExpectedProfile $profile
        $signature = Get-StaticJITStableLaunchSignature `
            -Manifest $manifest `
            -Route $route
        $signatures.Add($signature) | Out-Null
        $launchRecords.Add([PSCustomObject]@{
                Id = $launchId
                ExitCode = $launch.ExitCode
                TimedOut = $launch.TimedOut
                DurationMs = $launch.DurationMs
                CacheRoot = $cacheRoot
                ReportPath = $reportPath
                LogPath = $logPath
                Route = $route
                StableSelectionSignature = $signature
            }) | Out-Null
    }
    if ($signatures.Count -ne 2 -or $signatures[0] -ne $signatures[1]) {
        throw 'Two packaged process starts selected different stable StaticJIT routes.'
    }
    Assert-StaticJITArchiveSurface -ArchiveRoot $archiveRoot
    $finalExitCode = 0
}
catch {
    $failure = $_.Exception.Message
    Write-Host ("[error] {0}" -f $failure) -ForegroundColor Red
}
finally {
    $completedAtUtc = [DateTime]::UtcNow
    $summary = [ordered]@{
        Kind = 'StaticJITPackageSmoke'
        Configuration = $Configuration
        TargetProfile = $profile
        Label = $Label
        Status = if ($finalExitCode -eq 0) { 'Passed' } else { 'Failed' }
        ExitCode = $finalExitCode
        Failure = $failure
        StartedAtUtc = $startedAtUtc.ToString('o')
        CompletedAtUtc = $completedAtUtc.ToString('o')
        DurationMs = [int]($completedAtUtc - $startedAtUtc).TotalMilliseconds
        RunRoot = $runRoot
        ArchiveRoot = $archiveRoot
        ManifestPath = $manifestPath
        LinkResponsePath = $linkResponsePath
        ModuleBuildRulesPath = $moduleBuildRulesPath
        ProviderId = if ($null -ne $manifest) { [string]$manifest.providerId } else { '' }
        ProviderGeneration = if ($null -ne $manifest) { [string]$manifest.providerGeneration } else { '' }
        ModuleCount = if ($null -ne $manifest) { @($manifest.modules).Count } else { 0 }
        FunctionCount = if ($null -ne $manifest) { @($manifest.functions).Count } else { 0 }
        Launches = @($launchRecords.ToArray())
    }
    Write-Utf8JsonFile -Path $summaryPath -Value $summary -Depth 12
    Write-Utf8JsonFile -Path $metadataPath -Value ([ordered]@{
            Kind = 'StaticJITPackageSmoke'
            Configuration = $Configuration
            TargetProfile = $profile
            SkipPackage = [bool]$SkipPackage
            TimeoutMs = $resolvedTimeoutMs
            RunRoot = $runRoot
            ArchiveRoot = $archiveRoot
            SummaryPath = $summaryPath
            ExitCode = $finalExitCode
        }) -Depth 6
}

Write-Host ('StaticJIT package config : {0}' -f $Configuration)
Write-Host ('RunRoot                 : {0}' -f $runRoot)
Write-Host ('Summary                 : {0}' -f $summaryPath)
Write-Host ('FinalExitCode           : {0}' -f $finalExitCode)
exit $finalExitCode
