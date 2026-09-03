/**
 * Configure, pause, resume and clear a timer by reflected function name. The CSV
 * NegativeDiagnostic label is a heuristic: C++ compiles this and invokes those
 * methods by reflection, so this is a lifecycle oracle rather than a compile
 * failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerDynamicFunctionNameReflectionLifecycle
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerDynamicFunctionNameReflectionLifecycle
 * @Provenance Theme: Gameplay.Timer. C++ compiles then invokes Configure/Pause/Resume/Clear by reflection.
 * @Provenance CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerDynamicFunctionNameReflectionLifecycle
 * @Provenance Oracle: ConfigureDynamicTimer("DynamicCallback", 0.5, true) returns true;
 * @Provenance SetupCount 1, bConfiguredViaName true, bTimerActiveAfterSetup true,
 * @Provenance RemainingAfterSetup > 0 and <= 0.5;
 * @Provenance PauseDynamicTimer true; ResumeDynamicTimer true and bPausedAfterReflectionResume false;
 * @Provenance ClearDynamicTimer true, bInvalidAfterReflectionClear true, bActiveAfterReflectionClear false.
 * @Provenance Extra: inverted defaults before any Configure. Do not spawn from script.
 */

UCLASS()
class ACoverageTimerDynamicFunctionNameActor : AActor
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	int SetupCount = 0;

	UPROPERTY()
	float RemainingAfterSetup = 0.0f;

	UPROPERTY()
	bool bConfiguredViaName = false;

	UPROPERTY()
	bool bTimerActiveAfterSetup = false;

	UPROPERTY()
	bool bPausedAfterReflectionPause = false;

	UPROPERTY()
	bool bPausedAfterReflectionResume = true;

	UPROPERTY()
	bool bInvalidAfterReflectionClear = false;

	UPROPERTY()
	bool bActiveAfterReflectionClear = true;

	FTimerHandle DynamicHandle;

	/**
	 * Count a dynamically named timer callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs none
	 * @Return CallbackCount incremented once
	 */
	UFUNCTION()
	void DynamicCallback()
	{
		CallbackCount++;
	}

	/**
	 * Bind a timer through a reflected callback name and record setup state.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs the callback name, delay and looping flag
	 * @Return true when the handle exists and is active
	 * @Param CallbackName the function name passed to SetTimer
	 * @Param DelaySeconds the timer delay
	 * @Param bLooping whether the timer repeats
	 */
	UFUNCTION()
	bool ConfigureDynamicTimer(FName CallbackName, float DelaySeconds, bool bLooping)
	{
		SetupCount++;
		DynamicHandle = System::SetTimer(this, CallbackName, DelaySeconds, bLooping);
		bConfiguredViaName = SystemLibrary::TimerExistsHandle(DynamicHandle);
		bTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(DynamicHandle);
		RemainingAfterSetup = SystemLibrary::GetTimerRemainingTimeHandle(DynamicHandle);
		if (!bConfiguredViaName)
		{
			return false;
		}
		return bTimerActiveAfterSetup;
	}

	/**
	 * Pause the dynamically configured handle and record the paused state.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs none
	 * @Return true when the handle reports paused
	 */
	UFUNCTION()
	bool PauseDynamicTimer()
	{
		System::PauseTimerHandle(DynamicHandle);
		bPausedAfterReflectionPause = System::IsTimerPausedHandle(DynamicHandle);
		return bPausedAfterReflectionPause;
	}

	/**
	 * Unpause the dynamically configured handle and record the paused state.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs none
	 * @Return true when the handle no longer reports paused
	 */
	UFUNCTION()
	bool ResumeDynamicTimer()
	{
		System::UnPauseTimerHandle(DynamicHandle);
		bPausedAfterReflectionResume = System::IsTimerPausedHandle(DynamicHandle);
		return !bPausedAfterReflectionResume;
	}

	/**
	 * Clear the dynamically configured handle and record invalid/active flags.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs none
	 * @Return true when the handle is invalid and not active
	 */
	UFUNCTION()
	bool ClearDynamicTimer()
	{
		System::ClearAndInvalidateTimerHandle(DynamicHandle);
		bInvalidAfterReflectionClear = !SystemLibrary::TimerExistsHandle(DynamicHandle);
		bActiveAfterReflectionClear = SystemLibrary::IsTimerActiveHandle(DynamicHandle);
		if (!bInvalidAfterReflectionClear)
		{
			return false;
		}
		return !bActiveAfterReflectionClear;
	}

	/**
	 * Observe that an untouched actor holds the inverted defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs none
	 * @Return true when counts are 0, remaining is 0 and flags match the inverted defaults
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (CallbackCount != 0)
		{
			return false;
		}
		if (SetupCount != 0)
		{
			return false;
		}
		if (RemainingAfterSetup != 0.0f)
		{
			return false;
		}
		if (bConfiguredViaName != false)
		{
			return false;
		}
		if (bTimerActiveAfterSetup != false)
		{
			return false;
		}
		if (bPausedAfterReflectionPause != false)
		{
			return false;
		}
		if (bPausedAfterReflectionResume != true)
		{
			return false;
		}
		if (bInvalidAfterReflectionClear != false)
		{
			return false;
		}
		return bActiveAfterReflectionClear == true;
	}

	/**
	 * Observe that calling DynamicCallback directly increments only the callback count.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerDynamicFunctionNameReflectionLifecycle
	 * @Inputs none
	 * @Return true when CallbackCount is 1 and SetupCount is 0
	 */
	UFUNCTION()
	bool DirectCallback()
	{
		DynamicCallback();
		if (CallbackCount != 1)
		{
			return false;
		}
		return SetupCount == 0;
	}
}
