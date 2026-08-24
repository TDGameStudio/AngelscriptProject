// Theme: Gameplay.Timer. C++ compiles then VerifyByPath pause-state flags.
// CSV NegativeDiagnostic; method is a timer state-machine oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerHandlePauseUnpauseAndClear
// Oracle after BeginPlay: bAfterSetIsPaused false, bAfterPauseIsPaused true,
// bAfterUnPauseIsPaused false, bAfterClearIsPaused false.
// Extra: inverted defaults before BeginPlay; bCallbackCanCompile false.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ACoverageTimerHandleActor : AActor
{
	UPROPERTY()
	bool bAfterSetIsPaused = true;

	UPROPERTY()
	bool bAfterPauseIsPaused = false;

	UPROPERTY()
	bool bAfterUnPauseIsPaused = true;

	UPROPERTY()
	bool bAfterClearIsPaused = true;

	UPROPERTY()
	bool bCallbackCanCompile = false;

	FTimerHandle LoopingHandle;

	UFUNCTION()
	void NoopTimerCallback()
	{
		bCallbackCanCompile = true;
	}

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
}

bool Observe_TimerHandle_DefaultBeforeBeginPlay(ACoverageTimerHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerHandlePauseUnpauseAndClear setup: required Actor is null");
	}
	return Actor.bAfterSetIsPaused == true
		&& Actor.bAfterPauseIsPaused == false
		&& Actor.bAfterUnPauseIsPaused == true
		&& Actor.bAfterClearIsPaused == true
		&& Actor.bCallbackCanCompile == false;
}

bool Observe_TimerHandle_NoopMarksCompile(ACoverageTimerHandleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerHandlePauseUnpauseAndClear setup: required Actor is null");
	}
	Actor.NoopTimerCallback();
	return Actor.bCallbackCanCompile == true;
}
