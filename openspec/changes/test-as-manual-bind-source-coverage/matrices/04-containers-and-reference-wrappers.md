# Containers and reference wrappers

Array/map/set/optional/instanced-struct/soft-path/soft-pointer construction, mutation, iteration, lookup, null, reference, and container-result semantics.

## Accounting

- Logical units: 7
- Planned AS-facing surface rows: 207
- Planned `.as` files: 42
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-044` | `FInstancedStruct` | 2 | 13 | 5 | `REF-0265` `REF-0266` `REF-0267` `REF-0268` `REF-0269` `REF-0270` `REF-0271` `REF-0272` | `Engine` | `PlannedSource` |
| `MB-096` | `SoftObjectPath` | 1 | 23 | 4 | `REF-0569` `REF-0570` `REF-0571` `REF-0572` `REF-0573` `REF-0574` `REF-0575` `REF-0576` `REF-0577` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-100` | `TArray` | 2 | 50 | 8 | `REF-0596` `REF-0597` `REF-0598` `REF-0599` `REF-0600` `REF-0601` `REF-0602` `REF-0603` `REF-0604` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-101` | `TMap` | 2 | 39 | 7 | `REF-0605` `REF-0606` `REF-0607` `REF-0608` `REF-0609` `REF-0610` `REF-0611` `REF-0612` | `Engine` | `PlannedSource` |
| `MB-102` | `TOptional` | 2 | 12 | 4 | `REF-0613` `REF-0614` `REF-0615` `REF-0616` `REF-0617` `REF-0618` `REF-0619` `REF-0620` `REF-0621` | `Engine` | `PlannedSource` |
| `MB-103` | `TSet` | 2 | 26 | 6 | `REF-0622` `REF-0623` `REF-0624` `REF-0625` `REF-0626` `REF-0627` | `Engine` | `PlannedSource` |
| `MB-104` | `TSoftObjectPtr` | 3 | 44 | 8 | `REF-0628` `REF-0629` `REF-0630` `REF-0631` `REF-0632` `REF-0633` `REF-0634` `REF-0635` `REF-0636` | `Engine` `ExpectedDiagnostic` `Latent` `Editor` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-FINSTANCEDSTRUCT-001` | `TestSource/Bindings/FInstancedStruct/Test_Operators_01.as` | `MB-044-S003` | `Positive` | `Engine` |
| `TS-BIND-FINSTANCEDSTRUCT-002` | `TestSource/Bindings/FInstancedStruct/Test_Queries_01.as` | `MB-044-S006` `MB-044-S007` `MB-044-S008` `MB-044-S010` `MB-044-S011` `MB-044-S012` | `Positive` | `Engine` |
| `TS-BIND-FINSTANCEDSTRUCT-003` | `TestSource/Bindings/FInstancedStruct/Test_MutationAndLifecycle_01.as` | `MB-044-S009` | `Positive` | `Engine` |
| `TS-BIND-FINSTANCEDSTRUCT-004` | `TestSource/Bindings/FInstancedStruct/Test_NamespaceAndGlobalFunctions_01.as` | `MB-044-S013` | `Positive` | `Engine` |
| `TS-BIND-FINSTANCEDSTRUCT-005` | `TestSource/Bindings/FInstancedStruct/Test_Behavior_01.as` | `MB-044-S001` `MB-044-S002` `MB-044-S004` `MB-044-S005` | `Positive` | `Engine` |
| `TS-BIND-SOFTOBJECTPATH-001` | `TestSource/Bindings/SoftObjectPath/Test_Operators_01.as` | `MB-096-S010` | `Positive` | `Engine` |
| `TS-BIND-SOFTOBJECTPATH-002` | `TestSource/Bindings/SoftObjectPath/Test_Queries_01.as` | `MB-096-S003` `MB-096-S004` `MB-096-S005` `MB-096-S006` `MB-096-S007` `MB-096-S008` `MB-096-S009` `MB-096-S015` `MB-096-S016` `MB-096-S017` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-SOFTOBJECTPATH-003` | `TestSource/Bindings/SoftObjectPath/Test_Queries_02.as` | `MB-096-S018` `MB-096-S019` `MB-096-S020` `MB-096-S021` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-SOFTOBJECTPATH-004` | `TestSource/Bindings/SoftObjectPath/Test_Behavior_01.as` | `MB-096-S001` `MB-096-S002` `MB-096-S011` `MB-096-S012` `MB-096-S013` `MB-096-S014` `MB-096-S022` `MB-096-S023` | `Positive` | `Engine` |
| `TS-BIND-TARRAY-001` | `TestSource/Bindings/TArray/Test_ConstructionAndAssignment_01.as` | `MB-100-S004` `MB-100-S010` `MB-100-S042` `MB-100-S046` | `Positive` | `Engine` |
| `TS-BIND-TARRAY-002` | `TestSource/Bindings/TArray/Test_Operators_01.as` | `MB-100-S002` `MB-100-S003` `MB-100-S005` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TARRAY-003` | `TestSource/Bindings/TArray/Test_IndexAndIteration_01.as` | `MB-100-S011` `MB-100-S022` `MB-100-S041` `MB-100-S044` `MB-100-S045` `MB-100-S048` `MB-100-S049` `MB-100-S050` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TARRAY-004` | `TestSource/Bindings/TArray/Test_Queries_01.as` | `MB-100-S023` `MB-100-S031` `MB-100-S032` `MB-100-S033` `MB-100-S034` `MB-100-S035` | `Positive` | `Engine` |
| `TS-BIND-TARRAY-005` | `TestSource/Bindings/TArray/Test_MutationAndLifecycle_01.as` | `MB-100-S006` `MB-100-S007` `MB-100-S008` `MB-100-S014` `MB-100-S015` `MB-100-S016` `MB-100-S017` `MB-100-S018` `MB-100-S019` `MB-100-S021` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TARRAY-006` | `TestSource/Bindings/TArray/Test_MutationAndLifecycle_02.as` | `MB-100-S024` `MB-100-S025` `MB-100-S026` `MB-100-S027` `MB-100-S028` `MB-100-S029` `MB-100-S030` `MB-100-S040` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TARRAY-007` | `TestSource/Bindings/TArray/Test_Behavior_01.as` | `MB-100-S001` `MB-100-S009` `MB-100-S012` `MB-100-S013` `MB-100-S020` `MB-100-S036` `MB-100-S037` `MB-100-S038` `MB-100-S039` `MB-100-S043` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TARRAY-008` | `TestSource/Bindings/TArray/Test_Behavior_02.as` | `MB-100-S047` | `Positive` | `Engine` |
| `TS-BIND-TMAP-001` | `TestSource/Bindings/TMap/Test_ConstructionAndAssignment_01.as` | `MB-101-S016` `MB-101-S023` `MB-101-S031` | `Positive` | `Engine` |
| `TS-BIND-TMAP-002` | `TestSource/Bindings/TMap/Test_Operators_01.as` | `MB-101-S005` `MB-101-S006` `MB-101-S017` | `Positive` | `Engine` |
| `TS-BIND-TMAP-003` | `TestSource/Bindings/TMap/Test_IndexAndIteration_01.as` | `MB-101-S029` `MB-101-S035` `MB-101-S038` `MB-101-S039` | `Positive` | `Engine` |
| `TS-BIND-TMAP-004` | `TestSource/Bindings/TMap/Test_Queries_01.as` | `MB-101-S008` `MB-101-S011` `MB-101-S012` `MB-101-S013` `MB-101-S014` `MB-101-S015` `MB-101-S020` `MB-101-S021` `MB-101-S026` `MB-101-S027` | `Positive` | `Engine` |
| `TS-BIND-TMAP-005` | `TestSource/Bindings/TMap/Test_Queries_02.as` | `MB-101-S033` `MB-101-S034` | `Positive` | `Engine` |
| `TS-BIND-TMAP-006` | `TestSource/Bindings/TMap/Test_MutationAndLifecycle_01.as` | `MB-101-S007` `MB-101-S009` `MB-101-S010` `MB-101-S018` `MB-101-S019` `MB-101-S025` `MB-101-S028` | `Positive` | `Engine` |
| `TS-BIND-TMAP-007` | `TestSource/Bindings/TMap/Test_Behavior_01.as` | `MB-101-S001` `MB-101-S002` `MB-101-S003` `MB-101-S004` `MB-101-S022` `MB-101-S024` `MB-101-S030` `MB-101-S032` `MB-101-S036` `MB-101-S037` | `Positive` | `Engine` |
| `TS-BIND-TOPTIONAL-001` | `TestSource/Bindings/TOptional/Test_ConstructionAndAssignment_01.as` | `MB-102-S004` `MB-102-S005` | `Positive` | `Engine` |
| `TS-BIND-TOPTIONAL-002` | `TestSource/Bindings/TOptional/Test_Operators_01.as` | `MB-102-S001` `MB-102-S002` `MB-102-S003` `MB-102-S006` | `Positive` | `Engine` |
| `TS-BIND-TOPTIONAL-003` | `TestSource/Bindings/TOptional/Test_Queries_01.as` | `MB-102-S007` `MB-102-S009` `MB-102-S010` `MB-102-S011` | `Positive` | `Engine` |
| `TS-BIND-TOPTIONAL-004` | `TestSource/Bindings/TOptional/Test_MutationAndLifecycle_01.as` | `MB-102-S008` `MB-102-S012` | `Positive` | `Engine` |
| `TS-BIND-TSET-001` | `TestSource/Bindings/TSet/Test_ConstructionAndAssignment_01.as` | `MB-103-S010` `MB-103-S017` `MB-103-S021` | `Positive` | `Engine` |
| `TS-BIND-TSET-002` | `TestSource/Bindings/TSet/Test_Operators_01.as` | `MB-103-S011` | `Positive` | `Engine` |
| `TS-BIND-TSET-003` | `TestSource/Bindings/TSet/Test_IndexAndIteration_01.as` | `MB-103-S019` `MB-103-S023` `MB-103-S025` `MB-103-S026` | `Positive` | `Engine` |
| `TS-BIND-TSET-004` | `TestSource/Bindings/TSet/Test_Queries_01.as` | `MB-103-S008` `MB-103-S014` `MB-103-S015` | `Positive` | `Engine` |
| `TS-BIND-TSET-005` | `TestSource/Bindings/TSet/Test_MutationAndLifecycle_01.as` | `MB-103-S005` `MB-103-S006` `MB-103-S007` `MB-103-S009` `MB-103-S012` `MB-103-S013` | `Positive` | `Engine` |
| `TS-BIND-TSET-006` | `TestSource/Bindings/TSet/Test_Behavior_01.as` | `MB-103-S001` `MB-103-S002` `MB-103-S003` `MB-103-S004` `MB-103-S016` `MB-103-S018` `MB-103-S020` `MB-103-S022` `MB-103-S024` | `Positive` | `Engine` |
| `TS-BIND-TSOFTOBJECTPTR-001` | `TestSource/Bindings/TSoftObjectPtr/Test_ConstructionAndAssignment_01.as` | `MB-104-S015` `MB-104-S016` `MB-104-S017` `MB-104-S036` `MB-104-S037` `MB-104-S038` `MB-104-S039` | `Positive` | `Engine` |
| `TS-BIND-TSOFTOBJECTPTR-002` | `TestSource/Bindings/TSoftObjectPtr/Test_Operators_01.as` | `MB-104-S018` `MB-104-S019` `MB-104-S040` `MB-104-S041` `MB-104-S042` | `Positive` | `Engine` |
| `TS-BIND-TSOFTOBJECTPTR-003` | `TestSource/Bindings/TSoftObjectPtr/Test_Queries_01.as` | `MB-104-S009` `MB-104-S010` `MB-104-S011` `MB-104-S012` `MB-104-S013` `MB-104-S020` `MB-104-S030` `MB-104-S031` `MB-104-S032` `MB-104-S033` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TSOFTOBJECTPTR-004` | `TestSource/Bindings/TSoftObjectPtr/Test_Queries_02.as` | `MB-104-S034` `MB-104-S043` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-TSOFTOBJECTPTR-005` | `TestSource/Bindings/TSoftObjectPtr/Test_MutationAndLifecycle_01.as` | `MB-104-S014` `MB-104-S021` `MB-104-S035` `MB-104-S044` | `Positive` | `Latent` |
| `TS-BIND-TSOFTOBJECTPTR-006` | `TestSource/Bindings/TSoftObjectPtr/Test_ConversionAndFormatting_01.as` | `MB-104-S007` `MB-104-S008` `MB-104-S028` `MB-104-S029` | `Positive` | `Engine` |
| `TS-BIND-TSOFTOBJECTPTR-007` | `TestSource/Bindings/TSoftObjectPtr/Test_Behavior_01.as` | `MB-104-S001` `MB-104-S002` `MB-104-S003` `MB-104-S004` `MB-104-S005` `MB-104-S006` `MB-104-S022` `MB-104-S023` `MB-104-S024` `MB-104-S025` | `Positive` | `Editor` |
| `TS-BIND-TSOFTOBJECTPTR-008` | `TestSource/Bindings/TSoftObjectPtr/Test_Behavior_02.as` | `MB-104-S026` `MB-104-S027` | `Positive` | `Engine` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
