#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
$fixture = Join-Path $project ('Saved/AgentTemp/harness-feedback-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($fixture)
function Assert-True($Condition, $Message) { if (-not $Condition) { throw $Message } }
function Assert-Throws([scriptblock]$Action, $Message) { try { & $Action | Out-Null } catch { return }; throw $Message }
& git -C $fixture init --quiet
[IO.File]::WriteAllText((Join-Path $fixture '.gitignore'), "Saved/`n")
& git -C $fixture add .gitignore
& git -C $fixture -c user.name=Fixture -c user.email=fixture@example.invalid commit --quiet -m 'Fixture'
$context = [pscustomobject]@{ WorkspaceRoot=$fixture; HarnessRoot=$project; PrimaryRoot=$fixture; GitCommonDir=(Join-Path $fixture '.git'); Topology='Primary'; Branch='fixture'; Head=(& git -C $fixture rev-parse HEAD) }
$module = Import-Module (Join-Path $project '.agents/skills/harness/scripts/Harness.psd1') -Force -PassThru
$observed = Invoke-Harness harness.observe -Context $context -Parameters @{Category='Explain';Summary='Missing caller explanation';SourceRef='user:1';DedupKey='missing-callers';OwnerDraftId='harness/explain'}
if ($observed.status -ne 'Succeeded') { throw "Public observe failed: $($observed.error.message)" }
$first = $observed.data
$second = & $module { param($c) Add-HarnessObservation -Context $c -Category Explain -Summary 'Repeated caller omission' -SourceRef 'user:2' -DedupKey 'missing-callers' } $context
$read = { & $module { param($c) Get-HarnessEvolutionStatus -Context $c -InboxOnly -Limit 1 } $context }
$inbox = & $read
Assert-True ($inbox.Groups.Count -eq 1 -and $inbox.Groups[0].Count -eq 2 -and $inbox.Groups[0].Status -eq 'pending') 'Repeated observations must group without losing occurrences.'
$before = @(Get-ChildItem -LiteralPath $fixture -Recurse -File | ForEach-Object { $_.FullName + ':' + (Get-FileHash -LiteralPath $_.FullName).Hash }) -join "`n"
& $read | Out-Null
$after = @(Get-ChildItem -LiteralPath $fixture -Recurse -File | ForEach-Object { $_.FullName + ':' + (Get-FileHash -LiteralPath $_.FullName).Hash }) -join "`n"
Assert-True ($before -eq $after) 'Inbox query must not write any file.'
Import-Module (Join-Path $project '.agents/skills/harness/scripts/Feedback.psm1') -Force
Assert-Throws { Set-HarnessEvolutionTriage -Context $context -ObservationIds @($first.RunId) -Disposition selected -Scope 'Restore callers' } 'Selection requires an actual user decision source.'
$selected = Invoke-Harness harness.evolution.triage -Context $context -Parameters @{ObservationIds=@($first.RunId,$second.RunId);Disposition='selected';DecisionSource='user:3';Scope='Restore caller explanation only'}
Assert-True ($selected.status -eq 'Succeeded') 'Public triage must dispatch to the selected context.'
$retargeted = Invoke-Harness harness.evolution.triage -Context $context -Parameters @{Context=$context;ObservationIds=@($first.RunId);Disposition='dismissed';DecisionSource='user:other';Scope='Other'}
Assert-True ($retargeted.status -eq 'Failed' -and $retargeted.error.code -eq 'ContextAuthorityMismatch') 'Caller replacement of the selected feedback context must be rejected.'
Assert-Throws { Set-HarnessEvolutionTriage -Context $context -ObservationIds @($first.RunId) -Disposition resolved -Result 'fixed' } 'Resolution requires evidence.'
Set-HarnessEvolutionTriage -Context $context -ObservationIds @($first.RunId,$second.RunId) -Disposition resolved -Result 'Added caller method' -Evidence @('test:explain-pass') | Out-Null
$resolved = & $read
Assert-True ($resolved.Groups[0].Status -eq 'resolved' -and $resolved.Groups[0].Occurrences[0].Disposition.DecisionSource -eq 'user:3') 'Resolution must retain selection authorization.'
& $module { param($c) Add-HarnessObservation -Context $c -Category Explain -Summary 'Recurrence' -SourceRef 'user:4' -DedupKey 'missing-callers' } $context | Out-Null
Assert-True ((& $read).Groups[0].Status -eq 'pending') 'New recurrence must not inherit resolved disposition.'
Assert-Throws { Set-HarnessEvolutionTriage -Context $context -ObservationIds @('missing') -Disposition dismissed -DecisionSource 'user:5' -Scope 'Noise' } 'Unknown observation must not be classified.'
Assert-True (Test-Path -LiteralPath (Join-Path $fixture 'Saved/Harness/Observations/INBOX.md')) 'Mutation should render a human-readable inbox.'
$legacyPaths = @(foreach ($store in @('Harness','Hardness')) {
    $directory = Join-Path $fixture "Saved/$store/Observations"
    [void][IO.Directory]::CreateDirectory($directory)
    $path = Join-Path $directory 'legacy-no-optional-fields.json'
    [IO.File]::WriteAllText($path, (@{runId="legacy-$store";summary="Legacy $store observation";category='Explain';observedAtUtc='2026-09-18T00:00:00Z'} | ConvertTo-Json))
    $path
})
$legacyBefore = @($legacyPaths | ForEach-Object { (Get-FileHash -LiteralPath $_).Hash }) -join ':'
$legacyInbox = Get-HarnessFeedbackInbox -Context $context
Assert-True ($legacyInbox.Issues.Count -eq 0) "Legacy observations may omit optional dedupKey/sourceRef/ownerDraftId: $($legacyInbox.Issues -join '; ')"
foreach ($store in @('Harness','Hardness')) {
    $legacyGroup = @($legacyInbox.Groups | Where-Object Key -eq "id:legacy-$store")
    Assert-True ($legacyGroup.Count -eq 1 -and $legacyGroup[0].Count -eq 1 -and $legacyGroup[0].Status -eq 'pending') 'Legacy observations must remain individually addressable without a dedup key.'
    Assert-True ($null -eq $legacyGroup[0].Occurrences[0].SourceRef -and $null -eq $legacyGroup[0].Occurrences[0].OwnerDraftId) 'Missing legacy metadata must stay unset rather than inventing provenance.'
}
Set-HarnessEvolutionTriage -Context $context -ObservationIds @('legacy-Harness','legacy-Hardness') -Disposition selected -DecisionSource 'user:legacy' -Scope 'Inspect legacy observations' | Out-Null
$legacyAfter = @($legacyPaths | ForEach-Object { (Get-FileHash -LiteralPath $_).Hash }) -join ':'
Assert-True ($legacyBefore -eq $legacyAfter) 'Reading and triaging legacy observations must not rewrite their raw files.'
$badObservation = Join-Path $fixture 'Saved/Harness/Observations/bad-json.json'
[IO.File]::WriteAllText($badObservation, '{bad')
$badInbox = Get-HarnessFeedbackInbox -Context $context
Assert-True ($badInbox.Issues.Count -eq 1 -and $badInbox.Issues[0] -like 'bad-json.json:*') 'Malformed JSON must still produce an inbox read issue.'
$triageBefore = @(Get-ChildItem -LiteralPath (Join-Path $fixture 'Saved/Harness/Observations/triage') -Filter '*.json' -File).Count
Assert-Throws { Set-HarnessEvolutionTriage -Context $context -ObservationIds @('legacy-Harness') -Disposition dismissed -DecisionSource 'user:bad' -Scope 'Blocked read' } 'Malformed JSON must still block triage.'
$triageAfter = @(Get-ChildItem -LiteralPath (Join-Path $fixture 'Saved/Harness/Observations/triage') -Filter '*.json' -File).Count
Assert-True ($triageBefore -eq $triageAfter) 'A blocked triage must not create a decision record.'
$notice = Get-HarnessUpdateNotice -HarnessRoot $fixture
Assert-True ($null -eq $notice.Updates -and $notice.UpdatesIssue) 'Missing update notice should be reported nonfatally.'
$noticeDir = Join-Path $fixture '.agents/skills/harness'
[void][IO.Directory]::CreateDirectory($noticeDir)
[IO.File]::WriteAllText((Join-Path $noticeDir 'updates.json'), '{bad')
Assert-True ([bool](Get-HarnessUpdateNotice -HarnessRoot $fixture).UpdatesIssue) 'Corrupt update notice should be reported nonfatally.'
[IO.File]::WriteAllText((Join-Path $noticeDir 'updates.json'), '{"revision":"fixture-v1","published_at":"2026-09-19","summary":"Updated explanations","affected_skills":["explaining-work"]}')
Assert-True ((Get-HarnessUpdateNotice -HarnessRoot $fixture).Updates.revision -eq 'fixture-v1') 'Valid update revision must be available.'
'Harness feedback assertions passed.'
