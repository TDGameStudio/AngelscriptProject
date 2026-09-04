[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}

function Assert-Contains {
    param([string]$Text, [string]$Expected, [string]$Message)
    if (-not $Text.Contains($Expected, [System.StringComparison]::Ordinal)) {
        throw "Assertion failed: $Message (missing '$Expected')"
    }
}

function Assert-NotContains {
    param([string]$Text, [string]$Forbidden, [string]$Message)
    if ($Text.Contains($Forbidden, [System.StringComparison]::Ordinal)) {
        throw "Assertion failed: $Message (found '$Forbidden')"
    }
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$harnessManifest = Join-Path $projectRoot '.agents\skills\harness\scripts\Harness.psd1'
$legacyManifest = Join-Path $projectRoot '.agents\skills\hardness\scripts\Hardness.psd1'
$agentsPath = Join-Path $projectRoot 'AGENTS.md'
$agentsChinesePath = Join-Path $projectRoot 'AGENTS_ZH.md'

Assert-True (Test-Path -LiteralPath $harnessManifest -PathType Leaf) 'the canonical Harness module exists'
Assert-True (-not (Test-Path -LiteralPath $legacyManifest)) 'the old Hardness module path is absent'
Assert-True (Test-Path -LiteralPath $agentsPath -PathType Leaf) 'the canonical root Agent entry exists'
Assert-True (-not (Test-Path -LiteralPath $agentsChinesePath)) 'the duplicate Chinese root Agent entry is absent'
Assert-True (Test-Path -LiteralPath (Join-Path $projectRoot 'Wiki\Agents_ZH.md') -PathType Leaf) 'subsystem-owned Wiki guidance remains present'

$agentsEnglish = Get-Content -Raw -LiteralPath $agentsPath
$readme = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'README.md')
$skillIndex = Get-Content -Raw -LiteralPath (Join-Path $projectRoot '.agents\skills\README.md')
$harnessSkill = Get-Content -Raw -LiteralPath (Join-Path $projectRoot '.agents\skills\harness\SKILL.md')
$taskDag = Get-Content -Raw -LiteralPath (Join-Path $projectRoot '.agents\skills\harness\references\task-dag.md')
$unrealSkill = Get-Content -Raw -LiteralPath (Join-Path $projectRoot '.agents\skills\unreal-engine-develop\SKILL.md')

Assert-True (@(Get-Content -LiteralPath $agentsPath).Count -le 80) 'the canonical root Agent entry stays thin'
Assert-Contains $agentsEnglish 'Unreal Engine 5.8' 'the canonical Agent entry uses the current engine baseline'
Assert-Contains $agentsEnglish 'Plugins/Angelscript' 'the canonical Agent entry states the plugin-first objective'
Assert-Contains $agentsEnglish 'tasks.md' 'the canonical Agent entry routes first to the current task plan'
Assert-Contains $agentsEnglish 'attachments/INDEX.md' 'the canonical Agent entry routes first to the attachment index'
Assert-Contains $agentsEnglish '.agents/skills/README.md' 'the canonical Agent entry routes to the Skill index'
Assert-Contains $agentsEnglish 'openspec/specs/' 'the canonical Agent entry routes to durable specs'
Assert-Contains $agentsEnglish 'Reference/README.md' 'the canonical Agent entry routes to the reference index'
Assert-Contains $agentsEnglish '<domain>/<type>-<scope>-<outcome>' 'the canonical Agent entry preserves Change naming'
Assert-Contains $agentsEnglish 'smallest impact-related verification' 'the canonical Agent entry defaults to impact-scoped verification'
Assert-Contains $agentsEnglish 'current PowerShell 7 process' 'the canonical Agent entry keeps direct Harness dispatch'
Assert-Contains $agentsEnglish 'Harness `ue.*` routes' 'the canonical Agent entry routes Unreal work through Harness'
Assert-Contains $agentsEnglish 'explicitly requested' 'the canonical Agent entry preserves explicit-only Review and worktree authority'
foreach ($heavySection in @('## Project Directory Structure', '## Architecture Overview', '## External Reference Repositories', '## Test Number Baselines', '121 `Bind_*.cpp`', '1518+', '691/691 PASS')) {
    Assert-NotContains $agentsEnglish $heavySection "the thin Agent entry omits volatile detail: $heavySection"
}
Assert-NotContains $readme 'AGENTS_ZH.md' 'the root README presents one project-level Agent entry'
Assert-Contains $readme 'Unreal Engine `5.8`' 'the root README uses the current engine baseline'
Assert-Contains $readme '| PowerShell | 7.0+（Core） |' 'the root README requires the supported PowerShell host'
Assert-Contains $readme 'Invoke-Harness -Command ue.build' 'the root README routes builds through Harness'
Assert-Contains $readme 'Invoke-Harness -Command ue.test' 'the root README routes tests through Harness'
Assert-NotContains $readme 'Current/Goal' 'the root README does not invent repository modes'
Assert-NotContains $readme 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Run' 'the root README does not publish legacy UE wrappers'
Assert-NotContains $unrealSkill 'does not enable itself' 'the Unreal Skill acknowledges that project Skills are enabled'
Assert-Contains $skillIndex 'directly in the current PowerShell 7 process' 'the Skill index distinguishes direct route invocation'
Assert-Contains $harnessSkill 'ordinary Harness routes execute directly in that current process' 'the Harness entry documents direct invocation'
Assert-Contains $harnessSkill 'Intentional child `pwsh` processes' 'the Harness entry bounds isolated child hosts'
Assert-Contains $taskDag '& ./.agents/skills/harness/tests/Harness.Tests.ps1' 'task verification examples use the current PowerShell process'
Assert-Contains $unrealSkill 'ordinary route dispatch stays in the caller process' 'the Unreal Skill distinguishes managed workers from dispatch'

$moduleManifests = @(
    $harnessManifest
    (Join-Path $projectRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1')
    (Join-Path $projectRoot '.agents\skills\git-operations\scripts\GitOperations.psd1')
    (Join-Path $projectRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1')
)
foreach ($manifest in $moduleManifests) {
    $data = Import-PowerShellDataFile -LiteralPath $manifest
    Assert-Equal '3.0.0' ([string]$data.ModuleVersion) "breaking module version is current: $manifest"
}

Import-Module $harnessManifest -Force
try {
    $routes = @(Get-HarnessCommand)
    foreach ($name in @('harness.status', 'harness.observe', 'harness.evolution.status')) {
        Assert-Equal 1 @($routes | Where-Object Name -eq $name).Count "Harness exposes $name exactly once"
    }
    Assert-Equal 0 @($routes | Where-Object Name -in @('hardness.status', 'hardness.observe', 'hardness.evolution.status')).Count 'old framework routes are absent'
    Assert-Equal 0 @(Get-Command -Module Harness | Where-Object Name -match 'Hardness').Count 'Harness exports no old public symbol'
    Assert-True ($null -eq (Get-Command New-HardnessContext -ErrorAction SilentlyContinue)) 'the old context constructor is unavailable'

    $context = New-HarnessContext -WorkspaceRoot $projectRoot
    $status = Invoke-Harness -Command harness.status -Context $context
    Assert-Equal 'Succeeded' $status.status 'the canonical Harness status route succeeds'
}
finally {
    Remove-Module Harness -Force -ErrorAction SilentlyContinue
}

Write-Output 'HarnessCutover.Tests.ps1: PASS'
