/**
 * A looping timer walked through set, pause, unpause and clear, with exists and
 * paused queries recorded after each transition. The CSV NegativeDiagnostic
 * label is a heuristic: C++ compiles this and VerifyByPath the flags, so this is
 * a handle-query oracle rather than a compile failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerHandleInvalidationAndSupportedQueries
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerHandleInvalidationAndSupportedQueries
 * @Provenance Theme: Gameplay.Timer. C++ compiles then VerifyByPath invalidation flags.
 * @Provenance CSV NegativeDiagnostic; method is a handle-query oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerHandleInvalidationAndSupportedQueries
 * @Provenance Oracle after BeginPlay: bValidAfterSet true, bPausedAfterSet false, bPausedAfterPause true,
 * @Provenance bPausedAfterUnpause false, bInvalidAfterClear true, bPausedQueryAfterClearIsFalse true.
 * @Provenance Extra: inverted defaults before BeginPlay. Do not spawn from script.
 */

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

	/**
	 * Empty callback bound to the queried looping timer.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerHandleInvalidationAndSupportedQueries
	 * @Inputs none
	 * @Return nothing; the handle queries are what the test observes
	 */
	UFUNCTION()
	void Callback()
	{
	}

	/**
	 * WorldStory: BeginPlay sets a looping timer, then records exists and paused
	 * queries after pause, unpause and clear.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerHandleInvalidationAndSupportedQueries
	 * @Inputs none
	 * @Return exists and paused flags recorded after each transition
	 */
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

	/**
	 * Observe that an untouched actor holds the inverted defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerHandleInvalidationAndSupportedQueries
	 * @Inputs none
	 * @Return true when flags match the inverted defaults
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultBeforeBeginPlay()
	{
		if (bValidAfterSet != false)
		{
			return false;
		}
		if (bPausedAfterSet != true)
		{
			return false;
		}
		if (bPausedAfterPause != false)
		{
			return false;
		}
		if (bPausedAfterUnpause != true)
		{
			return false;
		}
		if (bInvalidAfterClear != false)
		{
			return false;
		}
		return bPausedQueryAfterClearIsFalse == true;
	}
}
