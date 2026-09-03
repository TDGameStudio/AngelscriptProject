/**
 * SetTimer single-shot and looping setup from BeginPlay. C++ verifies
 * bLoopingSetupComplete by path, so that UPROPERTY name is part of the contract
 * and is kept verbatim. The observers cover the empty defaults and direct
 * callback increments.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerBasicUsage
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerBasicUsage
 * @Provenance Theme: Gameplay.Timer. WorldStory SetTimer single-shot and looping setup.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerBasicUsage
 * @Provenance Oracle after BeginPlay: bLoopingSetupComplete true.
 * @Provenance Extra: counts 0 / bSingleShotExecuted false until callbacks. Do not spawn from script.
 */

UCLASS()
class ACoverageTimerBasicUsageActor : AActor
{
	UPROPERTY()
	int SingleShotCallCount = 0;

	UPROPERTY()
	int LoopingCallCount = 0;

	UPROPERTY()
	bool bSingleShotExecuted = false;

	UPROPERTY()
	bool bLoopingSetupComplete = false;

	FTimerHandle SingleShotHandle;
	FTimerHandle LoopingHandle;

	/**
	 * Count a single-shot timer callback and mark it executed.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerBasicUsage
	 * @Inputs none
	 * @Return SingleShotCallCount incremented and bSingleShotExecuted true
	 */
	UFUNCTION()
	void SingleShotCallback()
	{
		SingleShotCallCount++;
		bSingleShotExecuted = true;
		Print("SingleShotCallback executed, count: " + SingleShotCallCount);
	}

	/**
	 * Count a looping timer callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerBasicUsage
	 * @Inputs none
	 * @Return LoopingCallCount incremented once
	 */
	UFUNCTION()
	void LoopingCallback()
	{
		LoopingCallCount++;
		Print("LoopingCallback executed, count: " + LoopingCallCount);
	}

	/**
	 * WorldStory: BeginPlay sets a single-shot timer and a looping timer.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerBasicUsage
	 * @Inputs none
	 * @Return bLoopingSetupComplete true after the looping timer is set
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerBasicUsage: Setting up timers");

		// SetTimer single shot (non-looping)
		SingleShotHandle = System::SetTimer(this, n"SingleShotCallback", 0.1f, false);
		Print("Single shot timer set with 0.1s delay");

		// SetTimer looping
		LoopingHandle = System::SetTimer(this, n"LoopingCallback", 0.1f, true);
		bLoopingSetupComplete = true;
		Print("Looping timer set with 0.1s interval");
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerBasicUsage
	 * @Inputs none
	 * @Return true when counts are 0 and both flags are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (SingleShotCallCount != 0)
		{
			return false;
		}
		if (LoopingCallCount != 0)
		{
			return false;
		}
		if (bSingleShotExecuted != false)
		{
			return false;
		}
		return bLoopingSetupComplete == false;
	}

	/**
	 * Observe that calling both callbacks once records the expected counts.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerBasicUsage
	 * @Inputs none
	 * @Return true when the single-shot count is 1, the flag is true and the loop count is 1
	 */
	UFUNCTION()
	bool DirectCallbacks()
	{
		SingleShotCallback();
		LoopingCallback();
		if (SingleShotCallCount != 1)
		{
			return false;
		}
		if (bSingleShotExecuted != true)
		{
			return false;
		}
		return LoopingCallCount == 1;
	}
}
