[CmdletBinding()]
param(
    [ValidateSet('All', 'Foundation', 'Discovery', 'RunLifecycle', 'RunLabels', 'Build', 'ExternalAdmission', 'ConcurrencyProgress', 'Automation', 'Suites', 'Integration')]
    [string] $Tag = 'All'
)

#Requires -Version 7.0
#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$previousUnrealTestMode = $env:HARNESS_UNREAL_TEST_MODE
$previousUnrealTestStateRoot = $env:HARNESS_UNREAL_TEST_STATE_ROOT
$previousUnrealLegacyTestStateRoot = $env:HARNESS_UNREAL_TEST_LEGACY_STATE_ROOT
$unrealTestStateRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-unreal-state-{0}" -f [guid]::NewGuid().ToString('N'))
$unrealLegacyTestStateRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-unreal-state-{0}" -f [guid]::NewGuid().ToString('N'))
$env:HARNESS_UNREAL_TEST_MODE = '1'
$env:HARNESS_UNREAL_TEST_STATE_ROOT = $unrealTestStateRoot
$env:HARNESS_UNREAL_TEST_LEGACY_STATE_ROOT = $unrealLegacyTestStateRoot

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string] $Message)
    if ($Expected -ne $Actual) {
        throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')"
    }
}

function Assert-Match {
    param([string] $Actual, [string] $Pattern, [string] $Message)
    if ($Actual -notmatch $Pattern) {
        throw "Assertion failed: $Message (actual '$Actual', pattern '$Pattern')"
    }
}

function Assert-Throws {
    param([scriptblock] $Action, [string] $Pattern, [string] $Message)
    try {
        & $Action
    }
    catch {
        Assert-Match -Actual $_.Exception.Message -Pattern $Pattern -Message $Message
        return
    }
    throw "Assertion failed: $Message (action did not throw)"
}

function Assert-SequenceEqual {
    param(
        [AllowEmptyCollection()][object[]] $Expected,
        [AllowEmptyCollection()][object[]] $Actual,
        [string] $Message
    )
    $expectedValues = @($Expected | ForEach-Object { [string] $_ })
    $actualValues = @($Actual | ForEach-Object { [string] $_ })
    if ($expectedValues.Count -ne $actualValues.Count) {
        throw "Assertion failed: $Message (expected $($expectedValues.Count) values, actual $($actualValues.Count): $($actualValues -join ' | '))"
    }
    for ($index = 0; $index -lt $expectedValues.Count; $index++) {
        if ($expectedValues[$index] -cne $actualValues[$index]) {
            throw "Assertion failed: $Message (index $index expected '$($expectedValues[$index])', actual '$($actualValues[$index])')"
        }
    }
}

function Test-Selected {
    param([string] $Name)
    return $Tag -eq 'All' -or $Tag -eq $Name
}

function Invoke-TestGit {
    param([Parameter(Mandatory = $true)][string] $Repository, [Parameter(Mandatory = $true)][string[]] $Arguments)
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
    return @($output | ForEach-Object { [string] $_ })
}

function New-UnrealTestFixture {
    param([Parameter(Mandatory = $true)][string] $Parent)

    $workspace = Join-Path $Parent 'workspace'
    $engine = Join-Path $Parent 'engine'
    foreach ($directory in @(
        $workspace
        (Join-Path $workspace 'Source')
        (Join-Path $engine 'Engine/Build')
        (Join-Path $engine 'Engine/Source')
        (Join-Path $engine 'Engine/Binaries/DotNET/UnrealBuildTool')
        (Join-Path $engine 'Engine/Binaries/ThirdParty/DotNet/10.0/win-x64')
        (Join-Path $engine 'Engine/Binaries/Win64')
    )) {
        [void][System.IO.Directory]::CreateDirectory($directory)
    }

    [void](Invoke-TestGit -Repository $workspace -Arguments @('init', '-b', 'main'))
    [System.IO.File]::WriteAllText((Join-Path $workspace '.gitignore'), "AgentConfig.ini`nSaved/`n", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $workspace 'Fixture.uproject'), "{}`n", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $workspace 'Source/FixtureEditor.Target.cs'), "public class FixtureEditorTarget {}`n", [System.Text.UTF8Encoding]::new($false))
    [void](Invoke-TestGit -Repository $workspace -Arguments @('add', '--', '.gitignore', 'Fixture.uproject', 'Source/FixtureEditor.Target.cs'))
    [void](Invoke-TestGit -Repository $workspace -Arguments @('-c', 'user.name=Harness Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-m', 'fixture'))

    [System.IO.File]::WriteAllText((Join-Path $engine 'Engine/Build/InstalledBuild.txt'), 'Fixture', [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $engine 'Engine/Build/Build.version'), '{"MajorVersion":5,"MinorVersion":8,"PatchVersion":0}', [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $engine 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.runtimeconfig.json'), '{"runtimeOptions":{"tfm":"net10.0","framework":{"name":"Microsoft.NETCore.App","version":"10.0.0"}}}', [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllBytes((Join-Path $engine 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll'), [byte[]] (1, 2, 3))
    [System.IO.File]::WriteAllBytes((Join-Path $engine 'Engine/Binaries/ThirdParty/DotNet/10.0/win-x64/dotnet.exe'), [byte[]] (1, 2, 3))
    [System.IO.File]::WriteAllBytes((Join-Path $engine 'Engine/Binaries/Win64/UnrealEditor-Cmd.exe'), [byte[]] (1, 2, 3))

    $projectFile = Join-Path $workspace 'Fixture.uproject'
    $commonDirectory = (Resolve-Path (Join-Path $workspace '.git')).Path
    $agentConfig = @"
[Build]
Architecture=x64
Configuration=Development
DefaultTimeoutMs=120000
EditorTarget=FixtureEditor
Platform=Win64

[Paths]
EngineRoot=$engine
ProjectFile=$projectFile

[Test]
DefaultTimeoutMs=120000

[Harness]
SchemaVersion=3
WorkspaceRoot=$workspace
PrimaryRoot=$workspace
GitCommonDir=$commonDirectory
"@
    [System.IO.File]::WriteAllText((Join-Path $workspace 'AgentConfig.ini'), $agentConfig, [System.Text.UTF8Encoding]::new($false))

    return [pscustomobject]@{
        WorkspaceRoot = $workspace
        EngineRoot    = $engine
        ProjectFile   = $projectFile
    }
}

$skillRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$manifestPath = Join-Path $skillRoot 'scripts/UnrealEngineDevelop.psd1'
$modulePath = Join-Path $skillRoot 'scripts/UnrealEngineDevelop.psm1'
$workerPath = Join-Path $skillRoot 'scripts/Invoke-UnrealRunWorker.ps1'

if (Test-Selected 'Foundation') {
    Assert-True (Test-Path -LiteralPath $manifestPath -PathType Leaf) 'the Unreal module manifest must exist'
    Assert-True (Test-Path -LiteralPath $modulePath -PathType Leaf) 'the Unreal root module must exist'
    Assert-True (Test-Path -LiteralPath $workerPath -PathType Leaf) 'the internal worker boundary must exist'

    $moduleFiles = @(
        Get-ChildItem -LiteralPath (Join-Path $skillRoot 'scripts/Private') -Filter '*.ps1' -File -ErrorAction Stop
        Get-Item -LiteralPath $modulePath
        Get-Item -LiteralPath $workerPath
    )
    foreach ($file in $moduleFiles) {
        $tokens = $null
        $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $tokens, [ref] $errors)
        Assert-Equal 0 @($errors).Count "$($file.Name) must parse under PowerShell 7"
        $text = Get-Content -LiteralPath $file.FullName -Raw
        Assert-True ($text -notmatch '(?i)\bpowershell\.exe\b') "$($file.Name) must not launch Windows PowerShell"
        Assert-True ($text -notmatch '(?i)(?:^|[\\/])Tools[\\/].*\.ps1') "$($file.Name) must not depend on root Tools scripts"
    }

    $manifest = Test-ModuleManifest -Path $manifestPath
    Assert-Equal '7.0' ([string] $manifest.PowerShellVersion) 'the manifest requires PowerShell 7'
    Assert-Equal 'Core' (@($manifest.CompatiblePSEditions) -join '|') 'the manifest supports only Core'

    $expectedFunctions = @(
        'Get-HarnessUnrealStatus'
        'Get-HarnessUnrealEngineList'
        'Get-HarnessUnrealTargetList'
        'Get-HarnessUnrealProcessList'
        'Get-HarnessUnrealUbtCapabilities'
        'Invoke-HarnessUnrealUbt'
        'Invoke-HarnessUnrealBuild'
        'Invoke-HarnessUnrealTest'
        'Get-HarnessUnrealSuiteList'
        'New-HarnessUnrealSuitePlan'
        'Invoke-HarnessUnrealSuite'
        'Invoke-HarnessUnrealCommandlet'
        'Get-HarnessUnrealRunStatus'
        'Stop-HarnessUnrealRun'
    )

    $scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("unreal-module-import-{0}" -f [guid]::NewGuid().ToString('N'))
    [void](New-Item -ItemType Directory -Path $scratch)
    try {
        Push-Location $scratch
        try {
            Import-Module $manifestPath -Force
            Assert-Equal 0 @(Get-ChildItem -LiteralPath $scratch -Force).Count 'module import must not write to the caller directory'
        }
        finally {
            Pop-Location
        }
        $actualFunctions = @((Get-Module UnrealEngineDevelop).ExportedFunctions.Keys | Sort-Object)
        Assert-Equal (($expectedFunctions | Sort-Object) -join '|') ($actualFunctions -join '|') 'the public Unreal API is exact'

        $fixture = New-UnrealTestFixture -Parent (Join-Path $scratch 'fixture')
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $configuration = & $module { param($Root) Get-UnrealWorkspaceConfiguration -WorkspaceRoot $Root } $fixture.WorkspaceRoot
        Assert-Equal $fixture.WorkspaceRoot $configuration.WorkspaceRoot 'fixture configuration keeps the exact workspace root'
        Assert-Equal $fixture.EngineRoot $configuration.EngineRoot 'fixture configuration projects the workspace-owned engine root'
        Assert-Equal $fixture.ProjectFile $configuration.ProjectFile 'fixture configuration projects the root project file'
    }
    finally {
        Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $scratch) {
            Remove-Item -LiteralPath $scratch -Recurse -Force
        }
    }

    $capabilities = Get-Content -LiteralPath (Join-Path $skillRoot 'data/ubt-capabilities.json') -Raw | ConvertFrom-Json
    Assert-Equal 'harness-ubt-capabilities' $capabilities.schemaVersion 'UBT capability data uses its stable schema name'
    Assert-True (@($capabilities.capabilities).Count -ge 3) 'UBT capability catalog is not empty'
    foreach ($capability in @($capabilities.capabilities)) {
        Assert-True (-not [string]::IsNullOrWhiteSpace([string] $capability.id)) 'every UBT capability has an id'
        Assert-True ($capability.requiresEngineLease -eq $true) 'every maintained UBT capability requires the engine lease'
    }

    $profiles = Get-Content -LiteralPath (Join-Path $skillRoot 'data/launch-profiles.json') -Raw | ConvertFrom-Json
    Assert-Equal 'harness-unreal-launch-profiles' $profiles.schemaVersion 'launch-profile data uses its stable schema name'
    Assert-True (@($profiles.profiles.name) -contains 'headless') 'the default headless profile exists'
}

if ($Tag -ne 'Foundation') {
    Assert-True (Test-Path -LiteralPath $manifestPath -PathType Leaf) 'later tags require the Unreal module foundation'
    Import-Module $manifestPath -Force
}

$scenarioScratch = $null
$scenarioFixture = $null
if ($Tag -ne 'Foundation') {
    $scenarioScratch = Join-Path ([System.IO.Path]::GetTempPath()) ("unreal-scenarios-{0}" -f [guid]::NewGuid().ToString('N'))
    [void](New-Item -ItemType Directory -Path $scenarioScratch)
    $scenarioFixture = New-UnrealTestFixture -Parent $scenarioScratch
}

