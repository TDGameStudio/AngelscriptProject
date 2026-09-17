/**
 * @version v1
 * @summary Positional, named-argument, deferred and TSubclassOf SpawnActor calls, each counted separately. C++ verifies all four counts by path. The deferred spawn also writes a tag onto the actor before finishing it.
 * @topic World
 */
/**
 * @version root
 * @summary Positional, named-argument, deferred and TSubclassOf SpawnActor calls, each counted separately. C++ verifies all four counts by path. The deferred spawn also writes a tag onto the actor before finishing it.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay spawns one target through each of the four supported
	 * syntaxes and counts the ones that resolved.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.MultipleSpawnSyntaxesProduceValidActors
	 * @Inputs none
	 * @Return all four counts == 1
	 */
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

	/**
	 * Observe that a locally constructed source has spawned nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.MultipleSpawnSyntaxesProduceValidActors
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four counts are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (PositionalSpawnedCount != 0)
		{
			return false;
		}
		if (NamedSpawnedCount != 0)
		{
			return false;
		}
		if (DeferredSpawnedCount != 0)
		{
			return false;
		}
		return CastSpawnedCount == 0;
	}
}
/** @end */
