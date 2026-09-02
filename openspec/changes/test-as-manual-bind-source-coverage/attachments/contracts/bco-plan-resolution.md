# Bindings / Containers / Optional Contract V2 plan resolution

> Plan-only artifact. No TestSource, OpenSpec, plugin, product, runner, or documentation source was modified. The JSON companion is the exhaustive canonical override ledger.

## Outcome

- Canonical scope: **812 files / 3276 owner-qualified callables**.
- Legacy BCO audit: **3255 callables**; **3255** map exactly after annotation-aware normalization.
- Explained delta: **21** rows = **16 delegate/event declarations** + **5 multiline functions**.
- Planned result: **3546 exact declarations** plus **1 explicit retirement**.
- Adjudicated: **595 blockers**, **317 candidates**, **331 unmatched surfaces in 117 files**.

Plan review-ready and source-ready are separate. A concrete suggested signature remains evidence-blocked when typed runner values, raw oracles, before/after writebacks, exact diagnostics, or unique surface ownership are absent.

## JSON override-row contract

Join on `sourcePath + current.qualifiedIdentity`. Each canonical row carries owner, kind, annotations, exact current declaration, line, parameters/defaults, return, comment, and body hash. Each flattened replacement carries stable IDs, semantic name, exact declaration, exact adjacent English comments, typed channels/vectors, ordered body plan, fixture, cleanup-on-all-exits, coverage, independent statuses, blockers, and provenance.

A current row may map to one-to-many replacements or one explicit retirement. Delegate/event declarations remain declaration rows rather than fake executable entry functions.

## Semantic and signature corrections

- `invalid-inferred-signature-replaced-with-canonical-parameter-shape`: 101
- `semantic-name-improved`: 689

Proposed declarations contain no legacy `Observe_*`, `SurfaceNNN`, `_Nominal`, numeric `VariantN`, `Expected*`, `bExpect*`, synthesized condition-output, or generic variadic marker. Invalid method-token types are removed; unresolved externalization remains an evidence blocker.

## Canonical-only rows

- `TestSource/Bindings/BlueprintEvent/Test_Behavior_01.as:22` — `event` `FTSBlueprintEventBehaviorMulticast`
- `TestSource/Bindings/BlueprintEvent/Test_Behavior_01.as:23` — `delegate` `FTSBlueprintEventBehaviorDelegate`
- `TestSource/Bindings/BlueprintEvent/Test_MutationAndLifecycle_01.as:17` — `event` `FTSBlueprintEventMutationMulticast`
- `TestSource/Bindings/BlueprintEvent/Test_MutationAndLifecycle_01.as:18` — `delegate` `FTSBlueprintEventMutationDelegate`
- `TestSource/Bindings/Delegates/Test_Behavior_01.as:24` — `delegate` `FTSDelegatesBehaviorCompute`
- `TestSource/Bindings/Delegates/Test_Behavior_01.as:25` — `event` `FTSDelegatesBehaviorNotify`
- `TestSource/Bindings/Delegates/Test_Behavior_02.as:16` — `delegate` `FTSDelegatesSignatureNotify`
- `TestSource/Bindings/Delegates/Test_Behavior_02.as:17` — `event` `FTSDelegatesSignatureMulticast`
- `TestSource/Bindings/Delegates/Test_ConstructionAndAssignment_01.as:13` — `delegate` `FTSDelegatesAssignmentCompute`
- `TestSource/Bindings/Delegates/Test_ConstructionAndAssignment_01.as:14` — `event` `FTSDelegatesAssignmentNotify`
- `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_01.as:23` — `delegate` `FTSDelegatesMutationCompute`
- `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_01.as:24` — `event` `FTSDelegatesMutationNotify`
- `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_02.as:20` — `delegate` `FTSDelegatesErasedNotify`
- `TestSource/Bindings/Delegates/Test_MutationAndLifecycle_02.as:21` — `event` `FTSDelegatesErasedMulticast`
- `TestSource/Bindings/Delegates/Test_Queries_01.as:14` — `delegate` `FTSDelegatesQueryCompute`
- `TestSource/Bindings/Delegates/Test_Queries_01.as:15` — `event` `FTSDelegatesQueryNotify`
- `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:48` — `function` `GetAssetsByPathParity`
- `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:87` — `function` `GetAssetByObjectPathParity`
- `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:127` — `function` `GetAllAssetsParity`
- `TestSource/Containers/TSet/Test_AssetRegistryLiveQueryParity.as:162` — `function` `Observe_GetAssetByObjectPath_CopyIndependence`
- `TestSource/Containers/TSet/Test_SoftPathStringIdentityAndMissingClassBoundaries.as:127` — `function` `Observe_SoftPathIdentity_Nominal`

