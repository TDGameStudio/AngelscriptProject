# Implementation verification

Change `angelscript/feature-frontend-diagnostics-and-tooling`. 8.1 verified 2026-09-15 in the selected AngelscriptProject workspace after follow-up nodes 7.1–7.7. Durable deltas were later synced; see `spec-sync.md`. Knowledge candidates stay unpromoted. The Change is archived only after the completed-closure primitive.

## Final proving runs

Editor build `f7e5b8e620c6426486f6573245891ff5` (Development Win64 AngelscriptProjectEditor). Product bytes were unchanged after that build; 8.1 ran NativeEngine on the same binary.

| Selection | Run | Outcome |
|---|---|---|
| `Angelscript.UnitTest.NativeEngine` | `58e6f563f214438bbf7ace83d26d4aeb` | Succeeded 1164/1164 |
| `Angelscript.UnitTest.NativeEngine.Tooling` | `632135d7d7984e408726bed911620e1f` | Succeeded 23/23 (7.7 GREEN; same binary) |
| `Angelscript.UnitTest.Baseline` | `71959936e39644d5bd4662e2013f653c` | Reused; PassedWithWarnings; 3 complete, 0 failed. No startup/gate or adjacent-dormancy impact after 7.x |

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Report: `Saved/Harness/Unreal/Runs/58e6f563f214438bbf7ace83d26d4aeb/AutomationReport/index.json`.

`openspec.doctor` Succeeded. Strict Change validation Succeeded for `angelscript/feature-frontend-diagnostics-and-tooling` (run `6059fb81bb9e4b66b194a63f43c7a4b8`). Repository-wide `openspec.validate --strict` is intentionally not the 8.1 oracle: it audits unrelated archives.

Intentionally omitted Harness Quick/Performance/Integration, Standalone, full UE suites, VM/JIT execution, and legacy corpus activation: no new impact evidence required those gates; Baseline already proves dormancy.

## Historical 6.1 (not the 8.1 binary)

Editor build `ae945a25e9fc43959484364d34b97e07`. NativeEngine `a8f886db1ab04088aa3a6cf730a32b36` 1150/1150 and Integration `06adc1ebf2b84578b2a36aa167ee97e6` 3/3 proved 6.1 only. That binary does not prove 7.x repairs. Baseline reuse above is the same dormancy run.

## 4.1–4.4 oracles on current content

| Card / case | Current identity | Result on `58e6f563f214438bbf7ace83d26d4aeb` | Notes |
|---|---|---|---|
| 4.1 Retained ownership closure | `ToolingAnalysis.RetainedOwnershipClosure` | Success | Original 4.1 GREEN retained |
| 4.1 Partial read freeze | `ToolingAnalysis.PartialReadFreeze` | Success | Original 4.1 GREEN retained |
| 4.1 Identity and cancellation | `ToolingAnalysis.IdentityAndCancellation` | Success | Original 4.1 GREEN retained |
| 4.1 Additional accepted boundaries | no third 4.1 method | evidence-backed rejection of historical coverage | See honest gap. 7.1/7.2/7.6 own the unmet oracles |
| 4.2 Scope and member completion | `ToolingCompletion.ScopeAndMemberCompletion` | Success | Original 4.2 GREEN retained |
| 4.2 Real signature context | `ToolingCompletion.RealSignatureContext` | Success | Original 4.2 GREEN retained |
| 4.2 Additional accepted boundaries | `ToolingCompletion.ExitedScopesAndNearestShadow`, `GrammarExpectedTypeAndSourceOwnership`, `LegalClassAccessAndCompatibleReceiver`, `ProtectedMemberFromFreeFunction`, `ObservableOverloadAndNamedArgumentPayload`, `NestedHostAndNonmutationBoundaries` | Success | Not present at 4.2 close (2/2). Observed RED/GREEN on 7.3–7.5 |
| 4.3 Actual identifier binding | `ToolingNavigation.ActualIdentifierBinding` | Success | Original 4.3 GREEN retained |
| 4.3 Host location absence | `ToolingNavigation.HostLocationAbsence` | Success | Original 4.3 GREEN retained |
| 4.3 Additional accepted boundaries | `ToolingNavigation.RejectSamePathForeignResults`, `RetainedProvenanceAndExactTargets` | Success | Not a third 4.3 method at close. Observed RED/GREEN on 7.1 |
| 4.4 Cursor preserves scope | `ToolingCursor.CursorPreservesScopeWithoutSourceEdit` | Success | Original 4.4 GREEN retained |
| 4.4 Barrier before incomplete body | `ToolingCursor.BarrierBeforeIncompleteBody` | Success | Original 4.4 GREEN retained |
| 4.4 exited-scope / isolation follow-up | `ToolingCursor.ExitedScopesAndNearestShadow`, `ToolingCompletion.OneActualDeclarationPreparation` | Success | 7.3 / 7.7 |

