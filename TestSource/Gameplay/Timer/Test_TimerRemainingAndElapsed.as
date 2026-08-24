// Theme: Gameplay.Timer. C++ compiles then VerifyByPath remaining/elapsed flags.
// CSV NegativeDiagnostic; method is a query oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerRemainingAndElapsed
// Oracle after BeginPlay: bQueriesSucceeded true, bRemainingIsPositive true,
// bElapsedIsNonNegative true, bRemainingWithinConfiguredDelay true, bTimerActiveAfterQuery true.
// Extra: floats 0 / flags false until BeginPlay. Do not spawn from script.

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

	UFUNCTION()
	void QueryCallback()
	{
		Print("QueryCallback executed");
	}

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
}

bool Observe_TimerRemaining_DefaultEmpty(ACoverageTimerRemainingElapsedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerRemainingAndElapsed setup: required Actor is null");
	}
	return Actor.InitialRemaining == 0.0f
		&& Actor.InitialElapsed == 0.0f
		&& Actor.ObservedRemaining == 0.0f
		&& Actor.ObservedElapsed == 0.0f
		&& Actor.bRemainingIsPositive == false
		&& Actor.bElapsedIsNonNegative == false
		&& Actor.bRemainingWithinConfiguredDelay == false
		&& Actor.bTimerActiveAfterQuery == false
		&& Actor.bQueriesSucceeded == false;
}