The 16 delegate/event declarations preserve fixed names. Four AssetRegistry multiline wrappers receive raw-channel signatures. The soft-path aggregate is retired only after its three component behaviors are coverage-reconciled.

## Blocker adjudication

- `exact-vector-argument-evidence-missing`: 4350
- `raw-return-oracle-evidence-missing`: 2823
- `compound-wrapper-split-not-proven`: 1909
- `writeback-vector-evidence-missing`: 697
- `legacy-audit-blocker-adjudicated`: 595
- `unmatched-authored-surface-file-gate`: 459
- `candidate-body-refactor-adjudicated`: 317
- `shallow-null-oracle`: 274
- `unmatched-surface-no-unique-owner`: 197
- `unmatched-surface-fold-review`: 134
- `invalid-inferred-type-removed`: 101
- `exact-diagnostic-evidence-missing`: 95
- `zero-argument-externalization-unresolved`: 50
- `duplicate-proposed-declaration-resolution-required`: 30
- `retirement-coverage-reconciliation-required`: 1

Every blocker names the affected field, evidence-based reason, and exact evidence needed. No diagnostic string is invented.

## Unmatched authored surfaces

All 331 surfaces have resolution rows. Strong unique lexical/operator evidence may propose a fold; all other rows remain distinct-surface design gates. Generic authored templates are referenced by surface ID, rule path, and SHA-256 instead of being copied as executable declarations.

Files and counts:

