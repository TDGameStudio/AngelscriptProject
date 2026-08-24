// Theme: Gameplay.Timer. C++ compiles then VerifyByPath reuse-after-clear flags.
// CSV NegativeDiagnostic; method is a handle-reuse oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerClearThenReuseHandleVariable
// Oracle after BeginPlay: bFirstHandleCleared true, bSecondHandleActive true,
// bHandleReusedAfterClear true.
// Extra: counts 0 / remaining 0 / flags false. Do not spawn from script.

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

	UFUNCTION()
	void FirstCallback()
	{
		FirstCallbackCount++;
		Print("FirstCallback executed");
	}

	UFUNCTION()
	void SecondCallback()
	{
		SecondCallbackCount++;
		Print("SecondCallback executed");
	}

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
}

bool Observe_TimerClearReuse_DefaultEmpty(ACoverageTimerClearThenReuseHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerClearThenReuseHandleVariable setup: required Actor is null");
	}
	return Actor.FirstCallbackCount == 0
		&& Actor.SecondCallbackCount == 0
		&& Actor.FirstRemaining == 0.0f
		&& Actor.SecondRemaining == 0.0f
		&& Actor.bHandleReusedAfterClear == false
		&& Actor.bFirstHandleCleared == false
		&& Actor.bSecondHandleActive == false;
}

bool Observe_TimerClearReuse_DirectCallbacks(ACoverageTimerClearThenReuseHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerClearThenReuseHandleVariable setup: required Actor is null");
	}
	Actor.FirstCallback();
	Actor.SecondCallback();
	return Actor.FirstCallbackCount == 1 && Actor.SecondCallbackCount == 1;
}
