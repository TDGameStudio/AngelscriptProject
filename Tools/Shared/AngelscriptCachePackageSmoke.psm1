Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'UnrealCommandUtils.ps1')

function New-AngelscriptPackageRunnerArguments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectFile,

        [Parameter(Mandatory = $true)]
        [string]$Platform,

        [Parameter(Mandatory = $true)]
        [string]$Configuration,

        [Parameter(Mandatory = $true)]
        [string]$ArchiveDir,

        [string]$Map = '',

        [switch]$NoXGE,

        [string[]]$ExtraArgs = @()
    )

    $arguments = New-Object System.Collections.Generic.List[string]
    $arguments.Add('BuildCookRun') | Out-Null
    $arguments.Add("-project=$ProjectFile") | Out-Null
    $arguments.Add('-noP4') | Out-Null
    $arguments.Add('-utf8output') | Out-Null
    $arguments.Add("-platform=$Platform") | Out-Null
    $arguments.Add("-clientconfig=$Configuration") | Out-Null
    $arguments.Add('-build') | Out-Null
    $arguments.Add('-cook') | Out-Null
    $arguments.Add('-stage') | Out-Null
    $arguments.Add('-pak') | Out-Null
    $arguments.Add('-archive') | Out-Null
    $arguments.Add("-archivedirectory=$ArchiveDir") | Out-Null
    $arguments.Add('-nocompileeditor') | Out-Null
    if (-not [string]::IsNullOrWhiteSpace($Map)) {
        $arguments.Add("-map=$Map") | Out-Null
    }
    if ($NoXGE) {
        # RunUAT's -noxge controls UBT only. The Cook commandlet independently
        # loads XGEController unless its own command line disables shader XGE.
        $arguments.Add('-noxge') | Out-Null
        $arguments.Add(
            '-AdditionalCookerOptions=-noxgeshadercompile') | Out-Null
    }
    if ($null -ne $ExtraArgs -and $ExtraArgs.Count -gt 0) {
        foreach ($extra in $ExtraArgs) {
            $arguments.Add($extra) | Out-Null
        }
    }

    return @($arguments.ToArray())
}

function Get-AngelscriptCacheSmokeFullPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-AngelscriptCacheSmokePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$CandidatePath,

        [string]$Purpose = 'cache package-smoke operation'
    )

    $resolvedRoot = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $resolvedCandidate = Get-AngelscriptCacheSmokeFullPath -Path $CandidatePath
    $rootPrefix = $resolvedRoot.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar) +
        [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolvedCandidate.Equals(
            $resolvedRoot,
            [System.StringComparison]::OrdinalIgnoreCase) -and
        -not $resolvedCandidate.StartsWith(
            $rootPrefix,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Purpose escaped the disposable archive root. Archive=[$resolvedRoot] Candidate=[$resolvedCandidate]"
    }
    return $resolvedCandidate
}

function Get-AngelscriptCacheSmokeArchiveRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$CandidatePath
    )

    $resolvedRoot = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $resolvedCandidate = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedRoot `
        -CandidatePath $CandidatePath `
        -Purpose 'package-relative path calculation'
    if ($resolvedCandidate.Equals(
            $resolvedRoot,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        return ''
    }

    $rootPrefix = $resolvedRoot.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar) +
        [System.IO.Path]::DirectorySeparatorChar
    return $resolvedCandidate.Substring($rootPrefix.Length)
}

