/**
 * @version v1
 * @summary System::SetTimer call sites on both a component and an actor, compiled and run to confirm the call shapes stay stable. The CSV NegativeDiagnostic label is a heuristic: C++ compiles these and verifies the flags by path.
 * @topic World
 */
/**
 * @version root
 * @summary System::SetTimer call sites on both a component and an actor, compiled and run to confirm the call shapes stay stable. The CSV NegativeDiagnostic label is a heuristic: C++ compiles these and verifies the flags by path.
 * @topic Baseline
 */
UCLASS()
class UCoverageTimerComponentCallSite : UActorComponent
{
	FTimerHandle ComponentHandle;

	/**
	 * The callback the component timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return nothing; the timer reaching it is what the test observes
	 */
	UFUNCTION()
	void ComponentCallback()
	{
	}

	/**
	 * Set up the component timer, walk the pause and clear calls, and confirm the
	 * reported state at each step.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return true when the timer was active, paused on request, reported sane
	 * remaining and elapsed times, and no longer exists after being cleared
	 */
	UFUNCTION()
	bool ConfigureComponentTimer()
	{
		ComponentHandle = System::SetTimer(this, n"ComponentCallback", 1.0f, true);
		bool bActive = SystemLibrary::IsTimerActiveHandle(ComponentHandle);
		float Remaining = SystemLibrary::GetTimerRemainingTimeHandle(ComponentHandle);
		float Elapsed = SystemLibrary::GetTimerElapsedTimeHandle(ComponentHandle);

		System::PauseTimerHandle(ComponentHandle);
		bool bPaused = System::IsTimerPausedHandle(ComponentHandle);
		System::UnPauseTimerHandle(ComponentHandle);
		System::ClearAndInvalidateTimerHandle(ComponentHandle);

		if (!bActive)
		{
			return false;
		}
		if (!bPaused)
		{
			return false;
		}
		if (Remaining < 0.0f)
		{
			return false;
		}
		if (Elapsed < 0.0f)
		{
			return false;
		}
		return !SystemLibrary::TimerExistsHandle(ComponentHandle);
	}
}

UCLASS()
class ACoverageTimerCompileStableActor : AActor
{
	FTimerHandle NextTickHandle;
	FTimerHandle FunctionNameHandle;

	UPROPERTY()
	bool bNextTickCallSiteCompiled = false;

	UPROPERTY()
	bool bFunctionNameCallSiteCompiled = false;

	/**
	 * The callback the zero-delay timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return nothing; the call site compiling is what the test observes
	 */
	UFUNCTION()
	void NextTickCallback()
	{
	}

	/**
	 * The callback the repeating timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return nothing; the call site compiling is what the test observes
	 */
	UFUNCTION()
	void FunctionNameCallback()
	{
	}

	/**
	 * WorldStory: BeginPlay sets a zero-delay timer and a repeating timer, records
	 * that each call site compiled, then clears both.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return both flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NextTickHandle = System::SetTimer(this, n"NextTickCallback", 0.0f, false);
		bNextTickCallSiteCompiled = SystemLibrary::TimerExistsHandle(NextTickHandle) || !System::IsTimerPausedHandle(NextTickHandle);
		System::ClearAndInvalidateTimerHandle(NextTickHandle);

		FunctionNameHandle = System::SetTimer(this, n"FunctionNameCallback", 0.25f, true);
		bFunctionNameCallSiteCompiled = SystemLibrary::IsTimerActiveHandle(FunctionNameHandle)
			&& SystemLibrary::GetTimerRemainingTimeHandle(FunctionNameHandle) >= 0.0f
			&& SystemLibrary::GetTimerElapsedTimeHandle(FunctionNameHandle) >= 0.0f;
		System::ClearAndInvalidateTimerHandle(FunctionNameHandle);
	}

	/**
	 * Observe that a locally constructed actor has neither flag set.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (bNextTickCallSiteCompiled)
		{
			return false;
		}
		return !bFunctionNameCallSiteCompiled;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageTimerCompileStableActor Second)
	{
		if (Second is null)
		{
			throw("TimerCompileStableActorAndComponentCallSites setup: required Second is null");
		}
		bNextTickCallSiteCompiled = true;

		if (!bNextTickCallSiteCompiled)
		{
			return false;
		}
		return !Second.bNextTickCallSiteCompiled;
	}
}
/** @end */
