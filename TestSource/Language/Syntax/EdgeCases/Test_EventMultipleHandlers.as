// Theme: Language.Syntax.EdgeCases. WorldStory one event, three handlers in bind order.
// C++: AngelscriptCoverageEventTests.cpp::EventMultipleHandlers
// sha256=c27005fc59ea3721f95f55dcfd1d14001a7a0d864f4e79ed07efaa9b8446917d; lines 427-474.
// Oracle after BeginPlay: Counter=111 (1+10+100); Result="ABC".
// Extra: local construct Counter=0 and empty Result. FixtureIsolated.

event void FCoverageGameEvent();

UCLASS()
class ACoverageEventMultipleHandlersActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	FCoverageGameEvent OnGameEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Bind multiple handlers to same event
		OnGameEvent.AddUFunction(this, n"Handler1");
		OnGameEvent.AddUFunction(this, n"Handler2");
		OnGameEvent.AddUFunction(this, n"Handler3");

		// Trigger event - all handlers should be called
		OnGameEvent.Broadcast();
	}

	UFUNCTION()
	void Handler1()
	{
		Counter += 1;
		Result += "A";
	}

	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
		Result += "B";
	}

	UFUNCTION()
	void Handler3()
	{
		Counter += 100;
		Result += "C";
	}
}

bool Observe_EventMultipleHandlers_DefaultEmpty(ACoverageEventMultipleHandlersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventMultipleHandlers setup: required Actor is null");
	}
	return Actor.Counter == 0 && Actor.Result.Len() == 0;
}
