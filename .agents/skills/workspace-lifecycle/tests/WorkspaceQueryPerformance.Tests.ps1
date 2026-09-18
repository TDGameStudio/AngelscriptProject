#requires -Version 7.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
$module = Import-Module (Join-Path $projectRoot '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1') -Force -PassThru
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('harness-query-cost-' + [guid]::NewGuid().ToString('N'))
$failures = [Collections.Generic.List[string]]::new()
$savedSelection = [Environment]::GetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', 'Process')
function Check([bool]$value, [string]$message) {
    if ($value) { Write-Output "PASS $message" }
    else { $failures.Add($message); Write-Output "FAIL $message" }
}
function Invoke-QueryTestGit([string[]]$arguments) {
    $output = @(& git -C $fixture @arguments 2>&1)
    if ($LASTEXITCODE) { throw ($output -join "`n") }
    return $output
}
try {
    [void][IO.Directory]::CreateDirectory((Join-Path $fixture 'nested'))
    Invoke-QueryTestGit @('init','-q','-b','main') | Out-Null
    [IO.File]::WriteAllText((Join-Path $fixture '.gitignore'), "Saved/`nAgentConfig.ini`n")
    [IO.File]::WriteAllText((Join-Path $fixture 'Fixture.uproject'), '{}')
    Invoke-QueryTestGit @('add','.gitignore','Fixture.uproject') | Out-Null
    Invoke-QueryTestGit @('-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-qm','baseline') | Out-Null

    # Spy at the real native-operation boundary; no Git results are replaced.
    & $module {
        $script:QueryCostOriginalGit = (Get-Command Invoke-WorkspaceGit).ScriptBlock
        $script:QueryCostCalls = [Collections.Generic.List[string]]::new()
        function script:Invoke-WorkspaceGit {
            param([string]$Repository,[string[]]$Arguments,[switch]$AllowFailure)
            $script:QueryCostCalls.Add(($Arguments -join ' '))
            & $script:QueryCostOriginalGit @PSBoundParameters
        }
    }
    foreach ($command in @('Get-HarnessWorkspaceContext','Get-HarnessWorkspaceConfigStatus','Get-HarnessWorkspaceStatus')) {
        & $module { $script:QueryCostCalls.Clear() }
        $result = & $command -ProjectRoot (Join-Path $fixture 'nested')
        $rootProbes = @(& $module { $script:QueryCostCalls | Where-Object { $_ -eq 'rev-parse --show-toplevel' } }).Count
        # One canonical-root probe per public read is the resource boundary being improved.
        Check ($rootProbes -le 1) "$command bounds redundant native root probes (actual=$rootProbes, maximum=1)"
        $identity = if ($command -eq 'Get-HarnessWorkspaceConfigStatus') { $result.Identity } elseif ($command -eq 'Get-HarnessWorkspaceStatus') { $result.Context } else { $result }
        Check ($identity.WorkspaceRoot -eq $fixture -and $identity.Branch -eq 'main') "$command resolves a nested path with the current real identity"
    }
    Check (-not (Test-Path -LiteralPath (Join-Path $fixture 'AgentConfig.ini'))) 'read-only status does not materialize missing configuration'
    [Environment]::SetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', $fixture, 'Process')
    $defaultContext = Get-HarnessWorkspaceContext
    $defaultStatus = Get-HarnessWorkspaceStatus
    $defaultConfig = Get-HarnessWorkspaceConfigStatus
    Check ($defaultContext.WorkspaceRoot -eq $fixture -and $defaultStatus.WorkspaceRoot -eq $fixture -and $defaultConfig.Identity.WorkspaceRoot -eq $fixture) 'empty-root queries retain the selected process workspace'

    Invoke-QueryTestGit @('checkout','-qb','feature/live-query') | Out-Null
    Invoke-QueryTestGit @('-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','--allow-empty','-qm','fresh head') | Out-Null
    $expectedHead = [string](@(Invoke-QueryTestGit @('rev-parse','HEAD'))[-1])
    $fresh = Get-HarnessWorkspaceContext -ProjectRoot $fixture
    $freshStatus = Get-HarnessWorkspaceStatus -ProjectRoot $fixture
    Check ($fresh.Branch -eq 'feature/live-query' -and $fresh.Head -eq $expectedHead -and $freshStatus.Head -eq $expectedHead) 'successive reads detect branch and HEAD changes without refresh'

    $configPath = Join-Path $fixture 'AgentConfig.ini'
    [IO.File]::WriteAllText($configPath, "[Paths]`nEngineRoot=C:\FixtureEngine`n")
    $configured = Get-HarnessWorkspaceStatus -ProjectRoot $fixture
    Check ($configured.ConfigurationReady -and -not $configured.Configuration.IdentityValid) 'new configuration is read immediately and invalid identity stays visible'
    [IO.File]::WriteAllText($configPath, "[Paths]`nEngineRoot=`n")
    $changed = Get-HarnessWorkspaceConfigStatus -ProjectRoot $fixture
    Check (-not $changed.ConfigurationReady) 'configuration edits are visible on the next call'
    [IO.File]::WriteAllText((Join-Path $fixture 'dirty.txt'), 'visible only in detailed scan')
    $detailed = Get-HarnessWorkspaceStatus -ProjectRoot $fixture -Detailed
    Check ($detailed.Dirty -and @($detailed.Changes | Where-Object { $_ -match 'dirty.txt' }).Count -eq 1) 'explicit detailed status retains live dirty-file evidence'
}
finally {
    & $module { if (Get-Variable QueryCostOriginalGit -Scope Script -ErrorAction SilentlyContinue) { Set-Item Function:script:Invoke-WorkspaceGit $script:QueryCostOriginalGit } }
    [Environment]::SetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', $savedSelection, 'Process')
    $allowed = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    $resolved = [IO.Path]::GetFullPath($fixture)
    if (-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase) -or -not ([IO.Path]::GetFileName($resolved)).StartsWith('harness-query-cost-')) { throw 'Refusing unexpected query fixture cleanup path' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
if ($failures.Count) { throw ($failures -join "`n") }
Write-Output 'Workspace query performance and freshness checks passed.'
