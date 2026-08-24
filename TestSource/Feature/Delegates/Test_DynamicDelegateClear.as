// Theme: Feature.Delegates. WorldStory: multicast Clear removes all dynamic bindings.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateClear
// Spawn + BeginPlay oracle: Counter==1111 (1+10+100 first broadcast, then +1000 when unbound).
// Extra: default Counter 0; default event is unbound. Keep Counter.
// FixtureIsolated.

event void FCoverageDynamicClearEvent();

UCLASS()
class ACoverageDynamicClearActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	FCoverageDynamicClearEvent OnEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Add multiple listeners
		OnEvent.AddUFunction(this, n"Handler1");
		OnEvent.AddUFunction(this, n"Handler2");
		OnEvent.AddUFunction(this, n"Handler3");

		// Broadcast - all should be called
		OnEvent.Broadcast();

		// Clear all listeners
		OnEvent.Clear();

		// Broadcast again - none should be called
		OnEvent.Broadcast();

		// Verify not bound
		if (!OnEvent.IsBound())
		{
			Counter += 1000;
		}
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

	UFUNCTION()
	void Handler3()
	{
		Counter += 100;
	}
}

int Observe_Counter_DefaultZero(ACoverageDynamicClearActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateClear setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_OnEvent_DefaultUnbound(ACoverageDynamicClearActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateClear setup: required Actor is null");
	}
	return !Actor.OnEvent.IsBound();
}
