// Theme: Feature.Delegates. WorldStory multicast broadcast from Tick to a listener.
// C++: AngelscriptActorInteractionTests.cpp::DelegateBroadcast
// sha256=bcd5d5adaa5c2d2ec047c5b4b2e6ff8b54c60aad28901532a38b7e16ea362221; lines 621-665.
// Oracle after spawn+link+Tick: EventCallCount >= 1; LastFloatValue == 99.0.
// Extra: local construct leaves EventCallCount 0 and LastFloatValue 0.0; HandleTestEvent(0)
// is the zero-boundary write. FixtureIsolated. Tick owns Broadcast(99.0f).

event void FOnTestEvent(float Value);

UCLASS()
class ATestDelegateBroadcaster : AActor
{
	UPROPERTY()
	FOnTestEvent OnTestEvent;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		OnTestEvent.Broadcast(99.0f);
	}
}

UCLASS()
class ATestDelegateListener : AActor
{
	UPROPERTY()
	ATestDelegateBroadcaster Broadcaster;

	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	float LastFloatValue = 0.0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Broadcaster != null)
		{
			Broadcaster.OnTestEvent.AddUFunction(this, n"HandleTestEvent");
		}
	}

	UFUNCTION()
	void HandleTestEvent(float Value)
	{
		LastFloatValue = Value;
		EventCallCount += 1;
	}
}

bool Observe_DelegateBroadcast_DefaultEmpty(ATestDelegateListener Listener)
{
	if (Listener is null)
	{
		throw("Test_DelegateBroadcast setup: required Listener is null");
	}
	return Listener.EventCallCount == 0 && Listener.LastFloatValue == 0.0 && Listener.Broadcaster == null;
}

float Observe_DelegateBroadcast_ZeroBoundaryWrite(ATestDelegateListener Listener)
{
	if (Listener is null)
	{
		throw("Test_DelegateBroadcast setup: required Listener is null");
	}
	Listener.HandleTestEvent(0.0);
	return Listener.LastFloatValue;
}

bool Observe_DelegateBroadcast_CopyIndependence(ATestDelegateListener First, ATestDelegateListener Second)
{
	if (First is null)
	{
		throw("Test_DelegateBroadcast setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DelegateBroadcast setup: required Second is null");
	}
	First.HandleTestEvent(99.0);
	return First.EventCallCount == 1 && Second.EventCallCount == 0 && Second.LastFloatValue == 0.0;
}
