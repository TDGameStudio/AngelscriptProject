// Theme: Gameplay.Timer. WorldStory SetTimer single-shot and looping setup.
// C++: AngelscriptCoverageTimerTests.cpp::TimerBasicUsage
// Oracle after BeginPlay: bLoopingSetupComplete true.
// Extra: counts 0 / bSingleShotExecuted false until callbacks. Do not spawn from script.

UCLASS()
class ACoverageTimerBasicUsageActor : AActor
{
	UPROPERTY()
	int SingleShotCallCount = 0;

	UPROPERTY()
	int LoopingCallCount = 0;

	UPROPERTY()
	bool bSingleShotExecuted = false;

	UPROPERTY()
	bool bLoopingSetupComplete = false;

	FTimerHandle SingleShotHandle;
	FTimerHandle LoopingHandle;

	UFUNCTION()
	void SingleShotCallback()
	{
		SingleShotCallCount++;
		bSingleShotExecuted = true;
		Print("SingleShotCallback executed, count: " + SingleShotCallCount);
	}

	UFUNCTION()
	void LoopingCallback()
	{
		LoopingCallCount++;
		Print("LoopingCallback executed, count: " + LoopingCallCount);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerBasicUsage: Setting up timers");

		// SetTimer single shot (non-looping)
		SingleShotHandle = System::SetTimer(this, n"SingleShotCallback", 0.1f, false);
		Print("Single shot timer set with 0.1s delay");

		// SetTimer looping
		LoopingHandle = System::SetTimer(this, n"LoopingCallback", 0.1f, true);
		bLoopingSetupComplete = true;
		Print("Looping timer set with 0.1s interval");
	}
}

bool Observe_TimerBasicUsage_DefaultEmpty(ACoverageTimerBasicUsageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerBasicUsage setup: required Actor is null");
	}
	return Actor.SingleShotCallCount == 0
		&& Actor.LoopingCallCount == 0
		&& Actor.bSingleShotExecuted == false
		&& Actor.bLoopingSetupComplete == false;
}

bool Observe_TimerBasicUsage_DirectCallbacks(ACoverageTimerBasicUsageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerBasicUsage setup: required Actor is null");
	}
	Actor.SingleShotCallback();
	Actor.LoopingCallback();
	return Actor.SingleShotCallCount == 1
		&& Actor.bSingleShotExecuted == true
		&& Actor.LoopingCallCount == 1;
}
