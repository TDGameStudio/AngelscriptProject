# Objects, reflection, and assets

UObject, UStruct, UEnum, packages, asset manager/registry/data table, asset bundle, and script-mixin asset behavior.

## Accounting

- Logical units: 9
- Planned AS-facing surface rows: 151
- Planned `.as` files: 39
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-003` | `AssetBundleData` | 1 | 4 | 3 | `REF-0019` | `Engine` | `PlannedSource` |
| `MB-004` | `AssetManagerScriptMixins` | 1 | 3 | 2 | `REF-0020` | `Engine` | `PlannedSource` |
| `MB-005` | `AssetRegistry` | 2 | 29 | 7 | `REF-0021` `REF-0022` `REF-0023` `REF-0024` `REF-0025` `REF-0026` `REF-0027` | `Engine` `ExpectedDiagnostic` `Editor` | `PlannedSource` |
| `MB-106` | `UAssetManager` | 2 | 16 | 5 | `REF-0646` `REF-0647` | `Engine` `Latent` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-108` | `UDataTable` | 2 | 15 | 4 | `REF-0656` `REF-0657` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-110` | `UEnum` | 2 | 22 | 5 | `REF-0664` `REF-0665` `REF-0666` `REF-0667` `REF-0668` `REF-0669` `REF-0670` `REF-0671` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-116` | `UObject` | 2 | 57 | 10 | `REF-0693` `REF-0694` `REF-0695` `REF-0696` `REF-0697` `REF-0698` `REF-0699` | `Engine` `NetworkClient` `ExpectedDiagnostic` `Editor` | `PlannedSource` |
| `MB-117` | `UPackage` | 1 | 1 | 1 | `REF-0700` `REF-0701` `REF-0702` `REF-0703` `REF-0704` `REF-0705` `REF-0706` | `Engine` | `PlannedSource` |
| `MB-124` | `UStruct` | 3 | 4 | 2 | `REF-0744` `REF-0745` `REF-0746` `REF-0747` `REF-0748` `REF-0749` `REF-0750` | `Engine` `Editor` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-ASSETBUNDLEDATA-001` | `TestSource/Bindings/AssetBundleData/Test_Queries_01.as` | `MB-003-S004` | `Positive` | `Engine` |
| `TS-BIND-ASSETBUNDLEDATA-002` | `TestSource/Bindings/AssetBundleData/Test_MutationAndLifecycle_01.as` | `MB-003-S002` `MB-003-S003` | `Positive` | `Engine` |
| `TS-BIND-ASSETBUNDLEDATA-003` | `TestSource/Bindings/AssetBundleData/Test_Behavior_01.as` | `MB-003-S001` | `Positive` | `Engine` |
| `TS-BIND-ASSETMANAGERSCRIPTMIXINS-001` | `TestSource/Bindings/AssetManagerScriptMixins/Test_Queries_01.as` | `MB-004-S002` `MB-004-S003` | `Positive` | `Engine` |
| `TS-BIND-ASSETMANAGERSCRIPTMIXINS-002` | `TestSource/Bindings/AssetManagerScriptMixins/Test_Behavior_01.as` | `MB-004-S001` | `Positive` | `Engine` |
| `TS-BIND-ASSETREGISTRY-001` | `TestSource/Bindings/AssetRegistry/Test_ConstructionAndAssignment_01.as` | `MB-005-S011` `MB-005-S029` | `Positive` | `Engine` |
| `TS-BIND-ASSETREGISTRY-002` | `TestSource/Bindings/AssetRegistry/Test_Operators_01.as` | `MB-005-S010` | `Positive` | `Engine` |
| `TS-BIND-ASSETREGISTRY-003` | `TestSource/Bindings/AssetRegistry/Test_Queries_01.as` | `MB-005-S001` `MB-005-S002` `MB-005-S003` `MB-005-S007` `MB-005-S008` `MB-005-S012` `MB-005-S013` `MB-005-S014` `MB-005-S015` `MB-005-S016` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-ASSETREGISTRY-004` | `TestSource/Bindings/AssetRegistry/Test_Queries_02.as` | `MB-005-S017` `MB-005-S018` `MB-005-S019` `MB-005-S020` `MB-005-S021` `MB-005-S022` `MB-005-S023` `MB-005-S024` `MB-005-S025` `MB-005-S026` | `Positive` | `Editor` |
| `TS-BIND-ASSETREGISTRY-005` | `TestSource/Bindings/AssetRegistry/Test_MutationAndLifecycle_01.as` | `MB-005-S009` `MB-005-S028` | `Positive` | `Engine` |
| `TS-BIND-ASSETREGISTRY-006` | `TestSource/Bindings/AssetRegistry/Test_ConversionAndFormatting_01.as` | `MB-005-S027` | `Positive` | `Engine` |
| `TS-BIND-ASSETREGISTRY-007` | `TestSource/Bindings/AssetRegistry/Test_Behavior_01.as` | `MB-005-S004` `MB-005-S005` `MB-005-S006` | `Positive` | `Engine` |
| `TS-BIND-UASSETMANAGER-001` | `TestSource/Bindings/UAssetManager/Test_ConstructionAndAssignment_01.as` | `MB-106-S015` `MB-106-S016` | `Positive` | `Engine` |
| `TS-BIND-UASSETMANAGER-002` | `TestSource/Bindings/UAssetManager/Test_Operators_01.as` | `MB-106-S004` `MB-106-S007` | `Positive` | `Engine` |
| `TS-BIND-UASSETMANAGER-003` | `TestSource/Bindings/UAssetManager/Test_Queries_01.as` | `MB-106-S002` `MB-106-S003` `MB-106-S006` `MB-106-S008` `MB-106-S009` `MB-106-S010` | `Positive` | `Engine` |
| `TS-BIND-UASSETMANAGER-004` | `TestSource/Bindings/UAssetManager/Test_MutationAndLifecycle_01.as` | `MB-106-S013` `MB-106-S014` | `Positive;NegativeDiagnostic` | `Latent;ExpectedDiagnostic` |
| `TS-BIND-UASSETMANAGER-005` | `TestSource/Bindings/UAssetManager/Test_Behavior_01.as` | `MB-106-S001` `MB-106-S005` `MB-106-S011` `MB-106-S012` | `Positive` | `Engine` |
| `TS-BIND-UDATATABLE-001` | `TestSource/Bindings/UDataTable/Test_Operators_01.as` | `MB-108-S008` `MB-108-S012` | `Positive` | `Engine` |
| `TS-BIND-UDATATABLE-002` | `TestSource/Bindings/UDataTable/Test_Queries_01.as` | `MB-108-S002` `MB-108-S005` `MB-108-S006` `MB-108-S007` `MB-108-S010` `MB-108-S011` `MB-108-S013` `MB-108-S014` `MB-108-S015` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-UDATATABLE-003` | `TestSource/Bindings/UDataTable/Test_MutationAndLifecycle_01.as` | `MB-108-S001` `MB-108-S003` `MB-108-S004` | `Positive` | `Engine` |
| `TS-BIND-UDATATABLE-004` | `TestSource/Bindings/UDataTable/Test_ConversionAndFormatting_01.as` | `MB-108-S009` | `Positive` | `Engine` |
| `TS-BIND-UENUM-001` | `TestSource/Bindings/UEnum/Test_ConstructionAndAssignment_01.as` | `MB-110-S001` `MB-110-S002` | `Positive` | `Engine` |
| `TS-BIND-UENUM-002` | `TestSource/Bindings/UEnum/Test_IndexAndIteration_01.as` | `MB-110-S007` `MB-110-S008` `MB-110-S011` `MB-110-S012` `MB-110-S015` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-UENUM-003` | `TestSource/Bindings/UEnum/Test_Queries_01.as` | `MB-110-S009` `MB-110-S010` `MB-110-S013` `MB-110-S014` `MB-110-S016` `MB-110-S017` `MB-110-S018` `MB-110-S019` `MB-110-S020` `MB-110-S021` | `Positive` | `Engine` |
| `TS-BIND-UENUM-004` | `TestSource/Bindings/UEnum/Test_NamespaceAndGlobalFunctions_01.as` | `MB-110-S003` `MB-110-S004` `MB-110-S005` `MB-110-S006` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-UENUM-005` | `TestSource/Bindings/UEnum/Test_Behavior_01.as` | `MB-110-S022` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-001` | `TestSource/Bindings/UObject/Test_ConstructionAndAssignment_01.as` | `MB-116-S025` `MB-116-S028` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-002` | `TestSource/Bindings/UObject/Test_Operators_01.as` | `MB-116-S027` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-003` | `TestSource/Bindings/UObject/Test_Queries_01.as` | `MB-116-S003` `MB-116-S004` `MB-116-S005` `MB-116-S008` `MB-116-S009` `MB-116-S010` `MB-116-S011` `MB-116-S012` `MB-116-S013` `MB-116-S015` | `Positive` | `NetworkClient` |
| `TS-BIND-UOBJECT-004` | `TestSource/Bindings/UObject/Test_Queries_02.as` | `MB-116-S016` `MB-116-S017` `MB-116-S018` `MB-116-S019` `MB-116-S026` `MB-116-S031` `MB-116-S032` `MB-116-S033` `MB-116-S034` `MB-116-S035` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-UOBJECT-005` | `TestSource/Bindings/UObject/Test_Queries_03.as` | `MB-116-S036` `MB-116-S037` `MB-116-S038` `MB-116-S039` `MB-116-S040` `MB-116-S041` `MB-116-S042` `MB-116-S044` `MB-116-S045` `MB-116-S046` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-006` | `TestSource/Bindings/UObject/Test_Queries_04.as` | `MB-116-S048` `MB-116-S049` `MB-116-S050` `MB-116-S051` `MB-116-S054` `MB-116-S055` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-007` | `TestSource/Bindings/UObject/Test_MutationAndLifecycle_01.as` | `MB-116-S001` `MB-116-S002` `MB-116-S007` `MB-116-S021` `MB-116-S022` `MB-116-S029` `MB-116-S053` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-008` | `TestSource/Bindings/UObject/Test_ConversionAndFormatting_01.as` | `MB-116-S030` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-009` | `TestSource/Bindings/UObject/Test_NamespaceAndGlobalFunctions_01.as` | `MB-116-S043` | `Positive` | `Engine` |
| `TS-BIND-UOBJECT-010` | `TestSource/Bindings/UObject/Test_Behavior_01.as` | `MB-116-S006` `MB-116-S014` `MB-116-S020` `MB-116-S023` `MB-116-S024` `MB-116-S047` `MB-116-S052` `MB-116-S056` `MB-116-S057` | `Positive;NegativeDiagnostic` | `Editor;ExpectedDiagnostic` |
| `TS-BIND-UPACKAGE-001` | `TestSource/Bindings/UPackage/Test_Queries_01.as` | `MB-117-S001` | `Positive` | `Engine` |
| `TS-BIND-USTRUCT-001` | `TestSource/Bindings/UStruct/Test_ConstructionAndAssignment_01.as` | `MB-124-S003` | `Positive` | `Engine` |
| `TS-BIND-USTRUCT-002` | `TestSource/Bindings/UStruct/Test_Behavior_01.as` | `MB-124-S001` `MB-124-S002` `MB-124-S004` | `Positive` | `Editor` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
