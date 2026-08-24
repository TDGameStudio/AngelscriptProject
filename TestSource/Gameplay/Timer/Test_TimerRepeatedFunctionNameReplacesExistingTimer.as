// Theme: Gameplay.Timer. WorldStory repeated function-name SetTimer replaces the first handle.
// C++: AngelscriptCoverageTimerTests.cpp::TimerRepeatedFunctionNameReplacesExistingTimer
// Oracle after BeginPlay: bFirstHandleActiveBeforeReplace true,
// bFirstHandleInactiveAfterReplace true, bReplacementHandleActive true,
// ReplacementRemaining > 0 and <= 0.25.
// Extra: CallbackCount 0 / flags false / remaining 0. Do not spawn from script.

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

	UFUNCTION()
	void SharedCallback()
	{
		CallbackCount++;
	}

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
}

bool Observe_RepeatedFunctionName_DefaultEmpty(ACoverageTimerRepeatedFunctionNameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerRepeatedFunctionNameReplacesExistingTimer setup: required Actor is null");
	}
	return Actor.CallbackCount == 0
		&& Actor.bFirstHandleActiveBeforeReplace == false
		&& Actor.bFirstHandleInactiveAfterReplace == false
		&& Actor.bReplacementHandleActive == false
		&& Actor.ReplacementRemaining == 0.0f;
}

bool Observe_RepeatedFunctionName_DirectCallback(ACoverageTimerRepeatedFunctionNameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerRepeatedFunctionNameReplacesExistingTimer setup: required Actor is null");
	}
	Actor.SharedCallback();
	return Actor.CallbackCount == 1;
}
