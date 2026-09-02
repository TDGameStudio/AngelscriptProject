# Actors, components, World, and collision

World-backed lifecycle, actor/component identity, spawn/destroy/tick, collision query values, hit/overlap results, physics/component helpers, and LocalPlayer/GameInstance context.

## Accounting

- Logical units: 25
- Planned AS-facing surface rows: 428
- Planned `.as` files: 86
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-001` | `AActor` | 2 | 29 | 5 | `REF-0001` `REF-0002` `REF-0003` `REF-0004` `REF-0005` `REF-0006` `REF-0007` `REF-0008` `REF-0009` | `Editor` `World` `NetworkClient` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-002` | `APlayerController` | 2 | 21 | 3 | `REF-0010` `REF-0011` `REF-0012` `REF-0013` `REF-0014` `REF-0015` `REF-0016` `REF-0017` `REF-0018` | `World` `Engine` | `PlannedSource` |
| `MB-006` | `AVolume` | 1 | 4 | 3 | `REF-0028` `REF-0029` | `World` | `PlannedSource` |
| `MB-010` | `CollisionProfile` | 1 | 1 | 1 | `REF-0056` `REF-0057` `REF-0058` `REF-0059` `REF-0060` `REF-0061` `REF-0062` `REF-0063` | `World` | `PlannedSource` |
| `MB-017` | `FActorSpawnParameters` | 1 | 16 | 3 | `REF-0099` `REF-0100` `REF-0101` `REF-0102` `REF-0103` `REF-0104` `REF-0105` `REF-0106` `REF-0107` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-022` | `FBodyInstance` | 1 | 4 | 3 | `REF-0131` `REF-0132` `REF-0133` | `World` `Engine` | `PlannedSource` |
| `MB-028` | `FCollisionQueryParams` | 3 | 103 | 14 | `REF-0159` `REF-0160` `REF-0161` `REF-0162` `REF-0163` `REF-0164` `REF-0165` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-029` | `FCollisionShape` | 2 | 27 | 6 | `REF-0166` `REF-0167` `REF-0168` `REF-0169` `REF-0170` `REF-0171` | `World` | `PlannedSource` |
| `MB-040` | `FHitResult` | 1 | 27 | 4 | `REF-0239` `REF-0240` `REF-0241` `REF-0242` `REF-0243` `REF-0244` `REF-0245` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-049` | `FLatentActionInfo` | 1 | 5 | 1 | `REF-0295` `REF-0296` `REF-0297` `REF-0298` `REF-0299` | `Latent` | `PlannedSource` |
| `MB-058` | `FOverlapResult` | 1 | 7 | 3 | `REF-0344` `REF-0345` `REF-0346` `REF-0347` `REF-0348` `REF-0349` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-092` | `LandscapeProxy` | 1 | 1 | 1 | `REF-0547` `REF-0548` | `World` | `PlannedSource` |
| `MB-105` | `UActorComponent` | 1 | 25 | 3 | `REF-0637` `REF-0638` `REF-0639` `REF-0640` `REF-0641` `REF-0642` `REF-0643` `REF-0644` `REF-0645` | `Editor` `World` | `PlannedSource` |
| `MB-107` | `UCollisionProfile` | 1 | 3 | 1 | `REF-0648` `REF-0649` `REF-0650` `REF-0651` `REF-0652` `REF-0653` `REF-0654` `REF-0655` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-111` | `UFXSystemComponent` | 1 | 1 | 1 | `REF-0672` `REF-0673` `REF-0674` | `World` | `PlannedSource` |
| `MB-112` | `UGameInstance` | 1 | 11 | 3 | `REF-0675` `REF-0676` `REF-0677` `REF-0678` `REF-0679` | `World` `ExpectedDiagnostic` `NetworkClient` | `PlannedSource` |
| `MB-115` | `ULocalPlayer` | 1 | 2 | 1 | `REF-0688` `REF-0689` `REF-0690` `REF-0691` `REF-0692` | `World` | `PlannedSource` |
| `MB-118` | `UPoseableMeshComponent` | 1 | 2 | 1 | `REF-0707` `REF-0708` `REF-0709` | `World` | `PlannedSource` |
| `MB-119` | `UPrimitiveComponent` | 1 | 7 | 2 | `REF-0710` `REF-0711` `REF-0712` `REF-0713` `REF-0714` `REF-0715` `REF-0716` | `Editor` | `PlannedSource` |
| `MB-120` | `UProjectileMovementComponent` | 1 | 2 | 2 | `REF-0717` `REF-0718` `REF-0719` `REF-0720` `REF-0721` `REF-0722` | `World` | `PlannedSource` |
| `MB-121` | `USceneComponent` | 2 | 11 | 4 | `REF-0723` `REF-0724` `REF-0725` `REF-0726` `REF-0727` `REF-0728` `REF-0729` `REF-0730` `REF-0731` | `World` | `PlannedSource` |
| `MB-122` | `USkeletalMeshComponent` | 1 | 3 | 2 | `REF-0732` `REF-0733` `REF-0734` `REF-0735` `REF-0736` `REF-0737` `REF-0738` `REF-0739` `REF-0740` | `World` | `PlannedSource` |
| `MB-123` | `USkinnedMeshComponent` | 1 | 2 | 2 | `REF-0741` `REF-0742` `REF-0743` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-126` | `UWorld` | 1 | 40 | 7 | `REF-0759` `REF-0760` `REF-0761` | `NetworkClient` `World` | `PlannedSource` |
| `MB-127` | `WorldCollision` | 3 | 74 | 10 | `REF-0762` `REF-0763` `REF-0764` | `World` `ExpectedDiagnostic` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-AACTOR-001` | `TestSource/Bindings/AActor/Test_Queries_01.as` | `MB-001-S001` `MB-001-S002` `MB-001-S003` `MB-001-S004` `MB-001-S005` `MB-001-S008` `MB-001-S009` `MB-001-S010` `MB-001-S011` `MB-001-S012` | `Positive` | `Editor` |
| `TS-BIND-AACTOR-002` | `TestSource/Bindings/AActor/Test_Queries_02.as` | `MB-001-S013` `MB-001-S014` `MB-001-S018` `MB-001-S019` `MB-001-S020` | `Positive` | `World` |
| `TS-BIND-AACTOR-003` | `TestSource/Bindings/AActor/Test_MutationAndLifecycle_01.as` | `MB-001-S006` `MB-001-S007` `MB-001-S015` `MB-001-S016` `MB-001-S017` `MB-001-S021` `MB-001-S022` `MB-001-S023` `MB-001-S024` `MB-001-S027` | `Positive;NegativeDiagnostic` | `NetworkClient;ExpectedDiagnostic` |
| `TS-BIND-AACTOR-004` | `TestSource/Bindings/AActor/Test_MutationAndLifecycle_02.as` | `MB-001-S028` `MB-001-S029` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-AACTOR-005` | `TestSource/Bindings/AActor/Test_NamespaceAndGlobalFunctions_01.as` | `MB-001-S025` `MB-001-S026` | `Positive` | `World` |
| `TS-BIND-APLAYERCONTROLLER-001` | `TestSource/Bindings/APlayerController/Test_Queries_01.as` | `MB-002-S001` `MB-002-S002` `MB-002-S003` `MB-002-S004` `MB-002-S005` `MB-002-S006` `MB-002-S009` `MB-002-S010` `MB-002-S011` `MB-002-S013` | `Positive` | `World` |
| `TS-BIND-APLAYERCONTROLLER-002` | `TestSource/Bindings/APlayerController/Test_Queries_02.as` | `MB-002-S014` `MB-002-S015` `MB-002-S016` `MB-002-S017` `MB-002-S018` | `Positive` | `Engine` |
| `TS-BIND-APLAYERCONTROLLER-003` | `TestSource/Bindings/APlayerController/Test_MutationAndLifecycle_01.as` | `MB-002-S007` `MB-002-S008` `MB-002-S012` `MB-002-S019` `MB-002-S020` `MB-002-S021` | `Positive` | `World` |
| `TS-BIND-AVOLUME-001` | `TestSource/Bindings/AVolume/Test_Queries_01.as` | `MB-006-S001` | `Positive` | `World` |
| `TS-BIND-AVOLUME-002` | `TestSource/Bindings/AVolume/Test_MutationAndLifecycle_01.as` | `MB-006-S004` | `Positive` | `World` |
| `TS-BIND-AVOLUME-003` | `TestSource/Bindings/AVolume/Test_Behavior_01.as` | `MB-006-S002` `MB-006-S003` | `Positive` | `World` |
| `TS-BIND-COLLISIONPROFILE-001` | `TestSource/Bindings/CollisionProfile/Test_NamespaceAndGlobalFunctions_01.as` | `MB-010-S001` | `Positive` | `World` |
| `TS-BIND-FACTORSPAWNPARAMETERS-001` | `TestSource/Bindings/FActorSpawnParameters/Test_ConstructionAndAssignment_01.as` | `MB-017-S001` `MB-017-S004` `MB-017-S013` `MB-017-S014` `MB-017-S015` `MB-017-S016` | `Positive` | `World` |
| `TS-BIND-FACTORSPAWNPARAMETERS-002` | `TestSource/Bindings/FActorSpawnParameters/Test_Operators_01.as` | `MB-017-S012` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FACTORSPAWNPARAMETERS-003` | `TestSource/Bindings/FActorSpawnParameters/Test_Behavior_01.as` | `MB-017-S002` `MB-017-S003` `MB-017-S005` `MB-017-S006` `MB-017-S007` `MB-017-S008` `MB-017-S009` `MB-017-S010` `MB-017-S011` | `Positive` | `World` |
| `TS-BIND-FBODYINSTANCE-001` | `TestSource/Bindings/FBodyInstance/Test_Queries_01.as` | `MB-022-S001` | `Positive` | `World` |
| `TS-BIND-FBODYINSTANCE-002` | `TestSource/Bindings/FBodyInstance/Test_MutationAndLifecycle_01.as` | `MB-022-S004` | `Positive` | `World` |
| `TS-BIND-FBODYINSTANCE-003` | `TestSource/Bindings/FBodyInstance/Test_Behavior_01.as` | `MB-022-S002` `MB-022-S003` | `Positive` | `Engine` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-001` | `TestSource/Bindings/FCollisionQueryParams/Test_ConstructionAndAssignment_01.as` | `MB-028-S001` `MB-028-S005` `MB-028-S009` `MB-028-S010` `MB-028-S011` `MB-028-S012` `MB-028-S013` `MB-028-S016` `MB-028-S023` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-002` | `TestSource/Bindings/FCollisionQueryParams/Test_Operators_01.as` | `MB-028-S101` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-003` | `TestSource/Bindings/FCollisionQueryParams/Test_Queries_01.as` | `MB-028-S044` `MB-028-S045` `MB-028-S070` `MB-028-S071` `MB-028-S089` `MB-028-S091` `MB-028-S092` `MB-028-S094` `MB-028-S095` `MB-028-S100` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-004` | `TestSource/Bindings/FCollisionQueryParams/Test_Queries_02.as` | `MB-028-S102` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-005` | `TestSource/Bindings/FCollisionQueryParams/Test_MutationAndLifecycle_01.as` | `MB-028-S046` `MB-028-S047` `MB-028-S048` `MB-028-S049` `MB-028-S050` `MB-028-S051` `MB-028-S052` `MB-028-S053` `MB-028-S054` `MB-028-S055` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-006` | `TestSource/Bindings/FCollisionQueryParams/Test_MutationAndLifecycle_02.as` | `MB-028-S072` `MB-028-S073` `MB-028-S074` `MB-028-S075` `MB-028-S076` `MB-028-S077` `MB-028-S078` `MB-028-S079` `MB-028-S080` `MB-028-S081` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-007` | `TestSource/Bindings/FCollisionQueryParams/Test_MutationAndLifecycle_03.as` | `MB-028-S087` `MB-028-S088` `MB-028-S090` `MB-028-S097` `MB-028-S098` `MB-028-S103` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-008` | `TestSource/Bindings/FCollisionQueryParams/Test_ConversionAndFormatting_01.as` | `MB-028-S056` `MB-028-S082` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-009` | `TestSource/Bindings/FCollisionQueryParams/Test_NamespaceAndGlobalFunctions_01.as` | `MB-028-S002` `MB-028-S003` `MB-028-S004` `MB-028-S006` `MB-028-S007` `MB-028-S008` `MB-028-S017` `MB-028-S024` `MB-028-S028` `MB-028-S031` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-010` | `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_01.as` | `MB-028-S014` `MB-028-S015` `MB-028-S018` `MB-028-S019` `MB-028-S020` `MB-028-S021` `MB-028-S022` `MB-028-S025` `MB-028-S026` `MB-028-S027` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-011` | `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_02.as` | `MB-028-S029` `MB-028-S030` `MB-028-S032` `MB-028-S033` `MB-028-S034` `MB-028-S035` `MB-028-S036` `MB-028-S037` `MB-028-S038` `MB-028-S039` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-012` | `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_03.as` | `MB-028-S040` `MB-028-S041` `MB-028-S042` `MB-028-S043` `MB-028-S057` `MB-028-S058` `MB-028-S059` `MB-028-S060` `MB-028-S061` `MB-028-S062` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-013` | `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_04.as` | `MB-028-S063` `MB-028-S064` `MB-028-S065` `MB-028-S066` `MB-028-S067` `MB-028-S068` `MB-028-S069` `MB-028-S083` `MB-028-S084` `MB-028-S085` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONQUERYPARAMS-014` | `TestSource/Bindings/FCollisionQueryParams/Test_Behavior_05.as` | `MB-028-S086` `MB-028-S093` `MB-028-S096` `MB-028-S099` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONSHAPE-001` | `TestSource/Bindings/FCollisionShape/Test_ConstructionAndAssignment_01.as` | `MB-029-S001` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONSHAPE-002` | `TestSource/Bindings/FCollisionShape/Test_Queries_01.as` | `MB-029-S004` `MB-029-S005` `MB-029-S006` `MB-029-S007` `MB-029-S012` `MB-029-S013` `MB-029-S014` `MB-029-S015` `MB-029-S016` `MB-029-S017` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONSHAPE-003` | `TestSource/Bindings/FCollisionShape/Test_Queries_02.as` | `MB-029-S018` `MB-029-S019` `MB-029-S020` `MB-029-S021` `MB-029-S022` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONSHAPE-004` | `TestSource/Bindings/FCollisionShape/Test_MutationAndLifecycle_01.as` | `MB-029-S008` `MB-029-S009` `MB-029-S010` `MB-029-S011` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONSHAPE-005` | `TestSource/Bindings/FCollisionShape/Test_NamespaceAndGlobalFunctions_01.as` | `MB-029-S023` `MB-029-S024` `MB-029-S025` `MB-029-S026` `MB-029-S027` | `Positive` | `World` |
| `TS-BIND-FCOLLISIONSHAPE-006` | `TestSource/Bindings/FCollisionShape/Test_Behavior_01.as` | `MB-029-S002` `MB-029-S003` | `Positive` | `World` |
| `TS-BIND-FHITRESULT-001` | `TestSource/Bindings/FHitResult/Test_Queries_01.as` | `MB-040-S019` `MB-040-S021` `MB-040-S023` `MB-040-S026` | `Positive` | `World` |
| `TS-BIND-FHITRESULT-002` | `TestSource/Bindings/FHitResult/Test_MutationAndLifecycle_01.as` | `MB-040-S018` `MB-040-S020` `MB-040-S022` `MB-040-S024` `MB-040-S025` `MB-040-S027` | `Positive` | `World` |
| `TS-BIND-FHITRESULT-003` | `TestSource/Bindings/FHitResult/Test_Behavior_01.as` | `MB-040-S001` `MB-040-S002` `MB-040-S003` `MB-040-S004` `MB-040-S005` `MB-040-S006` `MB-040-S007` `MB-040-S008` `MB-040-S009` `MB-040-S010` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-FHITRESULT-004` | `TestSource/Bindings/FHitResult/Test_Behavior_02.as` | `MB-040-S011` `MB-040-S012` `MB-040-S013` `MB-040-S014` `MB-040-S015` `MB-040-S016` `MB-040-S017` | `Positive` | `World` |
| `TS-BIND-FLATENTACTIONINFO-001` | `TestSource/Bindings/FLatentActionInfo/Test_Behavior_01.as` | `MB-049-S001` `MB-049-S002` `MB-049-S003` `MB-049-S004` `MB-049-S005` | `Positive` | `Latent` |
| `TS-BIND-FOVERLAPRESULT-001` | `TestSource/Bindings/FOverlapResult/Test_Queries_01.as` | `MB-058-S003` `MB-058-S005` `MB-058-S006` | `Positive` | `World` |
| `TS-BIND-FOVERLAPRESULT-002` | `TestSource/Bindings/FOverlapResult/Test_MutationAndLifecycle_01.as` | `MB-058-S002` `MB-058-S004` `MB-058-S007` | `Positive` | `World` |
| `TS-BIND-FOVERLAPRESULT-003` | `TestSource/Bindings/FOverlapResult/Test_Behavior_01.as` | `MB-058-S001` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-LANDSCAPEPROXY-001` | `TestSource/Bindings/LandscapeProxy/Test_Queries_01.as` | `MB-092-S001` | `Positive` | `World` |
| `TS-BIND-UACTORCOMPONENT-001` | `TestSource/Bindings/UActorComponent/Test_Queries_01.as` | `MB-105-S002` `MB-105-S003` `MB-105-S010` `MB-105-S012` `MB-105-S013` `MB-105-S019` `MB-105-S020` `MB-105-S021` `MB-105-S023` `MB-105-S024` | `Positive` | `Editor` |
| `TS-BIND-UACTORCOMPONENT-002` | `TestSource/Bindings/UActorComponent/Test_MutationAndLifecycle_01.as` | `MB-105-S006` `MB-105-S008` `MB-105-S009` `MB-105-S011` `MB-105-S018` `MB-105-S025` | `Positive` | `Editor` |
| `TS-BIND-UACTORCOMPONENT-003` | `TestSource/Bindings/UActorComponent/Test_Behavior_01.as` | `MB-105-S001` `MB-105-S004` `MB-105-S005` `MB-105-S007` `MB-105-S014` `MB-105-S015` `MB-105-S016` `MB-105-S017` `MB-105-S022` | `Positive` | `World` |
| `TS-BIND-UCOLLISIONPROFILE-001` | `TestSource/Bindings/UCollisionProfile/Test_ConversionAndFormatting_01.as` | `MB-107-S001` `MB-107-S002` `MB-107-S003` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-UFXSYSTEMCOMPONENT-001` | `TestSource/Bindings/UFXSystemComponent/Test_Behavior_01.as` | `MB-111-S001` | `Positive` | `World` |
| `TS-BIND-UGAMEINSTANCE-001` | `TestSource/Bindings/UGameInstance/Test_IndexAndIteration_01.as` | `MB-112-S007` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-UGAMEINSTANCE-002` | `TestSource/Bindings/UGameInstance/Test_Queries_01.as` | `MB-112-S006` `MB-112-S008` `MB-112-S009` `MB-112-S010` `MB-112-S011` | `Positive;NegativeDiagnostic` | `NetworkClient;ExpectedDiagnostic` |
| `TS-BIND-UGAMEINSTANCE-003` | `TestSource/Bindings/UGameInstance/Test_MutationAndLifecycle_01.as` | `MB-112-S001` `MB-112-S002` `MB-112-S003` `MB-112-S004` `MB-112-S005` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-ULOCALPLAYER-001` | `TestSource/Bindings/ULocalPlayer/Test_Queries_01.as` | `MB-115-S001` `MB-115-S002` | `Positive` | `World` |
| `TS-BIND-UPOSEABLEMESHCOMPONENT-001` | `TestSource/Bindings/UPoseableMeshComponent/Test_Behavior_01.as` | `MB-118-S001` `MB-118-S002` | `Positive` | `World` |
| `TS-BIND-UPRIMITIVECOMPONENT-001` | `TestSource/Bindings/UPrimitiveComponent/Test_Queries_01.as` | `MB-119-S001` `MB-119-S002` `MB-119-S003` `MB-119-S004` `MB-119-S005` | `Positive` | `Editor` |
| `TS-BIND-UPRIMITIVECOMPONENT-002` | `TestSource/Bindings/UPrimitiveComponent/Test_MutationAndLifecycle_01.as` | `MB-119-S006` `MB-119-S007` | `Positive` | `Editor` |
| `TS-BIND-UPROJECTILEMOVEMENTCOMPONENT-001` | `TestSource/Bindings/UProjectileMovementComponent/Test_Queries_01.as` | `MB-120-S001` | `Positive` | `World` |
| `TS-BIND-UPROJECTILEMOVEMENTCOMPONENT-002` | `TestSource/Bindings/UProjectileMovementComponent/Test_MutationAndLifecycle_01.as` | `MB-120-S002` | `Positive` | `World` |
| `TS-BIND-USCENECOMPONENT-001` | `TestSource/Bindings/USceneComponent/Test_ConstructionAndAssignment_01.as` | `MB-121-S010` | `Positive` | `World` |
| `TS-BIND-USCENECOMPONENT-002` | `TestSource/Bindings/USceneComponent/Test_Queries_01.as` | `MB-121-S001` `MB-121-S002` `MB-121-S003` `MB-121-S004` `MB-121-S008` | `Positive` | `World` |
| `TS-BIND-USCENECOMPONENT-003` | `TestSource/Bindings/USceneComponent/Test_MutationAndLifecycle_01.as` | `MB-121-S005` `MB-121-S006` `MB-121-S007` `MB-121-S009` | `Positive` | `World` |
| `TS-BIND-USCENECOMPONENT-004` | `TestSource/Bindings/USceneComponent/Test_Behavior_01.as` | `MB-121-S011` | `Positive` | `World` |
| `TS-BIND-USKELETALMESHCOMPONENT-001` | `TestSource/Bindings/USkeletalMeshComponent/Test_Queries_01.as` | `MB-122-S001` `MB-122-S003` | `Positive` | `World` |
| `TS-BIND-USKELETALMESHCOMPONENT-002` | `TestSource/Bindings/USkeletalMeshComponent/Test_MutationAndLifecycle_01.as` | `MB-122-S002` | `Positive` | `World` |
| `TS-BIND-USKINNEDMESHCOMPONENT-001` | `TestSource/Bindings/USkinnedMeshComponent/Test_MutationAndLifecycle_01.as` | `MB-123-S001` | `Positive` | `World` |
| `TS-BIND-USKINNEDMESHCOMPONENT-002` | `TestSource/Bindings/USkinnedMeshComponent/Test_Behavior_01.as` | `MB-123-S002` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-UWORLD-001` | `TestSource/Bindings/UWorld/Test_ConstructionAndAssignment_01.as` | `MB-126-S001` `MB-126-S010` | `Positive` | `NetworkClient` |
| `TS-BIND-UWORLD-002` | `TestSource/Bindings/UWorld/Test_Queries_01.as` | `MB-126-S017` `MB-126-S018` `MB-126-S019` `MB-126-S020` `MB-126-S022` `MB-126-S023` `MB-126-S024` `MB-126-S025` `MB-126-S026` `MB-126-S027` | `Positive` | `NetworkClient` |
| `TS-BIND-UWORLD-003` | `TestSource/Bindings/UWorld/Test_Queries_02.as` | `MB-126-S028` `MB-126-S029` `MB-126-S030` `MB-126-S032` `MB-126-S033` `MB-126-S034` `MB-126-S037` `MB-126-S038` `MB-126-S039` `MB-126-S040` | `Positive` | `World` |
| `TS-BIND-UWORLD-004` | `TestSource/Bindings/UWorld/Test_MutationAndLifecycle_01.as` | `MB-126-S031` | `Positive` | `World` |
| `TS-BIND-UWORLD-005` | `TestSource/Bindings/UWorld/Test_NamespaceAndGlobalFunctions_01.as` | `MB-126-S002` `MB-126-S003` `MB-126-S004` `MB-126-S005` `MB-126-S006` `MB-126-S007` `MB-126-S008` `MB-126-S009` `MB-126-S011` `MB-126-S012` | `Positive` | `NetworkClient` |
| `TS-BIND-UWORLD-006` | `TestSource/Bindings/UWorld/Test_NamespaceAndGlobalFunctions_02.as` | `MB-126-S013` `MB-126-S014` `MB-126-S015` | `Positive` | `NetworkClient` |
| `TS-BIND-UWORLD-007` | `TestSource/Bindings/UWorld/Test_Behavior_01.as` | `MB-126-S016` `MB-126-S021` `MB-126-S035` `MB-126-S036` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-001` | `TestSource/Bindings/WorldCollision/Test_ConstructionAndAssignment_01.as` | `MB-127-S001` `MB-127-S005` `MB-127-S013` `MB-127-S022` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-002` | `TestSource/Bindings/WorldCollision/Test_Operators_01.as` | `MB-127-S008` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-003` | `TestSource/Bindings/WorldCollision/Test_Queries_01.as` | `MB-127-S009` `MB-127-S072` `MB-127-S073` `MB-127-S074` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-004` | `TestSource/Bindings/WorldCollision/Test_ConversionAndFormatting_01.as` | `MB-127-S063` `MB-127-S064` `MB-127-S065` `MB-127-S066` `MB-127-S067` `MB-127-S068` `MB-127-S069` `MB-127-S070` `MB-127-S071` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-005` | `TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_01.as` | `MB-127-S002` `MB-127-S003` `MB-127-S004` `MB-127-S029` `MB-127-S030` `MB-127-S031` `MB-127-S032` `MB-127-S033` `MB-127-S034` `MB-127-S035` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-006` | `TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_02.as` | `MB-127-S036` `MB-127-S037` `MB-127-S038` `MB-127-S039` `MB-127-S040` `MB-127-S041` `MB-127-S042` `MB-127-S043` `MB-127-S044` `MB-127-S045` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-007` | `TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_03.as` | `MB-127-S046` `MB-127-S047` `MB-127-S048` `MB-127-S049` `MB-127-S050` `MB-127-S051` `MB-127-S052` `MB-127-S053` `MB-127-S054` `MB-127-S055` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-008` | `TestSource/Bindings/WorldCollision/Test_NamespaceAndGlobalFunctions_04.as` | `MB-127-S056` `MB-127-S057` `MB-127-S058` `MB-127-S059` `MB-127-S060` `MB-127-S061` `MB-127-S062` | `Positive` | `World` |
| `TS-BIND-WORLDCOLLISION-009` | `TestSource/Bindings/WorldCollision/Test_Behavior_01.as` | `MB-127-S006` `MB-127-S007` `MB-127-S010` `MB-127-S011` `MB-127-S012` `MB-127-S014` `MB-127-S015` `MB-127-S016` `MB-127-S017` `MB-127-S018` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-WORLDCOLLISION-010` | `TestSource/Bindings/WorldCollision/Test_Behavior_02.as` | `MB-127-S019` `MB-127-S020` `MB-127-S021` `MB-127-S023` `MB-127-S024` `MB-127-S025` `MB-127-S026` `MB-127-S027` `MB-127-S028` | `Positive` | `World` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
