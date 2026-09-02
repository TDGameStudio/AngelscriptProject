# WG/HFD plan resolution

Plan-only review draft. It does not modify TestSource, OpenSpec, plugins, or product code.

## Result

- Sources: **635/635** — World 123, Gameplay 262, HotReload 209, TestFramework 38, Debugger 3.
- Canonical callable proposals: **2328/2328**.
- Prior WG blocking proposals covered: **986/986**; HFD blocker proposals preserved as field evidence: **5/5**; combined: **991/991**.
- Anonymous intermediate condition outputs replaced: **1128/1128**.
- DefaultComponent source contracts: **49/49**; HotReload matrices: **209/209**.
- Legacy incomplete-directive sources resolved by explicit declarations/fields: **10/10**.
- Final validation: **PASS**.

## Contract shape

Every `reviewRows[]` item fixes the exact current owner/kind/annotations/declaration anchor and contains one proposal with semantic/required-name ruling, exact proposed declaration, adjacent English comment, typed nominal/boundary/diagnostic vectors, raw result/writebacks, exact diagnostics, body assignments, prohibited direct calls, fixture phases/cleanup, status, and field-level evidence blockers.

Every HotReload source has an eleven-field retained/replaced/not-demonstrated matrix. `not-demonstrated-by-current-evidence` is intentionally paired with a field blocker and is not claimed as retained or replaced.

## Validation

```json
{
  "sourcesExpected": 635,
  "sourcesPlanned": 635,
  "sourceCounts": {
    "Debugger": 3,
    "Gameplay": 262,
    "HotReload": 209,
    "TestFramework": 38,
    "World": 123
  },
  "callablesExpected": 2328,
  "callablesPlanned": 2328,
  "callableCounts": {
    "Debugger": 4,
    "Gameplay": 1463,
    "HotReload": 273,
    "TestFramework": 212,
    "World": 376
  },
  "proposalsPlanned": 2328,
  "priorWGBlockingProposals": 986,
  "priorHFDBlockerProposals": 5,
  "priorBlockingOrBlockerProposals": 991,
  "intermediateOutputsExpected": 1128,
  "intermediateOutputsResolved": 1128,
  "legacyEllipsisDirectiveSourcesExpected": 10,
  "legacyEllipsisDirectiveSourcesResolved": 10,
  "defaultComponentSourcesExpected": 49,
  "defaultComponentSourcesResolved": 49,
  "allSourcesDeclaringDefaultComponents": 80,
  "hotReloadSourcesExpected": 209,
  "hotReloadMatrices": 209,
  "hfdOriginalBlockersExpected": 5,
  "hfdOriginalBlockersPreservedAsFieldEvidence": 5,
  "forbiddenAnonymousConditionPlaceholderOccurrences": 0,
  "forbiddenEllipsisOccurrences": 0,
  "diagnosticsWithoutExactMessage": [],
  "requiredNamesWithoutReason": [],
  "commentsMissingImmediateCaseFacts": [],
  "declarationErrors": [],
  "duplicateProposedOwnerDeclarations": [],
  "passed": true
}
```

## Prior blocker disposition

The 986 prior WG blocking reasons each have an explicit `priorBlockingResolutions[]` action. The five HFD blockers are preserved as field-level evidence blockers. Remaining uncertainty is attached only to a named field such as a raw output type, exact source line, or HotReload identity relation.

## High-risk rulings

- DefaultComponent null is always fixture failure; every declared component records type, owner/Outer/world, registration, and attachment expectations.
- Lifecycle, TimerManager, delegate, RepNotify, and native events are engine-dispatched; semantic readers list prohibited direct callback calls.
- Blueprint vectors name script-parent CDO, Blueprint-child CDO, spawned script instance, or spawned Blueprint-child instance explicitly.
- HotReload plans capture identities before reload, state which surface relation is evidenced, and require teardown of generations, objects, delegates, Blueprint assets, and worlds.
- The ProcessEvent case is retained as an explicit cross-scope dependency with exact signatures and 777/zero native-dispatch vectors; it is not counted as a WG/HFD source.

## Evidence blockers

- Source-level field blockers: **2097** across **221** sources.
- Proposal-level field blockers: **2649** across **279** proposals.

These are evidence requests, not execution-pass claims. The JSON contains every exact field path and required evidence statement.

## Final assertions

- `sources=635/635`
- `callables=2328/2328`
- `resolvedIntermediateOutputs=1128/1128`
- `forbiddenAnonymousConditionPlaceholderOccurrences=0`
- `forbiddenEllipsisOccurrences=0`
- `diagnosticsWithoutExactMessage=0`
- `passed=true`
