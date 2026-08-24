// Theme: Gameplay.Timer. WorldStory three independent looping timers.
// C++: AngelscriptCoverageTimerTests.cpp::MultipleTimers
// Oracle after BeginPlay: bAllTimersActive true, ActiveTimerCount 3.
// Extra: counts 0 / flags false until BeginPlay. Do not spawn from script.

UCLASS()
class ACoverageTimerMultipleTimersActor : AActor
{
	UPROPERTY()
	int FastTimerCallCount = 0;

	UPROPERTY()
	int MediumTimerCallCount = 0;

	UPROPERTY()
	int SlowTimerCallCount = 0;

	UPROPERTY()
	bool bAllTimersActive = false;

	UPROPERTY()
	int ActiveTimerCount = 0;

	FTimerHandle FastHandle;
	FTimerHandle MediumHandle;
	FTimerHandle SlowHandle;

	UFUNCTION()
	void FastTimerCallback()
	{
		FastTimerCallCount++;
		Print("FastTimer tick, count: " + FastTimerCallCount);
	}

	UFUNCTION()
	void MediumTimerCallback()
	{
		MediumTimerCallCount++;
		Print("MediumTimer tick, count: " + MediumTimerCallCount);
	}

	UFUNCTION()
	void SlowTimerCallback()
	{
		SlowTimerCallCount++;
		Print("SlowTimer tick, count: " + SlowTimerCallCount);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("MultipleTimers: Running multiple independent timers");

		// Fast timer: 0.1s interval
		FastHandle = System::SetTimer(this, n"FastTimerCallback", 0.1f, true);
		Print("Fast timer (0.1s) started");

		// Medium timer: 0.25s interval
		MediumHandle = System::SetTimer(this, n"MediumTimerCallback", 0.25f, true);
		Print("Medium timer (0.25s) started");

		// Slow timer: 0.5s interval
		SlowHandle = System::SetTimer(this, n"SlowTimerCallback", 0.5f, true);
		Print("Slow timer (0.5s) started");

		// Verify all timers are active
		int Count = 0;
		if (SystemLibrary::IsTimerActiveHandle(FastHandle))
		{
			Count++;
		}
		if (SystemLibrary::IsTimerActiveHandle(MediumHandle))
		{
			Count++;
		}
		if (SystemLibrary::IsTimerActiveHandle(SlowHandle))
		{
			Count++;
		}

		ActiveTimerCount = Count;
		bAllTimersActive = (Count == 3);
		Print("Active timer count: " + Count);
	}
}

bool Observe_MultipleTimers_DefaultEmpty(ACoverageTimerMultipleTimersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultipleTimers setup: required Actor is null");
	}
	return Actor.FastTimerCallCount == 0
		&& Actor.MediumTimerCallCount == 0
		&& Actor.SlowTimerCallCount == 0
		&& Actor.bAllTimersActive == false
		&& Actor.ActiveTimerCount == 0;
}

bool Observe_MultipleTimers_DirectCallbacks(ACoverageTimerMultipleTimersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultipleTimers setup: required Actor is null");
	}
	Actor.FastTimerCallback();
	Actor.MediumTimerCallback();
	Actor.SlowTimerCallback();
	return Actor.FastTimerCallCount == 1
		&& Actor.MediumTimerCallCount == 1
		&& Actor.SlowTimerCallCount == 1;
}
