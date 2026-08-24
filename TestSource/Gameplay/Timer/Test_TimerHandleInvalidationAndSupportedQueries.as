// Theme: Gameplay.Timer. C++ compiles then VerifyByPath invalidation flags.
// CSV NegativeDiagnostic; method is a handle-query oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerHandleInvalidationAndSupportedQueries
// Oracle after BeginPlay: bValidAfterSet true, bPausedAfterSet false, bPausedAfterPause true,
// bPausedAfterUnpause false, bInvalidAfterClear true, bPausedQueryAfterClearIsFalse true.
// Extra: inverted defaults before BeginPlay. Do not spawn from script.

UCLASS()
class ACoverageTimerInvalidationActor : AActor
{
	UPROPERTY()
	bool bValidAfterSet = false;

	UPROPERTY()
	bool bPausedAfterSet = true;

	UPROPERTY()
	bool bPausedAfterPause = false;

	UPROPERTY()
	bool bPausedAfterUnpause = true;

	UPROPERTY()
	bool bInvalidAfterClear = false;

	UPROPERTY()
	bool bPausedQueryAfterClearIsFalse = true;

	FTimerHandle Handle;

	UFUNCTION()
	void Callback()
	{
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Handle = System::SetTimer(this, n"Callback", 30.0f, true);
		bValidAfterSet = SystemLibrary::TimerExistsHandle(Handle);
		bPausedAfterSet = System::IsTimerPausedHandle(Handle);

		System::PauseTimerHandle(Handle);
		bPausedAfterPause = System::IsTimerPausedHandle(Handle);

		System::UnPauseTimerHandle(Handle);
		bPausedAfterUnpause = System::IsTimerPausedHandle(Handle);

		System::ClearAndInvalidateTimerHandle(Handle);
		bInvalidAfterClear = !SystemLibrary::TimerExistsHandle(Handle);
		bPausedQueryAfterClearIsFalse = !System::IsTimerPausedHandle(Handle);
	}
}

bool Observe_TimerInvalidation_DefaultBeforeBeginPlay(ACoverageTimerInvalidationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerHandleInvalidationAndSupportedQueries setup: required Actor is null");
	}
	return Actor.bValidAfterSet == false
		&& Actor.bPausedAfterSet == true
		&& Actor.bPausedAfterPause == false
		&& Actor.bPausedAfterUnpause == true
		&& Actor.bInvalidAfterClear == false
		&& Actor.bPausedQueryAfterClearIsFalse == true;
}
