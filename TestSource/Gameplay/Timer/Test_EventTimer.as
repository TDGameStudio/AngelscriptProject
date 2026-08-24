// Theme: Gameplay.Timer. C++ compiles and VerifyByPath timer pause flags.
// CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
// C++: AngelscriptCoverageEventTests.cpp::EventTimer
// Oracle after BeginPlay: bSingleShotNotPausedAfterSet true, bLoopNotPausedAfterSet true,
// bLoopPausedAfterPause true, bLoopNotPausedAfterUnPause true, bLoopNotPausedAfterClear true.
// ClearSingleShotTimer then bSingleShotNotPausedAfterClear true.
// Extra: defaults 0/false; HandleTimer without loops. Do not spawn from script.

UCLASS()
class ACoverageEventTimerActor : AActor
{
	UPROPERTY()
	int TimerCount = 0;

	UPROPERTY()
	int LoopTimerCount = 0;

	UPROPERTY()
	bool bSingleShotNotPausedAfterSet = false;

	UPROPERTY()
	bool bLoopNotPausedAfterSet = false;

	UPROPERTY()
	bool bLoopPausedAfterPause = false;

	UPROPERTY()
	bool bLoopNotPausedAfterUnPause = false;

	UPROPERTY()
	bool bLoopNotPausedAfterClear = false;

	UPROPERTY()
	bool bSingleShotNotPausedAfterClear = false;

	FTimerHandle TimerHandle;
	FTimerHandle LoopTimerHandle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TimerHandle = System::SetTimer(this, n"HandleTimer", 30.0f, false);
		bSingleShotNotPausedAfterSet = !System::IsTimerPausedHandle(TimerHandle);

		LoopTimerHandle = System::SetTimer(this, n"HandleLoopTimer", 30.0f, true);
		bLoopNotPausedAfterSet = !System::IsTimerPausedHandle(LoopTimerHandle);

		System::PauseTimerHandle(LoopTimerHandle);
		bLoopPausedAfterPause = System::IsTimerPausedHandle(LoopTimerHandle);

		System::UnPauseTimerHandle(LoopTimerHandle);
		bLoopNotPausedAfterUnPause = !System::IsTimerPausedHandle(LoopTimerHandle);

		System::ClearAndInvalidateTimerHandle(LoopTimerHandle);
		bLoopNotPausedAfterClear = !System::IsTimerPausedHandle(LoopTimerHandle);
	}

	UFUNCTION()
	void HandleTimer()
	{
		TimerCount++;
		if (LoopTimerCount >= 3)
		{
			System::ClearAndInvalidateTimerHandle(LoopTimerHandle);
		}
	}

	UFUNCTION()
	void HandleLoopTimer()
	{
		LoopTimerCount++;
	}

	UFUNCTION()
	void ClearSingleShotTimer()
	{
		System::ClearAndInvalidateTimerHandle(TimerHandle);
		bSingleShotNotPausedAfterClear = !System::IsTimerPausedHandle(TimerHandle);
	}
}

bool Observe_EventTimer_DefaultEmpty(ACoverageEventTimerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventTimer setup: required Actor is null");
	}
	return Actor.TimerCount == 0
		&& Actor.LoopTimerCount == 0
		&& Actor.bSingleShotNotPausedAfterSet == false
		&& Actor.bLoopNotPausedAfterSet == false
		&& Actor.bLoopPausedAfterPause == false
		&& Actor.bLoopNotPausedAfterUnPause == false
		&& Actor.bLoopNotPausedAfterClear == false
		&& Actor.bSingleShotNotPausedAfterClear == false;
}

bool Observe_EventTimer_HandleTimerWithoutLoop(ACoverageEventTimerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventTimer setup: required Actor is null");
	}
	Actor.HandleTimer();
	return Actor.TimerCount == 1 && Actor.LoopTimerCount == 0;
}

bool Observe_EventTimer_HandleLoopTimerBoundary(ACoverageEventTimerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventTimer setup: required Actor is null");
	}
	Actor.HandleLoopTimer();
	Actor.HandleLoopTimer();
	Actor.HandleLoopTimer();
	Actor.HandleTimer();
	return Actor.LoopTimerCount == 3 && Actor.TimerCount == 1;
}
