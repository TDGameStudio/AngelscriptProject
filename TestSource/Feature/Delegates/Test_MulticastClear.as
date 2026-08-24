// Theme: Feature.Delegates. WorldStory: multicast Clear drops every listener.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastClear
// Spawn + BeginPlay oracle: Counter==1111 (1+10+100 then +1000 unbound).
// Extra: default Counter 0; default event unbound. Keep Counter.
// FixtureIsolated.

event void FCoverageMulticastClearSignal();

UCLASS()
class ACoverageMulticastClearActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMulticastClearSignal OnMulticast;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Add multiple listeners
		OnMulticast.AddUFunction(this, n"Listener1");
		OnMulticast.AddUFunction(this, n"Listener2");
		OnMulticast.AddUFunction(this, n"Listener3");

		// Broadcast - all should be called
		OnMulticast.Broadcast();

		// Clear all listeners
		OnMulticast.Clear();

		// Broadcast again - none should be called
		OnMulticast.Broadcast();

		// Verify not bound
		if (!OnMulticast.IsBound())
		{
			Counter += 1000;
		}
	}

	UFUNCTION()
	void Listener1()
	{
		Counter += 1;
	}

	UFUNCTION()
	void Listener2()
	{
		Counter += 10;
	}

	UFUNCTION()
	void Listener3()
	{
		Counter += 100;
	}
}

int Observe_Counter_DefaultZero(ACoverageMulticastClearActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastClear setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_OnMulticast_DefaultUnbound(ACoverageMulticastClearActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastClear setup: required Actor is null");
	}
	return !Actor.OnMulticast.IsBound();
}
