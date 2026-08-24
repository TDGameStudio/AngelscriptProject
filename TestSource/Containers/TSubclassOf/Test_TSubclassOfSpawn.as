// Theme: Containers.TSubclassOf. WorldStory: SpawnActor from TSubclassOf<AActor>/APawn.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::TSubclassOfSpawn
// CompileScriptModule + spawn + BeginPlay. Oracle: ActorSpawnWorked and PawnSpawnWorked true.
// Extra: local construct leaves flags false and spawned refs null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSubclassOfSpawnActor : AActor
{
	UPROPERTY()
	TSubclassOf<AActor> ActorClassToSpawn;

	UPROPERTY()
	TSubclassOf<APawn> PawnClassToSpawn;

	UPROPERTY()
	bool ActorSpawnWorked = false;

	UPROPERTY()
	bool PawnSpawnWorked = false;

	UPROPERTY()
	AActor SpawnedActorRef;

	UPROPERTY()
	APawn SpawnedPawnRef;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set class references
		ActorClassToSpawn = AActor::StaticClass();
		PawnClassToSpawn = APawn::StaticClass();

		// Spawn using TSubclassOf
		if (ActorClassToSpawn != nullptr)
		{
			SpawnedActorRef = SpawnActor(ActorClassToSpawn);
			if (SpawnedActorRef != nullptr)
			{
				ActorSpawnWorked = true;
			}
		}

		if (PawnClassToSpawn != nullptr)
		{
			SpawnedPawnRef = Cast<APawn>(SpawnActor(PawnClassToSpawn));
			if (SpawnedPawnRef != nullptr)
			{
				PawnSpawnWorked = true;
			}
		}
	}
}

bool Observe_SubclassOfSpawn_DefaultEmpty(ACoverageSubclassOfSpawnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfSpawn setup: required Actor is null");
	}
	return Actor.ActorSpawnWorked == false
		&& Actor.PawnSpawnWorked == false
		&& Actor.SpawnedActorRef == nullptr
		&& Actor.SpawnedPawnRef == nullptr
		&& Actor.ActorClassToSpawn == nullptr
		&& Actor.PawnClassToSpawn == nullptr;
}

bool Observe_SubclassOfSpawn_CopyIndependence(ACoverageSubclassOfSpawnActor First, ACoverageSubclassOfSpawnActor Second)
{
	if (First is null)
	{
		throw("Test_TSubclassOfSpawn setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSubclassOfSpawn setup: required Second is null");
	}
	First.ActorClassToSpawn = AActor::StaticClass();
	return First.ActorClassToSpawn != nullptr && Second.ActorClassToSpawn == nullptr;
}
