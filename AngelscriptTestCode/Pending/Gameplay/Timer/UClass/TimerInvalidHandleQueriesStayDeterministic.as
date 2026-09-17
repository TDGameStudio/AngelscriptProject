/**
 * @version v1
 * @summary Queries against an unset timer handle stay deterministic: not exists, not active, not paused, and remaining/elapsed are non-positive. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Queries against an unset timer handle stay deterministic: not exists, not active, not paused, and remaining/elapsed are non-positive. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerInvalidHandleQueryActor : AActor
{
	UPROPERTY()
	float InvalidRemaining = 1.0f;

	UPROPERTY()
	float InvalidElapsed = 1.0f;

	UPROPERTY()
	bool bDefaultHandleInvalid = false;

	UPROPERTY()
	bool bInactiveBeforeSet = false;

	UPROPERTY()
	bool bNotPausedBeforeSet = false;

	UPROPERTY()
	bool bRemainingNonPositiveForInvalid = false;

	UPROPERTY()
	bool bElapsedNonPositiveForInvalid = false;

	UPROPERTY()
	bool bStillInvalidAfterNoopLifecycle = false;

	FTimerHandle InvalidHandle;

	/**
	 * WorldStory: BeginPlay queries an unset handle, then no-ops pause, unpause
	 * and clear against it.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerInvalidHandleQueriesStayDeterministic
	 * @Inputs none
	 * @Return invalid-handle query flags recorded
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bDefaultHandleInvalid = !SystemLibrary::TimerExistsHandle(InvalidHandle);
		bInactiveBeforeSet = !SystemLibrary::IsTimerActiveHandle(InvalidHandle);
		bNotPausedBeforeSet = !System::IsTimerPausedHandle(InvalidHandle);

		InvalidRemaining = SystemLibrary::GetTimerRemainingTimeHandle(InvalidHandle);
		InvalidElapsed = SystemLibrary::GetTimerElapsedTimeHandle(InvalidHandle);
		bRemainingNonPositiveForInvalid = (InvalidRemaining <= 0.0f);
		bElapsedNonPositiveForInvalid = (InvalidElapsed <= 0.0f);

		System::PauseTimerHandle(InvalidHandle);
		System::UnPauseTimerHandle(InvalidHandle);
		System::ClearAndInvalidateTimerHandle(InvalidHandle);

		bStillInvalidAfterNoopLifecycle = !SystemLibrary::TimerExistsHandle(InvalidHandle)
			&& !SystemLibrary::IsTimerActiveHandle(InvalidHandle)
			&& !System::IsTimerPausedHandle(InvalidHandle);
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerInvalidHandleQueriesStayDeterministic
	 * @Inputs none
	 * @Return true when remaining/elapsed are 1.0 and every flag is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultBeforeBeginPlay()
	{
		if (InvalidRemaining != 1.0f)
		{
			return false;
		}
		if (InvalidElapsed != 1.0f)
		{
			return false;
		}
		if (bDefaultHandleInvalid != false)
		{
			return false;
		}
		if (bInactiveBeforeSet != false)
		{
			return false;
		}
		if (bNotPausedBeforeSet != false)
		{
			return false;
		}
		if (bRemainingNonPositiveForInvalid != false)
		{
			return false;
		}
		if (bElapsedNonPositiveForInvalid != false)
		{
			return false;
		}
		return bStillInvalidAfterNoopLifecycle == false;
	}
}
/** @end */