function Reset-AngelscriptCacheSmokeEvidence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$EvidenceRoot
    )

    $resolvedArchive = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $resolvedEvidence = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $EvidenceRoot `
        -Purpose 'package-smoke evidence reset'
    $evidenceLeaf = Split-Path -Leaf $resolvedEvidence
    $parentLeaf = Split-Path -Leaf (Split-Path -Parent $resolvedEvidence)
    if ($resolvedEvidence.Equals(
            $resolvedArchive,
            [System.StringComparison]::OrdinalIgnoreCase) -or
        $evidenceLeaf -ne 'CachePackageSmoke' -or
        $parentLeaf -ne 'Saved') {
        throw "Package-smoke evidence reset requires an exact Saved/CachePackageSmoke directory below the disposable archive: $resolvedEvidence"
    }

    if (Test-Path -LiteralPath $resolvedEvidence) {
        $item = Get-Item -LiteralPath $resolvedEvidence -Force
        if (-not $item.PSIsContainer -or
            ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            throw "Package-smoke evidence reset rejected a non-directory or reparse-point target: $resolvedEvidence"
        }
        Remove-Item -LiteralPath $resolvedEvidence -Recurse -Force
    }
    return $resolvedEvidence
}

function Test-AngelscriptCacheSmokeExcludedPackagePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$CandidatePath
    )

    $relativePath = Get-AngelscriptCacheSmokeArchiveRelativePath `
        -ArchiveRoot $ArchiveRoot `
        -CandidatePath $CandidatePath
    $normalized = ('\' + $relativePath.Replace('/', '\'))
    return $normalized -match '(?i)\\Content\\Paks\\' -or
        $normalized -match '(?i)\\SimulatedUFS\\' -or
        $normalized -match '(?i)\\Saved\\'
}

function Resolve-AngelscriptPackagedExecutable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [ValidateSet('Development', 'Shipping')]
        [string]$Configuration
    )

    $resolvedRoot = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    if (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
        throw "Packaged archive root was not found: $resolvedRoot"
    }

    $acceptedBaseNames = @(
        $ProjectName,
        "$ProjectName-Win64-$Configuration"
    )
    $candidates = @(
        Get-ChildItem -LiteralPath $resolvedRoot -Directory |
            ForEach-Object {
                Get-ChildItem -LiteralPath $_.FullName -Filter '*.exe' -File
            } |
            Where-Object {
                $acceptedBaseNames -contains $_.BaseName -and
                -not (Test-AngelscriptCacheSmokeExcludedPackagePath `
                    -ArchiveRoot $resolvedRoot `
                    -CandidatePath $_.FullName)
            } |
            Sort-Object -Property FullName
    )
    if ($candidates.Count -ne 1) {
        $display = if ($candidates.Count -eq 0) {
            '<none>'
        }
        else {
            @($candidates.FullName) -join '; '
        }
        throw "Expected exactly one packaged $Configuration executable for '$ProjectName'; found $($candidates.Count): $display"
    }
    return (Assert-AngelscriptCacheSmokePath `
            -ArchiveRoot $resolvedRoot `
            -CandidatePath $candidates[0].FullName `
            -Purpose 'packaged executable discovery')
}

function Resolve-AngelscriptPackagedScriptRoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot
    )

    $resolvedRoot = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    if (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
        throw "Packaged archive root was not found: $resolvedRoot"
    }

    $candidates = @(
        Get-ChildItem -LiteralPath $resolvedRoot -Directory -Filter 'Script' -Recurse |
            Where-Object {
                -not (Test-AngelscriptCacheSmokeExcludedPackagePath `
                    -ArchiveRoot $resolvedRoot `
                    -CandidatePath $_.FullName)
            } |
            Sort-Object -Property FullName
    )
    if ($candidates.Count -ne 1) {
        $display = if ($candidates.Count -eq 0) {
            '<none outside Pak/UFS/Saved>'
        }
        else {
            @($candidates.FullName) -join '; '
        }
        throw "Expected exactly one loose staged Script root; found $($candidates.Count): $display"
    }
    return (Assert-AngelscriptCacheSmokePath `
            -ArchiveRoot $resolvedRoot `
            -CandidatePath $candidates[0].FullName `
            -Purpose 'loose Script discovery')
}

function Assert-AngelscriptLoosePackageLayout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [ValidateSet('Development', 'Shipping')]
        [string]$Configuration
    )

    $resolvedRoot = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $executable = Resolve-AngelscriptPackagedExecutable `
        -ArchiveRoot $resolvedRoot `
        -ProjectName $ProjectName `
        -Configuration $Configuration
    $scriptRoot = Resolve-AngelscriptPackagedScriptRoot `
        -ArchiveRoot $resolvedRoot
    $bindsPath = Join-Path $scriptRoot 'Binds.Cache'
    if (-not (Test-Path -LiteralPath $bindsPath -PathType Leaf)) {
        throw "Loose staged Script is missing Binds.Cache: $bindsPath"
    }

    $sources = @(
        Get-ChildItem -LiteralPath $scriptRoot -Filter '*.as' -File -Recurse |
            Sort-Object -Property FullName
    )
    if ($sources.Count -eq 0) {
        throw "Loose staged Script contains no authoritative .as source: $scriptRoot"
    }

    $legacyArtifacts = @(
        Get-ChildItem -LiteralPath $resolvedRoot -Filter 'PrecompiledScript*.Cache' -File -Recurse |
            Sort-Object -Property FullName
    )
    if ($legacyArtifacts.Count -gt 0) {
        throw "Packaged archive contains rejected legacy script cache artifact(s): $(@($legacyArtifacts.FullName) -join '; ')"
    }

    $packagedCacheRoot = Join-Path $scriptRoot 'AngelscriptCache'
    if (Test-Path -LiteralPath $packagedCacheRoot) {
        throw "Packaged archive must not contain a Script/AngelscriptCache baseline: $packagedCacheRoot"
    }

    return [PSCustomObject]@{
        ArchiveRoot = $resolvedRoot
        Executable = $executable
        ScriptRoot = $scriptRoot
        BindsCache = Get-AngelscriptCacheSmokeFullPath -Path $bindsPath
        SourceCount = $sources.Count
    }
}

function New-AngelscriptCacheSmokeFixture {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$ScriptRoot
    )

    $resolvedArchive = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $resolvedScript = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $ScriptRoot `
        -Purpose 'package-smoke Script selection'
    if (-not (Test-Path -LiteralPath $resolvedScript -PathType Container)) {
        throw "The validated loose Script root does not exist: $resolvedScript"
    }

    $fixtureRoot = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath (Join-Path $resolvedScript 'Game\CacheSmoke') `
        -Purpose 'package-smoke fixture creation'
    $sourcePath = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath (Join-Path $fixtureRoot 'CachePackageSmoke.as') `
        -Purpose 'package-smoke source creation'
    New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null

    $baseline = @'
enum ECachePackageSmokeState
{
    Ready = 1,
}

class FCachePackageSmokeType
{
    int Value = 1;

    int Read()
    {
        return Value;
    }
}

const int CachePackageSmokeGlobal = 10;

int ReadCachePackageSmokeValue()
{
    return 101;
}
'@
    $bodyEdit = @'
enum ECachePackageSmokeState
{
    Ready = 1,
}

class FCachePackageSmokeType
{
    int Value = 1;

    int Read()
    {
        return Value;
    }
}

const int CachePackageSmokeGlobal = 10;

int ReadCachePackageSmokeValue()
{
    return 202;
}
'@
    $invalidSource = @'
enum ECachePackageSmokeState
{
    Ready = 1,
}

class FCachePackageSmokeType
{
    int Value = 1;

    int Read()
    {
        return Value;
    }
}

const int CachePackageSmokeGlobal = 10;

int ReadCachePackageSmokeValue()
{
    THIS_IS_INTENTIONALLY_INVALID CACHE SOURCE
}
'@
    $structuralEdit = @'
enum ECachePackageSmokeState
{
    Ready = 1,
    StructuralValue = 2,
}

class FCachePackageSmokeType
{
    int Value = 1;

    int Read()
    {
        return Value;
    }
}

const int CachePackageSmokeGlobal = 10;

int ReadCachePackageSmokeValue()
{
    return 303;
}
'@
    $typeSchemaEdit = @'
enum ECachePackageSmokeState
{
    Ready = 1,
}

class FCachePackageSmokeType
{
    int Value = 1;
    int ExtraValue = 2;

    int Read()
    {
        return Value;
    }
}

const int CachePackageSmokeGlobal = 10;

int ReadCachePackageSmokeValue()
{
    return 101;
}
'@
    $moduleStateEdit = @'
enum ECachePackageSmokeState
{
    Ready = 1,
}

class FCachePackageSmokeType
{
    int Value = 1;

    int Read()
    {
        return Value;
    }
}

const int CachePackageSmokeGlobal = 20;

int ReadCachePackageSmokeValue()
{
    return 101;
}
'@
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($sourcePath, $baseline, $utf8)
    return [PSCustomObject]@{
        ArchiveRoot = $resolvedArchive
        ScriptRoot = $resolvedScript
        FixtureRoot = $fixtureRoot
        SourcePath = $sourcePath
        Baseline = $baseline
        BodyEdit = $bodyEdit
        InvalidSource = $invalidSource
        StructuralEdit = $structuralEdit
        TypeSchemaEdit = $typeSchemaEdit
        ModuleStateEdit = $moduleStateEdit
    }
}

