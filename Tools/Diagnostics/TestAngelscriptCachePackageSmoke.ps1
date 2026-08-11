[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Assert-Throws {
    param([scriptblock]$Body, [string]$Message)
    try {
        & $Body
    }
    catch {
        return
    }
    throw $Message
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $projectRoot 'Tools\Shared\AngelscriptCachePackageSmoke.psm1'
if (Test-Path -LiteralPath $modulePath -PathType Leaf) {
    Import-Module $modulePath -Force
}

$argumentFixture = @{
    ProjectFile = 'D:\Fixture\Fixture.uproject'
    Platform = 'Win64'
    Configuration = 'Development'
    ArchiveDir = 'D:\Fixture\Archive'
    Map = '/Game/Test/ActorTestMap'
}
$defaultPackageArguments = @(
    New-AngelscriptPackageRunnerArguments @argumentFixture)
Assert-True (-not ($defaultPackageArguments -contains '-noxge')) `
    'Default package arguments must not silently disable the selected UAT build executor.'
Assert-True (-not (@($defaultPackageArguments | Where-Object {
                $_ -like '-AdditionalCookerOptions=*noxgeshadercompile*'
            }).Count -gt 0)) `
    'Default package arguments must not silently disable distributed shader compilation.'

$localPackageArguments = @(
    New-AngelscriptPackageRunnerArguments `
        @argumentFixture `
        -NoXGE `
        -ExtraArgs @('-prereqs'))
Assert-Equal 1 @($localPackageArguments | Where-Object {
        $_ -eq '-noxge'
    }).Count 'NoXGE package mode must pass exactly one UAT build-executor flag.'
Assert-Equal 1 @($localPackageArguments | Where-Object {
        $_ -eq '-AdditionalCookerOptions=-noxgeshadercompile'
    }).Count 'NoXGE package mode must disable XGE inside the Cook commandlet.'
Assert-True ($localPackageArguments -contains '-prereqs') `
    'NoXGE package argument construction must preserve caller ExtraArgs.'

$packageRunnerSource = Get-Content `
    -LiteralPath (Join-Path $projectRoot 'Tools\RunPackage.ps1') `
    -Raw
Assert-True ($packageRunnerSource -match
        '\bNew-AngelscriptPackageRunnerArguments\b') `
    'The production package wrapper must delegate to the tested argument constructor.'

Assert-Equal 300000 `
    (Resolve-AngelscriptCachePackageLaunchTimeoutMs -RemainingTimeoutMs 3400000) `
    'One packaged launch must retain headroom inside the outer smoke deadline.'
Assert-Equal 90000 `
    (Resolve-AngelscriptCachePackageLaunchTimeoutMs -RemainingTimeoutMs 120000) `
    'A smaller remaining deadline must still reserve the cleanup budget.'
Assert-Throws -Body {
    Resolve-AngelscriptCachePackageLaunchTimeoutMs -RemainingTimeoutMs 0
} -Message 'A nonpositive remaining launch deadline must fail.'
Assert-Throws -Body {
    Resolve-AngelscriptCachePackageLaunchTimeoutMs -RemainingTimeoutMs 30000
} -Message 'A launch must fail early when no cleanup headroom remains.'

$smokeRunnerSource = Get-Content `
    -LiteralPath (Join-Path $projectRoot 'Tools\RunAngelscriptCachePackageSmoke.ps1') `
    -Raw
Assert-True ($smokeRunnerSource -match
        '\bResolve-AngelscriptCachePackageLaunchTimeoutMs\b') `
    'The production smoke loop must reserve outer-deadline cleanup headroom per launch.'

$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    'as-cache-package-smoke-selftest-' + [guid]::NewGuid().ToString('N'))
try {
    # Match the maintained runner's real layout: the disposable archive itself
    # lives below the worktree Saved directory, while only Saved directories
    # *inside* that archive are excluded from package discovery.
    $archiveRoot = Join-Path $testRoot 'Saved\CachePackage\Run\Archive'
    $platformRoot = Join-Path $archiveRoot 'Windows'
    $packageRoot = Join-Path $platformRoot 'AngelscriptProject'
    $binaryRoot = Join-Path $packageRoot 'Binaries\Win64'
    $scriptRoot = Join-Path $packageRoot 'Script'
    $gameRoot = Join-Path $scriptRoot 'Game'
    New-Item -ItemType Directory -Path $binaryRoot, $gameRoot -Force | Out-Null
    $launcherPath = Join-Path $platformRoot 'AngelscriptProject.exe'
    [System.IO.File]::WriteAllBytes($launcherPath, [byte[]]@(77, 90))
    [System.IO.File]::WriteAllBytes(
        (Join-Path $binaryRoot 'AngelscriptProject.exe'),
        [byte[]]@(77, 90))
    [System.IO.File]::WriteAllBytes(
        (Join-Path $scriptRoot 'Binds.Cache'),
        [byte[]]@(1, 2, 3, 4))
    [System.IO.File]::WriteAllText(
        (Join-Path $gameRoot 'Existing.as'),
        "int Existing() { return 1; }`n")

    $executable = Resolve-AngelscriptPackagedExecutable `
        -ArchiveRoot $archiveRoot `
        -ProjectName 'AngelscriptProject' `
        -Configuration 'Development'
    Assert-Equal `
        $launcherPath `
        $executable `
        'Executable discovery should resolve the canonical archive launcher, not its nested binary.'

    $resolvedScriptRoot = Resolve-AngelscriptPackagedScriptRoot `
        -ArchiveRoot $archiveRoot
    Assert-Equal $scriptRoot $resolvedScriptRoot `
        'Loose Script discovery should return the unique staged source root.'
    $layout = Assert-AngelscriptLoosePackageLayout `
        -ArchiveRoot $archiveRoot `
        -ProjectName 'AngelscriptProject' `
        -Configuration 'Development'
    Assert-Equal $scriptRoot $layout.ScriptRoot `
        'Validated layout should retain its loose Script coordinate.'
    Assert-Equal $executable $layout.Executable `
        'Validated layout should retain its executable coordinate.'

    $secondExecutable = Join-Path $platformRoot `
        'AngelscriptProject-Win64-Development.exe'
    [System.IO.File]::WriteAllBytes($secondExecutable, [byte[]]@(77, 90))
    Assert-Throws -Body {
        Resolve-AngelscriptPackagedExecutable `
            -ArchiveRoot $archiveRoot `
            -ProjectName 'AngelscriptProject' `
            -Configuration 'Development'
    } -Message 'Ambiguous packaged executable discovery must fail.'
    Remove-Item -LiteralPath $secondExecutable -Force

    $bindsPath = Join-Path $scriptRoot 'Binds.Cache'
    Move-Item -LiteralPath $bindsPath -Destination "$bindsPath.hidden"
    Assert-Throws -Body {
        Assert-AngelscriptLoosePackageLayout `
            -ArchiveRoot $archiveRoot `
            -ProjectName 'AngelscriptProject' `
            -Configuration 'Development'
    } -Message 'A loose package without Binds.Cache must fail.'
    Move-Item -LiteralPath "$bindsPath.hidden" -Destination $bindsPath

    $legacyPath = Join-Path $scriptRoot 'PrecompiledScript.Cache'
    [System.IO.File]::WriteAllBytes($legacyPath, [byte[]]@(9, 9, 9))
    Assert-Throws -Body {
        Assert-AngelscriptLoosePackageLayout `
            -ArchiveRoot $archiveRoot `
            -ProjectName 'AngelscriptProject' `
            -Configuration 'Development'
    } -Message 'A staged legacy PrecompiledScript.Cache must fail.'
    Remove-Item -LiteralPath $legacyPath -Force

    $packagedCacheRoot = Join-Path $scriptRoot 'AngelscriptCache\fixture'
    New-Item -ItemType Directory -Path $packagedCacheRoot -Force | Out-Null
    Assert-Throws -Body {
        Assert-AngelscriptLoosePackageLayout `
            -ArchiveRoot $archiveRoot `
            -ProjectName 'AngelscriptProject' `
            -Configuration 'Development'
    } -Message 'A staged Cache V2 baseline under Script must fail.'
    Remove-Item -LiteralPath (Join-Path $scriptRoot 'AngelscriptCache') -Recurse -Force

    $scriptHoldingRoot = Join-Path $testRoot 'script-holding'
    Move-Item -LiteralPath $scriptRoot -Destination $scriptHoldingRoot
    $simulatedPakRoot = Join-Path $packageRoot 'Content\Paks\SimulatedUFS\Script'
    New-Item -ItemType Directory -Path $simulatedPakRoot -Force | Out-Null
    [System.IO.File]::WriteAllText(
        (Join-Path $simulatedPakRoot 'OnlyInPak.as'),
        "int OnlyInPak() { return 1; }`n")
    Assert-Throws -Body {
        Assert-AngelscriptLoosePackageLayout `
            -ArchiveRoot $archiveRoot `
            -ProjectName 'AngelscriptProject' `
            -Configuration 'Development'
    } -Message 'Script found only under simulated Pak/UFS storage must fail.'
    Remove-Item -LiteralPath (Join-Path $packageRoot 'Content') -Recurse -Force
    Move-Item -LiteralPath $scriptHoldingRoot -Destination $scriptRoot

    $fixture = New-AngelscriptCacheSmokeFixture `
        -ArchiveRoot $archiveRoot `
        -ScriptRoot $scriptRoot
    Assert-True (Test-Path -LiteralPath $fixture.SourcePath -PathType Leaf) `
        'The disposable package fixture source should be created.'
    Assert-True ($fixture.SourcePath.StartsWith($archiveRoot,
            [System.StringComparison]::OrdinalIgnoreCase)) `
        'The package fixture must remain inside the disposable archive.'
    $baseline = Get-Content -LiteralPath $fixture.SourcePath -Raw
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario 'BodyEdit')
    $bodyEdit = Get-Content -LiteralPath $fixture.SourcePath -Raw
    Assert-True ($baseline -ne $bodyEdit) 'Body edit should change fixture bytes.'
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario 'InvalidSource')
    Assert-True ((Get-Content -LiteralPath $fixture.SourcePath -Raw) -match 'INVALID') `
        'Invalid-source scenario should be visibly diagnosable.'
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario 'Baseline')
    Assert-Equal $baseline (Get-Content -LiteralPath $fixture.SourcePath -Raw) `
        'Restoring Baseline should restore byte-identical source.'
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario 'StructuralEdit')
    Assert-True ((Get-Content -LiteralPath $fixture.SourcePath -Raw) -match 'StructuralValue') `
        'Structural scenario should change the declared type surface.'
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario 'TypeSchemaEdit')
    Assert-True ((Get-Content -LiteralPath $fixture.SourcePath -Raw) -match 'ExtraValue') `
        'Type-schema scenario should change a reflected script type layout.'
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario 'ModuleStateEdit')
    Assert-True ((Get-Content -LiteralPath $fixture.SourcePath -Raw) -match 'CachePackageSmokeGlobal = 20') `
        'Module-state scenario should change global state without changing the type layout.'

    $evidenceRoot = Join-Path $packageRoot 'Saved\CachePackageSmoke'
    $evidenceMarker = Join-Path $evidenceRoot 'CacheV2\stale.marker'
    $preservedMarker = Join-Path $packageRoot 'Saved\Preserved\keep.marker'
    New-Item -ItemType Directory `
        -Path (Split-Path -Parent $evidenceMarker), `
            (Split-Path -Parent $preservedMarker) `
        -Force | Out-Null
    [System.IO.File]::WriteAllText($evidenceMarker, 'stale')
    [System.IO.File]::WriteAllText($preservedMarker, 'keep')
    [void](Reset-AngelscriptCacheSmokeEvidence `
            -ArchiveRoot $archiveRoot `
            -EvidenceRoot $evidenceRoot)
    Assert-True (-not (Test-Path -LiteralPath $evidenceRoot)) `
        'A reused package must discard the previous smoke Cache, reports, logs, and dumps.'
    Assert-True (Test-Path -LiteralPath $preservedMarker -PathType Leaf) `
        'Evidence reset must not remove sibling Saved content.'
    [void](Reset-AngelscriptCacheSmokeEvidence `
            -ArchiveRoot $archiveRoot `
            -EvidenceRoot $evidenceRoot)
    Assert-Throws -Body {
        Reset-AngelscriptCacheSmokeEvidence `
            -ArchiveRoot $archiveRoot `
            -EvidenceRoot $archiveRoot
    } -Message 'Evidence reset must reject the archive root itself.'
    Assert-Throws -Body {
        Reset-AngelscriptCacheSmokeEvidence `
            -ArchiveRoot $archiveRoot `
            -EvidenceRoot (Join-Path $testRoot 'CachePackageSmoke')
    } -Message 'Evidence reset must reject paths outside the disposable archive.'

    $reportPath = Join-Path $testRoot 'session.json'
    [System.IO.File]::WriteAllText(
        $reportPath,
        ([ordered]@{
                schemaVersion = 2
                mutationPhase = 2
                mutationPhaseName = 'ShuttingDown'
                lastTransactionOrdinal = '2'
                current = [ordered]@{
                    present = $true
                    publicationSchemaVersion = 2
                    transactionOrdinal = '2'
                    sourceSnapshot = ('a' * 64)
                    restoredFromStore = $true
                    persistedGenerationId = ('b' * 64)
                }
                pendingColdStart = [ordered]@{ present = $false }
                latestSuccessful = [ordered]@{ present = $true }
                decisionTrace = [ordered]@{
                    schemaVersion = 1
                    enabled = $true
                    events = @(
                        [ordered]@{
                            schemaVersion = 1
                            stage = 1
                            stageName = 'StartupSelection'
                            outcome = 6
                            outcomeName = 'Reused'
                            expectedCoordinate = ('b' * 64)
                            primaryCount = 0
                            secondaryCount = 0
                        },
                        [ordered]@{
                            schemaVersion = 1
                            stage = 2
                            stageName = 'StartupRestore'
                            outcome = 1
                            outcomeName = 'Restored'
                            expectedCoordinate = ('b' * 64)
                            primaryCount = 1
                            secondaryCount = 3
                        }
                    )
                }
            } | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    $report = Read-AngelscriptCacheReport -Path $reportPath
    Assert-Equal 2 $report.schemaVersion 'Report schema should be retained.'
    [void](Assert-AngelscriptCacheScenarioReport `
        -Scenario 'Warm' `
        -Report $report `
        -ExpectCurrent `
        -RequireRestoredFromStore `
        -ExpectedPersistedGenerationId ('b' * 64) `
        -RequireExactStartupTrace)

    Assert-Throws -Body {
        [void](Assert-AngelscriptCacheScenarioReport `
            -Scenario 'Warm' `
            -Report $report `
            -ExpectCurrent `
            -RequireRestoredFromStore `
            -ExpectedPersistedGenerationId ('c' * 64) `
            -RequireExactStartupTrace)
    } -Message 'A warm report with the wrong persisted generation must fail.'

    $report.current.restoredFromStore = $false
    Assert-Throws -Body {
        [void](Assert-AngelscriptCacheScenarioReport `
            -Scenario 'Warm' `
            -Report $report `
            -ExpectCurrent `
            -RequireRestoredFromStore `
            -RequireExactStartupTrace)
    } -Message 'A warm report without restored provenance must fail.'
    $report.current.restoredFromStore = $true

    # The reader deliberately remains compatible with older diagnostic captures;
    # V7.6 scenario assertions themselves require schema-2 provenance.
    [System.IO.File]::WriteAllText(
        $reportPath,
        ([ordered]@{
                schemaVersion = 1
                mutationPhase = 2
                mutationPhaseName = 'ShuttingDown'
                lastTransactionOrdinal = '1'
                current = [ordered]@{ present = $false }
                pendingColdStart = [ordered]@{ present = $false }
                latestSuccessful = [ordered]@{ present = $false }
                decisionTrace = [ordered]@{
                    schemaVersion = 1
                    enabled = $false
                    events = @()
                }
            } | ConvertTo-Json -Depth 6 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    $legacyReport = Read-AngelscriptCacheReport -Path $reportPath
    Assert-Equal 1 $legacyReport.schemaVersion 'Schema-1 reports should remain readable.'

    # Diagnostic schema 3 adds the stable FunctionKey route snapshot consumed
    # by the Python dump correlation.  The package-smoke reader must accept the
    # Runtime's current schema while retaining the older saved-report readers.
    $schema3Document = $report | ConvertTo-Json -Depth 8 | ConvertFrom-Json
    $schema3Document.schemaVersion = 3
    $schema3Document | Add-Member `
        -NotePropertyName functionRoutes `
        -NotePropertyValue ([PSCustomObject]@{ present = $false })
    [System.IO.File]::WriteAllText(
        $reportPath,
        ($schema3Document | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    $schema3Report = Read-AngelscriptCacheReport -Path $reportPath
    Assert-Equal 3 $schema3Report.schemaVersion `
        'The current Runtime diagnostic schema should be readable.'

    # Schema 4 carries the aggregate hybrid function-reuse proof even when the
    # bounded decision journal is disabled or has evicted older events.
    $schema4Document = $schema3Report | ConvertTo-Json -Depth 8 | ConvertFrom-Json
    $schema4Document.schemaVersion = 4
    $schema4Document.current.restoredFromStore = $false
    $schema4Document | Add-Member `
        -NotePropertyName functionReuse `
        -NotePropertyValue ([PSCustomObject]@{
            schemaVersion = 1
            present = $true
            candidateGenerationId = ('b' * 64)
            candidateModuleCount = 2
            restoredFunctionCount = 7
            compiledMissCount = 3
            notCacheableCount = 1
            rejectedCorruptCount = 0
        })
    $schema4Document.decisionTrace.events += [PSCustomObject]@{
        schemaVersion = 2
        stage = 3
        stageName = 'FunctionLookup'
        outcome = 1
        outcomeName = 'Restored'
        reasonDomainName = 'FunctionLookup'
        moduleKeys = @(('d' * 64))
        functionKey = ('e' * 64)
        expectedCoordinate = ('b' * 64)
        primaryCount = 0
        secondaryCount = 0
    }
    $schema4Document.decisionTrace.events += [PSCustomObject]@{
        schemaVersion = 2
        stage = 3
        stageName = 'FunctionLookup'
        outcome = 5
        outcomeName = 'Compiled'
        reasonDomainName = 'FunctionLookup'
        moduleKeys = @(('d' * 64))
        functionKey = ('f' * 64)
        expectedCoordinate = ('b' * 64)
        primaryCount = 1
        secondaryCount = 0
    }
    [System.IO.File]::WriteAllText(
        $reportPath,
        ($schema4Document | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    $schema4Report = Read-AngelscriptCacheReport -Path $reportPath
    Assert-Equal 4 $schema4Report.schemaVersion `
        'The function-reuse diagnostic schema should be readable.'
    [void](Assert-AngelscriptCacheScenarioReport `
        -Scenario 'Warm' `
        -Report $schema4Report `
        -ExpectCurrent `
        -RequireWarmCacheReuse `
        -ExpectedPersistedGenerationId ('a' * 64) `
        -ExpectedHybridCandidateGenerationId ('b' * 64))
    Assert-Throws -Body {
        [void](Assert-AngelscriptCacheScenarioReport `
            -Scenario 'Warm' `
            -Report $schema4Report `
            -ExpectCurrent `
            -RequireWarmCacheReuse `
            -ExpectedPersistedGenerationId ('a' * 64) `
            -ExpectedHybridCandidateGenerationId ('c' * 64))
    } -Message 'Hybrid reuse must validate its candidate independently from the final persisted Generation.'

    $schema4ExactReport = $schema4Report | ConvertTo-Json -Depth 8 |
        ConvertFrom-Json
    $schema4ExactReport.current.restoredFromStore = $true
    $schema4ExactReport.functionReuse.present = $false
    [void](Assert-AngelscriptCacheScenarioReport `
        -Scenario 'Warm' `
        -Report $schema4ExactReport `
        -ExpectCurrent `
        -RequireWarmCacheReuse `
        -ExpectedPersistedGenerationId ('b' * 64))

    $schema4Document.functionReuse.restoredFunctionCount = 0
    [System.IO.File]::WriteAllText(
        $reportPath,
        ($schema4Document | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    $plainFallbackReport = Read-AngelscriptCacheReport -Path $reportPath
    Assert-Throws -Body {
        [void](Assert-AngelscriptCacheScenarioReport `
            -Scenario 'Warm' `
            -Report $plainFallbackReport `
            -ExpectCurrent `
            -RequireWarmCacheReuse `
            -ExpectedHybridCandidateGenerationId ('b' * 64))
    } -Message 'A plain fallback compile must not satisfy the warm Cache oracle.'

    $missingCaptureDetailDocument = $schema4Report | ConvertTo-Json -Depth 8 |
        ConvertFrom-Json
    $missingCaptureDetailDocument.decisionTrace.events += [PSCustomObject]@{
        schemaVersion = 2
        stage = 5
        stageName = 'SuccessfulPublication'
        outcome = 4
        outcomeName = 'NotCacheable'
        reasonDomainName = 'CleanCapture'
        reasonCode = 1
        moduleKeys = @(('a' * 64))
    }
    [System.IO.File]::WriteAllText(
        $reportPath,
        ($missingCaptureDetailDocument | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    Assert-Throws -Body {
        Read-AngelscriptCacheReport -Path $reportPath
    } -Message 'A schema-4 CleanCapture failure without detail must fail validation.'

    $schema4Document.PSObject.Properties.Remove('functionReuse')
    [System.IO.File]::WriteAllText(
        $reportPath,
        ($schema4Document | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    Assert-Throws -Body {
        Read-AngelscriptCacheReport -Path $reportPath
    } -Message 'A schema-4 report without functionReuse must fail validation.'

    $schema3Document.PSObject.Properties.Remove('functionRoutes')
    [System.IO.File]::WriteAllText(
        $reportPath,
        ($schema3Document | ConvertTo-Json -Depth 8 -Compress),
        (New-Object System.Text.UTF8Encoding($false)))
    Assert-Throws -Body {
        Read-AngelscriptCacheReport -Path $reportPath
    } -Message 'A schema-3 report without functionRoutes must fail validation.'

    [System.IO.File]::WriteAllText(
        $reportPath,
        '{"schemaVersion":2,"current":{"present":true}}',
        (New-Object System.Text.UTF8Encoding($false)))
    Assert-Throws -Body {
        Read-AngelscriptCacheReport -Path $reportPath
    } -Message 'An incomplete process report must fail schema validation.'

    $cacheRoot = Join-Path $packageRoot 'Saved\CacheSmoke\CacheV2'
    $launchReport = Join-Path $packageRoot 'Saved\CacheSmoke\Reports\launch.json'
    $launchLog = Join-Path $packageRoot 'Saved\CacheSmoke\Logs\launch.log'
    $script:ObservedLaunch = $null
    $processDouble = {
        param($Executable, $Arguments, $WorkingDirectory, $TimeoutMs, $LogPath)
        $script:ObservedLaunch = [PSCustomObject]@{
            Executable = $Executable
            Arguments = @($Arguments)
            WorkingDirectory = $WorkingDirectory
            TimeoutMs = $TimeoutMs
            LogPath = $LogPath
        }
        return [PSCustomObject]@{
            ExitCode = 0
            TimedOut = $false
            DurationMs = 12
            LogPath = $LogPath
        }
    }
    $launch = Invoke-AngelscriptPackagedCacheLaunch `
        -ArchiveRoot $archiveRoot `
        -Executable $executable `
        -CacheRoot $cacheRoot `
        -ReportPath $launchReport `
        -LogPath $launchLog `
        -TimeoutMs 1000 `
        -ProcessInvoker $processDouble
    Assert-Equal 0 $launch.ExitCode 'Process-double launch should succeed.'
    Assert-True (@($script:ObservedLaunch.Arguments) -contains (
            "-as-cache-root=$cacheRoot")) `
        'Launch must pass the isolated Cache V2 root.'
    Assert-True (@($script:ObservedLaunch.Arguments) -contains (
            "-as-cache-report=$launchReport")) `
        'Launch must request the C++ process session report.'
    Assert-True (@($script:ObservedLaunch.Arguments) -contains '-as-cache-trace') `
        'Launch must enable bounded Cache decision tracing before Engine startup.'
    Assert-True (@($script:ObservedLaunch.Arguments) -contains `
            '-as-cache-exit-after-startup') `
        'Launch must use the Shipping-safe Cache startup-exit lifecycle instead of console commands.'
    Assert-True (-not (@($script:ObservedLaunch.Arguments) -contains `
                '-ExecCmds=as.Cache.Flush,quit')) `
        'Launch must not depend on ExecCmds, which is unavailable in Shipping.'
    Assert-True (@($script:ObservedLaunch.Arguments) -contains `
            '-LogCmds=Angelscript Verbose') `
        'Launch must retain detailed Cache capture rejection reasons in the isolated package-smoke log.'

    [void](Invoke-AngelscriptPackagedCacheLaunch `
        -ArchiveRoot $archiveRoot `
        -Executable $executable `
        -CacheRoot $cacheRoot `
        -ReportPath $launchReport `
        -LogPath $launchLog `
        -DiagnosticsMode Summary `
        -ExtraArguments @('-as-cache-pack-target-mib=16', '-as-cache-preparation-workers=2') `
        -TimeoutMs 1000 `
        -ProcessInvoker $processDouble)
    Assert-True (@($script:ObservedLaunch.Arguments) -contains (
            "-as-cache-report=$launchReport")) `
        'Summary diagnostics must retain the process report.'
    Assert-True (-not (@($script:ObservedLaunch.Arguments) -contains '-as-cache-trace')) `
        'Summary diagnostics must not pay bounded journal cost.'
    Assert-True (-not (@($script:ObservedLaunch.Arguments) -contains `
                '-LogCmds=Angelscript Verbose')) `
        'Summary diagnostics must not enable verbose logging.'
    Assert-True (@($script:ObservedLaunch.Arguments) -contains `
            '-as-cache-pack-target-mib=16') `
        'Benchmark writer-policy arguments must reach the packaged process.'

    [void](Invoke-AngelscriptPackagedCacheLaunch `
        -ArchiveRoot $archiveRoot `
        -Executable $executable `
        -CacheRoot $cacheRoot `
        -ReportPath $launchReport `
        -LogPath $launchLog `
        -DiagnosticsMode Disabled `
        -TimeoutMs 1000 `
        -ProcessInvoker $processDouble)
    Assert-True (-not (@($script:ObservedLaunch.Arguments) -contains (
                "-as-cache-report=$launchReport"))) `
        'Disabled diagnostics must omit report serialization.'
    Assert-True (-not (@($script:ObservedLaunch.Arguments) -contains '-as-cache-trace')) `
        'Disabled diagnostics must omit the decision journal.'

    $dumpOutput = Join-Path $packageRoot 'Saved\CacheSmoke\Reports\dump.json'
    $dumpTool = Join-Path $projectRoot `
        'Plugins\Angelscript\Tools\CacheV2Dump\cache_v2_dump.py'
    $script:ObservedDumpArguments = $null
    [System.IO.File]::WriteAllText(
        $launchReport,
        '{"schemaVersion":2}',
        (New-Object System.Text.UTF8Encoding($false)))
    $dumpProcessDouble = {
        param($Executable, $Arguments, $WorkingDirectory, $TimeoutMs, $OutputPath)
        $script:ObservedDumpArguments = @($Arguments)
        [System.IO.File]::WriteAllText(
            $OutputPath,
            '{"format":"AngelscriptCacheV2Dump","format_version":1,"ok":true,"namespaces":[]}',
            (New-Object System.Text.UTF8Encoding($false)))
        return [PSCustomObject]@{
            ExitCode = 0
            TimedOut = $false
            DurationMs = 3
        }
    }
    $dumpDocument = Invoke-AngelscriptCacheV2Dump `
        -ArchiveRoot $archiveRoot `
        -CacheRoot $cacheRoot `
        -ToolPath $dumpTool `
        -OutputPath $dumpOutput `
        -GenerationSelectors @('Current') `
        -SessionReport $launchReport `
        -TimeoutMs 1000 `
        -ProcessInvoker $dumpProcessDouble
    Assert-True ([bool]$dumpDocument.ok) 'Cache V2 dump helper should return parsed JSON.'
    Assert-True (@($script:ObservedDumpArguments) -contains '--generation') `
        'Cache V2 dump helper must pass the explicit generation selector.'
    Assert-True (@($script:ObservedDumpArguments) -contains '--session-report') `
        'Cache V2 dump helper must pass the C++ session report for correlation.'

    Assert-Throws -Body {
        New-AngelscriptCacheSmokeFixture `
            -ArchiveRoot $archiveRoot `
            -ScriptRoot (Join-Path $testRoot 'OutsideScript')
    } -Message 'Fixture writes outside the disposable archive must fail.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Host 'AngelScript Cache package-smoke helper self-tests passed.'
