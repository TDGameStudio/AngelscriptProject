# Purpose: build the old/new identity map and a discovery before-report from a
# UE log Found-list plus current TEST_CLASS source. Does not launch Unreal.

[CmdletBinding()]
param(
    [string] $WorkspaceRoot = (Get-Location).Path,
    [Parameter(Mandatory = $true)][string] $UnrealLog,
    [string] $BeforeReportPath,
    [string] $MapPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BeforeReportPath) {
    $BeforeReportPath = Join-Path $WorkspaceRoot 'openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/pre-move-identities.json'
}
if (-not $MapPath) {
    $MapPath = Join-Path $WorkspaceRoot 'openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments/data/migration-identity-map.json'
}

$allowed = @(
    'Basic', 'Lexer', 'Parser', 'AST', 'Sema', 'Compile', 'SourceExecution',
    'Diagnostics', 'Tooling', 'Definitions', 'Identity', 'TypeOwnership',
    'Registration', 'VM'
)

function Get-LayerFromOldPath {
    param([string] $Path)
    $p = $Path.Replace('\', '/')
    if ($p -match 'LanguageSurface/(SyntaxTests|LambdaTests)') { return 'Sema' }
    if ($p -match 'LanguageSurface/') { return 'Compile' }
    if ($p -match '/Preprocessor/') { return 'Lexer' }
    if ($p -match '/Declarations/|/Bodies/') { return 'Sema' }
    if ($p -match '/Builder/|/ModuleGraph/|/Reflection/|/Api/|CompileLifecycleTests') { return 'Compile' }
    if ($p -match '/Compiler/') { return 'SourceExecution' }
    if ($p -match '/AST/') { return 'AST' }
    if ($p -match '/Diagnostics/|SourceDiagnosticsTests') { return 'Diagnostics' }
    if ($p -match '/Tooling/') { return 'Tooling' }
    if ($p -match '/Definitions/') { return 'Definitions' }
    if ($p -match '/Identity/') { return 'Identity' }
    if ($p -match '/TypeOwnership/') { return 'TypeOwnership' }
    if ($p -match '/Registration/') { return 'Registration' }
    if ($p -match '/VM/') { return 'VM' }
    if ($p -match 'NativeEngineTestFoundationTests|SourceInputTests') { return 'Basic' }
    if ($p -match '/Lexer/') { return 'Lexer' }
    return $null
}

$classToLayer = @{}
$classToFile = @{}
$nativeRoot = Join-Path $WorkspaceRoot 'Plugins/Angelscript/Source/AngelscriptTest'
$scanRoots = @(
    (Join-Path $nativeRoot 'NewVersion/NativeEngine'),
    (Join-Path $nativeRoot 'NativeEngine')
)
foreach ($root in $scanRoots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.cpp' | ForEach-Object {
        $file = $_
        $layer = Get-LayerFromOldPath $file.FullName
        if (-not $layer) { return }
        $text = [System.IO.File]::ReadAllText($file.FullName)
        [regex]::Matches($text, 'TEST_CLASS_WITH_FLAGS\(\s*([A-Za-z0-9_]+)') | ForEach-Object {
            $classToLayer[$_.Groups[1].Value] = $layer
            $classToFile[$_.Groups[1].Value] = $file.FullName
        }
    }
}

$lines = Get-Content -LiteralPath $UnrealLog
$found = [System.Collections.Generic.List[string]]::new()
$inList = $false
foreach ($line in $lines) {
    if ($line -match 'Found (\d+) automation tests based on') {
        $inList = $true
        continue
    }
    if ($inList) {
        if ($line -match 'LogAutomationCommandLine: Display:\s+(Angelscript\.UnitTest\.\S+)') {
            $found.Add($Matches[1])
        }
        elseif ($found.Count -gt 0 -and $line -notmatch 'LogAutomationCommandLine: Display:\s+Angelscript\.UnitTest') {
            break
        }
    }
}
if ($found.Count -eq 0) { throw "No discovered Angelscript.UnitTest identities in $UnrealLog" }

$stateByPath = @{}
foreach ($line in $lines) {
    if ($line -match 'Test Completed\. Result=\{([^}]+)\} .+ Path=\{(Angelscript\.UnitTest\.[^}]+)\}') {
        $stateByPath[$Matches[2]] = if ($Matches[1] -ceq 'Success') { 'Success' } else { 'Fail' }
    }
}

