// Theme: World.Actor. WorldStory: BeginPlay EventCallCount on every spawned instance.
// C++: AngelscriptActorInteractionTests.cpp::MultiSpawn
// Oracle: C++ spawns three instances; each EventCallCount becomes 1 (total >= 3).
// Extra: EventCallCount stays 0 until BeginPlay. Spawn is the C++ fixture oracle,
// not a script SpawnActor. FixtureIsolated.

UCLASS()
class ATestActorMultiSpawn : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}
}
