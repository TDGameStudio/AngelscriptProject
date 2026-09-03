/**
 * A function-name timer walked through set, pause, unpause and clear, with the
 * paused state recorded after each transition. The CSV NegativeDiagnostic label
 * is a heuristic: C++ compiles this and VerifyByPath the pause flags, so this is
 * a lifecycle oracle rather than a compile failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.EventTimer
 * @Harness UClass
 * @Tag Gameplay.Timer.EventTimer
 * @Provenance Theme: Gameplay.Timer. C++ compiles and VerifyByPath timer pause flags.
 * @Provenance CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventTimer
 * @Provenance Oracle after BeginPlay: bSingleShotNotPausedAfterSet true, bLoopNotPausedAfterSet true,
 * @Provenance bLoopPausedAfterPause true, bLoopNotPausedAfterUnPause true, bLoopNotPausedAfterClear true.
 * @Provenance ClearSingleShotTimer then bSingleShotNotPausedAfterClear true.
 * @Provenance Extra: defaults 0/false; HandleTimer without loops. Do not spawn from script.
 */

UCLASS()
class ACoverageEventTimerActor : AActor
{
	UPROPERTY()
	int TimerCount = 0;

	UPROPERTY()
	int LoopTimerCount = 0;

	UPROPERTY()
	bool bSingleShotNotPausedAfterSet = false;

	UPROPERTY()
	bool bLoopNotPausedAfterSet = false;

	UPROPERTY()
	bool bLoopPausedAfterPause = false;

	UPROPERTY()
	bool bLoopNotPausedAfterUnPause = false;

	UPROPERTY()
	bool bLoopNotPausedAfterClear = false;

	UPROPERTY()
	bool bSingleShotNotPausedAfterClear = false;

	FTimerHandle TimerHandle;
	FTimerHandle LoopTimerHandle;

	/**
	 * WorldStory: BeginPlay sets a single-shot and a looping timer, then records
	 * the paused state after pause, unpause and clear.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return pause flags recorded after set, pause, unpause and clear
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TimerHandle = System::SetTimer(this, n"HandleTimer", 30.0f, false);
		bSingleShotNotPausedAfterSet = !System::IsTimerPausedHandle(TimerHandle);

		LoopTimerHandle = System::SetTimer(this, n"HandleLoopTimer", 30.0f, true);
		bLoopNotPausedAfterSet = !System::IsTimerPausedHandle(LoopTimerHandle);

		System::PauseTimerHandle(LoopTimerHandle);
		bLoopPausedAfterPause = System::IsTimerPausedHandle(LoopTimerHandle);

		System::UnPauseTimerHandle(LoopTimerHandle);
		bLoopNotPausedAfterUnPause = !System::IsTimerPausedHandle(LoopTimerHandle);

		System::ClearAndInvalidateTimerHandle(LoopTimerHandle);
		bLoopNotPausedAfterClear = !System::IsTimerPausedHandle(LoopTimerHandle);
	}

	/**
	 * Count a single-shot callback and clear the loop handle after three loops.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return TimerCount incremented; loop handle cleared when LoopTimerCount is at least 3
	 */
	UFUNCTION()
	void HandleTimer()
	{
		TimerCount++;
		if (LoopTimerCount >= 3)
		{
			System::ClearAndInvalidateTimerHandle(LoopTimerHandle);
		}
	}

	/**
	 * Count a looping timer callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return LoopTimerCount incremented once
	 */
	UFUNCTION()
	void HandleLoopTimer()
	{
		LoopTimerCount++;
	}

	/**
	 * Clear the single-shot handle and record that it is not paused afterwards.
	 *
	 * @Kind Action
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return bSingleShotNotPausedAfterClear written from IsTimerPausedHandle
	 */
	UFUNCTION()
	void ClearSingleShotTimer()
	{
		System::ClearAndInvalidateTimerHandle(TimerHandle);
		bSingleShotNotPausedAfterClear = !System::IsTimerPausedHandle(TimerHandle);
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return true when counts are 0 and every pause flag is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (TimerCount != 0)
		{
			return false;
		}
		if (LoopTimerCount != 0)
		{
			return false;
		}
		if (bSingleShotNotPausedAfterSet != false)
		{
			return false;
		}
		if (bLoopNotPausedAfterSet != false)
		{
			return false;
		}
		if (bLoopPausedAfterPause != false)
		{
			return false;
		}
		if (bLoopNotPausedAfterUnPause != false)
		{
			return false;
		}
		if (bLoopNotPausedAfterClear != false)
		{
			return false;
		}
		return bSingleShotNotPausedAfterClear == false;
	}

	/**
	 * Observe that HandleTimer without any loop callbacks only increments TimerCount.
	 *
	 * @Kind Observe
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return true when TimerCount is 1 and LoopTimerCount is 0
	 */
	UFUNCTION()
	bool HandleTimerWithoutLoop()
	{
		HandleTimer();
		if (TimerCount != 1)
		{
			return false;
		}
		return LoopTimerCount == 0;
	}

	/**
	 * Observe that three loop callbacks then HandleTimer clear after the third loop.
	 *
	 * @Kind Observe
	 * @Covers Timer.EventTimer
	 * @Inputs none
	 * @Return true when LoopTimerCount is 3 and TimerCount is 1
	 * @Boundary three loop callbacks
	 */
	UFUNCTION()
	bool HandleLoopTimerBoundary()
	{
		HandleLoopTimer();
		HandleLoopTimer();
		HandleLoopTimer();
		HandleTimer();
		if (LoopTimerCount != 3)
		{
			return false;
		}
		return TimerCount == 1;
	}
}