$tests = foreach ($id in $found) {
    $state = if ($stateByPath.ContainsKey($id)) { $stateByPath[$id] } else { 'NotRun' }
    [ordered]@{
        testDisplayName = ($id.Split('.')[-1])
        fullTestPath    = $id
        state           = $state
        warnings        = 0
        errors          = 0
    }
}
$success = @($tests | Where-Object { $_.state -ceq 'Success' }).Count
$failed = @($tests | Where-Object { $_.state -ceq 'Fail' }).Count
$notRun = @($tests | Where-Object { $_.state -ceq 'NotRun' }).Count
$beforeDoc = [ordered]@{
    reportCreatedOn       = '2026.09.15-05.18.20'
    source                = $UnrealLog
    note                  = 'Discovery list from the pre-move Automation log. The run crashed in Bindings before index.json export.'
    succeeded             = $success
    succeededWithWarnings = 0
    failed                = $failed
    notRun                = $notRun
    inProcess             = 0
    tests                 = @($tests)
}
$beforeDoc | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $BeforeReportPath -Encoding UTF8

function Convert-Identity {
    param([string] $Old)
    $parts = $Old.Split('.')
    if ($parts.Length -lt 4 -or $parts[0] -cne 'Angelscript' -or $parts[1] -cne 'UnitTest') {
        return [pscustomobject]@{ New = $Old; Disposition = 'identity-preserving'; Layer = $null; Tenant = 'Unknown' }
    }
    $area = $parts[2]
    if ($area -cne 'NativeEngine') {
        $tenant = if ($area -ceq 'RuntimeBindings' -or $area -ceq 'Bindings') { $area } else { $area }
        return [pscustomobject]@{ New = $Old; Disposition = 'identity-preserving'; Layer = $null; Tenant = $tenant }
    }
    if ($parts[3] -ceq 'LanguageSurface') {
        $class = $parts[4]
        $layer = $classToLayer[$class]
        if (-not $layer) { throw "No layer for LanguageSurface class $class" }
        $tail = ($parts[4..($parts.Length - 1)] -join '.')
        return [pscustomobject]@{
            New         = "Angelscript.UnitTest.NativeEngine.$layer.$tail"
            Disposition = 'one-to-one'
            Layer       = $layer
            Tenant      = 'NativeEngine'
        }
    }
    if ($allowed -contains $parts[3]) {
        return [pscustomobject]@{ New = $Old; Disposition = 'one-to-one'; Layer = $parts[3]; Tenant = 'NativeEngine' }
    }
    $class = $parts[3]
    $tail = ($parts[4..($parts.Length - 1)] -join '.')
    if ($class -ceq 'Builder') {
        return [pscustomobject]@{
            New         = "Angelscript.UnitTest.NativeEngine.Compile.BuilderStages.$tail"
            Disposition = 'collision-rename'
            Layer       = 'Compile'
            Tenant      = 'NativeEngine'
        }
    }
    $layer = $classToLayer[$class]
    if (-not $layer) { throw "No layer for NativeEngine class $class ($Old)" }
    return [pscustomobject]@{
        New         = "Angelscript.UnitTest.NativeEngine.$layer.$class.$tail"
        Disposition = 'one-to-one'
        Layer       = $layer
        Tenant      = 'NativeEngine'
    }
}

$tenantMaps = @{
    NativeEngine    = [System.Collections.Generic.List[object]]::new()
    Framework       = [System.Collections.Generic.List[object]]::new()
    RuntimeBindings = [System.Collections.Generic.List[object]]::new()
    Bindings        = [System.Collections.Generic.List[object]]::new()
    Baseline        = [System.Collections.Generic.List[object]]::new()
}

foreach ($id in $found) {
    $mapped = Convert-Identity $id
    $entry = [ordered]@{
        old         = $id
        new         = $mapped.New
        disposition = $mapped.Disposition
    }
    if ($mapped.Layer) { $entry.layer = $mapped.Layer }
    if (-not $tenantMaps.ContainsKey($mapped.Tenant)) {
        throw "Unassigned tenant for $id"
    }
    $tenantMaps[$mapped.Tenant].Add($entry)
}

