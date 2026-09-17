/**
 * @version v1
 * @summary A looping timer walked through set, pause, unpause and clear, with the paused state recorded after each transition. The CSV NegativeDiagnostic label is a heuristic: the method is a timer state-machine oracle, not a.
 * @topic World
 */
/**
 * @version root
 * @summary A looping timer walked through set, pause, unpause and clear, with the paused state recorded after each transition. The CSV NegativeDiagnostic label is a heuristic: the method is a timer state-machine oracle, not a.
 * @topic Baseline
 */
UCLASS()
class AFunctionalTimerActor : AActor
{
	UPROPERTY()
	FTimerHandle LoopingHandle;

	UPROPERTY()
	bool bAfterSetIsPaused = false;

	UPROPERTY()
	bool bAfterPauseIsPaused = false;

	UPROPERTY()
	bool bAfterUnPauseIsPaused = false;

	UPROPERTY()
	bool bAfterClearIsPaused = false;

	/**
	 * The callback the looping timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Actor.PauseUnpauseAndClearTransitionsAreObservable
	 * @Inputs none
	 * @Return nothing; the timer state machine is what the test observes
	 */
	UFUNCTION()
	void NoopTimerCallback()
	{
	}

	/**
	 * WorldStory: BeginPlay starts a looping timer, then records the paused state
	 * after each of the pause, unpause and clear transitions.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.PauseUnpauseAndClearTransitionsAreObservable
	 * @Inputs none
	 * @Return false, true, false, false in that order
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
	 * Observe that a locally constructed actor has recorded no timer state.
	 *
	 * @Kind Observe
	 * @Covers Actor.PauseUnpauseAndClearTransitionsAreObservable
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bAfterSetIsPaused)
		{
			return false;
		}
		if (bAfterPauseIsPaused)
		{
			return false;
		}
		if (bAfterUnPauseIsPaused)
		{
			return false;
		}
		return !bAfterClearIsPaused;
	}
}
/** @end */
