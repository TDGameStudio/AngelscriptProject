// Theme: Gameplay.Timer. C++ compiles then VerifyByPath clear/invalidate flags.
// CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerClearAndInvalidate
// Oracle after BeginPlay: bActiveBeforeClear true, bValidBeforeClear true,
// bActiveAfterClear false, bValidAfterClear false.
// Extra: all flags false until BeginPlay. Do not spawn from script.

UCLASS()
class ACoverageTimerClearInvalidateActor : AActor
{
	UPROPERTY()
	bool bActiveBeforeClear = false;

	UPROPERTY()
	bool bActiveAfterClear = false;

	UPROPERTY()
	bool bValidBeforeClear = false;

	UPROPERTY()
	bool bValidAfterClear = false;

	FTimerHandle ClearHandle;

	UFUNCTION()
	void ClearTestCallback()
	{
		Print("ClearTestCallback (should not execute if cleared)");
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerClearAndInvalidate: Testing ClearAndInvalidateTimerHandle");

		// Set a timer
		ClearHandle = System::SetTimer(this, n"ClearTestCallback", 1.0f, false);

		bActiveBeforeClear = SystemLibrary::IsTimerActiveHandle(ClearHandle);
		bValidBeforeClear = SystemLibrary::TimerExistsHandle(ClearHandle);

		Print("Before clear - Active: " + bActiveBeforeClear + ", Valid: " + bValidBeforeClear);

		// Clear and invalidate
		System::ClearAndInvalidateTimerHandle(ClearHandle);

		bActiveAfterClear = SystemLibrary::IsTimerActiveHandle(ClearHandle);
		bValidAfterClear = SystemLibrary::TimerExistsHandle(ClearHandle);

		Print("After clear - Active: " + bActiveAfterClear + ", Valid: " + bValidAfterClear);
	}
}

bool Observe_TimerClearInvalidate_DefaultEmpty(ACoverageTimerClearInvalidateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerClearAndInvalidate setup: required Actor is null");
	}
	return Actor.bActiveBeforeClear == false
		&& Actor.bActiveAfterClear == false
		&& Actor.bValidBeforeClear == false
		&& Actor.bValidAfterClear == false;
}
