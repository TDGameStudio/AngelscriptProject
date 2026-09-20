#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
. (Join-Path $PSScriptRoot 'HistoricalChangeFixture.ps1')
function Check($condition, $message) { if (-not $condition) { throw $message } }
function Write-Fixture($path, $text) { [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path)); [IO.File]::WriteAllText($path, $text) }
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('harness-handoff-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($fixture)
$context = [pscustomobject]@{HarnessRoot=$projectRoot;WorkspaceRoot=$fixture;PrimaryRoot=$fixture;GitCommonDir=$fixture;Topology='Primary';Branch='fixture';Head=('1' * 40)}
try {
    $exe = Join-Path $projectRoot '.agents/skills/openspec/bin/openspec.exe'
    & $exe init $fixture --project-id fixture --title Fixture --workflow angelscript | Out-Null
    if ($LASTEXITCODE) { throw 'OpenSpec fixture initialization failed' }
    $domain = Invoke-Harness openspec.domain -Context $context -ArgumentList @('create','harness','--title','Harness','--json')
    Check ($domain.status -eq 'Succeeded') 'domain initialization failed'
    $draft = Invoke-Harness harness.draft.create -Context $context -Parameters @{DraftId='harness/modern';Title='Modern selected scope'}
    $selected = Join-Path $draft.data.Path 'designs/selected'
    Write-Fixture (Join-Path $selected 'design.md') "---`ndesign: selected`nstatus: designed`n---`n`n# Architecture`n`nA -> B. Terms live here.`n"
    Write-Fixture (Join-Path $selected 'handoff.md') "## OpenSpec Handoff`n`n- Scope: selected`n- Target Change: harness/improve-modern-handoff`n`n## Exploration Carryover`n`n| Source | Target | Reason |`n| --- | --- | --- |`n| design.md | attachments/drafts/design.md | Accepted architecture and terms |`n| handoff.md | attachments/drafts/handoff.md | Explicit target |`n"
    $sourceBinary = Join-Path $draft.data.Path 'attachments/diagram.png'
    [void][IO.Directory]::CreateDirectory((Split-Path $sourceBinary -Parent))
    $approvedBytes = [byte[]]@(137,80,78,71,1,2,3)
    [IO.File]::WriteAllBytes($sourceBinary, $approvedBytes)
    Add-Content -LiteralPath (Join-Path $selected 'handoff.md') -Value '| ../../attachments/diagram.png | attachments/drafts/diagram.png | Approved diagram bytes |'
    $params = @{ChangeId='harness/improve-modern-handoff';Title='Modern';Goal='Modern handoff';Origin='Draft';DraftId='harness/modern';Scope='selected';SessionId='fixture-handoff'}
    $metadataFailures = @()
    $originalHandoff = [IO.File]::ReadAllText((Join-Path $selected 'handoff.md'))
    foreach ($field in @('Title','Goal')) {
        $exact = $params.Clone(); $exact.ChangeId = 'harness/improve-bound-' + $field.ToLowerInvariant()
        Write-Fixture (Join-Path $selected 'handoff.md') ($originalHandoff.Replace($params.ChangeId, $exact.ChangeId))
        $shown = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($exact + @{PlanOnly=$true})
        Check ($shown.status -eq 'Succeeded') "$field preview failed"
        $metadataGate = @{ConvergenceSource='message:ready';DecisionSource='message:create';Decision='create';TargetChange=$exact.ChangeId;HandoffRevision=$shown.data.HandoffRevision}
        $changed = $exact.Clone(); $changed[$field] = 'Export local data to a remote service'
        $changedPreview = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($changed + @{PlanOnly=$true})
        $rejected = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($changed + @{Gate=$metadataGate})
        $nativeRoot = Join-Path $fixture ('openspec/changes/' + $exact.ChangeId)
        $intentFolder = Join-Path $fixture 'Saved/Harness/ChangeCreates'
        $hasIntent = [IO.Directory]::Exists($intentFolder) -and [IO.Directory]::GetFiles($intentFolder, '*.json').Length -gt 0
        if ($changedPreview.data.HandoffRevision -eq $shown.data.HandoffRevision -or $rejected.status -ne 'Failed' -or (Test-Path $nativeRoot) -or $hasIntent) {
            $metadataFailures += "$field changed without invalidating the exact Gate before native creation"
            continue
        }
        $acceptedExact = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($exact + @{Gate=$metadataGate})
        Check ($acceptedExact.status -eq 'Succeeded') "$field exact approved retry failed"
        $retriedExact = Invoke-HistoricalFixtureCreate -Context $context -Parameters $exact
        Check ($retriedExact.status -eq 'Succeeded' -and $retriedExact.data.Resumed) "$field consumed exact retry failed"
    }
    Write-Fixture (Join-Path $selected 'handoff.md') $originalHandoff
    Check ($metadataFailures.Count -eq 0) ($metadataFailures -join '; ')
    # An already consumed pre-fix draft receipt remains recoverable with its
    # original request and original digest, even though new approvals bind metadata.
    $historicalParams = $params.Clone(); $historicalParams.ChangeId = 'historical/improve-draft-recovery'
    Write-Fixture (Join-Path $selected 'handoff.md') ($originalHandoff.Replace($params.ChangeId, $historicalParams.ChangeId))
    $historicalPreview = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($historicalParams + @{PlanOnly=$true})
    $historicalGate = @{ConvergenceSource='message:ready';DecisionSource='message:create';Decision='create';TargetChange=$historicalParams.ChangeId;HandoffRevision=$historicalPreview.data.HandoffRevision}
    $nativeFailure = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($historicalParams + @{Gate=$historicalGate})
    Check ($nativeFailure.status -eq 'Failed' -and $nativeFailure.error.message -match 'OpenSpec change create failed') 'historical retry fixture did not reach its missing-domain native prerequisite'
    $historicalIntentPath = [IO.Directory]::GetFiles((Join-Path $fixture 'Saved/Harness/ChangeCreates'), '*.json')[0]
    $historicalIntent = Get-Content -LiteralPath $historicalIntentPath -Raw | ConvertFrom-Json -AsHashtable
    $historicalDraft = $historicalPreview.data.Draft | ConvertTo-Json -Depth 30 | ConvertFrom-Json -AsHashtable
    $historicalDraft.ExpectedExports = @($historicalDraft.ExpectedExports | ForEach-Object { @{Source=$_.Source;Target=$_.Target;Reason=$_.Reason} })
    # Independent serialization of the historical protocol fixture: its Title
    # and Goal slots were empty for draft-origin handoffs.
    $historicalBasis = @{operation='create';target=$historicalParams.ChangeId;draft=$historicalDraft;handoff_text='';title='';goal='';reason='';candidates=@{};baselines=@{}}
    $historicalRevision = (($historicalBasis | ConvertTo-Json -Depth 30 -Compress) | & python -X utf8 -c 'import hashlib,json,sys; print(hashlib.sha256(json.dumps(json.load(sys.stdin),sort_keys=True,ensure_ascii=False,separators=(",", ":")).encode("utf8")).hexdigest())').Trim()
    $historicalIntent.marker.gate.revision = $historicalRevision
    [void]$historicalIntent.marker.gate.Remove('revision_schema')
    [void]$historicalIntent.marker.gate.Remove('export_digest_schema')
    [void]$historicalIntent.marker.gate.Remove('expected_exports')
    [void]$historicalIntent.marker.Remove('exportDigestSchema')
    $historicalIntent.marker.expectedExports = $historicalDraft.ExpectedExports
    Write-Fixture $historicalIntentPath ($historicalIntent | ConvertTo-Json -Depth 30)
    $historicalDomain = Invoke-Harness openspec.domain -Context $context -ArgumentList @('create','historical','--title','Historical','--json')
    Check ($historicalDomain.status -eq 'Succeeded') 'historical retry domain setup failed'
    $historicalRetry = Invoke-HistoricalFixtureCreate -Context $context -Parameters $historicalParams
    if ($historicalRetry.status -ne 'Succeeded') { throw $historicalRetry.error.message }
    Check ($historicalRetry.data.HandoffId -eq $historicalIntent.marker.gate.handoff_id) 'historical exact retry replaced consumed authority'
    Write-Fixture (Join-Path $selected 'handoff.md') $originalHandoff
    $preview = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($params + @{PlanOnly=$true})
    if ($preview.status -ne 'Succeeded') { throw $preview.error.message }
    Check (-not (Test-Path (Join-Path $fixture 'openspec/changes/harness/improve-modern-handoff'))) 'PlanOnly created formal records'
    $checked = Invoke-Harness harness.draft.check -Context $context -Parameters @{DraftId='harness/modern';Scope='selected';ChangeId=$params.ChangeId}
    Check ($checked.data.DraftRevision -eq $preview.data.DraftRevision) 'draft.check and create preview disagree about draft content'
    Check ($checked.data.DraftRevision -ne $preview.data.HandoffRevision) 'draft-only revision masquerades as the full Create request'
    $missing = Invoke-HistoricalFixtureCreate -Context $context -Parameters $params
    Check ($missing.status -eq 'Failed') 'missing user Gate was accepted'
    $gate = @{ConvergenceSource='message:ready';DecisionSource='message:create';Decision='create';TargetChange=$params.ChangeId;HandoffRevision=$preview.data.HandoffRevision}
    $emptySource = $gate.Clone(); $emptySource.DecisionSource=''
    Check ((Invoke-HistoricalFixtureCreate -Context $context -Parameters ($params + @{Gate=$emptySource})).status -eq 'Failed') 'empty actual answer source was accepted'
    Add-Content -LiteralPath (Join-Path $selected 'design.md') -Value 'A changed boundary'
    Check ((Invoke-HistoricalFixtureCreate -Context $context -Parameters ($params + @{Gate=$gate})).status -eq 'Failed') 'stale design Gate was accepted'
    $updated = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($params + @{PlanOnly=$true})
    $gate.HandoffRevision = $updated.data.HandoffRevision
    $created = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($params + @{Gate=$gate})
    if ($created.status -ne 'Succeeded') { throw $created.error.message }
    $changeRoot = $created.data.Path
    $origin = Get-Content -LiteralPath (Join-Path $changeRoot 'attachments/data/harness-origin.json') -Raw | ConvertFrom-Json
    Check ($origin.schema -eq 3) 'new origin is not schema 3'
    Check ($origin.expectedExports.Count -eq 3) 'modern terms require an invented glossary or omit the binary'
    $followup = Join-Path $changeRoot ('attachments/talks/' + $origin.gate.post_talk_id + '.md')
    Check ((Get-Content -LiteralPath $followup -Raw) -match 'handoff-followup') 'creation omitted follow-up decisions'
    $originalFollowup = [IO.File]::ReadAllText($followup)
    [IO.File]::WriteAllText($followup, '# Broken follow-up')
    $broken = Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$params.ChangeId}
    Check ($broken.status -eq 'Failed') 'malformed mandatory follow-up was silently accepted'
    [IO.File]::WriteAllText($followup, $originalFollowup)
    Copy-Item -LiteralPath (Join-Path $selected 'design.md') -Destination (Join-Path $fixture 'design-copy.md')
    Write-Fixture (Join-Path $changeRoot 'attachments/drafts/design.md') ([IO.File]::ReadAllText((Join-Path $selected 'design.md')))
    Write-Fixture (Join-Path $changeRoot 'attachments/drafts/handoff.md') ([IO.File]::ReadAllText((Join-Path $selected 'handoff.md')))
    Add-Content -LiteralPath (Join-Path $changeRoot 'attachments/INDEX.md') -Value "- [Design](drafts/design.md)`n- [Handoff](drafts/handoff.md)"
    $exportedBinary = Join-Path $changeRoot 'attachments/drafts/diagram.png'
    [IO.File]::WriteAllBytes($exportedBinary, $approvedBytes)
    Add-Content -LiteralPath (Join-Path $changeRoot 'attachments/INDEX.md') -Value '- [Diagram](drafts/diagram.png)'
    $seed = Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$params.ChangeId}
    if ($seed.status -ne 'Succeeded') { throw $seed.error.message }
    [IO.File]::WriteAllBytes($exportedBinary, [byte[]]@(9,9,9))
    $changedBytes = Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$params.ChangeId}
    [IO.File]::WriteAllBytes($exportedBinary, $approvedBytes)
    [IO.File]::WriteAllBytes($sourceBinary, [byte[]]@(8,8,8))
    Write-Fixture (Join-Path $changeRoot 'attachments/drafts/design.md') '# Intentionally translated accepted design'
    $evolvedSource = Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$params.ChangeId}
    $archived = Invoke-Harness harness.draft.archive -Context $context -Parameters @{DraftId='harness/modern';SourceRef='message:archive';Reason='Archive unresolved topic explicitly'}
    Check ($archived.status -eq 'Succeeded') 'explicit archive failed'
    [IO.File]::WriteAllBytes($exportedBinary, [byte[]]@(7,7,7))
    $changedAfterArchive = Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$params.ChangeId}
    [IO.File]::WriteAllBytes($exportedBinary, $approvedBytes)
    $correctAfterArchive = Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$params.ChangeId}
    $binaryFailures = @()
    if ($changedBytes.status -ne 'Failed') { $binaryFailures += 'changed binary bytes passed seed verification' }
    if ($changedAfterArchive.status -ne 'Failed') { $binaryFailures += 'changed binary bytes passed after source archive' }
    if ($evolvedSource.status -ne 'Succeeded' -or $correctAfterArchive.status -ne 'Succeeded') { $binaryFailures += 'accepted binary or translated Markdown depends on the live draft' }
    Check ($binaryFailures.Count -eq 0) ($binaryFailures -join '; ')
    $resumed = Invoke-HistoricalFixtureCreate -Context $context -Parameters $params
    Check ($resumed.status -eq 'Succeeded' -and $resumed.data.Resumed) 'consumed Gate incorrectly requires unavailable draft on resume'
    Check ([IO.File]::ReadAllText($followup) -eq $originalFollowup) 'creation resume rewrote delivered follow-up state'
    # Preserve the pre-v2 scoped handoff contract without migrating its records.
    $legacyRoot = Join-Path $fixture 'openspec/drafts/harness/legacy'
    $legacyScope = Join-Path $legacyRoot 'designs/selected'
    Write-Fixture (Join-Path $legacyRoot 'README.md') "---`ndraft: harness/legacy`nmode: research`nstatus: exploring`nopened: 2026-09-17`n---`n`n- **此刻**：Research`n- **焦点**：[Log](log.md)`n- **已决**：R2`n- **下一问**：Another scope`n- **讲清于**：[R1](log.md#r1) · 2026-09-17`n"
    Write-Fixture (Join-Path $legacyRoot 'log.md') "## R1`nExplained.`n## R2`nApproved selected scope.`n"
    Write-Fixture (Join-Path $legacyRoot 'findings/evidence.md') '# Evidence'
    $legacyReadme = "---`ndesign: selected`nstatus: designed`napproval_round: R2`n---`nDiscussed at R1.`n"
    $legacyHandoff = @'
