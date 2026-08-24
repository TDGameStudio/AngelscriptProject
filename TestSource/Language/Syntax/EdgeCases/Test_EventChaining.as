// Theme: Language.Syntax.EdgeCases. WorldStory handler Broadcast chains three events.
// C++: AngelscriptCoverageEventTests.cpp::EventChaining
// sha256=aed6660dc78615fa0a5b5fc4fc01c5ff4dd4ae2202e94f2072aca4cfd857bd45; lines 1325-1378.
// Oracle: Counter=111; EventChain="First;Second;Third;". Extra: default Counter=0 empty chain.
// FixtureIsolated. Ordering is bind order plus nested Broadcast.

event void FCoverageChainEvent();

UCLASS()
class ACoverageEventChainingActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString EventChain;

	FCoverageChainEvent OnFirstEvent;
	FCoverageChainEvent OnSecondEvent;
	FCoverageChainEvent OnThirdEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Setup event chain
		OnFirstEvent.AddUFunction(this, n"HandleFirstEvent");
		OnSecondEvent.AddUFunction(this, n"HandleSecondEvent");
		OnThirdEvent.AddUFunction(this, n"HandleThirdEvent");

		// Trigger first event, which chains to others
		OnFirstEvent.Broadcast();
	}

	UFUNCTION()
	void HandleFirstEvent()
	{
		Counter += 1;
		EventChain += "First;";
		// Chain to second event
		OnSecondEvent.Broadcast();
	}

	UFUNCTION()
	void HandleSecondEvent()
	{
		Counter += 10;
		EventChain += "Second;";
		// Chain to third event
		OnThirdEvent.Broadcast();
	}

	UFUNCTION()
	void HandleThirdEvent()
	{
		Counter += 100;
		EventChain += "Third;";
	}
}

bool Observe_EventChaining_DefaultEmpty(ACoverageEventChainingActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventChaining setup: required Actor is null");
	}
	return Actor.Counter == 0 && Actor.EventChain.Len() == 0;
}
