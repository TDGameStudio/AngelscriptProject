// Theme: Gameplay.Timer. C++ compiles then VerifyByPath active/paused flags.
// CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerManagement
// Oracle after BeginPlay: bIsActiveAfterSet true, bIsPausedAfterPause true,
// bIsPausedAfterUnPause false, bIsActiveAfterClear false.
// Extra: inverted defaults; CallbackExecutionCount 0. Do not spawn from script.

UCLASS()
class ACoverageTimerManagementActor : AActor
{
	UPROPERTY()
	bool bIsActiveAfterSet = false;

	UPROPERTY()
	bool bIsActiveAfterClear = true;

	UPROPERTY()
	bool bIsPausedAfterPause = false;

	UPROPERTY()
	bool bIsPausedAfterUnPause = true;

	UPROPERTY()
	int CallbackExecutionCount = 0;

	FTimerHandle ManagedHandle;

	UFUNCTION()
	void ManagedCallback()
	{
		CallbackExecutionCount++;
		Print("ManagedCallback executed, count: " + CallbackExecutionCount);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerManagement: Testing timer lifecycle operations");

		// Set a looping timer
		ManagedHandle = System::SetTimer(this, n"ManagedCallback", 0.2f, true);
		bIsActiveAfterSet = SystemLibrary::IsTimerActiveHandle(ManagedHandle);
		Print("Timer set, IsActive: " + bIsActiveAfterSet);

		// Pause the timer
		System::PauseTimerHandle(ManagedHandle);
		bIsPausedAfterPause = System::IsTimerPausedHandle(ManagedHandle);
		Print("Timer paused, IsPaused: " + bIsPausedAfterPause);

		// UnPause the timer
		System::UnPauseTimerHandle(ManagedHandle);
		bIsPausedAfterUnPause = System::IsTimerPausedHandle(ManagedHandle);
		Print("Timer unpaused, IsPaused: " + bIsPausedAfterUnPause);

		// Clear the timer
		System::ClearAndInvalidateTimerHandle(ManagedHandle);
		bIsActiveAfterClear = SystemLibrary::IsTimerActiveHandle(ManagedHandle);
		Print("Timer cleared, IsActive: " + bIsActiveAfterClear);
	}
}

bool Observe_TimerManagement_DefaultBeforeBeginPlay(ACoverageTimerManagementActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerManagement setup: required Actor is null");
	}
	return Actor.bIsActiveAfterSet == false
		&& Actor.bIsActiveAfterClear == true
		&& Actor.bIsPausedAfterPause == false
		&& Actor.bIsPausedAfterUnPause == true
		&& Actor.CallbackExecutionCount == 0;
}

bool Observe_TimerManagement_DirectCallback(ACoverageTimerManagementActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerManagement setup: required Actor is null");
	}
	Actor.ManagedCallback();
	return Actor.CallbackExecutionCount == 1;
}
