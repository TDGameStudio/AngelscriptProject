/**
 * @version v1
 * @summary Three independent looping timers started from BeginPlay. C++ verifies bAllTimersActive and ActiveTimerCount by path after setup, so those UPROPERTY names are part of the contract and are kept verbatim. The observers.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Three independent looping timers started from BeginPlay. C++ verifies bAllTimersActive and ActiveTimerCount by path after setup, so those UPROPERTY names are part of the contract and are kept verbatim. The observers.
 * @topic Baseline
 */
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

	/**
	 * Count a fast looping timer tick.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.MultipleTimers
	 * @Inputs none
	 * @Return FastTimerCallCount incremented once
	 */
	UFUNCTION()
	void FastTimerCallback()
	{
		FastTimerCallCount++;
		Print("FastTimer tick, count: " + FastTimerCallCount);
	}

	/**
	 * Count a medium looping timer tick.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.MultipleTimers
	 * @Inputs none
	 * @Return MediumTimerCallCount incremented once
	 */
	UFUNCTION()
	void MediumTimerCallback()
	{
		MediumTimerCallCount++;
		Print("MediumTimer tick, count: " + MediumTimerCallCount);
	}

	/**
	 * Count a slow looping timer tick.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.MultipleTimers
	 * @Inputs none
	 * @Return SlowTimerCallCount incremented once
	 */
	UFUNCTION()
	void SlowTimerCallback()
	{
		SlowTimerCallCount++;
		Print("SlowTimer tick, count: " + SlowTimerCallCount);
	}

	/**
	 * WorldStory: BeginPlay starts three independent looping timers and records
	 * how many are active.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.MultipleTimers
	 * @Inputs none
	 * @Return ActiveTimerCount 3 and bAllTimersActive true when every handle is active
	 */
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

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.MultipleTimers
	 * @Inputs none
	 * @Return true when counts are 0, ActiveTimerCount is 0 and bAllTimersActive is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FastTimerCallCount != 0)
		{
			return false;
		}
		if (MediumTimerCallCount != 0)
		{
			return false;
		}
		if (SlowTimerCallCount != 0)
		{
			return false;
		}
		if (bAllTimersActive != false)
		{
			return false;
		}
		return ActiveTimerCount == 0;
	}

	/**
	 * Observe that calling each callback once increments every count.
	 *
	 * @Kind Observe
	 * @Covers Timer.MultipleTimers
	 * @Inputs none
	 * @Return true when every callback count is 1
	 */
	UFUNCTION()
	bool DirectCallbacks()
	{
		FastTimerCallback();
		MediumTimerCallback();
		SlowTimerCallback();
		if (FastTimerCallCount != 1)
		{
			return false;
		}
		if (MediumTimerCallCount != 1)
		{
			return false;
		}
		return SlowTimerCallCount == 1;
	}
}
/** @end */
