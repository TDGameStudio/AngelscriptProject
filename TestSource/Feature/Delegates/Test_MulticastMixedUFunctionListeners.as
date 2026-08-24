// Theme: Feature.Delegates. WorldStory: mixed UFUNCTION listeners then targeted Unbind.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastMixedUFunctionListeners
// Spawn + BeginPlay oracle: Counter==21 (1+10 first broadcast, then Handler2 only = +10).
// Extra: default Counter 0; default event unbound. Keep Counter.
// FixtureIsolated.

event void FCoverageMixedUFunctionSignal();

UCLASS()
class ACoverageMulticastMixedUFunctionActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMixedUFunctionSignal OnMulticast;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticast.AddUFunction(this, n"Handler");
		OnMulticast.AddUFunction(this, n"Handler2");
		OnMulticast.Broadcast();

		OnMulticast.Unbind(this, n"Handler");
		OnMulticast.Broadcast();
	}

	UFUNCTION()
	void Handler()
	{
		Counter += 1;
	}

	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
	}
}

int Observe_Counter_DefaultZero(ACoverageMulticastMixedUFunctionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastMixedUFunctionListeners setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_OnMulticast_DefaultUnbound(ACoverageMulticastMixedUFunctionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastMixedUFunctionListeners setup: required Actor is null");
	}
	return !Actor.OnMulticast.IsBound();
}
