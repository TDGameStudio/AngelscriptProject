// Theme: World.Actor. C++ compiles this actor then VerifyByPath pause-state flags.
// CSV marks NegativeDiagnostic; the method is a timer state-machine oracle, not a compile-fail.
// C++: AngelscriptActorTimerRuntimeBehaviorTests.cpp::PauseUnpauseAndClearTransitionsAreObservable
// Oracle: bAfterSetIsPaused false, bAfterPauseIsPaused true, bAfterUnPauseIsPaused false,
// bAfterClearIsPaused false.
// Extra: all flags default false until BeginPlay. Do not spawn from script. FixtureIsolated.

UCLASS()
class AFunctionalTimerActor : AActor
{
	UPROPERTY()
	FTimerHandle LoopingHandle;

	UPROPERTY()
	bool bAfterSetIsPaused = false;

	UPROPERTY()
	bool bAfterPauseIsPaused = false;

	UPROPERTY()
	bool bAfterUnPauseIsPaused = false;

	UPROPERTY()
	bool bAfterClearIsPaused = false;

	UFUNCTION()
	void NoopTimerCallback()
	{
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
