/**
 * Reusing the same script handle variable after ClearAndInvalidateTimerHandle.
 * The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and
 * VerifyByPath the reuse flags, so this is a handle-reuse oracle rather than a
 * compile failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerClearThenReuseHandleVariable
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerClearThenReuseHandleVariable
 * @Provenance Theme: Gameplay.Timer. C++ compiles then VerifyByPath reuse-after-clear flags.
 * @Provenance CSV NegativeDiagnostic; method is a handle-reuse oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerClearThenReuseHandleVariable
 * @Provenance Oracle after BeginPlay: bFirstHandleCleared true, bSecondHandleActive true,
 * @Provenance bHandleReusedAfterClear true.
 * @Provenance Extra: counts 0 / remaining 0 / flags false. Do not spawn from script.
 */

UCLASS()
class ACoverageTimerClearThenReuseHandleActor : AActor
{
	UPROPERTY()
	int FirstCallbackCount = 0;

	UPROPERTY()
	int SecondCallbackCount = 0;

	UPROPERTY()
	float FirstRemaining = 0.0f;

	UPROPERTY()
	float SecondRemaining = 0.0f;

	UPROPERTY()
	bool bHandleReusedAfterClear = false;

	UPROPERTY()
	bool bFirstHandleCleared = false;

	UPROPERTY()
	bool bSecondHandleActive = false;

	FTimerHandle SharedHandle;

	/**
	 * Count the first timer callback bound through the shared handle.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerClearThenReuseHandleVariable
	 * @Inputs none
	 * @Return FirstCallbackCount incremented once
	 */
	UFUNCTION()
	void FirstCallback()
	{
		FirstCallbackCount++;
		Print("FirstCallback executed");
	}

	/**
	 * Count the second timer callback bound after the handle is reused.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerClearThenReuseHandleVariable
	 * @Inputs none
	 * @Return SecondCallbackCount incremented once
	 */
	UFUNCTION()
	void SecondCallback()
	{
		SecondCallbackCount++;
		Print("SecondCallback executed");
	}

	/**
	 * WorldStory: BeginPlay sets a timer, clears the handle, then reuses the same
	 * script variable for a second timer.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerClearThenReuseHandleVariable
	 * @Inputs none
	 * @Return bFirstHandleCleared, bSecondHandleActive and bHandleReusedAfterClear recorded
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerClearThenReuseHandleVariable: Testing handle cleanup before reuse");

		// Set first timer
		SharedHandle = System::SetTimer(this, n"FirstCallback", 2.0f, false);
		FirstRemaining = SystemLibrary::GetTimerRemainingTimeHandle(SharedHandle);
		Print("First timer set, remaining: " + FirstRemaining);

		System::ClearAndInvalidateTimerHandle(SharedHandle);
		bFirstHandleCleared = !SystemLibrary::TimerExistsHandle(SharedHandle);

		// Reuse the same script handle variable after invalidating the old timer.
		SharedHandle = System::SetTimer(this, n"SecondCallback", 0.25f, false);
		SecondRemaining = SystemLibrary::GetTimerRemainingTimeHandle(SharedHandle);
		bSecondHandleActive = SystemLibrary::IsTimerActiveHandle(SharedHandle);
		Print("Second timer set after clear, remaining: " + SecondRemaining);

		bHandleReusedAfterClear = bFirstHandleCleared && bSecondHandleActive
			&& SecondRemaining > 0.0f && SecondRemaining <= 0.25f;
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerClearThenReuseHandleVariable
	 * @Inputs none
	 * @Return true when counts and remaining are 0 and every flag is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FirstCallbackCount != 0)
		{
			return false;
		}
		if (SecondCallbackCount != 0)
		{
			return false;
		}
		if (FirstRemaining != 0.0f)
		{
			return false;
		}
		if (SecondRemaining != 0.0f)
		{
			return false;
		}
		if (bHandleReusedAfterClear != false)
		{
			return false;
		}
		if (bFirstHandleCleared != false)
		{
			return false;
		}
		return bSecondHandleActive == false;
	}

	/**
	 * Observe that calling both callbacks once increments each count.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerClearThenReuseHandleVariable
	 * @Inputs none
	 * @Return true when both callback counts are 1
	 */
	UFUNCTION()
	bool DirectCallbacks()
	{
		FirstCallback();
		SecondCallback();
		if (FirstCallbackCount != 1)
		{
			return false;
		}
		return SecondCallbackCount == 1;
	}
}
