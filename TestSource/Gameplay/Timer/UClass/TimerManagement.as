/**
 * A looping timer walked through set, pause, unpause and clear, with active and
 * paused flags recorded after each transition. The CSV NegativeDiagnostic label
 * is a heuristic: C++ compiles this and VerifyByPath the flags, so this is a
 * lifecycle oracle rather than a compile failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerManagement
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerManagement
 * @Provenance Theme: Gameplay.Timer. C++ compiles then VerifyByPath active/paused flags.
 * @Provenance CSV NegativeDiagnostic; method is a lifecycle oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerManagement
 * @Provenance Oracle after BeginPlay: bIsActiveAfterSet true, bIsPausedAfterPause true,
 * @Provenance bIsPausedAfterUnPause false, bIsActiveAfterClear false.
 * @Provenance Extra: inverted defaults; CallbackExecutionCount 0. Do not spawn from script.
 */

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

	/**
	 * Count a managed looping timer callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerManagement
	 * @Inputs none
	 * @Return CallbackExecutionCount incremented once
	 */
	UFUNCTION()
	void ManagedCallback()
	{
		CallbackExecutionCount++;
		Print("ManagedCallback executed, count: " + CallbackExecutionCount);
	}

	/**
	 * WorldStory: BeginPlay sets a looping timer, then records active and paused
	 * state after pause, unpause and clear.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerManagement
	 * @Inputs none
	 * @Return active and paused flags recorded after each transition
	 */
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

	/**
	 * Observe that an untouched actor holds the inverted defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerManagement
	 * @Inputs none
	 * @Return true when flags match the inverted defaults and CallbackExecutionCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultBeforeBeginPlay()
	{
		if (bIsActiveAfterSet != false)
		{
			return false;
		}
		if (bIsActiveAfterClear != true)
		{
			return false;
		}
		if (bIsPausedAfterPause != false)
		{
			return false;
		}
		if (bIsPausedAfterUnPause != true)
		{
			return false;
		}
		return CallbackExecutionCount == 0;
	}

	/**
	 * Observe that calling the managed callback directly increments the count.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerManagement
	 * @Inputs none
	 * @Return true when CallbackExecutionCount is 1
	 */
	UFUNCTION()
	bool DirectCallback()
	{
		ManagedCallback();
		return CallbackExecutionCount == 1;
	}
}
