// Theme: Language.Syntax.EdgeCases. WorldStory Unbind removes one handler.
// C++: AngelscriptCoverageEventTests.cpp::EventUnbinding
// sha256=429b2297204b43e04219437ea649225b9dcd9c1c2824f004a89d87d642252773; lines 1202-1242.
// Oracle: Counter=21 (first Broadcast 1+10, second Broadcast 10 only). Extra: default 0.
// FixtureIsolated. Unbind(this, n"Handler1") does not clear Handler2.

event void FCoverageUnbindEvent();

UCLASS()
class ACoverageEventUnbindingActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	FCoverageUnbindEvent OnEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Bind handlers
		OnEvent.AddUFunction(this, n"Handler1");
		OnEvent.AddUFunction(this, n"Handler2");

		// Trigger event - both should be called
		OnEvent.Broadcast();

		// Unbind Handler1
		OnEvent.Unbind(this, n"Handler1");

		// Trigger event - only Handler2 should be called
		OnEvent.Broadcast();
	}

	UFUNCTION()
	void Handler1()
	{
		Counter += 1;
	}

	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
	}
}

bool Observe_EventUnbinding_DefaultEmpty(ACoverageEventUnbindingActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventUnbinding setup: required Actor is null");
	}
	return Actor.Counter == 0;
}