function Set-AngelscriptCacheSmokeFixtureScenario {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$Fixture,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Baseline', 'BodyEdit', 'InvalidSource', 'StructuralEdit',
            'TypeSchemaEdit', 'ModuleStateEdit')]
        [string]$Scenario
    )

    $sourcePath = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot ([string]$Fixture.ArchiveRoot) `
        -CandidatePath ([string]$Fixture.SourcePath) `
        -Purpose 'package-smoke scenario mutation'
    $content = [string]$Fixture.$Scenario
    [System.IO.File]::WriteAllText(
        $sourcePath,
        $content,
        (New-Object System.Text.UTF8Encoding($false)))
    return $sourcePath
}

function Resolve-AngelscriptCachePackageLaunchTimeoutMs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$RemainingTimeoutMs,

        [int]$MaximumLaunchTimeoutMs = 300000,

        [int]$CleanupHeadroomMs = 30000
    )

    if ($RemainingTimeoutMs -le 0) {
        throw 'Remaining packaged cache launch timeout must be positive.'
    }
    if ($MaximumLaunchTimeoutMs -le 0) {
        throw 'Maximum packaged cache launch timeout must be positive.'
    }
    if ($CleanupHeadroomMs -lt 0) {
        throw 'Packaged cache launch cleanup headroom cannot be negative.'
    }
    if ($RemainingTimeoutMs -le $CleanupHeadroomMs) {
        throw "Packaged cache launch has only $RemainingTimeoutMs ms remaining and cannot reserve $CleanupHeadroomMs ms for cleanup."
    }

    return [Math]::Min(
        $MaximumLaunchTimeoutMs,
        $RemainingTimeoutMs - $CleanupHeadroomMs)
}