try {
    if (Test-Selected 'RunLabels') {
        $labelledBuildPlan = Invoke-HarnessUnrealBuild `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Label '  lexer-red  ' `
            -PlanOnly
        Assert-Equal 'lexer-red' $labelledBuildPlan.Label 'a caller-defined build label is trimmed and exposed by PlanOnly'
        Assert-Equal 'lexer-red' $labelledBuildPlan.Request.label 'the effective build label is retained by the run request'
        Assert-Match ([System.IO.Path]::GetFileName($labelledBuildPlan.Paths.RunRoot)) '^[a-f0-9]{32}$' 'the run directory remains keyed only by RunId'
        Assert-True (@($labelledBuildPlan.Arguments | Where-Object { [string] $_ -match 'lexer-red' }).Count -eq 0) 'display labels never enter native build arguments'

        $defaultBuildPlan = Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Label '   ' -PlanOnly
        Assert-Equal 'FixtureEditor' $defaultBuildPlan.Label 'a blank build label preserves the existing target-derived default'

        $unicodeBuildPlan = Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Label '  词法分析 RED  ' -PlanOnly
        Assert-Equal '词法分析 RED' $unicodeBuildPlan.Label 'a readable Unicode build label is preserved after trimming'

        $ubtPlan = Invoke-HarnessUnrealUbt `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Capability query-targets `
            -Label '  target-query  ' `
            -PlanOnly
        $testPlan = Invoke-HarnessUnrealTest `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -TestPrefix 'Angelscript.UnitTest.Parser' `
            -Label '  parser-green  ' `
            -PlanOnly
        $commandletPlan = Invoke-HarnessUnrealCommandlet `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Commandlet BlueprintImpact `
            -Label '  ast-dump  ' `
            -PlanOnly
        Assert-Equal 'target-query' $ubtPlan.Label 'generic UBT exposes the normalized caller label'
        Assert-Equal 'parser-green' $testPlan.Label 'Automation exposes the normalized caller label'
        Assert-Equal 'ast-dump' $commandletPlan.Label 'commandlet execution exposes the normalized caller label'
        Assert-Equal 'query-targets' (Invoke-HarnessUnrealUbt -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Capability query-targets -Label ' ' -PlanOnly).Label 'generic UBT retains its capability-derived default label'
        Assert-Equal 'Angelscript.UnitTest.Parser' (Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.UnitTest.Parser' -Label ' ' -PlanOnly).Label 'Automation retains its selection-derived default label'
        Assert-Equal 'BlueprintImpact' (Invoke-HarnessUnrealCommandlet -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Commandlet BlueprintImpact -Label ' ' -PlanOnly).Label 'commandlets retain their name-derived default label'

        $runsRoot = Join-Path $scenarioFixture.WorkspaceRoot 'Saved/Harness/Unreal/Runs'
        $runCountBeforeInvalid = if (Test-Path -LiteralPath $runsRoot) { @(Get-ChildItem -LiteralPath $runsRoot -Directory).Count } else { 0 }
        Assert-Throws {
            Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Label (('x' * 128) + 'y') -PlanOnly
        } '128|label' 'labels longer than 128 UTF-16 code units are rejected'
        Assert-Throws {
            Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Label "bad`nlabel" -PlanOnly
        } 'control|label' 'labels containing control characters are rejected'
        $runCountAfterInvalid = if (Test-Path -LiteralPath $runsRoot) { @(Get-ChildItem -LiteralPath $runsRoot -Directory).Count } else { 0 }
        Assert-Equal $runCountBeforeInvalid $runCountAfterInvalid 'invalid labels create no run directory'

        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $statusRequest = & $module {
            param($Workspace, $Engine, $Project, $Executable)
            New-UnrealRunRequest `
                -WorkspaceRoot $Workspace `
                -EngineRoot $Engine `
                -ProjectFile $Project `
                -Operation Test `
                -FilePath $Executable `
                -Arguments @('-NoProfile', '-Command', "Write-Output 'label-status'") `
                -WorkingDirectory $Workspace `
                -TimeoutMs 10000 `
                -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') }) `
                -Label 'status-green'
        } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe')
        $statusRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $statusRequest
        Assert-Equal 'Succeeded' $statusRun.State 'the labelled status fixture reaches a terminal success'
        Assert-Equal 'status-green' $statusRun.Label 'run status exposes the persisted effective label'
        $statusMetadata = Get-Content -LiteralPath $statusRun.MetadataPath -Raw | ConvertFrom-Json -Depth 100
        Assert-Equal 'status-green' $statusMetadata.label 'new run metadata copies the effective request label'
        [void] $statusMetadata.PSObject.Properties.Remove('label')
        [System.IO.File]::WriteAllText($statusRun.MetadataPath, ($statusMetadata | ConvertTo-Json -Depth 100), [System.Text.UTF8Encoding]::new($false))
        $historicalStatus = Get-HarnessUnrealRunStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $statusRun.RunId
        Assert-Equal 'status-green' $historicalStatus.Label 'historical metadata falls back to its contained request label'

        $processRequest = & $module { param($Request) Set-UnrealRunExecutionAssignment -Request $Request } $labelledBuildPlan.Request
        $processMapping = & $module {
            param($Execution, $RunId)
            Enter-UnrealExecutionDriveMapping -Execution $Execution -RunId $RunId
        } $processRequest.execution $processRequest.runId
        try {
            [void][System.IO.Directory]::CreateDirectory($processRequest.paths.RunRoot)
            [System.IO.File]::WriteAllText($processRequest.paths.UbtLogPath, "[1/2] Compile LabelFixture.cpp`n", [System.Text.UTF8Encoding]::new($false))
            $processMetadata = & $module { param($Request) New-UnrealRunMetadata -Request $Request } $processRequest
            $processMetadata.state = 'Running'
            $processMetadata.workerPid = $PID
            $processMetadata.nativePid = 4242
            & $module {
                param($Request, $Metadata)
                Write-UnrealJsonFileAtomic -Path $Request.paths.RequestPath -Value $Request
                Write-UnrealJsonFileAtomic -Path $Request.paths.MetadataPath -Value $Metadata
            } $processRequest $processMetadata
            $commandLine = 'dotnet.exe "{0}" FixtureEditor Win64 Development "-Project={1}" -NoMutex "-Log={2}"' -f `
                (Join-Path $scenarioFixture.EngineRoot 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll'), `
                $processRequest.execution.projectFile, `
                $processRequest.executionPaths.UbtLogPath
            $processView = & $module {
                param($Id, $Executable, $CommandLine)
                ConvertTo-UnrealProcessView -ProcessId $Id -Name dotnet -Executable $Executable -CommandLine $CommandLine
            } 4242 $scenarioFixture.EngineRoot $commandLine
            Assert-True $processView.RecognizedBuild 'the contained labelled build is recognized from trusted run evidence'
            Assert-Equal 'lexer-red' $processView.Label 'recognized build observation exposes the trusted request label'
        }
        finally {
            & $module {
                param($Mapping, $RunId)
                Exit-UnrealExecutionDriveMapping -Mapping $Mapping -RunId $RunId
            } $processMapping $processRequest.runId
        }
    }
    if (Test-Selected 'Discovery') {
        $currentAssignmentPath = Join-Path $unrealTestStateRoot 'DriveAssignments.json'
        $legacyAssignmentPath = Join-Path $unrealLegacyTestStateRoot 'DriveAssignments.json'
        [void][System.IO.Directory]::CreateDirectory($unrealLegacyTestStateRoot)
        $legacyAssignmentBytes = [System.Text.UTF8Encoding]::new($false).GetBytes('{"schemaVersion":"hardness-unreal-drive-assignments","assignments":[]}')
        [System.IO.File]::WriteAllBytes($legacyAssignmentPath, $legacyAssignmentBytes)

        [void](Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -PlanOnly)
        Assert-True (Test-Path -LiteralPath $legacyAssignmentPath -PathType Leaf) 'PlanOnly leaves the legacy registry in place'
        Assert-True (-not (Test-Path -LiteralPath $currentAssignmentPath)) 'PlanOnly does not create or migrate the Harness registry'
        Assert-Equal ([Convert]::ToBase64String($legacyAssignmentBytes)) ([Convert]::ToBase64String([System.IO.File]::ReadAllBytes($legacyAssignmentPath))) 'PlanOnly leaves the legacy registry byte-for-byte unchanged'

        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        [void](& $module {
            param($WorkspaceRoot, $ProjectFile, $GitCommonDir)
            Get-UnrealExecutionPath -WorkspaceRoot $WorkspaceRoot -ProjectFile $ProjectFile -GitCommonDir $GitCommonDir -RunId ([guid]::NewGuid().ToString('N')) -Assign
        } $scenarioFixture.WorkspaceRoot $scenarioFixture.ProjectFile (Join-Path $scenarioFixture.WorkspaceRoot '.git'))
        Assert-True (-not (Test-Path -LiteralPath $legacyAssignmentPath)) 'the first real registry-dependent operation moves the lone legacy registry'
        Assert-True (Test-Path -LiteralPath $currentAssignmentPath -PathType Leaf) 'the first real operation materializes the current Harness registry'
        $migratedAssignment = Get-Content -LiteralPath $currentAssignmentPath -Raw | ConvertFrom-Json
        Assert-Equal 'harness-unreal-drive-assignments' $migratedAssignment.schemaVersion 'the real operation rewrites the migrated payload with the current schema'

        [System.IO.File]::WriteAllBytes($legacyAssignmentPath, $legacyAssignmentBytes)
        $currentBeforeRegistryConflict = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($currentAssignmentPath))
        Assert-Throws {
            & $module {
                param($WorkspaceRoot, $ProjectFile, $GitCommonDir)
                Get-UnrealExecutionPath -WorkspaceRoot $WorkspaceRoot -ProjectFile $ProjectFile -GitCommonDir $GitCommonDir -RunId ([guid]::NewGuid().ToString('N')) -Assign
            } $scenarioFixture.WorkspaceRoot $scenarioFixture.ProjectFile (Join-Path $scenarioFixture.WorkspaceRoot '.git') | Out-Null
        } 'legacy.*current|current.*legacy|conflict' 'conflicting legacy and current registries fail closed'
        Assert-Equal $currentBeforeRegistryConflict ([Convert]::ToBase64String([System.IO.File]::ReadAllBytes($currentAssignmentPath))) 'registry conflict does not overwrite the current file'
        Assert-Equal ([Convert]::ToBase64String($legacyAssignmentBytes)) ([Convert]::ToBase64String([System.IO.File]::ReadAllBytes($legacyAssignmentPath))) 'registry conflict does not overwrite the legacy file'
        Remove-Item -LiteralPath $legacyAssignmentPath -Force
        Remove-Item -LiteralPath $currentAssignmentPath -Force

        $status = Get-HarnessUnrealStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot
        Assert-True $status.Ready 'fixture Unreal status is ready'
        Assert-Equal 'Installed' $status.Engine.Kind 'InstalledBuild marker is authoritative'
        Assert-Equal '5.8.0' $status.Engine.Version 'Build.version is reported'
        Assert-Equal '10.0' $status.Engine.DotNet.VersionDirectory 'runtimeconfig selects the bundled major.minor directory'
        Assert-Equal (Join-Path $scenarioFixture.EngineRoot 'Engine/Binaries/ThirdParty/DotNet/10.0/win-x64/dotnet.exe') $status.Engine.DotNet.Executable 'bundled dotnet is selected without a fixed SDK patch'
        Assert-Equal 'DosDevice' $status.Execution.Strategy 'Windows Unreal execution uses a transient DOS-device view'
        Assert-Equal 'Proposed' $status.Execution.AssignmentState 'read-only status proposes an execution drive without assigning it'
        Assert-Match $status.ExecutionPath '^[G-Z]:\\$' 'read-only status exposes a short execution root'
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $unrealTestStateRoot 'DriveAssignments.json'))) 'read-only status does not create the assignment registry'

        $engines = @(Get-HarnessUnrealEngineList -WorkspaceRoot $scenarioFixture.WorkspaceRoot)
        $configured = @($engines | Where-Object { $_.Configured })
        Assert-Equal 1 $configured.Count 'configured EngineRoot appears exactly once in engine discovery'
        Assert-Equal $scenarioFixture.EngineRoot $configured[0].EngineRoot 'configured EngineRoot remains authoritative'

        $targets = @(Get-HarnessUnrealTargetList -WorkspaceRoot $scenarioFixture.WorkspaceRoot)
        Assert-Equal 1 $targets.Count 'source target discovery returns the fixture target once'
        Assert-Equal 'FixtureEditor' $targets[0].Name 'Target.cs class name is normalized'
        Assert-Equal 'Editor' $targets[0].Type 'Editor target type is inferred'
        Assert-Equal 'SourceScan' $targets[0].Source 'default target discovery does not launch UBT'

        $capabilities = Get-HarnessUnrealUbtCapabilities -WorkspaceRoot $scenarioFixture.WorkspaceRoot
        Assert-True (@($capabilities.capabilities | Where-Object { $_.id -eq 'query-targets' -and $_.available }).Count -eq 1) 'QueryTargets is a vetted UBT capability'
        Assert-True (@($capabilities.capabilities | Where-Object { $_.id -eq 'clean' -and -not $_.available }).Count -eq 1) 'destructive clean stays unavailable'

        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $installedBuildDecision = & $module {
            param($Root)
            Get-UnrealConcurrencyDecision -Operation Build -EngineRoot $Root -Policy Auto -InstalledEngine $true -TypedProjectBuild
        } $scenarioFixture.EngineRoot
        Assert-True $installedBuildDecision.RequiresEngineLease 'installed builds retain a Harness engine lane'
        Assert-Equal 'Shared' $installedBuildDecision.EngineLane 'ordinary installed builds select the shared engine lane'
        Assert-True (@($installedBuildDecision.UbtArguments) -notcontains '-WaitMutex') 'parallel installed builds do not request UBT WaitMutex'
        Assert-True (@($installedBuildDecision.UbtArguments) -contains '-NoEngineChanges') 'installed builds add NoEngineChanges as defense'
        Assert-True (@($installedBuildDecision.UbtArguments) -contains '-NoMutex') 'Harness supplies NoMutex for the controlled parallel lane'

        $sourceBuildDecision = & $module {
            param($Root)
            Get-UnrealConcurrencyDecision -Operation Build -EngineRoot $Root -Policy Auto -InstalledEngine $false -TypedProjectBuild
        } $scenarioFixture.EngineRoot
        Assert-True $sourceBuildDecision.RequiresEngineLease 'source builds serialize by EngineRoot'
        Assert-True (@($sourceBuildDecision.UbtArguments) -contains '-WaitMutex') 'source builds retain UBT WaitMutex'
        Assert-True (@($sourceBuildDecision.UbtArguments) -notcontains '-NoEngineChanges') 'source builds do not claim the installed-engine guard'

        $testDecision = & $module {
            param($Root)
            Get-UnrealConcurrencyDecision -Operation Test -EngineRoot $Root -Policy Auto -InstalledEngine $true
        } $scenarioFixture.EngineRoot
        Assert-True (-not $testDecision.RequiresEngineLease) 'non-UBT tests use only their exact workspace lease'
        Assert-Equal 'CrossWorkspaceNonUbt' $testDecision.Decision 'non-UBT cross-workspace eligibility is explicit'
    }
    if (Test-Selected 'RunLifecycle') {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $successArguments = @('-NoProfile', '-Command', "Write-Output 'fixture-success'")
        $successRequest = & $module {
            param($Workspace, $Engine, $Project, $Executable, $Arguments)
            New-UnrealRunRequest `
                -WorkspaceRoot $Workspace `
                -EngineRoot $Engine `
                -ProjectFile $Project `
                -Operation Test `
                -FilePath $Executable `
                -Arguments $Arguments `
                -WorkingDirectory $Workspace `
                -TimeoutMs 10000 `
                -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
        } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe') $successArguments
        Assert-True (& $module { Test-UnrealRunStateTransition -CurrentState Queued -NextState WaitingWorkspace }) 'Queued may advance to WaitingWorkspace'
        Assert-True (-not (& $module { Test-UnrealRunStateTransition -CurrentState Queued -NextState Running })) 'Queued may not skip directly to Running'
        Assert-True (& $module { Test-UnrealRunStateTransition -CurrentState WaitingWorkspace -NextState WaitingExecutionDrive }) 'workspace ownership advances to execution-drive ownership'
        Assert-True (& $module { Test-UnrealRunStateTransition -CurrentState WaitingExecutionDrive -NextState Running }) 'non-UBT execution advances from its drive lease to Running'
        Assert-True (& $module { Test-UnrealRunStateTransition -CurrentState Running -NextState Cancelled }) 'Running may terminate as Cancelled'
        $tamperedRequest = $successRequest | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $tamperedRequest.paths.LogPath = Join-Path $scenarioScratch 'escaped-command.log'
        Assert-Throws {
            & $module { param($Request) Start-UnrealRunRequest -Request $Request } $tamperedRequest
        } 'contained run directory' 'a tampered run evidence path is rejected before launch'
        Assert-True (-not (Test-Path -LiteralPath $successRequest.paths.RunRoot)) 'rejected request containment creates no run directory'
        $successTimer = [System.Diagnostics.Stopwatch]::StartNew()
        $success = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $successRequest
        $successTimer.Stop()
        Assert-Equal 'Succeeded' $success.State 'a native fake process reaches Succeeded'
        Assert-Equal 0 $success.ExitCode 'a successful native fake process preserves exit code zero'
        Assert-True ($successTimer.ElapsedMilliseconds -lt 10000) 'successful worker execution is bounded'
        Assert-True (Test-Path -LiteralPath $success.RequestPath -PathType Leaf) 'Request.json is retained'
        Assert-True (Test-Path -LiteralPath $success.LogPath -PathType Leaf) 'Command.log is retained'
        Assert-Match (Get-Content -LiteralPath $success.LogPath -Raw) 'fixture-success' 'stdout is streamed into bounded run evidence'
        $persistedSuccessRequest = Get-Content -LiteralPath $success.RequestPath -Raw | ConvertFrom-Json -Depth 100
        Assert-Equal 'harness-unreal-request' $persistedSuccessRequest.schemaVersion 'real runs persist the stable execution-path request schema'
        Assert-Equal 'Assigned' $persistedSuccessRequest.execution.assignmentState 'real runs assign a stable execution drive before request persistence'
        Assert-True ([string] $persistedSuccessRequest.execution.projectFile -like "$([string] $persistedSuccessRequest.execution.driveLetter)\*") 'the child project view is rooted on the assigned drive'
        $releasedTarget = & $module { param($Drive) Get-UnrealDosDeviceTarget -DriveLetter $Drive } ([string] $persistedSuccessRequest.execution.driveLetter)
        Assert-True ([string]::IsNullOrWhiteSpace([string] $releasedTarget)) 'worker completion removes the Harness-owned transient mapping'

        $foreignExecution = $persistedSuccessRequest.execution
        & $module {
            param($Drive, $RawTarget)
            Initialize-UnrealDosDeviceInterop
            [Harness.Unreal.Interop.DosDeviceNative]::Create($Drive, $RawTarget)
        } ([string] $foreignExecution.driveLetter) ([string] $foreignExecution.rawTarget)
        try {
            $foreignRequest = & $module {
                param($Workspace, $Engine, $Project, $Executable)
                New-UnrealRunRequest `
                    -WorkspaceRoot $Workspace `
                    -EngineRoot $Engine `
                    -ProjectFile $Project `
                    -Operation Test `
                    -FilePath $Executable `
                    -Arguments @('-NoProfile', '-Command', "Write-Output 'foreign-mapping'") `
                    -WorkingDirectory $Workspace `
                    -TimeoutMs 10000 `
                    -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
            } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe')
            $foreignRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $foreignRequest
            Assert-Equal 'Succeeded' $foreignRun.State 'an exact foreign mapping can be reused safely'
            Assert-Equal 'Foreign' $foreignRun.Execution.MappingState 'foreign mapping ownership remains explicit in terminal metadata'
            $foreignTarget = & $module { param($Drive) Get-UnrealDosDeviceTarget -DriveLetter $Drive } ([string] $foreignExecution.driveLetter)
            Assert-True (-not [string]::IsNullOrWhiteSpace([string] $foreignTarget)) 'worker completion preserves a matching foreign mapping'
        }
        finally {
            & $module {
                param($Drive, $RawTarget)
                Initialize-UnrealDosDeviceInterop
                [Harness.Unreal.Interop.DosDeviceNative]::RemoveExact($Drive, $RawTarget)
            } ([string] $foreignExecution.driveLetter) ([string] $foreignExecution.rawTarget)
        }

        $assignmentPath = Join-Path $unrealTestStateRoot 'DriveAssignments.json'
        $assignmentBeforeConflict = Get-Content -LiteralPath $assignmentPath -Raw
        $conflictingRawTarget = & $module { param($Root) ConvertTo-UnrealRawDosTarget -WorkspaceRoot $Root } $scenarioScratch
        & $module {
            param($Drive, $RawTarget)
            Initialize-UnrealDosDeviceInterop
            [Harness.Unreal.Interop.DosDeviceNative]::Create($Drive, $RawTarget)
        } ([string] $foreignExecution.driveLetter) $conflictingRawTarget
        try {
            $conflictPlan = Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -PlanOnly
            Assert-True ($conflictPlan.Execution.DriveLetter -cne [string] $foreignExecution.driveLetter) 'PlanOnly proposes another free drive when the stable drive has a foreign target'
            Assert-Equal 'Proposed' $conflictPlan.Execution.AssignmentState 'a conflict proposal does not rewrite the stable assignment'
            Assert-Equal $assignmentBeforeConflict (Get-Content -LiteralPath $assignmentPath -Raw) 'conflict planning leaves the assignment registry byte-for-byte unchanged'
            $reallocatedRequest = & $module {
                param($Workspace, $Engine, $Project, $Executable)
                New-UnrealRunRequest `
                    -WorkspaceRoot $Workspace `
                    -EngineRoot $Engine `
                    -ProjectFile $Project `
                    -Operation Test `
                    -FilePath $Executable `
                    -Arguments @('-NoProfile', '-Command', "Write-Output 'reallocated-mapping'") `
                    -WorkingDirectory $Workspace `
                    -TimeoutMs 10000 `
                    -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
            } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe')
            $reallocatedRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $reallocatedRequest
            Assert-Equal 'Succeeded' $reallocatedRun.State 'a real run reallocates before request persistence when the stable drive conflicts'
            $reallocatedPersisted = Get-Content -LiteralPath $reallocatedRun.RequestPath -Raw | ConvertFrom-Json -Depth 100
            Assert-True ([string] $reallocatedPersisted.execution.driveLetter -cne [string] $foreignExecution.driveLetter) 'the real request records the reallocated drive'
            $conflictingTargetAfterRun = & $module { param($Drive) Get-UnrealDosDeviceTarget -DriveLetter $Drive } ([string] $foreignExecution.driveLetter)
            $conflictPreserved = & $module { param($RawTarget, $Root) Test-UnrealDosDeviceTargetsWorkspace -RawTarget $RawTarget -WorkspaceRoot $Root } $conflictingTargetAfterRun $scenarioScratch
            Assert-True $conflictPreserved 'the reallocated run never removes the conflicting foreign drive'
        }
        finally {
            & $module {
                param($Drive, $RawTarget)
                Initialize-UnrealDosDeviceInterop
                [Harness.Unreal.Interop.DosDeviceNative]::RemoveExact($Drive, $RawTarget)
            } ([string] $foreignExecution.driveLetter) $conflictingRawTarget
        }

        $staleDrive = [string] $reallocatedPersisted.execution.driveLetter
        $staleRawTarget = [string] $reallocatedPersisted.execution.rawTarget
        & $module {
            param($Drive, $RawTarget, $AssignmentKey)
            Initialize-UnrealDosDeviceInterop
            [Harness.Unreal.Interop.DosDeviceNative]::Create($Drive, $RawTarget)
            $store = Read-UnrealDriveAssignmentStore
            $record = @($store.assignments | Where-Object { [string] $_.key -ceq $AssignmentKey } | Select-Object -First 1)
            if ($record.Count -ne 1) { throw 'stale recovery fixture assignment is missing' }
            $record[0].ownerRunId = [guid]::NewGuid().ToString('N')
            $record[0].ownerPid = 2147483647
            $record[0].mappingOwned = $true
            Write-UnrealDriveAssignmentStore -Store $store
        } $staleDrive $staleRawTarget ([string] $reallocatedPersisted.execution.assignmentKey)
        try {
            $stalePlan = Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -PlanOnly
            Assert-Equal 'StaleOwned' $stalePlan.Execution.MappingState 'PlanOnly identifies an abandoned exact Harness-owned mapping without mutating it'
            $staleRecoveryRequest = & $module {
                param($Workspace, $Engine, $Project, $Executable)
                New-UnrealRunRequest `
                    -WorkspaceRoot $Workspace `
                    -EngineRoot $Engine `
                    -ProjectFile $Project `
                    -Operation Test `
                    -FilePath $Executable `
                    -Arguments @('-NoProfile', '-Command', "Write-Output 'stale-recovery'") `
                    -WorkingDirectory $Workspace `
                    -TimeoutMs 10000 `
                    -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
            } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe')
            $staleRecoveryRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $staleRecoveryRequest
            Assert-Equal 'Succeeded' $staleRecoveryRun.State 'a later real run reclaims an abandoned owned mapping'
            $staleTargetAfterRun = & $module { param($Drive) Get-UnrealDosDeviceTarget -DriveLetter $Drive } $staleDrive
            Assert-True ([string]::IsNullOrWhiteSpace([string] $staleTargetAfterRun)) 'stale recovery leaves no owned mapping behind'
        }
        finally {
            & $module {
                param($Drive, $RawTarget, $Workspace)
                $current = Get-UnrealDosDeviceTarget -DriveLetter $Drive
                if (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $current -WorkspaceRoot $Workspace) {
                    Initialize-UnrealDosDeviceInterop
                    [Harness.Unreal.Interop.DosDeviceNative]::RemoveExact($Drive, $RawTarget)
                }
            } $staleDrive $staleRawTarget $scenarioFixture.WorkspaceRoot
        }

        $timeoutArguments = @('-NoProfile', '-Command', 'Start-Sleep -Seconds 10')
        $timeoutRequest = & $module {
            param($Workspace, $Engine, $Project, $Executable, $Arguments)
            New-UnrealRunRequest `
                -WorkspaceRoot $Workspace `
                -EngineRoot $Engine `
                -ProjectFile $Project `
                -Operation Test `
                -FilePath $Executable `
                -Arguments $Arguments `
                -WorkingDirectory $Workspace `
                -TimeoutMs 500 `
                -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
        } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe') $timeoutArguments
        $timeoutTimer = [System.Diagnostics.Stopwatch]::StartNew()
        $timedOut = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $timeoutRequest
        $timeoutTimer.Stop()
        Assert-Equal 'TimedOut' $timedOut.State 'a native fake process exceeding its budget reaches TimedOut'
        Assert-True ($timedOut.ExitCode -ne 0) 'timeout returns a non-zero result'
        Assert-True ($timeoutTimer.ElapsedMilliseconds -lt 8000) 'timeout terminates the native process tree within a bounded allowance'
        Assert-True ($null -eq (Get-Process -Id ([int] $timedOut.NativePid) -ErrorAction SilentlyContinue)) 'timeout leaves no native process behind'

        $cancelArguments = @('-NoProfile', '-Command', 'Start-Sleep -Seconds 30')
        $cancelRequest = & $module {
            param($Workspace, $Engine, $Project, $Executable, $Arguments)
            New-UnrealRunRequest `
                -WorkspaceRoot $Workspace `
                -EngineRoot $Engine `
                -ProjectFile $Project `
                -Operation Test `
                -FilePath $Executable `
                -Arguments $Arguments `
                -WorkingDirectory $Workspace `
                -TimeoutMs 30000 `
                -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Auto'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
        } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe') $cancelArguments
        $queued = & $module { param($Request) Start-UnrealRunRequest -Request $Request -NoWait } $cancelRequest
        $deadline = [DateTime]::UtcNow.AddSeconds(8)
        do {
            Start-Sleep -Milliseconds 100
            $running = Get-HarnessUnrealRunStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $queued.RunId
        } while ($running.State -notin @('Running', 'Failed', 'TimedOut') -and [DateTime]::UtcNow -lt $deadline)
        Assert-Equal 'Running' $running.State 'an asynchronous native fake process becomes observable as Running'
        $cancelTimer = [System.Diagnostics.Stopwatch]::StartNew()
        $cancelled = Stop-HarnessUnrealRun -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $queued.RunId -Confirm:$false
        $cancelTimer.Stop()
        Assert-Equal 'Cancelled' $cancelled.State 'explicit cancellation reaches Cancelled'
        Assert-True ($cancelled.ExitCode -ne 0) 'cancelled run returns a non-zero result'
        Assert-True ($cancelTimer.ElapsedMilliseconds -lt 5000) 'explicit cancellation is bounded'
        Assert-True ($null -eq (Get-Process -Id ([int] $running.WorkerPid) -ErrorAction SilentlyContinue)) 'cancellation leaves no worker process behind'
        Assert-True ($null -eq (Get-Process -Id ([int] $running.NativePid) -ErrorAction SilentlyContinue)) 'cancellation leaves no native process behind'
        $workspaceLeaseReleased = & $module {
            param($Workspace)
            $lease = Enter-UnrealLease -Scope 'workspace' -Key $Workspace -Policy Fail -TimeoutMs 1
            if ($null -eq $lease) { return $false }
            try { return $true }
            finally { Exit-UnrealLease -Lease $lease }
        } $scenarioFixture.WorkspaceRoot
        Assert-True $workspaceLeaseReleased 'cancellation releases the exact workspace lease'

        $orphanRequest = & $module {
            param($Workspace, $Engine, $Project, $Executable)
            New-UnrealRunRequest `
                -WorkspaceRoot $Workspace `
                -EngineRoot $Engine `
                -ProjectFile $Project `
                -Operation Test `
                -FilePath $Executable `
                -Arguments @('-NoProfile', '-Command', "Write-Output 'never-started'") `
                -WorkingDirectory $Workspace `
                -TimeoutMs 10000 `
                -ConcurrencyDecision ([pscustomobject]@{ Policy = 'Fail'; Decision = 'CrossWorkspaceNonUbt'; RequiresEngineLease = $false; Reasons = @('fixture') })
        } $scenarioFixture.WorkspaceRoot $scenarioFixture.EngineRoot $scenarioFixture.ProjectFile (Join-Path $PSHOME 'pwsh.exe')
        & $module {
            param($Request)
            [void][System.IO.Directory]::CreateDirectory([string] $Request.paths.RunRoot)
            Write-UnrealJsonFileAtomic -Path ([string] $Request.paths.RequestPath) -Value $Request
            $metadata = New-UnrealRunMetadata -Request $Request
            $metadata.state = 'Running'
            $metadata.workerPid = 2147483647
            Write-UnrealJsonFileAtomic -Path ([string] $Request.paths.MetadataPath) -Value $metadata
        } $orphanRequest
        $orphaned = Get-HarnessUnrealRunStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $orphanRequest.runId
        Assert-Equal 'Orphaned' $orphaned.State 'status infers Orphaned for a missing recorded worker'
        Assert-Equal 'Running' $orphaned.RecordedState 'orphan inference does not rewrite recorded state'
        & $module {
            param($Path, $CurrentPid)
            [void](Update-UnrealRunMetadata -Path $Path -Changes @{ workerPid = $CurrentPid; workerStartedAtUtc = '2000-01-01T00:00:00Z' })
        } $orphanRequest.paths.MetadataPath $PID
        $reused = Get-HarnessUnrealRunStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $orphanRequest.runId
        Assert-Equal 'Orphaned' $reused.State 'a reused live PID is not the recorded worker'
        & $module {
            param($Path, $CurrentPid)
            [void](Update-UnrealRunMetadata -Path $Path -Changes @{ workerPid = $CurrentPid })
        } $orphanRequest.paths.MetadataPath $PID
        Assert-Throws {
            Stop-HarnessUnrealRun -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $orphanRequest.runId -Confirm:$false
        } 'does not match run' 'cancellation refuses an unrelated live PID'
        Write-Output ("RunLifecycle timing: success={0}ms timeout={1}ms cancellation={2}ms" -f $successTimer.ElapsedMilliseconds, $timeoutTimer.ElapsedMilliseconds, $cancelTimer.ElapsedMilliseconds)
    }
    if (Test-Selected 'Build') {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $runsRoot = Join-Path $scenarioFixture.WorkspaceRoot 'Saved/Harness/Unreal/Runs'
        $dotNetRootBefore = [Environment]::GetEnvironmentVariable('DOTNET_ROOT', 'Process')
        $pathBefore = [Environment]::GetEnvironmentVariable('PATH', 'Process')
        $tempBefore = [Environment]::GetEnvironmentVariable('TEMP', 'Process')

        $installedPlan = Invoke-HarnessUnrealBuild `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -NoXge `
            -PlanOnly `
            -ExtraArguments @('-TraceWrites', '-Example=alpha beta')
        Assert-True $installedPlan.PlanOnly 'build PlanOnly is explicit'
        Assert-Equal 'Build' $installedPlan.Operation 'the typed build uses the Build operation'
        Assert-Equal 'FixtureEditor' $installedPlan.Target 'configured EditorTarget is normalized'
        Assert-Equal 'Win64' $installedPlan.Platform 'configured platform is normalized'
        Assert-Equal 'Development' $installedPlan.Configuration 'configured build configuration is normalized'
        Assert-Equal 'x64' $installedPlan.Architecture 'configured architecture is normalized'
        Assert-Equal 'Installed' $installedPlan.EngineKind 'installed layout is retained in the plan'
        Assert-Equal 120000 $installedPlan.TimeoutMs 'configured build timeout is selected'
        Assert-SequenceEqual -Expected @(
            (Join-Path $scenarioFixture.EngineRoot 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll')
            'FixtureEditor'
            'Win64'
            'Development'
            "-Project=$($installedPlan.ExecutionProjectFile)"
            '-architecture=x64'
            '-NoHotReload'
            '-NoHotReloadFromIDE'
            '-Progress'
            '-NoXGE'
            '-NoMutex'
            '-NoEngineChanges'
            '-TraceWrites'
            '-Example=alpha beta'
            "-Log=$($installedPlan.ExecutionPaths.UbtLogPath)"
        ) -Actual $installedPlan.Arguments -Message 'installed build arguments are exact and ordered'
        Assert-Equal (Split-Path -Parent $installedPlan.Executable) ([string] $installedPlan.Environment.DOTNET_ROOT) 'DOTNET_ROOT is child-local and follows the selected host'
        Assert-Equal $installedPlan.ExecutionPaths.TempPath ([string] $installedPlan.Environment.UnrealBuildTool_TMP) 'UBT temp uses the short per-run execution view'
        Assert-Equal $installedPlan.ExecutionPaths.TempPath ([string] $installedPlan.Environment.TMP) 'TMP uses the short per-run execution view'
        Assert-Equal $installedPlan.ExecutionPaths.TempPath ([string] $installedPlan.Environment.TEMP) 'TEMP uses the short per-run execution view'
        Assert-Equal '0' ([string] $installedPlan.Environment.DOTNET_MULTILEVEL_LOOKUP) 'bundled .NET multilevel lookup is disabled'
        Assert-Equal 'LatestMajor' ([string] $installedPlan.Environment.DOTNET_ROLL_FORWARD) 'bundled .NET roll-forward policy is explicit'
        Assert-Equal $dotNetRootBefore ([Environment]::GetEnvironmentVariable('DOTNET_ROOT', 'Process')) 'planning does not mutate parent DOTNET_ROOT'
        Assert-Equal $pathBefore ([Environment]::GetEnvironmentVariable('PATH', 'Process')) 'planning does not mutate parent PATH'
        Assert-Equal $tempBefore ([Environment]::GetEnvironmentVariable('TEMP', 'Process')) 'planning does not mutate parent TEMP'
        Assert-True (-not (Test-Path -LiteralPath $installedPlan.Paths.RunRoot)) 'PlanOnly creates no run directory'
        Assert-True (-not (Test-Path -LiteralPath $installedPlan.ExecutionPath)) 'PlanOnly does not create the proposed DOS-device mapping'
        Assert-Equal 'Parallel' $installedPlan.BuildConcurrency 'installed build Auto mode selects controlled parallelism'
        Assert-True (@($installedPlan.Arguments | Where-Object { $_ -ceq '-WaitMutex' }).Count -eq 0) 'parallel installed builds do not request WaitMutex'
        Assert-Equal 0 @($installedPlan.Arguments | Where-Object { $_ -match '(?i)^[-/]Session(?:=|:)' }).Count 'top-level typed builds do not impersonate recursive UBT sessions'
        Assert-Equal 0 @($installedPlan.Arguments | Where-Object { $_ -ceq '-NoUBA' }).Count 'typed builds preserve configured UBA policy'
        Assert-True (@($installedPlan.Arguments | Where-Object { $_ -ceq '-NoEngineChanges' }).Count -eq 1) 'installed NoEngineChanges appears exactly once'
        Assert-True (@($installedPlan.Arguments | Where-Object { $_ -match '(?i)^[-/]NoMutex(?:=|$)' }).Count -eq 1) 'Harness supplies NoMutex exactly once for the controlled parallel lane'

        $installedMarker = Join-Path $scenarioFixture.EngineRoot 'Engine/Build/InstalledBuild.txt'
        [System.IO.File]::Delete($installedMarker)
        try {
            $sourcePlan = Invoke-HarnessUnrealBuild `
                -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
                -Target FixtureGame `
                -Platform Win64 `
                -Configuration shipping `
                -Architecture arm64 `
                -TimeoutMs 30000 `
                -ConcurrencyPolicy Fail `
                -PlanOnly
            Assert-Equal 'Source' $sourcePlan.EngineKind 'source layout is detected after the installed marker is absent'
            Assert-Equal 'Shipping' $sourcePlan.Configuration 'configuration matching is canonical and case-insensitive'
            Assert-Equal 'arm64' $sourcePlan.Architecture 'an explicit safe architecture is preserved'
            Assert-Equal 'Fail' $sourcePlan.Concurrency.Policy 'explicit concurrency policy is retained'
            Assert-True (@($sourcePlan.Arguments) -contains '-WaitMutex') 'source builds retain WaitMutex'
            Assert-True (@($sourcePlan.Arguments) -notcontains '-NoEngineChanges') 'source builds do not claim the installed-engine guard'
            Assert-True (-not (Test-Path -LiteralPath $sourcePlan.Paths.RunRoot)) 'source PlanOnly creates no run directory'
        }
        finally {
            [System.IO.File]::WriteAllText($installedMarker, 'Fixture', [System.Text.UTF8Encoding]::new($false))
        }

        foreach ($unsafeArgument in @('-UniqueBuildEnvironment', '-UniqueBuildEnvironment=true', 'UniqueBuildEnvironment=true', '/NoMutex', '-NoUBA', '-Mode=Clean', 'Clean', '@unsafe.rsp', "/Log=$scenarioScratch/escape.log")) {
            Assert-Throws {
                Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -PlanOnly -ExtraArguments @($unsafeArgument)
            } 'unsafe|reserved|prohibited|destructive|response|ownership' "build rejects unsafe or policy-owned argument '$unsafeArgument'"
        }

        $queryPlan = Invoke-HarnessUnrealUbt `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Capability query-targets `
            -Arguments @('-SomeValue=alpha beta') `
            -TimeoutMs 45000 `
            -PlanOnly
        Assert-Equal 'QueryTargets' $queryPlan.Operation 'the vetted query capability has a dedicated operation'
        Assert-SequenceEqual -Expected @(
            (Join-Path $scenarioFixture.EngineRoot 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll')
            '-Mode=QueryTargets'
            "-Project=$($queryPlan.ExecutionProjectFile)"
            "-Output=$($queryPlan.ExecutionPaths.TargetsPath)"
            '-IncludeAllTargets'
            '-DontIncludeParentAssembly'
            '-WaitMutex'
            '-SomeValue=alpha beta'
            "-Log=$($queryPlan.ExecutionPaths.UbtLogPath)"
        ) -Actual $queryPlan.Arguments -Message 'QueryTargets arguments are exact, ordered, and retain caller boundaries'
        Assert-Equal 0 @($queryPlan.Arguments | Where-Object { $_ -match '(?i)^[-/]Session(?:=|:)' }).Count 'top-level QueryTargets does not impersonate a recursive UBT session'
        Assert-True (-not (Test-Path -LiteralPath $queryPlan.Paths.RunRoot)) 'generic UBT PlanOnly creates no run directory'
        $queryFixtureDirectory = Join-Path $scenarioFixture.WorkspaceRoot 'Saved/Harness/Unreal/QueryTargetsFixture'
        [void][System.IO.Directory]::CreateDirectory($queryFixtureDirectory)
        $queryFixturePath = Join-Path $queryFixtureDirectory 'Targets.json'
        $targetSourcePath = Join-Path $scenarioFixture.WorkspaceRoot 'Source/FixtureEditor.Target.cs'
        $relativeTargetSource = [System.IO.Path]::GetRelativePath($queryFixtureDirectory, $targetSourcePath)
        $queryFixtureDocument = [pscustomobject]@{
            Targets = @([pscustomobject]@{ Name = 'FixtureEditor'; Path = $relativeTargetSource; Type = 'Editor'; DefaultTarget = $true })
        }
        [System.IO.File]::WriteAllText($queryFixturePath, ($queryFixtureDocument | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
        $queriedTargets = @(& $module {
            param($Workspace, $Path)
            Read-UnrealUbtTargetList -WorkspaceRoot $Workspace -TargetsPath $Path
        } $scenarioFixture.WorkspaceRoot $queryFixturePath)
        Assert-Equal 1 $queriedTargets.Count 'bounded QueryTargets JSON is parsed once'
        Assert-Equal 'FixtureEditor' $queriedTargets[0].Name 'QueryTargets preserves the target name'
        Assert-Equal 'UbtQuery' $queriedTargets[0].Source 'QueryTargets records its authoritative source'
        Assert-Equal $targetSourcePath $queriedTargets[0].Path 'QueryTargets paths resolve relative to the output and stay in the workspace'
        Assert-True $queriedTargets[0].DefaultTarget 'QueryTargets retains the optional default-target marker'
        Assert-Throws {
            Invoke-HarnessUnrealUbt -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Capability clean -PlanOnly
        } 'unavailable|destructive' 'the destructive clean capability is unavailable'
        Assert-Throws {
            Invoke-HarnessUnrealUbt -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Capability arbitrary-mode -PlanOnly
        } 'unknown|not audited' 'unknown generic UBT capabilities are rejected'
        Assert-Throws {
            Invoke-HarnessUnrealUbt -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Capability query-targets -Arguments @('-Output=escape.json') -PlanOnly
        } 'reserved|unsafe' 'generic UBT cannot override managed output paths'

        $genericBuildPlan = Invoke-HarnessUnrealUbt `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Capability build `
            -Arguments @('FixtureEditor', 'Win64', 'Development') `
            -PlanOnly
        Assert-Equal 0 @($genericBuildPlan.Arguments | Where-Object { $_ -ceq '-NoUBA' }).Count 'generic builds preserve configured UBA policy'
        Assert-Equal 0 @($genericBuildPlan.Arguments | Where-Object { $_ -match '(?i)^[-/]Session(?:=|:)' }).Count 'top-level generic builds do not impersonate recursive UBT sessions'

        $nativeRequest = $installedPlan.Request | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $nativeRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $nativeRequest.arguments = @('-NoProfile', '-Command', "Write-Output 'fixture-build-success'")
        $nativeRequest.environment = [pscustomobject]@{}
        $nativeResult = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $nativeRequest
        Assert-Equal 'Succeeded' $nativeResult.State 'a fake native build request reaches Succeeded'
        Assert-Equal 'Build' $nativeResult.Operation 'fake native execution retains the Build operation'
        Assert-Match (Get-Content -LiteralPath $nativeResult.LogPath -Raw) 'fixture-build-success' 'fake native build output reaches run evidence'
    }
    if (Test-Selected 'ExternalAdmission') {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $failures = [Collections.Generic.List[string]]::new()
        $otherRoot = Join-Path $scenarioFixture.WorkspaceRoot 'different-workspace'
        [void][IO.Directory]::CreateDirectory($otherRoot)
        $otherProject = Join-Path $otherRoot 'Fixture.uproject'
        [IO.File]::WriteAllText($otherProject, '{}')
        $aliasRoot = Join-Path $scenarioScratch 'workspace-alias'
        [void](New-Item -ItemType Junction -Path $aliasRoot -Target $scenarioFixture.WorkspaceRoot)
        $aliasProject = Join-Path $aliasRoot 'Fixture.uproject'
        $externalDrive = & $module {
            param($Root)
            Initialize-UnrealDosDeviceInterop
            $drive = @('P:', 'Q:', 'R:', 'S:', 'T:') | Where-Object { [string]::IsNullOrEmpty((Get-UnrealDosDeviceTarget -DriveLetter $_)) } | Select-Object -First 1
            if (-not $drive) { throw 'No free drive for isolated external execution-alias fixture.' }
            $target = '\??\' + $Root
            [Harness.Unreal.Interop.DosDeviceNative]::Create($drive, $target)
            [pscustomobject]@{ Drive=$drive; Target=$target; Project=$drive+'\Fixture.uproject' }
        } $scenarioFixture.WorkspaceRoot
        try {
            & $module {
                param($Fixture, $OtherProject, $AliasProject, $MappedProject, $Failures)
                function Get-Process {
                    param($Id, $ErrorAction)
                    if ($null -ne $Id) { return Microsoft.PowerShell.Management\Get-Process -Id $Id -ErrorAction $ErrorAction }
                    if ($fixtureScan -eq 'Unreadable') { return [pscustomobject]@{ Id=4242; ProcessName='dotnet'; Path='C:\Fixture\dotnet.exe'; StartTime=[DateTime]::UtcNow } }
                    $fixtureState.Scans++
                    if ($fixtureState.Scans -gt 1 -and (Test-Path -LiteralPath $request.paths.MetadataPath)) {
                        $snapshot = Get-UnrealRunStatusRecord -WorkspaceRoot $Fixture.WorkspaceRoot -RunId $request.runId
                        if ($snapshot.State -eq 'WaitingExternalBuild' -and $snapshot.Message -match '4242') { $fixtureState.WaitObserved = $true }
                    }
                    if ($fixtureScan -eq 'GoneAfterWait' -and $fixtureState.Scans -gt 1) { return }
                    if ($fixtureScan -eq 'AppearsAfterEngine' -and -not $fixtureState.EngineAcquired) { return }
                    return [pscustomobject]@{ Id=4242; ProcessName=$fixtureProcessName; Path='C:\Fixture\dotnet.exe'; StartTime=[DateTime]::UtcNow }
                }
                function Get-CimInstance {
                    param($ClassName, $Filter, $ErrorAction)
                    [pscustomobject]@{ ProcessId=4242; CommandLine=$(if ($fixtureScan -eq 'Unreadable') { '' } else { $fixtureCommandLine }) }
                }
                $cases = @(
                    @{ Name='Fail refuses an already running same-workspace IDE UBT'; Project=$Fixture.ProjectFile; Policy='Fail'; Scan='Present'; State='Failed'; Launch=$false },
                    @{ Name='Wait times out without launching or killing external UBT'; Project=$Fixture.ProjectFile; Policy='Wait'; Scan='Present'; State='TimedOut'; Launch=$false; Timeout=450 },
                    @{ Name='Auto waits until the external build exits'; Project=$Fixture.ProjectFile; Policy='Auto'; Scan='GoneAfterWait'; State='Succeeded'; Launch=$true; MinScans=2 },
                    @{ Name='a distinct nested workspace stays eligible for parallel execution'; Project=$OtherProject; Policy='Fail'; Scan='Present'; State='Succeeded'; Launch=$true },
                    @{ Name='an actual filesystem alias cannot bypass exact project admission'; Project=$AliasProject; Policy='Fail'; Scan='Present'; State='Failed'; Launch=$false },
                    @{ Name='an external execution drive cannot bypass physical project admission'; Project=$MappedProject; Policy='Fail'; Scan='Present'; State='Failed'; Launch=$false },
                    @{ Name='a contender arriving during engine wait is rechecked before launch'; Project=$Fixture.ProjectFile; Policy='Fail'; Scan='AppearsAfterEngine'; State='Failed'; Launch=$false },
                    @{ Name='a failed command-line scan cannot claim safe admission'; Project=$Fixture.ProjectFile; Policy='Fail'; Scan='Unreadable'; State='Failed'; Launch=$false },
                    @{ Name='an open editor alone does not block a build'; Project=$Fixture.ProjectFile; Policy='Fail'; Scan='Present'; State='Succeeded'; Launch=$true; ProcessName='UnrealEditor' }
                )
                foreach ($case in $cases) {
                    $fixtureState = @{ Scans=0; Launched=$false; EngineAcquired=$false; Killed=$false; WaitObserved=$false }
                    $fixtureScan = $case.Scan
                    $fixtureProcessName = if ($case.ContainsKey('ProcessName')) { $case.ProcessName } else { 'dotnet' }
                    $fixtureCommandLine = if ($fixtureProcessName -eq 'UnrealEditor') { 'UnrealEditor.exe "' + $case.Project + '"' } else { 'dotnet C:\Fixture\UnrealBuildTool.dll FixtureEditor Win64 Development -Project="' + $case.Project + '" -WaitMutex -FromMsBuild -architecture=x64' }
                    $plan = Invoke-HarnessUnrealBuild -WorkspaceRoot $Fixture.WorkspaceRoot -ConcurrencyPolicy $case.Policy -TimeoutMs 10000 -PlanOnly
                    $request = Set-UnrealRunExecutionAssignment -Request $plan.Request
                    $request.timeoutMs = if ($case.ContainsKey('Timeout')) { $case.Timeout } else { 10000 }
                    $request.createdAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
                    [void][IO.Directory]::CreateDirectory($request.paths.TempPath)
                    Write-UnrealJsonFileAtomic -Path $request.paths.RequestPath -Value $request
                    Write-UnrealJsonFileAtomic -Path $request.paths.MetadataPath -Value (New-UnrealRunMetadata -Request $request)
                    # The external machine snapshot and native executable are boundaries;
                    # worker admission, path identity, leases, state and evidence stay real.
                    $enterEngine = ${function:Enter-UnrealEngineLane}
                    function Enter-UnrealEngineLane {
                        param($EngineRoot, $Mode, $Policy, $TimeoutMs)
                        $lease = & $enterEngine @PSBoundParameters
                        $fixtureState.EngineAcquired = $true
                        return $lease
                    }
                    function Invoke-UnrealNativeProcess {
                        param($Request, $MetadataPath)
                        $fixtureState.Launched = $true
                        [pscustomobject]@{ ExitCode=0; TimedOut=$false; DurationMs=1 }
                    }
                    function Stop-UnrealProcessTree { param($ProcessId) $fixtureState.Killed=$true; throw 'An external process must never be killed by admission.' }
                    try {
                        $result = Invoke-UnrealRequestWorker -RequestPath $request.paths.RequestPath
                        if ($result.state -ne $case.State -or $fixtureState.Launched -ne $case.Launch -or $fixtureState.Killed) { throw "state=$($result.state), launched=$($fixtureState.Launched), killed=$($fixtureState.Killed), message=$($result.message)" }
                        if ($case.ContainsKey('MinScans') -and ($fixtureState.Scans -lt $case.MinScans -or -not $fixtureState.WaitObserved)) { throw 'The native child launched without exposing the wait and observing the external build depart.' }
                        if ($case.State -ne 'Succeeded' -and $result.message -notmatch 'external|inspect|quiescence') { throw "No actionable admission reason: $($result.message)" }
                        Write-Output "PASS $($case.Name)"
                    }
                    catch { $Failures.Add("$($case.Name): $_"); Write-Output "FAIL $($case.Name): $_" }
                    finally { Set-Item Function:Enter-UnrealEngineLane $enterEngine }
                }
                try {
                    $view = ConvertTo-UnrealProcessView -ProcessId 4242 -Name dotnet -CommandLine ('dotnet C:\Fixture\UnrealBuildTool.dll FixtureEditor Win64 Development -Project="' + $Fixture.ProjectFile + '" -WaitMutex -architecture=x64')
                    if ($view.ProjectFile -ne $Fixture.ProjectFile -or $view.Target -ne 'FixtureEditor' -or $view.RecognizedBuild -or $view.Progress.ProgressKnown) { throw 'External basic identity is absent or is being promoted to trusted managed progress.' }
                    $fixtureScan='Present'; $fixtureProcessName='dotnet'; $fixtureCommandLine='dotnet C:\Fixture\UnrealBuildTool.dll FixtureEditor Win64 Development -Project="'+$OtherProject+'"'
                    $views = @(Get-HarnessUnrealProcessList -WorkspaceRoot $Fixture.WorkspaceRoot)
                    if ($views.Count -ne 1 -or $views[0].WorkspaceMatch) { throw 'A nested different workspace was matched by substring.' }
                    Write-Output 'PASS external basic identity remains useful without claiming trusted progress or substring workspace identity'
                }
                catch { $Failures.Add("external process identity: $_"); Write-Output "FAIL external process identity: $_" }
                try {
                    $plan = Invoke-HarnessUnrealBuild -WorkspaceRoot $Fixture.WorkspaceRoot -PlanOnly
                    $metadata = New-UnrealRunMetadata -Request $plan.Request
                    $metadata.state = 'WaitingExternalBuild'
                    $metadata.workerPid = 2147483647
                    Write-UnrealJsonFileAtomic -Path $plan.Paths.MetadataPath -Value $metadata
                    $orphan = Get-UnrealRunStatusRecord -WorkspaceRoot $Fixture.WorkspaceRoot -RunId $plan.RunId
                    if ($orphan.State -ne 'Orphaned' -or $orphan.RecordedState -ne 'WaitingExternalBuild') { throw 'A dead worker left external waiting indistinguishable from a live wait.' }
                    Write-Output 'PASS a dead worker in external wait is reported as Orphaned without rewriting its recorded state'
                }
                catch { $Failures.Add("external wait liveness: $_"); Write-Output "FAIL external wait liveness: $_" }
            } $scenarioFixture $otherProject $aliasProject $externalDrive.Project $failures
        }
        finally {
            [Harness.Unreal.Interop.DosDeviceNative]::RemoveExact($externalDrive.Drive, $externalDrive.Target)
            [IO.Directory]::Delete($aliasRoot) # Delete only this fixture junction, never its target.
        }
        if ($failures.Count -gt 0) { throw ($failures -join "`n") }
    }
    if (Test-Selected 'ConcurrencyProgress') {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop

        $parallelPlan = Invoke-HarnessUnrealBuild `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -BuildConcurrency Auto `
            -PlanOnly
        Assert-Equal 'Auto' $parallelPlan.RequestedBuildConcurrency 'the caller build-concurrency selection is retained'
        Assert-Equal 'Parallel' $parallelPlan.BuildConcurrency 'Auto selects the installed-project parallel lane'
        Assert-Equal 'ParallelInstalledProjectBuild' $parallelPlan.Concurrency.Decision 'the controlled installed-project decision is explicit'
        Assert-Equal 'Shared' $parallelPlan.Concurrency.EngineLane 'parallel builds occupy a shared engine lane'
        Assert-True $parallelPlan.Concurrency.RequiresEngineLease 'parallel builds still coordinate through Harness'
        Assert-True (@($parallelPlan.Arguments) -contains '-NoMutex') 'parallel builds use the UBT concurrency switch'
        Assert-True (@($parallelPlan.Arguments) -contains '-NoEngineChanges') 'parallel builds retain the installed-engine write guard'
        Assert-True (@($parallelPlan.Arguments) -notcontains '-WaitMutex') 'parallel builds do not request the exclusive UBT mutex'
        Assert-True (@($parallelPlan.Arguments) -notcontains '-NoUBA') 'the configured UBA policy remains unchanged for long-path acceptance'
        Assert-True (@($parallelPlan.Arguments) -notcontains '-NoXGE') 'XGE remains enabled unless the typed caller opts out explicitly'
        Assert-Equal $parallelPlan.ExecutionPaths.TempPath ([string] $parallelPlan.Environment.TEMP) 'parallel build TEMP uses the run-local execution view'
        Assert-True (@($parallelPlan.Arguments) -contains "-Log=$($parallelPlan.ExecutionPaths.UbtLogPath)") 'parallel build UBT log uses the run-local execution view'

        $serializePlan = Invoke-HarnessUnrealBuild `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -BuildConcurrency Serialize `
            -PlanOnly
        Assert-Equal 'Serialize' $serializePlan.BuildConcurrency 'Serialize remains explicit in the plan'
        Assert-Equal 'Exclusive' $serializePlan.Concurrency.EngineLane 'serialized builds occupy the exclusive engine lane'
        Assert-True (@($serializePlan.Arguments) -contains '-WaitMutex') 'serialized builds coordinate with external UBT'
        Assert-True (@($serializePlan.Arguments) -notcontains '-NoMutex') 'serialized builds do not bypass the UBT mutex'

        $installedMarker = Join-Path $scenarioFixture.EngineRoot 'Engine/Build/InstalledBuild.txt'
        [System.IO.File]::Delete($installedMarker)
        try {
            $sourceAutoPlan = Invoke-HarnessUnrealBuild `
                -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
                -BuildConcurrency Auto `
                -PlanOnly
            Assert-Equal 'Serialize' $sourceAutoPlan.BuildConcurrency 'Auto serializes a source-engine build'
            Assert-Equal 'Exclusive' $sourceAutoPlan.Concurrency.EngineLane 'source-engine builds use the exclusive engine lane'
            Assert-True (@($sourceAutoPlan.Arguments) -contains '-WaitMutex') 'source-engine builds retain WaitMutex'
            Assert-True (@($sourceAutoPlan.Arguments) -notcontains '-NoMutex') 'source-engine builds never enter the parallel lane'
            Assert-Throws {
                Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -BuildConcurrency Parallel -PlanOnly
            } 'installed.*project|Parallel' 'explicit Parallel is rejected for a source engine'
        }
        finally {
            [System.IO.File]::WriteAllText($installedMarker, 'Fixture', [System.Text.UTF8Encoding]::new($false))
        }

        $genericBuildPlan = Invoke-HarnessUnrealUbt `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Capability build `
            -Arguments @('FixtureEditor', 'Win64', 'Development') `
            -PlanOnly
        Assert-Equal 'SerializedEngineUbt' $genericBuildPlan.Concurrency.Decision 'generic UBT build remains conservative'
        Assert-Equal 'Exclusive' $genericBuildPlan.Concurrency.EngineLane 'generic UBT build uses the exclusive engine lane'
        Assert-True (@($genericBuildPlan.Arguments) -contains '-WaitMutex') 'generic UBT build retains WaitMutex'
        foreach ($ownedArgument in @('-NoMutex', '/WaitMutex', '-NoEngineChanges=true')) {
            Assert-Throws {
                Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -PlanOnly -ExtraArguments @($ownedArgument)
            } 'ownership|Harness.*owns|BuildConcurrency' "raw concurrency argument '$ownedArgument' is rejected as an ownership conflict"
        }

        [void][System.IO.Directory]::CreateDirectory($parallelPlan.Paths.RunRoot)
        $progressPrefix = 'x' * (600 * 1024)
        $progressText = $progressPrefix + "`n@progress 'Compiling C++ source code' 40%`n[12/30] Compile Module.Fixture.cpp`n[13/"
        [System.IO.File]::WriteAllText($parallelPlan.Paths.UbtLogPath, $progressText, [System.Text.UTF8Encoding]::new($false))
        $progress = & $module { param($Paths) Get-UnrealBuildProgressSnapshot -Paths $Paths } $parallelPlan.Paths
        Assert-True $progress.ProgressKnown 'recognized UBT progress is known'
        Assert-Equal 12 $progress.Current 'the last complete action numerator is retained'
        Assert-Equal 30 $progress.Total 'the last complete action denominator is retained'
        Assert-Equal 40 $progress.Percent 'action progress has a stable percentage'
        Assert-Equal 'Compile Module.Fixture.cpp' $progress.Text 'the current action text is bounded and retained'
        Assert-Equal 'UbtLog' $progress.Source 'the recognized contained evidence source is explicit'
        Assert-Equal $parallelPlan.Paths.UbtLogPath $progress.EvidencePath 'progress never redirects to an arbitrary log'
        Assert-True $progress.Truncated 'oversized progress evidence reads only a bounded tail'
        Assert-True ($progress.BytesInspected -le (512 * 1024)) 'progress evidence inspection is bounded to 512 KiB'
        Assert-True (-not [string]::IsNullOrWhiteSpace([string] $progress.ObservedAtUtc)) 'progress observation time is stable'

        $unknownRunId = [guid]::NewGuid().ToString('N')
        $unknownPaths = & $module {
            param($Workspace, $RunId)
            Get-UnrealRunPaths -WorkspaceRoot $Workspace -RunId $RunId
        } $scenarioFixture.WorkspaceRoot $unknownRunId
        $unknownProgress = & $module { param($Paths) Get-UnrealBuildProgressSnapshot -Paths $Paths } $unknownPaths
        Assert-True (-not $unknownProgress.ProgressKnown) 'missing progress evidence fails soft as unknown'
        Assert-Equal 'None' $unknownProgress.Source 'unknown progress has an explicit source'
        Assert-True ($null -eq $unknownProgress.Percent) 'unknown progress does not invent a percentage'

        $request = & $module { param($Request) Set-UnrealRunExecutionAssignment -Request $Request } $parallelPlan.Request
        $processMapping = & $module { param($Execution, $RunId) Enter-UnrealExecutionDriveMapping -Execution $Execution -RunId $RunId } $request.execution $request.runId
        try {
        $metadata = & $module { param($Request) New-UnrealRunMetadata -Request $Request } $request
        $metadata.state = 'Running'
        $metadata.workerPid = $PID
        $metadata.nativePid = 4242
        & $module {
            param($Request, $Metadata)
            Write-UnrealJsonFileAtomic -Path $Request.paths.RequestPath -Value $Request
            Write-UnrealJsonFileAtomic -Path $Request.paths.MetadataPath -Value $Metadata
        } $request $metadata
        $runStatus = Get-HarnessUnrealRunStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $request.runId
        Assert-True $runStatus.Progress.ProgressKnown 'run status exposes contained build progress'
        Assert-Equal 12 $runStatus.Progress.Current 'run status preserves the parsed action count'

        $outsideLog = Join-Path $scenarioScratch 'untrusted-ubt.log'
        [System.IO.File]::WriteAllText($outsideLog, "[99/100] Untrusted action`n", [System.Text.UTF8Encoding]::new($false))
        $correlatedCommandLine = 'dotnet.exe "{0}" FixtureEditor Win64 Development "-Project={1}" -NoMutex "-Log={2}"' -f `
            (Join-Path $scenarioFixture.EngineRoot 'Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll'), `
            $request.execution.projectFile, `
            $request.executionPaths.UbtLogPath
        $correlated = & $module {
            param($Id, $Name, $Executable, $CommandLine)
            ConvertTo-UnrealProcessView -ProcessId $Id -Name $Name -Executable $Executable -CommandLine $CommandLine
        } 4242 'dotnet' $scenarioFixture.EngineRoot $correlatedCommandLine
        Assert-True $correlated.RecognizedBuild 'contained log identity plus matching project, request, and nativePid identifies the build'
        Assert-Equal $scenarioFixture.WorkspaceRoot $correlated.WorkspaceRoot 'recognized build exposes its exact workspace'
        Assert-Equal 'FixtureEditor' $correlated.Target 'recognized build exposes its trusted target'
        Assert-Equal 'Development' $correlated.Configuration 'recognized build exposes its trusted configuration'
        Assert-Equal 'Parallel' $correlated.BuildConcurrency 'recognized build exposes its managed concurrency'
        Assert-Equal 12 $correlated.Progress.Current 'process progress comes from the physical contained run evidence'
        $wrongPid = & $module {
            param($Id, $Name, $Executable, $CommandLine)
            ConvertTo-UnrealProcessView -ProcessId $Id -Name $Name -Executable $Executable -CommandLine $CommandLine
        } 4243 'dotnet' $scenarioFixture.EngineRoot $correlatedCommandLine
        Assert-True (-not $wrongPid.RecognizedBuild) 'a mismatched nativePid cannot correlate run evidence'
        Assert-True (-not $wrongPid.Progress.ProgressKnown) 'an uncorrelated process cannot expose log progress'
        $externalLog = & $module {
            param($Id, $Name, $Executable, $CommandLine)
            ConvertTo-UnrealProcessView -ProcessId $Id -Name $Name -Executable $Executable -CommandLine $CommandLine
        } 4242 'dotnet' $scenarioFixture.EngineRoot ($correlatedCommandLine.Replace([string] $request.executionPaths.UbtLogPath, $outsideLog))
        Assert-True (-not $externalLog.RecognizedBuild) 'an external command-line log cannot correlate contained run evidence'
        Assert-True (-not $externalLog.Progress.ProgressKnown) 'an external command-line log cannot expose contained progress'
        }
        finally {
            & $module { param($Mapping, $RunId) Exit-UnrealExecutionDriveMapping -Mapping $Mapping -RunId $RunId } $processMapping $request.runId
        }

        $contentionPlan = Invoke-HarnessUnrealBuild -WorkspaceRoot $scenarioFixture.WorkspaceRoot -BuildConcurrency Parallel -PlanOnly
        $contentionRequest = $contentionPlan.Request | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $timestampPath = Join-Path $scenarioFixture.EngineRoot 'Engine/Intermediate/Build/Win64/FixtureEditor/UHT/Timestamp'
        $contentionRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $contentionRequest.arguments = @(
            '-NoProfile'
            '-Command'
            '[System.IO.File]::WriteAllText($env:FIXTURE_UBT_LOG, $env:FIXTURE_UHT_MESSAGE, [System.Text.UTF8Encoding]::new($false)); exit 0'
        )
        $contentionRequest.environment = [pscustomobject]@{
            FIXTURE_UBT_LOG = [string] $contentionRequest.paths.UbtLogPath
            FIXTURE_UHT_MESSAGE = "The process cannot access the file '$timestampPath' because it is being used by another process."
        }
        $contentionResult = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $contentionRequest
        Assert-Equal 'Failed' $contentionResult.State 'shared-engine UHT Timestamp contention overrides native success'
        Assert-True ($contentionResult.ExitCode -ne 0) 'shared-engine UHT Timestamp contention returns a non-zero result'
        Assert-Match $contentionResult.Message 'UHT.*Timestamp.*Serialize|dedicated EngineRoot' 'contention guidance offers Serialize or a dedicated engine'

        $leaseScript = Join-Path $scenarioScratch 'engine-lane-holder.ps1'
        [System.IO.File]::WriteAllText($leaseScript, @'
param([string] $Manifest, [string] $EngineRoot, [string] $Mode, [string] $ReadyPath, [int] $HoldMs)
$ErrorActionPreference = 'Stop'
Import-Module $Manifest -Force
$module = Get-Module UnrealEngineDevelop -ErrorAction Stop
& $module {
    param($Root, $LaneMode, $SignalPath, $Delay)
    $lease = Enter-UnrealEngineLane -EngineRoot $Root -Mode $LaneMode -Policy Wait -TimeoutMs 5000
    if ($null -eq $lease) { throw 'fixture engine lane was not acquired' }
    try {
        [System.IO.File]::WriteAllText($SignalPath, $LaneMode, [System.Text.UTF8Encoding]::new($false))
        Start-Sleep -Milliseconds $Delay
    }
    finally { Exit-UnrealEngineLane -Lease $lease }
} $EngineRoot $Mode $ReadyPath $HoldMs
'@, [System.Text.UTF8Encoding]::new($false))

        $laneProcesses = [System.Collections.Generic.List[System.Diagnostics.Process]]::new()
        try {
            $sharedReady = @((Join-Path $scenarioScratch 'shared-a.ready'), (Join-Path $scenarioScratch 'shared-b.ready'))
            foreach ($readyPath in $sharedReady) {
                $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
                $startInfo.FileName = Join-Path $PSHOME 'pwsh.exe'
                $startInfo.UseShellExecute = $false
                $startInfo.CreateNoWindow = $true
                foreach ($argument in @('-NoProfile', '-File', $leaseScript, '-Manifest', $manifestPath, '-EngineRoot', $scenarioFixture.EngineRoot, '-Mode', 'Shared', '-ReadyPath', $readyPath, '-HoldMs', '1800')) {
                    [void] $startInfo.ArgumentList.Add([string] $argument)
                }
                $holder = [System.Diagnostics.Process]::Start($startInfo)
                $laneProcesses.Add($holder)
            }
            $sharedDeadline = [DateTime]::UtcNow.AddSeconds(4)
            while (@($sharedReady | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }).Count -lt 2 -and [DateTime]::UtcNow -lt $sharedDeadline) {
                Start-Sleep -Milliseconds 50
            }
            Assert-Equal 2 @($sharedReady | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }).Count 'distinct shared lane holders overlap'

            $exclusiveReady = Join-Path $scenarioScratch 'exclusive.ready'
            $exclusiveInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $exclusiveInfo.FileName = Join-Path $PSHOME 'pwsh.exe'
            $exclusiveInfo.UseShellExecute = $false
            $exclusiveInfo.CreateNoWindow = $true
            foreach ($argument in @('-NoProfile', '-File', $leaseScript, '-Manifest', $manifestPath, '-EngineRoot', $scenarioFixture.EngineRoot, '-Mode', 'Exclusive', '-ReadyPath', $exclusiveReady, '-HoldMs', '1')) {
                [void] $exclusiveInfo.ArgumentList.Add([string] $argument)
            }
            $exclusive = [System.Diagnostics.Process]::Start($exclusiveInfo)
            $laneProcesses.Add($exclusive)
            Start-Sleep -Milliseconds 250
            Assert-True (-not (Test-Path -LiteralPath $exclusiveReady -PathType Leaf)) 'exclusive engine work waits while shared builds are active'
            foreach ($process in $laneProcesses) {
                Assert-True $process.WaitForExit(7000) 'engine lane fixture exits within the bounded deadline'
                Assert-Equal 0 $process.ExitCode 'engine lane fixture succeeds'
            }
            Assert-True (Test-Path -LiteralPath $exclusiveReady -PathType Leaf) 'exclusive engine work proceeds after shared holders release'

            $crashReady = Join-Path $scenarioScratch 'crash.ready'
            $crashInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $crashInfo.FileName = Join-Path $PSHOME 'pwsh.exe'
            $crashInfo.UseShellExecute = $false
            $crashInfo.CreateNoWindow = $true
            foreach ($argument in @('-NoProfile', '-File', $leaseScript, '-Manifest', $manifestPath, '-EngineRoot', $scenarioFixture.EngineRoot, '-Mode', 'Shared', '-ReadyPath', $crashReady, '-HoldMs', '30000')) {
                [void] $crashInfo.ArgumentList.Add([string] $argument)
            }
            $crashed = [System.Diagnostics.Process]::Start($crashInfo)
            $laneProcesses.Add($crashed)
            $crashDeadline = [DateTime]::UtcNow.AddSeconds(4)
            while (-not (Test-Path -LiteralPath $crashReady -PathType Leaf) -and [DateTime]::UtcNow -lt $crashDeadline) { Start-Sleep -Milliseconds 50 }
            Assert-True (Test-Path -LiteralPath $crashReady -PathType Leaf) 'crash fixture acquires a shared lane'
            $crashed.Kill($true)
            [void] $crashed.WaitForExit(5000)
            $recovered = & $module {
                param($Root)
                $lease = Enter-UnrealEngineLane -EngineRoot $Root -Mode Exclusive -Policy Wait -TimeoutMs 2000
                if ($null -eq $lease) { return $false }
                try { return $true }
                finally { Exit-UnrealEngineLane -Lease $lease }
            } $scenarioFixture.EngineRoot
            Assert-True $recovered 'an abandoned named engine lane is recovered after a holder crash'
        }
        finally {
            foreach ($process in $laneProcesses) {
                try {
                    if (-not $process.HasExited) { $process.Kill($true); [void] $process.WaitForExit(5000) }
                }
                catch { }
                $process.Dispose()
            }
        }
    }
    if (Test-Selected 'Automation') {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $projectRoot = [System.IO.Path]::GetFullPath((Join-Path $skillRoot '../../..'))
        $suiteCatalog = Get-Content -LiteralPath (Join-Path $skillRoot 'data/suites.json') -Raw | ConvertFrom-Json -Depth 100
        $smokeSuite = @($suiteCatalog.suites | Where-Object { [string] $_.name -ceq 'Smoke' })
        $smokeGroup = @(& $module { param($Root) Get-UnrealAutomationGroupRecords -WorkspaceRoot $Root } $projectRoot | Where-Object { [string] $_.Name -ceq 'AngelscriptSmoke' })
        Assert-Equal 1 $smokeSuite.Count 'the declarative Smoke suite exists exactly once'
        Assert-Equal 1 $smokeGroup.Count 'the engine AngelscriptSmoke group exists exactly once'
        Assert-SequenceEqual -Expected @($smokeSuite[0].entries.prefix) -Actual @($smokeGroup[0].Filters) -Message 'the engine AngelscriptSmoke group exactly matches the Harness Smoke suite'
        $configDirectory = Join-Path $scenarioFixture.WorkspaceRoot 'Config'
        [void][System.IO.Directory]::CreateDirectory($configDirectory)
        [System.IO.File]::WriteAllText((Join-Path $configDirectory 'DefaultEngine.ini'), @"
[/Script/AutomationController.AutomationControllerSettings]
+Groups=(Name="FixtureSmoke",Filters=((Contains="Angelscript.TestModule.Engine.",MatchFromStart=true)))
"@, [System.Text.UTF8Encoding]::new($false))

        $prefixPlan = Invoke-HarnessUnrealTest `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -TestPrefix 'Angelscript.TestModule.Engine' `
            -ConcurrencyPolicy Fail `
            -PlanOnly `
            -ExtraArguments @('-FixtureValue=alpha beta')
        Assert-Equal 'Test' $prefixPlan.Operation 'prefix planning selects the Test operation'
        Assert-Equal 'Prefix' $prefixPlan.SelectionKind 'prefix selection is explicit'
        Assert-Equal 'Angelscript.TestModule.Engine' $prefixPlan.TestPrefix 'the exact caller prefix is retained'
        Assert-Equal '^Angelscript.TestModule.Engine' $prefixPlan.AutomationTarget 'prefix execution uses starts-with semantics explicitly'
        Assert-Equal 'headless' $prefixPlan.LaunchProfile 'tests default to the headless launch profile'
        Assert-Equal 'Fail' $prefixPlan.Concurrency.Policy 'test concurrency policy is retained'
        Assert-True (-not $prefixPlan.Concurrency.RequiresEngineLease) 'tests use only their workspace lease'
        Assert-True $prefixPlan.EnforceAutomationReport 'reports are enforced by default'
        Assert-True (@($prefixPlan.Arguments) -contains '-NullRHI') 'tests default to NullRHI'
        Assert-True (@($prefixPlan.Arguments) -contains "-ABSLOG=$($prefixPlan.ExecutionPaths.UnrealLogPath)") 'Unreal writes through the independent per-run execution log path'
        Assert-True (@($prefixPlan.Arguments) -contains "-ReportExportPath=$($prefixPlan.ExecutionPaths.ReportPath)") 'the report directory uses the run-local execution view'
        Assert-True (@($prefixPlan.Arguments) -contains '-FixtureValue=alpha beta') 'test extra-argument boundaries are preserved'
        Assert-True (-not (Test-Path -LiteralPath $prefixPlan.Paths.RunRoot)) 'test PlanOnly creates no run directory'

        $groupPlan = Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Group FixtureSmoke -Fast -PlanOnly
        Assert-Equal 'Group' $groupPlan.SelectionKind 'defined group selection is explicit'
        Assert-Equal 'FixtureSmoke' $groupPlan.Group 'the exact configured group is retained'
        Assert-Equal 'Group:FixtureSmoke' $groupPlan.AutomationTarget 'group execution uses UE group syntax'
        Assert-Equal 'fast-headless' $groupPlan.LaunchProfile 'Fast selects the declarative fast-headless profile'
        Assert-True (@($groupPlan.Arguments) -contains '-NoLiveCoding') 'fast profile arguments come from tracked launch-profile data'

        $crashPlan = Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.CrashOnly.Fixture' -PlanOnly
        Assert-True $crashPlan.CrashOnly 'an exact crash-only prefix is classified explicitly'
        Assert-True (@($crashPlan.Arguments) -contains '-AngelscriptRunCrashOnlyTests') 'crash-only execution receives its opt-in flag'
        Assert-Throws {
            Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript' -PlanOnly
        } 'Crash-only tests must be run separately' 'a broad prefix cannot include crash-only tests'
        Assert-Throws {
            Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.CrashOnly+Angelscript.TestModule' -PlanOnly
        } 'Crash-only tests must be run separately' 'crash-only and ordinary prefixes cannot be combined'
        Assert-Throws {
            Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.Fixture' -Group FixtureSmoke -PlanOnly
        } 'exactly one' 'prefix and group cannot be combined'
        Assert-Throws {
            Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -PlanOnly
        } 'exactly one' 'a test selection is required'
        Assert-Throws {
            Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Group MissingGroup -PlanOnly
        } 'Unknown automation group' 'undefined groups are rejected'
        foreach ($unsafeArgument in @('-ExecCmds=Quit', '-ReportExportPath=C:\escape', '-ABSLOG=C:\escape.log', '-NullRHI', '-AngelscriptRunCrashOnlyTests', '-run=Other', '@unsafe.rsp', 'Other.uproject')) {
            Assert-Throws {
                Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.Fixture' -PlanOnly -ExtraArguments @($unsafeArgument)
            } 'reserved|response|switch' "tests reject managed or positional argument '$unsafeArgument'"
        }

        $noReportPlan = Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.Fixture.Render' -Render -NoReport -PlanOnly
        Assert-Equal 'render' $noReportPlan.LaunchProfile 'Render selects the declarative render profile'
        Assert-True (@($noReportPlan.Arguments) -notcontains '-NullRHI') 'render plans do not add NullRHI'
        Assert-True (-not $noReportPlan.EnforceAutomationReport) 'NoReport selects native process truth explicitly'
        Assert-True (@($noReportPlan.Arguments | Where-Object { $_ -like '-ReportExportPath=*' }).Count -eq 0) 'NoReport omits report export arguments'
        Assert-Throws {
            Invoke-HarnessUnrealTest -WorkspaceRoot $scenarioFixture.WorkspaceRoot -TestPrefix 'Angelscript.Fixture' -Render -Fast -PlanOnly
        } 'Fast.*Render|Render.*Fast' 'Fast and Render cannot select conflicting profiles'

        $commandletPlan = Invoke-HarnessUnrealCommandlet `
            -WorkspaceRoot $scenarioFixture.WorkspaceRoot `
            -Commandlet BlueprintImpact `
            -ConcurrencyPolicy Wait `
            -PlanOnly `
            -ExtraArguments @('-FixtureValue=one value')
        Assert-Equal 'Commandlet' $commandletPlan.Operation 'commandlet planning selects the Commandlet operation'
        Assert-Equal 'BlueprintImpact' $commandletPlan.Commandlet 'commandlet identity is retained'
        Assert-Equal 'headless' $commandletPlan.LaunchProfile 'commandlets default to headless NullRHI'
        Assert-True (@($commandletPlan.Arguments) -contains '-run=BlueprintImpact') 'commandlet syntax is exact'
        Assert-True (@($commandletPlan.Arguments) -contains '-FixtureValue=one value') 'commandlet argument boundaries are preserved'
        Assert-True (@($commandletPlan.Arguments) -contains "-ABSLOG=$($commandletPlan.ExecutionPaths.UnrealLogPath)") 'commandlets use the independent run-local execution log path'
        Assert-Throws {
            Invoke-HarnessUnrealCommandlet -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Commandlet 'Bad;Quit' -PlanOnly
        } 'Commandlet' 'unsafe commandlet names are rejected'
        Assert-Throws {
            Invoke-HarnessUnrealCommandlet -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Commandlet BlueprintImpact -PlanOnly -ExtraArguments @('-run=Other')
        } 'reserved' 'callers cannot override the managed commandlet'

        $passReportSource = Join-Path $scenarioScratch 'automation-pass.json'
        $failReportSource = Join-Path $scenarioScratch 'automation-fail.json'
        [System.IO.File]::WriteAllText($passReportSource, '{"reportCreatedOn":"2026.09.03-12.00.00","succeeded":1,"succeededWithWarnings":0,"failed":0,"notRun":0,"inProcess":0,"tests":[{"testDisplayName":"Pass","fullTestPath":"Angelscript.Fixture.Pass","state":"Success","warnings":0,"errors":0}]}', [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::WriteAllText($failReportSource, '{"reportCreatedOn":"2026.09.03-12.00.00","succeeded":0,"succeededWithWarnings":0,"failed":1,"notRun":0,"inProcess":0,"tests":[{"testDisplayName":"Fail","fullTestPath":"Angelscript.Fixture.Fail","state":"Fail","warnings":0,"errors":1}]}', [System.Text.UTF8Encoding]::new($false))
        $copyReportScript = @'
$source = [string] $env:FIXTURE_REPORT_SOURCE
$destination = [string] $env:FIXTURE_REPORT_DESTINATION
$log = [string] $env:FIXTURE_UNREAL_LOG
[void][System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($destination))
[System.IO.File]::Copy($source, $destination, $true)
[System.IO.File]::WriteAllText($log, 'fixture Unreal log', [System.Text.UTF8Encoding]::new($false))
'@

        $passRequest = $prefixPlan.Request | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $passRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $passRequest.arguments = @('-NoProfile', '-Command', $copyReportScript)
        $passRequest.environment = [pscustomobject]@{
            FIXTURE_REPORT_SOURCE      = $passReportSource
            FIXTURE_REPORT_DESTINATION = Join-Path $passRequest.paths.ReportPath 'index.json'
            FIXTURE_UNREAL_LOG         = $passRequest.paths.UnrealLogPath
        }
        $passRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $passRequest
        Assert-Equal 'Succeeded' $passRun.State 'zero-exit passing structured truth succeeds'
        Assert-True (Test-Path -LiteralPath $passRun.SummaryPath -PathType Leaf) 'enforced tests retain Summary.json'
        Assert-True (Test-Path -LiteralPath $passRequest.paths.UnrealLogPath -PathType Leaf) 'Unreal.log remains independent from Command.log'
        Assert-True (-not ([string] $passRequest.paths.UnrealLogPath).Equals([string] $passRun.LogPath, [System.StringComparison]::OrdinalIgnoreCase)) 'editor and worker logs have distinct paths'
        $passSummary = Get-Content -LiteralPath $passRun.SummaryPath -Raw | ConvertFrom-Json
        Assert-Equal 'Passed' $passSummary.Outcome 'worker persists passing parser truth'

        $failRequest = $groupPlan.Request | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $failRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $failRequest.arguments = @('-NoProfile', '-Command', $copyReportScript)
        $failRequest.environment = [pscustomobject]@{
            FIXTURE_REPORT_SOURCE      = $failReportSource
            FIXTURE_REPORT_DESTINATION = Join-Path $failRequest.paths.ReportPath 'index.json'
            FIXTURE_UNREAL_LOG         = $failRequest.paths.UnrealLogPath
        }
        $failRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $failRequest
        Assert-Equal 'Failed' $failRun.State 'zero-exit failing structured truth is promoted to Failed'
        Assert-True ($failRun.ExitCode -ne 0) 'structured report failure produces a non-zero Harness result'
        $failSummary = Get-Content -LiteralPath $failRun.SummaryPath -Raw | ConvertFrom-Json
        Assert-Equal 'Failed' $failSummary.Outcome 'worker persists failing parser truth'

        $missingRequest = $crashPlan.Request | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $missingRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $missingRequest.arguments = @('-NoProfile', '-Command', "Write-Output 'no-report-fixture'")
        $missingRequest.environment = [pscustomobject]@{}
        $missingRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $missingRequest
        Assert-Equal 'Failed' $missingRun.State 'zero-exit missing structured truth is promoted to Failed'
        $missingSummary = Get-Content -LiteralPath $missingRun.SummaryPath -Raw | ConvertFrom-Json
        Assert-Equal 'Missing' $missingSummary.Outcome 'missing structured truth is explicit in Summary.json'

        $noReportRequest = $noReportPlan.Request | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $noReportRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $noReportRequest.arguments = @('-NoProfile', '-Command', "Write-Output 'no-report-process-truth'")
        $noReportRequest.environment = [pscustomobject]@{}
        $noReportRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $noReportRequest
        Assert-Equal 'Succeeded' $noReportRun.State 'NoReport uses successful native process truth'
        Assert-True (-not (Test-Path -LiteralPath $noReportRun.SummaryPath)) 'NoReport does not fabricate Summary.json'
    }
    if (Test-Selected 'Suites') {
        $module = Get-Module UnrealEngineDevelop -ErrorAction Stop
        $suiteImplementationText = Get-Content -LiteralPath (Join-Path $skillRoot 'scripts/Private/Suites.ps1') -Raw
        Assert-True ($suiteImplementationText -notmatch '\bInvoke-HarnessUnrealTest\b') 'suite execution does not reacquire the workspace lease through the public Test command'
        Assert-True ($suiteImplementationText -notmatch '(?i)(?:^|[\\/])Tools[\\/].*\.ps1') 'suite execution does not depend on a root Tools script'
        $expectedSuiteNames = @('Smoke', 'NativeCore', 'RuntimeCpp', 'Bindings', 'HotReload', 'Cache', 'Debugger', 'FunctionalSamples', 'All')
        $catalog = @(Get-HarnessUnrealSuiteList -WorkspaceRoot $scenarioFixture.WorkspaceRoot)
        Assert-SequenceEqual -Expected $expectedSuiteNames -Actual @($catalog.Name) -Message 'only maintained Unreal Automation suites are listed'
        Assert-True (@($catalog | Where-Object { $_.Kind -cne 'UnrealAutomation' }).Count -eq 0) 'every maintained suite is Unreal Automation only'

        $planOne = New-HarnessUnrealSuitePlan -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Suite Debugger -TimeoutMs 60000
        $planTwo = New-HarnessUnrealSuitePlan -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Suite Debugger -TimeoutMs 60000
        Assert-Equal 'harness-unreal-suite-plan' $planOne.SchemaVersion 'suite plans publish the stable plan schema'
        Assert-Equal 'harness-unreal-suites' $planOne.DataSchemaVersion 'suite plans retain the stable declarative data schema'
        Assert-Match $planOne.DataHash '^sha256:[a-f0-9]{64}$' 'suite plans retain the exact tracked data hash'
        Assert-Equal (($planOne | ConvertTo-Json -Depth 100 -Compress)) (($planTwo | ConvertTo-Json -Depth 100 -Compress)) 'suite planning is deterministic across repeated calls'
        Assert-True ($null -eq $planOne.PSObject.Properties['RunId']) 'deterministic suite plans contain no RunId'
        Assert-True ($null -eq $planOne.PSObject.Properties['CreatedAtUtc']) 'deterministic suite plans contain no timestamp'
        Assert-True ($null -eq $planOne.PSObject.Properties['Paths']) 'deterministic suite plans allocate no run paths'
        Assert-Equal 'SequentialSingleWorkspaceLease' $planOne.Execution 'suite execution strategy is explicit'
        Assert-Equal 2 $planOne.EntryCount 'Debugger retains its two Automation entries'
        Assert-SequenceEqual -Expected @(1, 2) -Actual @($planOne.Entries.Order) -Message 'suite entry order is explicit and stable'
        Assert-SequenceEqual -Expected @('AutoEvaluate', 'TestModuleDebugger') -Actual @($planOne.Entries.Label) -Message 'Debugger labels are stable'
        Assert-SequenceEqual -Expected @('Heavy', 'Heavy') -Actual @($planOne.Entries.Tier) -Message 'entry tiers survive declarative planning'
        Assert-True (@($planOne.Entries | Where-Object { $_.LaunchProfile -cne 'headless' }).Count -eq 0) 'suite entries select the tracked headless launch profile'
        Assert-SequenceEqual -Expected @('Entries/001-AutoEvaluate', 'Entries/002-TestModuleDebugger') -Actual @($planOne.Entries.RelativeRoot) -Message 'entry evidence shape is deterministic without a run root'
        $suiteRunsRoot = Join-Path $scenarioFixture.WorkspaceRoot 'Saved/Harness/Unreal/Runs'
        $suiteRunsRootExisted = Test-Path -LiteralPath $suiteRunsRoot -PathType Container
        $suiteRunTreeBefore = if ($suiteRunsRootExisted) {
            @(Get-ChildItem -LiteralPath $suiteRunsRoot -Force -Recurse | Sort-Object FullName | ForEach-Object {
                '{0}|{1}|{2}' -f $_.FullName.Substring($suiteRunsRoot.Length), $_.PSIsContainer, $(if ($_.PSIsContainer) { 0 } else { $_.Length })
            })
        }
        else { @() }
        $planViaInvoke = Invoke-HarnessUnrealSuite -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Suite Debugger -TimeoutMs 60000 -PlanOnly
        Assert-Equal (($planOne | ConvertTo-Json -Depth 100 -Compress)) (($planViaInvoke | ConvertTo-Json -Depth 100 -Compress)) 'suite run PlanOnly returns the same deterministic plan'
        Assert-Equal $suiteRunsRootExisted (Test-Path -LiteralPath $suiteRunsRoot -PathType Container) 'suite PlanOnly does not create the run root'
        $suiteRunTreeAfter = if (Test-Path -LiteralPath $suiteRunsRoot -PathType Container) {
            @(Get-ChildItem -LiteralPath $suiteRunsRoot -Force -Recurse | Sort-Object FullName | ForEach-Object {
                '{0}|{1}|{2}' -f $_.FullName.Substring($suiteRunsRoot.Length), $_.PSIsContainer, $(if ($_.PSIsContainer) { 0 } else { $_.Length })
            })
        }
        else { @() }
        Assert-SequenceEqual -Expected $suiteRunTreeBefore -Actual $suiteRunTreeAfter -Message 'suite PlanOnly leaves any pre-existing run tree unchanged'

        $allPlan = New-HarnessUnrealSuitePlan -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Suite All -TimeoutMs 60000
        Assert-Equal 36 $allPlan.EntryCount 'All retains exactly 36 Unreal Automation prefixes'
        Assert-Equal 36 @($allPlan.Entries.Prefix | Sort-Object -Unique).Count 'All prefixes are unique'
        Assert-True (@($allPlan.Entries.Prefix) -contains 'Angelscript.TestModule.Generator') 'All retains the Generator prefix'
        Assert-True (@($allPlan.Entries | Where-Object { $_.Kind -cne 'UnrealAutomation' }).Count -eq 0) 'All contains no CMake or package entry'
        Assert-True (@($allPlan.Entries | Where-Object { $_.Label -match 'Standalone|Package|Coverage|Release' }).Count -eq 0) 'external pipelines are not executable suite entries'
        Assert-SequenceEqual -Expected @('Standalone', 'StandaloneRelease', 'CachePackage', 'package', 'coverage', 'release') -Actual @($allPlan.DeferredCapabilities.Id) -Message 'deferred external capabilities are explicit and stable'
        Assert-True (@($allPlan.DeferredCapabilities | Where-Object { $_.Status -cne 'Deferred' }).Count -eq 0) 'every excluded external capability is marked Deferred'
        Assert-Throws {
            New-HarnessUnrealSuitePlan -WorkspaceRoot $scenarioFixture.WorkspaceRoot -Suite Standalone -TimeoutMs 60000
        } 'Unknown suite|deferred' 'Standalone cannot silently enter the Unreal suite runner'

        $fakeSuiteScript = @'
$orderPath = [string] $env:FIXTURE_ORDER_PATH
$order = [string] $env:FIXTURE_ORDER
$reportPath = [string] $env:FIXTURE_REPORT_PATH
$unrealLogPath = [string] $env:FIXTURE_UNREAL_LOG_PATH
[System.IO.File]::AppendAllText($orderPath, "start:$order`n", [System.Text.UTF8Encoding]::new($false))
Start-Sleep -Milliseconds 150
[void][System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($reportPath))
$report = '{"reportCreatedOn":"2026.09.03-12.00.00","succeeded":1,"succeededWithWarnings":0,"failed":0,"notRun":0,"inProcess":0,"tests":[{"testDisplayName":"Pass","fullTestPath":"Angelscript.Fixture.Pass","state":"Success","warnings":0,"errors":0}]}'
[System.IO.File]::WriteAllText($reportPath, $report, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText($unrealLogPath, "fixture-suite:$order", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::AppendAllText($orderPath, "end:$order`n", [System.Text.UTF8Encoding]::new($false))
'@
        $fakeSuiteScriptPath = Join-Path $scenarioScratch 'Invoke-FakeSuiteEntry.ps1'
        [System.IO.File]::WriteAllText($fakeSuiteScriptPath, $fakeSuiteScript, [System.Text.UTF8Encoding]::new($false))
        $suiteOperation = & $module {
            param($Workspace)
            New-UnrealSuiteOperation -WorkspaceRoot $Workspace -Suite Debugger -TimeoutMs 60000
        } $scenarioFixture.WorkspaceRoot
        $suiteRequest = $suiteOperation.Request
        $suiteRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        $orderPath = Join-Path $scenarioScratch 'suite-order.log'
        foreach ($entry in @($suiteRequest.suite.entries)) {
            $entry.arguments = @('-NoProfile', '-File', $fakeSuiteScriptPath)
            $entry.environment = [pscustomobject]@{
                FIXTURE_ORDER_PATH       = $orderPath
                FIXTURE_ORDER            = [string] $entry.order
                FIXTURE_REPORT_PATH      = Join-Path $entry.paths.ReportPath 'index.json'
                FIXTURE_UNREAL_LOG_PATH  = [string] $entry.paths.UnrealLogPath
            }
        }
        $suiteTimer = [System.Diagnostics.Stopwatch]::StartNew()
        $suiteRun = & $module { param($Request) Start-UnrealRunRequest -Request $Request } $suiteRequest
        $suiteTimer.Stop()
        Assert-Equal 'Succeeded' $suiteRun.State 'two fake Automation entries complete successfully'
        Assert-Equal 'Suite' $suiteRun.Operation 'suite execution retains its root operation'
        Assert-SequenceEqual -Expected @('start:1', 'end:1', 'start:2', 'end:2') -Actual @(Get-Content -LiteralPath $orderPath) -Message 'suite entries execute sequentially under one worker'
        Assert-True (Test-Path -LiteralPath $suiteRun.SummaryPath -PathType Leaf) 'suite execution retains a root Summary.json'
        Assert-True (@($suiteRun.Artifacts) -contains $suiteRun.SummaryPath) 'root metadata advertises the aggregate Summary.json'
        $suiteSummary = Get-Content -LiteralPath $suiteRun.SummaryPath -Raw | ConvertFrom-Json
        Assert-Equal 'harness-unreal-suite-summary' $suiteSummary.SchemaVersion 'root suite summary uses the stable schema name'
        Assert-Equal 'Passed' $suiteSummary.Outcome 'root summary aggregates passing structured truth'
        Assert-Equal 2 $suiteSummary.EntryCount 'root summary retains planned entry count'
        Assert-Equal 2 $suiteSummary.Succeeded 'root summary counts passing entries'
        Assert-Equal 0 $suiteSummary.Failed 'root summary has no failed entry'
        foreach ($entry in @($suiteRequest.suite.entries)) {
            Assert-True (Test-Path -LiteralPath $entry.paths.LogPath -PathType Leaf) "entry $($entry.order) retains Command.log"
            Assert-True (Test-Path -LiteralPath $entry.paths.UnrealLogPath -PathType Leaf) "entry $($entry.order) retains Unreal.log"
            Assert-True (Test-Path -LiteralPath (Join-Path $entry.paths.ReportPath 'index.json') -PathType Leaf) "entry $($entry.order) retains AutomationReport/index.json"
            Assert-True (Test-Path -LiteralPath $entry.paths.SummaryPath -PathType Leaf) "entry $($entry.order) retains Summary.json"
        }
        $postSuiteLease = & $module {
            param($Workspace)
            $lease = Enter-UnrealLease -Scope 'workspace' -Key $Workspace -Policy Fail -TimeoutMs 1
            if ($null -eq $lease) { return $false }
            try { return $true } finally { Exit-UnrealLease -Lease $lease }
        } $scenarioFixture.WorkspaceRoot
        Assert-True $postSuiteLease 'suite execution releases its one outer workspace lease'

        $cancelOperation = & $module {
            param($Workspace)
            New-UnrealSuiteOperation -WorkspaceRoot $Workspace -Suite Debugger -TimeoutMs 30000
        } $scenarioFixture.WorkspaceRoot
        $cancelRequest = $cancelOperation.Request
        $cancelRequest.filePath = Join-Path $PSHOME 'pwsh.exe'
        foreach ($entry in @($cancelRequest.suite.entries)) {
            $entry.arguments = @('-NoProfile', '-Command', 'Start-Sleep -Seconds 30')
            $entry.environment = [pscustomobject]@{}
        }
        $cancelQueued = & $module { param($Request) Start-UnrealRunRequest -Request $Request -NoWait } $cancelRequest
        $cancelDeadline = [DateTime]::UtcNow.AddSeconds(12)
        do {
            Start-Sleep -Milliseconds 100
            $cancelRunning = Get-HarnessUnrealRunStatus -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $cancelQueued.RunId
        } while (($cancelRunning.State -ne 'Running' -or $null -eq $cancelRunning.NativePid) -and [DateTime]::UtcNow -lt $cancelDeadline)
        Assert-Equal 'Running' $cancelRunning.State 'an asynchronous suite reaches Running'
        Assert-True ($null -ne $cancelRunning.NativePid) 'the current suite descendant is recorded for cancellation'
        $cancelTimer = [System.Diagnostics.Stopwatch]::StartNew()
        $cancelledSuite = Stop-HarnessUnrealRun -WorkspaceRoot $scenarioFixture.WorkspaceRoot -RunId $cancelQueued.RunId -Confirm:$false
        $cancelTimer.Stop()
        Assert-Equal 'Cancelled' $cancelledSuite.State 'suite cancellation reaches Cancelled'
        Assert-True ($null -eq (Get-Process -Id ([int] $cancelRunning.WorkerPid) -ErrorAction SilentlyContinue)) 'suite cancellation removes the worker'
        Assert-True ($null -eq (Get-Process -Id ([int] $cancelRunning.NativePid) -ErrorAction SilentlyContinue)) 'suite cancellation removes the current descendant'
        $postCancelLease = & $module {
            param($Workspace)
            $lease = Enter-UnrealLease -Scope 'workspace' -Key $Workspace -Policy Fail -TimeoutMs 1
            if ($null -eq $lease) { return $false }
            try { return $true } finally { Exit-UnrealLease -Lease $lease }
        } $scenarioFixture.WorkspaceRoot
        Assert-True $postCancelLease 'suite cancellation releases the outer workspace lease'
        Write-Output ("Suites timing: two-entry-run={0}ms cancellation={1}ms" -f $suiteTimer.ElapsedMilliseconds, $cancelTimer.ElapsedMilliseconds)
    }
    if (Test-Selected 'Integration') {
        $harnessManifestPath = [System.IO.Path]::GetFullPath((Join-Path $skillRoot '../harness/scripts/Harness.psd1'))
        Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue
        Remove-Module Harness -Force -ErrorAction SilentlyContinue
        Import-Module $harnessManifestPath -Force
        try {
            $harnessContext = New-HarnessContext -WorkspaceRoot $scenarioFixture.WorkspaceRoot
            Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'importing Harness does not eagerly import the Unreal leaf'

            $nonUnreal = Invoke-Harness -Command 'harness.status' -Context $harnessContext
            Assert-Equal 'Succeeded' $nonUnreal.status 'a non-Unreal route succeeds against the fixture workspace'
            Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'a non-Unreal route does not import the Unreal leaf'

            $routedStatus = Invoke-Harness -Command 'ue.status' -Context $harnessContext
            Assert-Equal 'Succeeded' $routedStatus.status 'ue.status succeeds through the common Harness envelope'
            Assert-Equal $scenarioFixture.WorkspaceRoot $routedStatus.data.WorkspaceRoot 'ue.status receives the exact context WorkspaceRoot'
            $loadedUnreal = @(Get-Module UnrealEngineDevelop -All)
            Assert-Equal 1 $loadedUnreal.Count 'the first Unreal route loads exactly one Unreal leaf'
            Assert-Equal ([System.IO.Path]::GetFullPath($modulePath)) ([System.IO.Path]::GetFullPath($loadedUnreal[0].Path)) 'the Unreal leaf resolves from the context HarnessRoot'

            $buildPlan = Invoke-Harness -Command 'ue.build' -Context $harnessContext -Parameters @{
                WorkspaceRoot   = $scenarioFixture.WorkspaceRoot
                BuildConcurrency = 'Parallel'
                TimeoutMs       = 30000
                PlanOnly        = $true
            }
            Assert-Equal 'Succeeded' $buildPlan.status 'ue.build PlanOnly succeeds through Harness without starting UBT'
            Assert-Equal 'Parallel' $buildPlan.data.BuildConcurrency 'ue.build forwards the explicit BuildConcurrency value'
            Assert-True (-not (Test-Path -LiteralPath $buildPlan.data.Paths.RunRoot)) 'routed build PlanOnly creates no run directory'

            $mismatchedRoot = [System.IO.Path]::GetFullPath($scenarioFixture.EngineRoot)
            $mismatched = Invoke-Harness -Command 'ue.status' -Context $harnessContext -Parameters @{ WorkspaceRoot = $mismatchedRoot }
            Assert-Equal 'Failed' $mismatched.status 'an explicit cross-root Unreal parameter is rejected through the common envelope'
            Assert-Match $mismatched.error.message 'WorkspaceRoot.*context|context.*WorkspaceRoot|selected.*workspace' 'the cross-root diagnostic identifies the context mismatch'

            $cancelRoute = Get-HarnessCommand -Name 'ue.run.cancel'
            Assert-True (-not $cancelRoute.Defaults.ContainsKey('Confirm')) 'the cancel route preserves the leaf confirmation contract'
        }
        finally {
            Remove-Module Harness -Force -ErrorAction SilentlyContinue
            Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue
        }
    }
}
finally {
    Remove-Module UnrealEngineDevelop -Force -ErrorAction SilentlyContinue
    if ($null -ne $scenarioScratch -and (Test-Path -LiteralPath $scenarioScratch)) {
        $temporaryRoot = Convert-Path -LiteralPath ([System.IO.Path]::GetTempPath())
        $resolvedScratch = Convert-Path -LiteralPath $scenarioScratch
        if (-not $resolvedScratch.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            [System.IO.Path]::GetFileName($resolvedScratch) -notlike 'unreal-scenarios-*') {
            throw "Refusing to remove unexpected scenario scratch path: $resolvedScratch"
        }
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
    $env:HARNESS_UNREAL_TEST_MODE = $previousUnrealTestMode
    $env:HARNESS_UNREAL_TEST_STATE_ROOT = $previousUnrealTestStateRoot
    $env:HARNESS_UNREAL_TEST_LEGACY_STATE_ROOT = $previousUnrealLegacyTestStateRoot
    if (Test-Path -LiteralPath $unrealTestStateRoot -PathType Container) {
        Remove-Item -LiteralPath $unrealTestStateRoot -Recurse -Force
    }
    if (Test-Path -LiteralPath $unrealLegacyTestStateRoot -PathType Container) {
        Remove-Item -LiteralPath $unrealLegacyTestStateRoot -Recurse -Force
    }
}

Write-Output "UnrealEngineDevelop.Tests.ps1 [$Tag]: PASS"
