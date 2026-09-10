[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')"
    }
}

function Assert-Match {
    param([string]$Actual, [string]$Pattern, [string]$Message)
    if ($Actual -notmatch $Pattern) {
        throw "Assertion failed: $Message (actual '$Actual', pattern '$Pattern')"
    }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    try {
        & $Action
    }
    catch {
        Assert-Match -Actual $_.Exception.Message -Pattern $Pattern -Message $Message
        return
    }
    throw "Assertion failed: $Message (action did not throw)"
}

function Invoke-FixtureGit {
    param([string]$Repository, [string[]]$Arguments)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $Repository @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw "Fixture git command failed: git -C '$Repository' $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return @($output | ForEach-Object { [string]$_ })
}

function Invoke-FixtureOpenSpec {
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $locationPushed = $false
    try {
        Push-Location -LiteralPath $WorkspaceRoot
        $locationPushed = $true
        $output = @(& $Executable @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        if ($locationPushed) {
            Pop-Location
        }
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw "Fixture OpenSpec command failed: $Executable $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return @($output | ForEach-Object { [string]$_ })
}

function New-InstallationFixture {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$SourceRoot
    )

    $workspaceTarget = Join-Path $Root '.agents\skills\workspace-lifecycle\scripts'
    $gitTarget = Join-Path $Root '.agents\skills\git-operations\scripts'
    $unrealTarget = Join-Path $Root '.agents\skills\unreal-engine-develop\scripts'
    $openspecTarget = Join-Path $Root '.agents\skills\openspec'
    [void](New-Item -ItemType Directory -Path $workspaceTarget -Force)
    [void](New-Item -ItemType Directory -Path $gitTarget -Force)
    [void](New-Item -ItemType Directory -Path $unrealTarget -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $openspecTarget 'bin') -Force)
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psm1') -Destination $workspaceTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1') -Destination $workspaceTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\git-operations\scripts\GitOperations.psm1') -Destination $gitTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\git-operations\scripts\GitOperations.psd1') -Destination $gitTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psm1') -Destination $unrealTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1') -Destination $unrealTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\openspec\bin\openspec.exe') -Destination (Join-Path $openspecTarget 'bin\openspec.exe')
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\openspec\commands') -Destination $openspecTarget -Recurse
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\openspec\release-manifest.json') -Destination $openspecTarget
    return $Root
}

function Set-FixtureManifestValue {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Name,
        $Value
    )

    $path = Join-Path $Root '.agents\skills\openspec\release-manifest.json'
    $metadata = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $metadata.$Name = $Value
    $json = $metadata | ConvertTo-Json -Depth 20 -Compress
    [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
}

$manifest = Join-Path $PSScriptRoot '..\scripts\Harness.psd1'
$moduleFile = Join-Path $PSScriptRoot '..\scripts\Harness.psm1'

$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($moduleFile, [ref]$tokens, [ref]$errors)
Assert-Equal 0 @($errors).Count 'Harness.psm1 must parse without errors'

$scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-import-{0}" -f [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $scratch)
try {
    Push-Location $scratch
    try {
        Import-Module $manifest -Force
        Assert-Equal 0 @(Get-ChildItem -LiteralPath $scratch -Force).Count 'module import must not write to the current directory'
        Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'importing Harness must not import the Unreal leaf'
    }
    finally {
        Pop-Location
    }

    $expectedFunctions = @(
        'New-HarnessContext',
        'Get-HarnessCommand',
        'Invoke-Harness',
        'Test-HarnessInstallation'
    )
    $exported = @((Get-Module Harness).ExportedFunctions.Keys | Sort-Object)
    Assert-Equal (($expectedFunctions | Sort-Object) -join '|') (($exported | Sort-Object) -join '|') 'public API must stay minimal'

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
    $context = New-HarnessContext -WorkspaceRoot $repoRoot
    foreach ($property in @('SchemaVersion', 'HarnessRoot', 'WorkspaceRoot', 'PrimaryRoot', 'GitCommonDir', 'Topology', 'WorktreeName', 'Branch', 'Head', 'Managed')) {
        Assert-True ($property -in @($context.PSObject.Properties.Name)) "context must contain '$property'"
    }
    Assert-Equal '3' $context.SchemaVersion 'workspace context schema is versioned'
    Assert-Equal $repoRoot $context.HarnessRoot 'context loads the harness from this checkout'
    Assert-Equal $repoRoot $context.WorkspaceRoot 'context targets the requested registered workspace'
    Assert-Equal 'Primary' $context.Topology 'the main checkout derives Primary topology from Git'
    Assert-True ('Mode' -notin @($context.PSObject.Properties.Name)) 'repository mode is not part of context'
    Assert-True ('GoalName' -notin @($context.PSObject.Properties.Name)) 'Goal name is not part of context'
    $contextParameters = @((Get-Command New-HarnessContext).Parameters.Keys)
    Assert-True ('Mode' -notin $contextParameters) 'New-HarnessContext exposes no mode compatibility parameter'
    Assert-True ('GoalName' -notin $contextParameters) 'New-HarnessContext exposes no Goal-name compatibility parameter'
    Assert-True ('ProjectRoot' -notin $contextParameters) 'WorkspaceRoot is the only repository-selection parameter'

    $invalidActiveNameFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-invalid-active-change-name') -SourceRoot $repoRoot
    $invalidActiveNameRoot = Join-Path $invalidActiveNameFixture 'openspec\changes\fixture\legacy-name'
    [void](New-Item -ItemType Directory -Path $invalidActiveNameRoot -Force)
    [System.IO.File]::WriteAllText((Join-Path $invalidActiveNameRoot 'change.yaml'), @'
api_version: openspec.dev/v1
kind: change
metadata:
  uid: change_22222222-2222-4222-8222-222222222222
  id: fixture/legacy-name
  title: Invalid active semantic name
workflow: angelscript
created_at: 2026-09-04T00:00:00Z
goal: Prove installation audit rejects an invalid active Change identity.
'@, [System.Text.UTF8Encoding]::new($false))
    $invalidActiveNameHealth = Test-HarnessInstallation -ProjectRoot $invalidActiveNameFixture
    Assert-True (-not $invalidActiveNameHealth.IsValid) 'installation audit rejects a nonconforming active Change identity'
    Assert-Equal 1 @($invalidActiveNameHealth.Errors | Where-Object { $_ -match "Active Change identity 'fixture/legacy-name'.*<type>-<scope>-<outcome>" }).Count 'installation audit reports the invalid active identity exactly once'

    $routes = @(Get-HarnessCommand)
    foreach ($name in @(
        'workspace.list', 'workspace.status', 'workspace.new', 'workspace.bootstrap', 'workspace.verify', 'workspace.remove', 'workspace.activate',
        'workspace.config.status', 'workspace.config.get', 'workspace.config.set',
        'git.status', 'git.commit', 'git.integrate', 'git.push',
        'harness.status', 'harness.observe', 'harness.evolution.status', 'openspec.maintenance.status',
        'task.status',
        'openspec.validate', 'openspec.change'
    )) {
        Assert-True ($name -in @($routes.Name)) "route '$name' must be registered"
    }
    $expectedUnrealRoutes = [ordered]@{
        'ue.status'           = 'Get-HarnessUnrealStatus'
        'ue.engine.list'      = 'Get-HarnessUnrealEngineList'
        'ue.target.list'      = 'Get-HarnessUnrealTargetList'
        'ue.process.list'     = 'Get-HarnessUnrealProcessList'
        'ue.ubt.capabilities' = 'Get-HarnessUnrealUbtCapabilities'
        'ue.ubt.invoke'       = 'Invoke-HarnessUnrealUbt'
        'ue.build'            = 'Invoke-HarnessUnrealBuild'
        'ue.test'             = 'Invoke-HarnessUnrealTest'
        'ue.commandlet'       = 'Invoke-HarnessUnrealCommandlet'
        'ue.suite.list'       = 'Get-HarnessUnrealSuiteList'
        'ue.suite.plan'       = 'New-HarnessUnrealSuitePlan'
        'ue.suite.run'        = 'Invoke-HarnessUnrealSuite'
        'ue.run.status'       = 'Get-HarnessUnrealRunStatus'
        'ue.run.cancel'       = 'Stop-HarnessUnrealRun'
    }
    $unrealRoutes = @($routes | Where-Object { $_.Name -like 'ue.*' })
    Assert-Equal $expectedUnrealRoutes.Count $unrealRoutes.Count 'Harness publishes exactly the complete Unreal route surface'
    Assert-Equal (($expectedUnrealRoutes.Keys | Sort-Object) -join '|') (($unrealRoutes.Name | Sort-Object) -join '|') 'Harness publishes no missing or extra Unreal route'
    foreach ($routeName in $expectedUnrealRoutes.Keys) {
        $route = $unrealRoutes | Where-Object Name -eq $routeName | Select-Object -First 1
        Assert-Equal 'PowerShell' $route.Kind "$routeName is a PowerShell leaf route"
        Assert-Equal '.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1' $route.Target "$routeName resolves the reviewed Unreal manifest from HarnessRoot"
        Assert-Equal $expectedUnrealRoutes[$routeName] $route.EntryPoint "$routeName maps to its exact public function"
    }
    $buildRoute = $unrealRoutes | Where-Object Name -eq 'ue.build' | Select-Object -First 1
    Assert-True $buildRoute.Defaults.ContainsKey('BuildConcurrency') 'ue.build exposes the typed BuildConcurrency route default'
    Assert-Equal 'Auto' $buildRoute.Defaults.BuildConcurrency 'ue.build defaults BuildConcurrency to Auto'
    $cancelRoute = $unrealRoutes | Where-Object Name -eq 'ue.run.cancel' | Select-Object -First 1
    Assert-True (-not $cancelRoute.Defaults.ContainsKey('Confirm')) 'ue.run.cancel does not silently disable confirmation'
    Assert-Equal 0 @($routes | Where-Object { $_.Name -match '^(staticjit\.|cache\.|coverage$|standalone\.|engine\.|execution\.|toolchain\.)' }).Count 'unimplemented non-Unreal leaf routes remain unpublished'

    $first = Invoke-Harness -Command 'workspace.status' -Context $context
    $second = Invoke-Harness -Command 'workspace.status' -Context $context
    foreach ($result in @($first, $second)) {
        foreach ($property in @('schemaVersion', 'command', 'runId', 'status', 'exitCode', 'durationMs', 'artifacts', 'data', 'error')) {
            Assert-True ($property -in @($result.PSObject.Properties.Name)) "result must contain '$property'"
        }
        Assert-Equal '1.0' $result.schemaVersion 'result schema is versioned'
        Assert-Equal 'workspace.status' $result.command 'result identifies its route'
        Assert-Equal 'Succeeded' $result.status 'workspace status succeeds repeatedly in one session'
        Assert-Equal 0 $result.exitCode 'successful route returns exit code zero'
        Assert-Equal 0 @($result.artifacts).Count 'a route with no artifacts returns an empty array, not a null entry'
    }
    Assert-True ($first.runId -ne $second.runId) 'each invocation gets a distinct run id'

    $unknown = Invoke-Harness -Command 'missing.route' -Context $context
    Assert-Equal 'Failed' $unknown.status 'unknown route returns a failed envelope instead of terminating the session'
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$unknown.error.message)) 'failed envelope contains an error message'

    $nativeFailure = Invoke-Harness -Command 'openspec.validate' -Context $context -ArgumentList @('__harness_missing_target__', '--json')
    Assert-Equal 'Failed' $nativeFailure.status 'a native non-zero exit returns a failed envelope'
    Assert-Equal 1 $nativeFailure.exitCode 'native exit code is preserved'
    Assert-True ($null -ne $nativeFailure.data) 'native failure preserves its diagnostic data'
    Assert-True (@($nativeFailure.data.Output).Count -gt 0) 'native failure preserves stdout and stderr output'

    $unrealEnvelopeRoot = Join-Path $scratch 'unreal-envelope'
    $unrealEnvelopeScripts = Join-Path $unrealEnvelopeRoot '.agents\skills\unreal-engine-develop\scripts'
    [void](New-Item -ItemType Directory -Path $unrealEnvelopeScripts -Force)
    [System.IO.File]::WriteAllText((Join-Path $unrealEnvelopeScripts 'UnrealEngineDevelop.psd1'), @'
@{
    RootModule = 'UnrealEngineDevelop.psm1'
    ModuleVersion = '1.0.0'
    GUID = '8939df42-d93d-4382-9622-ea9011423908'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Invoke-HarnessUnrealUbt'
        'Invoke-HarnessUnrealBuild'
        'Invoke-HarnessUnrealTest'
        'Invoke-HarnessUnrealCommandlet'
        'Invoke-HarnessUnrealSuite'
        'Get-HarnessUnrealRunStatus'
        'Stop-HarnessUnrealRun'
    )
}
'@, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $unrealEnvelopeScripts 'UnrealEngineDevelop.psm1'), @'
function New-FixtureUnrealResult {
    param([string] $Scenario)
    switch ($Scenario) {
        'Failed' { return [pscustomobject]@{ RunId = 'fixture-run'; State = 'Failed'; ExitCode = 6; Artifacts = @('fixture.log') } }
        'TimedOut' { return [pscustomobject]@{ RunId = 'fixture-run'; State = 'TimedOut'; ExitCode = 2; Artifacts = @('timeout.log') } }
        'Orphaned' { return [pscustomobject]@{ RunId = 'fixture-run'; State = 'Orphaned'; ExitCode = $null; Artifacts = @('orphan.log') } }
        'Queued' { return [pscustomobject]@{ RunId = 'fixture-run'; State = 'Queued'; ExitCode = $null; Artifacts = @() } }
        'Cancelled' { return [pscustomobject]@{ RunId = 'fixture-run'; State = 'Cancelled'; ExitCode = 2; Artifacts = @('cancel.log') } }
        default { return [pscustomobject]@{ RunId = 'fixture-run'; State = 'Succeeded'; ExitCode = 0; Artifacts = @('success.log') } }
    }
}
function Invoke-HarnessUnrealUbt { param($WorkspaceRoot, $Scenario = 'Succeeded') New-FixtureUnrealResult $Scenario }
function Invoke-HarnessUnrealBuild { param($WorkspaceRoot, $BuildConcurrency, $Scenario = 'Succeeded') New-FixtureUnrealResult $Scenario }
function Invoke-HarnessUnrealTest { param($WorkspaceRoot, $Scenario = 'Succeeded') New-FixtureUnrealResult $Scenario }
function Invoke-HarnessUnrealCommandlet { param($WorkspaceRoot, $Scenario = 'Succeeded') New-FixtureUnrealResult $Scenario }
function Invoke-HarnessUnrealSuite { param($WorkspaceRoot, $Scenario = 'Succeeded') New-FixtureUnrealResult $Scenario }
function Get-HarnessUnrealRunStatus { param($WorkspaceRoot, $Scenario = 'Failed') New-FixtureUnrealResult $Scenario }
function Stop-HarnessUnrealRun { param($WorkspaceRoot, $Scenario = 'Cancelled') New-FixtureUnrealResult $Scenario }
Export-ModuleMember -Function Invoke-HarnessUnrealUbt, Invoke-HarnessUnrealBuild, Invoke-HarnessUnrealTest, Invoke-HarnessUnrealCommandlet, Invoke-HarnessUnrealSuite, Get-HarnessUnrealRunStatus, Stop-HarnessUnrealRun
'@, [System.Text.UTF8Encoding]::new($false))
    $unrealEnvelopeContext = $context | Select-Object *
    $unrealEnvelopeContext.HarnessRoot = $unrealEnvelopeRoot
    foreach ($executionRoute in @('ue.build', 'ue.ubt.invoke', 'ue.test', 'ue.commandlet', 'ue.suite.run')) {
        $failedOperation = Invoke-Harness -Command $executionRoute -Context $unrealEnvelopeContext -Parameters @{ Scenario = 'Failed' }
        Assert-Equal 'Failed' $failedOperation.status "$executionRoute propagates a synchronous terminal failure to the common envelope"
        Assert-Equal 6 $failedOperation.exitCode "$executionRoute preserves the operation exit code"
        Assert-Equal 'UnrealOperationFailed' $failedOperation.error.code "$executionRoute exposes the stable Unreal operation error code"
        Assert-Match $failedOperation.error.message ([regex]::Escape($executionRoute)) "$executionRoute failure identifies its route"
        Assert-Equal 'Failed' $failedOperation.data.State "$executionRoute preserves the terminal operation data"
        Assert-Equal 'fixture.log' $failedOperation.artifacts[0] "$executionRoute preserves the operation artifacts"
    }
    foreach ($terminalCase in @(
        [pscustomobject]@{ State = 'TimedOut'; ExitCode = 2 },
        [pscustomobject]@{ State = 'Cancelled'; ExitCode = 2 },
        [pscustomobject]@{ State = 'Orphaned'; ExitCode = 1 }
    )) {
        $terminalOperation = Invoke-Harness -Command 'ue.build' -Context $unrealEnvelopeContext -Parameters @{ Scenario = $terminalCase.State }
        Assert-Equal 'Failed' $terminalOperation.status "synchronous $($terminalCase.State) is a failed execution envelope"
        Assert-Equal $terminalCase.ExitCode $terminalOperation.exitCode "synchronous $($terminalCase.State) uses the expected non-zero envelope exit"
        Assert-Equal $terminalCase.State $terminalOperation.data.State "synchronous $($terminalCase.State) preserves returned operation data"
    }
    $queuedOperation = Invoke-Harness -Command 'ue.build' -Context $unrealEnvelopeContext -Parameters @{ Scenario = 'Queued' }
    Assert-Equal 'Succeeded' $queuedOperation.status 'a non-terminal asynchronous-style dispatch remains a successful envelope'
    $successfulOperation = Invoke-Harness -Command 'ue.build' -Context $unrealEnvelopeContext -Parameters @{ Scenario = 'Succeeded' }
    Assert-Equal 'Succeeded' $successfulOperation.status 'a successful synchronous operation remains a successful envelope'
    Assert-Equal 'success.log' $successfulOperation.artifacts[0] 'a successful operation retains its artifacts'
    $failedObservation = Invoke-Harness -Command 'ue.run.status' -Context $unrealEnvelopeContext -Parameters @{ Scenario = 'Failed' }
    Assert-Equal 'Succeeded' $failedObservation.status 'successfully observing a failed run is not itself an execution failure'
    Assert-Equal 'Failed' $failedObservation.data.State 'status observation retains the observed failed state'
    $cancelledCommand = Invoke-Harness -Command 'ue.run.cancel' -Context $unrealEnvelopeContext -Parameters @{ Scenario = 'Cancelled' }
    Assert-Equal 'Succeeded' $cancelledCommand.status 'a successful cancellation command is not reclassified from its cancelled result state'
    Assert-Equal 'Cancelled' $cancelledCommand.data.State 'cancellation retains the resulting cancelled state'
    & (Get-Module Harness -ErrorAction Stop) { Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue }

    $sourceOpenSpec = Join-Path $repoRoot '.agents\skills\openspec\bin\openspec.exe'
    $taskWorkspaceRoot = Join-Path $scratch 'task-workspace'
    $taskWorkspaceExeDirectory = Join-Path $taskWorkspaceRoot '.agents\skills\openspec\bin'
    [void](New-Item -ItemType Directory -Path $taskWorkspaceExeDirectory -Force)
    Copy-Item -LiteralPath $sourceOpenSpec -Destination (Join-Path $taskWorkspaceExeDirectory 'openspec.exe')
    [void](Invoke-FixtureGit -Repository $taskWorkspaceRoot -Arguments @('init', '-b', 'main'))
    [System.IO.File]::WriteAllText((Join-Path $taskWorkspaceRoot '.gitignore'), "Saved/`nAgentConfig.ini`n")
    [System.IO.File]::WriteAllText((Join-Path $taskWorkspaceRoot 'Fixture.uproject'), "{}`n")
    $taskWorkspaceContext = New-HarnessContext -WorkspaceRoot $taskWorkspaceRoot

    $alternateRepositoryRoot = Join-Path $repoRoot 'Tools\openspec'
    $retargetedGitStatus = Invoke-Harness -Command 'git.status' -Context $context -Parameters @{ WorkspaceRoot = $alternateRepositoryRoot }
    Assert-Equal 'Failed' $retargetedGitStatus.status 'selected Context rejects a Git route retargeted to another repository'
    Assert-Equal 'ContextAuthorityMismatch' $retargetedGitStatus.error.code 'a rejected route retarget exposes the stable authority error code'
    Assert-True ($null -eq $retargetedGitStatus.data) 'route authority rejection occurs before the alternate leaf is invoked'

    $taskWorkspaceInit = Invoke-Harness -Command 'openspec.init' -Context $taskWorkspaceContext -ArgumentList @(
        '--project-id', 'harness-task-workspace',
        '--title', 'Harness Task Workspace Fixture'
    )
    Assert-Equal 'Succeeded' $taskWorkspaceInit.status 'Task Graph fixture initializes through the selected workspace'
    $taskWorkspaceDomain = Invoke-Harness -Command 'openspec.domain' -Context $taskWorkspaceContext -ArgumentList @(
        'create', 'fixture', '--title', 'Fixture', '--description', 'Fixture', '--json'
    )
    Assert-Equal 'Succeeded' $taskWorkspaceDomain.status 'Task Graph fixture domain is created'

    $legacyArchiveRoot = Join-Path $taskWorkspaceRoot 'openspec\archive\changes\fixture\2026-01-01-legacy-archive-name'
    $legacyArchiveManifestPath = Join-Path $legacyArchiveRoot 'change.yaml'
    [void](New-Item -ItemType Directory -Path $legacyArchiveRoot -Force)
    [System.IO.File]::WriteAllText($legacyArchiveManifestPath, @'
api_version: openspec.dev/v1
kind: change
metadata:
  uid: change_11111111-1111-4111-8111-111111111111
  id: fixture/legacy-archive-name
  title: Immutable legacy archive fixture
workflow: angelscript
created_at: 2026-01-01T00:00:00Z
archived_at: 2026-01-02T00:00:00Z
archive_schema: closure-v1
closure:
  kind: completed
goal: Prove semantic naming never rewrites historical archives.
'@, [System.Text.UTF8Encoding]::new($false))
    $legacyArchiveHash = (Get-FileHash -LiteralPath $legacyArchiveManifestPath -Algorithm SHA256).Hash

    $validSemanticChangeIds = @(
        'fixture/feature-runtime-route-selection',
        'fixture/fix-change-name-validation',
        'fixture/refactor-skill-module-boundaries',
        'fixture/improve-status-error-diagnostics',
        'fixture/docs-change-authoring-guidance',
        'fixture/test-semantic-name-regressions',
        'fixture/chore-record-tree-maintenance'
    )
    foreach ($changeId in $validSemanticChangeIds) {
        $validSemanticChange = Invoke-Harness -Command 'openspec.change' -Context $taskWorkspaceContext -ArgumentList @(
            'create', $changeId, '--title', "Semantic fixture $changeId", '--goal', 'Exercise one allowed semantic Change type', '--json'
        )
        Assert-Equal 'Succeeded' $validSemanticChange.status "semantic Change type is accepted for '$changeId'"
        $validSemanticLeaf = ($changeId -split '/', 2)[1]
        $validSemanticManifestPath = Join-Path $taskWorkspaceRoot "openspec\changes\fixture\$validSemanticLeaf\change.yaml"
        Assert-True (Test-Path -LiteralPath $validSemanticManifestPath -PathType Leaf) "accepted semantic Change '$changeId' is created at its canonical active identity"
    }

    $invalidSemanticChangeCases = @(
        [pscustomobject]@{ Id = 'fixture/feat-change-naming'; Reason = 'the Git commit alias feat is not a Change type' },
        [pscustomobject]@{ Id = 'fixture/repair-change-naming'; Reason = 'an unknown semantic type is rejected' },
        [pscustomobject]@{ Id = 'fixture/fix-naming'; Reason = 'a Change leaf without a distinct outcome is rejected' },
        [pscustomobject]@{ Id = 'fixture/fix'; Reason = 'a Change leaf without scope and outcome is rejected' },
        [pscustomobject]@{ Id = 'fixture/Fix-change-naming'; Reason = 'uppercase text is rejected by the project boundary' }
    )
    foreach ($invalidCase in $invalidSemanticChangeCases) {
        $invalidSemanticChange = Invoke-Harness -Command 'openspec.change' -Context $taskWorkspaceContext -ArgumentList @(
            'create', $invalidCase.Id, '--title', 'Rejected semantic fixture', '--goal', 'This target must not be created', '--json'
        )
        Assert-Equal 'Failed' $invalidSemanticChange.status $invalidCase.Reason
        Assert-Equal 'InvalidChangeName' $invalidSemanticChange.error.code "semantic failure for '$($invalidCase.Id)' exposes the stable error code"
        Assert-True ($null -eq $invalidSemanticChange.data) "semantic failure for '$($invalidCase.Id)' occurs before the portable CLI is invoked"
        Assert-Match $invalidSemanticChange.error.message '<type>-<scope>-<outcome>' "semantic failure for '$($invalidCase.Id)' states the canonical form"
        Assert-Match $invalidSemanticChange.error.message 'feature.*fix.*refactor.*improve.*docs.*test.*chore' "semantic failure for '$($invalidCase.Id)' lists every allowed type"
        $invalidSemanticLeaf = ($invalidCase.Id -split '/', 2)[1]
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $taskWorkspaceRoot "openspec\changes\fixture\$invalidSemanticLeaf"))) "rejected semantic target '$($invalidCase.Id)' never mutates the active record tree"
    }

    $taskWorkspaceOpenSpec = Join-Path $taskWorkspaceExeDirectory 'openspec.exe'
    [void](Invoke-FixtureOpenSpec -WorkspaceRoot $taskWorkspaceRoot -Executable $taskWorkspaceOpenSpec -Arguments @(
        'change', 'create', 'fixture/legacy-change-name', '--title', 'Legacy source', '--goal', 'Seed a pre-policy active Change', '--json'
    ))
    $legacyMove = Invoke-Harness -Command 'openspec.change' -Context $taskWorkspaceContext -ArgumentList @(
        'move', 'fixture/legacy-change-name', '--to', 'fixture/fix-legacy-change-name', '--json'
    )
    Assert-Equal 'Succeeded' $legacyMove.status 'a pre-policy active source may move to a conforming target'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $taskWorkspaceRoot 'openspec\changes\fixture\legacy-change-name'))) 'successful repair removes the legacy active source path'
    Assert-True (Test-Path -LiteralPath (Join-Path $taskWorkspaceRoot 'openspec\changes\fixture\fix-legacy-change-name\change.yaml') -PathType Leaf) 'successful repair creates the conforming active target'

    [void](Invoke-FixtureOpenSpec -WorkspaceRoot $taskWorkspaceRoot -Executable $taskWorkspaceOpenSpec -Arguments @(
        'change', 'create', 'fixture/legacy-move-source', '--title', 'Legacy move source', '--goal', 'Prove an invalid target cannot consume a legacy source', '--json'
    ))
    $legacyMoveSourcePath = Join-Path $taskWorkspaceRoot 'openspec\changes\fixture\legacy-move-source'
    $legacyMoveSourceHash = (Get-FileHash -LiteralPath (Join-Path $legacyMoveSourcePath 'change.yaml') -Algorithm SHA256).Hash
    $invalidMove = Invoke-Harness -Command 'openspec.change' -Context $taskWorkspaceContext -ArgumentList @(
        'move', 'fixture/legacy-move-source', '--to', 'fixture/feat-move-target', '--json'
    )
    Assert-Equal 'Failed' $invalidMove.status 'a legacy active source does not permit a nonconforming move target'
    Assert-Equal 'InvalidChangeName' $invalidMove.error.code 'a rejected move target exposes the stable naming error code'
    Assert-True ($null -eq $invalidMove.data) 'a nonconforming move target is rejected before the portable CLI is invoked'
    Assert-Match $invalidMove.error.message '<type>-<scope>-<outcome>' 'a rejected move target states the canonical form'
    Assert-True (Test-Path -LiteralPath $legacyMoveSourcePath -PathType Container) 'a rejected move preserves the legacy active source'
    Assert-Equal $legacyMoveSourceHash (Get-FileHash -LiteralPath (Join-Path $legacyMoveSourcePath 'change.yaml') -Algorithm SHA256).Hash 'a rejected move preserves the legacy source manifest byte-for-byte'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $taskWorkspaceRoot 'openspec\changes\fixture\feat-move-target'))) 'a rejected move never creates its nonconforming target'
    Assert-True (Test-Path -LiteralPath $legacyArchiveRoot -PathType Container) 'semantic route validation leaves the historical archive path in place'
    Assert-Equal $legacyArchiveHash (Get-FileHash -LiteralPath $legacyArchiveManifestPath -Algorithm SHA256).Hash 'semantic route validation leaves the historical archive manifest byte-for-byte unchanged'

    $taskWorkspaceChange = Invoke-Harness -Command 'openspec.change' -Context $taskWorkspaceContext -ArgumentList @(
        'create', 'fixture/test-task-dag', '--title', 'Task DAG', '--goal', 'Verify Harness task recognition', '--json'
    )
    Assert-Equal 'Succeeded' $taskWorkspaceChange.status 'Task Graph fixture change is created'
    $taskWorkspacePath = Join-Path $taskWorkspaceRoot 'openspec\changes\fixture\test-task-dag\tasks.md'
    $taskWorkspaceDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.10": []
    "2.1": ["1.2"]
