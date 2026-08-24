// Theme: Gameplay.Debug. WorldStory interval Tick logging.
// C++: AngelscriptCoverageLoggingTests.cpp::PerformanceConsciousLogging
// Oracle VerifyByPath TickCounter 0, LogInterval 60 after spawn (before Tick).
// Extra: TickCounter 0 is the empty default; LogInterval 60 is the interval boundary.
// FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class APerformanceLogTestActor : AActor
{
	UPROPERTY()
	int TickCounter = 0;

	UPROPERTY()
	int LogInterval = 60;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("Actor initialized - will log every " + LogInterval + " ticks");
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCounter++;

		if (TickCounter % LogInterval == 0)
		{
			Print("[Tick " + TickCounter + "] Still running, DeltaSeconds: " + DeltaSeconds);
		}

		if (TickCounter == 100)
		{
			Print("Milestone: Reached 100 ticks");
		}
	}
}

bool Observe_PerformanceLog_Defaults(APerformanceLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PerformanceConsciousLogging setup: required Actor is null");
	}
	return Actor.TickCounter == 0 && Actor.LogInterval == 60;
}

bool Observe_PerformanceLog_IntervalBoundary(APerformanceLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PerformanceConsciousLogging setup: required Actor is null");
	}
	return (Actor.LogInterval != 0) && (60 % Actor.LogInterval == 0) && (1 % Actor.LogInterval != 0);
}
