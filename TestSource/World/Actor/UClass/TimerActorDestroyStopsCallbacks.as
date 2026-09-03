/**
 * A looping timer on an actor, whose callbacks must stop once the actor is
 * destroyed. C++ verifies the timer was active before the destroy and that the
 * callback count stayed at zero throughout.
 *
 * @Theme World.Actor
 * @Subject Actor.TimerActorDestroyStopsCallbacks
 * @Harness UClass
 * @Tag World.Actor.TimerActorDestroyStopsCallbacks
 * @Provenance Theme: World.Actor. WorldStory: looping timer on an actor stops after Destroy.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerActorDestroyStopsCallbacks
 * @Provenance Oracle: VerifyByPath bTimerActiveBeforeDestroy true after BeginPlay, CallbackCount 0
 * @Provenance before and after Actor->Destroy().
 * @Provenance Extra: CallbackCount 0 and bTimerActiveBeforeDestroy false until BeginPlay.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ACoverageTimerDestroyCleanupActor : AActor
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bTimerActiveBeforeDestroy = false;

	FTimerHandle DestroyCleanupHandle;

	/**
	 * Count each timer callback and print the running total.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.TimerActorDestroyStopsCallbacks
	 * @Inputs none
	 * @Return CallbackCount incremented once per callback
	 */
	UFUNCTION()
	void CleanupCallback()
	{
		CallbackCount++;
		Print("CleanupCallback executed, count: " + CallbackCount);
	}

	/**
	 * WorldStory: BeginPlay starts the looping timer and records that it went active.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.TimerActorDestroyStopsCallbacks
	 * @Inputs none
	 * @Return bTimerActiveBeforeDestroy true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DestroyCleanupHandle = System::SetTimer(this, n"CleanupCallback", 0.1f, true);
		bTimerActiveBeforeDestroy = SystemLibrary::IsTimerActiveHandle(DestroyCleanupHandle);
	}

	/**
	 * Observe that a locally constructed actor has no count and no timer state.
	 *
	 * @Kind Observe
	 * @Covers Actor.TimerActorDestroyStopsCallbacks
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the count is 0 and the flag is clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (CallbackCount != 0)
		{
			return false;
		}
		return !bTimerActiveBeforeDestroy;
	}
}
