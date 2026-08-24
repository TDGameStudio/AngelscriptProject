// Theme: Gameplay.Timer. WorldStory delayed single-shot and repeating timers.
// C++: AngelscriptCoverageTimerTests.cpp::TimerDelayExecution
// Oracle after BeginPlay: bShortDelaySetup true, bLongDelaySetup true, bRepeatingDelaySetup true.
// Extra: setup flags false and counts 0 until BeginPlay. Do not spawn from script.

UCLASS()
class ACoverageTimerDelayExecutionActor : AActor
{
	UPROPERTY()
	bool bShortDelaySetup = false;

	UPROPERTY()
	bool bLongDelaySetup = false;

	UPROPERTY()
	bool bRepeatingDelaySetup = false;

	UPROPERTY()
	int ShortDelayCallCount = 0;

	UPROPERTY()
	int RepeatingCallCount = 0;

	FTimerHandle ShortDelayHandle;
	FTimerHandle LongDelayHandle;
	FTimerHandle RepeatingHandle;

	UFUNCTION()
	void ShortDelayCallback()
	{
		ShortDelayCallCount++;
		Print("ShortDelayCallback executed after 0.5s delay");
	}

	UFUNCTION()
	void LongDelayCallback()
	{
		Print("LongDelayCallback executed after 1.0s delay");
	}

	UFUNCTION()
	void RepeatingCallback()
	{
		RepeatingCallCount++;
		Print("RepeatingCallback executed, count: " + RepeatingCallCount);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerDelayExecution: Testing delayed execution patterns");

		// Delay 0.5 seconds, execute once
		ShortDelayHandle = System::SetTimer(this, n"ShortDelayCallback", 0.5f, false);
		bShortDelaySetup = true;
		Print("Short delay timer (0.5s) set for single execution");

		// Delay 1.0 second, execute once
		LongDelayHandle = System::SetTimer(this, n"LongDelayCallback", 1.0f, false);
		bLongDelaySetup = true;
		Print("Long delay timer (1.0s) set for single execution");

		// Delay 0.3 seconds, then repeat every 0.3 seconds
		RepeatingHandle = System::SetTimer(this, n"RepeatingCallback", 0.3f, true);
		bRepeatingDelaySetup = true;
		Print("Repeating timer (0.3s interval) set up");
	}
}

bool Observe_TimerDelay_DefaultEmpty(ACoverageTimerDelayExecutionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerDelayExecution setup: required Actor is null");
	}
	return Actor.bShortDelaySetup == false
		&& Actor.bLongDelaySetup == false
		&& Actor.bRepeatingDelaySetup == false
		&& Actor.ShortDelayCallCount == 0
		&& Actor.RepeatingCallCount == 0;
}

bool Observe_TimerDelay_DirectCallbacks(ACoverageTimerDelayExecutionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerDelayExecution setup: required Actor is null");
	}
	Actor.ShortDelayCallback();
	Actor.RepeatingCallback();
	return Actor.ShortDelayCallCount == 1 && Actor.RepeatingCallCount == 1;
}