## OpenSpec Handoff

- Scope: selected
- Target Change: harness/improve-legacy-evidence

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| not-applicable | attachments/drafts/glossary.md | No public names |
| ../../findings/evidence.md | attachments/talks/promised.md | Approved rationale |
'@
    Write-Fixture (Join-Path $legacyScope 'README.md') $legacyReadme
    Write-Fixture (Join-Path $legacyScope 'design.md') '# Selected'
    Write-Fixture (Join-Path $legacyScope 'handoff.md') $legacyHandoff
    $legacyParams = @{DraftId='harness/legacy';Scope='selected';ChangeId='harness/improve-legacy-evidence'}
    $validLegacy = Invoke-Harness harness.draft.check -Context $context -Parameters $legacyParams
    Check ($validLegacy.status -eq 'Succeeded' -and $validLegacy.data.ApprovalRound -eq 'R2') 'legacy selected approval must be independent of topic focus and incidental round mentions'
    foreach ($case in @(
        $legacyReadme.Replace("approval_round: R2`n", ''),
        ($legacyReadme.Replace("approval_round: R2`n", '') + "`napproval_round: R2`n"),
        $legacyReadme.Replace('design: selected','design: sibling'),
        $legacyReadme.Replace('approval_round: R2','approval_round: R9')
    )) {
        Write-Fixture (Join-Path $legacyScope 'README.md') $case
        Check ((Invoke-Harness harness.draft.check -Context $context -Parameters $legacyParams).status -eq 'Failed') 'invalid legacy approval metadata passed'
    }
    Write-Fixture (Join-Path $legacyScope 'README.md') $legacyReadme
    foreach ($case in @(
        $legacyHandoff.Replace('harness/improve-legacy-evidence','harness/improve-legacy-evidence-extra'),
        $legacyHandoff.Replace('Scope: selected','Scope: sibling'),
        $legacyHandoff.Split('|')[0],
        $legacyHandoff.Replace('attachments/talks/promised.md','../outside.md')
    )) {
        Write-Fixture (Join-Path $legacyScope 'handoff.md') $case
        Check ((Invoke-Harness harness.draft.check -Context $context -Parameters $legacyParams).status -eq 'Failed') 'invalid legacy target or carryover passed'
    }
    Write-Fixture (Join-Path $legacyScope 'handoff.md') $legacyHandoff
    $legacyCreate = $legacyParams + @{Title='Legacy';Goal='Preserve legacy contracts';Origin='Draft';SessionId='fixture-legacy'}
    $legacyPreview = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($legacyCreate + @{PlanOnly=$true})
    $legacyGate = @{ConvergenceSource='message:legacy-ready';DecisionSource='message:legacy-create';Decision='create';TargetChange=$legacyParams.ChangeId;HandoffRevision=$legacyPreview.data.HandoffRevision}
    $legacyCreated = Invoke-HistoricalFixtureCreate -Context $context -Parameters ($legacyCreate + @{Gate=$legacyGate})
    if ($legacyCreated.status -ne 'Succeeded') { throw $legacyCreated.error.message }
    $legacyChange = $legacyCreated.data.Path
    Write-Fixture (Join-Path $legacyChange 'attachments/drafts/design.md') '# Design'
    Write-Fixture (Join-Path $legacyChange 'attachments/drafts/handoff.md') $legacyHandoff
    Write-Fixture (Join-Path $legacyChange 'attachments/drafts/glossary.md') '# No names'
    $legacyIndex = [IO.File]::ReadAllText((Join-Path $legacyChange 'attachments/INDEX.md')) + "- [Design](drafts/design.md)`n- [Handoff](drafts/handoff.md)`n- [Glossary](drafts/glossary.md)`n"
    Write-Fixture (Join-Path $legacyChange 'attachments/INDEX.md') $legacyIndex
    Check ((Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$legacyParams.ChangeId}).status -eq 'Failed') 'missing promised legacy carryover passed'
    Write-Fixture (Join-Path $legacyChange 'attachments/talks/promised.md') '# Rationale'
    $legacyIndex += "- [Rationale](talks/promised.md)`n"
    Write-Fixture (Join-Path $legacyChange 'attachments/INDEX.md') $legacyIndex
    Check ((Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$legacyParams.ChangeId}).status -eq 'Succeeded') 'complete legacy carryover failed'
    Write-Fixture (Join-Path $legacyChange 'attachments/INDEX.md') ($legacyIndex + "- [Again](talks/promised.md)`n")
    Check ((Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$legacyParams.ChangeId}).status -eq 'Failed') 'duplicate legacy index passed'
    Write-Fixture (Join-Path $legacyChange 'attachments/INDEX.md') $legacyIndex
    Write-Fixture (Join-Path $legacyChange 'attachments/talks/promised.md') '[Missing](missing.md)'
    Check ((Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$legacyParams.ChangeId}).status -eq 'Failed') 'broken legacy carried link passed'
    Write-Fixture (Join-Path $legacyChange 'attachments/talks/promised.md') '# Rationale'
    $legacyMarkerPath = Join-Path $legacyChange 'attachments/data/harness-origin.json'
    $legacyMarker = Get-Content -LiteralPath $legacyMarkerPath -Raw | ConvertFrom-Json
    $legacyMarker.PSObject.Properties.Remove('exportDigestSchema')
    $legacyMarker.gate.PSObject.Properties.Remove('revision_schema')
    $legacyMarker.gate.PSObject.Properties.Remove('export_digest_schema')
    $legacyMarker.gate.PSObject.Properties.Remove('expected_exports')
    foreach ($export in $legacyMarker.expectedExports) {
        $export.PSObject.Properties.Remove('Preservation')
        $export.PSObject.Properties.Remove('Sha256')
    }
    foreach ($schema in @(1,2,3)) {
        $legacyMarker.schema = $schema
        Write-Fixture $legacyMarkerPath ($legacyMarker | ConvertTo-Json -Depth 12)
        Check ((Invoke-Harness harness.change.seed.verify -Context $context -Parameters @{ChangeId=$legacyParams.ChangeId}).status -eq 'Succeeded') "historical schema $schema required new approval"
    }
    'Harness handoff tests passed.'
}
finally {
    $resolved = [IO.Path]::GetFullPath($fixture)
    $allowed = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar + 'harness-handoff-'
    if (-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe handoff fixture cleanup' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