- `TestSource/Bindings/AssetRegistry/Test_Behavior_01.as`: 2
- `TestSource/Bindings/AssetRegistry/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/BlueprintEvent/Test_Behavior_01.as`: 2
- `TestSource/Bindings/BlueprintType/Test_Behavior_01.as`: 3
- `TestSource/Bindings/BlueprintType/Test_Behavior_02.as`: 4
- `TestSource/Bindings/BlueprintType/Test_ConstructionAndAssignment_01.as`: 9
- `TestSource/Bindings/BlueprintType/Test_Operators_01.as`: 5
- `TestSource/Bindings/Console/Test_Behavior_01.as`: 3
- `TestSource/Bindings/Debugging/Test_Behavior_01.as`: 1
- `TestSource/Bindings/Debugging/Test_Queries_01.as`: 1
- `TestSource/Bindings/Delegates/Test_Behavior_01.as`: 9
- `TestSource/Bindings/Delegates/Test_ConstructionAndAssignment_01.as`: 3
- `TestSource/Bindings/FActorSpawnParameters/Test_Behavior_01.as`: 1
- `TestSource/Bindings/FAnchors/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FBox/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FBox/Test_ConstructionAndAssignment_01.as`: 3
- `TestSource/Bindings/FBox3f/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FBox3f/Test_ConstructionAndAssignment_01.as`: 2
- `TestSource/Bindings/FBox3f/Test_Operators_01.as`: 1
- `TestSource/Bindings/FBoxSphereBounds/Test_Behavior_01.as`: 6
- `TestSource/Bindings/FBoxSphereBounds/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FBoxSphereBounds3f/Test_Behavior_01.as`: 6
- `TestSource/Bindings/FBoxSphereBounds3f/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_01.as`: 7
- `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_02.as`: 1
- `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_04.as`: 1
- `TestSource/Bindings/FCollisionQueryParams/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FColor/Test_Behavior_01.as`: 1
- `TestSource/Bindings/FDateTime/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FDateTime/Test_Operators_01.as`: 2
- `TestSource/Bindings/FFormatArgumentValue/Test_Behavior_01.as`: 8
- `TestSource/Bindings/FInputActionValue/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FInputBindingHandle/Test_Behavior_01.as`: 1
- `TestSource/Bindings/FInputBindingHandle/Test_Operators_01.as`: 3
- `TestSource/Bindings/FInstancedStruct/Test_Behavior_01.as`: 1
- `TestSource/Bindings/FIntPoint/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FIntPoint/Test_ConstructionAndAssignment_01.as`: 5
- `TestSource/Bindings/FIntVector/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FIntVector/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FIntVector2/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FIntVector2/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FIntVector4/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FIntVector4/Test_ConstructionAndAssignment_01.as`: 5
- `TestSource/Bindings/FLinearColor/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FLinearColor/Test_ConstructionAndAssignment_01.as`: 6
- `TestSource/Bindings/FLinearColor/Test_ConstructionAndAssignment_02.as`: 2
- `TestSource/Bindings/FMargin/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FName/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FName/Test_ConstructionAndAssignment_01.as`: 2
- `TestSource/Bindings/FName/Test_Operators_01.as`: 1
- `TestSource/Bindings/FPlane/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FPlane4f/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FQuat/Test_Behavior_01.as`: 2
- `TestSource/Bindings/FQuat/Test_Behavior_02.as`: 2
- `TestSource/Bindings/FQuat/Test_ConstructionAndAssignment_01.as`: 6
- `TestSource/Bindings/FQuat/Test_ConstructionAndAssignment_02.as`: 1
- `TestSource/Bindings/FQuat4f/Test_Behavior_01.as`: 5
- `TestSource/Bindings/FQuat4f/Test_ConstructionAndAssignment_01.as`: 6
- `TestSource/Bindings/FRandomStream/Test_Behavior_01.as`: 1
- `TestSource/Bindings/FRotator/Test_Behavior_01.as`: 5
- `TestSource/Bindings/FRotator/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FRotator/Test_Operators_01.as`: 1
- `TestSource/Bindings/FRotator3f/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FRotator3f/Test_Behavior_02.as`: 1
- `TestSource/Bindings/FRotator3f/Test_ConstructionAndAssignment_01.as`: 4
- `TestSource/Bindings/FSphere/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FSphere3f/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FString/Test_ConstructionAndAssignment_01.as`: 3
- `TestSource/Bindings/FString/Test_Operators_01.as`: 2
- `TestSource/Bindings/FText/Test_Behavior_01.as`: 1
- `TestSource/Bindings/FText/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/FTimespan/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FTimespan/Test_ConstructionAndAssignment_01.as`: 5
- `TestSource/Bindings/FTimespan/Test_Operators_01.as`: 1
- `TestSource/Bindings/FTransform/Test_Behavior_01.as`: 6
- `TestSource/Bindings/FTransform/Test_ConstructionAndAssignment_01.as`: 4
- `TestSource/Bindings/FTransform/Test_NamespaceAndGlobalFunctions_01.as`: 1
- `TestSource/Bindings/FTransform3f/Test_Behavior_01.as`: 6
- `TestSource/Bindings/FTransform3f/Test_ConstructionAndAssignment_01.as`: 3
- `TestSource/Bindings/FTransform3f/Test_NamespaceAndGlobalFunctions_01.as`: 1
- `TestSource/Bindings/FVector/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FVector/Test_ConstructionAndAssignment_01.as`: 3
- `TestSource/Bindings/FVector/Test_Operators_01.as`: 1
- `TestSource/Bindings/FVector2D/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FVector2D/Test_ConstructionAndAssignment_01.as`: 3
- `TestSource/Bindings/FVector2D/Test_Operators_01.as`: 2
- `TestSource/Bindings/FVector2f/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FVector2f/Test_ConstructionAndAssignment_01.as`: 9
- `TestSource/Bindings/FVector2f/Test_ConstructionAndAssignment_02.as`: 2
- `TestSource/Bindings/FVector3f/Test_Behavior_01.as`: 3
- `TestSource/Bindings/FVector3f/Test_ConstructionAndAssignment_01.as`: 7
- `TestSource/Bindings/FVector4/Test_Behavior_01.as`: 4
- `TestSource/Bindings/FVector4/Test_ConstructionAndAssignment_01.as`: 5
- `TestSource/Bindings/FVector4f/Test_Behavior_01.as`: 4
- `TestSource/Bindings/InputEvents/Test_Behavior_01.as`: 1
- `TestSource/Bindings/InputEvents/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/Json/Test_Behavior_02.as`: 2
- `TestSource/Bindings/SoftObjectPath/Test_Behavior_01.as`: 3
- `TestSource/Bindings/Stats/Test_Behavior_01.as`: 1
- `TestSource/Bindings/TMap/Test_Behavior_01.as`: 2
- `TestSource/Bindings/TMap/Test_ConstructionAndAssignment_01.as`: 2
- `TestSource/Bindings/TMap/Test_Operators_01.as`: 1
- `TestSource/Bindings/TOptional/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/TOptional/Test_Operators_01.as`: 2
- `TestSource/Bindings/TSet/Test_Behavior_01.as`: 1
- `TestSource/Bindings/TSet/Test_ConstructionAndAssignment_01.as`: 2
- `TestSource/Bindings/TSoftObjectPtr/Test_Behavior_01.as`: 6
- `TestSource/Bindings/TSoftObjectPtr/Test_Behavior_02.as`: 1
- `TestSource/Bindings/TSoftObjectPtr/Test_ConstructionAndAssignment_01.as`: 6
- `TestSource/Bindings/TSoftObjectPtr/Test_Operators_01.as`: 4
- `TestSource/Bindings/UAssetManager/Test_ConstructionAndAssignment_01.as`: 1
- `TestSource/Bindings/UAssetManager/Test_Operators_01.as`: 1
- `TestSource/Bindings/UDataTable/Test_Operators_01.as`: 1
- `TestSource/Bindings/UObject/Test_Queries_04.as`: 1
- `TestSource/Bindings/UStruct/Test_Behavior_01.as`: 1
- `TestSource/Bindings/UUserWidget/Test_Behavior_01.as`: 3
- `TestSource/Bindings/UUserWidget/Test_NamespaceAndGlobalFunctions_01.as`: 1

## Self-validation

- Canonical baseline exact: `True` (`812 / 3276`).
- Callable coverage complete: `True`.
- Count difference classified: `{'delta': 21, 'delegateOrEvent': 16, 'multilineFunction': 5}`.
- All 595 blocker rows adjudicated: `True`.
- All 317 candidate rows adjudicated: `True`.
- All 331 unmatched surfaces adjudicated: `True`.
- Forbidden proposed declarations: `0`.
- Duplicate owner-qualified proposals requiring review: `13`.
- Every replacement has exact comments: `True`.
- Every blocker has evidenceNeeded: `True`.

## Consumer rules

1. Flatten one replacement into one task checkbox.
2. Emit a design-resolution task, not a source task, when implementationState is evidence-blocked.
3. Do not assign a file with fileGateBlockers until all unmatched surfaces are approved.
4. Treat runner-blocked independently from source design.
5. Project the retirement as coverage transfer, never as a replacement function.

## Later verification commands

```powershell
python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode audit --max-diagnostics 0
python -B -m pytest TestSource/Generation/python/tests/test_as_callable_inventory_v2.py TestSource/Generation/python/tests/test_as_inventory_current_forms_v2.py -q
openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive
```

These are plan commands. This subtask did not run source migration or runtime tests.
