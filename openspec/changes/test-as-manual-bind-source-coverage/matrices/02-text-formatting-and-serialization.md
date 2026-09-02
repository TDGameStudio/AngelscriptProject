# Text, formatting, and serialization

String/name/text/date/time/formatting, identifier, color text, JSON, and object-conversion surfaces with exact return and parse/format observations.

## Accounting

- Logical units: 12
- Planned AS-facing surface rows: 388
- Planned `.as` files: 74
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-030` | `FColor` | 1 | 28 | 6 | `REF-0172` `REF-0173` `REF-0174` `REF-0175` `REF-0176` `REF-0177` `REF-0178` `REF-0179` `REF-0180` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-033` | `FDateTime` | 1 | 42 | 8 | `REF-0194` `REF-0195` `REF-0196` `REF-0197` `REF-0198` `REF-0199` `REF-0200` | `Engine` `World` | `PlannedSource` |
| `MB-035` | `FFormatArgumentValue` | 2 | 10 | 2 | `REF-0210` `REF-0211` `REF-0212` | `Engine` | `PlannedSource` |
| `MB-039` | `FGuid` | 1 | 15 | 6 | `REF-0230` `REF-0231` `REF-0232` `REF-0233` `REF-0234` `REF-0235` `REF-0236` `REF-0237` `REF-0238` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-056` | `FName` | 2 | 18 | 5 | `REF-0334` `REF-0335` `REF-0336` `REF-0337` `REF-0338` `REF-0339` `REF-0340` | `Engine` `World` | `PlannedSource` |
| `MB-057` | `FNumberFormattingOptions` | 2 | 13 | 5 | `REF-0341` `REF-0342` `REF-0343` | `Engine` | `PlannedSource` |
| `MB-074` | `FString` | 3 | 98 | 13 | `REF-0442` `REF-0443` `REF-0444` `REF-0445` `REF-0446` `REF-0447` `REF-0448` `REF-0449` | `World` `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-075` | `FStringTableRegistry` | 1 | 10 | 3 | `REF-0450` | `Engine` | `PlannedSource` |
| `MB-076` | `FText` | 3 | 43 | 7 | `REF-0451` `REF-0452` `REF-0453` `REF-0454` `REF-0455` | `Engine` | `PlannedSource` |
| `MB-077` | `FTimespan` | 1 | 49 | 8 | `REF-0456` `REF-0457` `REF-0458` `REF-0459` `REF-0460` `REF-0461` `REF-0462` `REF-0463` | `Engine` `World` | `PlannedSource` |
| `MB-090` | `Json` | 2 | 59 | 9 | `REF-0537` `REF-0538` `REF-0539` `REF-0540` `REF-0541` `REF-0542` `REF-0543` `REF-0544` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-091` | `JsonObjectConverter` | 2 | 3 | 2 | `REF-0545` `REF-0546` | `Engine` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-FCOLOR-001` | `TestSource/Bindings/FColor/Test_ConstructionAndAssignment_01.as` | `MB-030-S005` | `Positive` | `Engine` |
| `TS-BIND-FCOLOR-002` | `TestSource/Bindings/FColor/Test_Operators_01.as` | `MB-030-S004` | `Positive` | `Engine` |
| `TS-BIND-FCOLOR-003` | `TestSource/Bindings/FColor/Test_ConversionAndFormatting_01.as` | `MB-030-S006` `MB-030-S008` `MB-030-S010` `MB-030-S028` | `Positive` | `Engine` |
| `TS-BIND-FCOLOR-004` | `TestSource/Bindings/FColor/Test_NamespaceAndGlobalFunctions_01.as` | `MB-030-S011` `MB-030-S012` `MB-030-S013` `MB-030-S014` `MB-030-S015` `MB-030-S016` `MB-030-S017` `MB-030-S018` `MB-030-S019` `MB-030-S020` | `Positive` | `Engine` |
| `TS-BIND-FCOLOR-005` | `TestSource/Bindings/FColor/Test_NamespaceAndGlobalFunctions_02.as` | `MB-030-S021` `MB-030-S022` `MB-030-S023` `MB-030-S024` `MB-030-S025` `MB-030-S026` `MB-030-S027` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FCOLOR-006` | `TestSource/Bindings/FColor/Test_Behavior_01.as` | `MB-030-S001` `MB-030-S002` `MB-030-S003` `MB-030-S007` `MB-030-S009` | `Positive` | `Engine` |
| `TS-BIND-FDATETIME-001` | `TestSource/Bindings/FDateTime/Test_ConstructionAndAssignment_01.as` | `MB-033-S023` `MB-033-S026` `MB-033-S040` | `Positive` | `Engine` |
| `TS-BIND-FDATETIME-002` | `TestSource/Bindings/FDateTime/Test_Operators_01.as` | `MB-033-S002` `MB-033-S022` `MB-033-S024` `MB-033-S025` `MB-033-S039` | `Positive` | `Engine` |
| `TS-BIND-FDATETIME-003` | `TestSource/Bindings/FDateTime/Test_Queries_01.as` | `MB-033-S003` `MB-033-S004` `MB-033-S005` `MB-033-S006` `MB-033-S007` `MB-033-S008` `MB-033-S009` `MB-033-S010` `MB-033-S011` `MB-033-S012` | `Positive` | `World` |
| `TS-BIND-FDATETIME-004` | `TestSource/Bindings/FDateTime/Test_Queries_02.as` | `MB-033-S013` `MB-033-S014` `MB-033-S015` `MB-033-S020` `MB-033-S029` `MB-033-S031` `MB-033-S032` | `Positive` | `World` |
| `TS-BIND-FDATETIME-005` | `TestSource/Bindings/FDateTime/Test_MutationAndLifecycle_01.as` | `MB-033-S041` | `Positive` | `Engine` |
| `TS-BIND-FDATETIME-006` | `TestSource/Bindings/FDateTime/Test_ConversionAndFormatting_01.as` | `MB-033-S016` `MB-033-S017` `MB-033-S018` `MB-033-S019` `MB-033-S030` `MB-033-S035` `MB-033-S036` `MB-033-S037` `MB-033-S038` `MB-033-S042` | `Positive` | `Engine` |
| `TS-BIND-FDATETIME-007` | `TestSource/Bindings/FDateTime/Test_NamespaceAndGlobalFunctions_01.as` | `MB-033-S027` `MB-033-S028` `MB-033-S033` `MB-033-S034` | `Positive` | `Engine` |
| `TS-BIND-FDATETIME-008` | `TestSource/Bindings/FDateTime/Test_Behavior_01.as` | `MB-033-S001` `MB-033-S021` | `Positive` | `World` |
| `TS-BIND-FFORMATARGUMENTVALUE-001` | `TestSource/Bindings/FFormatArgumentValue/Test_ConstructionAndAssignment_01.as` | `MB-035-S001` | `Positive` | `Engine` |
| `TS-BIND-FFORMATARGUMENTVALUE-002` | `TestSource/Bindings/FFormatArgumentValue/Test_Behavior_01.as` | `MB-035-S002` `MB-035-S003` `MB-035-S004` `MB-035-S005` `MB-035-S006` `MB-035-S007` `MB-035-S008` `MB-035-S009` `MB-035-S010` | `Positive` | `Engine` |
| `TS-BIND-FGUID-001` | `TestSource/Bindings/FGuid/Test_ConstructionAndAssignment_01.as` | `MB-039-S001` | `Positive` | `Engine` |
| `TS-BIND-FGUID-002` | `TestSource/Bindings/FGuid/Test_Operators_01.as` | `MB-039-S004` `MB-039-S006` `MB-039-S007` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FGUID-003` | `TestSource/Bindings/FGuid/Test_Queries_01.as` | `MB-039-S009` `MB-039-S012` | `Positive` | `Engine` |
| `TS-BIND-FGUID-004` | `TestSource/Bindings/FGuid/Test_ConversionAndFormatting_01.as` | `MB-039-S010` `MB-039-S011` `MB-039-S014` `MB-039-S015` | `Positive` | `Engine` |
| `TS-BIND-FGUID-005` | `TestSource/Bindings/FGuid/Test_NamespaceAndGlobalFunctions_01.as` | `MB-039-S013` | `Positive` | `Engine` |
| `TS-BIND-FGUID-006` | `TestSource/Bindings/FGuid/Test_Behavior_01.as` | `MB-039-S002` `MB-039-S003` `MB-039-S005` `MB-039-S008` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FNAME-001` | `TestSource/Bindings/FName/Test_ConstructionAndAssignment_01.as` | `MB-056-S004` `MB-056-S013` `MB-056-S014` `MB-056-S018` | `Positive` | `Engine` |
| `TS-BIND-FNAME-002` | `TestSource/Bindings/FName/Test_Operators_01.as` | `MB-056-S005` `MB-056-S015` | `Positive` | `Engine` |
| `TS-BIND-FNAME-003` | `TestSource/Bindings/FName/Test_Queries_01.as` | `MB-056-S006` `MB-056-S007` `MB-056-S008` `MB-056-S010` `MB-056-S011` `MB-056-S012` | `Positive` | `World` |
| `TS-BIND-FNAME-004` | `TestSource/Bindings/FName/Test_MutationAndLifecycle_01.as` | `MB-056-S009` | `Positive` | `World` |
| `TS-BIND-FNAME-005` | `TestSource/Bindings/FName/Test_Behavior_01.as` | `MB-056-S001` `MB-056-S002` `MB-056-S003` `MB-056-S016` `MB-056-S017` | `Positive` | `Engine` |
| `TS-BIND-FNUMBERFORMATTINGOPTIONS-001` | `TestSource/Bindings/FNumberFormattingOptions/Test_ConstructionAndAssignment_01.as` | `MB-057-S001` | `Positive` | `Engine` |
| `TS-BIND-FNUMBERFORMATTINGOPTIONS-002` | `TestSource/Bindings/FNumberFormattingOptions/Test_Operators_01.as` | `MB-057-S002` | `Positive` | `Engine` |
| `TS-BIND-FNUMBERFORMATTINGOPTIONS-003` | `TestSource/Bindings/FNumberFormattingOptions/Test_Queries_01.as` | `MB-057-S010` `MB-057-S011` | `Positive` | `Engine` |
| `TS-BIND-FNUMBERFORMATTINGOPTIONS-004` | `TestSource/Bindings/FNumberFormattingOptions/Test_MutationAndLifecycle_01.as` | `MB-057-S003` `MB-057-S004` `MB-057-S005` `MB-057-S006` `MB-057-S007` `MB-057-S008` `MB-057-S009` | `Positive` | `Engine` |
| `TS-BIND-FNUMBERFORMATTINGOPTIONS-005` | `TestSource/Bindings/FNumberFormattingOptions/Test_NamespaceAndGlobalFunctions_01.as` | `MB-057-S012` `MB-057-S013` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-001` | `TestSource/Bindings/FString/Test_ConstructionAndAssignment_01.as` | `MB-074-S001` `MB-074-S002` `MB-074-S005` `MB-074-S006` `MB-074-S064` `MB-074-S093` | `Positive` | `World` |
| `TS-BIND-FSTRING-002` | `TestSource/Bindings/FString/Test_Operators_01.as` | `MB-074-S007` `MB-074-S009` `MB-074-S010` `MB-074-S011` `MB-074-S063` `MB-074-S092` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FSTRING-003` | `TestSource/Bindings/FString/Test_IndexAndIteration_01.as` | `MB-074-S023` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FSTRING-004` | `TestSource/Bindings/FString/Test_Queries_01.as` | `MB-074-S019` `MB-074-S026` `MB-074-S027` `MB-074-S042` `MB-074-S043` `MB-074-S044` `MB-074-S045` `MB-074-S046` `MB-074-S047` `MB-074-S048` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FSTRING-005` | `TestSource/Bindings/FString/Test_Queries_02.as` | `MB-074-S049` `MB-074-S059` `MB-074-S062` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-006` | `TestSource/Bindings/FString/Test_MutationAndLifecycle_01.as` | `MB-074-S012` `MB-074-S013` `MB-074-S014` `MB-074-S015` `MB-074-S016` `MB-074-S017` `MB-074-S018` `MB-074-S020` `MB-074-S021` `MB-074-S022` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FSTRING-007` | `TestSource/Bindings/FString/Test_MutationAndLifecycle_02.as` | `MB-074-S024` `MB-074-S025` `MB-074-S030` `MB-074-S031` `MB-074-S065` `MB-074-S094` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FSTRING-008` | `TestSource/Bindings/FString/Test_ConversionAndFormatting_01.as` | `MB-074-S029` `MB-074-S050` `MB-074-S051` `MB-074-S060` `MB-074-S061` `MB-074-S066` `MB-074-S069` `MB-074-S071` `MB-074-S074` `MB-074-S075` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-009` | `TestSource/Bindings/FString/Test_ConversionAndFormatting_02.as` | `MB-074-S076` `MB-074-S077` `MB-074-S078` `MB-074-S079` `MB-074-S080` `MB-074-S081` `MB-074-S082` `MB-074-S083` `MB-074-S084` `MB-074-S085` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-010` | `TestSource/Bindings/FString/Test_ConversionAndFormatting_03.as` | `MB-074-S086` `MB-074-S087` `MB-074-S088` `MB-074-S089` `MB-074-S090` `MB-074-S091` `MB-074-S095` `MB-074-S096` `MB-074-S097` `MB-074-S098` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-011` | `TestSource/Bindings/FString/Test_NamespaceAndGlobalFunctions_01.as` | `MB-074-S037` `MB-074-S038` `MB-074-S039` `MB-074-S068` `MB-074-S070` `MB-074-S072` `MB-074-S073` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-012` | `TestSource/Bindings/FString/Test_Behavior_01.as` | `MB-074-S003` `MB-074-S004` `MB-074-S008` `MB-074-S028` `MB-074-S032` `MB-074-S033` `MB-074-S034` `MB-074-S035` `MB-074-S036` `MB-074-S040` | `Positive` | `Engine` |
| `TS-BIND-FSTRING-013` | `TestSource/Bindings/FString/Test_Behavior_02.as` | `MB-074-S041` `MB-074-S052` `MB-074-S053` `MB-074-S054` `MB-074-S055` `MB-074-S056` `MB-074-S057` `MB-074-S058` `MB-074-S067` | `Positive` | `Engine` |
| `TS-BIND-FSTRINGTABLEREGISTRY-001` | `TestSource/Bindings/FStringTableRegistry/Test_ConstructionAndAssignment_01.as` | `MB-075-S001` | `Positive` | `Engine` |
| `TS-BIND-FSTRINGTABLEREGISTRY-002` | `TestSource/Bindings/FStringTableRegistry/Test_NamespaceAndGlobalFunctions_01.as` | `MB-075-S002` `MB-075-S003` `MB-075-S004` | `Positive` | `Engine` |
| `TS-BIND-FSTRINGTABLEREGISTRY-003` | `TestSource/Bindings/FStringTableRegistry/Test_Behavior_01.as` | `MB-075-S005` `MB-075-S006` `MB-075-S007` `MB-075-S008` `MB-075-S009` `MB-075-S010` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-001` | `TestSource/Bindings/FText/Test_ConstructionAndAssignment_01.as` | `MB-076-S001` `MB-076-S002` `MB-076-S012` `MB-076-S043` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-002` | `TestSource/Bindings/FText/Test_Queries_01.as` | `MB-076-S005` `MB-076-S006` `MB-076-S007` `MB-076-S008` `MB-076-S009` `MB-076-S010` `MB-076-S041` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-003` | `TestSource/Bindings/FText/Test_ConversionAndFormatting_01.as` | `MB-076-S013` `MB-076-S014` `MB-076-S015` `MB-076-S016` `MB-076-S019` `MB-076-S020` `MB-076-S021` `MB-076-S022` `MB-076-S023` `MB-076-S024` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-004` | `TestSource/Bindings/FText/Test_ConversionAndFormatting_02.as` | `MB-076-S025` `MB-076-S026` `MB-076-S027` `MB-076-S028` `MB-076-S029` `MB-076-S030` `MB-076-S031` `MB-076-S032` `MB-076-S033` `MB-076-S034` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-005` | `TestSource/Bindings/FText/Test_ConversionAndFormatting_03.as` | `MB-076-S035` `MB-076-S036` `MB-076-S037` `MB-076-S038` `MB-076-S039` `MB-076-S040` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-006` | `TestSource/Bindings/FText/Test_NamespaceAndGlobalFunctions_01.as` | `MB-076-S011` `MB-076-S017` `MB-076-S018` | `Positive` | `Engine` |
| `TS-BIND-FTEXT-007` | `TestSource/Bindings/FText/Test_Behavior_01.as` | `MB-076-S003` `MB-076-S004` `MB-076-S042` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-001` | `TestSource/Bindings/FTimespan/Test_ConstructionAndAssignment_01.as` | `MB-077-S005` `MB-077-S006` `MB-077-S007` `MB-077-S008` `MB-077-S009` `MB-077-S010` `MB-077-S011` `MB-077-S012` `MB-077-S013` `MB-077-S014` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-002` | `TestSource/Bindings/FTimespan/Test_ConstructionAndAssignment_02.as` | `MB-077-S015` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-003` | `TestSource/Bindings/FTimespan/Test_Operators_01.as` | `MB-077-S017` `MB-077-S019` `MB-077-S020` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-004` | `TestSource/Bindings/FTimespan/Test_Queries_01.as` | `MB-077-S021` `MB-077-S022` `MB-077-S023` `MB-077-S024` `MB-077-S025` `MB-077-S026` `MB-077-S027` `MB-077-S028` `MB-077-S029` `MB-077-S030` | `Positive` | `World` |
| `TS-BIND-FTIMESPAN-005` | `TestSource/Bindings/FTimespan/Test_Queries_02.as` | `MB-077-S031` `MB-077-S032` `MB-077-S033` `MB-077-S034` `MB-077-S035` `MB-077-S036` `MB-077-S037` `MB-077-S044` `MB-077-S045` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-006` | `TestSource/Bindings/FTimespan/Test_ConversionAndFormatting_01.as` | `MB-077-S038` `MB-077-S039` `MB-077-S040` `MB-077-S041` `MB-077-S042` `MB-077-S043` `MB-077-S048` `MB-077-S049` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-007` | `TestSource/Bindings/FTimespan/Test_NamespaceAndGlobalFunctions_01.as` | `MB-077-S046` `MB-077-S047` | `Positive` | `Engine` |
| `TS-BIND-FTIMESPAN-008` | `TestSource/Bindings/FTimespan/Test_Behavior_01.as` | `MB-077-S001` `MB-077-S002` `MB-077-S003` `MB-077-S004` `MB-077-S016` `MB-077-S018` | `Positive` | `World` |
| `TS-BIND-JSON-001` | `TestSource/Bindings/Json/Test_IndexAndIteration_01.as` | `MB-090-S052` `MB-090-S057` | `Positive` | `Engine` |
| `TS-BIND-JSON-002` | `TestSource/Bindings/Json/Test_Queries_01.as` | `MB-090-S014` `MB-090-S021` `MB-090-S029` `MB-090-S030` `MB-090-S033` `MB-090-S034` `MB-090-S037` `MB-090-S038` `MB-090-S039` `MB-090-S040` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-JSON-003` | `TestSource/Bindings/Json/Test_Queries_02.as` | `MB-090-S041` `MB-090-S054` `MB-090-S055` `MB-090-S056` | `Positive` | `Engine` |
| `TS-BIND-JSON-004` | `TestSource/Bindings/Json/Test_MutationAndLifecycle_01.as` | `MB-090-S025` `MB-090-S026` `MB-090-S027` `MB-090-S028` `MB-090-S035` `MB-090-S036` `MB-090-S042` `MB-090-S043` `MB-090-S044` `MB-090-S045` | `Positive` | `Engine` |
| `TS-BIND-JSON-005` | `TestSource/Bindings/Json/Test_MutationAndLifecycle_02.as` | `MB-090-S046` `MB-090-S048` `MB-090-S050` `MB-090-S051` | `Positive` | `Engine` |
| `TS-BIND-JSON-006` | `TestSource/Bindings/Json/Test_ConversionAndFormatting_01.as` | `MB-090-S059` | `Positive` | `Engine` |
| `TS-BIND-JSON-007` | `TestSource/Bindings/Json/Test_NamespaceAndGlobalFunctions_01.as` | `MB-090-S002` `MB-090-S003` `MB-090-S004` `MB-090-S005` `MB-090-S006` `MB-090-S007` `MB-090-S008` `MB-090-S058` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-JSON-008` | `TestSource/Bindings/Json/Test_Behavior_01.as` | `MB-090-S001` `MB-090-S009` `MB-090-S010` `MB-090-S011` `MB-090-S012` `MB-090-S013` `MB-090-S015` `MB-090-S016` `MB-090-S017` `MB-090-S018` | `Positive` | `Engine` |
| `TS-BIND-JSON-009` | `TestSource/Bindings/Json/Test_Behavior_02.as` | `MB-090-S019` `MB-090-S020` `MB-090-S022` `MB-090-S023` `MB-090-S024` `MB-090-S031` `MB-090-S032` `MB-090-S047` `MB-090-S049` `MB-090-S053` | `Positive` | `Engine` |
| `TS-BIND-JSONOBJECTCONVERTER-001` | `TestSource/Bindings/JsonObjectConverter/Test_MutationAndLifecycle_01.as` | `MB-091-S002` | `Positive` | `Engine` |
| `TS-BIND-JSONOBJECTCONVERTER-002` | `TestSource/Bindings/JsonObjectConverter/Test_NamespaceAndGlobalFunctions_01.as` | `MB-091-S001` `MB-091-S003` | `Positive` | `Engine` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