---

## Tasks

- [ ] 1.10 Independent work

    **Files**

    - `independent`

    **Verification**

    ```sh
    independent
    ```

- [ ] 2.1 Blocked work

    **Files**

    - `blocked`

    **Verification**

    ```sh
    blocked
    ```

- [ ] 1.2 Ready work

    **Files**

    - `ready`

    **Verification**

    ```sh
    ready
    ```

- [x] 1.1 Completed base

    **Files**

    - `base`

    **Verification**

    ```sh
    base
    ```
'@
    [System.IO.File]::WriteAllText($taskWorkspacePath, $taskWorkspaceDocument, [System.Text.UTF8Encoding]::new($false))

    $taskStatus = Invoke-Harness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/test-task-dag' }
    Assert-Equal 'Succeeded' $taskStatus.status 'task.status recognizes a selected workspace Task Graph'
    Assert-Equal 'fixture/test-task-dag' $taskStatus.data.changeId 'task.status returns the selected change'
    Assert-True ('tasks' -in @($taskStatus.data.PSObject.Properties.Name)) 'task.status returns parsed TaskPlan data'
    Assert-True ('Output' -notin @($taskStatus.data.PSObject.Properties.Name)) 'task.status does not expose an untyped native-output wrapper'
    Assert-Equal '1.1|1.2|1.10|2.1' (@($taskStatus.data.tasks.id) -join '|') 'task.status presents task IDs in natural numeric order'
    $completedTask = $taskStatus.data.tasks | Where-Object id -eq '1.1' | Select-Object -First 1
    $readyTask = $taskStatus.data.tasks | Where-Object id -eq '1.2' | Select-Object -First 1
    $independentTask = $taskStatus.data.tasks | Where-Object id -eq '1.10' | Select-Object -First 1
    $blockedTask = $taskStatus.data.tasks | Where-Object id -eq '2.1' | Select-Object -First 1
    Assert-True $completedTask.done 'task.status preserves completed checkbox state'
    Assert-True (-not $completedTask.ready) 'completed work is never returned Ready'
    Assert-Equal '1.1' (@($readyTask.after) -join '|') 'task.status preserves normalized direct predecessors'
    Assert-True $readyTask.ready 'an incomplete task with completed predecessors is Ready'
    Assert-True $independentTask.ready 'an incomplete root task is Ready'
    Assert-True (-not $blockedTask.ready) 'an incomplete task with an incomplete predecessor remains blocked'
    foreach ($duplicateState in @('readyTasks', 'readyTaskIds', 'blockedTasks', 'blockedTaskIds')) {
        Assert-True ($duplicateState -notin @($taskStatus.data.PSObject.Properties.Name)) "task.status does not duplicate derived state as '$duplicateState'"
    }

    $taskCycleDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": ["1.2"]
    "1.2": ["1.1"]
