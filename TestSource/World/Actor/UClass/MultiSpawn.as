/**
 * A BeginPlay override counted on every spawned instance. C++ spawns three
 * instances and verifies each count reaches 1. The spawn is the C++ fixture oracle
 * rather than a script-side SpawnActor.
 *
 * @Theme World.Actor
 * @Subject Actor.MultiSpawn
 * @Harness UClass
 * @Tag World.Actor.MultiSpawn
 * @Provenance Theme: World.Actor. WorldStory: BeginPlay EventCallCount on every spawned instance.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::MultiSpawn
 * @Provenance Oracle: C++ spawns three instances; each EventCallCount becomes 1 (total >= 3).
 * @Provenance Extra: EventCallCount stays 0 until BeginPlay. Spawn is the C++ fixture oracle,
 * @Provenance not a script SpawnActor. FixtureIsolated.
 */

UCLASS()
class ATestActorMultiSpawn : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	/**
	 * WorldStory: BeginPlay counts each dispatch on this instance.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.MultiSpawn
	 * @Inputs none
	 * @Return EventCallCount == 1 on every spawned instance
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed instance has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Actor.MultiSpawn
	 * @Inputs an instance that has not begun play
	 * @Return true when EventCallCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return EventCallCount == 0;
	}
}
