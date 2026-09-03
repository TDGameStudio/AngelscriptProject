/**
 * Delayed single-shot and repeating timers started from BeginPlay. C++ verifies
 * the three setup flags by path, so those UPROPERTY names are part of the
 * contract and are kept verbatim. The observers cover the empty defaults and
 * direct callback increments.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerDelayExecution
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerDelayExecution
 * @Provenance Theme: Gameplay.Timer. WorldStory delayed single-shot and repeating timers.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerDelayExecution
 * @Provenance Oracle after BeginPlay: bShortDelaySetup true, bLongDelaySetup true, bRepeatingDelaySetup true.
 * @Provenance Extra: setup flags false and counts 0 until BeginPlay. Do not spawn from script.
 */

UCLASS()
class ACoverageTimerDelayExecutionActor : AActor
{
	UPROPERTY()
	bool bShortDelaySetup = false;

	UPROPERTY()
	bool bLongDelaySetup = false;

	UPROPERTY()
	bool bRepeatingDelaySetup = false;

	UPROPERTY()
	int ShortDelayCallCount = 0;

	UPROPERTY()
	int RepeatingCallCount = 0;

	FTimerHandle ShortDelayHandle;
	FTimerHandle LongDelayHandle;
	FTimerHandle RepeatingHandle;

	/**
	 * Count a short-delay single-shot callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerDelayExecution
	 * @Inputs none
	 * @Return ShortDelayCallCount incremented once
	 */
	UFUNCTION()
	void ShortDelayCallback()
	{
		ShortDelayCallCount++;
		Print("ShortDelayCallback executed after 0.5s delay");
	}

	/**
	 * Print when the long-delay single-shot callback runs.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerDelayExecution
	 * @Inputs none
	 * @Return a print only; the setup flag is what the test observes
	 */
	UFUNCTION()
	void LongDelayCallback()
	{
		Print("LongDelayCallback executed after 1.0s delay");
	}

	/**
	 * Count a repeating delayed callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerDelayExecution
	 * @Inputs none
	 * @Return RepeatingCallCount incremented once
	 */
	UFUNCTION()
	void RepeatingCallback()
	{
		RepeatingCallCount++;
		Print("RepeatingCallback executed, count: " + RepeatingCallCount);
	}

	/**
	 * WorldStory: BeginPlay sets a short delay, a long delay and a repeating timer.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerDelayExecution
	 * @Inputs none
	 * @Return all three setup flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerDelayExecution: Testing delayed execution patterns");

		// Delay 0.5 seconds, execute once
		ShortDelayHandle = System::SetTimer(this, n"ShortDelayCallback", 0.5f, false);
		bShortDelaySetup = true;
		Print("Short delay timer (0.5s) set for single execution");

		// Delay 1.0 second, execute once
		LongDelayHandle = System::SetTimer(this, n"LongDelayCallback", 1.0f, false);
		bLongDelaySetup = true;
		Print("Long delay timer (1.0s) set for single execution");

		// Delay 0.3 seconds, then repeat every 0.3 seconds
		RepeatingHandle = System::SetTimer(this, n"RepeatingCallback", 0.3f, true);
		bRepeatingDelaySetup = true;
		Print("Repeating timer (0.3s interval) set up");
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerDelayExecution
	 * @Inputs none
	 * @Return true when setup flags are false and counts are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bShortDelaySetup != false)
		{
			return false;
		}
		if (bLongDelaySetup != false)
		{
			return false;
		}
		if (bRepeatingDelaySetup != false)
		{
			return false;
		}
		if (ShortDelayCallCount != 0)
		{
			return false;
		}
		return RepeatingCallCount == 0;
	}

	/**
	 * Observe that calling the short and repeating callbacks once increments each count.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerDelayExecution
	 * @Inputs none
	 * @Return true when both counts are 1
	 */
	UFUNCTION()
	bool DirectCallbacks()
	{
		ShortDelayCallback();
		RepeatingCallback();
		if (ShortDelayCallCount != 1)
		{
			return false;
		}
		return RepeatingCallCount == 1;
	}
}
