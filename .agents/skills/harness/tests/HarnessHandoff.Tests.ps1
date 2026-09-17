#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('harness-handoff-' + [guid]::NewGuid().ToString('N'))
$context = [pscustomobject]@{ WorkspaceRoot=$fixtureRoot; HarnessRoot=$projectRoot; PrimaryRoot=$fixtureRoot; GitCommonDir=$fixtureRoot; Topology='Primary'; Branch='fixture'; Head=('1' * 40) }
$failures = [Collections.Generic.List[string]]::new()
$checkCount = 0
function Check($want, $got, $label) {
    $script:checkCount++
    if ($want -ne $got) { $failures.Add("$label expected=$want actual=$got") }
}
function Write-Utf8($path, $text) {
    [void][IO.Directory]::CreateDirectory((Split-Path $path -Parent))
    [IO.File]::WriteAllText($path, $text)
}
try {
    [void][IO.Directory]::CreateDirectory($fixtureRoot)
    $exe = Join-Path $projectRoot '.agents/skills/openspec/bin/openspec.exe'
    & $exe init $fixtureRoot --project-id fixture --title Fixture --workflow angelscript | Out-Null
    [void](Invoke-Harness openspec.domain -Context $context -ArgumentList @('create','harness','--title','Harness','--json'))
    [void](Invoke-Harness harness.draft.create -Context $context -Parameters @{DraftId='harness/fixture'; Title='Fixture'})
    $draft = Join-Path $fixtureRoot 'openspec/drafts/harness/fixture'
    $selected = Join-Path $draft 'designs/selected'
    $readme = "---`ndesign: selected`nstatus: designed`napproval_round: R2`n---`nDiscussed at R1.`n"
    $handoff = @'
## OpenSpec Handoff

- Scope: selected
- Target Change: harness/improve-handoff-evidence

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| not-applicable | attachments/drafts/glossary.md | No public naming decisions |
| ../../findings/evidence.md | attachments/talks/promised.md | Approved rationale |
'@
    Write-Utf8 (Join-Path $draft 'log.md') "## R1`nExplained.`n## R2`nApproved selected scope.`n"
    Write-Utf8 (Join-Path $draft 'findings/evidence.md') '# Evidence'
    Write-Utf8 (Join-Path $selected 'README.md') $readme
    Write-Utf8 (Join-Path $selected 'design.md') '# Selected'
    Write-Utf8 (Join-Path $selected 'handoff.md') $handoff
    $parameters = @{DraftId='harness/fixture'; Scope='selected'; ChangeId='harness/improve-handoff-evidence'}
    $valid = Invoke-Harness harness.draft.check -Context $context -Parameters $parameters
    Check Succeeded $valid.status 'research focus can hand off a different approved scope'
    Check R2 $valid.data.ApprovalRound 'explicit approval wins over first mentioned round'
    foreach ($case in @(
        @{Name='incidental round is not approval'; Text=$readme.Replace("approval_round: R2`n", '')},
        @{Name='body example is not approval metadata'; Text=($readme.Replace("approval_round: R2`n", '') + "`napproval_round: R2`n")},
        @{Name='wrong design identity'; Text=$readme.Replace('design: selected','design: sibling')},
        @{Name='nonexistent approval'; Text=$readme.Replace('approval_round: R2','approval_round: R9')}
    )) {
        Write-Utf8 (Join-Path $selected 'README.md') $case.Text
        Check Failed (Invoke-Harness harness.draft.check -Context $context -Parameters $parameters).status $case.Name
    }
    Write-Utf8 (Join-Path $selected 'README.md') $readme
    foreach ($case in @(
        @{Name='wrong exact target'; Text=$handoff.Replace('harness/improve-handoff-evidence','harness/improve-handoff-evidence-extra')},
        @{Name='wrong handoff scope'; Text=$handoff.Replace('Scope: selected','Scope: sibling')},
        @{Name='missing carryover table'; Text=$handoff.Split('|')[0]},
        @{Name='escaping carryover target'; Text=$handoff.Replace('attachments/talks/promised.md','../outside.md')}
    )) {
        Write-Utf8 (Join-Path $selected 'handoff.md') $case.Text
        Check Failed (Invoke-Harness harness.draft.check -Context $context -Parameters $parameters).status $case.Name
    }
    Write-Utf8 (Join-Path $selected 'handoff.md') $handoff
    $created = Invoke-Harness harness.change.create -Context $context -Parameters ($parameters + @{Title='Handoff'; Goal='Freeze expected exports'; Origin='Draft'})
    Check Succeeded $created.status 'create with explicit approved source'
    $change = Join-Path $fixtureRoot 'openspec/changes/harness/improve-handoff-evidence'
    $markerPath = Join-Path $change 'attachments/data/harness-origin.json'
    $marker = Get-Content $markerPath -Raw | ConvertFrom-Json
    Check 2 $marker.schema 'new marker uses schema 2'
    Write-Utf8 (Join-Path $change 'attachments/drafts/design.md') '# Design'
    Write-Utf8 (Join-Path $change 'attachments/drafts/handoff.md') $handoff
    Write-Utf8 (Join-Path $change 'attachments/drafts/glossary.md') '# No names'
    $index = "- [Design](drafts/design.md)`n- [Handoff](drafts/handoff.md)`n- [Glossary](drafts/glossary.md)`n- [Origin](data/harness-origin.json)`n"
    Write-Utf8 (Join-Path $change 'attachments/INDEX.md') $index
    Check Failed (Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$parameters.ChangeId}).status 'promised file missing despite otherwise complete index'
    Write-Utf8 (Join-Path $change 'attachments/talks/promised.md') '# Rationale'
    $index += "- [Rationale](talks/promised.md)`n"
    Write-Utf8 (Join-Path $change 'attachments/INDEX.md') $index
    Check Succeeded (Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$parameters.ChangeId}).status 'all promised files exist and are indexed'
    Write-Utf8 (Join-Path $change 'attachments/INDEX.md') ($index + "- [Again](talks/promised.md)`n")
    Check Failed (Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$parameters.ChangeId}).status 'duplicate index blocks seed'
    Write-Utf8 (Join-Path $change 'attachments/INDEX.md') $index
    Write-Utf8 (Join-Path $change 'attachments/talks/promised.md') '[Missing](missing.md)'
    Check Failed (Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$parameters.ChangeId}).status 'broken carried link blocks seed'
    Write-Utf8 (Join-Path $change 'attachments/talks/promised.md') '# Rationale'
    # Existing schema 1 Changes retain their original gate, without a draft migration.
    $marker.schema = 1
    Write-Utf8 $markerPath ($marker | ConvertTo-Json -Depth 8)
    Check Succeeded (Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$parameters.ChangeId}).status 'schema 1 compatibility'
    if ($failures.Count) { throw ($failures -join "`n") }
    "Harness handoff tests passed ($checkCount contract checks)."
}
finally {
    $resolved = [IO.Path]::GetFullPath($fixtureRoot)
    $expected = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar + 'harness-handoff-'
    if (-not $resolved.StartsWith($expected, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe fixture cleanup' }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
