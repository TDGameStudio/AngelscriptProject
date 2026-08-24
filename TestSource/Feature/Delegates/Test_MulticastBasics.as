// Theme: Feature.Delegates. WorldStory: IsBound, AddUFunction, Broadcast, Clear.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastBasics
// Spawn + BeginPlay oracle: Counter==4 (unbound=1, bound=2, broadcast=3, cleared=4).
// Extra: default Counter 0; default event unbound. Keep Counter.
// FixtureIsolated.

event void FCoverageMulticastBasicsSignal();

UCLASS()
class ACoverageMulticastBasicsActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMulticastBasicsSignal OnMulticast;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test IsBound before adding listeners
		if (!OnMulticast.IsBound())
		{
			Counter = 1;
		}

		// Add listener
		OnMulticast.AddUFunction(this, n"HandleMulticast");

		// Test IsBound after adding
		if (OnMulticast.IsBound())
		{
			Counter = 2;
		}

		// Broadcast
		OnMulticast.Broadcast();

		// Clear all listeners
		OnMulticast.Clear();
		if (!OnMulticast.IsBound())
		{
			Counter = 4;
		}
	}

	UFUNCTION()
	void HandleMulticast()
	{
		Counter = 3;
	}
}

int Observe_Counter_DefaultZero(ACoverageMulticastBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastBasics setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_OnMulticast_DefaultUnbound(ACoverageMulticastBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastBasics setup: required Actor is null");
	}
	return !Actor.OnMulticast.IsBound();
}
