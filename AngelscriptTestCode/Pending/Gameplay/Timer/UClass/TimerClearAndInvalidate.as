/**
 * @version v1
 * @summary ClearAndInvalidateTimerHandle observed through active and exists queries before and after the clear. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath the flags, so this is a lifecycle.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary ClearAndInvalidateTimerHandle observed through active and exists queries before and after the clear. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath the flags, so this is a lifecycle.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerClearInvalidateActor : AActor
{
	UPROPERTY()
	bool bActiveBeforeClear = false;

	UPROPERTY()
	bool bActiveAfterClear = false;

	UPROPERTY()
	bool bValidBeforeClear = false;

	UPROPERTY()
	bool bValidAfterClear = false;

	FTimerHandle ClearHandle;

	/**
	 * Callback that must not run if the handle is cleared first.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerClearAndInvalidate
	 * @Inputs none
	 * @Return a print only; the handle state is what the test observes
	 */
	UFUNCTION()
	void ClearTestCallback()
	{
		Print("ClearTestCallback (should not execute if cleared)");
	}

	/**
	 * WorldStory: BeginPlay sets a timer, records active/exists, then clears and
	 * records those queries again.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerClearAndInvalidate
	 * @Inputs none
	 * @Return true, true before clear and false, false after clear
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerClearAndInvalidate: Testing ClearAndInvalidateTimerHandle");

		// Set a timer
		ClearHandle = System::SetTimer(this, n"ClearTestCallback", 1.0f, false);

		bActiveBeforeClear = SystemLibrary::IsTimerActiveHandle(ClearHandle);
		bValidBeforeClear = SystemLibrary::TimerExistsHandle(ClearHandle);

		Print("Before clear - Active: " + bActiveBeforeClear + ", Valid: " + bValidBeforeClear);

		// Clear and invalidate
		System::ClearAndInvalidateTimerHandle(ClearHandle);

		bActiveAfterClear = SystemLibrary::IsTimerActiveHandle(ClearHandle);
		bValidAfterClear = SystemLibrary::TimerExistsHandle(ClearHandle);

		Print("After clear - Active: " + bActiveAfterClear + ", Valid: " + bValidAfterClear);
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerClearAndInvalidate
	 * @Inputs none
	 * @Return true when every flag is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bActiveBeforeClear != false)
		{
			return false;
		}
		if (bActiveAfterClear != false)
		{
			return false;
		}
		if (bValidBeforeClear != false)
		{
			return false;
		}
		return bValidAfterClear == false;
	}
}
/** @end */
