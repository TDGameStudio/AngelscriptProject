Set-StrictMode -Version Latest

# Headless automation launch profile for Angelscript test runs.
# NullRHI is applied separately by RunTests.ps1 (default). Do NOT pass -Render unless a test needs real GPU.

function Get-AngelscriptTestFastLaunchArgs {
    <#
    .SYNOPSIS
        Extra UnrealEditor-Cmd arguments that trim editor startup work for automation.
    #>
    return @(
        '-NoLoadStartupPackages'
        '-NoLiveCoding'
        '-NoScreenMessages'
        '-DisableAutomaticShaderCompilerLaunch'
    )
}

function Get-AngelscriptTestCoarseShards {
    <#
    .SYNOPSIS
        Top-level shards for parallel full-suite runs (one editor boot per shard).
    .DESCRIPTION
        Coarse sharding keeps wall time near max(shard) instead of sum(shards).
        Typical wall time on a warm machine: ~4-6 minutes for all Angelscript tests.
    #>
    return @(
        @{ Prefix = 'Angelscript.TestModule'; Label = 'TestModule'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.Editor'; Label = 'Editor'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.GAS'; Label = 'GAS'; Tier = 'Heavy' }
        @{ Prefix = 'Angelscript.Template'; Label = 'Template'; Tier = 'Light' }
    )
}

function Get-AngelscriptTestMonolithicPrefix {
    return 'Angelscript'
}

function Get-AngelscriptTestSlowPrefixExclusions {
    <#
    .SYNOPSIS
        Prefixes to skip for a fast CI gate (~5 min target). Run separately overnight.
    #>
    return @(
        'Angelscript.TestModule.Debugger'
        'Angelscript.TestModule.Performance'
        'Angelscript.TestModule.HotReload'
    )
}
