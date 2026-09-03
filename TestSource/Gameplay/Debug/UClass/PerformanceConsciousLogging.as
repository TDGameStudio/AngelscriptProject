/**
 * Interval-based Tick logging, where the actor only prints every N ticks plus at a
 * milestone. C++ verifies the counter and interval by path before any tick, so the
 * UPROPERTY names are part of the contract and are kept verbatim.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.PerformanceConsciousLogging
 * @Harness UClass
 * @Tag Gameplay.Debug.PerformanceConsciousLogging
 * @Provenance Theme: Gameplay.Debug. WorldStory interval Tick logging.
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::PerformanceConsciousLogging
 * @Provenance Oracle VerifyByPath TickCounter 0, LogInterval 60 after spawn (before Tick).
 * @Provenance Extra: TickCounter 0 is the empty default; LogInterval 60 is the interval boundary.
 * @Provenance FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class APerformanceLogTestActor : AActor
{
	UPROPERTY()
	int TickCounter = 0;

	UPROPERTY()
	int LogInterval = 60;

	/**
	 * WorldStory: BeginPlay announces the interval it will log at.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.PerformanceConsciousLogging
	 * @Inputs none
	 * @Return one print naming LogInterval
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("Actor initialized - will log every " + LogInterval + " ticks");
	}

	/**
	 * WorldStory: Tick counts frames, prints on each interval boundary and announces
	 * the hundred-tick milestone.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.PerformanceConsciousLogging
	 * @Inputs the frame delta
	 * @Return a print every LogInterval ticks and one at tick 100
	 * @Param DeltaSeconds the frame delta
	 */
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

	/**
	 * Observe that a locally constructed actor keeps its declared counter and interval.
	 *
	 * @Kind Observe
	 * @Covers Debug.PerformanceConsciousLogging
	 * @Inputs an actor that has not been ticked
	 * @Return true when the counter is 0 and the interval is 60
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (TickCounter != 0)
		{
			return false;
		}
		return LogInterval == 60;
	}

	/**
	 * Observe that the interval divides its own frame cleanly and rejects the first tick.
	 *
	 * @Kind Observe
	 * @Covers Debug.PerformanceConsciousLogging
	 * @Inputs none
	 * @Return true when the interval is non-zero, divides 60 and does not divide 1
	 * @Boundary interval arithmetic
	 */
	UFUNCTION()
	bool IntervalBoundary()
	{
		if (LogInterval == 0)
		{
			return false;
		}
		if (60 % LogInterval != 0)
		{
			return false;
		}
		return 1 % LogInterval != 0;
	}
}
