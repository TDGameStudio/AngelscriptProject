Set-StrictMode -Version Latest

# Shared suite definitions for RunTestSuite.ps1 / RunTestSuiteParallel.ps1.
# Tier=Heavy: cold-start UE editor + full engine / large binding surface (run with low concurrency).

$script:AngelscriptTestSuiteDefinitions = [ordered]@{
    Smoke = @(
        @{ Prefix = 'Angelscript.TestModule.Engine.MultiEngine'; Label = 'MultiEngine'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Engine.DependencyInjection'; Label = 'DependencyInjection'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Engine.EngineSubsystem'; Label = 'EngineSubsystem'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Engine.BindConfig'; Label = 'BindConfig'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Shared.EngineHelper'; Label = 'SharedEngineHelper'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Parity'; Label = 'Parity'; Tier = 'Light' }
    )
    NativeCore = @(
        @{ Prefix = 'Angelscript.TestModule.AngelScriptSDK'; Label = 'AngelScriptSDK'; Tier = 'Heavy' }
    )
    RuntimeCpp = @(
        @{ Prefix = 'Angelscript.TestModule.Engine'; Label = 'Engine'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.CppTests'; Label = 'CppTestsLegacy'; Tier = 'Light' }
    )
    Bindings = @(
        @{ Prefix = 'Angelscript.TestModule.Bindings'; Label = 'Bindings'; Tier = 'Heavy' }
    )
    HotReload = @(
        @{ Prefix = 'Angelscript.TestModule.HotReload'; Label = 'HotReload'; Tier = 'Heavy' }
    )
    Debugger = @(
        @{ Prefix = 'Angelscript.TestModule.Engine.Debugger.AutoEvaluate'; Label = 'AutoEvaluate'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Debugger.'; Label = 'TestModuleDebugger'; Tier = 'Heavy' }
    )
    FunctionalSamples = @(
        @{ Prefix = 'Angelscript.TestModule.Actor'; Label = 'Actor'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Component'; Label = 'Component'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Delegate'; Label = 'Delegate'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Interface'; Label = 'Interface'; Tier = 'Light' }
    )
    All = @(
        @{ Prefix = 'Angelscript.Editor'; Label = 'Editor'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.GAS'; Label = 'GAS'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.GameplayTags'; Label = 'GameplayTags'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.Template'; Label = 'Template'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Actor'; Label = 'Actor'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.AngelScriptSDK'; Label = 'AngelScriptSDK'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Bindings'; Label = 'Bindings'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Blueprint'; Label = 'Blueprint'; Tier = 'Heavy' }
		@{ Prefix = 'Angelscript.TestModule.Generator'; Label = 'Generator'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Compiler'; Label = 'Compiler'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Component'; Label = 'Component'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Core'; Label = 'Core'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Debugger'; Label = 'Debugger'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Delegate'; Label = 'Delegate'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Dump'; Label = 'Dump'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Editor'; Label = 'TestModuleEditor'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Engine'; Label = 'Engine'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.FileSystem'; Label = 'FileSystem'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Functional'; Label = 'Functional'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.FunctionLibraries'; Label = 'FunctionLibraries'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.GameInstanceSubsystem'; Label = 'GameInstanceSubsystem'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.GC'; Label = 'GC'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.HotReload'; Label = 'HotReload'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Inheritance'; Label = 'Inheritance'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Interface'; Label = 'Interface'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Memory'; Label = 'Memory'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Networking'; Label = 'Networking'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Parity'; Label = 'Parity'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Performance'; Label = 'Performance'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Preprocessor'; Label = 'Preprocessor'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Shared'; Label = 'Shared'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.StaticJIT'; Label = 'StaticJIT'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.TestModule.Syntax'; Label = 'Syntax'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.Validation'; Label = 'Validation'; Tier = 'Light' }
        @{ Prefix = 'Angelscript.TestModule.WorldSubsystem'; Label = 'WorldSubsystem'; Tier = 'Light' }
    )
}

function Get-AngelscriptTestSuiteDefinitions {
    return $script:AngelscriptTestSuiteDefinitions
}

function Get-AngelscriptTestSuiteEntries {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SuiteName
    )

    $definitions = Get-AngelscriptTestSuiteDefinitions
    if (-not $definitions.Contains($SuiteName)) {
        throw "Unknown suite '$SuiteName'. Use -ListSuites to inspect available values."
    }

    return @($definitions[$SuiteName])
}

function Get-AngelscriptTestModuleSuiteEntries {
    return @(Get-AngelscriptTestSuiteEntries -SuiteName 'All' | Where-Object {
            $_.Prefix -like 'Angelscript.TestModule*'
        })
}

function Resolve-AngelscriptTestSuiteEntryTier {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry
    )

    if ($Entry.ContainsKey('Tier') -and -not [string]::IsNullOrWhiteSpace([string]$Entry.Tier)) {
        return [string]$Entry.Tier
    }

    return 'Light'
}

function Write-AngelscriptTestSuiteCatalog {
    Write-Host 'Available suites:'
    foreach ($suiteName in (Get-AngelscriptTestSuiteDefinitions).Keys) {
        Write-Host "- $suiteName"
        foreach ($entry in (Get-AngelscriptTestSuiteEntries -SuiteName $suiteName)) {
            $tier = Resolve-AngelscriptTestSuiteEntryTier -Entry $entry
            Write-Host "    [$tier] $($entry.Prefix)"
        }
    }
}
