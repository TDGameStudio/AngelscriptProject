[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$runBuildPath = Join-Path $projectRoot 'Tools\RunBuild.ps1'
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $runBuildPath,
    [ref]$tokens,
    [ref]$parseErrors)

if ($parseErrors.Count -ne 0) {
    throw ('RunBuild.ps1 has PowerShell parse errors: {0}' -f
        (($parseErrors | ForEach-Object Message) -join '; '))
}

$parameterNames = @($ast.ParamBlock.Parameters | ForEach-Object {
        $_.Name.VariablePath.UserPath
    })
if ($parameterNames -notcontains 'Target') {
    throw 'RunBuild.ps1 must expose an optional Target parameter for non-Editor target builds.'
}
if ($parameterNames -notcontains 'Configuration') {
    throw 'RunBuild.ps1 must expose an optional Configuration parameter for Shipping target builds.'
}

$contents = Get-Content -LiteralPath $runBuildPath -Raw -Encoding UTF8
if ($contents -notmatch '\[CmdletBinding\(PositionalBinding\s*=\s*\$false\)\]') {
    throw 'RunBuild.ps1 must disable positional binding so -- arguments cannot bind to Target or Configuration.'
}
if ($contents -notmatch '\$resolvedTarget\s*=') {
    throw 'RunBuild.ps1 must resolve Target separately from the configured EditorTarget default.'
}
if ($contents -notmatch 'Target\s*=\s*\$resolvedTarget') {
    throw 'RunBuild.ps1 metadata/output must report the resolved target.'
}
if ($contents -notmatch '\$resolvedTarget\s*\r?\n\s*\$agentConfig\.Platform') {
    throw 'RunBuild.ps1 must pass the resolved target as the first UBT target argument.'
}
if ($contents -notmatch '\$resolvedConfiguration\s*\r?\n\s*"-Project=') {
    throw 'RunBuild.ps1 must pass the resolved configuration after the configured platform.'
}

Write-Output 'RunBuildSelfTests: PASS'
