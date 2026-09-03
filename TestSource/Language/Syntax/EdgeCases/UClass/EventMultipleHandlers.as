/**
 * One event with three handlers bound in order. A single broadcast must invoke
 * all three in bind order, which the appended string records.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EventMultipleHandlers
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.EventMultipleHandlers
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventMultipleHandlers
 * @Provenance sha256=c27005fc59ea3721f95f55dcfd1d14001a7a0d864f4e79ed07efaa9b8446917d; lines 427-474.
 * @Provenance Oracle after BeginPlay: Counter=111 (1+10+100); Result="ABC".
 * @Provenance Extra: local construct Counter=0 and empty Result. FixtureIsolated.
 */

/**
 * The game event carrying three bound handlers.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageGameEvent();

UCLASS()
class ACoverageEventMultipleHandlersActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	FCoverageGameEvent OnGameEvent;

	/**
	 * Binds three handlers and broadcasts once.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three handlers run
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnGameEvent.AddUFunction(this, n"Handler1");
		OnGameEvent.AddUFunction(this, n"Handler2");
		OnGameEvent.AddUFunction(this, n"Handler3");

		OnGameEvent.Broadcast();
	}

	/**
	 * The first bound handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1 and the result gains "A"
	 */
	UFUNCTION()
	void Handler1()
	{
		Counter += 1;
		Result += "A";
	}

	/**
	 * The second bound handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 10 and the result gains "B"
	 */
	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
		Result += "B";
	}

	/**
	 * The third bound handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 100 and the result gains "C"
	 */
	UFUNCTION()
	void Handler3()
	{
		Counter += 100;
		Result += "C";
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the counter is 0 and the result is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventMultipleHandlersDefaultToEmpty()
	{
		if (Counter != 0)
		{
			return false;
		}

		return Result.Len() == 0;
	}

	/**
	 * Observe the state after one broadcast reaches all three handlers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then both counters
	 * @Return true when the counter is 111 and the result is "ABC"
	 */
	UFUNCTION()
	bool EventMultipleHandlersAllRunInOrder()
	{
		BeginPlay();

		if (Counter != 111)
		{
			return false;
		}

		return Result == "ABC";
	}
}
