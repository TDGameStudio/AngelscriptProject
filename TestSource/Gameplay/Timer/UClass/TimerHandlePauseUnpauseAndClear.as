/**
 * A looping timer walked through set, pause, unpause and clear, with the paused
 * state recorded after each transition. The CSV NegativeDiagnostic label is a
 * heuristic: C++ compiles this and VerifyByPath the flags, so this is a timer
 * state-machine oracle rather than a compile failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerHandlePauseUnpauseAndClear
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerHandlePauseUnpauseAndClear
 * @Provenance Theme: Gameplay.Timer. C++ compiles then VerifyByPath pause-state flags.
 * @Provenance CSV NegativeDiagnostic; method is a timer state-machine oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerHandlePauseUnpauseAndClear
 * @Provenance Oracle after BeginPlay: bAfterSetIsPaused false, bAfterPauseIsPaused true,
 * @Provenance bAfterUnPauseIsPaused false, bAfterClearIsPaused false.
 * @Provenance Extra: inverted defaults before BeginPlay; bCallbackCanCompile false.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ACoverageTimerHandleActor : AActor
{
	UPROPERTY()
	bool bAfterSetIsPaused = true;

	UPROPERTY()
	bool bAfterPauseIsPaused = false;

	UPROPERTY()
	bool bAfterUnPauseIsPaused = true;

	UPROPERTY()
	bool bAfterClearIsPaused = true;

	UPROPERTY()
	bool bCallbackCanCompile = false;

	FTimerHandle LoopingHandle;

	/**
	 * Mark that the looping callback can compile when invoked directly.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerHandlePauseUnpauseAndClear
	 * @Inputs none
	 * @Return bCallbackCanCompile true
	 */
	UFUNCTION()
	void NoopTimerCallback()
	{
		bCallbackCanCompile = true;
	}

	/**
	 * WorldStory: BeginPlay starts a looping timer, then records the paused state
	 * after pause, unpause and clear.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerHandlePauseUnpauseAndClear
	 * @Inputs none
	 * @Return false, true, false, false in that order after the four transitions
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LoopingHandle = System::SetTimer(this, n"NoopTimerCallback", 0.5f, true);
		bAfterSetIsPaused = System::IsTimerPausedHandle(LoopingHandle);

		System::PauseTimerHandle(LoopingHandle);
		bAfterPauseIsPaused = System::IsTimerPausedHandle(LoopingHandle);

		System::UnPauseTimerHandle(LoopingHandle);
		bAfterUnPauseIsPaused = System::IsTimerPausedHandle(LoopingHandle);

		System::ClearAndInvalidateTimerHandle(LoopingHandle);
		bAfterClearIsPaused = System::IsTimerPausedHandle(LoopingHandle);
	}

	/**
	 * Observe that an untouched actor holds the inverted defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerHandlePauseUnpauseAndClear
	 * @Inputs none
	 * @Return true when flags match the inverted defaults and bCallbackCanCompile is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultBeforeBeginPlay()
	{
		if (bAfterSetIsPaused != true)
		{
			return false;
		}
		if (bAfterPauseIsPaused != false)
		{
			return false;
		}
		if (bAfterUnPauseIsPaused != true)
		{
			return false;
		}
		if (bAfterClearIsPaused != true)
		{
			return false;
		}
		return bCallbackCanCompile == false;
	}

	/**
	 * Observe that invoking the noop callback marks it compilable.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerHandlePauseUnpauseAndClear
	 * @Inputs none
	 * @Return true when bCallbackCanCompile is true
	 */
	UFUNCTION()
	bool NoopMarksCompile()
	{
		NoopTimerCallback();
		return bCallbackCanCompile == true;
	}
}