---

## Tasks

- [ ] 1.1 First

    **Files**

    - `first`

    **Verification**

    ```sh
    first
    ```

- [ ] 1.2 Second

    **Files**

    - `second`

    **Verification**

    ```sh
    second
    ```
'@
    [System.IO.File]::WriteAllText($taskWorkspacePath, $taskCycleDocument, [System.Text.UTF8Encoding]::new($false))
    $cycleStatus = Invoke-Harness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/test-task-dag' }
    Assert-Equal 'Succeeded' $cycleStatus.status 'task.status preserves a successfully inspected invalid Task Graph in its envelope'
    Assert-Equal 'waiting' $cycleStatus.data.state 'an invalid Task Graph remains waiting instead of becoming schedulable'
    Assert-True ('cycle' -in @($cycleStatus.data.taskIssues.code)) 'task.status preserves OpenSpec cycle diagnostics'
    Assert-Equal 0 @($cycleStatus.data.tasks | Where-Object ready).Count 'task.status never produces Ready work from a cycle'

    $retiredTaskDocument = '- [ ] 1.1 Retired metadata — verify: `never`' + "`n" + '  > Files: `old.rs`'
    [System.IO.File]::WriteAllText($taskWorkspacePath, $retiredTaskDocument, [System.Text.UTF8Encoding]::new($false))
    $retiredStatus = Invoke-Harness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/test-task-dag' }
    Assert-Equal 'Succeeded' $retiredStatus.status 'task.status preserves an inspected zero-node invalid plan'
    Assert-Equal 'waiting' $retiredStatus.data.state 'retired metadata remains unschedulable'
    Assert-Equal 0 @($retiredStatus.data.tasks).Count 'retired metadata yields no executable tasks'
    Assert-True ('unsupported-task-format' -in @($retiredStatus.data.taskIssues.code)) 'the migration diagnostic survives Harness projection'

    $missingTaskStatus = Invoke-Harness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/missing' }
    Assert-Equal 'Failed' $missingTaskStatus.status 'task.status reports a missing change through the common failed envelope'
    Assert-True ($missingTaskStatus.exitCode -ne 0) 'task.status preserves the missing-change native exit code'
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$missingTaskStatus.error.message)) 'task.status preserves the missing-change diagnostic'

    $fixtureProject = Join-Path $scratch 'fixture-project'
    [void](New-Item -ItemType Directory -Path $fixtureProject)
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('init', '-b', 'main'))
    $fixtureModuleDirectory = Join-Path $fixtureProject '.agents\\skills\\workspace-lifecycle\\scripts'
    $fixtureGitModuleDirectory = Join-Path $fixtureProject '.agents\\skills\\git-operations\\scripts'
    [void](New-Item -ItemType Directory -Path $fixtureModuleDirectory -Force)
    [void](New-Item -ItemType Directory -Path $fixtureGitModuleDirectory -Force)
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\workspace-lifecycle\\scripts\\WorkspaceLifecycle.psm1') -Destination $fixtureModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\workspace-lifecycle\\scripts\\WorkspaceLifecycle.psd1') -Destination $fixtureModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\git-operations\\scripts\\GitOperations.psm1') -Destination $fixtureGitModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\git-operations\\scripts\\GitOperations.psd1') -Destination $fixtureGitModuleDirectory
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject '.gitignore'), ".worktrees/`nAgentConfig.ini`nSaved/`n")
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject 'Fixture.uproject'), "{}`n")
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject 'fixture.txt'), "fixture`n")
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('add', '--', '.'))
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('-c', 'user.name=Harness Tests', '-c', 'user.email=harness-tests@example.invalid', 'commit', '-m', 'fixture'))

    $externalContainer = Join-Path $scratch 'external-worktrees'
    [void](New-Item -ItemType Directory -Path $externalContainer)
    $fixtureWorkspace = Join-Path $externalContainer 'fixture-workspace'
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'add', '-b', 'feature/fixture-workspace', $fixtureWorkspace, 'HEAD'))

    $fixturePrimaryContext = New-HarnessContext -WorkspaceRoot $fixtureProject
    $workspaceContext = New-HarnessContext -WorkspaceRoot $fixtureWorkspace
    Assert-Equal $repoRoot $workspaceContext.HarnessRoot 'a target worktree does not change the loaded harness root'
    Assert-Equal $fixtureWorkspace $workspaceContext.WorkspaceRoot 'context targets an arbitrary registered worktree'
    Assert-Equal $fixtureProject $workspaceContext.PrimaryRoot 'context records the registered primary checkout'
    Assert-Equal 'Worktree' $workspaceContext.Topology 'linked topology derives from Git registration'
    Assert-Equal 'feature/fixture-workspace' $workspaceContext.Branch 'context preserves the actual branch name'
    Assert-True ('Mode' -notin @($workspaceContext.PSObject.Properties.Name)) 'linked context has no repository mode'
    Assert-True ('GoalName' -notin @($workspaceContext.PSObject.Properties.Name)) 'linked context has no Goal name'

    $workspaceAuthorityCases = @(
        [pscustomobject]@{ Route = 'workspace.list'; Parameters = @{ WorkspaceRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.status'; Parameters = @{ ProjectRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.new'; Parameters = @{ RepositoryRoot = $fixtureWorkspace } },
        [pscustomobject]@{ Route = 'workspace.bootstrap'; Parameters = @{ WorkspaceRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.verify'; Parameters = @{ ProjectRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.activate'; Parameters = @{ WorkspaceRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.config.status'; Parameters = @{ ProjectRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.config.get'; Parameters = @{ WorkspaceRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.config.set'; Parameters = @{ ProjectRoot = $fixtureProject } },
        [pscustomobject]@{ Route = 'workspace.remove'; Parameters = @{ RepositoryRoot = $fixtureWorkspace } },
        [pscustomobject]@{ Route = 'workspace.remove'; Parameters = @{ WorktreeRoot = $fixtureProject } }
    )
    foreach ($authorityCase in $workspaceAuthorityCases) {
        $rejected = Invoke-Harness -Command $authorityCase.Route -Context $workspaceContext -Parameters $authorityCase.Parameters
        Assert-Equal 'Failed' $rejected.status "$($authorityCase.Route) rejects a dispatcher-owned workspace override"
        Assert-Equal 'ContextAuthorityMismatch' $rejected.error.code "$($authorityCase.Route) reports the stable context authority failure"
        Assert-True ($null -eq $rejected.data) "$($authorityCase.Route) rejects the override before leaf data exists"
    }
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $fixtureProject 'AgentConfig.ini'))) 'rejected workspace retargets do not bootstrap or configure the alternate target'

    foreach ($routeName in @('git.status', 'git.commit', 'git.push')) {
        $rejected = Invoke-Harness -Command $routeName -Context $workspaceContext -Parameters @{ ProjectRoot = $fixtureProject }
        Assert-Equal 'Failed' $rejected.status "$routeName rejects an alternate Git target"
        Assert-Equal 'ContextAuthorityMismatch' $rejected.error.code "$routeName reports the stable context authority failure"
        Assert-True ($null -eq $rejected.data) "$routeName rejects before the Git leaf returns data"
    }

    foreach ($routeName in @($expectedUnrealRoutes.Keys)) {
        $rejected = Invoke-Harness -Command $routeName -Context $workspaceContext -Parameters @{ WorkspaceRoot = $fixtureProject }
        Assert-Equal 'Failed' $rejected.status "$routeName rejects an alternate Unreal workspace"
        Assert-Equal 'ContextAuthorityMismatch' $rejected.error.code "$routeName reports the stable context authority failure"
        Assert-True ($null -eq $rejected.data) "$routeName rejects before the Unreal leaf returns data"
    }

    foreach ($routeName in @('harness.status', 'harness.observe', 'harness.evolution.status', 'openspec.maintenance.status')) {
        $rejected = Invoke-Harness -Command $routeName -Context $workspaceContext -Parameters @{ Context = $fixturePrimaryContext }
        Assert-Equal 'Failed' $rejected.status "$routeName rejects a caller-supplied replacement Context"
        Assert-Equal 'ContextAuthorityMismatch' $rejected.error.code "$routeName reports the stable context authority failure"
        Assert-True ($null -eq $rejected.data) "$routeName rejects before the internal route returns data"
    }

    $blankRoot = Invoke-Harness -Command 'git.status' -Context $workspaceContext -Parameters @{ WorkspaceRoot = ' ' }
    Assert-Equal 'ContextAuthorityMismatch' $blankRoot.error.code 'a blank dispatcher-owned root is rejected explicitly'
    $conflictingAliases = Invoke-Harness -Command 'git.status' -Context $workspaceContext -Parameters @{ WorkspaceRoot = $fixtureWorkspace; ProjectRoot = $fixtureProject }
    Assert-Equal 'ContextAuthorityMismatch' $conflictingAliases.error.code 'conflicting canonical and alias roots are rejected explicitly'

    foreach ($matchingParameters in @(
        @{ WorkspaceRoot = $fixtureWorkspace },
        @{ ProjectRoot = $fixtureWorkspace },
        @{ WorkspaceRoot = ($fixtureWorkspace + [System.IO.Path]::DirectorySeparatorChar); ProjectRoot = $fixtureWorkspace }
    )) {
        $matchingWorkspaceStatus = Invoke-Harness -Command 'workspace.status' -Context $workspaceContext -Parameters $matchingParameters
        Assert-Equal 'Succeeded' $matchingWorkspaceStatus.status 'matching explicit workspace roots are idempotent aliases'
        Assert-Equal $fixtureWorkspace $matchingWorkspaceStatus.data.WorkspaceRoot 'matching aliases normalize to the selected canonical workspace'
    }
    foreach ($matchingParameters in @(
        @{ WorkspaceRoot = $fixtureWorkspace },
        @{ ProjectRoot = $fixtureWorkspace },
        @{ WorkspaceRoot = $fixtureWorkspace; ProjectRoot = ($fixtureWorkspace + [System.IO.Path]::DirectorySeparatorChar) }
    )) {
        $matchingGitStatus = Invoke-Harness -Command 'git.status' -Context $workspaceContext -Parameters $matchingParameters
        Assert-Equal 'Succeeded' $matchingGitStatus.status 'matching explicit Git roots are idempotent aliases'
        Assert-Equal $fixtureWorkspace $matchingGitStatus.data.WorkspaceRoot 'matching Git aliases normalize to the selected canonical workspace'
    }

    $linkedIntegration = Invoke-Harness -Command 'git.integrate' -Context $workspaceContext -Parameters @{
        SourceWorkspaceRoot = $fixtureProject
        ExpectedSourceHead = $fixturePrimaryContext.Head
        TargetBranches = @{ '.' = 'feature/fixture-workspace' }
        WhatIf = $true
    }
    Assert-Equal 'Failed' $linkedIntegration.status 'git.integrate cannot silently redirect a linked selected Context to its primary root'
    Assert-Equal 'ContextAuthorityMismatch' $linkedIntegration.error.code 'linked-context integration reports the dispatcher authority failure'

    $overriddenIntegration = Invoke-Harness -Command 'git.integrate' -Context $fixturePrimaryContext -Parameters @{
        WorkspaceRoot = $fixtureWorkspace
        SourceWorkspaceRoot = $fixtureWorkspace
        ExpectedSourceHead = $workspaceContext.Head
        TargetBranches = @{ '.' = 'main' }
        WhatIf = $true
    }
    Assert-Equal 'ContextAuthorityMismatch' $overriddenIntegration.error.code 'git.integrate rejects an explicit target override from the primary Context'

    $legalIntegration = Invoke-Harness -Command 'git.integrate' -Context $fixturePrimaryContext -Parameters @{
        SourceWorkspaceRoot = $fixtureWorkspace
        ExpectedSourceHead = $workspaceContext.Head
        TargetBranches = @{ '.' = 'main' }
        WhatIf = $true
    }
    Assert-Equal 'Succeeded' $legalIntegration.status 'primary integration retains SourceWorkspaceRoot as its sole authorized different root'
    Assert-True $legalIntegration.data.Preview 'the legal integration authority fixture remains non-mutating'

    $fastStatus = Invoke-Harness -Command 'workspace.status' -Context $workspaceContext
    Assert-Equal 'Succeeded' $fastStatus.status 'fast workspace status succeeds for an arbitrary registered worktree'
    Assert-Equal 'Fast' $fastStatus.data.DetailLevel 'workspace status defaults to the fast tier'
    Assert-True ('Changes' -notin @($fastStatus.data.PSObject.Properties.Name)) 'fast status does not perform a dirty-state scan'
    $detailedStatus = Invoke-Harness -Command 'workspace.status' -Context $workspaceContext -Parameters @{ Detailed = $true }
    Assert-Equal 'Succeeded' $detailedStatus.status 'detailed workspace status is an explicit route option'
    Assert-Equal 'Detailed' $detailedStatus.data.DetailLevel 'detailed status identifies its cost tier'
    Assert-True ('Changes' -in @($detailedStatus.data.PSObject.Properties.Name)) 'detailed status includes live dirty state'

    $workspaceList = Invoke-Harness -Command 'workspace.list' -Context $workspaceContext
    Assert-Equal 'Succeeded' $workspaceList.status 'workspace.list enumerates the selected common Git directory'
    Assert-Equal 2 @($workspaceList.data).Count 'workspace.list returns the primary and arbitrary linked worktree'
    Assert-True ($fixtureWorkspace -in @($workspaceList.data.WorkspaceRoot)) 'workspace.list preserves the actual external worktree path'

    $harnessStatus = Invoke-Harness -Command 'harness.status' -Context $workspaceContext
    Assert-Equal 'Succeeded' $harnessStatus.status 'harness.status provides a fast cross-client status surface'
    Assert-Equal $fixtureWorkspace $harnessStatus.data.Workspace.WorkspaceRoot 'harness.status stays bound to the selected workspace'
    Assert-True (-not $harnessStatus.data.DetailedScan) 'harness.status never opts into detailed repository scans'

    $observation = Invoke-Harness -Command 'harness.observe' -Context $workspaceContext -Parameters @{
        Category = 'Timing'
        Summary = 'Fixture status timing remained bounded.'
        Change = 'harness/refactor-unified-workspace-core'
        Stage = 'apply'
        DurationMs = 42
    }
    Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'non-Unreal routes must not import the Unreal leaf'
    Assert-Equal 'Succeeded' $observation.status 'harness.observe writes one ignored bounded record'
    Assert-Equal 1 @($observation.artifacts).Count 'observation path is exposed as an artifact'
    Assert-True (Test-Path -LiteralPath $observation.data.Path -PathType Leaf) 'observation file exists below the selected workspace'
    $observationRecord = Get-Content -LiteralPath $observation.data.Path -Raw | ConvertFrom-Json
    Assert-Equal 'harness-observation-v1' $observationRecord.schemaVersion 'observation records use a versioned schema'
    Assert-Equal $fixtureWorkspace $observationRecord.workspaceRoot 'observation records cannot drift to the harness checkout'
    Assert-Equal 42 $observationRecord.durationMs 'observation preserves an optional timing span'
    Assert-Equal 0 @((Invoke-FixtureGit -Repository $fixtureWorkspace -Arguments @('status', '--porcelain=v1')) | Where-Object { $_ -like '*Saved/Harness*' }).Count 'ignored observations never enter Git status'

    $evolution = Invoke-Harness -Command 'harness.evolution.status' -Context $workspaceContext
    Assert-Equal 'Succeeded' $evolution.status 'harness.evolution.status summarizes ignored evidence'
    Assert-Equal 1 $evolution.data.ObservationCount 'evolution status counts observation files without replaying bodies'
    Assert-True (-not $evolution.data.RawBodiesLoaded) 'evolution status reports that raw bodies were not loaded'

    $maintenance = Invoke-Harness -Command 'openspec.maintenance.status' -Context $context
    Assert-Equal 'Succeeded' $maintenance.status 'OpenSpec maintenance status is a read-only route'
    Assert-True ('RecordedCommit' -in @($maintenance.data.PSObject.Properties.Name)) 'maintenance status reports the parent gitlink'
    Assert-True ('PackagedSha256' -in @($maintenance.data.PSObject.Properties.Name)) 'maintenance status reports the actual package hash'
    Assert-True (-not $maintenance.data.Mutated) 'maintenance status never mutates source or package state'

    $unregisteredRoot = Join-Path $scratch 'unregistered-workspace'
    $unregisteredModuleDirectory = Join-Path $unregisteredRoot '.agents\\skills\\workspace-lifecycle\\scripts'
    [void](New-Item -ItemType Directory -Path $unregisteredModuleDirectory -Force)
    $unregisteredSentinel = Join-Path $scratch 'unregistered-leaf-imported.txt'
    $escapedSentinel = $unregisteredSentinel.Replace("'", "''")
    [System.IO.File]::WriteAllText((Join-Path $unregisteredModuleDirectory 'WorkspaceLifecycle.psm1'), "[System.IO.File]::WriteAllText('$escapedSentinel', 'imported')")
    Assert-Throws { New-HarnessContext -WorkspaceRoot $unregisteredRoot | Out-Null } 'Git|repository|registered|workspace' 'an unregistered path cannot become a Harness context'
    Assert-True (-not (Test-Path -LiteralPath $unregisteredSentinel)) 'target workspace content is never imported as harness code'

    $created = Invoke-Harness -Command 'workspace.new' -Context $fixturePrimaryContext -Parameters @{ Name = 'future-workspace' }
    Assert-Equal 'Succeeded' $created.status 'workspace.new creates an explicitly named workspace from the selected primary'
    Assert-Equal 'future-workspace' $created.data.Branch 'new workspace branch defaults exactly to Name'
    $createdContext = New-HarnessContext -WorkspaceRoot $created.data.WorktreeRoot
    $removePreview = Invoke-Harness -Command 'workspace.remove' -Context $createdContext -Parameters @{ WhatIf = $true; DiscardIgnoredFiles = $true }
    Assert-Equal 'Succeeded' $removePreview.status 'workspace.remove is explicitly previewable from the exact linked context'
    Assert-True (-not $removePreview.data.Removed) 'removal preview leaves the worktree registered'

    Push-Location $fixtureProject
    try {
        $callerLocation = (Get-Location).Path
        $nativeInit = Invoke-Harness -Command 'openspec.init' -Context $workspaceContext -ArgumentList @(
            '--project-id', 'harness-workspace-fixture',
            '--title', 'Harness Workspace Fixture'
        )
        Assert-Equal 'Succeeded' $nativeInit.status 'native mutation succeeds in the selected workspace'
        Assert-Equal $callerLocation (Get-Location).Path 'native mutation restores the caller location'
        Assert-True (Test-Path -LiteralPath (Join-Path $fixtureWorkspace 'openspec\\project.yaml') -PathType Leaf) 'native mutation writes inside WorkspaceRoot'
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $fixtureProject 'openspec'))) 'native mutation never writes into the primary checkout'
    }
    finally {
        Pop-Location
    }

    $focusedEvolutionTest = Join-Path $repoRoot '.agents\skills\harness\tests\HarnessEvolution.Tests.ps1'
    Assert-True (Test-Path -LiteralPath $focusedEvolutionTest -PathType Leaf) 'the exact evolution lifecycle is owned by the dedicated focused fixture'

    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'remove', '--force', $created.data.WorktreeRoot))
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'remove', '--force', $fixtureWorkspace))

    $incompleteHealth = Test-HarnessInstallation -ProjectRoot $fixtureProject
    Assert-True (-not $incompleteHealth.IsValid) 'installation fails when the required OpenSpec leaf is missing'
    Assert-Equal 1 @($incompleteHealth.Errors | Where-Object { $_ -match 'OpenSpec' }).Count 'the required OpenSpec package is reported as an error'

    $validFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-valid') -SourceRoot $repoRoot
    $validFixtureHealth = Test-HarnessInstallation -ProjectRoot $validFixture
    Assert-True $validFixtureHealth.IsValid 'a complete fixed OpenSpec 0.9.0 package passes installation health'
    Assert-Equal '0.9.0' $validFixtureHealth.OpenSpecPackage.Version 'health reports the verified final OpenSpec identity'
    Assert-True $validFixtureHealth.OpenSpecPackage.Verified 'health distinguishes a verified package from mere file presence'
    Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'installation validation checks the Unreal manifest without importing it'

    $missingUnrealFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-missing-unreal') -SourceRoot $repoRoot
    Remove-Item -LiteralPath (Join-Path $missingUnrealFixture '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1') -Force
    $missingUnrealHealth = Test-HarnessInstallation -ProjectRoot $missingUnrealFixture
    Assert-True (-not $missingUnrealHealth.IsValid) 'installation fails when the required Unreal leaf manifest is missing'
    Assert-Match (@($missingUnrealHealth.Errors) -join ' ') 'Unreal.*manifest|manifest.*Unreal' 'the missing Unreal manifest has a bounded diagnostic'
    Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'a missing Unreal manifest check does not import another Unreal module'

    $corruptFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-corrupt-exe') -SourceRoot $repoRoot
    [System.IO.File]::WriteAllBytes((Join-Path $corruptFixture '.agents\skills\openspec\bin\openspec.exe'), [byte[]](1, 2, 3, 4))
    $corruptHealth = Test-HarnessInstallation -ProjectRoot $corruptFixture
    Assert-True (-not $corruptHealth.IsValid) 'corrupt executable bytes never pass installation health'
    Assert-Match (@($corruptHealth.Errors) -join ' ') 'hash|identity|size' 'corrupt executable bytes fail a static identity check before execution'

    $wrongHashFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-wrong-hash') -SourceRoot $repoRoot
    Set-FixtureManifestValue -Root $wrongHashFixture -Name 'sha256' -Value ('f' * 64)
    $wrongHashHealth = Test-HarnessInstallation -ProjectRoot $wrongHashFixture
    Assert-True (-not $wrongHashHealth.IsValid) 'a manifest with the wrong executable hash is rejected'
    Assert-Match (@($wrongHashHealth.Errors) -join ' ') 'hash|identity' 'wrong manifest hash has a bounded package diagnostic'

    $wrongVersionFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-wrong-version') -SourceRoot $repoRoot
    Set-FixtureManifestValue -Root $wrongVersionFixture -Name 'version' -Value '0.8.0'
    $wrongVersionHealth = Test-HarnessInstallation -ProjectRoot $wrongVersionFixture
    Assert-True (-not $wrongVersionHealth.IsValid) 'a non-final manifest version is rejected'
    Assert-Match (@($wrongVersionHealth.Errors) -join ' ') 'version|identity' 'wrong manifest version has a bounded package diagnostic'

    $missingManifestFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-missing-manifest') -SourceRoot $repoRoot
    Remove-Item -LiteralPath (Join-Path $missingManifestFixture '.agents\skills\openspec\release-manifest.json') -Force
    $missingManifestHealth = Test-HarnessInstallation -ProjectRoot $missingManifestFixture
    Assert-True (-not $missingManifestHealth.IsValid) 'a package without a release manifest is rejected'
    Assert-Match (@($missingManifestHealth.Errors) -join ' ') 'manifest.*missing|missing.*manifest' 'missing manifest is reported explicitly'

    $schemaFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-invalid-manifest-schema') -SourceRoot $repoRoot
    $schemaManifestPath = Join-Path $schemaFixture '.agents\skills\openspec\release-manifest.json'
    $schemaManifest = Get-Content -LiteralPath $schemaManifestPath -Raw | ConvertFrom-Json
    $schemaManifest.PSObject.Properties.Remove('sourceTagType')
    [System.IO.File]::WriteAllText($schemaManifestPath, ($schemaManifest | ConvertTo-Json -Depth 20 -Compress), [System.Text.UTF8Encoding]::new($false))
    $schemaHealth = Test-HarnessInstallation -ProjectRoot $schemaFixture
    Assert-True (-not $schemaHealth.IsValid) 'an incomplete release-manifest schema is rejected'
    Assert-Match (@($schemaHealth.Errors) -join ' ') 'schema|sourceTagType' 'manifest schema mismatch identifies the missing field'

    $missingDocsFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-missing-docs') -SourceRoot $repoRoot
    Remove-Item -LiteralPath (Join-Path $missingDocsFixture '.agents\skills\openspec\commands') -Recurse -Force
    $missingDocsHealth = Test-HarnessInstallation -ProjectRoot $missingDocsFixture
    Assert-True (-not $missingDocsHealth.IsValid) 'a package without command docs is rejected'
    Assert-Match (@($missingDocsHealth.Errors) -join ' ') 'command doc|commands|missing' 'missing command docs are reported explicitly'

    $mismatchedDocsFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-mismatched-docs') -SourceRoot $repoRoot
    [System.IO.File]::AppendAllText((Join-Path $mismatchedDocsFixture '.agents\skills\openspec\commands\status.md'), "`nfixture mismatch`n")
    $mismatchedDocsHealth = Test-HarnessInstallation -ProjectRoot $mismatchedDocsFixture
    Assert-True (-not $mismatchedDocsHealth.IsValid) 'command docs that do not match the final digest are rejected'
    Assert-Match (@($mismatchedDocsHealth.Errors) -join ' ') 'digest|identity' 'command-doc mismatch has a bounded package diagnostic'

    $manifestDocsFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-manifest-docs') -SourceRoot $repoRoot
    Set-FixtureManifestValue -Root $manifestDocsFixture -Name 'commandDocsDigest' -Value ('e' * 64)
    $manifestDocsHealth = Test-HarnessInstallation -ProjectRoot $manifestDocsFixture
    Assert-True (-not $manifestDocsHealth.IsValid) 'a manifest with the wrong command-doc digest is rejected'
    Assert-Match (@($manifestDocsHealth.Errors) -join ' ') 'digest|identity' 'wrong manifest command-doc digest is reported'

    $health = Test-HarnessInstallation -ProjectRoot $repoRoot
    Assert-True $health.IsValid 'installation self-check succeeds'
    Assert-Equal 0 @($health.Errors).Count 'installation self-check reports no errors'
    Assert-Equal 0 @($health.Warnings).Count 'the installed harness has no missing required leaf warnings'
}
finally {
    Remove-Module Harness -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force
    }
}

Write-Output 'Harness.Tests.ps1: PASS'
