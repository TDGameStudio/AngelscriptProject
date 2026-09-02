# Math and geometry

Scalar math, vector/rotator/quaternion/transform/matrix, integer vectors, ranges, bounds, planes, spheres, layout values, and random/frame-time behavior.

## Accounting

- Logical units: 34
- Planned AS-facing surface rows: 1283
- Planned `.as` files: 221
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-018` | `FAnchors` | 1 | 6 | 3 | `REF-0108` `REF-0109` `REF-0110` `REF-0111` `REF-0112` `REF-0113` | `Engine` | `PlannedSource` |
| `MB-023` | `FBox` | 2 | 34 | 7 | `REF-0134` `REF-0135` `REF-0136` `REF-0137` `REF-0138` `REF-0139` `REF-0140` | `Engine` `ExpectedDiagnostic` `World` | `PlannedSource` |
| `MB-024` | `FBox2D` | 1 | 3 | 2 | `REF-0141` `REF-0142` `REF-0143` `REF-0144` `REF-0145` `REF-0146` | `Engine` | `PlannedSource` |
| `MB-025` | `FBox3f` | 2 | 26 | 7 | `REF-0147` `REF-0148` `REF-0149` `REF-0150` | `Engine` `ExpectedDiagnostic` `World` | `PlannedSource` |
| `MB-026` | `FBoxSphereBounds` | 2 | 21 | 6 | `REF-0151` `REF-0152` `REF-0153` `REF-0154` | `Engine` `World` | `PlannedSource` |
| `MB-027` | `FBoxSphereBounds3f` | 2 | 21 | 6 | `REF-0155` `REF-0156` `REF-0157` `REF-0158` | `Engine` `World` | `PlannedSource` |
| `MB-036` | `FFrameTime` | 1 | 2 | 1 | `REF-0213` `REF-0214` `REF-0215` `REF-0216` `REF-0217` | `Engine` | `PlannedSource` |
| `MB-038` | `FGeometry` | 1 | 5 | 2 | `REF-0221` `REF-0222` `REF-0223` `REF-0224` `REF-0225` `REF-0226` `REF-0227` `REF-0228` `REF-0229` | `Engine` | `PlannedSource` |
| `MB-045` | `FIntPoint` | 2 | 22 | 4 | `REF-0273` `REF-0274` `REF-0275` `REF-0276` `REF-0277` `REF-0278` `REF-0279` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |
| `MB-046` | `FIntVector` | 3 | 28 | 6 | `REF-0280` `REF-0281` `REF-0282` `REF-0283` `REF-0284` `REF-0285` `REF-0286` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |
| `MB-047` | `FIntVector2` | 3 | 10 | 3 | `REF-0287` `REF-0288` `REF-0289` `REF-0290` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-048` | `FIntVector4` | 3 | 21 | 4 | `REF-0291` `REF-0292` `REF-0293` `REF-0294` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-050` | `FLinearColor` | 2 | 49 | 8 | `REF-0300` `REF-0301` `REF-0302` `REF-0303` `REF-0304` `REF-0305` `REF-0306` `REF-0307` `REF-0308` | `Engine` `World` | `PlannedSource` |
| `MB-051` | `FMargin` | 1 | 14 | 3 | `REF-0309` `REF-0310` `REF-0311` `REF-0312` `REF-0313` `REF-0314` | `World` | `PlannedSource` |
| `MB-052` | `FMath` | 2 | 251 | 27 | `REF-0315` `REF-0316` `REF-0317` `REF-0318` `REF-0319` `REF-0320` `REF-0321` | `Engine` `ExpectedDiagnostic` `World` | `PlannedSource` |
| `MB-053` | `FMatrix` | 1 | 4 | 2 | `REF-0322` `REF-0323` `REF-0324` | `Engine` | `PlannedSource` |
| `MB-061` | `FPlane` | 1 | 8 | 2 | `REF-0366` `REF-0367` `REF-0368` `REF-0369` `REF-0370` `REF-0371` `REF-0372` `REF-0373` `REF-0374` | `Engine` | `PlannedSource` |
| `MB-062` | `FPlane4f` | 1 | 6 | 2 | `REF-0375` `REF-0376` `REF-0377` | `Engine` | `PlannedSource` |
| `MB-066` | `FQuat` | 3 | 72 | 11 | `REF-0394` `REF-0395` `REF-0396` `REF-0397` `REF-0398` `REF-0399` `REF-0400` `REF-0401` `REF-0402` | `Engine` `ExpectedDiagnostic` `World` | `PlannedSource` |
| `MB-067` | `FQuat4f` | 3 | 70 | 11 | `REF-0403` `REF-0404` `REF-0405` `REF-0406` | `World` `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-068` | `FRandomStream` | 2 | 23 | 7 | `REF-0407` `REF-0408` `REF-0409` `REF-0410` `REF-0411` `REF-0412` `REF-0413` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-069` | `FRange` | 1 | 5 | 3 | `REF-0414` `REF-0415` `REF-0416` `REF-0417` `REF-0418` `REF-0419` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-070` | `FRotator` | 3 | 56 | 10 | `REF-0420` `REF-0421` `REF-0422` `REF-0423` `REF-0424` `REF-0425` `REF-0426` `REF-0427` `REF-0428` | `World` `Engine` `Editor` | `PlannedSource` |
| `MB-071` | `FRotator3f` | 3 | 40 | 7 | `REF-0429` `REF-0430` `REF-0431` `REF-0432` | `World` `Engine` | `PlannedSource` |
| `MB-072` | `FSphere` | 2 | 15 | 3 | `REF-0433` `REF-0434` `REF-0435` | `Engine` `World` | `PlannedSource` |
| `MB-073` | `FSphere3f` | 2 | 13 | 3 | `REF-0436` `REF-0437` `REF-0438` `REF-0439` `REF-0440` `REF-0441` | `Engine` `World` | `PlannedSource` |
| `MB-078` | `FTransform` | 3 | 63 | 9 | `REF-0464` `REF-0465` `REF-0466` `REF-0467` `REF-0468` `REF-0469` `REF-0470` `REF-0471` `REF-0472` | `Engine` `World` | `PlannedSource` |
| `MB-079` | `FTransform3f` | 3 | 60 | 8 | `REF-0473` `REF-0474` `REF-0475` | `Engine` `World` | `PlannedSource` |
| `MB-081` | `FVector` | 3 | 102 | 13 | `REF-0483` `REF-0484` `REF-0485` `REF-0486` `REF-0487` `REF-0488` `REF-0489` `REF-0490` `REF-0491` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |
| `MB-082` | `FVector2D` | 3 | 51 | 10 | `REF-0492` `REF-0493` `REF-0494` `REF-0495` `REF-0496` `REF-0497` `REF-0498` `REF-0499` `REF-0500` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |
| `MB-083` | `FVector2f` | 3 | 49 | 9 | `REF-0501` `REF-0502` `REF-0503` `REF-0504` `REF-0505` `REF-0506` `REF-0507` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |
| `MB-084` | `FVector3f` | 3 | 93 | 14 | `REF-0508` `REF-0509` `REF-0510` `REF-0511` `REF-0512` `REF-0513` `REF-0514` | `World` `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-085` | `FVector4` | 1 | 18 | 3 | `REF-0515` `REF-0516` `REF-0517` `REF-0518` `REF-0519` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-086` | `FVector4f` | 1 | 22 | 5 | `REF-0520` `REF-0521` `REF-0522` `REF-0523` | `World` `ExpectedDiagnostic` `Engine` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-FANCHORS-001` | `TestSource/Bindings/FAnchors/Test_Operators_01.as` | `MB-018-S004` | `Positive` | `Engine` |
| `TS-BIND-FANCHORS-002` | `TestSource/Bindings/FAnchors/Test_Queries_01.as` | `MB-018-S005` `MB-018-S006` | `Positive` | `Engine` |
| `TS-BIND-FANCHORS-003` | `TestSource/Bindings/FAnchors/Test_Behavior_01.as` | `MB-018-S001` `MB-018-S002` `MB-018-S003` | `Positive` | `Engine` |
| `TS-BIND-FBOX-001` | `TestSource/Bindings/FBox/Test_ConstructionAndAssignment_01.as` | `MB-023-S006` `MB-023-S007` `MB-023-S009` `MB-023-S010` `MB-023-S034` | `Positive` | `Engine` |
| `TS-BIND-FBOX-002` | `TestSource/Bindings/FBox/Test_Operators_01.as` | `MB-023-S008` `MB-023-S011` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FBOX-003` | `TestSource/Bindings/FBox/Test_Queries_01.as` | `MB-023-S012` `MB-023-S013` `MB-023-S014` `MB-023-S015` `MB-023-S016` `MB-023-S019` `MB-023-S027` `MB-023-S028` `MB-023-S029` `MB-023-S030` | `Positive` | `World` |
| `TS-BIND-FBOX-004` | `TestSource/Bindings/FBox/Test_Queries_02.as` | `MB-023-S031` `MB-023-S032` | `Positive` | `Engine` |
| `TS-BIND-FBOX-005` | `TestSource/Bindings/FBox/Test_NamespaceAndGlobalFunctions_01.as` | `MB-023-S033` | `Positive` | `Engine` |
| `TS-BIND-FBOX-006` | `TestSource/Bindings/FBox/Test_Behavior_01.as` | `MB-023-S001` `MB-023-S002` `MB-023-S003` `MB-023-S004` `MB-023-S005` `MB-023-S017` `MB-023-S018` `MB-023-S020` `MB-023-S021` `MB-023-S022` | `Positive` | `World` |
| `TS-BIND-FBOX-007` | `TestSource/Bindings/FBox/Test_Behavior_02.as` | `MB-023-S023` `MB-023-S024` `MB-023-S025` `MB-023-S026` | `Positive` | `Engine` |
| `TS-BIND-FBOX2D-001` | `TestSource/Bindings/FBox2D/Test_Queries_01.as` | `MB-024-S003` | `Positive` | `Engine` |
| `TS-BIND-FBOX2D-002` | `TestSource/Bindings/FBox2D/Test_Behavior_01.as` | `MB-024-S001` `MB-024-S002` | `Positive` | `Engine` |
| `TS-BIND-FBOX3F-001` | `TestSource/Bindings/FBox3f/Test_ConstructionAndAssignment_01.as` | `MB-025-S001` `MB-025-S008` `MB-025-S012` `MB-025-S024` | `Positive` | `Engine` |
| `TS-BIND-FBOX3F-002` | `TestSource/Bindings/FBox3f/Test_Operators_01.as` | `MB-025-S007` `MB-025-S009` `MB-025-S011` `MB-025-S013` `MB-025-S023` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FBOX3F-003` | `TestSource/Bindings/FBox3f/Test_Queries_01.as` | `MB-025-S014` `MB-025-S015` `MB-025-S016` `MB-025-S017` `MB-025-S020` `MB-025-S021` | `Positive` | `Engine` |
| `TS-BIND-FBOX3F-004` | `TestSource/Bindings/FBox3f/Test_MutationAndLifecycle_01.as` | `MB-025-S025` | `Positive` | `Engine` |
| `TS-BIND-FBOX3F-005` | `TestSource/Bindings/FBox3f/Test_ConversionAndFormatting_01.as` | `MB-025-S026` | `Positive` | `Engine` |
| `TS-BIND-FBOX3F-006` | `TestSource/Bindings/FBox3f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-025-S022` | `Positive` | `Engine` |
| `TS-BIND-FBOX3F-007` | `TestSource/Bindings/FBox3f/Test_Behavior_01.as` | `MB-025-S002` `MB-025-S003` `MB-025-S004` `MB-025-S005` `MB-025-S006` `MB-025-S010` `MB-025-S018` `MB-025-S019` | `Positive` | `World` |
| `TS-BIND-FBOXSPHEREBOUNDS-001` | `TestSource/Bindings/FBoxSphereBounds/Test_ConstructionAndAssignment_01.as` | `MB-026-S011` `MB-026-S021` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS-002` | `TestSource/Bindings/FBoxSphereBounds/Test_Operators_01.as` | `MB-026-S012` | `Positive` | `World` |
| `TS-BIND-FBOXSPHEREBOUNDS-003` | `TestSource/Bindings/FBoxSphereBounds/Test_Queries_01.as` | `MB-026-S014` `MB-026-S015` `MB-026-S016` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS-004` | `TestSource/Bindings/FBoxSphereBounds/Test_NamespaceAndGlobalFunctions_01.as` | `MB-026-S019` `MB-026-S020` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS-005` | `TestSource/Bindings/FBoxSphereBounds/Test_Behavior_01.as` | `MB-026-S001` `MB-026-S002` `MB-026-S003` `MB-026-S004` `MB-026-S005` `MB-026-S006` `MB-026-S007` `MB-026-S008` `MB-026-S009` `MB-026-S010` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS-006` | `TestSource/Bindings/FBoxSphereBounds/Test_Behavior_02.as` | `MB-026-S013` `MB-026-S017` `MB-026-S018` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS3F-001` | `TestSource/Bindings/FBoxSphereBounds3f/Test_ConstructionAndAssignment_01.as` | `MB-027-S011` `MB-027-S021` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS3F-002` | `TestSource/Bindings/FBoxSphereBounds3f/Test_Operators_01.as` | `MB-027-S012` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS3F-003` | `TestSource/Bindings/FBoxSphereBounds3f/Test_Queries_01.as` | `MB-027-S014` `MB-027-S015` `MB-027-S016` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS3F-004` | `TestSource/Bindings/FBoxSphereBounds3f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-027-S019` `MB-027-S020` | `Positive` | `World` |
| `TS-BIND-FBOXSPHEREBOUNDS3F-005` | `TestSource/Bindings/FBoxSphereBounds3f/Test_Behavior_01.as` | `MB-027-S001` `MB-027-S002` `MB-027-S003` `MB-027-S004` `MB-027-S005` `MB-027-S006` `MB-027-S007` `MB-027-S008` `MB-027-S009` `MB-027-S010` | `Positive` | `Engine` |
| `TS-BIND-FBOXSPHEREBOUNDS3F-006` | `TestSource/Bindings/FBoxSphereBounds3f/Test_Behavior_02.as` | `MB-027-S013` `MB-027-S017` `MB-027-S018` | `Positive` | `Engine` |
| `TS-BIND-FFRAMETIME-001` | `TestSource/Bindings/FFrameTime/Test_Behavior_01.as` | `MB-036-S001` `MB-036-S002` | `Positive` | `Engine` |
| `TS-BIND-FGEOMETRY-001` | `TestSource/Bindings/FGeometry/Test_Queries_01.as` | `MB-038-S001` `MB-038-S002` | `Positive` | `Engine` |
| `TS-BIND-FGEOMETRY-002` | `TestSource/Bindings/FGeometry/Test_Behavior_01.as` | `MB-038-S003` `MB-038-S004` `MB-038-S005` | `Positive` | `Engine` |
| `TS-BIND-FINTPOINT-001` | `TestSource/Bindings/FIntPoint/Test_ConstructionAndAssignment_01.as` | `MB-045-S008` `MB-045-S009` `MB-045-S010` `MB-045-S011` `MB-045-S012` `MB-045-S013` `MB-045-S014` `MB-045-S015` `MB-045-S016` `MB-045-S017` | `Positive` | `World` |
| `TS-BIND-FINTPOINT-002` | `TestSource/Bindings/FIntPoint/Test_Operators_01.as` | `MB-045-S018` `MB-045-S019` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FINTPOINT-003` | `TestSource/Bindings/FIntPoint/Test_Queries_01.as` | `MB-045-S020` `MB-045-S021` | `Positive` | `Engine` |
| `TS-BIND-FINTPOINT-004` | `TestSource/Bindings/FIntPoint/Test_Behavior_01.as` | `MB-045-S001` `MB-045-S002` `MB-045-S003` `MB-045-S004` `MB-045-S005` `MB-045-S006` `MB-045-S007` `MB-045-S022` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR-001` | `TestSource/Bindings/FIntVector/Test_ConstructionAndAssignment_01.as` | `MB-046-S001` `MB-046-S009` `MB-046-S015` `MB-046-S016` `MB-046-S017` `MB-046-S018` `MB-046-S026` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR-002` | `TestSource/Bindings/FIntVector/Test_Operators_01.as` | `MB-046-S010` `MB-046-S011` `MB-046-S013` `MB-046-S014` `MB-046-S019` `MB-046-S020` `MB-046-S025` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FINTVECTOR-003` | `TestSource/Bindings/FIntVector/Test_Queries_01.as` | `MB-046-S021` `MB-046-S022` `MB-046-S024` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR-004` | `TestSource/Bindings/FIntVector/Test_MutationAndLifecycle_01.as` | `MB-046-S027` | `Positive` | `Engine` |
| `TS-BIND-FINTVECTOR-005` | `TestSource/Bindings/FIntVector/Test_ConversionAndFormatting_01.as` | `MB-046-S028` | `Positive` | `Engine` |
| `TS-BIND-FINTVECTOR-006` | `TestSource/Bindings/FIntVector/Test_Behavior_01.as` | `MB-046-S002` `MB-046-S003` `MB-046-S004` `MB-046-S005` `MB-046-S006` `MB-046-S007` `MB-046-S008` `MB-046-S012` `MB-046-S023` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR2-001` | `TestSource/Bindings/FIntVector2/Test_ConstructionAndAssignment_01.as` | `MB-047-S007` `MB-047-S010` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR2-002` | `TestSource/Bindings/FIntVector2/Test_Operators_01.as` | `MB-047-S008` `MB-047-S009` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FINTVECTOR2-003` | `TestSource/Bindings/FIntVector2/Test_Behavior_01.as` | `MB-047-S001` `MB-047-S002` `MB-047-S003` `MB-047-S004` `MB-047-S005` `MB-047-S006` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR4-001` | `TestSource/Bindings/FIntVector4/Test_ConstructionAndAssignment_01.as` | `MB-048-S009` `MB-048-S010` `MB-048-S011` `MB-048-S012` `MB-048-S013` `MB-048-S014` `MB-048-S015` `MB-048-S016` `MB-048-S017` `MB-048-S018` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR4-002` | `TestSource/Bindings/FIntVector4/Test_ConstructionAndAssignment_02.as` | `MB-048-S021` | `Positive` | `World` |
| `TS-BIND-FINTVECTOR4-003` | `TestSource/Bindings/FIntVector4/Test_Operators_01.as` | `MB-048-S019` `MB-048-S020` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FINTVECTOR4-004` | `TestSource/Bindings/FIntVector4/Test_Behavior_01.as` | `MB-048-S001` `MB-048-S002` `MB-048-S003` `MB-048-S004` `MB-048-S005` `MB-048-S006` `MB-048-S007` `MB-048-S008` | `Positive` | `World` |
| `TS-BIND-FLINEARCOLOR-001` | `TestSource/Bindings/FLinearColor/Test_ConstructionAndAssignment_01.as` | `MB-050-S008` `MB-050-S009` `MB-050-S010` `MB-050-S011` `MB-050-S012` `MB-050-S013` `MB-050-S014` `MB-050-S015` `MB-050-S016` `MB-050-S017` | `Positive` | `Engine` |
| `TS-BIND-FLINEARCOLOR-002` | `TestSource/Bindings/FLinearColor/Test_ConstructionAndAssignment_02.as` | `MB-050-S018` `MB-050-S019` `MB-050-S020` `MB-050-S049` | `Positive` | `Engine` |
| `TS-BIND-FLINEARCOLOR-003` | `TestSource/Bindings/FLinearColor/Test_Operators_01.as` | `MB-050-S021` | `Positive` | `Engine` |
| `TS-BIND-FLINEARCOLOR-004` | `TestSource/Bindings/FLinearColor/Test_Queries_01.as` | `MB-050-S022` `MB-050-S023` `MB-050-S024` `MB-050-S025` `MB-050-S026` `MB-050-S027` | `Positive` | `Engine` |
| `TS-BIND-FLINEARCOLOR-005` | `TestSource/Bindings/FLinearColor/Test_NamespaceAndGlobalFunctions_01.as` | `MB-050-S030` `MB-050-S031` `MB-050-S032` `MB-050-S033` `MB-050-S034` `MB-050-S035` `MB-050-S036` `MB-050-S037` `MB-050-S038` `MB-050-S039` | `Positive` | `World` |
| `TS-BIND-FLINEARCOLOR-006` | `TestSource/Bindings/FLinearColor/Test_NamespaceAndGlobalFunctions_02.as` | `MB-050-S040` `MB-050-S041` `MB-050-S042` `MB-050-S043` `MB-050-S044` `MB-050-S045` `MB-050-S046` | `Positive` | `Engine` |
| `TS-BIND-FLINEARCOLOR-007` | `TestSource/Bindings/FLinearColor/Test_Behavior_01.as` | `MB-050-S001` `MB-050-S002` `MB-050-S003` `MB-050-S004` `MB-050-S005` `MB-050-S006` `MB-050-S007` `MB-050-S028` `MB-050-S029` `MB-050-S047` | `Positive` | `World` |
| `TS-BIND-FLINEARCOLOR-008` | `TestSource/Bindings/FLinearColor/Test_Behavior_02.as` | `MB-050-S048` | `Positive` | `Engine` |
| `TS-BIND-FMARGIN-001` | `TestSource/Bindings/FMargin/Test_Operators_01.as` | `MB-051-S006` `MB-051-S007` `MB-051-S008` `MB-051-S009` `MB-051-S010` | `Positive` | `World` |
| `TS-BIND-FMARGIN-002` | `TestSource/Bindings/FMargin/Test_Queries_01.as` | `MB-051-S011` `MB-051-S012` `MB-051-S013` `MB-051-S014` | `Positive` | `World` |
| `TS-BIND-FMARGIN-003` | `TestSource/Bindings/FMargin/Test_Behavior_01.as` | `MB-051-S001` `MB-051-S002` `MB-051-S003` `MB-051-S004` `MB-051-S005` | `Positive` | `World` |
| `TS-BIND-FMATH-001` | `TestSource/Bindings/FMath/Test_Queries_01.as` | `MB-052-S010` `MB-052-S012` `MB-052-S013` `MB-052-S014` `MB-052-S015` `MB-052-S016` `MB-052-S033` `MB-052-S034` `MB-052-S035` `MB-052-S036` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FMATH-002` | `TestSource/Bindings/FMath/Test_Queries_02.as` | `MB-052-S051` `MB-052-S052` `MB-052-S053` `MB-052-S054` `MB-052-S055` `MB-052-S056` `MB-052-S129` `MB-052-S130` `MB-052-S135` `MB-052-S136` | `Positive` | `Engine` |
| `TS-BIND-FMATH-003` | `TestSource/Bindings/FMath/Test_Queries_03.as` | `MB-052-S181` `MB-052-S182` `MB-052-S183` `MB-052-S184` `MB-052-S185` `MB-052-S186` `MB-052-S187` `MB-052-S188` `MB-052-S189` `MB-052-S190` | `Positive` | `Engine` |
| `TS-BIND-FMATH-004` | `TestSource/Bindings/FMath/Test_Queries_04.as` | `MB-052-S195` `MB-052-S196` `MB-052-S197` `MB-052-S198` `MB-052-S244` `MB-052-S245` `MB-052-S246` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FMATH-005` | `TestSource/Bindings/FMath/Test_MutationAndLifecycle_01.as` | `MB-052-S103` `MB-052-S104` | `Positive` | `Engine` |
| `TS-BIND-FMATH-006` | `TestSource/Bindings/FMath/Test_ConversionAndFormatting_01.as` | `MB-052-S148` `MB-052-S164` | `Positive` | `Engine` |
| `TS-BIND-FMATH-007` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_01.as` | `MB-052-S001` `MB-052-S002` `MB-052-S003` `MB-052-S004` `MB-052-S005` `MB-052-S006` `MB-052-S007` `MB-052-S008` `MB-052-S009` `MB-052-S011` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FMATH-008` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_02.as` | `MB-052-S017` `MB-052-S018` `MB-052-S019` `MB-052-S020` `MB-052-S021` `MB-052-S022` `MB-052-S023` `MB-052-S024` `MB-052-S025` `MB-052-S026` | `Positive` | `Engine` |
| `TS-BIND-FMATH-009` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_03.as` | `MB-052-S027` `MB-052-S028` `MB-052-S029` `MB-052-S030` `MB-052-S031` `MB-052-S032` `MB-052-S037` `MB-052-S038` `MB-052-S039` `MB-052-S040` | `Positive` | `Engine` |
| `TS-BIND-FMATH-010` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_04.as` | `MB-052-S041` `MB-052-S042` `MB-052-S043` `MB-052-S044` `MB-052-S045` `MB-052-S046` `MB-052-S047` `MB-052-S048` `MB-052-S049` `MB-052-S050` | `Positive` | `World` |
| `TS-BIND-FMATH-011` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_05.as` | `MB-052-S057` `MB-052-S058` `MB-052-S059` `MB-052-S060` `MB-052-S061` `MB-052-S062` `MB-052-S063` `MB-052-S064` `MB-052-S065` `MB-052-S066` | `Positive` | `Engine` |
| `TS-BIND-FMATH-012` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_06.as` | `MB-052-S067` `MB-052-S068` `MB-052-S069` `MB-052-S070` `MB-052-S071` `MB-052-S072` `MB-052-S073` `MB-052-S074` `MB-052-S075` `MB-052-S076` | `Positive` | `Engine` |
| `TS-BIND-FMATH-013` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_07.as` | `MB-052-S077` `MB-052-S078` `MB-052-S079` `MB-052-S080` `MB-052-S081` `MB-052-S082` `MB-052-S083` `MB-052-S084` `MB-052-S085` `MB-052-S086` | `Positive` | `Engine` |
| `TS-BIND-FMATH-014` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_08.as` | `MB-052-S087` `MB-052-S088` `MB-052-S089` `MB-052-S090` `MB-052-S091` `MB-052-S092` `MB-052-S093` `MB-052-S094` `MB-052-S095` `MB-052-S096` | `Positive` | `Engine` |
| `TS-BIND-FMATH-015` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_09.as` | `MB-052-S097` `MB-052-S098` `MB-052-S099` `MB-052-S100` `MB-052-S101` `MB-052-S102` `MB-052-S105` `MB-052-S106` `MB-052-S107` `MB-052-S108` | `Positive` | `Engine` |
| `TS-BIND-FMATH-016` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_10.as` | `MB-052-S109` `MB-052-S110` `MB-052-S111` `MB-052-S112` `MB-052-S113` `MB-052-S114` `MB-052-S115` `MB-052-S116` `MB-052-S117` `MB-052-S118` | `Positive` | `Engine` |
| `TS-BIND-FMATH-017` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_11.as` | `MB-052-S119` `MB-052-S120` `MB-052-S121` `MB-052-S122` `MB-052-S123` `MB-052-S124` `MB-052-S125` `MB-052-S126` `MB-052-S127` `MB-052-S128` | `Positive` | `Engine` |
| `TS-BIND-FMATH-018` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_12.as` | `MB-052-S131` `MB-052-S132` `MB-052-S133` `MB-052-S134` `MB-052-S137` `MB-052-S138` `MB-052-S139` `MB-052-S140` `MB-052-S141` `MB-052-S142` | `Positive` | `Engine` |
| `TS-BIND-FMATH-019` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_13.as` | `MB-052-S143` `MB-052-S144` `MB-052-S145` `MB-052-S146` `MB-052-S147` `MB-052-S149` `MB-052-S150` `MB-052-S151` `MB-052-S152` `MB-052-S153` | `Positive` | `Engine` |
| `TS-BIND-FMATH-020` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_14.as` | `MB-052-S154` `MB-052-S155` `MB-052-S156` `MB-052-S157` `MB-052-S158` `MB-052-S159` `MB-052-S160` `MB-052-S161` `MB-052-S162` `MB-052-S163` | `Positive` | `Engine` |
| `TS-BIND-FMATH-021` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_15.as` | `MB-052-S165` `MB-052-S166` `MB-052-S167` `MB-052-S168` `MB-052-S169` `MB-052-S170` `MB-052-S171` `MB-052-S172` `MB-052-S173` `MB-052-S174` | `Positive` | `Engine` |
| `TS-BIND-FMATH-022` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_16.as` | `MB-052-S175` `MB-052-S176` `MB-052-S177` `MB-052-S178` `MB-052-S179` `MB-052-S180` `MB-052-S191` `MB-052-S192` `MB-052-S193` `MB-052-S194` | `Positive` | `Engine` |
| `TS-BIND-FMATH-023` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_17.as` | `MB-052-S199` `MB-052-S200` `MB-052-S201` `MB-052-S202` `MB-052-S203` `MB-052-S204` `MB-052-S205` `MB-052-S206` `MB-052-S207` `MB-052-S208` | `Positive` | `World` |
| `TS-BIND-FMATH-024` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_18.as` | `MB-052-S209` `MB-052-S210` `MB-052-S211` `MB-052-S212` `MB-052-S213` `MB-052-S214` `MB-052-S215` `MB-052-S216` `MB-052-S217` `MB-052-S218` | `Positive` | `Engine` |
| `TS-BIND-FMATH-025` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_19.as` | `MB-052-S219` `MB-052-S220` `MB-052-S221` `MB-052-S222` `MB-052-S223` `MB-052-S224` `MB-052-S225` `MB-052-S226` `MB-052-S227` `MB-052-S228` | `Positive` | `Engine` |
| `TS-BIND-FMATH-026` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_20.as` | `MB-052-S229` `MB-052-S230` `MB-052-S231` `MB-052-S232` `MB-052-S233` `MB-052-S234` `MB-052-S235` `MB-052-S236` `MB-052-S237` `MB-052-S238` | `Positive` | `Engine` |
| `TS-BIND-FMATH-027` | `TestSource/Bindings/FMath/Test_NamespaceAndGlobalFunctions_21.as` | `MB-052-S239` `MB-052-S240` `MB-052-S241` `MB-052-S242` `MB-052-S243` `MB-052-S247` `MB-052-S248` `MB-052-S249` `MB-052-S250` `MB-052-S251` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FMATRIX-001` | `TestSource/Bindings/FMatrix/Test_NamespaceAndGlobalFunctions_01.as` | `MB-053-S002` | `Positive` | `Engine` |
| `TS-BIND-FMATRIX-002` | `TestSource/Bindings/FMatrix/Test_Behavior_01.as` | `MB-053-S001` `MB-053-S003` `MB-053-S004` | `Positive` | `Engine` |
| `TS-BIND-FPLANE-001` | `TestSource/Bindings/FPlane/Test_Queries_01.as` | `MB-061-S005` `MB-061-S006` | `Positive` | `Engine` |
| `TS-BIND-FPLANE-002` | `TestSource/Bindings/FPlane/Test_Behavior_01.as` | `MB-061-S001` `MB-061-S002` `MB-061-S003` `MB-061-S004` `MB-061-S007` `MB-061-S008` | `Positive` | `Engine` |
| `TS-BIND-FPLANE4F-001` | `TestSource/Bindings/FPlane4f/Test_Queries_01.as` | `MB-062-S005` `MB-062-S006` | `Positive` | `Engine` |
| `TS-BIND-FPLANE4F-002` | `TestSource/Bindings/FPlane4f/Test_Behavior_01.as` | `MB-062-S001` `MB-062-S002` `MB-062-S003` `MB-062-S004` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-001` | `TestSource/Bindings/FQuat/Test_ConstructionAndAssignment_01.as` | `MB-066-S004` `MB-066-S005` `MB-066-S006` `MB-066-S007` `MB-066-S008` `MB-066-S012` `MB-066-S013` `MB-066-S014` `MB-066-S015` `MB-066-S016` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-002` | `TestSource/Bindings/FQuat/Test_ConstructionAndAssignment_02.as` | `MB-066-S017` `MB-066-S039` `MB-066-S072` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-003` | `TestSource/Bindings/FQuat/Test_Operators_01.as` | `MB-066-S009` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-004` | `TestSource/Bindings/FQuat/Test_Queries_01.as` | `MB-066-S010` `MB-066-S011` `MB-066-S019` `MB-066-S020` `MB-066-S023` `MB-066-S032` `MB-066-S046` `MB-066-S047` `MB-066-S048` `MB-066-S060` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-005` | `TestSource/Bindings/FQuat/Test_Queries_02.as` | `MB-066-S061` `MB-066-S062` `MB-066-S063` `MB-066-S064` `MB-066-S065` `MB-066-S067` `MB-066-S070` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-006` | `TestSource/Bindings/FQuat/Test_ConversionAndFormatting_01.as` | `MB-066-S037` `MB-066-S038` `MB-066-S069` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-007` | `TestSource/Bindings/FQuat/Test_NamespaceAndGlobalFunctions_01.as` | `MB-066-S043` `MB-066-S044` `MB-066-S045` `MB-066-S049` `MB-066-S050` `MB-066-S051` `MB-066-S052` `MB-066-S053` `MB-066-S054` `MB-066-S055` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FQUAT-008` | `TestSource/Bindings/FQuat/Test_NamespaceAndGlobalFunctions_02.as` | `MB-066-S056` `MB-066-S057` `MB-066-S058` `MB-066-S059` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-009` | `TestSource/Bindings/FQuat/Test_Behavior_01.as` | `MB-066-S001` `MB-066-S002` `MB-066-S003` `MB-066-S018` `MB-066-S021` `MB-066-S022` `MB-066-S024` `MB-066-S025` `MB-066-S026` `MB-066-S027` | `Positive` | `Engine` |
| `TS-BIND-FQUAT-010` | `TestSource/Bindings/FQuat/Test_Behavior_02.as` | `MB-066-S028` `MB-066-S029` `MB-066-S030` `MB-066-S031` `MB-066-S033` `MB-066-S034` `MB-066-S035` `MB-066-S036` `MB-066-S040` `MB-066-S041` | `Positive` | `World` |
| `TS-BIND-FQUAT-011` | `TestSource/Bindings/FQuat/Test_Behavior_03.as` | `MB-066-S042` `MB-066-S066` `MB-066-S068` `MB-066-S071` | `Positive` | `Engine` |
| `TS-BIND-FQUAT4F-001` | `TestSource/Bindings/FQuat4f/Test_ConstructionAndAssignment_01.as` | `MB-067-S012` `MB-067-S013` `MB-067-S014` `MB-067-S015` `MB-067-S016` `MB-067-S020` `MB-067-S021` `MB-067-S022` `MB-067-S023` `MB-067-S024` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-002` | `TestSource/Bindings/FQuat4f/Test_ConstructionAndAssignment_02.as` | `MB-067-S025` `MB-067-S026` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-003` | `TestSource/Bindings/FQuat4f/Test_Operators_01.as` | `MB-067-S017` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-004` | `TestSource/Bindings/FQuat4f/Test_Queries_01.as` | `MB-067-S018` `MB-067-S019` `MB-067-S028` `MB-067-S029` `MB-067-S032` `MB-067-S037` `MB-067-S043` `MB-067-S044` `MB-067-S045` `MB-067-S046` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-005` | `TestSource/Bindings/FQuat4f/Test_Queries_02.as` | `MB-067-S047` `MB-067-S048` `MB-067-S050` `MB-067-S053` `MB-067-S057` `MB-067-S058` `MB-067-S059` | `Positive` | `Engine` |
| `TS-BIND-FQUAT4F-006` | `TestSource/Bindings/FQuat4f/Test_ConversionAndFormatting_01.as` | `MB-067-S039` `MB-067-S052` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-007` | `TestSource/Bindings/FQuat4f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-067-S055` `MB-067-S056` `MB-067-S060` `MB-067-S061` `MB-067-S062` `MB-067-S063` `MB-067-S064` `MB-067-S065` `MB-067-S066` `MB-067-S067` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FQUAT4F-008` | `TestSource/Bindings/FQuat4f/Test_NamespaceAndGlobalFunctions_02.as` | `MB-067-S068` `MB-067-S069` `MB-067-S070` | `Positive` | `Engine` |
| `TS-BIND-FQUAT4F-009` | `TestSource/Bindings/FQuat4f/Test_Behavior_01.as` | `MB-067-S001` `MB-067-S002` `MB-067-S003` `MB-067-S004` `MB-067-S005` `MB-067-S006` `MB-067-S007` `MB-067-S008` `MB-067-S009` `MB-067-S010` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-010` | `TestSource/Bindings/FQuat4f/Test_Behavior_02.as` | `MB-067-S011` `MB-067-S027` `MB-067-S030` `MB-067-S031` `MB-067-S033` `MB-067-S034` `MB-067-S035` `MB-067-S036` `MB-067-S038` `MB-067-S040` | `Positive` | `World` |
| `TS-BIND-FQUAT4F-011` | `TestSource/Bindings/FQuat4f/Test_Behavior_03.as` | `MB-067-S041` `MB-067-S042` `MB-067-S049` `MB-067-S051` `MB-067-S054` | `Positive` | `World` |
| `TS-BIND-FRANDOMSTREAM-001` | `TestSource/Bindings/FRandomStream/Test_ConstructionAndAssignment_01.as` | `MB-068-S001` `MB-068-S021` | `Positive` | `Engine` |
| `TS-BIND-FRANDOMSTREAM-002` | `TestSource/Bindings/FRandomStream/Test_Operators_01.as` | `MB-068-S020` | `Positive` | `Engine` |
| `TS-BIND-FRANDOMSTREAM-003` | `TestSource/Bindings/FRandomStream/Test_Queries_01.as` | `MB-068-S009` `MB-068-S011` `MB-068-S012` `MB-068-S013` `MB-068-S016` | `Positive` | `Engine` |
| `TS-BIND-FRANDOMSTREAM-004` | `TestSource/Bindings/FRandomStream/Test_MutationAndLifecycle_01.as` | `MB-068-S008` `MB-068-S022` | `Positive` | `Engine` |
| `TS-BIND-FRANDOMSTREAM-005` | `TestSource/Bindings/FRandomStream/Test_ConversionAndFormatting_01.as` | `MB-068-S023` | `Positive` | `Engine` |
| `TS-BIND-FRANDOMSTREAM-006` | `TestSource/Bindings/FRandomStream/Test_Behavior_01.as` | `MB-068-S002` `MB-068-S003` `MB-068-S004` `MB-068-S005` `MB-068-S006` `MB-068-S007` `MB-068-S010` `MB-068-S014` `MB-068-S015` `MB-068-S017` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FRANDOMSTREAM-007` | `TestSource/Bindings/FRandomStream/Test_Behavior_02.as` | `MB-068-S018` `MB-068-S019` | `Positive` | `Engine` |
| `TS-BIND-FRANGE-001` | `TestSource/Bindings/FRange/Test_Queries_01.as` | `MB-069-S002` | `Positive` | `Engine` |
| `TS-BIND-FRANGE-002` | `TestSource/Bindings/FRange/Test_NamespaceAndGlobalFunctions_01.as` | `MB-069-S004` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FRANGE-003` | `TestSource/Bindings/FRange/Test_Behavior_01.as` | `MB-069-S001` `MB-069-S003` `MB-069-S005` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FROTATOR-001` | `TestSource/Bindings/FRotator/Test_ConstructionAndAssignment_01.as` | `MB-070-S001` `MB-070-S011` `MB-070-S013` `MB-070-S015` `MB-070-S017` `MB-070-S054` | `Positive` | `World` |
| `TS-BIND-FROTATOR-002` | `TestSource/Bindings/FRotator/Test_Operators_01.as` | `MB-070-S012` `MB-070-S014` `MB-070-S016` `MB-070-S018` `MB-070-S053` | `Positive` | `World` |
| `TS-BIND-FROTATOR-003` | `TestSource/Bindings/FRotator/Test_Queries_01.as` | `MB-070-S019` `MB-070-S020` `MB-070-S021` `MB-070-S022` `MB-070-S024` `MB-070-S025` `MB-070-S026` `MB-070-S027` `MB-070-S029` `MB-070-S046` | `Positive` | `World` |
| `TS-BIND-FROTATOR-004` | `TestSource/Bindings/FRotator/Test_Queries_02.as` | `MB-070-S047` `MB-070-S048` | `Positive` | `Engine` |
| `TS-BIND-FROTATOR-005` | `TestSource/Bindings/FRotator/Test_MutationAndLifecycle_01.as` | `MB-070-S055` | `Positive` | `Engine` |
| `TS-BIND-FROTATOR-006` | `TestSource/Bindings/FRotator/Test_ConversionAndFormatting_01.as` | `MB-070-S051` `MB-070-S056` | `Positive` | `Editor` |
| `TS-BIND-FROTATOR-007` | `TestSource/Bindings/FRotator/Test_NamespaceAndGlobalFunctions_01.as` | `MB-070-S030` `MB-070-S031` `MB-070-S032` `MB-070-S033` `MB-070-S034` `MB-070-S035` `MB-070-S036` `MB-070-S037` `MB-070-S038` `MB-070-S039` | `Positive` | `World` |
| `TS-BIND-FROTATOR-008` | `TestSource/Bindings/FRotator/Test_NamespaceAndGlobalFunctions_02.as` | `MB-070-S040` `MB-070-S041` `MB-070-S042` | `Positive` | `Engine` |
| `TS-BIND-FROTATOR-009` | `TestSource/Bindings/FRotator/Test_Behavior_01.as` | `MB-070-S002` `MB-070-S003` `MB-070-S004` `MB-070-S005` `MB-070-S006` `MB-070-S007` `MB-070-S008` `MB-070-S009` `MB-070-S010` `MB-070-S023` | `Positive` | `World` |
| `TS-BIND-FROTATOR-010` | `TestSource/Bindings/FRotator/Test_Behavior_02.as` | `MB-070-S028` `MB-070-S043` `MB-070-S044` `MB-070-S045` `MB-070-S049` `MB-070-S050` `MB-070-S052` | `Positive` | `World` |
| `TS-BIND-FROTATOR3F-001` | `TestSource/Bindings/FRotator3f/Test_ConstructionAndAssignment_01.as` | `MB-071-S008` `MB-071-S009` `MB-071-S010` `MB-071-S011` `MB-071-S012` `MB-071-S013` `MB-071-S014` `MB-071-S040` | `Positive` | `World` |
| `TS-BIND-FROTATOR3F-002` | `TestSource/Bindings/FRotator3f/Test_Operators_01.as` | `MB-071-S015` | `Positive` | `Engine` |
| `TS-BIND-FROTATOR3F-003` | `TestSource/Bindings/FRotator3f/Test_Queries_01.as` | `MB-071-S016` `MB-071-S017` `MB-071-S018` `MB-071-S019` `MB-071-S021` `MB-071-S022` `MB-071-S023` `MB-071-S024` `MB-071-S026` | `Positive` | `World` |
| `TS-BIND-FROTATOR3F-004` | `TestSource/Bindings/FRotator3f/Test_ConversionAndFormatting_01.as` | `MB-071-S038` | `Positive` | `World` |
| `TS-BIND-FROTATOR3F-005` | `TestSource/Bindings/FRotator3f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-071-S027` `MB-071-S028` `MB-071-S029` `MB-071-S030` | `Positive` | `Engine` |
| `TS-BIND-FROTATOR3F-006` | `TestSource/Bindings/FRotator3f/Test_Behavior_01.as` | `MB-071-S001` `MB-071-S002` `MB-071-S003` `MB-071-S004` `MB-071-S005` `MB-071-S006` `MB-071-S007` `MB-071-S020` `MB-071-S025` `MB-071-S031` | `Positive` | `Engine` |
| `TS-BIND-FROTATOR3F-007` | `TestSource/Bindings/FRotator3f/Test_Behavior_02.as` | `MB-071-S032` `MB-071-S033` `MB-071-S034` `MB-071-S035` `MB-071-S036` `MB-071-S037` `MB-071-S039` | `Positive` | `World` |
| `TS-BIND-FSPHERE-001` | `TestSource/Bindings/FSphere/Test_ConstructionAndAssignment_01.as` | `MB-072-S008` `MB-072-S009` | `Positive` | `Engine` |
| `TS-BIND-FSPHERE-002` | `TestSource/Bindings/FSphere/Test_Queries_01.as` | `MB-072-S010` `MB-072-S011` `MB-072-S012` `MB-072-S015` | `Positive` | `World` |
| `TS-BIND-FSPHERE-003` | `TestSource/Bindings/FSphere/Test_Behavior_01.as` | `MB-072-S001` `MB-072-S002` `MB-072-S003` `MB-072-S004` `MB-072-S005` `MB-072-S006` `MB-072-S007` `MB-072-S013` `MB-072-S014` | `Positive` | `World` |
| `TS-BIND-FSPHERE3F-001` | `TestSource/Bindings/FSphere3f/Test_ConstructionAndAssignment_01.as` | `MB-073-S008` `MB-073-S009` | `Positive` | `Engine` |
| `TS-BIND-FSPHERE3F-002` | `TestSource/Bindings/FSphere3f/Test_Queries_01.as` | `MB-073-S010` `MB-073-S011` `MB-073-S013` | `Positive` | `World` |
| `TS-BIND-FSPHERE3F-003` | `TestSource/Bindings/FSphere3f/Test_Behavior_01.as` | `MB-073-S001` `MB-073-S002` `MB-073-S003` `MB-073-S004` `MB-073-S005` `MB-073-S006` `MB-073-S007` `MB-073-S012` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM-001` | `TestSource/Bindings/FTransform/Test_ConstructionAndAssignment_01.as` | `MB-078-S011` `MB-078-S015` `MB-078-S016` `MB-078-S017` `MB-078-S018` `MB-078-S063` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-002` | `TestSource/Bindings/FTransform/Test_Queries_01.as` | `MB-078-S024` `MB-078-S025` `MB-078-S026` `MB-078-S027` `MB-078-S040` `MB-078-S042` `MB-078-S043` `MB-078-S044` `MB-078-S045` `MB-078-S046` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-003` | `TestSource/Bindings/FTransform/Test_Queries_02.as` | `MB-078-S047` `MB-078-S049` `MB-078-S050` `MB-078-S051` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-004` | `TestSource/Bindings/FTransform/Test_MutationAndLifecycle_01.as` | `MB-078-S021` `MB-078-S022` `MB-078-S055` `MB-078-S056` `MB-078-S057` `MB-078-S059` `MB-078-S060` `MB-078-S061` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-005` | `TestSource/Bindings/FTransform/Test_ConversionAndFormatting_01.as` | `MB-078-S052` `MB-078-S053` `MB-078-S054` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-006` | `TestSource/Bindings/FTransform/Test_NamespaceAndGlobalFunctions_01.as` | `MB-078-S003` `MB-078-S007` `MB-078-S008` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-007` | `TestSource/Bindings/FTransform/Test_Behavior_01.as` | `MB-078-S001` `MB-078-S002` `MB-078-S004` `MB-078-S005` `MB-078-S006` `MB-078-S009` `MB-078-S010` `MB-078-S012` `MB-078-S013` `MB-078-S014` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM-008` | `TestSource/Bindings/FTransform/Test_Behavior_02.as` | `MB-078-S019` `MB-078-S020` `MB-078-S023` `MB-078-S028` `MB-078-S029` `MB-078-S030` `MB-078-S031` `MB-078-S032` `MB-078-S033` `MB-078-S034` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM-009` | `TestSource/Bindings/FTransform/Test_Behavior_03.as` | `MB-078-S035` `MB-078-S036` `MB-078-S037` `MB-078-S038` `MB-078-S039` `MB-078-S041` `MB-078-S048` `MB-078-S058` `MB-078-S062` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM3F-001` | `TestSource/Bindings/FTransform3f/Test_ConstructionAndAssignment_01.as` | `MB-079-S011` `MB-079-S015` `MB-079-S016` `MB-079-S017` `MB-079-S018` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM3F-002` | `TestSource/Bindings/FTransform3f/Test_Queries_01.as` | `MB-079-S024` `MB-079-S025` `MB-079-S026` `MB-079-S027` `MB-079-S040` `MB-079-S042` `MB-079-S043` `MB-079-S044` `MB-079-S045` `MB-079-S046` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM3F-003` | `TestSource/Bindings/FTransform3f/Test_Queries_02.as` | `MB-079-S047` `MB-079-S049` `MB-079-S050` `MB-079-S051` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM3F-004` | `TestSource/Bindings/FTransform3f/Test_MutationAndLifecycle_01.as` | `MB-079-S021` `MB-079-S022` `MB-079-S052` `MB-079-S053` `MB-079-S054` `MB-079-S056` `MB-079-S057` `MB-079-S058` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM3F-005` | `TestSource/Bindings/FTransform3f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-079-S007` `MB-079-S008` `MB-079-S060` | `Positive` | `Engine` |
| `TS-BIND-FTRANSFORM3F-006` | `TestSource/Bindings/FTransform3f/Test_Behavior_01.as` | `MB-079-S001` `MB-079-S002` `MB-079-S003` `MB-079-S004` `MB-079-S005` `MB-079-S006` `MB-079-S009` `MB-079-S010` `MB-079-S012` `MB-079-S013` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM3F-007` | `TestSource/Bindings/FTransform3f/Test_Behavior_02.as` | `MB-079-S014` `MB-079-S019` `MB-079-S020` `MB-079-S023` `MB-079-S028` `MB-079-S029` `MB-079-S030` `MB-079-S031` `MB-079-S032` `MB-079-S033` | `Positive` | `World` |
| `TS-BIND-FTRANSFORM3F-008` | `TestSource/Bindings/FTransform3f/Test_Behavior_03.as` | `MB-079-S034` `MB-079-S035` `MB-079-S036` `MB-079-S037` `MB-079-S038` `MB-079-S039` `MB-079-S041` `MB-079-S048` `MB-079-S055` `MB-079-S059` | `Positive` | `World` |
| `TS-BIND-FVECTOR-001` | `TestSource/Bindings/FVector/Test_ConstructionAndAssignment_01.as` | `MB-081-S001` `MB-081-S011` `MB-081-S019` `MB-081-S020` `MB-081-S021` `MB-081-S022` `MB-081-S023` `MB-081-S024` `MB-081-S100` | `Positive` | `World` |
| `TS-BIND-FVECTOR-002` | `TestSource/Bindings/FVector/Test_Operators_01.as` | `MB-081-S012` `MB-081-S013` `MB-081-S014` `MB-081-S015` `MB-081-S016` `MB-081-S017` `MB-081-S025` `MB-081-S026` `MB-081-S027` `MB-081-S099` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FVECTOR-003` | `TestSource/Bindings/FVector/Test_Queries_01.as` | `MB-081-S028` `MB-081-S035` `MB-081-S036` `MB-081-S037` `MB-081-S038` `MB-081-S042` `MB-081-S047` `MB-081-S048` `MB-081-S050` `MB-081-S053` | `Positive` | `World` |
| `TS-BIND-FVECTOR-004` | `TestSource/Bindings/FVector/Test_Queries_02.as` | `MB-081-S055` `MB-081-S059` `MB-081-S060` `MB-081-S061` `MB-081-S062` `MB-081-S065` `MB-081-S069` `MB-081-S070` `MB-081-S074` `MB-081-S076` | `Positive` | `World` |
| `TS-BIND-FVECTOR-005` | `TestSource/Bindings/FVector/Test_Queries_03.as` | `MB-081-S077` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR-006` | `TestSource/Bindings/FVector/Test_MutationAndLifecycle_01.as` | `MB-081-S063` `MB-081-S101` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR-007` | `TestSource/Bindings/FVector/Test_ConversionAndFormatting_01.as` | `MB-081-S051` `MB-081-S052` `MB-081-S095` `MB-081-S096` `MB-081-S102` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR-008` | `TestSource/Bindings/FVector/Test_NamespaceAndGlobalFunctions_01.as` | `MB-081-S087` `MB-081-S088` `MB-081-S089` `MB-081-S090` `MB-081-S091` `MB-081-S092` `MB-081-S093` `MB-081-S094` | `Positive` | `World` |
| `TS-BIND-FVECTOR-009` | `TestSource/Bindings/FVector/Test_Behavior_01.as` | `MB-081-S002` `MB-081-S003` `MB-081-S004` `MB-081-S005` `MB-081-S006` `MB-081-S007` `MB-081-S008` `MB-081-S009` `MB-081-S010` `MB-081-S018` | `Positive` | `World` |
| `TS-BIND-FVECTOR-010` | `TestSource/Bindings/FVector/Test_Behavior_02.as` | `MB-081-S029` `MB-081-S030` `MB-081-S031` `MB-081-S032` `MB-081-S033` `MB-081-S034` `MB-081-S039` `MB-081-S040` `MB-081-S041` `MB-081-S043` | `Positive` | `World` |
| `TS-BIND-FVECTOR-011` | `TestSource/Bindings/FVector/Test_Behavior_03.as` | `MB-081-S044` `MB-081-S045` `MB-081-S046` `MB-081-S049` `MB-081-S054` `MB-081-S056` `MB-081-S057` `MB-081-S058` `MB-081-S064` `MB-081-S066` | `Positive` | `World` |
| `TS-BIND-FVECTOR-012` | `TestSource/Bindings/FVector/Test_Behavior_04.as` | `MB-081-S067` `MB-081-S068` `MB-081-S071` `MB-081-S072` `MB-081-S073` `MB-081-S075` `MB-081-S078` `MB-081-S079` `MB-081-S080` `MB-081-S081` | `Positive` | `World` |
| `TS-BIND-FVECTOR-013` | `TestSource/Bindings/FVector/Test_Behavior_05.as` | `MB-081-S082` `MB-081-S083` `MB-081-S084` `MB-081-S085` `MB-081-S086` `MB-081-S097` `MB-081-S098` | `Positive` | `World` |
| `TS-BIND-FVECTOR2D-001` | `TestSource/Bindings/FVector2D/Test_ConstructionAndAssignment_01.as` | `MB-082-S001` `MB-082-S008` `MB-082-S018` `MB-082-S019` `MB-082-S020` `MB-082-S021` `MB-082-S022` `MB-082-S023` `MB-082-S049` | `Positive` | `World` |
| `TS-BIND-FVECTOR2D-002` | `TestSource/Bindings/FVector2D/Test_Operators_01.as` | `MB-082-S009` `MB-082-S010` `MB-082-S011` `MB-082-S012` `MB-082-S013` `MB-082-S014` `MB-082-S015` `MB-082-S016` `MB-082-S024` `MB-082-S025` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FVECTOR2D-003` | `TestSource/Bindings/FVector2D/Test_Operators_02.as` | `MB-082-S026` `MB-082-S048` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2D-004` | `TestSource/Bindings/FVector2D/Test_Queries_01.as` | `MB-082-S027` `MB-082-S030` `MB-082-S031` `MB-082-S032` `MB-082-S033` `MB-082-S036` `MB-082-S037` `MB-082-S039` `MB-082-S040` `MB-082-S041` | `Positive` | `World` |
| `TS-BIND-FVECTOR2D-005` | `TestSource/Bindings/FVector2D/Test_Queries_02.as` | `MB-082-S044` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2D-006` | `TestSource/Bindings/FVector2D/Test_MutationAndLifecycle_01.as` | `MB-082-S050` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2D-007` | `TestSource/Bindings/FVector2D/Test_ConversionAndFormatting_01.as` | `MB-082-S051` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2D-008` | `TestSource/Bindings/FVector2D/Test_NamespaceAndGlobalFunctions_01.as` | `MB-082-S046` `MB-082-S047` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2D-009` | `TestSource/Bindings/FVector2D/Test_Behavior_01.as` | `MB-082-S002` `MB-082-S003` `MB-082-S004` `MB-082-S005` `MB-082-S006` `MB-082-S007` `MB-082-S017` `MB-082-S028` `MB-082-S029` `MB-082-S034` | `Positive` | `World` |
| `TS-BIND-FVECTOR2D-010` | `TestSource/Bindings/FVector2D/Test_Behavior_02.as` | `MB-082-S035` `MB-082-S038` `MB-082-S042` `MB-082-S043` `MB-082-S045` | `Positive` | `World` |
| `TS-BIND-FVECTOR2F-001` | `TestSource/Bindings/FVector2f/Test_ConstructionAndAssignment_01.as` | `MB-083-S009` `MB-083-S010` `MB-083-S011` `MB-083-S012` `MB-083-S013` `MB-083-S014` `MB-083-S015` `MB-083-S016` `MB-083-S017` `MB-083-S018` | `Positive` | `World` |
| `TS-BIND-FVECTOR2F-002` | `TestSource/Bindings/FVector2f/Test_ConstructionAndAssignment_02.as` | `MB-083-S019` `MB-083-S020` `MB-083-S021` `MB-083-S022` `MB-083-S023` `MB-083-S024` | `Positive` | `World` |
| `TS-BIND-FVECTOR2F-003` | `TestSource/Bindings/FVector2f/Test_Operators_01.as` | `MB-083-S025` `MB-083-S026` `MB-083-S027` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FVECTOR2F-004` | `TestSource/Bindings/FVector2f/Test_Queries_01.as` | `MB-083-S028` `MB-083-S031` `MB-083-S032` `MB-083-S033` `MB-083-S034` `MB-083-S037` `MB-083-S038` `MB-083-S040` `MB-083-S042` `MB-083-S043` | `Positive` | `World` |
| `TS-BIND-FVECTOR2F-005` | `TestSource/Bindings/FVector2f/Test_Queries_02.as` | `MB-083-S046` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2F-006` | `TestSource/Bindings/FVector2f/Test_ConversionAndFormatting_01.as` | `MB-083-S041` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR2F-007` | `TestSource/Bindings/FVector2f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-083-S048` `MB-083-S049` | `Positive` | `World` |
| `TS-BIND-FVECTOR2F-008` | `TestSource/Bindings/FVector2f/Test_Behavior_01.as` | `MB-083-S001` `MB-083-S002` `MB-083-S003` `MB-083-S004` `MB-083-S005` `MB-083-S006` `MB-083-S007` `MB-083-S008` `MB-083-S029` `MB-083-S030` | `Positive` | `World` |
| `TS-BIND-FVECTOR2F-009` | `TestSource/Bindings/FVector2f/Test_Behavior_02.as` | `MB-083-S035` `MB-083-S036` `MB-083-S039` `MB-083-S044` `MB-083-S045` `MB-083-S047` | `Positive` | `World` |
| `TS-BIND-FVECTOR3F-001` | `TestSource/Bindings/FVector3f/Test_ConstructionAndAssignment_01.as` | `MB-084-S008` `MB-084-S009` `MB-084-S010` `MB-084-S011` `MB-084-S012` `MB-084-S013` `MB-084-S014` `MB-084-S015` `MB-084-S016` `MB-084-S017` | `Positive` | `World` |
| `TS-BIND-FVECTOR3F-002` | `TestSource/Bindings/FVector3f/Test_ConstructionAndAssignment_02.as` | `MB-084-S018` `MB-084-S019` `MB-084-S020` `MB-084-S021` `MB-084-S093` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-003` | `TestSource/Bindings/FVector3f/Test_Operators_01.as` | `MB-084-S022` `MB-084-S023` `MB-084-S024` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FVECTOR3F-004` | `TestSource/Bindings/FVector3f/Test_Queries_01.as` | `MB-084-S025` `MB-084-S032` `MB-084-S033` `MB-084-S034` `MB-084-S035` `MB-084-S039` `MB-084-S044` `MB-084-S045` `MB-084-S047` `MB-084-S049` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-005` | `TestSource/Bindings/FVector3f/Test_Queries_02.as` | `MB-084-S051` `MB-084-S055` `MB-084-S056` `MB-084-S057` `MB-084-S058` `MB-084-S061` `MB-084-S065` `MB-084-S066` `MB-084-S070` `MB-084-S072` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-006` | `TestSource/Bindings/FVector3f/Test_Queries_03.as` | `MB-084-S073` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-007` | `TestSource/Bindings/FVector3f/Test_MutationAndLifecycle_01.as` | `MB-084-S059` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-008` | `TestSource/Bindings/FVector3f/Test_ConversionAndFormatting_01.as` | `MB-084-S048` `MB-084-S088` `MB-084-S089` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-009` | `TestSource/Bindings/FVector3f/Test_NamespaceAndGlobalFunctions_01.as` | `MB-084-S083` `MB-084-S084` `MB-084-S085` `MB-084-S086` `MB-084-S087` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-010` | `TestSource/Bindings/FVector3f/Test_Behavior_01.as` | `MB-084-S001` `MB-084-S002` `MB-084-S003` `MB-084-S004` `MB-084-S005` `MB-084-S006` `MB-084-S007` `MB-084-S026` `MB-084-S027` `MB-084-S028` | `Positive` | `World` |
| `TS-BIND-FVECTOR3F-011` | `TestSource/Bindings/FVector3f/Test_Behavior_02.as` | `MB-084-S029` `MB-084-S030` `MB-084-S031` `MB-084-S036` `MB-084-S037` `MB-084-S038` `MB-084-S040` `MB-084-S041` `MB-084-S042` `MB-084-S043` | `Positive` | `World` |
| `TS-BIND-FVECTOR3F-012` | `TestSource/Bindings/FVector3f/Test_Behavior_03.as` | `MB-084-S046` `MB-084-S050` `MB-084-S052` `MB-084-S053` `MB-084-S054` `MB-084-S060` `MB-084-S062` `MB-084-S063` `MB-084-S064` `MB-084-S067` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-013` | `TestSource/Bindings/FVector3f/Test_Behavior_04.as` | `MB-084-S068` `MB-084-S069` `MB-084-S071` `MB-084-S074` `MB-084-S075` `MB-084-S076` `MB-084-S077` `MB-084-S078` `MB-084-S079` `MB-084-S080` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR3F-014` | `TestSource/Bindings/FVector3f/Test_Behavior_05.as` | `MB-084-S081` `MB-084-S082` `MB-084-S090` `MB-084-S091` `MB-084-S092` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR4-001` | `TestSource/Bindings/FVector4/Test_ConstructionAndAssignment_01.as` | `MB-085-S010` `MB-085-S011` `MB-085-S012` `MB-085-S013` `MB-085-S014` `MB-085-S015` `MB-085-S018` | `Positive` | `World` |
| `TS-BIND-FVECTOR4-002` | `TestSource/Bindings/FVector4/Test_Operators_01.as` | `MB-085-S016` `MB-085-S017` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FVECTOR4-003` | `TestSource/Bindings/FVector4/Test_Behavior_01.as` | `MB-085-S001` `MB-085-S002` `MB-085-S003` `MB-085-S004` `MB-085-S005` `MB-085-S006` `MB-085-S007` `MB-085-S008` `MB-085-S009` | `Positive` | `World` |
| `TS-BIND-FVECTOR4F-001` | `TestSource/Bindings/FVector4f/Test_ConstructionAndAssignment_01.as` | `MB-086-S001` `MB-086-S011` `MB-086-S016` `MB-086-S020` | `Positive` | `World` |
| `TS-BIND-FVECTOR4F-002` | `TestSource/Bindings/FVector4f/Test_Operators_01.as` | `MB-086-S012` `MB-086-S013` `MB-086-S014` `MB-086-S015` `MB-086-S017` `MB-086-S018` `MB-086-S019` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FVECTOR4F-003` | `TestSource/Bindings/FVector4f/Test_MutationAndLifecycle_01.as` | `MB-086-S021` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR4F-004` | `TestSource/Bindings/FVector4f/Test_ConversionAndFormatting_01.as` | `MB-086-S022` | `Positive` | `Engine` |
| `TS-BIND-FVECTOR4F-005` | `TestSource/Bindings/FVector4f/Test_Behavior_01.as` | `MB-086-S002` `MB-086-S003` `MB-086-S004` `MB-086-S005` `MB-086-S006` `MB-086-S007` `MB-086-S008` `MB-086-S009` `MB-086-S010` | `Positive` | `World` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
