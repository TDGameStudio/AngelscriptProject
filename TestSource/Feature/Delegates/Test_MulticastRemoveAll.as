// Theme: Feature.Delegates. WorldStory: Unbind removes one (object, function) pair.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastRemoveAll
// Spawn + BeginPlay oracle: Counter==201 (Handler once + OtherHandler twice; AddUFunction is unique).
// Extra: default Counter 0; default event unbound. Keep Counter.
// FixtureIsolated.

event void FCoverageMulticastRemoveAllSignal();

UCLASS()
class ACoverageMulticastRemoveAllActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMulticastRemoveAllSignal OnMulticast;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Add the same (object, function) pair multiple times. AS AddUFunction is
		// add-unique for dynamic multicast delegates, so duplicate adds collapse to a
		// single binding rather than stacking three.
		OnMulticast.AddUFunction(this, n"Handler");
		OnMulticast.AddUFunction(this, n"Handler");
		OnMulticast.AddUFunction(this, n"Handler");

		// Add different function
		OnMulticast.AddUFunction(this, n"OtherHandler");

		// Broadcast - Handler (once, deduped) + OtherHandler.
		OnMulticast.Broadcast();

		// Unbind removes the (object, function) binding for Handler.
		OnMulticast.Unbind(this, n"Handler");

		// Broadcast again - only OtherHandler should be called
		OnMulticast.Broadcast();
	}

	UFUNCTION()
	void Handler()
	{
		Counter += 1;
	}

	UFUNCTION()
	void OtherHandler()
	{
		Counter += 100;
	}
}

int Observe_Counter_DefaultZero(ACoverageMulticastRemoveAllActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastRemoveAll setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_OnMulticast_DefaultUnbound(ACoverageMulticastRemoveAllActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastRemoveAll setup: required Actor is null");
	}
	return !Actor.OnMulticast.IsBound();
}
