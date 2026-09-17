/**
 * @version v1
 * @summary A second SetTimer with the same function name replaces the first handle. C++ verifies the replacement flags and remaining time by path, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A second SetTimer with the same function name replaces the first handle. C++ verifies the replacement flags and remaining time by path, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerRepeatedFunctionNameActor : AActor
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bFirstHandleActiveBeforeReplace = false;

	UPROPERTY()
	bool bFirstHandleInactiveAfterReplace = false;

	UPROPERTY()
	bool bReplacementHandleActive = false;

	UPROPERTY()
	float ReplacementRemaining = 0.0f;

	FTimerHandle FirstHandle;
	FTimerHandle ReplacementHandle;

	/**
	 * Count the shared function-name callback used by both handles.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerRepeatedFunctionNameReplacesExistingTimer
	 * @Inputs none
	 * @Return CallbackCount incremented once
	 */
	UFUNCTION()
	void SharedCallback()
	{
		CallbackCount++;
	}

	/**
	 * WorldStory: BeginPlay sets a timer by function name, then sets it again so
	 * the first handle is replaced.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerRepeatedFunctionNameReplacesExistingTimer
	 * @Inputs none
	 * @Return replacement flags and remaining time recorded
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FirstHandle = System::SetTimer(this, n"SharedCallback", 2.0f, false);
		bFirstHandleActiveBeforeReplace = SystemLibrary::IsTimerActiveHandle(FirstHandle);

		ReplacementHandle = System::SetTimer(this, n"SharedCallback", 0.25f, false);
		bFirstHandleInactiveAfterReplace = !SystemLibrary::IsTimerActiveHandle(FirstHandle);
		bReplacementHandleActive = SystemLibrary::IsTimerActiveHandle(ReplacementHandle);
		ReplacementRemaining = SystemLibrary::GetTimerRemainingTimeHandle(ReplacementHandle);
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerRepeatedFunctionNameReplacesExistingTimer
	 * @Inputs none
	 * @Return true when CallbackCount is 0, flags are false and remaining is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (CallbackCount != 0)
		{
			return false;
		}
		if (bFirstHandleActiveBeforeReplace != false)
		{
			return false;
		}
		if (bFirstHandleInactiveAfterReplace != false)
		{
			return false;
		}
		if (bReplacementHandleActive != false)
		{
			return false;
		}
		return ReplacementRemaining == 0.0f;
	}

	/**
	 * Observe that calling the shared callback directly increments the count.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerRepeatedFunctionNameReplacesExistingTimer
	 * @Inputs none
	 * @Return true when CallbackCount is 1
	 */
	UFUNCTION()
	bool DirectCallback()
	{
		SharedCallback();
		return CallbackCount == 1;
	}
}
/** @end */