## Review oracles on current content

| Review finding | Resolving tasks | Current identities | Result |
|---|---|---|---|
| Final F01 / Independent F02 signature payload | 7.5 | `ToolingCompletion.ObservableOverloadAndNamedArgumentPayload`, `NestedHostAndNonmutationBoundaries`; `CallAssessment.CompleteAndIncompleteMapping` | Success |
| Final F02 / Independent F03 protected access | 7.4 | `ToolingCompletion.LegalClassAccessAndCompatibleReceiver`, `ProtectedMemberFromFreeFunction` | Success |
| Final F03 / Independent F01 navigation identity | 7.1 | `ToolingNavigation.RejectSamePathForeignResults`, `RetainedProvenanceAndExactTargets` | Success |
| Final F04 missing historical RED / third methods | 7.1–7.7 + this note | n/a (process) | Honest: 4.1/4.3/4.4/3.1 and several 2.x/5.1/6.1 cards were not given pre-implementation RED or a third discovered method. Those extra oracles are not relabeled as 4.x historical RED. 7.x repairs have their own observed RED/GREEN |
| Final F05 / Independent F05 query status | 7.2 | `ToolingCompletion.InvalidUnavailableAndEmptyAreDistinct`, `CancellationAfterWorkStarts` | Success |
| Independent F04 exited scopes | 7.3 | `ToolingCursor.ExitedScopesAndNearestShadow`, `ToolingCompletion.ExitedScopesAndNearestShadow`, `GrammarExpectedTypeAndSourceOwnership` | Success |
| Final F06 freeze ownership | 7.6 | `ToolingAnalysis.ForeignRangeOrReadableEdge`, `TransitiveLeasesAndPartialFreezeControl` | Success |
| Final F07 double declaration prepare | 7.7 | `ToolingCompletion.OneActualDeclarationPreparation` | Success |

## 6.1 producer/fix/query integration (same 8.1 run)

| Case | Identity | Result |
|---|---|---|
| Real compile-fix-reanalysis | `DiagnosticsToolingIntegration.RealCompileFixReanalysis` | Success |
| Partial source and determinism | `DiagnosticsToolingIntegration.PartialSourceAndDeterminism` | Success |
| Joined early-phase failure | `DiagnosticsToolingIntegration.JoinedEarlyPhaseFailureAndRetainedToolingData` | Success |

## Honest missing historical RED

Do not treat later 7.x RED as 4.x/3.1 historical RED.

- 4.1 case 4, 4.3 case 3, and 4.4 never landed a third discovered boundary method at their original close.
- 4.2 case 3 was named but ToolingCompletion discovered only `ScopeAndMemberCompletion` and `RealSignatureContext` (GREEN `3d92470c754b47af8de674e36a2773b3`, 2/2).
- 3.1 Evidence recorded no separate pre-implementation RED; several 2.x/5.1/6.1 Evidence blocks start at GREEN.
- 7.1–7.7 each recorded grouped RED then GREEN on their proving prefixes. 8.1 maps those current-content identities; it does not invent a 4.x RED run.

## Baseline dormancy

- `Angelscript.UnitTest.Baseline.RuntimeDormantByDefault`
- `Angelscript.UnitTest.Baseline.OptionalIntegrationsDormantByDefault`
- `Angelscript.UnitTest.Baseline.LegacySuiteExcludedByDefault`

`WITH_ANGELSCRIPT_UNITTESTS` remains 0; `WITH_ANGELSCRIPT_TESTS` remains 1. No Engine creation was added for language-service or tooling tests.

## Inventory

Branch dispositions and per-family expected payloads remain in `diagnostic-migration-inventory.md`. 8.1 did not refresh inventory rows; producer IDs were unchanged.
