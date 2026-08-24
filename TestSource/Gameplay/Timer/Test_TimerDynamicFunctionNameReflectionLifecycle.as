// Theme: Gameplay.Timer. C++ compiles then invokes Configure/Pause/Resume/Clear by reflection.
// CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerDynamicFunctionNameReflectionLifecycle
// Oracle: ConfigureDynamicTimer("DynamicCallback", 0.5, true) returns true;
// SetupCount 1, bConfiguredViaName true, bTimerActiveAfterSetup true,
// RemainingAfterSetup > 0 and <= 0.5;
// PauseDynamicTimer true; ResumeDynamicTimer true and bPausedAfterReflectionResume false;
// ClearDynamicTimer true, bInvalidAfterReflectionClear true, bActiveAfterReflectionClear false.
// Extra: inverted defaults before any Configure. Do not spawn from script.

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

	UFUNCTION()
	void DynamicCallback()
	{
		CallbackCount++;
	}

	UFUNCTION()
	bool ConfigureDynamicTimer(FName CallbackName, float DelaySeconds, bool bLooping)
	{
		SetupCount++;
		DynamicHandle = System::SetTimer(this, CallbackName, DelaySeconds, bLooping);
		bConfiguredViaName = SystemLibrary::TimerExistsHandle(DynamicHandle);
		bTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(DynamicHandle);
		RemainingAfterSetup = SystemLibrary::GetTimerRemainingTimeHandle(DynamicHandle);
		return bConfiguredViaName && bTimerActiveAfterSetup;
	}

	UFUNCTION()
	bool PauseDynamicTimer()
	{
		System::PauseTimerHandle(DynamicHandle);
		bPausedAfterReflectionPause = System::IsTimerPausedHandle(DynamicHandle);
		return bPausedAfterReflectionPause;
	}

	UFUNCTION()
	bool ResumeDynamicTimer()
	{
		System::UnPauseTimerHandle(DynamicHandle);
		bPausedAfterReflectionResume = System::IsTimerPausedHandle(DynamicHandle);
		return !bPausedAfterReflectionResume;
	}

	UFUNCTION()
	bool ClearDynamicTimer()
	{
		System::ClearAndInvalidateTimerHandle(DynamicHandle);
		bInvalidAfterReflectionClear = !SystemLibrary::TimerExistsHandle(DynamicHandle);
		bActiveAfterReflectionClear = SystemLibrary::IsTimerActiveHandle(DynamicHandle);
		return bInvalidAfterReflectionClear && !bActiveAfterReflectionClear;
	}
}

bool Observe_DynamicFunctionName_DefaultEmpty(ACoverageTimerDynamicFunctionNameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerDynamicFunctionNameReflectionLifecycle setup: required Actor is null");
	}
	return Actor.CallbackCount == 0
		&& Actor.SetupCount == 0
		&& Actor.RemainingAfterSetup == 0.0f
		&& Actor.bConfiguredViaName == false
		&& Actor.bTimerActiveAfterSetup == false
		&& Actor.bPausedAfterReflectionPause == false
		&& Actor.bPausedAfterReflectionResume == true
		&& Actor.bInvalidAfterReflectionClear == false
		&& Actor.bActiveAfterReflectionClear == true;
}

bool Observe_DynamicFunctionName_DirectCallback(ACoverageTimerDynamicFunctionNameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerDynamicFunctionNameReflectionLifecycle setup: required Actor is null");
	}
	Actor.DynamicCallback();
	return Actor.CallbackCount == 1 && Actor.SetupCount == 0;
}