function Invoke-AngelscriptPackagedCacheLaunch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$Executable,

        [Parameter(Mandatory = $true)]
        [string]$CacheRoot,

        [Parameter(Mandatory = $true)]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [string]$LogPath,

        [string]$Map = '/Game/Test/ActorTestMap',

        [ValidateSet('Disabled', 'Summary', 'Verbose')]
        [string]$DiagnosticsMode = 'Verbose',

        [string[]]$ExtraArguments = @(),

        [int]$TimeoutMs = 300000,

        [scriptblock]$ProcessInvoker
    )

    if ($TimeoutMs -le 0) {
        throw 'Packaged cache launch TimeoutMs must be positive.'
    }
    $resolvedArchive = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $resolvedExecutable = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $Executable `
        -Purpose 'packaged executable launch'
    $resolvedCache = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $CacheRoot `
        -Purpose 'packaged cache root selection'
    $resolvedReport = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $ReportPath `
        -Purpose 'packaged process report selection'
    $resolvedLog = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $LogPath `
        -Purpose 'packaged process log selection'
    if (-not (Test-Path -LiteralPath $resolvedExecutable -PathType Leaf)) {
        throw "Packaged executable was not found: $resolvedExecutable"
    }
    foreach ($directory in @(
            $resolvedCache,
            (Split-Path -Parent $resolvedReport),
            (Split-Path -Parent $resolvedLog))) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $arguments = New-Object System.Collections.Generic.List[string]
    if (-not [string]::IsNullOrWhiteSpace($Map)) {
        $arguments.Add($Map) | Out-Null
    }
    $arguments.Add('-nullrhi') | Out-Null
    $arguments.Add('-unattended') | Out-Null
    $arguments.Add('-nosplash') | Out-Null
    $arguments.Add('-nosound') | Out-Null
    $arguments.Add("-as-cache-root=$resolvedCache") | Out-Null
    if ($DiagnosticsMode -ne 'Disabled') {
        $arguments.Add("-as-cache-report=$resolvedReport") | Out-Null
    }
    if ($DiagnosticsMode -eq 'Verbose') {
        # Consumed while FAngelscriptEngineConfig is created, before startup
        # selection. Enabling the trace later would miss exact-start decisions.
        $arguments.Add('-as-cache-trace') | Out-Null
        # The isolated verbose mode retains detailed capture rejection reasons
        # without changing normal game logging defaults.
        $arguments.Add('-LogCmds=Angelscript Verbose') | Out-Null
    }
    foreach ($extraArgument in @($ExtraArguments)) {
        if ([string]::IsNullOrWhiteSpace($extraArgument)) {
            throw 'Packaged cache launch ExtraArguments cannot contain empty values.'
        }
        if ($extraArgument -like '-as-cache-root=*' -or
            $extraArgument -like '-as-cache-report=*' -or
            $extraArgument -eq '-as-cache-exit-after-startup' -or
            $extraArgument -like '-ExecCmds=*') {
            throw "Packaged cache launch ExtraArguments cannot replace the isolated lifecycle coordinate: $extraArgument"
        }
        $arguments.Add($extraArgument) | Out-Null
    }
    # Shipping compiles out ExecCmds. This explicit Runtime lifecycle hook waits
    # for successful AS startup, then requests normal Engine shutdown so the
    # production Cache flush and process-report path runs unchanged.
    $arguments.Add('-as-cache-exit-after-startup') | Out-Null
    $argumentArray = @($arguments.ToArray())
    $workingDirectory = Split-Path -Parent $resolvedExecutable

    $processResult = if ($null -ne $ProcessInvoker) {
        & $ProcessInvoker `
            $resolvedExecutable `
            $argumentArray `
            $workingDirectory `
            $TimeoutMs `
            $resolvedLog
    }
    else {
        Invoke-StreamingProcess `
            -FilePath $resolvedExecutable `
            -ArgumentList $argumentArray `
            -WorkingDirectory $workingDirectory `
            -TimeoutMs $TimeoutMs `
            -LogPath $resolvedLog `
            -Label 'cache-package-launch'
    }

    return [PSCustomObject]@{
        ExitCode = [int]$processResult.ExitCode
        TimedOut = [bool]$processResult.TimedOut
        DurationMs = [int]$processResult.DurationMs
        Executable = $resolvedExecutable
        Arguments = $argumentArray
        WorkingDirectory = $workingDirectory
        CacheRoot = $resolvedCache
        ReportPath = $resolvedReport
        LogPath = $resolvedLog
        DiagnosticsMode = $DiagnosticsMode
    }
}

function Invoke-AngelscriptCacheV2Dump {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchiveRoot,

        [Parameter(Mandatory = $true)]
        [string]$CacheRoot,

        [Parameter(Mandatory = $true)]
        [string]$ToolPath,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [string[]]$GenerationSelectors = @(),

        [string[]]$DiffSelectors = @(),

        [string]$SessionReport = '',

        [int]$TimeoutMs = 120000,

        [scriptblock]$ProcessInvoker
    )

    if ($TimeoutMs -le 0) {
        throw 'Cache V2 dump TimeoutMs must be positive.'
    }
    if ($GenerationSelectors.Count -gt 0 -and $DiffSelectors.Count -gt 0) {
        throw 'Cache V2 dump cannot combine generation and diff selectors.'
    }
    if ($DiffSelectors.Count -ne 0 -and $DiffSelectors.Count -ne 2) {
        throw 'Cache V2 dump diff requires exactly two generation selectors.'
    }

    $resolvedArchive = Get-AngelscriptCacheSmokeFullPath -Path $ArchiveRoot
    $resolvedCache = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $CacheRoot `
        -Purpose 'Cache V2 dump input selection'
    $resolvedOutput = Assert-AngelscriptCacheSmokePath `
        -ArchiveRoot $resolvedArchive `
        -CandidatePath $OutputPath `
        -Purpose 'Cache V2 dump output selection'
    $resolvedTool = Get-AngelscriptCacheSmokeFullPath -Path $ToolPath
    if (-not (Test-Path -LiteralPath $resolvedTool -PathType Leaf)) {
        throw "Cache V2 dump tool was not found: $resolvedTool"
    }
    if (-not (Test-Path -LiteralPath $resolvedCache -PathType Container)) {
        throw "Cache V2 dump root was not found: $resolvedCache"
    }
    $resolvedSession = ''
    if (-not [string]::IsNullOrWhiteSpace($SessionReport)) {
        $resolvedSession = Assert-AngelscriptCacheSmokePath `
            -ArchiveRoot $resolvedArchive `
            -CandidatePath $SessionReport `
            -Purpose 'Cache V2 session correlation input'
        if (-not (Test-Path -LiteralPath $resolvedSession -PathType Leaf)) {
            throw "Cache V2 session report was not found: $resolvedSession"
        }
    }
    New-Item -ItemType Directory -Path (
        Split-Path -Parent $resolvedOutput) -Force | Out-Null

    $arguments = New-Object System.Collections.Generic.List[string]
    $arguments.Add($resolvedTool) | Out-Null
    $arguments.Add($resolvedCache) | Out-Null
    $arguments.Add('--json') | Out-Null
    foreach ($selector in $GenerationSelectors) {
        if ([string]::IsNullOrWhiteSpace($selector)) {
            throw 'Cache V2 dump generation selector cannot be empty.'
        }
        $arguments.Add('--generation') | Out-Null
        $arguments.Add($selector) | Out-Null
    }
    if ($DiffSelectors.Count -eq 2) {
        $arguments.Add('--diff') | Out-Null
        $arguments.Add($DiffSelectors[0]) | Out-Null
        $arguments.Add($DiffSelectors[1]) | Out-Null
    }
    if (-not [string]::IsNullOrWhiteSpace($resolvedSession)) {
        $arguments.Add('--session-report') | Out-Null
        $arguments.Add($resolvedSession) | Out-Null
    }
    $argumentArray = @($arguments.ToArray())
    $workingDirectory = Split-Path -Parent $resolvedTool
    $processResult = if ($null -ne $ProcessInvoker) {
        & $ProcessInvoker `
            'python' `
            $argumentArray `
            $workingDirectory `
            $TimeoutMs `
            $resolvedOutput
    }
    else {
        Invoke-StreamingProcess `
            -FilePath 'python' `
            -ArgumentList $argumentArray `
            -WorkingDirectory $workingDirectory `
            -TimeoutMs $TimeoutMs `
            -LogPath $resolvedOutput `
            -Label 'cache-v2-dump'
    }
    if ([bool]$processResult.TimedOut -or [int]$processResult.ExitCode -ne 0) {
        throw "Cache V2 dump failed (exit $($processResult.ExitCode), timedOut=$($processResult.TimedOut)): $resolvedOutput"
    }
    if (-not (Test-Path -LiteralPath $resolvedOutput -PathType Leaf)) {
        throw "Cache V2 dump did not produce JSON: $resolvedOutput"
    }
    try {
        $document = Get-Content -LiteralPath $resolvedOutput -Raw -Encoding UTF8 |
            ConvertFrom-Json
    }
    catch {
        throw "Cache V2 dump output is not valid JSON: $resolvedOutput. $($_.Exception.Message)"
    }
    if ($null -eq $document -or
        $document.PSObject.Properties.Name -notcontains 'ok' -or
        -not [bool]$document.ok) {
        throw "Cache V2 dump returned an unsuccessful document: $resolvedOutput"
    }
    return $document
}

function Read-AngelscriptCacheReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = Get-AngelscriptCacheSmokeFullPath -Path $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Cache V2 process report was not found: $resolvedPath"
    }
    try {
        $report = Get-Content -LiteralPath $resolvedPath -Raw -Encoding UTF8 |
            ConvertFrom-Json
    }
    catch {
        throw "Cache V2 process report is not valid JSON: $resolvedPath. $($_.Exception.Message)"
    }

    $requiredTopLevel = @(
        'schemaVersion',
        'mutationPhase',
        'mutationPhaseName',
        'lastTransactionOrdinal',
        'current',
        'pendingColdStart',
        'latestSuccessful',
        'decisionTrace'
    )
    foreach ($field in $requiredTopLevel) {
        if ($report.PSObject.Properties.Name -notcontains $field) {
            throw "Cache V2 process report is missing required field '$field': $resolvedPath"
        }
    }
    if (@(1, 2, 3, 4) -notcontains [int]$report.schemaVersion) {
        throw "Unsupported Cache V2 process report schema '$($report.schemaVersion)': $resolvedPath"
    }
    foreach ($publicationName in @('current', 'pendingColdStart', 'latestSuccessful')) {
        $publication = $report.$publicationName
        if ($null -eq $publication -or
            $publication.PSObject.Properties.Name -notcontains 'present') {
            throw "Cache V2 process report publication '$publicationName' is incomplete: $resolvedPath"
        }
    }
    if ($null -eq $report.decisionTrace -or
        $report.decisionTrace.PSObject.Properties.Name -notcontains 'schemaVersion' -or
        $report.decisionTrace.PSObject.Properties.Name -notcontains 'enabled' -or
        $report.decisionTrace.PSObject.Properties.Name -notcontains 'events') {
        throw "Cache V2 process report decisionTrace is incomplete: $resolvedPath"
    }
    if ([int]$report.schemaVersion -ge 3) {
        if ($report.PSObject.Properties.Name -notcontains 'functionRoutes' -or
            $null -eq $report.functionRoutes -or
            $report.functionRoutes.PSObject.Properties.Name -notcontains 'present' -or
            $report.functionRoutes.present -isnot [bool]) {
            throw "Cache V2 schema-3 process report functionRoutes is incomplete: $resolvedPath"
        }
        if ([bool]$report.functionRoutes.present) {
            foreach ($field in @(
                    'publicationOrdinal',
                    'vmRouteCount',
                    'nativeRouteCount',
                    'routes')) {
                if ($report.functionRoutes.PSObject.Properties.Name -notcontains
                    $field) {
                    throw "Cache V2 schema-3 process report functionRoutes is missing '$field': $resolvedPath"
                }
            }
            if ([string]$report.functionRoutes.publicationOrdinal -notmatch
                '^\d+$') {
                throw "Cache V2 schema-3 functionRoutes publicationOrdinal is invalid: $resolvedPath"
            }
            if ([int]$report.functionRoutes.vmRouteCount -lt 0 -or
                [int]$report.functionRoutes.nativeRouteCount -lt 0) {
                throw "Cache V2 schema-3 functionRoutes counts are invalid: $resolvedPath"
            }
        }
    }
    if ([int]$report.schemaVersion -ge 4) {
        if ($report.PSObject.Properties.Name -notcontains 'functionReuse' -or
            $null -eq $report.functionReuse -or
            $report.functionReuse.PSObject.Properties.Name -notcontains
                'present' -or
            $report.functionReuse.present -isnot [bool]) {
            throw "Cache V2 schema-4 process report functionReuse is incomplete: $resolvedPath"
        }
        if ([bool]$report.functionReuse.present) {
            foreach ($field in @(
                    'schemaVersion',
                    'candidateGenerationId',
                    'candidateModuleCount',
                    'restoredFunctionCount',
                    'compiledMissCount',
                    'notCacheableCount',
                    'rejectedCorruptCount')) {
                if ($report.functionReuse.PSObject.Properties.Name -notcontains
                    $field) {
                    throw "Cache V2 schema-4 process report functionReuse is missing '$field': $resolvedPath"
                }
            }
            if ([int]$report.functionReuse.schemaVersion -ne 1) {
                throw "Cache V2 functionReuse summary schema is unsupported: $resolvedPath"
            }
            $candidateGenerationId =
                [string]$report.functionReuse.candidateGenerationId
            if ($candidateGenerationId -notmatch '^[0-9a-f]{64}$' -or
                $candidateGenerationId -match '^0{64}$') {
                throw "Cache V2 functionReuse candidateGenerationId is invalid: $resolvedPath"
            }
            foreach ($field in @(
                    'candidateModuleCount',
                    'restoredFunctionCount',
                    'compiledMissCount',
                    'notCacheableCount',
                    'rejectedCorruptCount')) {
                if ([long]$report.functionReuse.$field -lt 0) {
                    throw "Cache V2 functionReuse count '$field' is invalid: $resolvedPath"
                }
            }
        }

        $captureFailures = @($report.decisionTrace.events | Where-Object {
                $_.PSObject.Properties.Name -contains 'reasonDomainName' -and
                [string]$_.reasonDomainName -eq 'CleanCapture' -and
                @('NotCacheable', 'Rejected') -contains
                    [string]$_.outcomeName
            })
        foreach ($captureFailure in $captureFailures) {
            if ($captureFailure.PSObject.Properties.Name -notcontains 'detail' -or
                [string]::IsNullOrWhiteSpace([string]$captureFailure.detail)) {
                throw "Cache V2 CleanCapture failure omitted its bounded detail: $resolvedPath"
            }
        }
    }
    return $report
}

function Assert-AngelscriptCacheScenarioReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Cold', 'Warm', 'BodyEdit', 'InvalidSource', 'Restored', 'StructuralEdit', 'StructuralWarm')]
        [string]$Scenario,

        [Parameter(Mandatory = $true)]
        [PSObject]$Report,

        [switch]$ExpectCurrent,

        [string]$ExpectedSourceSnapshot = '',

        [string]$DifferentSourceSnapshot = '',

        [switch]$RequireRestoredFromStore,

        [switch]$RequireNormalCompile,

        [switch]$RequireWarmCacheReuse,

        [string]$ExpectedPersistedGenerationId = '',

        [string]$ExpectedHybridCandidateGenerationId = '',

        [switch]$RequireExactStartupTrace
    )

    if (@(1, 2, 3, 4) -notcontains [int]$Report.schemaVersion -or
        [string]$Report.mutationPhaseName -ne 'ShuttingDown') {
        throw "Scenario '$Scenario' did not retain a complete shutdown report."
    }
    if (($RequireRestoredFromStore -and $RequireNormalCompile) -or
        ($RequireWarmCacheReuse -and $RequireNormalCompile)) {
        throw "Scenario '$Scenario' cannot require Cache reuse and normal compilation together."
    }
    if (($RequireRestoredFromStore -or $RequireNormalCompile -or
            -not [string]::IsNullOrWhiteSpace($ExpectedPersistedGenerationId) -or
            -not [string]::IsNullOrWhiteSpace(
                $ExpectedHybridCandidateGenerationId)) -and
        [int]$Report.schemaVersion -lt 2) {
        throw "Scenario '$Scenario' requires schema-2 Cache provenance."
    }
    if ($ExpectCurrent -and -not [bool]$Report.current.present) {
        throw "Scenario '$Scenario' expected a Current Cache V2 publication."
    }
    if (-not $ExpectCurrent -and $Scenario -eq 'InvalidSource' -and
        [bool]$Report.current.present) {
        throw "Invalid-source scenario must not publish a Current generation."
    }
    if ($ExpectCurrent) {
        foreach ($field in @('transactionOrdinal', 'sourceSnapshot')) {
            if ($Report.current.PSObject.Properties.Name -notcontains $field) {
                throw "Scenario '$Scenario' Current publication is missing '$field'."
            }
        }
        $sourceSnapshot = [string]$Report.current.sourceSnapshot
        if ($sourceSnapshot -notmatch '^[0-9a-f]{64}$') {
            throw "Scenario '$Scenario' Current sourceSnapshot is not a stable 256-bit key."
        }
        if (-not [string]::IsNullOrWhiteSpace($ExpectedSourceSnapshot) -and
            $sourceSnapshot -ne $ExpectedSourceSnapshot) {
            throw "Scenario '$Scenario' sourceSnapshot did not match the expected generation."
        }
        if (-not [string]::IsNullOrWhiteSpace($DifferentSourceSnapshot) -and
            $sourceSnapshot -eq $DifferentSourceSnapshot) {
            throw "Scenario '$Scenario' sourceSnapshot unexpectedly matched the prior generation."
        }

        if ([int]$Report.schemaVersion -ge 2) {
            if ($Report.current.PSObject.Properties.Name -notcontains
                'restoredFromStore') {
                throw "Scenario '$Scenario' Current publication is missing schema-2 restored provenance."
            }
            $restoredFromStore = [bool]$Report.current.restoredFromStore
            if ($RequireRestoredFromStore -and -not $restoredFromStore) {
                throw "Scenario '$Scenario' expected Current to be restored from Store."
            }
            if ($RequireNormalCompile -and $restoredFromStore) {
                throw "Scenario '$Scenario' expected normal compilation, not Store restoration."
            }
            if ($restoredFromStore) {
                if ($Report.current.PSObject.Properties.Name -notcontains
                    'persistedGenerationId') {
                    throw "Scenario '$Scenario' restored Current is missing persistedGenerationId."
                }
                $persistedGenerationId =
                    [string]$Report.current.persistedGenerationId
                if ($persistedGenerationId -notmatch '^[0-9a-f]{64}$') {
                    throw "Scenario '$Scenario' persistedGenerationId is not a stable 256-bit key."
                }
                if (-not [string]::IsNullOrWhiteSpace(
                        $ExpectedPersistedGenerationId) -and
                    $persistedGenerationId -ne
                        $ExpectedPersistedGenerationId.ToLowerInvariant()) {
                    throw "Scenario '$Scenario' restored the wrong persisted Generation."
                }
            }
            elseif (-not $RequireWarmCacheReuse -and
                -not [string]::IsNullOrWhiteSpace(
                    $ExpectedPersistedGenerationId)) {
                throw "Scenario '$Scenario' cannot match a persisted Generation without Store restoration."
            }
        }
    }

    if ($RequireWarmCacheReuse) {
        if ([int]$Report.schemaVersion -lt 4) {
            throw "Scenario '$Scenario' requires schema-4 function-reuse provenance."
        }
        if (-not [bool]$Report.decisionTrace.enabled) {
            throw "Scenario '$Scenario' expected pre-initialization Cache decision tracing."
        }
        $restoredFromStore = [bool]$Report.current.restoredFromStore
        if ($restoredFromStore) {
            $exactEvents = @($Report.decisionTrace.events | Where-Object {
                    [string]$_.stageName -eq 'StartupRestore' -and
                    [string]$_.outcomeName -eq 'Restored'
                })
            if ($exactEvents.Count -ne 1) {
                throw "Scenario '$Scenario' exact warm mode requires one StartupRestore event."
            }
        }
        else {
            $summary = $Report.functionReuse
            if (-not [bool]$summary.present -or
                [int]$summary.candidateModuleCount -lt 1 -or
                [int]$summary.restoredFunctionCount -lt 1) {
                throw "Scenario '$Scenario' did not prove hybrid function reuse."
            }
            if (-not [string]::IsNullOrWhiteSpace(
                    $ExpectedHybridCandidateGenerationId) -and
                [string]$summary.candidateGenerationId -ne
                    $ExpectedHybridCandidateGenerationId.ToLowerInvariant()) {
                throw "Scenario '$Scenario' hybrid reuse selected the wrong Generation."
            }
            $restoredEvents = @($Report.decisionTrace.events | Where-Object {
                    [string]$_.stageName -eq 'FunctionLookup' -and
                    [string]$_.outcomeName -eq 'Restored'
                })
            if ($restoredEvents.Count -lt 1) {
                throw "Scenario '$Scenario' aggregate hybrid proof has no typed restored lookup event."
            }
            $typedMissEvents = @($Report.decisionTrace.events | Where-Object {
                    ([string]$_.stageName -eq 'FunctionLookup' -and
                        [string]$_.outcomeName -in @(
                            'Compiled', 'Miss', 'NotCacheable', 'Rejected')) -or
                    ($_.PSObject.Properties.Name -contains 'reasonDomainName' -and
                        [string]$_.reasonDomainName -eq 'CleanCapture' -and
                        [string]$_.outcomeName -in @(
                            'NotCacheable', 'Rejected'))
                })
            if ($typedMissEvents.Count -lt 1) {
                throw "Scenario '$Scenario' hybrid reuse did not account for unsupported or compiled work."
            }
        }
    }

    if ($RequireExactStartupTrace) {
        if (-not [bool]$Report.decisionTrace.enabled) {
            throw "Scenario '$Scenario' expected pre-initialization Cache decision tracing."
        }
        $restoreEvents = @($Report.decisionTrace.events | Where-Object {
                [string]$_.stageName -eq 'StartupRestore' -and
                [string]$_.outcomeName -eq 'Restored'
            })
        if ($restoreEvents.Count -ne 1) {
            throw "Scenario '$Scenario' expected exactly one successful StartupRestore event, found $($restoreEvents.Count)."
        }
        $restoreEvent = $restoreEvents[0]
        if ([int]$restoreEvent.primaryCount -lt 1 -or
            [int]$restoreEvent.secondaryCount -lt 1) {
            throw "Scenario '$Scenario' exact restore did not report restored modules/functions."
        }
        if (-not [string]::IsNullOrWhiteSpace(
                $ExpectedPersistedGenerationId)) {
            if ($restoreEvent.PSObject.Properties.Name -notcontains
                'expectedCoordinate' -or
                [string]$restoreEvent.expectedCoordinate -ne
                    $ExpectedPersistedGenerationId.ToLowerInvariant()) {
                throw "Scenario '$Scenario' StartupRestore event did not identify the expected Generation."
            }
        }
    }
    return $Report
}

Export-ModuleMember -Function @(
    'New-AngelscriptPackageRunnerArguments',
    'Reset-AngelscriptCacheSmokeEvidence',
    'Resolve-AngelscriptPackagedExecutable',
    'Resolve-AngelscriptPackagedScriptRoot',
    'Assert-AngelscriptLoosePackageLayout',
    'New-AngelscriptCacheSmokeFixture',
    'Set-AngelscriptCacheSmokeFixtureScenario',
    'Resolve-AngelscriptCachePackageLaunchTimeoutMs',
    'Invoke-AngelscriptPackagedCacheLaunch',
    'Invoke-AngelscriptCacheV2Dump',
    'Read-AngelscriptCacheReport',
    'Assert-AngelscriptCacheScenarioReport'
)
