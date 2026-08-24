// Theme: World.Actor. WorldStory: positional, named, deferred, and TSubclassOf SpawnActor.
// C++: AngelscriptActorSpawnPatternsTests.cpp::MultipleSpawnSyntaxesProduceValidActors
// Oracle: VerifyByPath each *SpawnedCount == 1. Spawn is the oracle.
// Extra: TargetTag 0; counts stay 0 if a spawn returns null. FixtureIsolated.

UCLASS()
class AFunctionalSpawnTargetActor : AActor
{
	UPROPERTY()
	int32 TargetTag = 0;
}

UCLASS()
class AFunctionalSpawnSourceActor : AActor
{
	UPROPERTY()
	int32 PositionalSpawnedCount = 0;

	UPROPERTY()
	int32 NamedSpawnedCount = 0;

	UPROPERTY()
	int32 DeferredSpawnedCount = 0;

	UPROPERTY()
	int32 CastSpawnedCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AFunctionalSpawnTargetActor PositionalSpawn = Cast<AFunctionalSpawnTargetActor>(SpawnActor(
			AFunctionalSpawnTargetActor::StaticClass(),
			FVector(100.0, 0.0, 0.0),
			FRotator::ZeroRotator));
		if (PositionalSpawn != nullptr)
		{
			PositionalSpawnedCount += 1;
		}

		AFunctionalSpawnTargetActor NamedSpawn = Cast<AFunctionalSpawnTargetActor>(SpawnActor(
			AFunctionalSpawnTargetActor::StaticClass(),
			Location = FVector(0.0, 100.0, 0.0),
			Rotation = FRotator::ZeroRotator));
		if (NamedSpawn != nullptr)
		{
			NamedSpawnedCount += 1;
		}

		AActor DeferredSpawn = SpawnActor(
			AFunctionalSpawnTargetActor::StaticClass(),
			Location = FVector(0.0, 0.0, 100.0),
			Rotation = FRotator::ZeroRotator,
			bDeferredSpawn = true);
		if (DeferredSpawn != nullptr)
		{
			AFunctionalSpawnTargetActor TypedDeferred = Cast<AFunctionalSpawnTargetActor>(DeferredSpawn);
			if (TypedDeferred != nullptr)
			{
				TypedDeferred.TargetTag = 99;
			}
			FinishSpawningActor(DeferredSpawn);
			DeferredSpawnedCount += 1;
		}

		TSubclassOf<AFunctionalSpawnTargetActor> TargetSubclass = AFunctionalSpawnTargetActor::StaticClass();
		AFunctionalSpawnTargetActor TypedSpawn = Cast<AFunctionalSpawnTargetActor>(SpawnActor(TargetSubclass));
		if (TypedSpawn != nullptr)
		{
			CastSpawnedCount += 1;
		}
	}
}
