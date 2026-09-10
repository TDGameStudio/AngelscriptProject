#requires -Version 7.0
[CmdletBinding()]
param([string]$Executable, [string]$ExercisePath, [string]$ScenarioPath, [string]$OwnedDeltaPath, [string]$CurrentSpecPath)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
if ([string]::IsNullOrWhiteSpace($Executable)) {
    $Executable = Join-Path $projectRoot '.agents/skills/openspec/bin/openspec.exe'
}
$Executable = (Resolve-Path -LiteralPath $Executable).Path
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$scratch = Join-Path $tempBase ('openspec-authoring-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($scratch)

function Invoke-AuthoringCli {
    param([string[]]$Arguments, [switch]$ExpectFailure)
    $output = @(& $Executable @Arguments 2>&1)
    $code = $LASTEXITCODE
    if (($ExpectFailure -and $code -eq 0) -or (-not $ExpectFailure -and $code -ne 0)) {
        throw "Unexpected exit $code for $($Arguments -join ' '): $($output -join "`n")"
    }
    $output -join "`n"
}

function Get-FilledExample {
    param([string]$RelativePath)
    $text = Get-Content -LiteralPath (Join-Path $projectRoot $RelativePath) -Raw
    $match = [regex]::Match($text, '(?ms)^````markdown\r?\n(.*?)^````\s*$')
    if (-not $match.Success) { throw "Missing filled example: $RelativePath" }
    $match.Groups[1].Value
}

function Complete-Scaffold {
    param([string]$RelativePath)
    $text = Get-Content -LiteralPath (Join-Path $projectRoot $RelativePath) -Raw
    [regex]::Replace($text, '(?s)<!--.*?-->', 'Documented fixture')
}

Push-Location -LiteralPath $scratch
try {
    [void](Invoke-AuthoringCli -Arguments @('init', '.', '--project-id', 'authoring-fixture'))
    [void](Invoke-AuthoringCli -Arguments @('domain', 'create', 'fixture'))
    [void](Invoke-AuthoringCli -Arguments @('change', 'create', 'fixture/authoring'))
    [void](Invoke-AuthoringCli -Arguments @('spec', 'create', 'fixture/behavior'))
    $taskPath = Join-Path $scratch 'openspec/changes/fixture/authoring/tasks.md'
    $specPath = Join-Path $scratch 'openspec/specs/fixture/behavior/spec.md'
    [IO.File]::WriteAllText((Join-Path $scratch 'openspec/changes/fixture/authoring/proposal.md'), 'Exercise maintained authoring examples.')

    $example = Get-FilledExample '.agents/skills/openspec/references/tasks.md'
    [IO.File]::WriteAllText($taskPath, $example)
    $plan = (Invoke-AuthoringCli -Arguments @('instructions', 'apply', '--change', 'fixture/authoring', '--json')) | ConvertFrom-Json
    if ($plan.tasks.Count -ne 1 -or -not $plan.tasks[0].ready -or $plan.tasks[0].verify -cne 'cargo test option_policy' -or ($plan.tasks[0].files -join '|') -cne 'src/options.rs|tests/option_policy.rs') {
        throw 'Filled Task example did not preserve its exact executable projection.'
    }

    $taskTemplate = Complete-Scaffold 'openspec/workflows/angelscript/templates/tasks.md'
    $taskTemplate = $taskTemplate.Replace('<exact executable proving command>', 'cargo test fixture_contract')
    [IO.File]::WriteAllText($taskPath, $taskTemplate)
    $plan = (Invoke-AuthoringCli -Arguments @('instructions', 'apply', '--change', 'fixture/authoring', '--json')) | ConvertFrom-Json
    if ($plan.tasks.Count -ne 1 -or -not $plan.tasks[0].ready -or $plan.tasks[0].verify -cne 'cargo test fixture_contract') {
        throw "Completed Task scaffold is not executable: $($plan | ConvertTo-Json -Depth 10)"
    }

    $specExample = Get-FilledExample '.agents/skills/openspec/references/specs.md'
    [IO.File]::WriteAllText($specPath, "## Purpose`nPreserve a durable ancestry contract.`n`n## Requirements`n`n$specExample")
    [void](Invoke-AuthoringCli -Arguments @('validate', '--all', '--strict', '--json'))

    if (-not [string]::IsNullOrWhiteSpace($ExercisePath)) {
        $exercise = Get-Content -LiteralPath $ExercisePath -Raw
        $cards = [regex]::Matches($exercise, '(?ms)^````markdown\r?\n(.*?)^````\s*$')
        foreach ($card in $cards) {
            $body = $card.Groups[1].Value
            if ($body.StartsWith('---')) {
                [IO.File]::WriteAllText($taskPath, $body)
            }
            elseif ($body.StartsWith('## Purpose')) {
                [IO.File]::WriteAllText($specPath, $body.Replace('## ADDED Requirements', '## Requirements'))
            }
        }
        [void](Invoke-AuthoringCli -Arguments @('validate', '--all', '--strict', '--json'))
    }
    if (-not [string]::IsNullOrWhiteSpace($ScenarioPath)) {
        $scenario = Get-Content -LiteralPath $ScenarioPath -Raw
        [IO.File]::WriteAllText($specPath, $scenario.Replace('## ADDED Requirements', '## Requirements'))
        [void](Invoke-AuthoringCli -Arguments @('validate', '--all', '--strict', '--json'))
    }
    if (-not [string]::IsNullOrWhiteSpace($OwnedDeltaPath)) {
        $delta = (Get-Content -LiteralPath $OwnedDeltaPath -Raw).Replace("`r`n", "`n")
        $current = (Get-Content -LiteralPath $CurrentSpecPath -Raw).Replace("`r`n", "`n")
        $owned = [regex]::Matches($delta, '(?ms)^### Requirement: (.*?)\n.*?(?=^### Requirement: |\z)')
        if ($owned.Count -ne 3) { throw 'Expected exactly three owned authoring requirements.' }
        foreach ($requirement in $owned) {
            if (-not $current.Contains($requirement.Value.TrimEnd())) { throw 'Synchronization changed or lost an owned requirement card.' }
        }
        [IO.File]::WriteAllText($specPath, "## Purpose`nPreserve the owned authoring contract.`n`n" + $delta.Replace('## MODIFIED Requirements', '## Requirements'))
        [void](Invoke-AuthoringCli -Arguments @('validate', '--all', '--strict', '--json'))
    }
    $specTemplate = (Complete-Scaffold 'openspec/workflows/angelscript/templates/spec.md').Replace('## ADDED Requirements', '## Requirements')
    [IO.File]::WriteAllText($specPath, $specTemplate)
    [void](Invoke-AuthoringCli -Arguments @('validate', '--all', '--strict', '--json'))

    [IO.File]::WriteAllText($taskPath, '- [ ] 1.1 Retired format — verify: `never`' + "`n" + '  > Files: `old.rs`')
    $plan = (Invoke-AuthoringCli -Arguments @('instructions', 'apply', '--change', 'fixture/authoring', '--json')) | ConvertFrom-Json
    $readyCount = if ('tasks' -in $plan.PSObject.Properties.Name) { @($plan.tasks | Where-Object ready).Count } else { 0 }
    if ('unsupported-task-format' -notin @($plan.taskIssues.code) -or $readyCount -ne 0) {
        throw 'Retired Task format did not produce migration diagnostics with zero Ready work.'
    }
    [IO.File]::WriteAllText($taskPath, $example)
    [IO.File]::WriteAllText($specPath, "## Purpose`nPreserve a durable contract.`n`n## Requirements`n### Requirement: Failure`nThe system SHALL reject invalid cards.`n`n#### Scenario: Missing result`n`n- **WHEN** invoked`n")
    $failure = Invoke-AuthoringCli -Arguments @('validate', '--all', '--strict', '--json') -ExpectFailure
    if (-not $failure.Contains('WHEN and THEN')) { throw 'Scenario negative control failed for an unrelated reason.' }
    Write-Host 'Authoring tests passed: filled Task/Spec examples, completed scaffolds, exact Task projection, old-format and missing-clause negative controls.'
}
finally {
    Pop-Location
    $resolved = [IO.Path]::GetFullPath($scratch)
    if (-not $resolved.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notlike 'openspec-authoring-*') {
        throw "Refusing cleanup outside the exact authoring fixture: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
