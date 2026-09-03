/**
 * Multicast broadcast from Tick to a listener. After spawn, link, and Tick,
 * EventCallCount is at least 1 and LastFloatValue is 99.0. Local construct
 * leaves both at 0 and Broadcaster null.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateBroadcast
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateBroadcast
 * @Provenance Theme: Feature.Delegates. WorldStory multicast broadcast from Tick to a listener.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::DelegateBroadcast
 * @Provenance sha256=bcd5d5adaa5c2d2ec047c5b4b2e6ff8b54c60aad28901532a38b7e16ea362221; lines 621-665.
 * @Provenance Oracle after spawn+link+Tick: EventCallCount >= 1; LastFloatValue == 99.0.
 * @Provenance Extra: local construct leaves EventCallCount 0 and LastFloatValue 0.0; HandleTestEvent(0)
 * @Provenance is the zero-boundary write. FixtureIsolated. Tick owns Broadcast(99.0f).
 */

/**
 * A multicast event that reports a float.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Value
 * @Return nothing when broadcast
 */
event void FOnTestEvent(float Value);

UCLASS()
class ATestDelegateBroadcaster : AActor
{
	UPROPERTY()
	FOnTestEvent OnTestEvent;

	/**
	 * Broadcasts 99.0 each tick.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Broadcast
	 * @Param DeltaTime the frame delta
	 * @Inputs DeltaTime
	 * @Return nothing; OnTestEvent broadcasts 99.0
	 */
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

	/**
	 * Binds HandleTestEvent onto the broadcaster when one is set.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Broadcast
	 * @Inputs none
	 * @Return nothing; the listener is bound when Broadcaster is non-null
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Broadcaster != null)
		{
			Broadcaster.OnTestEvent.AddUFunction(this, n"HandleTestEvent");
		}
	}

	/**
	 * Records the broadcast value and increments the count.
	 *
	 * @Covers Delegates.Broadcast
	 * @Param Value the payload
	 * @Inputs Value
	 * @Return nothing; LastFloatValue and EventCallCount are written
	 */
	UFUNCTION()
	void HandleTestEvent(float Value)
	{
		LastFloatValue = Value;
		EventCallCount += 1;
	}

	/**
	 * Observe the default listener state.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs this
	 * @Return true when the count is 0, the last value is 0, and Broadcaster is null
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		if (LastFloatValue != 0.0)
		{
			return false;
		}
		return Broadcaster == null;
	}

	/**
	 * Observe a zero-boundary write through the handler.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs HandleTestEvent(0.0)
	 * @Return LastFloatValue after the write
	 * @Boundary zero value
	 */
	UFUNCTION()
	float ZeroBoundaryWrite()
	{
		HandleTestEvent(0.0);
		return LastFloatValue;
	}

	/**
	 * Observe that writing this leaves Second at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Second the other listener, runner-owned when non-null
	 * @Inputs HandleTestEvent(99.0) on this
	 * @Return true when this counted 1 and Second stays 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateListener Second)
	{
		if (Second is null)
		{
			throw("DelegateBroadcast setup: required Second is null");
		}
		HandleTestEvent(99.0);
		if (EventCallCount != 1)
		{
			return false;
		}
		if (Second.EventCallCount != 0)
		{
			return false;
		}
		return Second.LastFloatValue == 0.0;
	}
}
