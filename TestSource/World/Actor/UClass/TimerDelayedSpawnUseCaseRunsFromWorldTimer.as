/**
 * A delayed world timer that spawns an actor when it fires. C++ verifies the timer
 * went active, that nothing had spawned yet immediately after setup, and that the
 * remaining time fell inside the requested delay.
 *
 * @Theme World.Actor
 * @Subject Actor.TimerDelayedSpawnUseCase
 * @Harness UClass
 * @Tag World.Actor.TimerDelayedSpawnUseCaseRunsFromWorldTimer
 * @Provenance Theme: World.Actor. WorldStory: delayed world timer spawns an actor.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerDelayedSpawnUseCaseRunsFromWorldTimer
 * @Provenance Oracle: after BeginPlay, bSpawnTimerActiveAfterSetup true, bSpawnedAfterDelay false,
 * @Provenance bSpawnRemainingWithinDelay true. Spawn is the oracle of SpawnDelayedActor.
 * @Provenance Extra: SpawnedActor null, SpawnCount 0, spawned flags false until the timer fires.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * Spawn an actor, record the attempt, and mark that the delayed callback ran.
	 *
	 * @Kind Action
	 * @Covers Actor.TimerDelayedSpawnUseCase
	 * @Inputs none
	 * @Return SpawnCount incremented, bSpawnedAfterDelay set, bSpawnedActorValid set from the spawn
	 */
	UFUNCTION()
	void SpawnDelayedActor()
	{
		SpawnedActor = SpawnActor(AActor::StaticClass());
		SpawnCount++;
		bSpawnedAfterDelay = true;
		bSpawnedActorValid = (SpawnedActor != nullptr);
	}

	/**
	 * WorldStory: BeginPlay arms the delayed spawn timer, then records that it went
	 * active and how much time was left on it.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.TimerDelayedSpawnUseCase
	 * @Inputs none
	 * @Return bSpawnTimerActiveAfterSetup true, bSpawnedAfterDelay false, bSpawnRemainingWithinDelay true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SpawnHandle = System::SetTimer(this, n"SpawnDelayedActor", 0.2f, false);
		bSpawnTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(SpawnHandle);
		SpawnRemainingAfterSetup = SystemLibrary::GetTimerRemainingTimeHandle(SpawnHandle);
		bSpawnRemainingWithinDelay = SpawnRemainingAfterSetup > 0.0f && SpawnRemainingAfterSetup <= 0.25f;
	}

	/**
	 * Observe that a locally constructed actor has spawned nothing and armed no timer.
	 *
	 * @Kind Observe
	 * @Covers Actor.TimerDelayedSpawnUseCase
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, the count is 0, the remaining time is 0 and
	 * the spawned handle is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (SpawnedActor != nullptr)
		{
			return false;
		}
		if (bSpawnTimerActiveAfterSetup)
		{
			return false;
		}
		if (bSpawnedAfterDelay)
		{
			return false;
		}
		if (bSpawnedActorValid)
		{
			return false;
		}
		if (SpawnCount != 0)
		{
			return false;
		}
		if (SpawnRemainingAfterSetup != 0.0f)
		{
			return false;
		}
		return !bSpawnRemainingWithinDelay;
	}
}
