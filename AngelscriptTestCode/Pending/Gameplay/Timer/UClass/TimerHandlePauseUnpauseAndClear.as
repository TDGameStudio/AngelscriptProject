/**
 * @version v1
 * @summary A looping timer walked through set, pause, unpause and clear, with the paused state recorded after each transition. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath the flags, so this.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A looping timer walked through set, pause, unpause and clear, with the paused state recorded after each transition. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath the flags, so this.
 * @topic Baseline
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
/** @end */
