// Theme: Gameplay.Timer. C++ compiles then VerifyByPath invalid-handle query flags.
// CSV NegativeDiagnostic; method is a deterministic-query oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerInvalidHandleQueriesStayDeterministic
// Oracle after BeginPlay: bDefaultHandleInvalid true, bInactiveBeforeSet true,
// bNotPausedBeforeSet true, bRemainingNonPositiveForInvalid true,
// bElapsedNonPositiveForInvalid true, bStillInvalidAfterNoopLifecycle true.
// Extra: InvalidRemaining/Elapsed default 1.0; flags false. Do not spawn from script.

UCLASS()
class ACoverageTimerInvalidHandleQueryActor : AActor
{
	UPROPERTY()
	float InvalidRemaining = 1.0f;

	UPROPERTY()
	float InvalidElapsed = 1.0f;

	UPROPERTY()
	bool bDefaultHandleInvalid = false;

	UPROPERTY()
	bool bInactiveBeforeSet = false;

	UPROPERTY()
	bool bNotPausedBeforeSet = false;

	UPROPERTY()
	bool bRemainingNonPositiveForInvalid = false;

	UPROPERTY()
	bool bElapsedNonPositiveForInvalid = false;

	UPROPERTY()
	bool bStillInvalidAfterNoopLifecycle = false;

	FTimerHandle InvalidHandle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bDefaultHandleInvalid = !SystemLibrary::TimerExistsHandle(InvalidHandle);
		bInactiveBeforeSet = !SystemLibrary::IsTimerActiveHandle(InvalidHandle);
		bNotPausedBeforeSet = !System::IsTimerPausedHandle(InvalidHandle);

		InvalidRemaining = SystemLibrary::GetTimerRemainingTimeHandle(InvalidHandle);
		InvalidElapsed = SystemLibrary::GetTimerElapsedTimeHandle(InvalidHandle);
		bRemainingNonPositiveForInvalid = (InvalidRemaining <= 0.0f);
		bElapsedNonPositiveForInvalid = (InvalidElapsed <= 0.0f);

		System::PauseTimerHandle(InvalidHandle);
		System::UnPauseTimerHandle(InvalidHandle);
		System::ClearAndInvalidateTimerHandle(InvalidHandle);

		bStillInvalidAfterNoopLifecycle = !SystemLibrary::TimerExistsHandle(InvalidHandle)
			&& !SystemLibrary::IsTimerActiveHandle(InvalidHandle)
			&& !System::IsTimerPausedHandle(InvalidHandle);
	}
}

bool Observe_InvalidHandleQuery_DefaultBeforeBeginPlay(ACoverageTimerInvalidHandleQueryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerInvalidHandleQueriesStayDeterministic setup: required Actor is null");
	}
	return Actor.InvalidRemaining == 1.0f
		&& Actor.InvalidElapsed == 1.0f
		&& Actor.bDefaultHandleInvalid == false
		&& Actor.bInactiveBeforeSet == false
		&& Actor.bNotPausedBeforeSet == false
		&& Actor.bRemainingNonPositiveForInvalid == false
		&& Actor.bElapsedNonPositiveForInvalid == false
		&& Actor.bStillInvalidAfterNoopLifecycle == false;
}
