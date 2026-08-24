// Theme: World.Actor. WorldStory: delayed world timer spawns an actor.
// C++: AngelscriptCoverageTimerTests.cpp::TimerDelayedSpawnUseCaseRunsFromWorldTimer
// Oracle: after BeginPlay, bSpawnTimerActiveAfterSetup true, bSpawnedAfterDelay false,
// bSpawnRemainingWithinDelay true. Spawn is the oracle of SpawnDelayedActor.
// Extra: SpawnedActor null, SpawnCount 0, spawned flags false until the timer fires.
// FixtureIsolated.

UCLASS()
class ACoverageTimerDelayedSpawnActor : AActor
{
	UPROPERTY()
	AActor SpawnedActor;

	UPROPERTY()
	bool bSpawnTimerActiveAfterSetup = false;

	UPROPERTY()
	bool bSpawnedAfterDelay = false;

	UPROPERTY()
	bool bSpawnedActorValid = false;

	UPROPERTY()
	int SpawnCount = 0;

	UPROPERTY()
	float SpawnRemainingAfterSetup = 0.0f;

	UPROPERTY()
	bool bSpawnRemainingWithinDelay = false;

	FTimerHandle SpawnHandle;

	UFUNCTION()
	void SpawnDelayedActor()
	{
		SpawnedActor = SpawnActor(AActor::StaticClass());
		SpawnCount++;
		bSpawnedAfterDelay = true;
		bSpawnedActorValid = (SpawnedActor != nullptr);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SpawnHandle = System::SetTimer(this, n"SpawnDelayedActor", 0.2f, false);
		bSpawnTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(SpawnHandle);
		SpawnRemainingAfterSetup = SystemLibrary::GetTimerRemainingTimeHandle(SpawnHandle);
		bSpawnRemainingWithinDelay = SpawnRemainingAfterSetup > 0.0f && SpawnRemainingAfterSetup <= 0.25f;
	}
}
