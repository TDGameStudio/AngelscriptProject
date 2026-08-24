// Theme: World.Actor. WorldStory: looping timer on an actor stops after Destroy.
// C++: AngelscriptCoverageTimerTests.cpp::TimerActorDestroyStopsCallbacks
// Oracle: VerifyByPath bTimerActiveBeforeDestroy true after BeginPlay, CallbackCount 0
// before and after Actor->Destroy().
// Extra: CallbackCount 0 and bTimerActiveBeforeDestroy false until BeginPlay.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ACoverageTimerDestroyCleanupActor : AActor
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bTimerActiveBeforeDestroy = false;

	FTimerHandle DestroyCleanupHandle;

	UFUNCTION()
	void CleanupCallback()
	{
		CallbackCount++;
		Print("CleanupCallback executed, count: " + CallbackCount);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DestroyCleanupHandle = System::SetTimer(this, n"CleanupCallback", 0.1f, true);
		bTimerActiveBeforeDestroy = SystemLibrary::IsTimerActiveHandle(DestroyCleanupHandle);
	}
}
