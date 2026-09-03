/**
 * Remaining and elapsed queries immediately after SetTimer. The CSV
 * NegativeDiagnostic label is a heuristic: C++ compiles this and VerifyByPath
 * the query flags, so this is a query oracle rather than a compile failure.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.TimerRemainingAndElapsed
 * @Harness UClass
 * @Tag Gameplay.Timer.TimerRemainingAndElapsed
 * @Provenance Theme: Gameplay.Timer. C++ compiles then VerifyByPath remaining/elapsed flags.
 * @Provenance CSV NegativeDiagnostic; method is a query oracle, not a compile-fail.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::TimerRemainingAndElapsed
 * @Provenance Oracle after BeginPlay: bQueriesSucceeded true, bRemainingIsPositive true,
 * @Provenance bElapsedIsNonNegative true, bRemainingWithinConfiguredDelay true, bTimerActiveAfterQuery true.
 * @Provenance Extra: floats 0 / flags false until BeginPlay. Do not spawn from script.
 */

UCLASS()
class ACoverageTimerRemainingElapsedActor : AActor
{
	UPROPERTY()
	float InitialRemaining = 0.0f;

	UPROPERTY()
	float InitialElapsed = 0.0f;

	UPROPERTY()
	float ObservedRemaining = 0.0f;

	UPROPERTY()
	float ObservedElapsed = 0.0f;

	UPROPERTY()
	bool bRemainingIsPositive = false;

	UPROPERTY()
	bool bElapsedIsNonNegative = false;

	UPROPERTY()
	bool bRemainingWithinConfiguredDelay = false;

	UPROPERTY()
	bool bTimerActiveAfterQuery = false;

	UPROPERTY()
	bool bQueriesSucceeded = false;

	FTimerHandle QueryHandle;

	/**
	 * Print when the queried timer fires.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerRemainingAndElapsed
	 * @Inputs none
	 * @Return a print only; remaining and elapsed queries are what the test observes
	 */
	UFUNCTION()
	void QueryCallback()
	{
		Print("QueryCallback executed");
	}

	/**
	 * WorldStory: BeginPlay sets a 2.0s timer and queries remaining and elapsed
	 * immediately.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerRemainingAndElapsed
	 * @Inputs none
	 * @Return remaining/elapsed flags recorded and bQueriesSucceeded true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerRemainingAndElapsed: Testing GetTimerRemaining and GetTimerElapsed");

		// Set a timer with 2.0 second delay
		QueryHandle = System::SetTimer(this, n"QueryCallback", 2.0f, false);

		// Query immediately after setting
		InitialRemaining = SystemLibrary::GetTimerRemainingTimeHandle(QueryHandle);
		InitialElapsed = SystemLibrary::GetTimerElapsedTimeHandle(QueryHandle);

		bRemainingIsPositive = (InitialRemaining > 0.0f);
		bRemainingWithinConfiguredDelay = (InitialRemaining <= 2.0f);
		bElapsedIsNonNegative = (InitialElapsed >= 0.0f);
		bTimerActiveAfterQuery = SystemLibrary::IsTimerActiveHandle(QueryHandle);
		bQueriesSucceeded = true;

		Print("Initial Remaining: " + InitialRemaining + " seconds");
		Print("Initial Elapsed: " + InitialElapsed + " seconds");
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerRemainingAndElapsed
	 * @Inputs none
	 * @Return true when floats are 0 and every flag is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialRemaining != 0.0f)
		{
			return false;
		}
		if (InitialElapsed != 0.0f)
		{
			return false;
		}
		if (ObservedRemaining != 0.0f)
		{
			return false;
		}
		if (ObservedElapsed != 0.0f)
		{
			return false;
		}
		if (bRemainingIsPositive != false)
		{
			return false;
		}
		if (bElapsedIsNonNegative != false)
		{
			return false;
		}
		if (bRemainingWithinConfiguredDelay != false)
		{
			return false;
		}
		if (bTimerActiveAfterQuery != false)
		{
			return false;
		}
		return bQueriesSucceeded == false;
	}
}