$builderMethods = @(
    'DirectSessionRecoveryCannotPublishAfterDeclarationFailure',
    'ExplicitGlobalBaseNameDoesNotBindANamespacedShadow',
    'ClassDefaultStatementsShareOneActualLexicalBodyScope',
    'MaintainedSuffixFactsSurviveActualFunctionMaterialization',
    'RecordInheritanceAndOverrideRulesFailAtDeclarationResolution',
    'ExactBaseOverrideAndDistinctOverloadsProduceRealDefinitions',
    'NamedFunctionRetainsItsImageAndNamespaceAfterBuilderRelease',
    'ParallelNamedBodiesKeepTheSameActualFunctionKeysAndObservations',
    'AutoGlobalsInferOnceThroughForwardInitializerDependencies',
    'AutoInferenceCyclesAndMissingInitializersFailWithoutDefinitions',
    'FunctionDefinitionModifiersReachActualTraitsAndFrozenAuthentication',
    'EnumExplicitFloatConversionRetainsTypedConstantSemantics',
    'ParsedClassDefaultsProduceOneImplicitActualFunctionInSourceOrder',
    'GlobalInitializerAndDefaultArgumentsAreAnalyzedBeforeBodies',
    'InvalidDefaultInitializerCannotPublishDefinitions',
    'TypedefKeepsItsEntityIdentityButCanonicalizesFunctionTypeUses',
    'CyclicAliasesFailBeforeBodyAnalysis',
    'AuthoredAccessPoliciesReachFrozenDefinitionsAndOutliveTheBuilder',
    'InvalidAccessPolicyDoesNotPublishDefinitions',
    'MemberAccessAndConstructionReachActualDefinitionObjects',
    'IndependentStagesPublishActualDefinitionsOnlyAfterExplicitFreeze',
    'FullAndSplitRunsProduceIdenticalStageObservations',
    'EqualFunctionSignaturesShareTheCanonicalTypeButNotFunctionDefinitions',
    'IllegalOrderDoesNotConsumeOrPoisonTheCurrentStage',
    'PreprocessorSelectionIsRetainedAndDoesNotConstructDeclarations',
    'RecoveryStopsDefinitionPublicationAndKeepsFailureObservation',
    'ForwardDefaultDependenciesAreIndependentOfDeclarationOrder',
    'CyclicDefaultDependenciesCannotPublishDefinitions',
    'EnumExpressionsResolveBeforeHostDeclarationOutput',
    'EnumForwardAndGlobalConstantDependenciesUseOriginalTypedExpressions',
    'EnumShortCircuitDoesNotEvaluateUnselectedConstantFailure',
    'InvalidEnumConstantsFailBeforeDefinitionPublication',
    'InvalidOptionsRejectBeforeLexing',
    'EmptyTranslationUnitHasAValidVerifiedSourceAnchor',
    'ForeignDiagnosticSnapshotRejectsTheBuilderInput',
    'BodyLookupUsesItsNamespaceBeforeUnrelatedSameNameDeclarations',
    'UnrelatedNamespaceDeclarationsAreNotImplicitlyVisible',
    'UnknownConditionalFlagStopsBeforeDeclarationCollection',
    'ManyParallelBodiesRetainTheSerialCanonicalProjection',
    'FrozenImageOutlivesTheBuilderAndRetainsIdentityContext',
    'DefinitionDumpDistinguishesSameSizeFieldsWithDifferentTypes',
    'LayoutFailureRetainsExactReasonAndDoesNotFreezeTheDraft'
)
foreach ($method in $builderMethods) {
    $tenantMaps.NativeEngine.Add([ordered]@{
            old         = "Angelscript.UnitTest.NativeEngine.Builder.$method"
            new         = "Angelscript.UnitTest.NativeEngine.Compile.BuilderStages.$method"
            disposition = 'collision-rename'
            layer       = 'Compile'
        })
}

$map = [ordered]@{
    schemaVersion              = 1
    description                = 'Old-to-new Automation identity map from the 2026-09-15 pre-move discovery list.'
    beforeReport               = $BeforeReportPath
    allowedNativeEngineLayers  = $allowed
    tenants                    = [ordered]@{
        NativeEngine    = [ordered]@{
            oldPrefix            = 'Angelscript.UnitTest.NativeEngine'
            newPrefix            = 'Angelscript.UnitTest.NativeEngine'
            identityPreserving   = $false
            expectedEmptyLayers  = @('Parser')
            mappings             = @($tenantMaps.NativeEngine)
        }
        Framework       = [ordered]@{
            oldPrefix            = 'Angelscript.UnitTest.Framework'
            newPrefix            = 'Angelscript.UnitTest.Framework'
            identityPreserving   = $true
            expectedEmptyLayers  = @()
            mappings             = @($tenantMaps.Framework)
        }
        RuntimeBindings = [ordered]@{
            oldPrefix            = 'Angelscript.UnitTest.RuntimeBindings'
            newPrefix            = 'Angelscript.UnitTest.RuntimeBindings'
            identityPreserving   = $true
            expectedEmptyLayers  = @()
            mappings             = @($tenantMaps.RuntimeBindings)
        }
        Bindings        = [ordered]@{
            oldPrefix            = 'Angelscript.UnitTest.Bindings'
            newPrefix            = 'Angelscript.UnitTest.Bindings'
            identityPreserving   = $true
            expectedEmptyLayers  = @()
            mappings             = @($tenantMaps.Bindings)
        }
        Baseline        = [ordered]@{
            oldPrefix            = 'Angelscript.UnitTest.Baseline'
            newPrefix            = 'Angelscript.UnitTest.Baseline'
            identityPreserving   = $true
            expectedEmptyLayers  = @()
            mappings             = @($tenantMaps.Baseline)
        }
    }
}
$map | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $MapPath -Encoding UTF8
Write-Output "Wrote $($found.Count) discovered identities and map to $MapPath"
