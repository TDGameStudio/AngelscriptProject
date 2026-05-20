param()

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\test-helpers.ps1"

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpRoot = Join-Path $PSScriptRoot '.tmp\prd-workflow'

if (Test-Path $tmpRoot) {
    Remove-Item -Path $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $tmpRoot | Out-Null

$mockAgentCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File $repoRoot\tests\mock-agent.ps1"
$verifyOnePassCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$repoRoot\tests\mock-verify.ps1`" -PassAfter 1"

$prdFile = Join-Path $tmpRoot 'prd.json'
$progressFile = Join-Path $tmpRoot 'progress.txt'
$runsRoot = Join-Path $tmpRoot 'runs-prd'

$prdJson = @'
{
  "project": "RalphLoop",
  "branchName": "ralph/prd-workflow",
  "description": "Exercise read-only PRD mode",
  "userStories": [
    {
      "id": "US-002",
      "title": "Second story",
      "description": "This story has lower priority than the selected story.",
      "acceptanceCriteria": ["Do not select this first"],
      "priority": 2,
      "passes": false,
      "notes": "Later"
    },
    {
      "id": "US-001",
      "title": "Selected story",
      "description": "This is the first story to inject.",
      "acceptanceCriteria": ["Render id", "Render acceptance criteria"],
      "priority": 1,
      "passes": false,
      "notes": "Important note"
    },
    {
      "id": "US-000",
      "title": "Completed story",
      "description": "Already done.",
      "acceptanceCriteria": ["Ignored"],
      "priority": 0,
      "passes": true,
      "notes": ""
    }
  ]
}
'@

$progressText = @'
## Codebase Patterns
- Preserve existing loop runner behavior.

## Previous Work
- Provider profiles were normalized.
'@

Set-Content -Path $prdFile -Value $prdJson -Encoding UTF8
Set-Content -Path $progressFile -Value $progressText -Encoding UTF8

$prdBefore = Get-Content -Raw -Path $prdFile
$progressBefore = Get-Content -Raw -Path $progressFile

$prdArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'prd workflow smoke'
    '-Workflow'
    'Prd'
    '-PrdFile'
    $prdFile
    '-ProgressFile'
    $progressFile
    '-MaxIterations'
    '2'
    '-AgentCommand'
    $mockAgentCommand
    '-VerifyCommand'
    $verifyOnePassCommand
    '-RunsRoot'
    $runsRoot
)

$prdOutput = & powershell @prdArgs *>&1 | Out-String
$prdExitCode = $LASTEXITCODE

Assert-Equal '0' "$prdExitCode" 'PRD workflow should stop after verification succeeds.'
Assert-Equal $prdBefore (Get-Content -Raw -Path $prdFile) 'PRD workflow must not mutate prd.json.'
Assert-Equal $progressBefore (Get-Content -Raw -Path $progressFile) 'PRD workflow must not mutate progress.txt.'
Assert-True ($prdOutput -match 'Workflow\s+:\s+Prd') 'PRD workflow should be reported in the run header.'

$runDir = Get-ChildItem -Path $runsRoot -Directory | Select-Object -First 1
Assert-True ($null -ne $runDir) 'Expected a PRD workflow run directory.'

$runMetadata = Get-Content -Raw -Path (Join-Path $runDir.FullName 'run.json') | ConvertFrom-Json
Assert-Equal 'Prd' $runMetadata.workflow 'Run metadata should record PRD workflow.'
Assert-Equal $prdFile $runMetadata.prdFile 'Run metadata should record PRD path.'
Assert-Equal $progressFile $runMetadata.progressFile 'Run metadata should record progress path.'
Assert-Equal 'US-001' $runMetadata.selectedStory.id 'Run metadata should record the selected story.'

$iterationDir = Join-Path $runDir.FullName 'iter-001'
$promptText = Get-Content -Raw -Path (Join-Path $iterationDir 'prompt.txt')
$selectedStory = Get-Content -Raw -Path (Join-Path $iterationDir 'selected-story.json') | ConvertFrom-Json
$progressContext = Get-Content -Raw -Path (Join-Path $iterationDir 'progress-context.txt')
$agentSnapshot = Get-Content -Raw -Path (Join-Path $iterationDir 'agent-snapshot.json') | ConvertFrom-Json

Assert-Equal 'US-001' $selectedStory.id 'Selected story artifact should contain the chosen story.'
Assert-True ($progressContext -match 'Preserve existing loop runner behavior') 'Progress context artifact should contain progress text.'
Assert-True ($promptText -match 'US-001') 'Rendered PRD prompt should include the selected story id.'
Assert-True ($promptText -match 'Selected story') 'Rendered PRD prompt should include the selected story title.'
Assert-True ($promptText -match 'Render acceptance criteria') 'Rendered PRD prompt should include acceptance criteria.'
Assert-True ($promptText -match 'Important note') 'Rendered PRD prompt should include story notes.'
Assert-True ($promptText -match 'RalphLoop') 'Rendered PRD prompt should include PRD project metadata.'
Assert-True ($promptText -match 'ralph/prd-workflow') 'Rendered PRD prompt should include PRD branch metadata.'
Assert-True ($promptText -match 'Preserve existing loop runner behavior') 'Rendered PRD prompt should include progress text.'
Assert-True ($agentSnapshot.promptText -match 'US-001') 'Agent stdin should receive the rendered PRD prompt.'

$completePrdFile = Join-Path $tmpRoot 'prd-complete.json'
$completeRunsRoot = Join-Path $tmpRoot 'runs-prd-complete'

$completePrdJson = @'
{
  "project": "RalphLoop",
  "branchName": "ralph/complete",
  "description": "All done",
  "userStories": [
    {
      "id": "US-001",
      "title": "Completed",
      "description": "Done",
      "acceptanceCriteria": ["Done"],
      "priority": 1,
      "passes": true,
      "notes": ""
    }
  ]
}
'@

Set-Content -Path $completePrdFile -Value $completePrdJson -Encoding UTF8

$completeArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'complete prd smoke'
    '-Workflow'
    'Prd'
    '-PrdFile'
    $completePrdFile
    '-MaxIterations'
    '2'
    '-AgentCommand'
    $mockAgentCommand
    '-RunsRoot'
    $completeRunsRoot
)

$completeOutput = & powershell @completeArgs *>&1 | Out-String
$completeExitCode = $LASTEXITCODE

Assert-Equal '0' "$completeExitCode" 'Complete PRD workflow should exit successfully without running an agent.'

$completeRunDir = Get-ChildItem -Path $completeRunsRoot -Directory | Select-Object -First 1
Assert-True ($null -ne $completeRunDir) 'Expected a complete PRD run directory.'
Assert-True (-not (Test-Path (Join-Path $completeRunDir.FullName 'iter-001'))) 'Complete PRD should not create iteration directories.'

$completeState = Get-Content -Raw -Path (Join-Path $completeRunDir.FullName 'state.json') | ConvertFrom-Json
Assert-Equal 'prd-complete' $completeState.reason 'Complete PRD should record prd-complete final state.'
Assert-True ($completeOutput -match 'PRD workflow has no incomplete stories') 'Complete PRD should report that no stories remain.'

Write-Output 'ralph-loop PRD workflow tests passed'
